defmodule KejaDigitalWeb.Admin.AuditLogsLive do
  use Phoenix.LiveView
  import Ecto.Query
  alias KejaDigital.Audit
  alias KejaDigital.Repo

  @valid_fields [:actor_email, :actor_id, :action, :target_type, :inserted_at]

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "audit_logs")
    end

    {:ok,
     socket
     |> assign(:logs, list_logs())
     |> assign(:filter_field, nil)
     |> assign(:filter_value, nil)
     |> assign(:loading, false)
     |> assign(:error, nil)
     |> assign(:valid_fields, @valid_fields)}
  end

  def handle_event("filter", %{"filter" => %{"field" => field, "value" => value}}, socket) do
    field_atom = if field != "", do: String.to_existing_atom(field), else: nil

    filter =
      if field_atom in @valid_fields do
        %{field_atom => value}
      else
        %{}
      end

    {:noreply,
     socket
     |> assign(:loading, true)
     |> assign(:filter_field, field)
     |> assign(:filter_value, value)
     |> fetch_logs(filter)}
  rescue
    ArgumentError ->
      {:noreply,
       socket
       |> assign(:error, "Invalid filter field selected")
       |> assign(:loading, false)}
  end

  def handle_info({:audit_log_created, log}, socket) do
    updated_logs =
      [log | socket.assigns.logs]
      |> Enum.take(100)

    {:noreply, assign(socket, :logs, updated_logs)}
  end

  defp fetch_logs(socket, filter) do
    logs = list_logs(filter)

    socket
    |> assign(:logs, logs)
    |> assign(:loading, false)
    |> assign(:error, nil)
  rescue
    e ->
      socket
      |> assign(:error, "Error fetching logs: #{Exception.message(e)}")
      |> assign(:loading, false)
  end

  defp list_logs(filter \\ %{}) do
    base_query = from(a in Audit, order_by: [desc: a.inserted_at], limit: 100)

    filter
    |> Enum.reduce(base_query, fn
      {field, value}, query when is_binary(value) and byte_size(value) > 0 ->
        case field do
          :inserted_at ->
            from q in query,
              where: fragment("CAST(? AS TEXT) LIKE ?", field(q, ^field), ^"#{value}%")
          _ ->
            from q in query,
              where: fragment("CAST(? AS TEXT) ILIKE ?", field(q, ^field), ^"%#{value}%")
        end
      _, query -> query
    end)
    |> Repo.all()
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-6 px-4 sm:px-6 lg:px-8">
      <div class="max-w-7xl mx-auto">
        <!-- Header Section -->
        <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
          <div class="flex items-center justify-between">
            <div>
              <h1 class="text-2xl font-bold text-gray-900">Audit Logs</h1>
              <p class="mt-1 text-sm text-gray-500">Track and monitor system activities</p>
            </div>
            <div class="flex items-center space-x-2 text-sm text-gray-600">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <span>Last 100 entries</span>
            </div>
          </div>
        </div>

        <!-- Filter Section -->
        <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
          <form phx-change="filter" class="space-y-4 sm:space-y-0 sm:flex sm:items-end sm:space-x-4">
            <div class="flex-1">
              <label for="filter_field" class="block text-sm font-medium text-gray-700 mb-1">
                Filter by field
              </label>
              <select
                name="filter[field]"
                class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 rounded-md"
                value={@filter_field}
              >
                <option value="">Select a field</option>
                <%= for field <- @valid_fields do %>
                  <option value={field}><%= Phoenix.Naming.humanize(field) %></option>
                <% end %>
              </select>
            </div>

            <div class="flex-1">
              <label for="filter_value" class="block text-sm font-medium text-gray-700 mb-1">
                Search value
              </label>
              <div class="mt-1 relative rounded-md shadow-sm">
                <input
                  type="text"
                  name="filter[value]"
                  value={@filter_value}
                  class="focus:ring-indigo-500 focus:border-indigo-500 block w-full pl-3 pr-10 py-2 border-gray-300 rounded-md"
                  placeholder="Enter search term..."
                />
                <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                  <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                </div>
              </div>
            </div>
          </form>
        </div>

        <%= if @error do %>
          <div class="rounded-md bg-red-50 p-4 mb-6">
            <div class="flex">
              <div class="flex-shrink-0">
                <svg class="h-5 w-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div class="ml-3">
                <h3 class="text-sm font-medium text-red-800">Error</h3>
                <p class="mt-1 text-sm text-red-700"><%= @error %></p>
              </div>
            </div>
          </div>
        <% end %>

        <!-- Table Section -->
        <div class="bg-white rounded-lg shadow-sm overflow-hidden">
          <%= if @loading do %>
            <div class="flex justify-center items-center h-32">
              <div class="flex items-center space-x-4">
                <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
                <span class="text-gray-600">Loading logs...</span>
              </div>
            </div>
          <% else %>
            <div class="overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Action</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actor Email</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Target Type</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Timestamp</th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <%= for log <- @logs do %>
                    <tr class="hover:bg-gray-50 transition-colors duration-150">
                      <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        #<%= log.id %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap">
                        <span class={[
                          "px-2 py-1 text-xs font-medium rounded-full",
                          case log.action do
                            "create" -> "bg-green-100 text-green-800"
                            "update" -> "bg-blue-100 text-blue-800"
                            "delete" -> "bg-red-100 text-red-800"
                            _ -> "bg-gray-100 text-gray-800"
                          end
                        ]}>
                          <%= log.action %>
                        </span>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <%= log.actor_email %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <%= log.target_type %>
                      </td>
                      <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <div class="flex items-center space-x-1">
                          <svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                          </svg>
                          <span><%= Calendar.strftime(log.inserted_at, "%Y-%m-%d %H:%M:%S") %></span>
                        </div>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
