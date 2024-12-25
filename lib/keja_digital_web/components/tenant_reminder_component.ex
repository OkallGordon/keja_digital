defmodule KejaDigitalWeb.TenantReminderComponent do
  use KejaDigitalWeb, :live_component

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:show_reminder, true)}
  end

  def render(assigns) do
    ~H"""
    <%= if @show_reminder do %>
      <div class={reminder_container_class(@warning_level)}
           role="alert"
           phx-click="dismiss-reminder"
           phx-target={@myself}>
        <div class="flex items-center">
          <div class="py-1">
            <%= render_warning_icon(@warning_level) %>
          </div>
          <div class="ml-3">
            <h3 class="font-bold"><%= reminder_title(@warning_level) %></h3>
            <div class="mt-1">
              <p>Your rent payment of KES <%= @payment.amount %> for <%= @payment.unit.name %>
              is <%= @payment.days_overdue %> days overdue.</p>
              <%= if @warning_level in [:warning, :critical] do %>
                <p class="mt-2 font-semibold">Please settle your payment immediately to avoid any inconveniences.</p>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end

  def handle_event("dismiss-reminder", _, socket) do
    {:noreply, assign(socket, :show_reminder, false)}
  end

  defp reminder_container_class(:critical), do: "bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4"
  defp reminder_container_class(:warning), do: "bg-yellow-100 border-l-4 border-yellow-500 text-yellow-700 p-4 mb-4"
  defp reminder_container_class(:notice), do: "bg-orange-100 border-l-4 border-orange-500 text-orange-700 p-4 mb-4"
  defp reminder_container_class(:reminder), do: "bg-blue-100 border-l-4 border-blue-500 text-blue-700 p-4 mb-4"

  defp reminder_title(:critical), do: "URGENT: Critical Payment Notice"
  defp reminder_title(:warning), do: "Important: Payment Overdue"
  defp reminder_title(:notice), do: "Payment Notice"
  defp reminder_title(:reminder), do: "Rent Reminder"

  defp render_warning_icon(:critical), do: "⚠️"
  defp render_warning_icon(:warning), do: "⚠️"
  defp render_warning_icon(:notice), do: "ℹ️"
  defp render_warning_icon(:reminder), do: "📝"
end
