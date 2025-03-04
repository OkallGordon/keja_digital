defmodule KejaDigitalWeb.WelcomeLive do
  use KejaDigitalWeb, :live_view

  on_mount {KejaDigitalWeb.AdminAuth, :ensure_authenticated}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Welcome to Keja Digital")}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-r from-indigo-50 to-gray-50 flex flex-col py-12 px-6 lg:px-8">
      <div class="max-w-3xl mx-auto w-full">
        <div class="bg-white shadow-xl rounded-lg overflow-hidden">
          <div class="bg-indigo-600 p-8">
            <h1 class="text-3xl font-bold text-white">Welcome, <%= @current_admin.email %>!</h1>
            <p class="text-indigo-100 mt-2">You've successfully logged into Keja Digital.</p>
          </div>

          <div class="p-8">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div class="bg-gray-50 p-6 rounded-lg border border-gray-200">
                <h3 class="text-lg font-semibold text-gray-900">Quick Actions</h3>
                <div class="mt-4 space-y-2">
                  <.link
                    navigate={~p"/dashboard"}
                    class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 w-full justify-center">
                    Go to Dashboard
                  </.link>

                  <.link
                    href={~p"/admins/settings"}
                    class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md shadow-sm text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 w-full justify-center">
                    Account Settings
                  </.link>
                </div>
              </div>

              <div class="bg-gray-50 p-6 rounded-lg border border-gray-200">
                <h3 class="text-lg font-semibold text-gray-900">Recent Activity</h3>
                <p class="text-gray-600 mt-2">Welcome to your account. From here you can access all the features of Keja Digital.</p>

                <div class="mt-4 pt-4 border-t border-gray-200">
                  <.link
                    href={~p"/admins/log_out"}
                    method="delete"
                    class="text-sm font-medium text-red-600 hover:text-red-500">
                    Log out
                  </.link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
