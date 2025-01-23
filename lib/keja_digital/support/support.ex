defmodule KejaDigital.Support.Booking do
  @moduledoc """
  Schema definition for support bookings.
  Represents a customer's request for support or consultation.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @booking_types [
    "technical",
    "billing",
    "account",
    "maintenance",
    "general"
  ]

  @booking_statuses [
    "pending",
    "scheduled",
    "in_progress",
    "completed",
    "cancelled"
  ]

  schema "support_bookings" do
    # Personal Information
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone, :string

    # Booking Details
    field :booking_type, :string
    field :description, :string
    field :preferred_date, :date
    field :preferred_time, :time

    # Booking Status
    field :status, :string, default: "pending"
    field :notes, :string

    # Metadata
    field :assigned_agent_id, :integer
    field :reference_number, :string

    timestamps()
  end

  @doc """
  Changeset for creating or updating a support booking.
  Performs comprehensive validation of booking attributes.
  """
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [
      :first_name,
      :last_name,
      :email,
      :phone,
      :booking_type,
      :description,
      :preferred_date,
      :preferred_time,
      :status,
      :notes,
      :assigned_agent_id
    ])
    |> validate_required([
      :first_name,
      :last_name,
      :email,
      :phone,
      :booking_type,
      :description,
      :preferred_date
    ])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_inclusion(:booking_type, @booking_types)
    |> validate_inclusion(:status, @booking_statuses)
    |> validate_length(:first_name, min: 2, max: 50)
    |> validate_length(:last_name, min: 2, max: 50)
    |> validate_length(:description, min: 10, max: 500)
    |> validate_phone_number()
    |> unique_constraint(:reference_number)
    |> generate_reference_number()
  end

  # Validate phone number format
  defp validate_phone_number(changeset) do
    phone = get_change(changeset, :phone)

    if phone do
      # Simple phone number validation (adjust regex as needed)
      case Regex.run(~r/^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$/, phone) do
        nil ->
          add_error(changeset, :phone, "is invalid")
        _ ->
          changeset
      end
    else
      changeset
    end
  end

  # Generate a unique reference number for the booking
  defp generate_reference_number(changeset) do
    if get_field(changeset, :reference_number) == nil do
      # Generate a unique reference number
      reference = "SUP-#{:rand.uniform(100000)}"
      put_change(changeset, :reference_number, reference)
    else
      changeset
    end
  end
end
