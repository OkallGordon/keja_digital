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


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tenant_agreement_live, attrs) do
    tenant_agreement_live
    |> cast(attrs, [:tenant_name, :tenant_address, :tenant_phone, :rent, :late_fee, :deposit, :signature, :start_date, :agreement_content])
    |> validate_required([])
  end
end
