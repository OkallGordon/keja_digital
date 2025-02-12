defmodule KejaDigital.Agreements do
  @moduledoc """
  The Agreements context.
  """
  import Ecto.Query, warn: false
  alias KejaDigital.Repo

  alias KejaDigital.Agreements.TenantAgreementLive
  alias KejaDigital.Backoffice
  alias KejaDigital.Notifications

   def get_tenant_agreement_status(tenant_id) do
    case Repo.get_by(Agreement, tenant_id: tenant_id) do
      nil -> {:error, "No agreement found for tenant"}
      agreement -> {:ok, agreement.status}
    end
  end
  @doc """
  Returns the list of tenant_agreements.

  ## Examples

      iex> list_tenant_agreements()
      [%TenantAgreementLive{}, ...]

  """
  def list_tenant_agreements do
    Repo.all(TenantAgreementLive)
  end

  def list_tenant_agreements_for_user(id) do
    Repo.all(from t in TenantAgreementLive, where: t.tenant_id == ^id)
  end

def list_pending_tenant_agreements do
  from(ta in TenantAgreementLive,
    where: ta.status == "pending_review",
    order_by: [desc: ta.inserted_at])
  |> Repo.all()
end

def list_tenant_agreements_by_status(statuses) when is_list(statuses) do
  from(t in TenantAgreementLive,
    where: t.status in ^statuses,
    order_by: [desc: t.inserted_at]
  )
  |> Repo.all()
end

def update_tenant_agreement_live(%TenantAgreementLive{} = agreement, attrs) do
  agreement
  |> TenantAgreementLive.changeset(attrs)
  |> Repo.update()
  |> broadcast_agreement_update()
end

defp broadcast_agreement_update({:ok, agreement} = result) do
  Phoenix.PubSub.broadcast(
    KejaDigital.PubSub,
    "tenant_agreements",
    {:agreement_updated, agreement}
  )
  result
end

defp broadcast_agreement_update(result), do: result
  @doc """
  Gets a single tenant_agreement_live.

  Raises `Ecto.NoResultsError` if the Tenant agreement live does not exist.

  ## Examples

      iex> get_tenant_agreement_live!(123)
      %TenantAgreementLive{}

      iex> get_tenant_agreement_live!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tenant_agreement_live!(id), do: Repo.get!(TenantAgreementLive, id)
  @doc """
  Creates a tenant_agreement_live.

  ## Examples

      iex> create_tenant_agreement_live(%{field: value})
      {:ok, %TenantAgreementLive{}}

      iex> create_tenant_agreement_live(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
def create_tenant_agreement_live(attrs) do
  tenant_name = Map.get(attrs, "tenant_name", "default_tenant")

  case Repo.get_by(TenantAgreementLive, tenant_name: tenant_name, submitted: true) do
    nil ->
      case %TenantAgreementLive{}
           |> TenantAgreementLive.changeset(attrs)
           |> Repo.insert() do
        {:ok, tenant_agreement} ->
          admins = Backoffice.list_admin_users()

          Enum.each(admins, fn admin ->
            Notifications.create_notification(%{
              title: "New Tenant Agreement Submitted",
              content: "A new tenant agreement has been submitted by #{tenant_agreement.tenant_name}",
              is_read: false,
              user_id: admin.id,
              tenant_agreement_id: tenant_agreement.id
            })
          end)

          Phoenix.PubSub.broadcast(
            KejaDigital.PubSub,
            "admin_notifications",
            {:new_tenant_agreement, tenant_agreement}
          )

          {:ok, tenant_agreement}

        {:error, changeset} ->
          {:error, changeset}
      end

    _existing_agreement ->
      # Duplicate agreement found; return an error
      {:error, :already_submitted}
  end
end

def get_tenant_agreement_by_name(tenant_name) do
  Repo.one(
    from t in TenantAgreementLive,
    where: t.tenant_name == ^tenant_name
  )
end

def get_tenant_agreement_by_tenant_id(tenant_id) do
  Repo.get_by(TenantAgreement, tenant_id: tenant_id)
end

def check_tenant_submission_status(tenant_name) do
  case get_tenant_agreement_by_name(tenant_name) do
    nil ->
      {:ok, :not_submitted}
    agreement ->
      {:ok, agreement.status}
  end
end

  @doc """
  Updates a tenant_agreement_live.

  ## Examples

      iex> update_tenant_agreement_live(tenant_agreement_live, %{field: new_value})
      {:ok, %TenantAgreementLive{}}

      iex> update_tenant_agreement_live(tenant_agreement_live, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

def update_tenant_agreement_status(id, status) do
  tenant_agreement = get_tenant_agreement_live!(id)

  tenant_agreement
  |> TenantAgreementLive.changeset(%{status: status})
  |> Repo.update()
  |> case do
    {:ok, updated_agreement} ->
      Phoenix.PubSub.broadcast(
        KejaDigital.PubSub,
        "admin_notifications",
        {:updated_tenant_agreement, updated_agreement}
      )

      Phoenix.PubSub.broadcast(
        KejaDigital.PubSub,
        "tenant_agreement:#{updated_agreement.tenant_id}",
        {:agreement_status_updated, updated_agreement}
      )

      {:ok, updated_agreement}
     error -> error
  end
end
  @doc """
  Deletes a tenant_agreement_live.

  ## Examples

      iex> delete_tenant_agreement_live(tenant_agreement_live)
      {:ok, %TenantAgreementLive{}}

      iex> delete_tenant_agreement_live(tenant_agreement_live)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tenant_agreement_live(%TenantAgreementLive{} = tenant_agreement_live) do
    Repo.delete(tenant_agreement_live)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tenant_agreement_live changes.

  ## Examples

      iex> change_tenant_agreement_live(tenant_agreement_live)
      %Ecto.Changeset{data: %TenantAgreementLive{}}

  """
  def change_tenant_agreement_live(%TenantAgreementLive{} = tenant_agreement_live, attrs \\ %{}) do
    TenantAgreementLive.changeset(tenant_agreement_live, attrs)
  end
end
