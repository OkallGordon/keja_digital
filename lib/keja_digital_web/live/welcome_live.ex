defmodule KejaDigitalWeb.WelcomeLive do
  use KejaDigitalWeb, :live_view

  on_mount {KejaDigitalWeb.AdminAuth, :ensure_authenticated}

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Welcome to Keja Digital")}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-indigo-900 via-purple-900 to-blue-900 flex flex-col">
      <div class="container mx-auto px-4 py-12 flex-grow">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {# User Greeting #}
          <div class="lg:col-span-3 bg-white/10 backdrop-blur-lg rounded-2xl p-6 mb-6 text-white">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-4xl font-bold mb-2">Welcome, <%= @current_admin.email %></h1>
                <p class="text-xl text-indigo-100">Your dashboard to manage Keja Digital</p>
              </div>
              <div class="hidden md:block">
                <.link
                  href={~p"/admins/log_out"}
                  method="delete"
                  class="px-4 py-2 bg-red-600 hover:bg-red-700 rounded-lg text-white transition"
                >
                  Log Out
                </.link>
              </div>
            </div>
          </div>

          {# Navigation Cards #}
          <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6 hover:scale-105 transition">
            <div class="flex items-center mb-4">
              <svg class="w-8 h-8 text-green-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <h2 class="text-xl font-semibold text-white">Dashboard</h2>
            </div>
            <.link
              navigate={~p"/dashboard"}
              class="block w-full py-3 text-center bg-green-600 hover:bg-green-700 rounded-lg text-white transition"
            >
              View Dashboard
            </.link>
          </div>

          <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6 hover:scale-105 transition">
            <div class="flex items-center mb-4">
              <svg class="w-8 h-8 text-blue-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <h2 class="text-xl font-semibold text-white">Agreements</h2>
            </div>
            <div class="space-y-2">
              <.link
                navigate={~p"/agreements"}
                class="block w-full py-2 text-center bg-blue-600 hover:bg-blue-700 rounded-lg text-white transition"
              >
                Review Agreements
              </.link>
              <.link
                navigate={~p"/agreement/status"}
                class="block w-full py-2 text-center bg-blue-500 hover:bg-blue-600 rounded-lg text-white transition"
              >
                Agreement Status
              </.link>
            </div>
          </div>

          <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6 hover:scale-105 transition">
            <div class="flex items-center mb-4">
              <svg class="w-8 h-8 text-purple-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"></path>
              </svg>
              <h2 class="text-xl font-semibold text-white">Payments & Notifications</h2>
            </div>
            <div class="space-y-2">
              <.link
                navigate={~p"/notifications"}
                class="block w-full py-2 text-center bg-purple-600 hover:bg-purple-700 rounded-lg text-white transition"
              >
                View Notifications
              </.link>
              <.link
                navigate={~p"/payments/1"}
                class="block w-full py-2 text-center bg-purple-500 hover:bg-purple-600 rounded-lg text-white transition"
              >
                Payment Details
              </.link>
            </div>
          </div>

          {# Audit Logs Section #}
          <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6 hover:scale-105 transition lg:col-span-2">
            <div class="flex items-center mb-4">
              <svg class="w-8 h-8 text-yellow-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <h2 class="text-xl font-semibold text-white">Audit Logs</h2>
            </div>
            <.link
              navigate={~p"/dashboard/audit_logs"}
              class="block w-full py-3 text-center bg-yellow-600 hover:bg-yellow-700 rounded-lg text-white transition"
            >
              View Audit Logs
            </.link>
          </div>

          {# Quick Actions #}
          <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6 hover:scale-105 transition">
            <div class="flex items-center mb-4">
              <svg class="w-8 h-8 text-red-400 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
              <h2 class="text-xl font-semibold text-white">Quick Settings</h2>
            </div>
            <.link
              href={~p"/admins/settings"}
              class="block w-full py-3 text-center bg-red-600 hover:bg-red-700 rounded-lg text-white transition"
            >
              Account Settings
            </.link>
          </div>
        </div>
      </div>

      {# Footer #}
      <footer class="bg-white/10 backdrop-blur-lg text-white py-4">
        <div class="container mx-auto px-4 text-center">
          <p>&copy; 2024 Keja Digital. All rights reserved.</p>
        </div>
      </footer>
    </div>
    """
  end
end
