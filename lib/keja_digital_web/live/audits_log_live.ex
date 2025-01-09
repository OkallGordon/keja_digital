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
       |> assign(:valid_fields, @valid_fields)}  # Add this line to make fields available in template
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
        |> Enum.take(100)  # Keep only latest 100 entries

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
              # Handle date filtering specially
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
      <div class="p-4">
        <h1 class="text-2xl mb-4">Audit Logs</h1>

        <form phx-change="filter" class="mb-6 flex gap-4 items-end">
          <div>
            <label for="filter_field" class="block text-sm font-medium mb-1">Filter by field:</label>
            <select name="filter[field]" class="rounded border p-2" value={@filter_field}>
              <option value="">Select a field</option>
              <%= for field <- @valid_fields do %>
                <option value={field}><%= Phoenix.Naming.humanize(field) %></option>
              <% end %>
            </select>
          </div>

          <div>
            <label for="filter_value" class="block text-sm font-medium mb-1">Value:</label>
            <input
              type="text"
              name="filter[value]"
              value={@filter_value}
              class="rounded border p-2"
              placeholder="Enter value"
            />
          </div>
        </form>

        <%= if @error do %>
          <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4" role="alert">
            <p><%= @error %></p>
          </div>
        <% end %>

        <%= if @loading do %>
          <div class="flex justify-center my-4">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
          </div>
        <% else %>
          <div class="overflow-x-auto">
            <table class="min-w-full bg-white">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Action</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actor Email</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Target Type</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Inserted At</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200">
                <%= for log <- @logs do %>
                  <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= log.id %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= log.action %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= log.actor_email %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= log.target_type %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <%= Calendar.strftime(log.inserted_at, "%Y-%m-%d %H:%M:%S") %>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        <% end %>
      </div>
      """
    end
  end
