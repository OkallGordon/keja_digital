defmodule KejaDigitalWeb.TenantAgreementLive.Index do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Agreements
  alias KejaDigital.Agreements.TenantAgreementLive
  alias KejaDigital.Store
  alias KejaDigital.Store.User

  @impl true
  def mount(_params, %{"user_token" => user_token}, socket) do
    case Store.get_user_by_session_token(user_token) do
      %User{} = user ->
        # Fetch the tenancy agreement for the current user
        tenant_agreement_live = Agreements.list_tenant_agreements_for_user(user.id)

        socket =
          socket
          |> assign(:current_user, user)
          |> stream(:tenant_agreement_live, tenant_agreement_live)
          |> assign_can_edit(tenant_agreement_live)

        {:ok, socket}

      nil ->
        {:ok, push_navigate(socket, to: "/login")}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Tenant Agreement")
    |> assign(:tenant_agreement_live, Agreements.get_tenant_agreement_live!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tenant Agreement")
    |> assign(:tenant_agreement_live, %TenantAgreementLive{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tenant Agreements")
    |> assign(:tenant_agreement_live, nil)
  end

  @impl true
  def handle_info({KejaDigitalWeb.TenantAgreementLive.FormComponent, {:saved, tenant_agreement_live}}, socket) do
    {:noreply, stream_insert(socket, :tenant_agreement_live, tenant_agreement_live)}
  end

  @impl true
  def handle_info(:update_stats, socket) do
    # Handle the update_stats message
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant_agreement_live = Agreements.get_tenant_agreement_live!(id)
    {:ok, _} = Agreements.delete_tenant_agreement_live(tenant_agreement_live)

    {:noreply, stream_delete(socket, :tenant_agreement_live, tenant_agreement_live)}
  end

  # Private helper functions
  defp assign_can_edit(socket, tenant_agreement_live) do
    can_edit = case tenant_agreement_live do
      [] -> true  # No agreement, so can edit (create new)
      [agreement] ->
        not agreement.submitted  # Can edit if not submitted
    end

    socket
    |> assign(:can_edit, can_edit)
    |> assign(:page_title, if(can_edit, do: "New Tenancy Agreement", else: "View Tenancy Agreement"))
  end
end
