defmodule KejaDigitalWeb.PaymentLive do
  use KejaDigitalWeb, :live_view
  alias KejaDigital.Payments
  require Logger

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      # Subscribe to all payments
      Phoenix.PubSub.subscribe(KejaDigital.PubSub, "payments")

      # Subscribe to tenant-specific payments if tenant_id is provided
      if params["tenant_id"] do
        Phoenix.PubSub.subscribe(
          KejaDigital.PubSub,
          "tenant_payments:#{params["tenant_id"]}"
        )
      end
    end

    payments = case params do
      %{"tenant_id" => tenant_id} ->
        Payments.get_tenant_payments(tenant_id)
      _ ->
        Payments.list_all_payments()
    end

    {:ok,
     socket
     |> assign(:tenant_id, params["tenant_id"])
     |> assign(:loading, false)
     |> assign(:streams, %{
       payments: Phoenix.LiveView.stream(socket, :payments, payments)
     })}
  end

  @impl true
  def handle_info({:payment_created, payment}, socket) do
    Logger.info("Received new payment: #{inspect(payment)}")

    # Only add the payment if it matches the current tenant_id filter (if any)
    if should_add_payment?(payment, socket.assigns.tenant_id) do
      {:noreply, stream_insert(socket, :payments, payment)}
    else
      {:noreply, socket}
    end
  end

  defp should_add_payment?(_payment, nil), do: true
  defp should_add_payment?(payment, tenant_id) do
    payment.tenant_id == String.to_integer(tenant_id)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-4">
      <h2 class="text-2xl font-bold mb-6">Real-time Payment History</h2>

      <div class="space-y-4">
        <%= if @loading do %>
          <div class="text-center py-4">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto"></div>
          </div>
        <% end %>

        <div id="payments-list">
          <ul>
            <%= for {id, payment} <- @streams.payments do %>
              <li id={"payment-#{id}"} class="bg-white shadow rounded-lg p-4 mb-4 animate-fade-in">
                <div class="flex justify-between">
                  <div>
                    <p class="text-lg font-semibold">KES <%= payment.amount %></p>
                    <p class="text-gray-600">Transaction: <%= payment.transaction_id %></p>
                    <p class="text-gray-600">Phone: <%= payment.phone_number %></p>
                  </div>
                  <div class="text-right">
                    <p class="text-gray-600">
                      <%= Calendar.strftime(payment.payment_date, "%B %d, %Y at %H:%M") %>
                    </p>
                    <span class={[
                      "inline-block px-3 py-1 rounded-full text-sm",
                      payment.payment_status == "completed" && "bg-green-100 text-green-800",
                      payment.payment_status != "completed" && "bg-yellow-100 text-yellow-800"
                    ]}>
                      <%= payment.payment_status %>
                    </span>
                  </div>
                </div>
              </li>
            <% end %>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
