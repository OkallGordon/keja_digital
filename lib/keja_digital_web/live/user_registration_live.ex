defmodule KejaDigitalWeb.UserRegistrationLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Store
  alias KejaDigital.Store.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-2xl mx-auto bg-white rounded-xl shadow-lg p-8">
        <.header class="text-center">
          <h2 class="text-3xl font-extrabold text-gray-900">Create Your Account</h2>
          <:subtitle>
            <p class="mt-2 text-sm text-gray-600">
              Already registered?
              <.link navigate={~p"/users/log_in"} class="font-semibold text-indigo-600 hover:text-indigo-500 transition-colors duration-150">
                Sign in to your account
              </.link>
            </p>
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
          class="mt-8 space-y-6"
        >
       <div class="rounded-lg bg-red-50 p-4 text-sm text-red-700">
       <.error :if={@check_errors}>
         Oops, something went wrong! Please check the errors below.
       </.error>
       </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Personal Information Section -->
            <div class="space-y-6">
              <h3 class="text-lg font-medium text-gray-900">Personal Information</h3>
              <.input
                field={@form[:full_name]}
                type="text"
                label="Full Name"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
              <.input
                field={@form[:phone_number]}
                type="text"
                label="Phone Number"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
              <.input
                field={@form[:nationality]}
                type="text"
                label="Nationality"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>

            <!-- Additional Details Section -->
            <div class="space-y-6">
              <h3 class="text-lg font-medium text-gray-900">Additional Details</h3>
              <.input
                field={@form[:postal_address]}
                type="text"
                label="Postal Address"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
              <.input
                field={@form[:organization]}
                type="text"
                label="Organization"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
              <.input
                field={@form[:passport]}
                type="text"
                label="Passport Number"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
              <.input
                field={@form[:door_number]}
                type="select"
                label="Door Number"
                required
                options={Enum.map(@available_door_numbers, &{&1.number, &1.number})}
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>
          </div>

          <!-- Emergency Contact Section -->
          <div class="pt-6 border-t border-gray-200">
            <h3 class="text-lg font-medium text-gray-900 mb-6">Emergency Contact</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <.input
                field={@form[:next_of_kin]}
                type="text"
                label="Next of Kin"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
              <.input
                field={@form[:next_of_kin_contact]}
                type="text"
                label="Next of Kin Contact"
                required
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
              />
            </div>
          </div>

          <!-- Security Section -->
          <div class="pt-6 border-t border-gray-200">
            <h3 class="text-lg font-medium text-gray-900 mb-6">Security</h3>
            <.input
              field={@form[:password]}
              type="password"
              label="Password"
              required
              class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
            />
          </div>

          <:actions>
            <.button
              phx-disable-with="Creating account..."
              class="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors duration-150">
              Create account
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Store.change_user_registration(%User{})
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
        case Store.deliver_user_confirmation_instructions(
               user,
               &url(~p"/users/confirm/#{&1}")
             ) do
          {:ok, _} ->
            changeset = Store.change_user_registration(user)
            {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

          {:error, _error} ->
            changeset =
              Store.change_user_registration(user)
              |> Ecto.Changeset.add_error(:email, "failed to send confirmation instructions")

            {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
        end

      {:error, :door_number_taken} ->
        changeset =
          Store.change_user_registration(%User{}, user_params)
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
