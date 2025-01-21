defmodule KejaDigitalWeb.MessagesLive.Index do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store
  alias KejaDigital.Messages

  @impl true
  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "messages")
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "system_stats")
    end

    current_user = Store.get_user_by_session_token(user_token)

    if current_user do
      {:ok,
       assign(socket,
         current_user: current_user,
         messages: list_messages(),
         total_messages: Messages.count_total_messages(),
         unread_messages: Messages.count_unread_messages(),
         filters: %{
           status: nil,
           type: nil,
           recipient_id: nil
         }
       )}
    else
      {:ok, push_navigate(socket, to: "/login")}
    end
  end

  @impl true
  def handle_event("filter", %{"filters" => filters}, socket) do
    {:noreply,
     assign(socket,
       messages: list_messages(filters),
       filters: Map.merge(socket.assigns.filters, atomize_keys(filters))
     )}
  end

  @impl true
  def handle_event("mark-as-read", %{"id" => message_id}, socket) do
    {:ok, _message} = Messages.mark_as_read(message_id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:message_created, _message}, socket) do
    {:noreply,
     assign(socket,
       messages: list_messages(socket.assigns.filters),
       total_messages: Messages.count_total_messages(),
       unread_messages: Messages.count_unread_messages()
     )}
  end

  @impl true
  def handle_info({:message_updated, _message}, socket) do
    {:noreply,
     assign(socket,
       messages: list_messages(socket.assigns.filters),
       total_messages: Messages.count_total_messages(),
       unread_messages: Messages.count_unread_messages()
     )}
  end

  @impl true
  def handle_info(:update_stats, socket) do
    {:noreply,
     assign(socket,
       total_messages: Messages.count_total_messages(),
       unread_messages: Messages.count_unread_messages()
     )}
  end

  defp list_messages(filters \\ %{}) do
    filters
    |> Map.take([:status, :type, :recipient_id])
    |> Enum.reject(fn {_k, v} -> is_nil(v) || v == "" end)
    |> Enum.into(%{})
    |> Messages.list_messages()
  end

  defp atomize_keys(map) do
    map
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
    |> Enum.into(%{})
  end

  defp format_datetime(datetime) do
    datetime
    |> Calendar.strftime("%B %d, %Y at %I:%M %p")
  end

  @impl true
  def render (assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
       <div class="mb-8 grid grid-cols-1 md:grid-cols-2 gap-4">
       <div class="bg-white rounded-lg shadow p-6">
         <h3 class="text-xl font-semibold mb-2">Total Messages</h3>
         <p class="text-3xl font-bold"><%= @total_messages %></p>
     </div>
     <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-semibold mb-2">Unread Messages</h3>
      <p class="text-3xl font-bold text-red-500"><%= @unread_messages %></p>
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
            <option value="unread" selected={@filters.status == "unread"}>Unread</option>
            <option value="read" selected={@filters.status == "read"}>Read</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium mb-2">Message Type</label>
          <select name="filters[type]" class="w-full rounded-md border-gray-300">
            <option value="">All</option>
            <option value="inquiry" selected={@filters.type == "inquiry"}>Inquiry</option>
            <option value="notification" selected={@filters.type == "notification"}>Notification</option>
            <option value="system" selected={@filters.type == "system"}>System</option>
           </select>
         </div>
       </div>
      </form>
     </div>

     <div class="bg-white rounded-lg shadow overflow-hidden">
      <div class="divide-y divide-gray-200">
       <%= for message <- @messages do %>
         <div class="p-6 hover:bg-gray-50 transition-colors duration-150 flex items-start gap-4">
           <div class="flex-1">
            <div class="flex items-center gap-2 mb-1">
              <%= if message.status == "unread" do %>
                <span class="w-2 h-2 rounded-full bg-red-500"></span>
              <% end %>
              <h4 class="font-semibold"><%= message.title %></h4>
              <span class="text-sm text-gray-500">
                <%= format_datetime(message.inserted_at) %>
              </span>
            </div>
            <p class="text-gray-600 mb-2"><%= message.content %></p>
            <div class="flex items-center gap-2 text-sm text-gray-500">
              <span class="px-2 py-1 rounded-full bg-gray-100">
                <%= message.message_type %>
              </span>
              <%= if message.read_at do %>
                <span class="text-gray-400">
                  Read <%= format_datetime(message.read_at) %>
                </span>
              <% else %>
                <button
                  phx-click="mark-as-read"
                  phx-value-id={message.id}
                  class="text-blue-500 hover:text-blue-600"
                >
                  Mark as read
                </button>
              <% end %>
              </div>
            </div>
           </div>
          <% end %>
         </div>
         </div>
      </div>
    """
  end
end
