defmodule KejaDigital.PaymentChecker do
  use GenServer
  alias KejaDigital.Payments

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_check()
    {:ok, state}
  end

  def handle_info(:check_payments, state) do
    check_and_notify()
    schedule_check()
    {:noreply, state}
  end

  defp schedule_check do
    # Check every 12 hours
    Process.send_after(self(), :check_payments, :timer.hours(1))
  end

  defp check_and_notify do
    # Get all users and their payments
    KejaDigital.Store.list_users()
    |> Enum.each(fn user ->
      Payments.get_user_payments(user.id)
      |> Enum.each(fn payment ->
        # Just broadcast updates for the LiveView to handle
        Payments.broadcast_payment_update(payment)
      end)
    end)
  end
end
