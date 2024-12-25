defmodule KejaDigital.Rentals do
  import Ecto.Query
  alias KejaDigital.Repo
  alias KejaDigital.Rentals.Payment

  def get_user_overdue_payments(user_id, door_number) do
    today = Date.utc_today()

    from(p in Payment,
      where: p.user_id == ^user_id and p.due_date < ^today and p.status == "pending", # Direct comparison
      where: p.door_number == ^door_number,  # Replace `unit` with `door_number`
      select_merge: %{
        days_overdue: fragment("EXTRACT(DAY FROM (? - ?))", p.due_date, ^today) # Fix to subtract dates correctly
      }
    )
    |> Repo.all()
  end

  def subscribe_to_user_payments(user_id) do
    Phoenix.PubSub.subscribe(KejaDigital.PubSub, "user_payments:#{user_id}")
  end

  def broadcast_user_reminder(payment) do
    Phoenix.PubSub.broadcast(
      KejaDigital.PubSub,
      "user_payments:#{payment.user_id}",
      {:payment_reminder, payment}
    )
  end

  def get_warning_level(days_overdue) do
    cond do
      days_overdue > 30 -> :critical
      days_overdue > 14 -> :warning
      days_overdue > 7 -> :notice
      true -> :reminder
    end
  end
end
