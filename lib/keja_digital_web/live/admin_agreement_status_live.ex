defmodule KejaDigitalWeb.AgreementStatusLive do
  use KejaDigitalWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "admin_notifications")
    end

    tenant_agreements = KejaDigital.Agreements.list_pending_tenant_agreements()

    {:ok,
     socket
     |> assign(:tenant_agreements, tenant_agreements)}
  end

  # Handle incoming real-time notifications for new agreements
  def handle_info({:new_tenant_agreement, tenant_agreement}, socket) do
    {:noreply,
     update(socket, :tenant_agreements, fn agreements ->
       [tenant_agreement | agreements]
     end)}
  end

  # Handle incoming real-time notifications for updated agreements
  def handle_info({:updated_tenant_agreement, updated_agreement}, socket) do
    {:noreply,
     update(socket, :tenant_agreements, fn agreements ->
       Enum.map(agreements, fn agreement ->
         if agreement.id == updated_agreement.id do
           updated_agreement
         else
           agreement
         end
       end)
       |> Enum.filter(&(&1.status == "pending_review")) # Only keep pending reviews
     end)}
  end

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
