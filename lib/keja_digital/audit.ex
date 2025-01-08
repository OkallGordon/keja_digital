defmodule KejaDigital.Audit do
  use Ecto.Schema
  import Ecto.Changeset
 # import Ecto.Query

  schema "audit_logs" do
    field :action, :string
    field :actor_id, :integer
    field :actor_email, :string
    field :target_type, :string
    field :target_id, :integer
    field :changes, :map
    field :metadata, :map

    timestamps()
  end

  def log_action(actor, action, target, changes \\ %{}, metadata \\ %{}) do
    %KejaDigital.Audit{}
    |> cast(%{
      action: action,
      actor_id: actor.id,
      actor_email: actor.email,
      target_type: target.__struct__ |> to_string(),
      target_id: target.id,
      changes: changes,
      metadata: metadata
    }, [:action, :actor_id, :actor_email, :target_type, :target_id, :changes, :metadata])
    |> KejaDigital.Repo.insert()
  end
end
