defmodule KejaDigitalWeb.UserResetPasswordLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store

  alias KejaDigital.Store.User

  # Add lifecycle hook to prevent memory leaks
  @impl true
  def mount(params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000 * 60 * 60, self(), :check_token_expiry)

    socket = assign_user_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Store.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Reset Password</.header>

      <.simple_form
        for={@form}
        id="reset_password_form"
        phx-submit="reset_password"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
      >
        <.error :if={@form.errors != []}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <.input
          field={@form[:password]}
          type="password"
          label="New password"
          required
          phx-debounce="blur"
        />
        <.input
          field={@form[:password_confirmation]}
          type="password"
          label="Confirm new password"
          required
          phx-debounce="blur"
        />

        <:actions>
          <.button
            phx-disable-with="Resetting..."
            class="w-full"
            disabled={!@form.source.valid?}
          >
            Reset Password
          </.button>
        </:actions>
      </.simple_form>

      <p class="text-center text-sm mt-4">
        <.link href={~p"/users/register"} class="font-semibold text-brand hover:underline">
          Register
        </.link>
        |
        <.link href={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
          Log in
        </.link>
      </p>
    </div>
    """
  end

  @impl true
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Store.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Store.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  @impl true
  def handle_info(:check_token_expiry, socket) do
    if token_expired?(socket.assigns.token) do
      {:noreply,
       socket
       |> put_flash(:error, "Reset password link has expired. Please request a new one.")
       |> redirect(to: ~p"/users/reset_password")}
    else
      {:noreply, socket}
    end
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    case Store.get_user_by_reset_password_token(token) do
      %User{} = user ->
        socket
        |> assign(:user, user)
        |> assign(:token, token)
        |> assign(:trigger_submit, false)
      nil ->
        socket
        |> put_flash(:error, "Reset password link is invalid or it has expired.")
        |> redirect(to: ~p"/")
    end
  end

  defp assign_user_and_token(socket, _params) do
    socket
    |> put_flash(:error, "Reset token is required")
    |> redirect(to: ~p"/")
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end

  defp token_expired?(token) do
    case Store.get_user_by_reset_password_token(token) do
      nil -> true
      _user -> false
    end
  end
end
