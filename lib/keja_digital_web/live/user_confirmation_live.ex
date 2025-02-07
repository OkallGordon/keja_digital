defmodule KejaDigitalWeb.UserConfirmationLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">Confirm Account</.header>

      <.simple_form for={@form} id="confirmation_form" phx-submit="confirm_account">
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <:actions>
          <.button phx-disable-with="Confirming..." class="w-full">Confirm my account</.button>
        </:actions>
      </.simple_form>

      <p class="text-center mt-4">
        <.link href={~p"/users/register"}>Register</.link>
        | <.link href={~p"/users/log_in"}>Log in</.link>
      </p>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: nil]}
  end

def handle_event("confirm_account", %{"user" => %{"token" => token}}, socket) do
  case Store.confirm_user(token) do
    {:ok, _} ->
      {:noreply,
       socket
       |> put_flash(:info, "User confirmed successfully")
       |> redirect(to: ~p"/")}

    :error ->
      {:noreply,
       socket
       |> put_flash(:error, "User confirmation link is invalid or it has expired.")
       |> redirect(to: ~p"/")}
  end
end
end
