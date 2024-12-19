defmodule KejaDigitalWeb.AdminReviewLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Agreements
  alias KejaDigital.Notifications

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <.header>
        Tenant Agreement Reviews
        <:subtitle>Review and manage tenant agreement submissions</:subtitle>
      </.header>

      <div class="grid gap-6">
        <%= for agreement <- @pending_agreements do %>
          <div class="bg-white shadow rounded-lg p-6">
            <div class="flex justify-between items-start">
              <div>
                <h3 class="text-lg font-semibold"><%= agreement.tenant_name %></h3>
                <p class="text-sm text-gray-500">Submitted: <%= Calendar.strftime(agreement.inserted_at, "%B %d, %Y at %I:%M %p") %></p>
              </div>
              <span class={[
                "px-2 py-1 rounded-full text-xs",
                status_color(agreement.status)
              ]}>
                <%= String.capitalize(agreement.status) %>
              </span>
            </div>

            <div class="mt-4 grid grid-cols-2 gap-4">
              <div>
                <p class="text-sm font-medium text-gray-500">Phone</p>
                <p class="mt-1"><%= agreement.tenant_phone %></p>
              </div>
              <div>
                <p class="text-sm font-medium text-gray-500">Address</p>
                <p class="mt-1"><%= agreement.tenant_address %></p>
              </div>
              <div>
                <p class="text-sm font-medium text-gray-500">Start Date</p>
                <p class="mt-1"><%= agreement.start_date %></p>
              </div>
              <div>
                <p class="text-sm font-medium text-gray-500">Monthly Rent</p>
                <p class="mt-1">KES <%= agreement.rent %></p>
              </div>
            </div>

            <%= if agreement.status == "pending_review" do %>
              <div class="mt-6 flex space-x-3">
                <button
                  phx-click="approve_agreement"
                  phx-value-id={agreement.id}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700"
                >
                  Approve
                </button>
                <button
                  phx-click="reject_agreement"
                  phx-value-id={agreement.id}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700"
                >
                  Reject
                </button>
                <.link
                  navigate={~p"/agreements/#{agreement.id}"}
                  class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                >
                  View Details
                </.link>
              </div>
            <% end %>
          </div>
        <% end %>
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
        {:noreply, put_flash(socket, :error, "Failed to approve agreement")}
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
         |> put_flash(:info, "Agreement rejected")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to reject agreement")}
    end
  end

  @impl true
  def handle_info({:agreement_updated, agreement}, socket) do
    {:noreply, update(socket, :pending_agreements, fn agreements ->
      if Enum.any?(agreements, fn a -> a.id == agreement.id end) do
        Enum.map(agreements, fn a ->
          if a.id == agreement.id, do: agreement, else: a
        end)
      else
        [agreement | agreements]
      end
    end)}
  end

  defp list_pending_agreements do
    Agreements.list_tenant_agreements_by_status(["pending_review", "approved", "rejected"])
  end

  defp status_color(status) do
    case status do
      "pending_review" -> "bg-yellow-100 text-yellow-800"
      "approved" -> "bg-green-100 text-green-800"
      "rejected" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end
  end

  defp notify_tenant_of_review(agreement, status) do
    # Broadcast to the specific tenant's channel
    Phoenix.PubSub.broadcast(
      KejaDigital.PubSub,
      "tenant:#{agreement.tenant_name}",
      {:agreement_status_updated, %{
        status: status,
        updated_at: DateTime.utc_now()
      }}
    )

    # Create a notification record
    Notifications.create_notification(%{
      title: "Agreement #{String.capitalize(status)}",
      content: "Your tenancy agreement has been #{status} by the admin.",
      tenant_name: agreement.tenant_name,
      is_read: false
    })
  end
end
