defmodule KejaDigitalWeb.RentPaymentCheckerLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Payments

  @impl true
  def mount(_params, %{"user_token" => _token} = _session, socket) do
    user_id = socket.assigns.current_user.id

    if connected?(socket) do
      Payments.subscribe_to_payment_updates(user_id)
      # Start periodic stats updates if needed
      Process.send_after(self(), :update_stats, 5000)
    end

    payments = Payments.get_user_payments(user_id)

    socket =
      Enum.reduce(payments, socket, fn payment, acc ->
        push_event(acc, "show-notification", %{
          title: notification_title(Payments.get_payment_status(payment)),
          message: payment_message(payment)
        })
      end)

    {:ok, assign(socket, user_id: user_id, payments: payments)}
  end

  @impl true
  def handle_info(:update_stats, socket) do
    # Schedule the next update
    Process.send_after(self(), :update_stats, 5000)

    # Fetch fresh payment data
    updated_payments = Payments.get_user_payments(socket.assigns.user_id)

    {:noreply, assign(socket, payments: updated_payments)}
  end

  @impl true
  def handle_info({:payment_update, payment}, socket) do
    status = Payments.get_payment_status(payment)

    {:noreply, socket
     |> push_event("show-notification", %{
       title: notification_title(status),
       message: payment_message(payment)
     })
     |> update(:payments, fn payments ->
       [payment | Enum.reject(payments, &(&1.id == payment.id))]
     end)}
  end

  defp payment_message(payment) do
    status = Payments.get_payment_status(payment)
    case status do
      :upcoming ->
        "Your rent payment of KES #{payment.amount} for Door #{payment.door_number} is due in #{payment.days_until_due} days."
      _ ->
        "Your rent payment of KES #{payment.amount} for Door #{payment.door_number} is #{payment.days_overdue} days overdue."
    end
  end

  @impl true
  def handle_event("navigate_to_payments", %{"payment_id" => _payment_id}, socket) do
    {:noreply, push_navigate(socket, to: "/tenant/payments")}
  end
  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-8">
      <div class="max-w-4xl mx-auto px-4">
        <div class="mb-8">
          <h1 class="text-2xl font-bold text-gray-900">Payment Notifications</h1>
          <p class="mt-2 text-gray-600">Stay updated with your rental payment status</p>
        </div>

        <div class="space-y-4">
          <%= for payment <- @payments do %>
            <% status = Payments.get_payment_status(payment) %>
            <div class={notification_container_class(status)}>
              <div class="flex items-start p-6">
              <div class={notification_icon_class(status)}>
                <%= render_icon(status, assigns) %>
                </div>
                <div class="ml-4 flex-1">
                  <div class="flex items-center justify-between">
                    <h3 class={notification_title_class(status)}>
                      <%= notification_title(status) %>
                    </h3>
                    <span class={notification_badge_class(status)}>
                      <%= status_text(status) %>
                    </span>
                  </div>
                  <div class="mt-2">
                    <div class="text-sm text-gray-700">
                      <div class="flex items-center justify-between mb-2">
                        <span>Door Number:</span>
                        <span class="font-medium"><%= payment.door_number %></span>
                      </div>
                      <div class="flex items-center justify-between mb-2">
                        <span>Amount Due:</span>
                        <span class="font-medium">KES <%= payment.amount %></span>
                      </div>
                      <div class="flex items-center justify-between">
                        <span>Time Remaining:</span>
                        <span class="font-medium">
                          <%= if status == :upcoming do %>
                            <%= payment.days_until_due %> days
                          <% else %>
                            <%= payment.days_overdue %> days overdue
                          <% end %>
                        </span>
                      </div>
                    </div>

                    <%= if status in [:warning, :critical] do %>
                      <div class="mt-4 p-3 bg-red-50 rounded-md">
                        <p class="text-sm text-red-800 font-medium">
                          Please settle your payment immediately to avoid any inconveniences.
                        </p>
                      </div>
                    <% end %>

                    <div class="mt-4 flex justify-end">
                      <button
                        class={payment_button_class(status)}
                        phx-click="navigate_to_payments"
                        phx-value-payment_id={payment.id}
                      >
                        Make Payment
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    <audio id="notification-upcoming" src={~p"/assets/sounds/notification.mp3"} preload="auto"></audio>
    <audio id="notification-overdue" src={~p"/assets/sounds/overdue.mp3"} preload="auto"></audio>
    <audio id="notification-warning" src={~p"/assets/sounds/warning.mp3"} preload="auto"></audio>
    <audio id="notification-critical" src={~p"/assets/sounds/critical.mp3"} preload="auto"></audio>
    """
  end

  defp notification_container_class(:critical),
    do: "bg-white border border-red-200 rounded-lg shadow-sm overflow-hidden"

  defp notification_container_class(:warning),
    do: "bg-white border border-yellow-200 rounded-lg shadow-sm overflow-hidden"

  defp notification_container_class(:overdue),
    do: "bg-white border border-orange-200 rounded-lg shadow-sm overflow-hidden"

  defp notification_container_class(:upcoming),
    do: "bg-white border border-blue-200 rounded-lg shadow-sm overflow-hidden"

  defp notification_container_class(_),
    do: "bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden"

  defp notification_icon_class(:critical),
    do: "flex-shrink-0 w-10 h-10 rounded-full bg-red-100 text-red-500 flex items-center justify-center"

  defp notification_icon_class(:warning),
    do: "flex-shrink-0 w-10 h-10 rounded-full bg-yellow-100 text-yellow-500 flex items-center justify-center"

  defp notification_icon_class(:overdue),
    do: "flex-shrink-0 w-10 h-10 rounded-full bg-orange-100 text-orange-500 flex items-center justify-center"

  defp notification_icon_class(:upcoming),
    do: "flex-shrink-0 w-10 h-10 rounded-full bg-blue-100 text-blue-500 flex items-center justify-center"

  defp notification_icon_class(_),
    do: "flex-shrink-0 w-10 h-10 rounded-full bg-gray-100 text-gray-500 flex items-center justify-center"


defp render_icon(:critical, assigns) do
  ~H"""
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
  </svg>
  """
end

defp render_icon(:warning, assigns) do
  ~H"""
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
  </svg>
  """
end

defp render_icon(:overdue, assigns) do
  ~H"""
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
  </svg>
  """
end

defp render_icon(:upcoming, assigns) do
  ~H"""
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
  </svg>
  """
end

defp render_icon(_, assigns) do
  ~H"""
  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
  </svg>
  """
end
  defp notification_title_class(:critical), do: "text-lg font-semibold text-red-800"
  defp notification_title_class(:warning), do: "text-lg font-semibold text-yellow-800"
  defp notification_title_class(:overdue), do: "text-lg font-semibold text-orange-800"
  defp notification_title_class(:upcoming), do: "text-lg font-semibold text-blue-800"
  defp notification_title_class(_), do: "text-lg font-semibold text-gray-800"

  defp notification_badge_class(:critical), do: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800"
  defp notification_badge_class(:warning), do: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800"
  defp notification_badge_class(:overdue), do: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800"
  defp notification_badge_class(:upcoming), do: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
  defp notification_badge_class(_), do: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"

  defp payment_button_class(:critical), do: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
  defp payment_button_class(:warning), do: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-yellow-600 hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500"
  defp payment_button_class(:overdue), do: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500"
  defp payment_button_class(:upcoming), do: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
  defp payment_button_class(_), do: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-gray-600 hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"

  defp status_text(:critical), do: "Critical"
  defp status_text(:warning), do: "Warning"
  defp status_text(:overdue), do: "Overdue"
  defp status_text(:upcoming), do: "Upcoming"
  defp status_text(_), do: "Information"

  defp notification_title(:critical), do: "URGENT: Critical Payment Notice"
  defp notification_title(:warning), do: "Important: Payment Warning"
  defp notification_title(:overdue), do: "Payment Overdue"
  defp notification_title(:upcoming), do: "Upcoming Payment Reminder"
  defp notification_title(_), do: "Payment Information"
end
