defmodule KejaDigital.AgreementsTest do
  use KejaDigital.DataCase

  alias KejaDigital.Agreements
  alias KejaDigital.Agreements.TenantAgreementLive

  # Import fixtures
  import KejaDigital.StoreFixtures
  import KejaDigital.AgreementsFixtures

  describe "tenant_agreements" do
    @valid_attrs %{
      tenant_name: "John Doe",
      tenant_address: "123 Test Street, Nairobi",
      tenant_phone: "0712345678",
      rent: Decimal.new("50000.00"),
      late_fee: "10%",
      deposit: Decimal.new("100000.00"),
      signature: "John Doe Signature",
      start_date: ~D[2024-01-01],
      agreement_content: "Standard tenancy agreement",
      status: "pending_review",
      submitted: false
    }

    @update_attrs %{
      tenant_name: "Jane Doe",
      rent: Decimal.new("55000.00"),
      status: "approved",
      submitted: true
    }

    @invalid_attrs %{
      tenant_name: "",
      tenant_phone: "invalid",
      rent: -1000,
      deposit: 0
    }

    def tenant_agreement_fixture(attrs \\ %{}) do
      # Create a user first
      user = user_fixture()

      # Merge user details with default and passed attributes
      merged_attrs = Map.merge(@valid_attrs, attrs)
      |> Map.put(:tenant_id, user.id)
      |> Map.put(:tenant_name, user.full_name)
      |> Map.put(:tenant_phone, user.phone_number)

      {:ok, tenant_agreement} = Agreements.create_tenant_agreement_live(merged_attrs)
      tenant_agreement
    end

    test "list_tenant_agreements/0 returns all tenant agreements" do
      tenant_agreement = tenant_agreement_fixture()
      assert Agreements.list_tenant_agreements() == [tenant_agreement]
    end

    test "get_tenant_agreement_live!/1 returns the tenant agreement with given id" do
      tenant_agreement = tenant_agreement_fixture()
      assert Agreements.get_tenant_agreement_live!(tenant_agreement.id) == tenant_agreement
    end

    test "create_tenant_agreement_live/1 with valid data creates a tenant agreement" do
      user = user_fixture()

      attrs = @valid_attrs
      |> Map.put(:tenant_id, user.id)
      |> Map.put(:tenant_name, user.full_name)
      |> Map.put(:tenant_phone, user.phone_number)

      assert {:ok, %TenantAgreementLive{} = tenant_agreement} =
        Agreements.create_tenant_agreement_live(attrs)

      assert tenant_agreement.tenant_name == user.full_name
      assert tenant_agreement.status == "pending_review"
      assert tenant_agreement.submitted == false
    end

    test "create_tenant_agreement_live/1 with invalid data returns error changeset" do
      user = user_fixture()

      invalid_attrs = @invalid_attrs
      |> Map.put(:tenant_id, user.id)

      assert {:error, %Ecto.Changeset{}} =
        Agreements.create_tenant_agreement_live(invalid_attrs)
    end

    test "update_tenant_agreement_live/2 with valid data updates the tenant agreement" do
      tenant_agreement = tenant_agreement_fixture()

      assert {:ok, %TenantAgreementLive{} = updated_agreement} =
        Agreements.update_tenant_agreement_live(tenant_agreement, @update_attrs)

      assert updated_agreement.tenant_name == "Jane Doe"
      assert updated_agreement.rent == Decimal.new("55000.00")
      assert updated_agreement.status == "approved"
      assert updated_agreement.submitted == true
    end

    test "update_tenant_agreement_live/2 with invalid data returns error changeset" do
      tenant_agreement = tenant_agreement_fixture()

      assert {:error, %Ecto.Changeset{}} =
        Agreements.update_tenant_agreement_live(tenant_agreement, @invalid_attrs)

      assert tenant_agreement == Agreements.get_tenant_agreement_live!(tenant_agreement.id)
    end

    test "delete_tenant_agreement_live/1 deletes the tenant agreement" do
      tenant_agreement = tenant_agreement_fixture()
      assert {:ok, %TenantAgreementLive{}} = Agreements.delete_tenant_agreement_live(tenant_agreement)

      assert_raise Ecto.NoResultsError, fn ->
        Agreements.get_tenant_agreement_live!(tenant_agreement.id)
      end
    end

    test "list_tenant_agreements_for_user/1 returns agreements for a specific user" do
      # Create a tenant agreement (which also creates a user)
      tenant_agreement = tenant_agreement_live_fixture()

      all_agreements = Repo.all(TenantAgreementLive)
      IO.puts("\nAll Tenant Agreements in Database:")
      Enum.each(all_agreements, fn agreement ->
        IO.puts("Agreement ID: #{agreement.id}, Tenant ID: #{agreement.tenant_id}")
      end)

      agreements = Agreements.list_tenant_agreements_for_user(tenant_agreement.tenant_id)
      IO.puts("\nFetched Agreements:")
      Enum.each(agreements, fn agreement ->
        IO.puts("Fetched Agreement ID: #{agreement.id}, Tenant ID: #{agreement.tenant_id}")
      end)
      assert length(agreements) == 1, "Expected 1 agreement, but found #{length(agreements)}"
      assert hd(agreements).id == tenant_agreement.id
    end

    test "changeset validates phone number format" do
      user = user_fixture()

      invalid_phone_attrs = @valid_attrs
      |> Map.put(:tenant_id, user.id)
      |> Map.put(:tenant_phone, "invalid phone")

      {:error, changeset} = Agreements.create_tenant_agreement_live(invalid_phone_attrs)

      assert "must contain only numbers and plus sign" in errors_on(changeset).tenant_phone
    end

    test "changeset validates rent and deposit are positive" do
      user = user_fixture()

      negative_attrs = @valid_attrs
      |> Map.put(:tenant_id, user.id)
      |> Map.merge(%{rent: Decimal.new("-1000"), deposit: Decimal.new("-500")})

      {:error, changeset} = Agreements.create_tenant_agreement_live(negative_attrs)

      assert "must be greater than 0" in errors_on(changeset).rent
      assert "must be greater than 0" in errors_on(changeset).deposit
    end

    test "changeset validates status inclusion" do
      user = user_fixture()

      invalid_status_attrs = @valid_attrs
      |> Map.put(:tenant_id, user.id)
      |> Map.put(:status, "invalid_status")

      {:error, changeset} = Agreements.create_tenant_agreement_live(invalid_status_attrs)

      assert "is invalid" in errors_on(changeset).status
    end
  end
end
