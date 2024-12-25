defmodule KejaDigitalWeb.TenantDashboardLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Rentals

  @impl true
  def mount(_params, %{"user_token" => _token} = _session, socket) do
    user_id = socket.assigns.current_user.id  # Updated to fetch user_id from the current_user

    # For the demo, you can set a default door_number or fetch it from session or params
    door_number = socket.assigns.current_user.door_number  # Assuming `door_number` is part of the user session, adjust accordingly

    # Fetch overdue payments with the user_id and door_number
    overdue_payments = Rentals.get_user_overdue_payments(user_id, door_number)

    if connected?(socket) do
      Rentals.subscribe_to_user_payments(user_id)  # Subscribing to payment changes for this user
    end

    {:ok,
     assign(socket,
       user_id: user_id,  # Store the user_id in the socket
       door_number: door_number,  # Store the door_number in the socket (if needed for other operations)
       overdue_payments: overdue_payments  # Assign the fetched overdue payments
     )}
  end

  @impl true
  def handle_info({:payment_reminder, payment}, socket) do
    warning_level = Rentals.get_warning_level(payment.days_overdue)

    {:noreply,
     socket
     |> push_event("play-notification-sound", %{})
     |> stream_insert(:reminders, %{
       id: payment.id,
       payment: payment,
       warning_level: warning_level
     })}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4">
      <div class="max-w-4xl mx-auto">
        <%= if length(@overdue_payments) > 0 do %>
          <div id="reminders" phx-update="stream">
            <%= for {_id, reminder} <- @reminders do %>
              <.live_component
                module={KejaDigitalWeb.UserReminderComponent}  # Changed to UserReminderComponent
                id={"reminder-#{reminder.payment.id}"}
                payment={reminder.payment}
                warning_level={reminder.warning_level}
              />
            <% end %>
          </div>

          <div class="mt-8">
            <h3 class="text-lg font-semibold mb-4">Payment History</h3>
            <div class="overflow-x-auto">
              <table class="min-w-full bg-white">
                <thead class="bg-gray-100">
                  <tr>
                    <th class="px-6 py-3 text-left">Unit</th>
                    <th class="px-6 py-3 text-left">Amount</th>
                    <th class="px-6 py-3 text-left">Due Date</th>
                    <th class="px-6 py-3 text-left">Days Overdue</th>
                    <th class="px-6 py-3 text-left">Status</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                  <%= for payment <- @overdue_payments do %>
                    <tr class="hover:bg-gray-50">
                      <td class="px-6 py-4"><%= payment.door_number %></td> <!-- Updated to use door_number -->
                      <td class="px-6 py-4">KES <%= payment.amount %></td>
                      <td class="px-6 py-4"><%= payment.due_date %></td>
                      <td class="px-6 py-4 text-red-600"><%= payment.days_overdue %> days</td>
                      <td class="px-6 py-4">
                        <span class={warning_badge_class(Rentals.get_warning_level(payment.days_overdue))}>
                          <%= payment.days_overdue %> days overdue
                        </span>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        <% else %>
          <div class="text-center py-8">
            <h3 class="text-lg font-medium text-gray-900">No Overdue Payments</h3>
            <p class="mt-1 text-sm text-gray-500">You're all caught up with your rent payments!</p>
          </div>
        <% end %>
      </div>
    </div>

    <audio id="notification-sound" src={~p"/assets/sounds/notification.mp3"} preload="auto"></audio>
    """
  end

  defp warning_badge_class(:critical), do: "px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800"
  defp warning_badge_class(:warning), do: "px-2 py-1 text-xs font-semibold rounded-full bg-yellow-100 text-yellow-800"
  defp warning_badge_class(:notice), do: "px-2 py-1 text-xs font-semibold rounded-full bg-orange-100 text-orange-800"
  defp warning_badge_class(:reminder), do: "px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800"
end
