defmodule KejaDigital.Store.DoorNumber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "door_numbers" do
    field :number, :string
    field :occupied, :boolean, default: false

    timestamps()
  end

  def changeset(door_number, attrs) do
    door_number
    |> cast(attrs, [:number, :occupied])
    |> validate_required([:number, :occupied])
    |> unique_constraint(:number)
  end
end
