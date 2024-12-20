defmodule KejaDigitalWeb.TenantAgreementLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Repo
  alias KejaDigital.Agreements.TenantAgreementLive

  def mount(%{"tenant_id" => tenant_id}, _session, socket) do
    # Log tenant_id for debugging
    IO.inspect(tenant_id, label: "Received tenant_id")

    # Subscribe to updates if the socket is connected
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "tenant_agreement:#{tenant_id}")
    end

    # Fetch the agreement
    case Repo.get_by(TenantAgreementLive, id: tenant_id) do
      nil ->
        {:ok, assign(socket, agreement: nil, error: "Agreement not found")}

      %TenantAgreementLive{} = agreement ->
        {:ok, assign(socket, agreement: agreement, error: nil)}
    end
  end

  # Handle the case where no params are provided
  def mount(_params, _session, socket) do
    {:ok, assign(socket, agreement: nil, error: "Invalid data")}
  end

  # Handle updates to the agreement
  def handle_info({:agreement_status_updated, updated_agreement}, socket) do
    {:noreply, assign(socket, agreement: updated_agreement)}
  end

  # Render the template
  def render(assigns) do
    ~H"""
    <div>
      <h1>Your Agreement Status</h1>
      <%= if @error do %>
        <p class="error"><%= @error %></p>
      <% else %>
        <p>
          Agreement Status:
          <span class={"badge " <> badge_class(@agreement.status)}>
            <%= @agreement.status %>
          </span>
        </p>
        <p>Submitted On: <%= @agreement.inserted_at %></p>
      <% end %>
    </div>
    """
  end

  # Helper to assign badge class dynamically
  defp badge_class("pending_review"), do: "badge-warning"
  defp badge_class("approved"), do: "badge-success"
  defp badge_class("rejected"), do: "badge-danger"
  defp badge_class(_), do: "badge-secondary"
end
