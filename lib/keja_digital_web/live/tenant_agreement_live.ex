defmodule KejaDigitalWeb.TenantAgreementLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Repo
  alias KejaDigital.Agreements.TenantAgreementLive
  alias KejaDigital.Properties
  alias KejaDigital.Messages
  alias KejaDigital.Analytics
  alias KejaDigital.Store

  def mount(%{"tenant_id" => tenant_id}, _session, socket) do
    IO.inspect(tenant_id, label: "Received tenant_id")

    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "tenant_agreement:#{tenant_id}")
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "stats:#{tenant_id}")

      send(self(), :update_stats)
    end

    # Fetch the agreement
    case Repo.get_by(TenantAgreementLive, id: tenant_id) do
      nil ->
        {:ok, assign(socket, agreement: nil, error: "Agreement not found", stats: initial_stats())}

      %TenantAgreementLive{} = agreement ->
        {:ok,
         socket
         |> assign(agreement: agreement, error: nil)
         |> assign_stats()}
    end
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: send(self(), :update_stats)
    {:ok, assign(socket, agreement: nil, error: "Invalid data", stats: initial_stats())}
  end

  def handle_info({:agreement_status_updated, updated_agreement}, socket) do
    {:noreply, assign(socket, agreement: updated_agreement)}
  end

  def handle_info(:update_stats, socket) do
    {:noreply, assign_stats(socket)}
  end

  def handle_info(_, socket), do: {:noreply, socket}

  def render(assigns) do
    ~H"""
    <div>
      <h1>Your Agreement Status</h1>

      <div class="stats-summary">
        <div class="stat-card">
          <h3>Total Views</h3>
          <p><%= @stats.total_views %></p>
        </div>
        <div class="stat-card">
          <h3>Active Listings</h3>
          <p><%= @stats.active_listings %></p>
        </div>
        <div class="stat-card">
          <h3>Messages</h3>
          <p><%= @stats.total_messages %></p>
        </div>
      </div>

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

    # Helper functions for stats
    defp initial_stats do
      %{
        total_views: 0,
        active_listings: 0,
        total_messages: 0,
        saved_properties: 0
      }
    end

    defp assign_stats(socket) do
      stats = %{
        total_views: Analytics.get_total_views(),
        active_listings: Properties.count_active_listings(),
        total_messages: Messages.count_total_messages(),
        saved_properties: Store.count_saved_properties()
      }
      assign(socket, :stats, stats)
    rescue
      error ->
        IO.inspect(error, label: "Stats Error")
        assign(socket, :stats, initial_stats())
    end
end
