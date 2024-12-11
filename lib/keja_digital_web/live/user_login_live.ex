defmodule KejaDigitalWeb.UserLoginLive do
  use KejaDigitalWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-submit="login">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <.input field={@form[:door_number]} type="text" label="Door Number" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in <span aria-hidden="true">&rarr;</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    form = to_form(%{"email" => "", "password" => "", "door_number" => ""}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end

  def handle_event("login", %{"user" => %{"email" => email, "password" => password, "door_number" => door_number}}, socket) do
    case authenticate_user(email, password, door_number) do
      {:ok, _user} ->
        {:noreply, redirect(socket, to: "/dashboard")}

      {:error, :invalid_credentials} ->
        form = socket.assigns.form
        |> Ecto.Changeset.add_error(:email, "Invalid email, door number, or password")
        {:noreply, assign(socket, form: form)}
    end
  end

  defp authenticate_user(email, password, door_number) do
    user = KejaDigital.Store.get_user_by_email(email)

    if user && user.door_number == door_number && KejaDigital.Store.valid_password?(user, password) do
      {:ok, user}
    else
      {:error, :invalid_credentials}
    end
  end
end
