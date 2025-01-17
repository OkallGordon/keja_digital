defmodule KejaDigitalWeb.AdminReviewLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Agreements
  alias KejaDigital.Notifications
  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="space-y-8">
          <div class="bg-white shadow-sm rounded-lg px-8 py-6">
            <.header class="flex items-center justify-between">
              <div>
                <h1 class="text-3xl font-bold text-gray-900">Tenant Agreement Reviews</h1>
                <p class="mt-2 text-lg text-gray-600">Review and manage tenant agreement submissions</p>
              </div>
              <div class="flex items-center space-x-3">
                <div class="flex items-center px-3 py-1 rounded-full bg-yellow-100">
                  <div class="w-2 h-2 rounded-full bg-yellow-400 mr-2"></div>
                  <span class="text-sm text-yellow-700">Pending</span>
                </div>
                <div class="flex items-center px-3 py-1 rounded-full bg-green-100">
                  <div class="w-2 h-2 rounded-full bg-green-400 mr-2"></div>
                  <span class="text-sm text-green-700">Approved</span>
                </div>
                <div class="flex items-center px-3 py-1 rounded-full bg-red-100">
                  <div class="w-2 h-2 rounded-full bg-red-400 mr-2"></div>
                  <span class="text-sm text-red-700">Rejected</span>
                </div>
              </div>
            </.header>
          </div>

          <div class="grid grid-cols-1 gap-6">
            <%= for agreement <- @pending_agreements do %>
              <div class="bg-white shadow-lg rounded-xl overflow-hidden transition-all duration-300 hover:shadow-xl">
                <div class="p-6">
                  <div class="flex justify-between items-start">
                    <div class="flex items-center space-x-4">
                      <div class="h-12 w-12 rounded-full bg-indigo-100 flex items-center justify-center">
                        <svg class="h-6 w-6 text-indigo-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                        </svg>
                      </div>
                      <div>
                        <h3 class="text-xl font-semibold text-gray-900"><%= agreement.tenant_name %></h3>
                        <p class="text-sm text-gray-500 flex items-center">
                          <svg class="h-4 w-4 mr-1" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                          </svg>
                          <%= Calendar.strftime(agreement.inserted_at, "%B %d, %Y at %I:%M %p") %>
                        </p>
                      </div>
                    </div>
                    <span class={[
                      "px-3 py-1 rounded-full text-sm font-medium",
                      status_color(agreement.status)
                    ]}>
                      <%= String.capitalize(agreement.status) %>
                    </span>
                  </div>

                  <div class="mt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="bg-gray-50 rounded-lg p-4 flex items-start space-x-3">
                      <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                        </svg>
                      </div>
                      <div>
                        <p class="text-sm font-medium text-gray-900">Phone</p>
                        <p class="mt-1 text-sm text-gray-500"><%= agreement.tenant_phone %></p>
                      </div>
                    </div>

                    <div class="bg-gray-50 rounded-lg p-4 flex items-start space-x-3">
                      <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                        </svg>
                      </div>
                      <div>
                        <p class="text-sm font-medium text-gray-900">Address</p>
                        <p class="mt-1 text-sm text-gray-500"><%= agreement.tenant_address %></p>
                      </div>
                    </div>

                    <div class="bg-gray-50 rounded-lg p-4 flex items-start space-x-3">
                      <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                        </svg>
                      </div>
                      <div>
                        <p class="text-sm font-medium text-gray-900">Start Date</p>
                        <p class="mt-1 text-sm text-gray-500"><%= agreement.start_date %></p>
                      </div>
                    </div>

                    <div class="bg-gray-50 rounded-lg p-4 flex items-start space-x-3">
                      <div class="flex-shrink-0">
                        <svg class="h-6 w-6 text-gray-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                      </div>
                      <div>
                        <p class="text-sm font-medium text-gray-900">Monthly Rent</p>
                        <p class="mt-1 text-sm text-gray-500">KES <%= agreement.rent %></p>
                      </div>
                    </div>
                  </div>

                  <%= if agreement.status == "pending_review" do %>
                    <div class="mt-6 flex items-center space-x-4">
                      <button
                        phx-click="approve_agreement"
                        phx-value-id={agreement.id}
                        class="flex-1 inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-colors duration-200"
                      >
                        <svg class="h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                        </svg>
                        Approve Agreement
                      </button>
                      <button
                        phx-click="reject_agreement"
                        phx-value-id={agreement.id}
                        class="flex-1 inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-lg shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-colors duration-200"
                      >
                        <svg class="h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                        Reject Agreement
                      </button>
                      <.link
                        navigate={~p"/tenant_agreement/#{agreement.id}"}
                        class="flex-1 inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-lg text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-200"
                      >
                        <svg class="h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                        </svg>
                        View Details
                      </.link>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "tenant_agreements")
    end

    {:ok,
     socket
     |> assign(:pending_agreements, list_pending_agreements())
     |> assign(:page_title, "Review Agreements")}
  end

  @impl true
  def handle_event("approve_agreement", %{"id" => id}, socket) do
    agreement = Agreements.get_tenant_agreement_live!(id)

    case Agreements.update_tenant_agreement_live(agreement, %{status: "approved"}) do
      {:ok, updated_agreement} ->
        notify_tenant_of_review(updated_agreement, "approved")

        {:noreply,
         socket
         |> update(:pending_agreements, fn agreements ->
           Enum.map(agreements, fn a ->
             if a.id == updated_agreement.id, do: updated_agreement, else: a
           end)
         end)
         |> put_flash(:info, "Agreement approved successfully")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to approve agreement")
         |> put_flash(:error_details, "Please try again or contact support if the issue persists")}
    end
  end

  def handle_event("reject_agreement", %{"id" => id}, socket) do
    agreement = Agreements.get_tenant_agreement_live!(id)

    case Agreements.update_tenant_agreement_live(agreement, %{status: "rejected"}) do
      {:ok, updated_agreement} ->
        notify_tenant_of_review(updated_agreement, "rejected")

        {:noreply,
         socket
         |> update(:pending_agreements, fn agreements ->
           Enum.map(agreements, fn a ->
             if a.id == updated_agreement.id, do: updated_agreement, else: a
           end)
         end)
         |> put_flash(:info, "Agreement rejected successfully")
         |> put_flash(:info, "Agreement rejected successfully")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to reject agreement")
         |> put_flash(:error_details, "Please try again or contact support if the issue persists")}
    end
  end

  @impl true
  def handle_info({:agreement_updated, agreement}, socket) do
    {:noreply,
     update(socket, :pending_agreements, fn agreements ->
       if Enum.any?(agreements, fn a -> a.id == agreement.id end) do
         Enum.map(agreements, fn a ->
           if a.id == agreement.id, do: agreement, else: a
         end)
       else
         [agreement | agreements]
       end
     end)}
  end

  # Additional helper function for filtering agreements by status
  defp list_pending_agreements do
    Agreements.list_tenant_agreements_by_status(["pending_review", "approved", "rejected"])
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
  end

  defp status_color(status) do
    case status do
      "pending_review" -> "bg-yellow-100 text-yellow-800 border border-yellow-200"
      "approved" -> "bg-green-100 text-green-800 border border-green-200"
      "rejected" -> "bg-red-100 text-red-800 border border-red-200"
      _ -> "bg-gray-100 text-gray-800 border border-gray-200"
    end
  end

  defp notify_tenant_of_review(agreement, status) do
    # Broadcast to the specific tenant's channel
    Phoenix.PubSub.broadcast(
      KejaDigital.PubSub,
      "tenant:#{agreement.tenant_name}",
      {:agreement_status_updated, %{
        status: status,
        agreement_id: agreement.id,
        updated_at: DateTime.utc_now()
      }}
    )

    # Create a notification record with enhanced message
    notification_content =
      case status do
        "approved" ->
          "Congratulations! Your tenancy agreement has been approved. You can now proceed with the next steps."

        "rejected" ->
          "Your tenancy agreement has been reviewed and requires some modifications. Please check your email for detailed feedback."

        _ ->
          "Your tenancy agreement status has been updated. Please check your dashboard for more information."
      end

    Notifications.create_notification(%{
      title: "Agreement #{String.capitalize(status)}",
      content: notification_content,
      tenant_name: agreement.tenant_name,
      agreement_id: agreement.id,
      notification_type: "agreement_#{status}",
      is_read: false,
      metadata: %{
        agreement_status: status,
        updated_at: DateTime.utc_now()
      }
    })

    # Log the review action for audit purposes
    Logger.info("Agreement #{agreement.id} #{status} by admin at #{DateTime.utc_now()}")
  end

  def format_currency(amount) when is_binary(amount) do
    case Float.parse(amount) do
      {number, _} -> format_currency(number)
      :error -> amount
    end
  end


  def format_currency(amount) when is_number(amount) do
    :erlang.float_to_binary(amount / 1, [decimals: 2])
    |> (fn str -> "KES " <> str end).()
    |> String.replace(~r/(\d)(?=(\d{3})+(?!\d))/, "\\1,")
  end

  def format_currency(_), do: "N/A"
end
