defmodule KejaDigitalWeb.PropertiesLive.Saved do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Properties
  alias KejaDigital.Store

  @impl true
  def mount(_params, session, socket) do
    # Fetch the current user from the session
    current_user = Store.get_user_by_session_token(session["user_token"])

    if current_user do
      properties = Properties.list_properties(saved: true)

      socket = assign(socket,
        current_user: current_user,
        properties: properties,
        filter_type: nil,
        min_price: nil,
        max_price: nil,
        sort_by: "inserted_at",
        sort_order: "desc",
        quick_stats: get_updated_stats()  # Initial quick stats
      )

      {:ok, socket}
    else
      # Redirect to login if the user is not authenticated
      {:ok, redirect(socket, to: "/login")}
    end
  end

  @impl true
  def handle_event("filter", %{"type" => type}, socket) do
    properties = Properties.list_properties(
      saved: true,
      type: type,
      min_price: socket.assigns.min_price,
      max_price: socket.assigns.max_price,
      sort_by: socket.assigns.sort_by,
      sort_order: socket.assigns.sort_order
    )

    {:noreply, assign(socket, properties: properties, filter_type: type)}
  end

  @impl true
  def handle_event("price_filter", %{"min" => min, "max" => max}, socket) do
    min_price = if min == "", do: nil, else: String.to_integer(min)
    max_price = if max == "", do: nil, else: String.to_integer(max)

    properties = Properties.list_properties(
      saved: true,
      type: socket.assigns.filter_type,
      min_price: min_price,
      max_price: max_price,
      sort_by: socket.assigns.sort_by,
      sort_order: socket.assigns.sort_order
    )

    {:noreply, assign(socket, properties: properties, min_price: min_price, max_price: max_price)}
  end

  @impl true
  def handle_event("sort", %{"field" => field}, socket) do
    # Toggle sort order if clicking the same field
    sort_order = if socket.assigns.sort_by == field && socket.assigns.sort_order == "asc", do: "desc", else: "asc"

    properties = Properties.list_properties(
      saved: true,
      type: socket.assigns.filter_type,
      min_price: socket.assigns.min_price,
      max_price: socket.assigns.max_price,
      sort_by: field,
      sort_order: sort_order
    )

    {:noreply, assign(socket, properties: properties, sort_by: field, sort_order: sort_order)}
  end

  @impl true
  def handle_event("unsave", %{"id" => property_id}, socket) do
    case Properties.toggle_saved(property_id) do
      {:ok, _property} ->
        properties = Properties.list_properties(
          saved: true,
          type: socket.assigns.filter_type,
          min_price: socket.assigns.min_price,
          max_price: socket.assigns.max_price,
          sort_by: socket.assigns.sort_by,
          sort_order: socket.assigns.sort_order
        )
        {:noreply, assign(socket, properties: properties)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Could not unsave property")}
    end
  end

  @impl true
  def handle_info({:property_updated, property}, socket) do
    # Only update if the property is in our list
    if Enum.any?(socket.assigns.properties, & &1.id == property.id) do
      properties = Properties.list_properties(
        saved: true,
        type: socket.assigns.filter_type,
        min_price: socket.assigns.min_price,
        max_price: socket.assigns.max_price,
        sort_by: socket.assigns.sort_by,
        sort_order: socket.assigns.sort_order
      )
      {:noreply, assign(socket, properties: properties)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:update_stats, socket) do
    # Logic to fetch and update stats (you can customize this based on your needs)
    updated_stats = get_updated_stats()

    # Update the socket with the new stats
    {:noreply, assign(socket, quick_stats: updated_stats)}
  end

  # Private function to get the updated statistics
  defp get_updated_stats do
    # Example of how you might retrieve stats (e.g., total number of properties, saved properties)
    %{
      total_views: 100,   # Example stat
      active_listings: 20,  # Example stat
      saved_properties: 15  # Example stat
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Header Section -->
        <div class="flex justify-between items-center mb-8">
          <div>
            <h1 class="text-3xl font-bold text-gray-900">Saved Properties</h1>
            <p class="mt-1 text-sm text-gray-500">
              Welcome back, <%= @current_user.full_name %>
            </p>
          </div>
          <div class="flex items-center gap-4">
            <span class="text-sm text-gray-600">
              <%= length(@properties) %> saved properties
            </span>
          </div>
        </div>

        <!-- Filters Section -->
        <div class="bg-white rounded-xl shadow-sm p-6 mb-8">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <!-- Property Type Filter -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Property Type
              </label>
              <form phx-change="filter">
                <select name="type" class="w-full rounded-lg border-gray-300 shadow-sm focus:ring-blue-500 focus:border-blue-500">
                  <option value="">All Types</option>
                  <option value="apartment" selected={@filter_type == "apartment"}>Apartment</option>
                  <option value="house" selected={@filter_type == "house"}>House</option>
                  <option value="commercial" selected={@filter_type == "commercial"}>Commercial</option>
                </select>
              </form>
            </div>

            <!-- Price Range Filter -->
            <div class="lg:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-2">
                Price Range (KES)
              </label>
              <form phx-change="price_filter" class="flex gap-4">
                <div class="flex-1">
                  <input
                    type="number"
                    name="min"
                    placeholder="Minimum"
                    value={@min_price}
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div class="flex-1">
                  <input
                    type="number"
                    name="max"
                    placeholder="Maximum"
                    value={@max_price}
                    class="w-full rounded-lg border-gray-300 shadow-sm focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </form>
            </div>
          </div>
        </div>

        <%= if Enum.empty?(@properties) do %>
          <!-- Empty State -->
          <div class="text-center bg-white rounded-xl shadow-sm p-12">
            <div class="mx-auto w-24 h-24 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <.icon name="hero-heart" class="w-12 h-12 text-gray-400" />
            </div>
            <h3 class="text-lg font-medium text-gray-900 mb-2">No saved properties yet</h3>
            <p class="text-gray-500 max-w-sm mx-auto mb-6">
              Start exploring our available properties and save your favorites to view them here.
            </p>
            <.link
              navigate={~p"/properties"}
              class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              Browse Properties
            </.link>
          </div>
        <% else %>
          <!-- Properties Grid -->
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <%= for property <- @properties do %>
              <div id={"property-#{property.id}"} class="bg-white rounded-xl shadow-sm overflow-hidden group hover:shadow-md transition-all duration-200">
                <!-- Property Image -->
                <div class="relative aspect-video">
                  <img src={property.image_url || "/images/placeholder.png"} alt={property.title} class="w-full h-full object-cover"/>
                  <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/0 to-black/0"/>
                  <div class="absolute top-4 right-4">
                    <button
                      phx-click="unsave"
                      phx-value-id={property.id}
                      class="p-2 rounded-full bg-white/90 hover:bg-white transition-colors duration-200 group"
                    >
                      <.icon name="hero-heart-solid" class="w-5 h-5 text-red-500" />
                    </button>
                  </div>
                  <div class="absolute bottom-4 left-4 right-4 flex justify-between items-end">
                    <span class="px-2.5 py-1 rounded-full text-xs font-medium bg-white/90 text-gray-900">
                      <%= String.capitalize(property.property_type) %>
                    </span>
                    <span class={status_badge_class(property.status)}>
                      <%= String.capitalize(property.status) %>
                    </span>
                  </div>
                </div>

                <!-- Property Details -->
                <div class="p-6">
                  <div class="mb-4">
                    <div class="flex justify-between items-start mb-2">
                      <h3 class="text-lg font-semibold text-gray-900 line-clamp-1">
                        <%= property.title %>
                      </h3>
                      <p class="text-lg font-bold text-blue-600">
                        <%= format_price(property.price) %>
                      </p>
                    </div>
                    <p class="text-sm text-gray-600 flex items-center gap-1">
                      <.icon name="hero-map-pin" class="w-4 h-4" />
                      <%= property.location %>
                    </p>
                  </div>

                  <!-- Property Features -->
                  <div class="grid grid-cols-3 gap-4 py-4 border-t border-gray-100">
                    <%= if property.bedrooms do %>
                      <div class="text-center">
                        <.icon name="hero-home" class="w-5 h-5 mx-auto text-gray-400 mb-1" />
                        <span class="text-sm text-gray-600"><%= property.bedrooms %> Beds</span>
                      </div>
                    <% end %>
                    <%= if property.bathrooms do %>
                      <div class="text-center">
                        <.icon name="hero-beaker" class="w-5 h-5 mx-auto text-gray-400 mb-1" />
                        <span class="text-sm text-gray-600"><%= property.bathrooms %> Baths</span>
                      </div>
                    <% end %>
                    <%= if property.floor_area do %>
                      <div class="text-center">
                        <.icon name="hero-square-2-stack" class="w-5 h-5 mx-auto text-gray-400 mb-1" />
                        <span class="text-sm text-gray-600"><%= property.floor_area %> sq ft</span>
                      </div>
                    <% end %>
                  </div>

                  <!-- Actions -->
                  <div class="mt-4 flex justify-between items-center">
                    <.link
                      navigate={~p"/properties/active"}
                      class="text-sm font-medium text-blue-600 hover:text-blue-700 flex items-center gap-1"
                    >
                      View Details
                      <.icon name="hero-arrow-right" class="w-4 h-4" />
                    </.link>
                    <button
                      phx-click="unsave"
                      phx-value-id={property.id}
                      class="inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                    >
                      <.icon name="hero-trash" class="w-4 h-4 mr-1 text-gray-400" />
                      Remove
                    </button>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper functions
  defp status_badge_class(status) do
    base_classes = "px-2.5 py-1 rounded-full text-xs font-medium"

    status_specific_classes = case status do
      "active" -> "bg-green-100 text-green-800"
      "pending" -> "bg-yellow-100 text-yellow-800"
      "sold" -> "bg-red-100 text-red-800"
      _ -> "bg-gray-100 text-gray-800"
    end

    "#{base_classes} #{status_specific_classes}"
  end

  defp format_price(price) do
    "KES #{Number.Currency.number_to_currency(price, unit: "", precision: 0)}"
  end
end
