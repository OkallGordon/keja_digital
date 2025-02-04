defmodule KejaDigital.AgreementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Agreements` context.
  """

  # Import the Store fixtures to create a user
  import KejaDigital.StoreFixtures

  @doc """
  Generate a tenant_agreement_live.
  """
  def tenant_agreement_live_fixture(attrs \\ %{}) do
    # Create a user first
    user = user_fixture()

    # Prepare default attributes
    defaults = %{
      tenant_id: user.id,  # Add tenant_id from the created user
      tenant_name: user.full_name,  # Use user's full name
      tenant_address: user.postal_address,  # Use user's postal address
      tenant_phone: user.phone_number,  # Use user's phone number
      rent: Decimal.new("15000"),
      deposit: Decimal.new("5000"),
      signature: "Signature",
      start_date: ~D[2024-01-01],
      agreement_content: "Agreement Content",
      status: "pending_review",
      submitted: false,
      property_id: 1,
      agreement_date: ~D[2025-01-01]
    }

    # Merge passed attributes with defaults
    attrs = defaults |> Map.merge(attrs)

    # Create tenant agreement
    case KejaDigital.Agreements.create_tenant_agreement_live(attrs) do
      {:ok, tenant_agreement_live} -> tenant_agreement_live
      {:error, changeset} -> raise "Failed to create tenant agreement: #{inspect(changeset.errors)}"
    end
  end
end
