defmodule KejaDigitalWeb.NotificationsLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Notifications
  alias KejaDigital.Backoffice

  def render(assigns) do
    ~H"""
    <div>
      <h1>Admin Notifications</h1>
      <%= for notification <- @notifications do %>
        <div class={["notification", if(notification.is_read, do: "read", else: "unread")]}>
          <h3><%= notification.title %></h3>
          <p><%= notification.content %></p>
        </div>
      <% end %>
    </div>
    """
  end

  def mount(_params, %{"admin_token" => admin_token}, socket) do
    case Backoffice.get_admin_by_session_token(admin_token) do
      nil ->
        {:redirect, to: "/admin/login"}

      current_admin ->
        notifications = Notifications.list_notifications(current_admin.id)

        {:ok,
         socket
         |> assign(:current_admin, current_admin)
         |> assign(:notifications, notifications)}
    end
  end

  def mount(_params, _session, _socket) do
    # If the session does not contain the required token, redirect to login.
    {:redirect, to: "/admin/login"}
  end
end
