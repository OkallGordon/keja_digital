defmodule KejaDigital.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias KejaDigital.Repo

  alias KejaDigital.Payments.MpesaPayment

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
  |> limit(50)  # Adjust limit as needed
  |> Repo.all()
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
  def get_mpesa_payment!(id), do: Repo.get!(MpesaPayment, id)

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
end
