defmodule KejaDigital.Support do
  @moduledoc """
  Context module for handling support-related operations.
  Manages creation, retrieval, and management of support bookings.
  """

  import Ecto.Query
  #import Ecto.Changeset

  alias KejaDigital.Repo
  alias KejaDigital.Support.Booking

  @doc """
  Creates a new support booking.

  ## Parameters
    - attrs: A map of attributes for creating a support booking

  ## Returns
    - {:ok, booking} if successful
    - {:error, changeset} if validation fails
  """
  def create_booking(attrs) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves a support booking by its ID.

  ## Parameters
    - id: The unique identifier of the booking

  ## Returns
    - Booking struct if found
    - nil if not found
  """
  def get_booking(id), do: Repo.get(Booking, id)

  @doc """
  Retrieves all support bookings with optional filtering.

  ## Parameters
    - filters: A keyword list of optional filters

  ## Examples
    Support.list_bookings(status: "pending")
    Support.list_bookings(booking_type: "technical")
  """
  def list_bookings(filters \\ []) do
    Booking
    |> maybe_filter_by_status(filters[:status])
    |> maybe_filter_by_type(filters[:booking_type])
    |> maybe_filter_by_date_range(filters[:start_date], filters[:end_date])
    |> Repo.all()
  end

  @doc """
  Updates an existing support booking.

  ## Parameters
    - booking: The existing booking struct
    - attrs: A map of attributes to update

  ## Returns
    - {:ok, updated_booking} if successful
    - {:error, changeset} if validation fails
  """
  def update_booking(%Booking{} = booking, attrs) do
    booking
    |> Booking.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a support booking.

  ## Parameters
    - booking: The booking struct to delete

  ## Returns
    - {:ok, deleted_booking} if successful
    - {:error, changeset} if deletion fails
  """
  def delete_booking(%Booking{} = booking) do
    Repo.delete(booking)
  end

  @doc """
  Generates a changeset for a new or existing booking.

  ## Parameters
    - booking: The booking struct (can be new or existing)
    - attrs: A map of attributes to apply to the changeset

  ## Returns
    - Ecto.Changeset struct
  """
  def change_booking(%Booking{} = booking, attrs \\ %{}) do
    Booking.changeset(booking, attrs)
  end

  # Private filtering helpers
  defp maybe_filter_by_status(query, nil), do: query
  defp maybe_filter_by_status(query, status) do
    where(query, [b], b.status == ^status)
  end

  defp maybe_filter_by_type(query, nil), do: query
  defp maybe_filter_by_type(query, type) do
    where(query, [b], b.booking_type == ^type)
  end

  defp maybe_filter_by_date_range(query, nil, nil), do: query
  defp maybe_filter_by_date_range(query, start_date, end_date) do
    query
    |> maybe_filter_start_date(start_date)
    |> maybe_filter_end_date(end_date)
  end

  defp maybe_filter_start_date(query, nil), do: query
  defp maybe_filter_start_date(query, start_date) do
    where(query, [b], b.preferred_date >= ^start_date)
  end

  defp maybe_filter_end_date(query, nil), do: query
  defp maybe_filter_end_date(query, end_date) do
    where(query, [b], b.preferred_date <= ^end_date)
  end
end
