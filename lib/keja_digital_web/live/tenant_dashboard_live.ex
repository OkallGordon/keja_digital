defmodule KejaDigitalWeb.Tenant.DashboardLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Store
  alias KejaDigital.Payments

  import Number.Currency

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(30_000, self(), :update_dashboard)
    end

    {:ok,
     socket
     |> assign(:current_page, "dashboard")
     |> assign_defaults()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <!-- Stats Overview -->
      <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
        <!-- Pending Rent Card -->
        <a href="/tenant_agreements" class="block">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <.icon name="hero-currency-dollar" class="h-6 w-6 text-gray-400" />
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Pending Rent</dt>
                    <dd class="text-lg font-semibold text-gray-900">
                      <%= format_currency(@pending_rent.amount) %>
                    </dd>
                    <dt class="text-xs text-gray-500">Due on <%= @pending_rent.due_date %></dt>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </a>

        <!-- Agreement Status Card -->
        <a href="/tenant_agreements/:id" class="block">
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-5">
              <div class="flex items-center">
                <div class="flex-shrink-0">
                  <.icon name="hero-document-text" class="h-6 w-6 text-gray-400" />
                </div>
                <div class="ml-5 w-0 flex-1">
                  <dl>
                    <dt class="text-sm font-medium text-gray-500 truncate">Agreement Status</dt>
                    <dd class="text-lg font-semibold text-gray-900">
                      <%= @agreement_status.status %>
                    </dd>
                    <dt class="text-xs text-gray-500">Valid until <%= @agreement_status.valid_until %></dt>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </a>
      </div>

      <!-- Personal Information -->
      <div class="bg-white shadow rounded-lg">
        <div class="p-6">
          <h2 class="text-lg font-medium text-gray-900 mb-6">Personal Information</h2>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="space-y-4">
              <div>
                <h3 class="text-sm font-medium text-gray-500">Door Number</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.door_number %></p>
              </div>
              <div>
                <h3 class="text-sm font-medium text-gray-500">Email</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.email %></p>
              </div>
              <div>
                <h3 class="text-sm font-medium text-gray-500">Role</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.role %></p>
              </div>
              <div>
                <h3 class="text-sm font-medium text-gray-500">Organization</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.organization %></p>
              </div>
              <div>
                <h3 class="text-sm font-medium text-gray-500">Nationality</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.nationality %></p>
              </div>
            </div>
            <div class="space-y-4">
              <div>
                <h3 class="text-sm font-medium text-gray-500">Identification Number</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.passport %></p>
              </div>
              <div>
                <h3 class="text-sm font-medium text-gray-500">Postal Address</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.postal_address %></p>
              </div>
              <div>
                <h3 class="text-sm font-medium text-gray-500">Phone Number</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.phone_number %></p>
              </div>
              <div>
                <h3 class="text-sm font-medium text-gray-500">Next of Kin</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.next_of_kin %></p>
              </div>
              <div>
                <h3 class="text-sm font-medium text-gray-500">Next of Kin Contact</h3>
                <p class="mt-1 text-sm text-gray-900"><%= @current_user.next_of_kin_contact %></p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Payments -->
      <div class="bg-white shadow rounded-lg">
        <div class="p-6">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-lg font-medium text-gray-900">Recent Payments</h2>
            <a href="/tenant/payments" class="text-sm text-blue-600 hover:text-blue-800">
              View All
            </a>
          </div>
          <div class="flow-root">
            <ul role="list" class="-my-5 divide-y divide-gray-200">
              <%= for payment <- @recent_payments do %>
                <li class="py-4">
                  <div class="flex items-center space-x-4">
                    <div class="flex-shrink-0">
                      <.icon name="hero-check-circle" class="h-8 w-8 text-green-500" />
                    </div>
                    <div class="min-w-0 flex-1">
                      <p class="text-sm font-medium text-gray-900 truncate">
                        Payment for <%= payment.description %>
                      </p>
                      <p class="text-sm text-gray-500">
                        <%= payment.payment_date %>
                      </p>
                    </div>
                    <div>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        <%= number_to_currency(payment.amount, unit: "KES ") %>
                      </span>
                    </div>
                  </div>
                </li>
              <% end %>
            </ul>
          </div>
        </div>
      </div>

      <!-- Notifications -->
      <%= if length(@notifications) > 0 do %>
        <div class="bg-white shadow rounded-lg">
          <div class="p-6">
            <h2 class="text-lg font-medium text-gray-900 mb-4">Recent Notifications</h2>
            <ul role="list" class="divide-y divide-gray-200">
              <%= for notification <- @notifications do %>
                <li>
                  <div class="px-4 py-4">
                    <div class="flex items-center justify-between">
                      <p class="text-sm font-medium text-blue-600 truncate">
                        <%= notification.title %>
                      </p>
                      <div class="ml-2 flex-shrink-0 flex">
                        <p class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                          <%= notification.inserted_at %>
                        </p>
                      </div>
                    </div>
                    <div class="mt-2">
                      <p class="text-sm text-gray-500">
                        <%= notification.message %>
                      </p>
                    </div>
                  </div>
                </li>
              <% end %>
            </ul>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_info(:update_stats, socket) do
    {:noreply, assign_defaults(socket)}
  end

  @impl true
  def handle_info(:update_dashboard, socket) do
    {:noreply, assign_defaults(socket)}
  end

  defp assign_defaults(socket) do
    user = socket.assigns.current_user

    socket
    |> assign(:recent_payments, list_recent_payments(user))
    |> assign(:pending_rent, get_pending_rent(user))
    |> assign(:notifications, list_notifications(user))
    |> assign(:agreement_status, get_agreement_status(user))
  end

  defp list_recent_payments(user) do
    Payments.list_tenant_payments(user.id, limit: 3)
  end

  defp get_pending_rent(_user) do
    %{amount: 0.00, due_date: Date.utc_today()}
  end

  defp list_notifications(user) do
    Store.list_tenant_notifications(user.id, limit: 5)
  end

  defp get_agreement_status(_user) do
    %{status: "Active", valid_until: Date.utc_today() |> Date.add(365)}
  end

  defp format_currency(amount) do
    "KES #{:erlang.float_to_binary(amount, decimals: 2)}"
  end
end
