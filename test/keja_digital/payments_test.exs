defmodule KejaDigital.PaymentsTest do
  use KejaDigital.DataCase

  alias KejaDigital.Payments

  describe "mpesa_payments" do
    alias KejaDigital.Payments.MpesaPayment

    import KejaDigital.PaymentsFixtures

    @invalid_attrs %{status: nil, transaction_id: nil, amount: nil, phone_number: nil, till_number: nil, paid_at: nil, tenant_id: nil}

    test "list_mpesa_payments/0 returns all mpesa_payments" do
      mpesa_payment = mpesa_payment_fixture()
      assert Payments.list_mpesa_payments() == [mpesa_payment]
    end

    test "get_mpesa_payment!/1 returns the mpesa_payment with given id" do
      mpesa_payment = mpesa_payment_fixture()
      assert Payments.get_mpesa_payment!(mpesa_payment.id) == mpesa_payment
    end

    test "create_mpesa_payment/1 with valid data creates a mpesa_payment" do
      valid_attrs = %{status: "some status", transaction_id: "some transaction_id", amount: "120.5", phone_number: "some phone_number", till_number: "some till_number", paid_at: ~U[2024-12-19 14:15:00Z], tenant_id: 42}

      assert {:ok, %MpesaPayment{} = mpesa_payment} = Payments.create_mpesa_payment(valid_attrs)
      assert mpesa_payment.status == "some status"
      assert mpesa_payment.transaction_id == "some transaction_id"
      assert mpesa_payment.amount == Decimal.new("120.5")
      assert mpesa_payment.phone_number == "some phone_number"
      assert mpesa_payment.till_number == "some till_number"
      assert mpesa_payment.paid_at == ~U[2024-12-19 14:15:00Z]
      assert mpesa_payment.tenant_id == 42
    end

    test "create_mpesa_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_mpesa_payment(@invalid_attrs)
    end

    test "update_mpesa_payment/2 with valid data updates the mpesa_payment" do
      mpesa_payment = mpesa_payment_fixture()
      update_attrs = %{status: "some updated status", transaction_id: "some updated transaction_id", amount: "456.7", phone_number: "some updated phone_number", till_number: "some updated till_number", paid_at: ~U[2024-12-20 14:15:00Z], tenant_id: 43}

      assert {:ok, %MpesaPayment{} = mpesa_payment} = Payments.update_mpesa_payment(mpesa_payment, update_attrs)
      assert mpesa_payment.status == "some updated status"
      assert mpesa_payment.transaction_id == "some updated transaction_id"
      assert mpesa_payment.amount == Decimal.new("456.7")
      assert mpesa_payment.phone_number == "some updated phone_number"
      assert mpesa_payment.till_number == "some updated till_number"
      assert mpesa_payment.paid_at == ~U[2024-12-20 14:15:00Z]
      assert mpesa_payment.tenant_id == 43
    end

    test "update_mpesa_payment/2 with invalid data returns error changeset" do
      mpesa_payment = mpesa_payment_fixture()
      assert {:error, %Ecto.Changeset{}} = Payments.update_mpesa_payment(mpesa_payment, @invalid_attrs)
      assert mpesa_payment == Payments.get_mpesa_payment!(mpesa_payment.id)
    end

    test "delete_mpesa_payment/1 deletes the mpesa_payment" do
      mpesa_payment = mpesa_payment_fixture()
      assert {:ok, %MpesaPayment{}} = Payments.delete_mpesa_payment(mpesa_payment)
      assert_raise Ecto.NoResultsError, fn -> Payments.get_mpesa_payment!(mpesa_payment.id) end
    end

    test "change_mpesa_payment/1 returns a mpesa_payment changeset" do
      mpesa_payment = mpesa_payment_fixture()
      assert %Ecto.Changeset{} = Payments.change_mpesa_payment(mpesa_payment)
    end
  end
end
