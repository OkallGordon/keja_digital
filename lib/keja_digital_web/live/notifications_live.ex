defmodule KejaDigitalWeb.NotificationsLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Notifications
  alias KejaDigital.Backoffice

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <!-- Header -->
        <div class="flex items-center justify-between mb-8">
          <div>
            <h1 class="text-2xl font-bold text-gray-900">Notifications</h1>
            <p class="mt-1 text-sm text-gray-500">
              <%= length(Enum.filter(@notifications, & !&1.is_read)) %> unread notifications
            </p>
          </div>

          <button
            phx-click="mark_all_read"
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-blue-600 bg-blue-100 hover:bg-blue-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
          >
            Mark all as read
          </button>
        </div>

        <!-- Notifications List -->
        <div class="space-y-4">
          <%= if Enum.empty?(@notifications) do %>
            <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-12 text-center">
              <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-blue-100">
                <svg class="h-6 w-6 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                </svg>
              </div>
              <h3 class="mt-4 text-lg font-medium text-gray-900">No notifications</h3>
              <p class="mt-2 text-sm text-gray-500">You're all caught up! Check back later for new updates.</p>
            </div>
          <% else %>
            <%= for notification <- @notifications do %>
              <div class={[
                "group relative bg-white rounded-lg shadow-sm border transition-all duration-200 hover:shadow-md",
                if(notification.is_read, do: "border-gray-200", else: "border-blue-200 bg-blue-50")
              ]}>
                <div class="p-6">
                  <div class="flex items-start space-x-4">
                    <!-- Notification Icon -->
                    <div class={[
                      "flex-shrink-0 rounded-full p-2",
                      if(notification.is_read, do: "bg-gray-100", else: "bg-blue-100")
                    ]}>
                      <svg
                        class={[
                          "h-6 w-6",
                          if(notification.is_read, do: "text-gray-600", else: "text-blue-600")
                        ]}
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                      </svg>
                    </div>

                    <!-- Notification Content -->
                    <div class="flex-1 min-w-0">
                      <div class="flex items-center justify-between">
                        <h3 class={[
                          "text-lg font-semibold",
                          if(notification.is_read, do: "text-gray-900", else: "text-blue-900")
                        ]}>
                          <%= notification.title %>
                        </h3>
                        <div class="flex items-center">
                          <!-- Timestamp -->
                          <time class="text-sm text-gray-500" datetime={notification.inserted_at}>
                            <%= format_timestamp(notification.inserted_at) %>
                          </time>

                          <!-- Mark as Read Button -->
                          <%= unless notification.is_read do %>
                            <button
                              phx-click="mark_read"
                              phx-value-id={notification.id}
                              class="ml-4 text-sm text-blue-600 hover:text-blue-800"
                            >
                              Mark as read
                            </button>
                          <% end %>
                        </div>
                      </div>
                      <p class={[
                        "mt-1 text-sm",
                        if(notification.is_read, do: "text-gray-600", else: "text-blue-800")
                      ]}>
                        <%= notification.content %>
                      </p>

                  <%= if notification.tenant_agreement_id do %>
                    <div class="mt-4">
                  <.link
                      navigate={~p"/agreements/#{notification.tenant_agreement_id}"}
                      class="inline-flex items-center px-3 py-1.5 border border-gray-300 text-xs font-medium rounded-full text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                     >
                       View Agreement
                    <svg class="ml-1.5 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                    </svg>
                   </.link>
                     </div>
                      <% end %>
                    </div>
                  </div>
                </div>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, %{"admin_token" => admin_token}, socket) do
    case Backoffice.get_admin_by_session_token(admin_token) do
      nil ->
        {:redirect, to: "/admin/login"}

      current_admin ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(KejaDigital.PubSub, "admin_notifications:#{current_admin.id}")
        end

        notifications = Notifications.list_notifications(current_admin.id)

        {:ok,
         socket
         |> assign(:current_admin, current_admin)
         |> assign(:notifications, notifications)}
    end
  end

  def mount(_params, _session, _socket) do
    {:redirect, to: "/admin/login"}
  end

  def handle_event("mark_read", %{"id" => id}, socket) do
    notification = Enum.find(socket.assigns.notifications, &(&1.id == id))

    if notification do
      case Notifications.mark_as_read(notification) do
        {:ok, _updated} ->
          notifications = Notifications.list_notifications(socket.assigns.current_admin.id)
          {:noreply, assign(socket, :notifications, notifications)}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Could not mark notification as read")}
      end
    else
      {:noreply, put_flash(socket, :error, "Notification not found")}
    end
  end

  def handle_event("mark_all_read", %{"value" => ""}, socket) do
    case Notifications.mark_all_as_read(socket.assigns.current_admin.id) do
      {0, _} ->
        {:noreply, socket}
      {count, _} when is_integer(count) and count > 0 ->
        {:noreply, assign(socket, :notifications, [])}
      _ ->
        {:noreply, put_flash(socket, :error, "Could not mark notifications as read")}
    end
  end

  def handle_info({:new_notification, notification}, socket) do
    notifications = [notification | socket.assigns.notifications]
    {:noreply, assign(socket, :notifications, notifications)}
  end

  defp format_timestamp(nil), do: "N/A"
  defp format_timestamp(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y at %I:%M %p")
  end
end
