defmodule KejaDigital.AgreementsTest do
  use KejaDigital.DataCase

  alias KejaDigital.Agreements

  describe "tenant_agreements" do
    alias KejaDigital.Agreements.TenantAgreementLive

    import KejaDigital.AgreementsFixtures

    @invalid_attrs %{}

    test "list_tenant_agreements/0 returns all tenant_agreements" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      assert Agreements.list_tenant_agreements() == [tenant_agreement_live]
    end

    test "get_tenant_agreement_live!/1 returns the tenant_agreement_live with given id" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      assert Agreements.get_tenant_agreement_live!(tenant_agreement_live.id) == tenant_agreement_live
    end

    test "create_tenant_agreement_live/1 with valid data creates a tenant_agreement_live" do
      valid_attrs = %{}

      assert {:ok, %TenantAgreementLive{} = tenant_agreement_live} = Agreements.create_tenant_agreement_live(valid_attrs)
    end

    test "create_tenant_agreement_live/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Agreements.create_tenant_agreement_live(@invalid_attrs)
    end

    test "update_tenant_agreement_live/2 with valid data updates the tenant_agreement_live" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      update_attrs = %{}

      assert {:ok, %TenantAgreementLive{} = tenant_agreement_live} = Agreements.update_tenant_agreement_live(tenant_agreement_live, update_attrs)
    end

    test "update_tenant_agreement_live/2 with invalid data returns error changeset" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      assert {:error, %Ecto.Changeset{}} = Agreements.update_tenant_agreement_live(tenant_agreement_live, @invalid_attrs)
      assert tenant_agreement_live == Agreements.get_tenant_agreement_live!(tenant_agreement_live.id)
    end

    test "delete_tenant_agreement_live/1 deletes the tenant_agreement_live" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      assert {:ok, %TenantAgreementLive{}} = Agreements.delete_tenant_agreement_live(tenant_agreement_live)
      assert_raise Ecto.NoResultsError, fn -> Agreements.get_tenant_agreement_live!(tenant_agreement_live.id) end
    end

    test "change_tenant_agreement_live/1 returns a tenant_agreement_live changeset" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      assert %Ecto.Changeset{} = Agreements.change_tenant_agreement_live(tenant_agreement_live)
    end
  end
end
