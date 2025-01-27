defmodule KejaDigital.AgreementsTest do
  use KejaDigital.DataCase

  alias KejaDigital.Agreements
  alias KejaDigital.Agreements.TenantAgreementLive

  import KejaDigital.AgreementsFixtures

  @valid_attrs %{
    tenant_name: "John Doe",
    tenant_address: "123 Main St",
    tenant_phone: "1234567890",
    tenant_id: 1,
    rent: 15000,
    late_fee: "100",
    deposit: 5000,
    signature: "Signature",
    start_date: ~D[2024-01-01],
    agreement_content: "Agreement Content",
    status: "pending_review",
    submitted: true
  }

  @invalid_attrs %{
    tenant_name: nil,
    tenant_address: nil,
    tenant_phone: nil,
    tenant_id: nil,
    rent: nil,
    late_fee: nil,
    deposit: nil,
    signature: nil,
    start_date: nil,
    agreement_content: nil,
    status: nil,
    submitted: nil
  }

  describe "tenant_agreements" do
    test "list_tenant_agreements/0 returns all tenant_agreements" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      assert Agreements.list_tenant_agreements() == [tenant_agreement_live]
    end

    test "get_tenant_agreement_live!/1 returns the tenant_agreement_live with given id" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      assert Agreements.get_tenant_agreement_live!(tenant_agreement_live.id) == tenant_agreement_live
    end

    test "create_tenant_agreement_live/1 with valid data creates a tenant_agreement_live" do
      assert {:ok, %TenantAgreementLive{} = agreement} = Agreements.create_tenant_agreement_live(@valid_attrs)
      assert agreement.tenant_name == "John Doe"
      assert agreement.tenant_address == "123 Main St"
      assert agreement.rent == Decimal.new("15000")
      assert agreement.status == "pending_review"
    end

    test "create_tenant_agreement_live/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Agreements.create_tenant_agreement_live(@invalid_attrs)
    end

    test "update_tenant_agreement_live/2 with valid data updates the tenant_agreement_live" do
      tenant_agreement_live = tenant_agreement_live_fixture()
      update_attrs = %{
        rent: 16000,
        status: "approved"
      }

      assert {:ok, %TenantAgreementLive{} = agreement} = Agreements.update_tenant_agreement_live(tenant_agreement_live, update_attrs)
      assert agreement.rent == Decimal.new("16000")
      assert agreement.status == "approved"
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
