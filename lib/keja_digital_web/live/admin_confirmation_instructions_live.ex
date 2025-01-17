defmodule KejaDigitalWeb.AdminConfirmationInstructionsLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Backoffice

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "admin"))}
  end

  def handle_event("send_instructions", %{"admin" => %{"email" => email}}, socket) do
    if admin = Backoffice.get_admin_by_email(email) do
      Backoffice.deliver_admin_confirmation_instructions(
        admin,
        &url(~p"/admins/confirm/#{&1}")
      )
    end

    info =
      "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-50 to-pink-50 py-16 sm:py-24">
      <div class="mx-auto max-w-md px-4 sm:px-6 lg:px-8">
        <div class="bg-white rounded-2xl shadow-xl p-8 space-y-8">
          <div class="text-center space-y-2">
            <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-indigo-100 mb-4">
              <svg
                class="w-8 h-8 text-indigo-600"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>
            </div>
            <h1 class="text-3xl font-bold tracking-tight text-gray-900">
              Missing Confirmation Instructions?
            </h1>
            <p class="text-lg text-gray-600">
              Don't worry! We'll send a fresh confirmation link to your inbox.
            </p>
          </div>

          <.simple_form
            for={@form}
            id="resend_confirmation_form"
            phx-submit="send_instructions"
            class="space-y-6"
          >
            <div class="relative">
              <.input
                field={@form[:email]}
                type="email"
                placeholder="Enter your email address"
                required
                class="block w-full px-4 py-3 rounded-lg border-gray-300 shadow-sm focus:ring-indigo-500 focus:border-indigo-500"
                autocomplete="email"
              />
              <div class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none">
                <svg
                  class="w-5 h-5 text-gray-400"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"
                  />
                </svg>
              </div>
            </div>

            <.button
              phx-disable-with="Sending instructions..."
              class="w-full py-3 px-4 text-white bg-indigo-600 hover:bg-indigo-700 rounded-lg shadow-md hover:shadow-lg transition-all duration-200 flex items-center justify-center space-x-2"
            >
              <span>Resend Confirmation Instructions</span>
              <svg
                class="w-5 h-5 animate-pulse"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </.button>
          </.simple_form>

          <div class="pt-4 text-center space-x-4 text-sm">
            <.link
              href={~p"/admins/register"}
              class="font-medium text-indigo-600 hover:text-indigo-500 transition-colors duration-150"
            >
              Create Account
            </.link>
            <span class="text-gray-500">|</span>
            <.link
              href={~p"/admins/log_in"}
              class="font-medium text-indigo-600 hover:text-indigo-500 transition-colors duration-150"
            >
              Sign In
            </.link>
          </div>

          <div class="text-center text-sm text-gray-500">
            <p>Need help? Contact support at support@kejadigital.com</p>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
