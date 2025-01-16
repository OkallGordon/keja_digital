defmodule KejaDigitalWeb.AdminDashboardLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Store

  def mount(_params, _session, socket) do
    users = Store.list_users()
    admin_users = Enum.filter(users, fn user -> user.role == "admin" end)
    regular_users = Enum.filter(users, fn user -> user.role != "admin" end)
    available_door_numbers = Store.list_available_door_numbers()

    socket =
      socket
      |> assign(:admin_users, admin_users)
      |> assign(:regular_users, regular_users)
      |> assign(:show_delete_modal, false)
      |> assign(:show_edit_modal, false)
      |> assign(:user_to_delete, nil)
      |> assign(:user_to_edit, nil)
      |> assign(:changeset, nil)
      |> assign(:active_tab, "admins")
      |> assign(:available_door_numbers, available_door_numbers)

    {:ok, socket}
  end

  def handle_event("edit_user", %{"id" => user_id}, socket) do
    user = Store.get_user!(user_id)
    changeset = Store.change_user(user)
    available_door_numbers = Store.list_available_door_numbers(user_id)

    {:noreply,
     socket
     |> assign(:show_edit_modal, true)
     |> assign(:user_to_edit, user)
     |> assign(:changeset, changeset)
     |> assign(:available_door_numbers, available_door_numbers)}
  end

  def handle_event("save_user", %{"user" => user_params}, socket) do
    user = socket.assigns.user_to_edit

    case Store.update_user(user, user_params) do
      {:ok, _updated_user} ->
        users = Store.list_users()
        admin_users = Enum.filter(users, fn user -> user.role == "admin" end)
        regular_users = Enum.filter(users, fn user -> user.role != "admin" end)

        {:noreply,
         socket
         |> assign(:admin_users, admin_users)
         |> assign(:regular_users, regular_users)
         |> assign(:show_edit_modal, false)
         |> assign(:user_to_edit, nil)
         |> assign(:changeset, nil)
         |> put_flash(:info, "User updated successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "Error updating user")}
    end
  end

  def handle_event("cancel_edit", _, socket) do
    {:noreply,
     socket
     |> assign(:show_edit_modal, false)
     |> assign(:user_to_edit, nil)
     |> assign(:changeset, nil)}
  end

  def handle_event("delete_user", %{"id" => user_id}, socket) do
    {:noreply,
     socket
     |> assign(:show_delete_modal, true)
     |> assign(:user_to_delete, user_id)}
  end

  def handle_event("confirm_delete", _params, socket) do
    user = Store.get_user!(socket.assigns.user_to_delete)

    case Store.delete_user(user) do
      {:ok, _} ->
        users = Store.list_users()
        admin_users = Enum.filter(users, fn user -> user.role == "admin" end)
        regular_users = Enum.filter(users, fn user -> user.role != "admin" end)

        {:noreply,
         socket
         |> assign(:admin_users, admin_users)
         |> assign(:regular_users, regular_users)
         |> assign(:show_delete_modal, false)
         |> assign(:user_to_delete, nil)
         |> put_flash(:info, "User deleted successfully")}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(:show_delete_modal, false)
         |> put_flash(:error, "Failed to delete user")}
    end
  end

  def handle_event("cancel_delete", _params, socket) do
    {:noreply, assign(socket, show_delete_modal: false)}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <!-- Top Navigation Bar -->
      <nav class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between h-16">
            <div class="flex">
              <div class="flex-shrink-0 flex items-center">
                <h1 class="text-2xl font-bold text-blue-600">KejaDigital</h1>
              </div>
            </div>
            <div class="flex items-center">
              <.link
                navigate={~p"/users/register"}
                class="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                <svg class="h-5 w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                </svg>
                Add New User
              </.link>
            </div>
          </div>
        </div>
      </nav>

      <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <!-- Stats Overview -->
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 mb-8">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0 bg-blue-500 rounded-md p-3">
                  <svg class="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                </div>
                <div class="ml-5">
                  <div class="text-sm font-medium text-gray-500">Total Users</div>
                  <div class="mt-1 text-3xl font-semibold text-gray-900">
                    <%= length(@admin_users) + length(@regular_users) %>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0 bg-green-500 rounded-md p-3">
                  <svg class="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                  </svg>
                </div>
                <div class="ml-5">
                  <div class="text-sm font-medium text-gray-500">Administrators</div>
                  <div class="mt-1 text-3xl font-semibold text-gray-900">
                    <%= length(@admin_users) %>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0 bg-purple-500 rounded-md p-3">
                  <svg class="h-6 w-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                  </svg>
                </div>
                <div class="ml-5">
                  <div class="text-sm font-medium text-gray-500">Tenants</div>
                  <div class="mt-1 text-3xl font-semibold text-gray-900">
                    <%= length(@regular_users) %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Tab Navigation -->
        <div class="bg-white shadow rounded-lg mb-6">
          <nav class="flex space-x-4 px-4 py-3" aria-label="Tabs">
            <button
              phx-click="switch_tab"
              phx-value-tab="admins"
              class={[
                "px-3 py-2 text-sm font-medium rounded-md",
                @active_tab == "admins" && "bg-blue-100 text-blue-700",
                @active_tab != "admins" && "text-gray-500 hover:text-gray-700"
              ]}
            >
              Administrators
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="tenants"
              class={[
                "px-3 py-2 text-sm font-medium rounded-md",
                @active_tab == "tenants" && "bg-blue-100 text-blue-700",
                @active_tab != "tenants" && "text-gray-500 hover:text-gray-700"
              ]}
            >
              Tenants
            </button>
          </nav>
        </div>

        <!-- User Tables -->
        <div class="bg-white shadow rounded-lg overflow-hidden">
          <%= if @active_tab == "admins" do %>
            <.user_table users={@admin_users} />
          <% else %>
            <.user_table users={@regular_users} />
          <% end %>
        </div>
      </div>

      <!-- Delete Confirmation Modal -->
      <%= if @show_delete_modal do %>
        <div class="fixed z-10 inset-0 overflow-y-auto">
          <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"></div>
            <div class="inline-block align-bottom bg-white rounded-lg px-4 pt-5 pb-4 text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full sm:p-6">
              <div class="sm:flex sm:items-start">
                <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                  <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                  </svg>
                </div>
                <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                  <h3 class="text-lg leading-6 font-medium text-gray-900">Delete User</h3>
                  <div class="mt-2">
                    <p class="text-sm text-gray-500">
                      Are you sure you want to delete this user? This action cannot be undone.
                    </p>
                  </div>
                </div>
              </div>
              <div class="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
                <button
                  type="button"
                  phx-click="confirm_delete"
                  class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm"
                >
                  Delete
                </button>
                <button
                  type="button"
                  phx-click="cancel_delete"
                  class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:w-auto sm:text-sm"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Flash Messages -->
      <%= if flash = Phoenix.Flash.get(@flash, :info) || Phoenix.Flash.get(@flash, :error) do %>
        <div class={[
          "fixed bottom-4 right-4 rounded-lg shadow-lg p-4",
          Phoenix.Flash.get(@flash, :info) && "bg-green-50 border-l-4 border-green-400",
          Phoenix.Flash.get(@flash, :error) && "bg-red-50 border-l-4 border-red-400"
        ]}>
          <div class="flex">
            <div class="flex-shrink-0">
              <%= if Phoenix.Flash.get(@flash, :info) do %>
                <svg class="h-5 w-5 text-green-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                </svg>
              <% else %>
                <svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707"
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                </svg>
              <% end %>
            </div>
            <div class="ml-3">
              <p class={[
                "text-sm font-medium",
                Phoenix.Flash.get(@flash, :info) && "text-green-800",
                Phoenix.Flash.get(@flash, :error) && "text-red-800"
              ]}>
                <%= flash %>
              </p>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp user_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead>
          <tr class="bg-gray-50">
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          <%= for user <- @users do %>
            <tr class="hover:bg-gray-50 transition-colors duration-200">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="flex-shrink-0 h-10 w-10">
                    <div class="h-10 w-10 rounded-full bg-gradient-to-r from-blue-500 to-purple-500 flex items-center justify-center">
                      <span class="text-white font-medium"><%= String.first(user.email) %></span>
                    </div>
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900"><%= user.email %></div>
                    <div class="text-sm text-gray-500">ID: <%= user.id %></div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                  Active
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class={[
                  "px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-md",
                  user.role == "admin" && "bg-purple-100 text-purple-800",
                  user.role != "admin" && "bg-blue-100 text-blue-800"
                ]}>
                  <%= String.capitalize(user.role) %>
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <%= Calendar.strftime(user.inserted_at, "%B %d, %Y") %>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div class="flex items-center space-x-3">
                  <.link
                    navigate={~p"/users/settings"}
                    class="text-blue-600 hover:text-blue-900 flex items-center"
                  >
                    <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                    Edit
                  </.link>
                  <button
                    phx-click="delete_user"
                    phx-value-id={user.id}
                    class="text-red-600 hover:text-red-900 flex items-center"
                  >
                    <svg class="h-4 w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                    Delete
                  </button>
                </div>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
