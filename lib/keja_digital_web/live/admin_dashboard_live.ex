defmodule KejaDigitalWeb.AdminDashboardLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store

  def mount(_params, _session, socket) do
    # Fetch all users
    users = Store.list_users()

    # Separate users into admin and regular user lists
    admin_users = Enum.filter(users, fn user -> user.role == "admin" end)
    regular_users = Enum.filter(users, fn user -> user.role != "admin" end)

    socket =
      socket
      |> assign(:admin_users, admin_users)
      |> assign(:regular_users, regular_users)

    {:ok, socket}
  end

  def handle_event("delete_user", %{"id" => user_id}, socket) do
    user = Store.get_user!(user_id)

    case Store.delete_user(user) do
      {:ok, _user} ->
        # Refresh both user lists
        users = Store.list_users()
        admin_users = Enum.filter(users, fn user -> user.role == "admin" end)
        regular_users = Enum.filter(users, fn user -> user.role != "admin" end)

        {:noreply, assign(socket, admin_users: admin_users, regular_users: regular_users)}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to delete user.")}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto py-6">
      <h1 class="text-3xl font-bold text-gray-800 mb-6">Admin Dashboard</h1>

      <div class="mb-8">
        <h2 class="text-2xl font-semibold text-gray-700 mb-4">System Administrators</h2>
        <.user_table users={@admin_users} />
      </div>

      <div>
        <h2 class="text-2xl font-semibold text-gray-700 mb-4">Tenants Users</h2>
        <.user_table users={@regular_users} />
      </div>

      <%= if flash = Phoenix.Flash.get(@flash, :error) do %>
        <div class="bg-red-100 text-red-700 p-4 rounded-md mt-4">
          <p><%= flash %></p>
        </div>
      <% end %>
    </div>
    """
  end
  # Define a reusable table component
  defp user_table(assigns) do
    ~H"""
    <table class="w-full border-collapse bg-white shadow rounded-md">
      <thead>
        <tr class="bg-gray-100 border-b">
          <th class="text-left py-2 px-4">ID</th>
          <th class="text-left py-2 px-4">Email</th>
          <th class="text-left py-2 px-4">Role</th>
          <th class="text-left py-2 px-4">Actions</th>
        </tr>
      </thead>
      <tbody>
        <%= for user <- @users do %>
          <tr class="border-b hover:bg-gray-50">
            <td class="py-2 px-4"><%= user.id %></td>
            <td class="py-2 px-4"><%= user.email %></td>
            <td class="py-2 px-4"><%= user.role %></td>
            <td class="py-2 px-4 space-x-4">
              <.link navigate={~p"/admins/settings"} class="text-blue-500 hover:underline">Edit</.link>
              <.button phx-click="delete_user" phx-value-id={user.id} class="text-red-500 hover:underline">Delete</.button>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
