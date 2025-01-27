defmodule KejaDigital.AgreementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Agreements` context.
  """

  @doc """
  Generate a tenant_agreement_live.
  """
  def tenant_agreement_live_fixture(attrs \\ %{}, debug \\ false) do
    defaults = %{
      tenant_name: "Simba Mufasa",
      tenant_address: "123 Main St",
      tenant_phone: "1234567890",
      rent: Decimal.new("15000"),  # Assuming rent is stored as a Decimal
      deposit: Decimal.new("5000"),  # Assuming deposit is stored as a Decimal
      signature: "Signature",
      start_date: ~D[2024-01-01],
      agreement_content: "Agreement Content",
      status: "pending_review",
      submitted: true,
      property_id: 1,  # If you need to associate with a property
      agreement_date: ~D[2025-01-01]  # If applicable
    }

    attrs = Enum.into(attrs, defaults)

    if debug, do: IO.inspect(attrs, label: "Fixture Attributes")

    case KejaDigital.Agreements.create_tenant_agreement_live(attrs) do
      {:ok, tenant_agreement_live} -> tenant_agreement_live
      {:error, changeset} ->
        raise "Failed to create tenant agreement: #{inspect(changeset.errors)}"
    end
  end
end
