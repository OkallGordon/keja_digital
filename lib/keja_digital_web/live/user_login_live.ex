defmodule KejaDigitalWeb.UserLoginLive do
  use KejaDigitalWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8">
        <div class="bg-white shadow-xl rounded-lg p-8">
          <.header class="text-center">
            <div class="flex justify-center mb-6">
              <!-- You can add your logo here -->
              <div class="w-16 h-16 bg-blue-600 rounded-full flex items-center justify-center">
                <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                </svg>
              </div>
            </div>
            <h2 class="text-2xl font-bold text-gray-900 mb-2">Log in to account</h2>
            <:subtitle>
              <p class="mt-2 text-sm text-gray-600">
                Don't have an account?
                <.link navigate={~p"/users/register"} class="font-semibold text-blue-600 hover:text-blue-500">
                  Sign up
                </.link>
                for an account now.
              </p>
            </:subtitle>
          </.header>

          <.simple_form
            for={@form}
            id="login_form"
            action={~p"/users/log_in"}
            phx-update="ignore"
            class="mt-8 space-y-6"
          >
            <div class="space-y-4">
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                required
                class="appearance-none rounded-lg relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
              />
              <.input
                field={@form[:password]}
                type="password"
                label="Password"
                required
                class="appearance-none rounded-lg relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10 sm:text-sm"
              />
            </div>

            <div class="flex items-center justify-between">
              <div class="flex items-center">
                <.input
                  field={@form[:remember_me]}
                  type="checkbox"
                  label="Keep me logged in"
                  class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                />
              </div>
              <div class="text-sm">
                <.link
                  href={~p"/users/reset_password"}
                  class="font-semibold text-blue-600 hover:text-blue-500"
                >
                  Forgot your password?
                </.link>
              </div>
            </div>

            <:actions>
              <.button
                phx-disable-with="Logging in..."
                class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                  <svg
                    class="h-5 w-5 text-blue-500 group-hover:text-blue-400"
                    xmlns="http://www.w3.org/2000/svg"
                    viewBox="0 0 20 20"
                    fill="currentColor"
                    aria-hidden="true"
                  >
                    <path
                      fill-rule="evenodd"
                      d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </span>
                Log in <span aria-hidden="true" class="ml-2">→</span>
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end
  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
