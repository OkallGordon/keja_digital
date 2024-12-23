defmodule KejaDigitalWeb.TenantPaymentsLive do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Payments

  def mount(%{"phone_number" => phone_number}, _session, socket) do
    # Subscribe to the PubSub topic for this tenant
    Phoenix.PubSub.subscribe(KejaDigital.PubSub, "payments:#{phone_number}")

    # Assign initial payments
    {:ok, assign(socket, payments: Payments.get_mpesa_payment!(phone_number))}
  end

  def handle_info({:payment_received, payment}, socket) do
    # Prepend the new payment to the list of payments
    payments = [payment | socket.assigns.payments]
    {:noreply, assign(socket, payments: payments)}
  end
end
