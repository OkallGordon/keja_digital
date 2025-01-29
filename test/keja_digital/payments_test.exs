defmodule KejaDigital.Payments.MpesaPaymentTest do
  use KejaDigital.DataCase

  alias KejaDigital.Payments.MpesaPayment
  #alias KejaDigital.Store
  alias KejaDigital.Store.User

  describe "changeset/2" do
    @valid_attrs %{
      transaction_id: "MPESA123456",
      amount: Decimal.new("1000.00"),
      phone_number: "0712345678",
      till_number: "4154742",
      status: "completed",
      paid_at: DateTime.utc_now()
    }

    setup do
      # Create a test user with all required fields and full_name at least 10 characters
      {:ok, user} =
        %User{}
        |> User.registration_changeset(%{
          email: "test@gmail.com",
          phone_number: "0712345678",
          password: "somepassword123",
          role: "tenant",
          full_name: "John Doe Smith",
          postal_address: "P.O. Box 123",
          nationality: "Kenyan",
          organization: "Test Corp",
          next_of_kin: "Jane Doe",
          next_of_kin_contact: "0722345678",
          passport: "ABC123456"
        })
        |> Repo.insert()

      %{user: user}
    end

    test "creates valid changeset with all attributes", %{user: user} do
      changeset = MpesaPayment.changeset(%MpesaPayment{}, @valid_attrs)
      assert changeset.valid?
      assert get_change(changeset, :user_id) == user.id
    end

    test "returns error changeset with missing required fields" do
      changeset = MpesaPayment.changeset(%MpesaPayment{}, %{})
      refute changeset.valid?

      assert errors_on(changeset) == %{
        transaction_id: ["can't be blank"],
        amount: ["can't be blank"],
        phone_number: ["Phone number is missing", "can't be blank"],
        till_number: ["Invalid till number", "can't be blank"],
        status: ["can't be blank"],
        paid_at: ["can't be blank"]
      }
    end

    test "validates till number must be 4154742" do
      attrs = Map.put(@valid_attrs, :till_number, "1234567")
      changeset = MpesaPayment.changeset(%MpesaPayment{}, attrs)
      assert %{till_number: ["Invalid till number"]} = errors_on(changeset)
    end

    test "validates unique transaction_id constraint", %{user: _user} do
      # First, insert a payment
      {:ok, _payment} = %MpesaPayment{}
        |> MpesaPayment.changeset(@valid_attrs)
        |> Repo.insert()

      # Try to insert another payment with the same transaction_id
      {:error, changeset} = %MpesaPayment{}
        |> MpesaPayment.changeset(@valid_attrs)
        |> Repo.insert()

      assert %{transaction_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "returns error when user is not found for phone number" do
      attrs = Map.put(@valid_attrs, :phone_number, "0799999999")
      changeset = MpesaPayment.changeset(%MpesaPayment{}, attrs)
      assert %{phone_number: ["No user found with this phone number"]} = errors_on(changeset)
    end

    test "assigns correct user_id based on phone number", %{user: user} do
      changeset = MpesaPayment.changeset(%MpesaPayment{}, @valid_attrs)
      assert changeset.valid?
      assert get_change(changeset, :user_id) == user.id
    end

    test "handles different phone number formats", %{user: user} do
      # Update user's phone number to include country code
      {:ok, user} =
        user
        |> Ecto.Changeset.change(%{phone_number: "+254712345678"})
        |> Repo.update()

      attrs = Map.put(@valid_attrs, :phone_number, "+254712345678")
      changeset = MpesaPayment.changeset(%MpesaPayment{}, attrs)
      assert changeset.valid?
      assert get_change(changeset, :user_id) == user.id
    end
  end
end
