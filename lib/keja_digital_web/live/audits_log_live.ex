defmodule KejaDigitalWeb.Admin.AuditLogsLive do
  use Phoenix.LiveView
  import Ecto.Query
  alias KejaDigital.Audit
  alias KejaDigital.Repo

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "audit_logs")
    end

    # Fetch initial audit logs with no filter
    logs = list_logs()

    {:ok,
     socket
     |> assign(:logs, logs)       # Assign the logs to the socket
     |> assign(:filter, %{})       # Assign the default empty filter to the socket
    }
  end

  # Handle filtering event
  def handle_event("filter", %{"filter" => filter}, socket) do
    logs = list_logs(filter)    # Apply the filter to fetch logs
    {:noreply,
     socket
     |> assign(:filter, filter)  # Update the filter in socket
     |> assign(:logs, logs)}     # Update the logs in socket
  end

  # Handle the incoming PubSub messages for new audit log creation
  def handle_info({:audit_log_created, log}, socket) do
    {:noreply, assign(socket, :logs, [log | socket.assigns.logs])}  # Add new log to existing logs
  end

  # Function to fetch and apply filter to the audit logs
  defp list_logs(filter \\ %{}) do
    Audit
    |> apply_filter(filter)                # Apply the dynamic filter
    |> order_by([a], desc: a.inserted_at)   # Order by insertion date descending
    |> limit(100)                           # Limit the results to 100 logs
    |> Repo.all()
  end

  # Function to apply the dynamic filter to the query
  defp apply_filter(query, %{"field" => value}) do
    # Apply filter to a field (example dynamic filtering by field name)
    from(a in query, where: field(a, ^String.to_atom("field")) == ^value)
  end

  defp apply_filter(query, _filter), do: query  # If no filter, return the original query

  # Render function to display the audit logs in the UI
  def render(assigns) do
    ~H"""
    <div>
      <h1>Audit Logs</h1>
      <form phx-change="filter">
        <label for="filter_field">Filter by field:</label>
        <input type="text" name="filter[field]" value={@filter["field"] || ""} />
        <button type="submit">Apply Filter</button>
      </form>

      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Action</th>
            <th>Actor Email</th>
            <th>Inserted At</th>
          </tr>
        </thead>
        <tbody>
          <%= for log <- @logs do %>
            <tr>
              <td><%= log.id %></td>
              <td><%= log.action %></td>
              <td><%= log.actor_email %></td>
              <td><%= log.inserted_at %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
