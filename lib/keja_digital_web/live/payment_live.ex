defmodule KejaDigitalWeb.PaymentLive do
  use KejaDigitalWeb, :live_view

  @topic "payments"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      KejaDigitalWeb.Endpoint.subscribe(@topic)
    end

    {:ok, assign(socket, payment: [])}

  end

  def handle_info(%{event: "new_payment", payload: payment}, socket) do
    {:noreply, update(socket, :payments, fn payments -> [payment | payments] end)}
  end

  def render(assigns) do
    ~H"""
    <div class="payments-container">
      <h2>Recent M-PESA Payments</h2>
      <div class="payments-list">
        <%= for payment <- @payments do %>
          <div class="payment-item">
            <p>Transaction ID: <%= payment.transaction_id %></p>
            <p>Amount: KES <%= payment.amount %></p>
            <p>Phone: <%= payment.phone_number %></p>
            <p>Date: <%= Calendar.strftime(payment.inserted_at, "%Y-%m-%d %H:%M:%S") %></p>
            <p>Status: <%= payment.status %></p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
