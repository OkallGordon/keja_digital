defmodule KejaDigitalWeb.RentPaymentLive do
  use KejaDigitalWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(
        payment_type: nil,
        name: "",
        phone_number: "",
        email: "",
        amount: nil,
        error_message: nil,
        loading: false
      )
    }
  end
  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="max-w-2xl mx-auto bg-white shadow-2xl rounded-2xl p-8 space-y-8">
        <div class="text-center">
          <h1 class="text-4xl font-bold text-gray-800 mb-4">Complete Your Payment</h1>
          <p class="text-gray-600">Select payment type and provide your details</p>
        </div>

        <div class="space-y-6">
          <div>
            <h3 class="text-2xl font-semibold text-gray-800 mb-4">Select Payment Type</h3>
            <div class="grid grid-cols-3 gap-4">
              <%= for {type, amount} <- [
                {"Rent", 4500},
                {"Booking", 3000},
                {"Deposit", 4500}
              ] do %>
                <button
                  phx-click="select_payment_type"
                  phx-value-type={type}
                  phx-value-amount={amount}
                  class={[
                    "py-4 px-6 rounded-xl text-lg font-bold transition-all duration-300",
                    if @payment_type == type do
                      "bg-green-600 text-white"
                    else
                      "bg-gray-100 text-gray-700 hover:bg-gray-200"
                    end
                  ]}
                >
                  <%= type %>
                  <span class="block text-sm font-normal">KES <%= amount %></span>
                </button>
              <% end %>
            </div>
          </div>

          <%= if @payment_type do %>
            <div class="space-y-4">
              <div class="grid md:grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Full Name</label>
                  <input
                    type="text"
                    name="name"
                    value={@name}
                    phx-change="update_field"
                    phx-blur="update_field"
                    placeholder="Enter your full name"
                    class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>

                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
                  <div class="relative">
                    <span class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-500">+254</span>
                    <input
                      type="tel"
                      name="phone_number"
                      value={@phone_number}
                      phx-change="update_field"
                      phx-blur="validate_phone"
                      placeholder="712345678"
                      class="w-full pl-16 pr-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  <%= if @error_message do %>
                    <p class="text-red-500 text-sm mt-2"><%= @error_message %></p>
                  <% end %>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Email (Optional)</label>
                <input
                  type="email"
                  name="email"
                  value={@email}
                  phx-change="update_field"
                  phx-blur="update_field"
                  placeholder="Enter your email"
                  class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>

              <div class="bg-blue-50 border-l-4 border-blue-500 p-4 rounded-lg">
                <p class="text-blue-700 font-medium">
                  Payment for <%= @payment_type %>: KES <%= @amount %>
                </p>
              </div>

              <button
                phx-click="initiate_payment"
                disabled={@loading}
                class={[
                  "w-full py-4 rounded-xl text-xl font-bold transition-all duration-300",
                  if @loading do
                    "bg-gray-400 cursor-not-allowed"
                  else
                    "bg-green-600 text-white hover:bg-green-700"
                  end
                ]}
              >
                <%= if @loading do %>
                  <div class="flex items-center justify-center">
                    <svg class="animate-spin h-5 w-5 mr-3" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Processing...
                  </div>
                <% else %>
                  Proceed to Payment
                <% end %>
              </button>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
  def handle_event("select_payment_type", %{"type" => type, "amount" => amount}, socket) do
    {:noreply,
      socket
      |> assign(
        payment_type: type,
        amount: String.to_integer(amount),
        error_message: nil
      )
    }
  end

  def handle_event("update_field", params, socket) do
    # Flexible handling of update_field event
    case params do
      %{"name" => name, "value" => value} ->
        field = String.to_existing_atom(name)
        {:noreply, assign(socket, field, value)}

      %{"value" => value} ->
        # Fallback for events without a name (like blur events)
        {:noreply, assign(socket, :name, value)}

      _ ->
        # Unexpected input, just return the socket unchanged
        {:noreply, socket}
    end
  end

  def handle_event("validate_phone", %{"value" => phone}, socket) do
    # Basic Safaricom phone number validation
    case Regex.match?(~r/^(07|01)\d{8}$/, phone) do
      true ->
        {:noreply, assign(socket, error_message: nil, phone_number: phone)}
      false ->
        {:noreply, assign(socket, error_message: "Please enter a valid Safaricom phone number")}
    end
  end

  def handle_event("initiate_payment", _, socket) do
    # Enhanced validation with more detailed checks
    cond do
      socket.assigns.payment_type == nil ->
        {:noreply,
          socket
          |> put_flash(:error, "Please select a payment type")
        }

      String.trim(socket.assigns.name) == "" ->
        {:noreply,
          socket
          |> put_flash(:error, "Please enter your full name")
        }

      socket.assigns.phone_number == "" or socket.assigns.error_message != nil ->
        {:noreply,
          socket
          |> put_flash(:error, "Please enter a valid Safaricom phone number")
        }

      true ->
        # Start processing payment - this is where you'd integrate M-PESA STK push
        {:noreply,
          socket
          |> assign(loading: true)
          # You would call your M-PESA integration function here
          # After successful payment, update payment history and reset form
        }
    end
  end
end
