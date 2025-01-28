defmodule KejaDigital.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Payments` context.
  """

  @doc """
  Generate a unique mpesa_payment transaction_id.
  """
  def unique_mpesa_payment_transaction_id, do: "TX#{System.unique_integer([:positive])}"

  @doc """
  Generate a mpesa_payment.
  """
  def mpesa_payment_fixture(attrs \\ %{}) do
    tenant = KejaDigital.StoreFixtures.user_fixture()

    {:ok, mpesa_payment} =
      attrs
      |> Enum.into(%{
        amount: 120.50,
        paid_at: DateTime.utc_now(),
        phone_number: "0723456789",
        status: "completed",
        tenant_id: tenant.id,
        till_number: "123456",
        transaction_id: unique_mpesa_payment_transaction_id()
      })
      |> KejaDigital.Payments.create_mpesa_payment()

    mpesa_payment
  end
end
