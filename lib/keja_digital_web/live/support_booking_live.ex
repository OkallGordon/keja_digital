defmodule KejaDigitalWeb.SupportBookingLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Support
  alias KejaDigital.Support.Booking
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    changeset = Support.change_booking(%Booking{})

    socket =
      socket
      |> assign(
        changeset: changeset,
        booking_types: booking_types(),
        submit_status: nil,
        error_message: nil
      )

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  @impl true
  def handle_event("validate", %{"booking" => params}, socket) do
    changeset =
      %Booking{}
      |> Support.change_booking(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"booking" => params}, socket) do
    case Support.create_booking(params) do
      {:ok, booking} ->
        # Broadcast the booking event to the admin notifications topic
        PubSub.broadcast(KejaDigital.PubSub, "admin_notifications", {:new_booking, booking})

        socket =
          socket
          |> put_flash(:success, "Support booking created successfully. Reference: #{booking.id}")
          |> push_navigate(to: ~p"/support/booking")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(changeset: changeset)
         |> put_flash(:error, "Unable to submit booking. Please check the form.")}
    end
  end

  defp booking_types do
    [
      {"Technical Support", "technical"},
      {"Billing Inquiry", "billing"},
      {"Account Management", "account"},
      {"Property Maintenance", "maintenance"},
      {"General Consultation", "general"}
    ]
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
      <div class="sm:mx-auto sm:w-full sm:max-w-2xl">
        <div class="bg-white py-8 px-4 shadow-2xl sm:rounded-lg sm:px-10">
          <div class="text-center mb-8">
            <h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">
              Support Booking
            </h2>
            <p class="mt-2 text-center text-sm text-gray-600">
              Schedule a personalized support session with our experts
            </p>
          </div>

          <.form
            :let={f}
            for={@changeset}
            phx-change="validate"
            phx-submit="save"
            class="space-y-6"
          >
            <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
              <div>
                <.input
                  field={f[:first_name]}
                  label="First Name"
                  type="text"
                  required={true}
                />
              </div>

              <div>
                <.input
                  field={f[:last_name]}
                  label="Last Name"
                  type="text"
                  required={true}
                />
              </div>
            </div>

            <div>
              <.input
                field={f[:email]}
                label="Email Address"
                type="email"
                required={true}
              />
            </div>

            <div>
              <.input
                field={f[:phone]}
                label="Phone Number"
                type="tel"
                required={true}
              />
            </div>

            <div>
              <.input
                field={f[:booking_type]}
                label="Support Type"
                type="select"
                options={@booking_types}
                prompt="Select Support Type"
              />
            </div>

            <div>
              <.input
                field={f[:description]}
                label="Describe Your Issue"
                type="textarea"
                rows={4}
                placeholder="Provide detailed information about your support request..."
              />
            </div>

            <div>
              <.input
                field={f[:preferred_date]}
                label="Preferred Date"
                type="date"
                min={Date.to_string(Date.utc_today())}
                max={Date.to_string(Date.add(Date.utc_today(), 30))}
              />
            </div>

            <div>
              <button
                type="submit"
                class="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                Book Support Session
              </button>
            </div>
          </.form>
        </div>

        <div class="mt-6 text-center">
          <p class="text-sm text-gray-600">
            Need immediate help?
            <a href="/contact" class="font-medium text-indigo-600 hover:text-indigo-500">
              Contact our support team directly
            </a>
          </p>
        </div>
      </div>
    </div>
    """
  end
end
