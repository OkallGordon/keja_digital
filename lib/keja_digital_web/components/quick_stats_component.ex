defmodule KejaDigitalWeb.QuickStatsComponent do
  use KejaDigitalWeb, :live_component
  alias KejaDigital.{Store, Messages, Analytics}
  alias Phoenix.PubSub

  def mount(socket) do
    if connected?(socket) do
      :timer.send_interval(30000, self(), :update_stats)
      PubSub.subscribe(KejaDigital.PubSub, "system_stats")
    end

    {:ok, assign_stats(socket)}
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_stats()}
  end

  def handle_event("view_details", %{"stat" => stat_type}, socket) do
    route = case stat_type do
      "views" -> ~p"/analytics/views"
      "listings" -> ~p"/properties/active"
      "messages" -> ~p"/messages"
      "saved" -> ~p"/properties/saved"
    end

    {:noreply, push_navigate(socket, to: route)}
  end

  def handle_info(:update_stats, socket) do
    {:noreply, assign_stats(socket)}
  end

  defp assign_stats(socket) do
    socket
    |> assign(:total_views, Analytics.get_total_views())
    |> assign(:active_listings, Store.count_active_listings())
    |> assign(:total_messages, Messages.count_total_messages())
    |> assign(:saved_properties, Store.count_saved_properties())
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white shadow-sm">
      <div class="w-full px-4 lg:px-8 xl:px-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-6 py-6">
          <div
            phx-click="view_details"
            phx-value-stat="views"
            phx-target={@myself}
            class="p-6 rounded-lg bg-indigo-50 cursor-pointer hover:bg-indigo-100 transition-colors"
          >
            <div class="text-sm text-indigo-600 font-medium">Total Views</div>
            <div class="text-2xl font-bold text-indigo-900"><%= @total_views %></div>
            <div class="text-xs text-indigo-500 mt-1">Click for analytics</div>
          </div>

          <div
            phx-click="view_details"
            phx-value-stat="listings"
            phx-target={@myself}
            class="p-6 rounded-lg bg-green-50 cursor-pointer hover:bg-green-100 transition-colors"
          >
            <div class="text-sm text-green-600 font-medium">Active Listings</div>
            <div class="text-2xl font-bold text-green-900"><%= @active_listings %></div>
            <div class="text-xs text-green-500 mt-1">View active properties</div>
          </div>

          <div
            phx-click="view_details"
            phx-value-stat="messages"
            phx-target={@myself}
            class="p-6 rounded-lg bg-blue-50 cursor-pointer hover:bg-blue-100 transition-colors"
          >
            <div class="text-sm text-blue-600 font-medium">Messages</div>
            <div class="text-2xl font-bold text-blue-900"><%= @total_messages %></div>
            <div class="text-xs text-blue-500 mt-1">View all messages</div>
          </div>

          <div
            phx-click="view_details"
            phx-value-stat="saved"
            phx-target={@myself}
            class="p-6 rounded-lg bg-purple-50 cursor-pointer hover:bg-purple-100 transition-colors"
          >
            <div class="text-sm text-purple-600 font-medium">Saved Properties</div>
            <div class="text-2xl font-bold text-purple-900"><%= @saved_properties %></div>
            <div class="text-xs text-purple-500 mt-1">View saved properties</div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
