defmodule KejaDigital.Payments.MpesaPayment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mpesa_payments" do
    field :status, :string
    field :transaction_id, :string
    field :amount, :decimal
    field :phone_number, :string
    field :till_number, :string
    field :paid_at, :utc_datetime
    field :tenant_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(mpesa_payment, attrs) do
    mpesa_payment
    |> cast(attrs, [:transaction_id, :amount, :phone_number, :till_number, :status, :paid_at, :tenant_id])
    |> validate_required([:transaction_id, :amount, :phone_number, :till_number, :status, :paid_at, :tenant_id])
    |> unique_constraint(:transaction_id)
  end
end
