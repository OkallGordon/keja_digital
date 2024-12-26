defmodule KejaDigital.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :amount, :decimal
    field :due_date, :date
    field :status, :string, default: "pending"
    field :days_overdue, :integer, virtual: true
    field :door_number, :string
    field :user_id, :integer
    field :unit_id, :integer

    timestamps()
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :due_date, :status, :user_id, :door_number, :unit_id])
    |> validate_required([:amount, :due_date, :status, :user_id, :door_number])
    |> validate_number(:amount, greater_than: 0)
    |> assoc_constraint(:user_id)
    |> assoc_constraint(:unit)
  end
end
