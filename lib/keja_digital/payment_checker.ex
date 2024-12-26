defmodule KejaDigital.PaymentChecker do
  use GenServer
  alias KejaDigital.Payments
  #alias KejaDigital.Store

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
    # Check every 6 hours
    Process.send_after(self(), :check_payments, :timer.hours(6))
  end

  defp check_and_notify do
    # Query all users with pending payments
    KejaDigital.Store.list_users()  # Adjust this to your actual function name
    |> Enum.each(fn user ->
      Payments.get_user_payments(user.id)
      |> Enum.each(&Payments.broadcast_payment_update/1)
    end)
  end
end
