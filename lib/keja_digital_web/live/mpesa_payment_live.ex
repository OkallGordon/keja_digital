defmodule KejaDigitalWeb.MpesaPaymentLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Payments.MpesaPayment
  alias KejaDigital.Services.PDFGenerator
  import Ecto.Query, except: [update: 2, update: 3]

  def mount(_params, _session, %{assigns: %{current_user: nil}} = socket) do
    {:ok, redirect(socket, to: "user/log_in")}
  end

  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "mpesa_payments:#{user.id}")
    end

    socket =
      assign(socket,
        tenant_id: user.id,
        user: user,
        payments: list_payments(user.id),
        start_date: Date.beginning_of_month(Date.utc_today()),
        end_date: Date.end_of_month(Date.utc_today()),
        till_number: "4154742",
        search: "",
        sort_by: :paid_at,
        sort_direction: :desc,
        loading: false
      )

    {:ok, socket, temporary_assigns: [payments: []]}
  end
  def handle_event("filter-dates", %{"start_date" => start_date, "end_date" => end_date}, socket) do
    case {Date.from_iso8601(start_date), Date.from_iso8601(end_date)} do
      {{:ok, parsed_start_date}, {:ok, parsed_end_date}} ->
        # Ensure start date is not after end date
        if Date.compare(parsed_start_date, parsed_end_date) in [:lt, :eq] do
          {:noreply,
           socket
           |> assign(:start_date, parsed_start_date)
           |> assign(:end_date, parsed_end_date)
           |> assign(:loading, true)
           |> load_payments()}
        else
          {:noreply,
           socket
           |> put_flash(:error, "Start date must be before or equal to end date")
           |> assign(:loading, false)}
        end
      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "Invalid date format")
         |> assign(:loading, false)}
    end
  end

  def handle_event("download-statement", _params, socket) do
    payments = list_payments(socket.assigns.tenant_id, socket.assigns.start_date, socket.assigns.end_date)
    user = socket.assigns.user

    user_credentials = %{
      full_name: user.full_name,
      door_number: user.door_number,
      email: user.email,
      role: "Tenant"
    }

    case PDFGenerator.generate_statement(payments, user_credentials) do
      {:ok, statement_data} ->
        filename = "rent_statement_#{Date.to_string(socket.assigns.start_date)}_#{Date.to_string(socket.assigns.end_date)}.pdf"

        {:noreply,
         socket
         |> push_event("download-file", %{
           data: Base.encode64(statement_data),
           filename: filename,
           content_type: "application/pdf"
         })}

      {:error, _reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to generate PDF statement")}
    end
  end

  def handle_event("search", %{"search_term" => term}, socket) do
    payments = list_payments(
      socket.assigns.tenant_id,
      socket.assigns.start_date,
      socket.assigns.end_date,
      term
    )

    {:noreply,
     socket
     |> assign(:search_term, term)
     |> assign(:payments, payments)}
  end

  def handle_event("sort", %{"field" => field}, socket) do
    {field, direction} = sort_params(field, socket.assigns.sort_by, socket.assigns.sort_direction)

    {:noreply,
     socket
     |> assign(:sort_by, field)
     |> assign(:sort_direction, direction)
     |> assign(:loading, true)
     |> load_payments()}
  end

  def handle_event("navigate_to_rent_payment", _, socket) do
    {:noreply, push_navigate(socket, to: ~p"/rent/payment")}
  end
  def handle_info({:payment_made, _payment}, socket) do
    {:noreply,
     socket
     |> assign(:loading, true)
     |> load_payments()}
  end

  def handle_info(:update_stats, socket) do
    {:noreply,
     socket
     |> assign(:loading, true)
     |> load_payments()}
  end

  defp load_payments(socket) do
    payments = list_payments(
      socket.assigns.tenant_id,
      socket.assigns.start_date,
      socket.assigns.end_date,
      socket.assigns.search,
      socket.assigns.sort_by,
      socket.assigns.sort_direction
    )
    assign(socket, payments: payments, loading: false)
  end

  defp list_payments(tenant_id, start_date \\ nil, end_date \\ nil, search \\ "", sort_by \\ :paid_at, sort_direction \\ :desc) do
    if is_nil(tenant_id) do
      []
    else
      base_query = from(p in MpesaPayment, where: p.tenant_id == ^tenant_id)

      base_query
      |> filter_by_date_range(start_date, end_date)
      |> filter_by_search(search)
      |> order_by([p], [{^sort_direction, field(p, ^sort_by)}])
      |> KejaDigital.Repo.all()
    end
  end

  defp filter_by_search(query, ""), do: query
  defp filter_by_search(query, search) do
    search_term = "%#{search}%"
    from p in query,
      where: ilike(p.transaction_id, ^search_term) or
             ilike(fragment("CAST(? AS TEXT)", p.amount), ^search_term)
  end

  defp filter_by_date_range(query, nil, nil), do: query
  defp filter_by_date_range(query, start_date, nil) when not is_nil(start_date) do
    start_datetime = DateTime.new!(start_date, ~T[00:00:00.000], "Etc/UTC")
    from(p in query,
      where: p.paid_at >= ^start_datetime
    )
  end
  defp filter_by_date_range(query, nil, end_date) when not is_nil(end_date) do
    end_datetime = DateTime.new!(end_date, ~T[23:59:59.999], "Etc/UTC")
    from(p in query,
      where: p.paid_at <= ^end_datetime
    )
  end
  defp filter_by_date_range(query, start_date, end_date) when not is_nil(start_date) and not is_nil(end_date) do
    start_datetime = DateTime.new!(start_date, ~T[00:00:00.000], "Etc/UTC")
    end_datetime = DateTime.new!(end_date, ~T[23:59:59.999], "Etc/UTC")
    from(p in query,
      where: p.paid_at >= ^start_datetime and p.paid_at <= ^end_datetime
    )
  end

  defp sort_params(field, current_field, current_direction) do
    field = String.to_existing_atom(field)
    if field == current_field do
      {field, if(current_direction == :asc, do: :desc, else: :asc)}
    else
      {field, :asc}
    end
  end

  defp sort_indicator(field, sort_by, sort_direction) when field == sort_by do
    case sort_direction do
      :asc -> "↑"
      :desc -> "↓"
    end
  end

  defp sort_indicator(_, _, _), do: ""

  defp status_color_class(status) do
    base_class = "px-2 py-1 rounded-full text-sm font-medium"

    status_specific_class = case status do
      "completed" -> "bg-green-100 text-green-800"
      "pending" -> "bg-yellow-100 text-yellow-800"
      "failed" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end

    "#{base_class} #{status_specific_class}"
  end
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="grid grid-cols-1 lg:grid-cols-[400px,1fr] gap-8">
        <div class="bg-white shadow-lg rounded-xl p-8 h-fit">
          <div class="space-y-8">
            <div>
              <h2 class="text-3xl font-bold mb-6 text-gray-800">Make Payment</h2>

              <div class="bg-blue-50 border-l-6 border-blue-500 p-5 rounded-lg mb-8">
                <p class="text-blue-700 font-bold text-xl">Business Number: <%= @till_number %></p>
                <p class="text-sm text-blue-600 mt-2">Save this number for future payments</p>
              </div>
            </div>

            <div class="bg-gray-50 p-6 rounded-lg">
              <h3 class="font-semibold mb-4 text-xl text-gray-800">Payment Steps</h3>
              <ol class="list-decimal list-inside space-y-4 text-gray-700 text-base">
                <li>Open M-PESA on your phone</li>
                <li>Select <span class="font-medium text-gray-900">Buy Goods And Services</span> option</li>
                <li>Enter The Till Number: <span class="font-medium text-gray-900"><%= @till_number %></span></li>
                <li>Enter Payment/Rent amount</li>
                <li>Confirm with your M-PESA PIN</li>
              </ol>
            </div>

            <div>
              <button
                 phx-click="navigate_to_rent_payment"
                 class="w-full bg-green-600 text-white px-6 py-4 rounded-xl hover:bg-green-700 transition-colors duration-300 font-bold text-xl shadow-md"
                >
                Pay Rent
            </button>

            </div>
          </div>
        </div>

        <div class="bg-white shadow-lg rounded-xl p-8">
          <div class="mb-8">
            <h2 class="text-3xl font-bold text-gray-800 mb-6">Payment History</h2>

            <div class="flex flex-col md:flex-row justify-between items-center gap-6 mb-6">
              <form phx-change="filter-dates" class="flex gap-4 w-full md:w-auto">
                <div class="flex-1">
                  <label class="block text-sm text-gray-600 mb-2">From</label>
                  <input
                    type="date"
                    name="start_date"
                    value={Date.to_iso8601(@start_date)}
                    class="w-full rounded-lg border-gray-300 px-4 py-2.5 focus:ring-blue-500 focus:border-blue-500"
                  >
                </div>
                <div class="flex-1">
                  <label class="block text-sm text-gray-600 mb-2">To</label>
                  <input
                    type="date"
                    name="end_date"
                    value={Date.to_iso8601(@end_date)}
                    class="w-full rounded-lg border-gray-300 px-4 py-2.5 focus:ring-blue-500 focus:border-blue-500"
                  >
                </div>
              </form>

              <div class="flex flex-col md:flex-row gap-4 w-full md:w-auto">
                <form phx-change="search" phx-submit="search" class="flex-1">
                  <label class="block text-sm text-gray-600 mb-2">Search</label>
                  <input
                    type="text"
                    name="search_term"
                    value={@search}
                    placeholder="Search payments..."
                    class="w-full rounded-lg border-gray-300 px-4 py-2.5 focus:ring-blue-500 focus:border-blue-500"
                    autocomplete="off"
                    phx-debounce="500"
                  />
                </form>

                <div id="download-container" phx-hook="DownloadFile" class="self-end">
                  <button
                    phx-click="download-statement"
                    class="w-full md:w-auto bg-blue-600 text-white px-6 py-2.5 rounded-lg hover:bg-blue-700 transition flex items-center justify-center gap-2"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                      <polyline points="7 10 12 15 17 10"></polyline>
                      <line x1="12" y1="15" x2="12" y2="3"></line>
                    </svg>
                    Download Statement
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="overflow-x-auto relative">
            <%= if @loading do %>
              <div class="absolute inset-0 bg-white bg-opacity-75 flex items-center justify-center z-10">
                <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
              </div>
            <% end %>

            <%= if Enum.empty?(@payments) do %>
              <div class="text-center py-16">
                <h3 class="text-2xl font-medium text-gray-900 mb-4">No payments found</h3>
                <p class="text-lg text-gray-500">
                  <%= if @start_date && @end_date do %>
                    No payments found between <%= Date.to_string(@start_date) %> and <%= Date.to_string(@end_date) %>
                  <% else %>
                    Payments will appear here once they are processed.
                  <% end %>
                </p>
              </div>
            <% else %>
              <table class="w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <%= for {field, label} <- [
                      {"paid_at", "Date"},
                      {"amount", "Amount"},
                      {"transaction_id", "Transaction ID"},
                      {"status", "Status"}
                    ] do %>
                      <th
                        phx-click="sort"
                        phx-value-field={field}
                        class="px-6 py-4 text-left text-sm font-medium text-gray-500 uppercase tracking-wider cursor-pointer hover:bg-gray-100"
                      >
                        <%= label %>
                        <span class="ml-1">
                          <%= sort_indicator(String.to_existing_atom(field), @sort_by, @sort_direction) %>
                        </span>
                      </th>
                    <% end %>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <%= for payment <- @payments do %>
                    <tr class="hover:bg-gray-50 transition duration-150">
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        <%= Calendar.strftime(payment.paid_at, "%B %d, %Y %H:%M") %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        KES <%= :erlang.float_to_binary(payment.amount / 1, [decimals: 2]) %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 font-mono">
                        <%= payment.transaction_id %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <span class={status_color_class(payment.status)}>
                          <%= String.capitalize(payment.status) %>
                        </span>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
