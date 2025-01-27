defmodule KejaDigital.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias KejaDigital.Repo

  alias KejaDigital.Payments.MpesaPayment

  alias KejaDigital.Payments.Payment

  def create_payment(attrs) do
    %MpesaPayment{}
    |> MpesaPayment.changeset(attrs)
    |> Repo.insert()
    |> broadcast_payment()
  end

  def get_tenant_payments(tenant_id) do
    MpesaPayment
    |> where([p], p.tenant_id == ^tenant_id)
    |> order_by([p], desc: p.payment_date)
    |> Repo.all()
  end

  def get_payment(transaction_id) do
    Repo.get_by(MpesaPayment, transaction_id: transaction_id)
  end

  defp broadcast_payment({:ok, payment} = result) do
    Phoenix.PubSub.broadcast(
      KejaDigital.PubSub,
      "payments:#{payment.tenant_id}",
      {:new_payment, payment}
    )
    result
  end

  defp broadcast_payment(error), do: error

  @doc """
  Returns the list of mpesa_payments.

  ## Examples

      iex> list_mpesa_payments()
      [%MpesaPayment{}, ...]

  """
  def list_mpesa_payments do
    Repo.all(MpesaPayment)
  end

  # In lib/keja_digital/mpesa_payments.ex
def list_recent_payments do
  MpesaPayment
  |> order_by([p], desc: p.inserted_at)
  |> limit(100000)  # Adjust limit as needed
  |> Repo.all()
end

def list_all_payments do
  MpesaPayment
  |> order_by([p], desc: p.inserted_at)
  |> limit(100000)  # Limit to recent payments
  |> Repo.all()
end

def list_tenant_payments(tenant_id, opts \\ []) do
  # Apply optional filters like date range or status
  query = from p in MpesaPayment, where: p.tenant_id == ^tenant_id

  query =
    case opts[:status] do
      nil -> query
      status -> from p in query, where: p.status == ^status
    end

  Repo.all(query)
end

# Calculate pending rent for a tenant
def get_pending_rent(tenant_id) do
  # Assuming that rent is paid monthly and there's a Rent table.
  # You can adjust the logic depending on your schema.

  total_rent_due = 1000  # Example: Fetch this value from a Rent schema or config.
  paid_rent = list_tenant_payments(tenant_id)
                |> Enum.filter(fn p -> p.status == "paid" end)
                |> Enum.reduce(0, fn p, acc -> acc + p.amount end)

  total_rent_due - paid_rent
end

  @doc """
  Gets a single mpesa_payment.

  Raises `Ecto.NoResultsError` if the Mpesa payment does not exist.

  ## Examples

      iex> get_mpesa_payment!(123)
      %MpesaPayment{}

      iex> get_mpesa_payment!(456)
      ** (Ecto.NoResultsError)

  """

  def get_mpesa_payment!(id) do
    Repo.get!(MpesaPayment, id)
  end

  @doc """
  Creates a mpesa_payment.

  ## Examples

      iex> create_mpesa_payment(%{field: value})
      {:ok, %MpesaPayment{}}

      iex> create_mpesa_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
 def create_mpesa_payment(attrs \\ %{}) do
  %MpesaPayment{}
  |> MpesaPayment.changeset(attrs)
  |> Repo.insert()
  |> case do
    {:ok, payment} ->
      # Broadcast payment received event
      Phoenix.PubSub.broadcast(
        KejaDigital.PubSub,
        "payments:#{payment.phone_number}",
        {:payment_received, payment}
      )

      {:ok, payment}

    {:error, changeset} ->
      {:error, changeset}
  end
end


  @doc """
  Updates a mpesa_payment.

  ## Examples

      iex> update_mpesa_payment(mpesa_payment, %{field: new_value})
      {:ok, %MpesaPayment{}}

      iex> update_mpesa_payment(mpesa_payment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mpesa_payment(%MpesaPayment{} = mpesa_payment, attrs) do
    mpesa_payment
    |> MpesaPayment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mpesa_payment.

  ## Examples

      iex> delete_mpesa_payment(mpesa_payment)
      {:ok, %MpesaPayment{}}

      iex> delete_mpesa_payment(mpesa_payment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mpesa_payment(%MpesaPayment{} = mpesa_payment) do
    Repo.delete(mpesa_payment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mpesa_payment changes.

  ## Examples

      iex> change_mpesa_payment(mpesa_payment)
      %Ecto.Changeset{data: %MpesaPayment{}}

  """
  def change_mpesa_payment(%MpesaPayment{} = mpesa_payment, attrs \\ %{}) do
    MpesaPayment.changeset(mpesa_payment, attrs)
  end


  #from the payment checker
  def get_user_payments(user_id) do
    from(p in Payment,
      where: p.user_id == ^user_id and p.status == "pending",
      select_merge: %{
        days_until_due:
          fragment(
            "CASE WHEN ? > CURRENT_DATE THEN (? - CURRENT_DATE) END",
            p.due_date,
            p.due_date
          ),
        days_overdue:
          fragment(
            "CASE WHEN ? < CURRENT_DATE THEN (CURRENT_DATE - ?) END",
            p.due_date,
            p.due_date
          )
      }
    )
    |> Repo.all()
  end
  def get_payment_status(payment) do
    cond do
      payment.days_overdue != nil ->
        cond do
          payment.days_overdue > 30 -> :critical
          payment.days_overdue > 14 -> :warning
          payment.days_overdue > 0 -> :overdue
          true -> :pending
        end

      payment.days_until_due != nil ->
        cond do
          payment.days_until_due <= 5 -> :upcoming
          true -> :pending
        end

      true ->
        :pending
    end
  end

  def subscribe_to_payment_updates(user_id) do
    Phoenix.PubSub.subscribe(KejaDigital.PubSub, "user_payments:#{user_id}")
  end

  def broadcast_payment_update(payment) do
    Phoenix.PubSub.broadcast(
      KejaDigital.PubSub,
      "user_payments:#{payment.user_id}",
      {:payment_update, payment}
    )
  end

  @doc """
  Gets a user by phone number.
  Returns nil if the user is not found.
  """
  def get_user_by_phone(phone) do
    Repo.get_by(User, phone_number: phone)
  end

  @doc """
  Gets a user by door number.
  Returns nil if the user is not found.
  """
  def get_user_by_door_number(door_number) do
    Repo.get_by(User, door_number: door_number)
  end

  def search_payments(search, status) do
    Payments
    |> where([p], ilike(p.transaction_id, ^"%#{search}%") or ilike(p.phone_number, ^"%#{search}%"))
    |> filter_by_status(status)
    |> Repo.all()
  end

  def filter_by_status(query, "all"), do: query
  def filter_by_status(query, status) do
    where(query, [p], p.status == ^status)
  end
end
