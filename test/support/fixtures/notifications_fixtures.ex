defmodule KejaDigital.NotificationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Notifications` context.
  """

  @doc """
  Generate a notification with a given admin_id.
  """
  def notification_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "some content",
        is_read: true,
        title: "some title",
        admin_id: 1
      })

    {:ok, notification} =
      KejaDigital.Notifications.create_notification(attrs)

    notification
  end
end
