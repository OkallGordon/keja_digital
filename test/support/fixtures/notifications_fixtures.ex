defmodule KejaDigital.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Notifications` context.
  """

  @doc """
  Generate a notification.
  """
  def notification_fixture(attrs \\ %{}) do
    {:ok, notification} =
      attrs
      |> Enum.into(%{
        content: "some content",
        is_read: true,
        title: "some title"
      })
      |> KejaDigital.Notifications.create_notification()

    notification
  end
end
