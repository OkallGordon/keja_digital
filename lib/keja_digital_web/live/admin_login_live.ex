defmodule KejaDigitalWeb.AdminLoginLive do
  use KejaDigitalWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-md">
        <div class="text-center">
          <!-- Add your logo here -->
          <div class="mx-auto h-12 w-12 bg-indigo-600 rounded-full flex items-center justify-center">
            <svg class="h-8 w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
          </div>
          <h2 class="mt-6 text-3xl font-extrabold text-gray-900">Welcome Back</h2>
          <p class="mt-2 text-sm text-gray-600">
            Don't have an account?
            <.link navigate={~p"/admins/register"} class="font-medium text-indigo-600 hover:text-indigo-500">
              Sign up
            </.link>
            for an account now.
          </p>
        </div>

        <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
          <div class="bg-white py-8 px-4 shadow-lg rounded-lg sm:px-10">
            <.simple_form for={@form} id="login_form" action={~p"/admins/log_in"} phx-update="ignore" class="space-y-6">
              <div>
                <.input
                  field={@form[:email]}
                  type="email"
                  label="Email address"
                  required
                  class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                />
              </div>

              <div>
                <.input
                  field={@form[:password]}
                  type="password"
                  label="Password"
                  required
                  class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
                />
              </div>

              <div class="flex items-center justify-between">
                <.input
                  field={@form[:remember_me]}
                  type="checkbox"
                  label="Keep me logged in"
                  class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                />
                <.link
                  href={~p"/admins/reset_password"}
                  class="text-sm font-medium text-indigo-600 hover:text-indigo-500">
                  Forgot your password?
                </.link>
              </div>

              <div>
                <.button
                  phx-disable-with="Signing in..."
                  class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500">
                  Sign in <span aria-hidden="true" class="ml-2">→</span>
                </.button>
              </div>
            </.simple_form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "admin")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
