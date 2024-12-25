defmodule KejaDigital.Rentals do
  import Ecto.Query
  alias KejaDigital.Repo
  alias KejaDigital.Rentals.Payment

  def get_tenant_overdue_payments(tenant_id) do
    today = Date.utc_today()

    from(p in Payment,
      where: p.tenant_id == ^tenant_id and p.due_date < ^today and p.status == "pending",
      join: u in assoc(p, :unit),
      preload: [unit: u],
      select_merge: %{
        days_overdue: fragment("EXTRACT(DAY FROM ? - ?)", ^today, p.due_date)
      }
    )
    |> Repo.all()
  end

  def subscribe_to_tenant_payments(tenant_id) do
    Phoenix.PubSub.subscribe(KejaDigital.PubSub, "tenant_payments:#{tenant_id}")
  end

  def broadcast_tenant_reminder(payment) do
    Phoenix.PubSub.broadcast(
      KejaDigital.PubSub,
      "tenant_payments:#{payment.tenant_id}",
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
