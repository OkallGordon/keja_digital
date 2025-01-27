defmodule KejaDigital.NotificationsTest do
  use KejaDigital.DataCase
  alias KejaDigital.Notifications
  import KejaDigital.NotificationsFixtures

  describe "notifications" do
    alias KejaDigital.Notifications.Notification

    @invalid_attrs %{title: nil, content: nil, is_read: nil}
    @valid_attrs %{title: "some title", content: "some content", is_read: true}
    @update_attrs %{title: "some updated title", content: "some updated content", is_read: false}

    # Setup block to create an admin for testing
    setup do
      # Replace with actual admin creation if needed
      admin = %{id: 1}  # Assuming admin has id 1
      {:ok, admin: admin}
    end

    test "list_notifications/1 returns all notifications", %{admin: admin} do
      notification = notification_fixture(admin_id: admin.id)
      assert Notifications.list_notifications(admin.id) == [notification]
    end

    test "get_notification!/1 returns the notification with given id" do
      notification = notification_fixture()
      assert Notifications.get_notification!(notification.id) == notification
    end

    test "create_notification/1 with valid data creates a notification" do
      assert {:ok, %Notification{} = notification} = Notifications.create_notification(@valid_attrs)
      assert notification.title == "some title"
      assert notification.content == "some content"
      assert notification.is_read == true
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{} = notification} = Notifications.update_notification(notification, @update_attrs)
      assert notification.title == "some updated title"
      assert notification.content == "some updated content"
      assert notification.is_read == false
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = notification_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_notification(notification, @invalid_attrs)
      assert notification == Notifications.get_notification!(notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = notification_fixture()
      assert {:ok, %Notification{}} = Notifications.delete_notification(notification)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification!(notification.id) end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = notification_fixture()
      assert %Ecto.Changeset{} = Notifications.change_notification(notification)
    end
  end
end
