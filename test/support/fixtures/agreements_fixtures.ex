defmodule KejaDigital.AgreementsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Agreements` context.
  """

  @doc """
  Generate a tenant_agreement_live.
  """
  def tenant_agreement_live_fixture(attrs \\ %{}) do
    {:ok, tenant_agreement_live} =
      attrs
      |> Enum.into(%{

      })
      |> KejaDigital.Agreements.create_tenant_agreement_live()

    tenant_agreement_live
  end
end
