defmodule KejaDigital.Agreements do
  @moduledoc """
  The Agreements context.
  """

  import Ecto.Query, warn: false
  alias KejaDigital.Repo

  alias KejaDigital.Agreements.TenantAgreementLive
  alias KejaDigital.Backoffice
  alias KejaDigital.Notifications

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
    Repo.all(from t in TenantAgreementLive, where: t.id == ^id)
  end

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
  # Insert the tenant agreement
  case %TenantAgreementLive{}
       |> TenantAgreementLive.changeset(attrs)
       |> Repo.insert() do
    {:ok, tenant_agreement} ->
      # Find all admin users
      admins = Backoffice.list_admin_users()

      # Create notifications for each admin
      Enum.each(admins, fn admin ->
        Notifications.create_notification(%{
          title: "New Tenant Agreement Submitted",
          content: "A new tenant agreement has been submitted by #{tenant_agreement.tenant_name}",
          is_read: false,
          user_id: admin.id,
          tenant_agreement_id: tenant_agreement.id
        })
      end)

      {:ok, tenant_agreement}

    {:error, changeset} ->
      {:error, changeset}
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
  def update_tenant_agreement_live(%TenantAgreementLive{} = tenant_agreement_live, attrs) do
    tenant_agreement_live
    |> TenantAgreementLive.changeset(attrs)
    |> Repo.update()
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
