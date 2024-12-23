defmodule KejaDigital.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Payments` context.
  """

  @doc """
  Generate a unique mpesa_payment transaction_id.
  """
  def unique_mpesa_payment_transaction_id, do: "some transaction_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a mpesa_payment.
  """
  def mpesa_payment_fixture(attrs \\ %{}) do
    {:ok, mpesa_payment} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        paid_at: ~U[2024-12-19 14:15:00Z],
        phone_number: "some phone_number",
        status: "some status",
        tenant_id: 42,
        till_number: "some till_number",
        transaction_id: unique_mpesa_payment_transaction_id()
      })
      |> KejaDigital.Payments.create_mpesa_payment()

    mpesa_payment
  end
end
