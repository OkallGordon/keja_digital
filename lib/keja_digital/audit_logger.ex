defmodule KejaDigital.AuditLogger do
  alias KejaDigital.Audit
  alias KejaDigital.Repo
  alias KejaDigital.Store.{User}
  alias KejaDigital.Backoffice.Admin

  @doc """
  Creates an audit log entry.
  """
  def log_action(action, actor, target_type, target_id \\ nil, changes \\ %{}, metadata \\ %{}) do
    %Audit{
      action: action,
      actor_id: get_actor_id(actor),
      actor_email: get_actor_email(actor),
      target_type: target_type,
      target_id: target_id,
      changes: changes,
      metadata: metadata
    }
    |> Repo.insert()
    |> broadcast_change()
  end

  defp get_actor_id(%User{id: id}), do: id
  defp get_actor_id(%Admin{id: id}), do: id
  defp get_actor_id(id) when is_integer(id), do: id
  defp get_actor_id(_), do: nil

  defp get_actor_email(%User{email: email}), do: email
  defp get_actor_email(%Admin{email: email}), do: email
  defp get_actor_email(email) when is_binary(email), do: email
  defp get_actor_email(_), do: nil

  defp broadcast_change({:ok, audit_log}) do
    Phoenix.PubSub.broadcast(KejaDigital.PubSub, "audit_logs", {:audit_log_created, audit_log})
    {:ok, audit_log}
  end
  defp broadcast_change(error), do: error

  # User-specific audit logging functions
  def log_registration(user) do
    log_action("user_registration", user, "User", user.id)
  end

  def log_profile_update(user, changes) do
    log_action("profile_update", user, "User", user.id, changes)
  end

  def log_password_change(user) do
    log_action("password_change", user, "User", user.id)
  end

  def log_login(user, metadata \\ %{}) do
    log_action("login", user, "Session", user.id, %{}, metadata)
  end

  def log_logout(user, metadata \\ %{}) do
    log_action("logout", user, "Session", user.id, %{}, metadata)
  end

  def log_account_deletion(user) do
    log_action("account_deletion", user, "User", user.id)
  end

  def log_agreement_submission(user, agreement_id) do
    log_action("agreement_submission", user, "Agreement", agreement_id)
  end

  def log_agreement_opening(user, agreement_id) do
    log_action("agreement_opening", user, "Agreement", agreement_id)
  end

  # Admin-specific audit logging functions
  def log_admin_login(admin, metadata \\ %{}) do
    log_action("admin_login", admin, "AdminSession", admin.id, %{}, metadata)
  end

  def log_admin_logout(admin, metadata \\ %{}) do
    log_action("admin_logout", admin, "AdminSession", admin.id, %{}, metadata)
  end

  def log_user_suspension(admin, user, reason \\ nil) do
    log_action("user_suspension", admin, "User", user.id, %{"reason" => reason})
  end

  def log_user_reinstatement(admin, user) do
    log_action("user_reinstatement", admin, "User", user.id)
  end

  def log_system_configuration_change(admin, changes) do
    log_action("system_configuration_change", admin, "System", nil, changes)
  end

  @doc """
  Logs an admin record deletion, and updates the user's audit logs.
  """
  def log_delete(admin) do
    log_action("admin_delete", admin, "Admin", admin.id)
  end

  def log_update(admin, changes) do
    log_action("admin_update", admin, "Admin", admin.id, changes)
  end

  @doc """
  Backfills audit logs for existing users or admins.
  Use this carefully and only when needed.
  """
  def backfill_user_audit_logs do
    Repo.all(User)
    |> Enum.each(fn user ->
      log_action("user_backfill", user, "User", user.id, %{
        email: user.email,
        inserted_at: user.inserted_at
      })
    end)
  end

  def backfill_admin_audit_logs do
    Repo.all(Admin)
    |> Enum.each(fn admin ->
      log_action("admin_backfill", admin, "Admin", admin.id, %{
        email: admin.email,
        inserted_at: admin.inserted_at
      })
    end)
  end
end
