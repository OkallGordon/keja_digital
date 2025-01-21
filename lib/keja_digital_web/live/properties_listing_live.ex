defmodule KejaDigitalWeb.PropertiesLive.Active do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store
  alias KejaDigital.Properties

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "properties")
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "system_stats")
    end

    current_user =
      case Store.get_user_by_session_token(user_token) do
        nil -> nil
        user -> user
      end

    {:ok,
     socket
     |> assign(current_user: current_user)
     |> assign(
       filters: %{
         status: nil,
         type: nil,
         owner_id: nil,
         min_price: nil,
         max_price: nil,
         sort_by: "inserted_at",
         sort_order: "desc"
       }
     )
     |> load_properties()
     |> load_stats()}
  end

  @impl true
  def handle_event("filter", %{"filters" => filters}, socket) do
    {:noreply,
     socket
     |> assign(filters: Map.merge(socket.assigns.filters, atomize_keys(filters)))
     |> load_properties()}
  end

  @impl true
  def handle_event("toggle-saved", %{"id" => property_id}, socket) do
    case Properties.toggle_saved(property_id) do
      {:ok, _property} ->
        {:noreply,
         socket
         |> load_stats()}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Could not update saved status")}
    end
  end

  # Handle property updates
  @impl true
  def handle_info({event, _property}, socket)
      when event in [:property_created, :property_updated] do
    {:noreply,
     socket
     |> load_properties()
     |> load_stats()}
  end

  # Handle stats updates from PubSub
  @impl true
  def handle_info(:stats_updated, socket) do
    {:noreply, load_stats(socket)}
  end

  # Handle stats updates from QuickStatsComponent
  @impl true
  def handle_info(:update_stats, socket) do
    {:noreply, load_stats(socket)}
  end

  # Add catch-all handler for any unhandled messages
  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  # Private functions
  defp load_properties(socket) do
    properties = list_properties(socket.assigns.filters)
    assign(socket, :properties, properties)
  end

  defp load_stats(socket) do
    socket
    |> assign(:active_listings, Properties.count_active_listings())
    |> assign(:saved_properties, Properties.count_saved_properties())
  end

  defp list_properties(filters) do
    filters
    |> Map.take([:status, :type, :owner_id, :min_price, :max_price, :sort_by, :sort_order])
    |> Enum.reject(fn {_k, v} -> is_nil(v) || v == "" end)
    |> Enum.into(%{})
    |> Properties.list_properties()
  end

  defp atomize_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end

  @impl true
  def render(assigns) do
  ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="mb-8 grid grid-cols-1 md:grid-cols-3 gap-4">
    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-semibold mb-2">Active Listings</h3>
      <p class="text-3xl font-bold"><%= @active_listings %></p>
    </div>
    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-semibold mb-2">Saved Properties</h3>
      <p class="text-3xl font-bold"><%= @saved_properties %></p>
    </div>
  </div>

  <div class="bg-white rounded-lg shadow p-6 mb-8">
    <h3 class="text-xl font-semibold mb-4">Filters</h3>
    <form phx-change="filter">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium mb-2">Status</label>
          <select name="filters[status]" class="w-full rounded-md border-gray-300">
            <option value="">All</option>
            <option value="active" selected={@filters.status == "active"}>Active</option>
            <option value="pending" selected={@filters.status == "pending"}>Pending</option>
            <option value="sold" selected={@filters.status == "sold"}>Sold</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium mb-2">Property Type</label>
          <select name="filters[type]" class="w-full rounded-md border-gray-300">
            <option value="">All</option>
            <option value="apartment" selected={@filters.type == "apartment"}>Apartment</option>
            <option value="house" selected={@filters.type == "house"}>House</option>
            <option value="commercial" selected={@filters.type == "commercial"}>Commercial</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium mb-2">Sort By</label>
          <select name="filters[sort_by]" class="w-full rounded-md border-gray-300">
            <option value="inserted_at" selected={@filters.sort_by == "inserted_at"}>Date Added</option>
            <option value="price" selected={@filters.sort_by == "price"}>Price</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium mb-2">Min Price</label>
          <input
            type="number"
            name="filters[min_price]"
            value={@filters.min_price}
            class="w-full rounded-md border-gray-300"
          />
        </div>

        <div>
          <label class="block text-sm font-medium mb-2">Max Price</label>
          <input
            type="number"
            name="filters[max_price]"
            value={@filters.max_price}
            class="w-full rounded-md border-gray-300"
          />
        </div>

        <div>
          <label class="block text-sm font-medium mb-2">Sort Order</label>
          <select name="filters[sort_order]" class="w-full rounded-md border-gray-300">
            <option value="desc" selected={@filters.sort_order == "desc"}>Descending</option>
            <option value="asc" selected={@filters.sort_order == "asc"}>Ascending</option>
          </select>
        </div>
      </div>
    </form>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
    <%= for property <- @properties do %>
      <div class="bg-white rounded-lg shadow overflow-hidden">
        <img src={property.image_url} alt={property.title} class="w-full h-48 object-cover"/>
        <div class="p-6">
          <h3 class="text-xl font-semibold mb-2"><%= property.title %></h3>
          <p class="text-gray-600 mb-4"><%= property.description %></p>
          <div class="flex justify-between items-center">
          <span class="text-2xl font-bold">Ksh.<%= Number.Delimit.number_to_delimited(property.price) %></span>
            <button
              phx-click="toggle-saved"
              phx-value-id={property.id}
              class={"#{if property.saved, do: "text-red-500", else: "text-gray-400"} hover:text-red-500"}
            >
              <i class="fas fa-heart text-xl"></i>
            </button>
          </div>
        </div>
      </div>
    <% end %>
  </div>
</div>
"""
end
end
