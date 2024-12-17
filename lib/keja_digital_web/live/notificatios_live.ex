defmodule KejaDigitalWeb.Admin.NotificationsLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Notifications
  alias KejaDigitalWeb.AdminAuth

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

  def mount(_params, session, socket) do
    current_user = AdminAuth.fetch_current_admin(session)

    if current_user do
      notifications = Notifications.list_notifications(current_user.id)

      {:ok,
       socket
       |> assign(:current_user, current_user)
       |> assign(:notifications, notifications)}
    else
      # Redirect to login if the admin is not authenticated
      {:redirect, to: "/admin/login"}
    end
  end
end
