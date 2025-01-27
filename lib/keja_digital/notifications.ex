defmodule KejaDigital.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query, warn: false
  alias KejaDigital.Repo

  alias KejaDigital.Notifications.Notification

  # Mark a single notification as read
  def mark_as_read(notification_id) do
    Notification
    |> Repo.get(notification_id)
    |> case do
      nil -> {:error, :not_found}
      notification ->
        notification
        |> Notification.changeset(%{status: "read"})
        |> Repo.update()
    end
  end
  # Mark all notifications as read for a given admin

  def mark_all_as_read(admin_id) do
    from(n in Notification, where: n.admin_id == ^admin_id and not n.is_read, update: [set: [is_read: true]])
    |> Repo.update_all([])
  end


  @doc """
  Returns the list of notifications.

  ## Examples

      iex> list_notifications()
      [%Notification{}, ...]

  """
  def list_notifications(admin_id) do
    Notification
    |> where([n], n.admin_id == ^admin_id)
    |> Repo.all()
  end

  @doc """
  Gets a single notification.

  Raises `Ecto.NoResultsError` if the Notification does not exist.

  ## Examples

      iex> get_notification!(123)
      %Notification{}

      iex> get_notification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_notification!(id), do: Repo.get!(Notification, id)

   @doc """
  Creates a notification based on a booking.

  ## Parameters
    - booking: The booking struct for which the notification is being created
    - admin_id: The admin id who will receive the notification

  ## Returns
    - {:ok, notification} if successful
    - {:error, changeset} if validation fails
  """
  def create_notification_for_booking(booking, admin_id) do
    IO.inspect(booking, label: "Booking Data")

    notification_attrs = %{
      title: "New Support Booking: #{booking.booking_type}",
      content: """
      A new booking has been made with the following details:
      - Description: #{booking.description}
      - Name: #{booking.first_name} #{booking.last_name}
      - Phone: #{booking.phone}
      - Preferred Date: #{booking.preferred_date}
      """,
      admin_id: admin_id,
      is_read: false
    }
    IO.inspect(notification_attrs, label: "Notification Attributes")

    create_notification(notification_attrs)
  end


  @doc """
  Creates a notification.

  ## Examples

      iex> create_notification(%{field: value})
      {:ok, %Notification{}}

      iex> create_notification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_notification(attrs \\ %{}) do
    changeset = Notification.changeset(%Notification{}, attrs)

    case Repo.insert(changeset) do
      {:ok, notification} ->
        {:ok, notification}

      {:error, changeset} ->
        IO.inspect(changeset.errors, label: "Changeset Errors")
        {:error, changeset}
    end
  end

  @doc """
  Updates a notification.

  ## Examples

      iex> update_notification(notification, %{field: new_value})
      {:ok, %Notification{}}

      iex> update_notification(notification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_notification(%Notification{} = notification, attrs) do
    notification
    |> Notification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a notification.

  ## Examples

      iex> delete_notification(notification)
      {:ok, %Notification{}}

      iex> delete_notification(notification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_notification(%Notification{} = notification) do
    Repo.delete(notification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking notification changes.

  ## Examples

      iex> change_notification(notification)
      %Ecto.Changeset{data: %Notification{}}

  """
  def change_notification(%Notification{} = notification, attrs \\ %{}) do
    Notification.changeset(notification, attrs)
  end
end
