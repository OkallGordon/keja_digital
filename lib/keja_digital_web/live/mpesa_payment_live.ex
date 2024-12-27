defmodule KejaDigitalWeb.MpesaPaymentLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Payments.MpesaPayment
  import Ecto.Query, except: [update: 2, update: 3]

  def mount(_params, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "mpesa_payments:#{session["tenant_id"]}")
    end

    socket =
      assign(socket,
        tenant_id: session["tenant_id"],
        payments: list_payments(session["tenant_id"]),
        start_date: Date.beginning_of_month(Date.utc_today()),
        end_date: Date.end_of_month(Date.utc_today()),
        till_number: "4154742"
      )

    {:ok, socket}
  end

  def handle_event("filter-dates", %{"start_date" => start_date, "end_date" => end_date}, socket) do
    start_date = Date.from_iso8601!(start_date)
    end_date = Date.from_iso8601!(end_date)

    {:noreply,
     socket
     |> assign(:start_date, start_date)
     |> assign(:end_date, end_date)
     |> assign(:payments, list_payments(socket.assigns.tenant_id, start_date, end_date))}
  end

  def handle_event("download-statement", _params, socket) do
    payments = list_payments(socket.assigns.tenant_id, socket.assigns.start_date, socket.assigns.end_date)

    case generate_pdf_statement(payments) do
      {:ok, statement_data} ->
        filename = "rent_statement_#{Date.to_string(socket.assigns.start_date)}_#{Date.to_string(socket.assigns.end_date)}.pdf"

        {:noreply,
         socket
         |> push_event("download-file", %{
           data: statement_data,
           filename: filename,
           content_type: "application/pdf"
         })}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_info({:payment_made, payment}, socket) do
    {:noreply, Phoenix.Component.update(socket, :payments, &[payment | &1])}
  end

  defp list_payments(tenant_id, start_date \\ nil, end_date \\ nil) do
    base_query = from(p in MpesaPayment, where: p.tenant_id == ^tenant_id)
    query = filter_by_date_range(base_query, start_date, end_date)

    query
    |> order_by([p], desc: p.paid_at)
    |> KejaDigital.Repo.all()
  end

  defp filter_by_date_range(query, nil, nil), do: query
  defp filter_by_date_range(query, start_date, end_date) do
    start_datetime = DateTime.new!(start_date, ~T[00:00:00.000], "Etc/UTC")
    end_datetime = DateTime.new!(end_date, ~T[23:59:59.999], "Etc/UTC")

    from(p in query,
      where: p.paid_at >= ^start_datetime and p.paid_at <= ^end_datetime
    )
  end

  defp generate_pdf_statement(payments) do

    html = Phoenix.Template.render_to_string(
      KejaDigitalWeb.PDFView,
      "statement.html",
      "html",
      payments: payments
    )

    PdfGenerator.generate(html, page_size: "A4")
    |> case do
      {:ok, path} ->
        File.read(path)
        |> case do
          {:ok, binary} -> {:ok, binary}
          {:error, reason} -> {:error, reason}
        end

      {:error, reason} -> {:error, reason}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto py-8">
      <div class="bg-white shadow rounded-lg p-6 mb-6">
        <h2 class="text-2xl font-bold mb-4">Make Rent Payment</h2>
        <div class="bg-gray-50 p-4 rounded-lg">
          <h3 class="font-semibold mb-2">Payment Instructions:</h3>
          <ol class="list-decimal list-inside space-y-2">
            <li>Go to M-PESA on your phone</li>
            <li>Select Pay Bill</li>
            <li>Enter Business Number: <%= @till_number %></li>
            <li>Enter Account Number: Your phone number</li>
            <li>Enter Amount</li>
            <li>Enter your M-PESA PIN and confirm payment</li>
          </ol>
        </div>
      </div>

      <div class="bg-white shadow rounded-lg p-6">
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-2xl font-bold">Payment History</h2>

          <div class="flex gap-4">
            <form phx-change="filter-dates" class="flex gap-4">
            <div>
              <label class="block text-sm text-gray-600">From</label>
              <input type="date" name="start_date" value={Date.to_iso8601(@start_date)} class="rounded border px-2 py-1">
            </div>
            <div>
              <label class="block text-sm text-gray-600">To</label>
              <input type="date" name="end_date" value={Date.to_iso8601(@end_date)} class="rounded border px-2 py-1">
              </div>
          </form>

          <button phx-click="download-statement" class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
              Download Statement
          </button>
        </div>
      </div>

      <table class="min-w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Transaction ID</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <%= for payment <- @payments do %>
           <tr>
            <td class="px-6 py-4 whitespace-nowrap">
              <%= Calendar.strftime(payment.paid_at, "%B %d, %Y") %>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
               KES <%= :erlang.float_to_binary(payment.amount / 1, [decimals: 2]) %>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
              <%= payment.transaction_id %>
            </td>
            <td class="px-6 py-4 whitespace-nowrap">
             <span class={
                case payment.status do
                  "completed" -> "bg-green-100 text-green-800"
                  "pending" -> "bg-yellow-100 text-yellow-800"
                  "failed" -> "bg-red-100 text-red-800"
                  _ -> "bg-gray-100 text-gray-800"
                end <> " px-2 py-1 rounded-full text-sm font-medium"
            }>
              <%= String.capitalize(payment.status) %>
            </span>
           </td>
          </tr>
         <% end %>
        </tbody>
       </table>
      </div>
     </div>
  """
  end
end
