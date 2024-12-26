defmodule KejaDigitalWeb.UserPaymentLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Payments

  @impl true
  def mount(_params, %{"user_token" => _token} = _session, socket) do
    user_id = socket.assigns.current_user.id

    if connected?(socket) do
      Payments.subscribe_to_payment_updates(user_id)
    end

    payments = Payments.get_user_payments(user_id)
    {:ok, assign(socket, user_id: user_id, payments: payments)}
  end

  @impl true
  def handle_info({:payment_update, payment}, socket) do
    status = Payments.get_payment_status(payment)

    {:noreply,
     socket
     |> push_event("play-notification", %{type: Atom.to_string(status)})
     |> update(:payments, fn payments ->
       [payment | Enum.reject(payments, &(&1.id == payment.id))]
     end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-4">
      <div class="max-w-4xl mx-auto">
        <%= for payment <- @payments do %>
          <% status = Payments.get_payment_status(payment) %>
          <div class={notification_container_class(status)}>
            <div class="flex items-center">
              <div class="ml-3">
                <h3 class="font-bold"><%= notification_title(status) %></h3>
                <div class="mt-1">
                  <p>
                    <%= if status == :upcoming do %>
                      Your rent payment of KES <%= payment.amount %> for Door <%= payment.doornumber %> is due in <%= payment.days_until_due %> days.
                    <% else %>
                      Your rent payment of KES <%= payment.amount %> for Door <%= payment.doornumber %> is <%= payment.days_overdue %> days overdue.
                    <% end %>
                  </p>
                  <%= if status in [:warning, :critical] do %>
                    <p class="mt-2 font-semibold text-red-800">
                      Please settle your payment immediately to avoid any inconveniences.
                    </p>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    <audio id="notification-upcoming" src={~p"/assets/sounds/notification.mp3"} preload="auto"></audio>
    <audio id="notification-overdue" src={~p"/assets/sounds/overdue.mp3"} preload="auto"></audio>
    <audio id="notification-warning" src={~p"/assets/sounds/warning.mp3"} preload="auto"></audio>
    <audio id="notification-critical" src={~p"/assets/sounds/critical.mp3"} preload="auto"></audio>
    """
  end

  defp notification_container_class(:critical),
    do: "bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4"

  defp notification_container_class(:warning),
    do: "bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 mb-4"

  defp notification_container_class(:overdue),
    do: "bg-orange-100 border-l-4 border-orange-500 text-orange-700 p-4 mb-4"

  defp notification_container_class(:upcoming),
    do: "bg-blue-100 border-l-4 border-blue-500 text-blue-700 p-4 mb-4"

  defp notification_container_class(_),
    do: "bg-gray-100 border-l-4 border-gray-500 text-gray-700 p-4 mb-4"

  defp notification_title(:critical), do: "URGENT: Critical Payment Notice"
  defp notification_title(:warning), do: "Important: Payment Warning"
  defp notification_title(:overdue), do: "Payment Overdue"
  defp notification_title(:upcoming), do: "Upcoming Payment Reminder"
  defp notification_title(_), do: "Payment Information"
end
