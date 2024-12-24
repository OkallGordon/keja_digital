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
    |> validate_till_number()
    |> assign_tenant
  end

  defp validate_till_number(changeset) do
    case get_field(changeset, :till_number) do
      "4154742" -> changeset
      _ -> add_error(changeset, :till_number, "Invalid till number")
    end
  end

  defp assign_tenant(changeset) do
    case get_field(changeset, :phone_number) do
      nil -> changeset
      phone ->
        case KejaDigital.Store.get_tenant_by_phone(phone) do
          nil -> add_error(changeset, :phone_number, "No tenant found with this phone number")
          tenant -> put_change(changeset, :tenant_id, tenant.id)
        end
    end
  end
end
