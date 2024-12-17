defmodule KejaDigital.Agreements.TenantAgreementLive do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tenant_agreements" do
      field :tenant_name, :string
      field :tenant_address, :string
      field :tenant_phone, :string
      field :rent, :decimal
      field :late_fee, :string
      field :deposit, :decimal
      field :signature, :string
      field :start_date, :date
      field :agreement_content, :string
      field :signed_at, :naive_datetime

      field :status, :string, default: "pending_review"



    timestamps(type: :utc_datetime)
  end

  def changeset(tenant_agreement_live, attrs) do
    tenant_agreement_live
    |> cast(attrs, [:tenant_name, :tenant_address, :tenant_phone, :rent, :late_fee, :deposit, :signature, :start_date, :agreement_content, :status])
    |> validate_required([:tenant_name, :tenant_address, :tenant_phone, :rent, :deposit, :signature, :start_date, :status])
    |> validate_length(:tenant_name, min: 2, max: 100)
    |> validate_length(:tenant_phone, min: 10, max: 15)
    |> validate_format(:tenant_phone, ~r/^[0-9+]+$/, message: "must contain only numbers and plus sign")
    |> validate_number(:rent, greater_than: 0)
    |> validate_number(:deposit, greater_than: 0)
    |> validate_inclusion(:status, ["pending_review", "approved", "rejected"])
  end
end
