defmodule KejaDigital.Properties.Property do
  use Ecto.Schema
  import Ecto.Changeset

  schema "properties" do
    field :title, :string
    field :description, :string
    field :price, :decimal
    field :status, :string, default: "active"
    field :property_type, :string
    field :bedrooms, :integer
    field :bathrooms, :integer
    field :floor_area, :integer
    field :location, :string
    field :saved, :boolean, default: false
    field :featured, :boolean, default: false
    field :owner_id, :integer

    timestamps()
  end

  def changeset(property, attrs) do
    property
    |> cast(attrs, [:title, :description, :price, :status, :property_type,
                    :bedrooms, :bathrooms, :floor_area, :location, :saved,
                    :featured, :owner_id])
    |> validate_required([:title, :price, :property_type, :location, :owner_id])
    |> validate_inclusion(:status, ["active", "inactive", "sold", "rented"])
    |> validate_inclusion(:property_type, ["apartment", "house", "commercial", "land"])
    |> validate_number(:price, greater_than: 0)
  end
end
