defmodule KejaDigitalWeb.UserRegistrationLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store
  alias KejaDigital.Store.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Register for an account
        <:subtitle>
          Already registered?
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            Log in
          </.link>
          to your account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="registration_form"
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
      >
        <.error :if={@check_errors}>
          Oops, something went wrong! Please check the errors below.
        </.error>

        <!-- Additional Fields -->
        <.input field={@form[:full_name]} type="text" label="Full Name" required />
        <.input field={@form[:postal_address]} type="text" label="Postal Address" required />
        <.input field={@form[:phone_number]} type="text" label="Phone Number" required />
        <.input field={@form[:nationality]} type="text" label="Nationality" required />
        <.input field={@form[:organization]} type="text" label="Organization" required />
        <.input field={@form[:next_of_kin]} type="text" label="Next of Kin" required />
        <.input field={@form[:next_of_kin_contact]} type="text" label="Next of Kin Contact" required />
        <.input field={@form[:passport]} type="text" label="Passport Number" required />

        <!-- Door Number Dropdown -->
        <.input
          field={@form[:door_number]}
          type="select"
          label="Door Number"
          required
          options={Enum.map(@available_door_numbers, &{&1.number, &1.number})}
        />

        <!-- Original Fields -->
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.button phx-disable-with="Creating account..." class="w-full">Create an account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Store.change_user_registration(%User{})

    # Fetch available door numbers
    available_door_numbers = Store.list_available_door_numbers()

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)
      |> assign(available_door_numbers: available_door_numbers)

    {:ok, socket, temporary_assigns: [form: nil]}
  end
  def handle_event("save", %{"user" => user_params}, socket) do
    case Store.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Store.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Store.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, :door_number_taken} ->
        changeset = Store.change_user_registration(%User{}, user_params)
                    |> Ecto.Changeset.add_error(:door_number, "is already occupied")

        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Store.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
