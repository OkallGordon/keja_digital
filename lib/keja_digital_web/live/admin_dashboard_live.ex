defmodule KejaDigitalWeb.DashboardLive do
  use KejaDigitalWeb, :live_view

  def mount(_params, _session, socket) do
    # Subscribe to admin notifications channel when the view mounts
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "admin_notifications")
    end

    # Fetch existing pending tenant agreements
    tenant_agreements = KejaDigital.Agreements.list_pending_tenant_agreements()

    {:ok,
     socket
     |> assign(:tenant_agreements, tenant_agreements)}
  end

  # Handle incoming real-time notifications
  def handle_info({:new_tenant_agreement, tenant_agreement}, socket) do
    # Update the socket with the new tenant agreement
    {:noreply,
     update(socket, :tenant_agreements, fn agreements ->
       [tenant_agreement | agreements]
     end)}
  end

  # In your Admin Dashboard LiveView
def render(assigns) do
  ~H"""
  <div>
    <h1>Tenant Agreements Pending Review</h1>
    <%= for agreement <- @tenant_agreements do %>
      <div class="tenant-agreement">
        <h2>Tenant: <%= agreement.tenant_name %></h2>
        <p>Submitted on: <%= agreement.inserted_at %></p>
        <p>Status: <%= agreement.status %></p>
        <.link
          navigate={~p"/tenant_agreement/#{agreement.id}"}
          class="btn btn-primary"
        >
          Review Agreement
        </.link>
      </div>
    <% end %>
  </div>
  """
end
end
