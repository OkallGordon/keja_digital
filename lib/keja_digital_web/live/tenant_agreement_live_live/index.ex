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

        # Assign the tenancy agreements to the socket
        socket = assign(socket, :tenant_agreement_live, tenant_agreement_live)
        socket = assign(socket, :current_user, user)

        # Initialize stream for tenancy agreements
        socket = socket |> stream(:tenant_agreement_live, tenant_agreement_live)

        # Check if there is any tenancy agreement and if it has been submitted
        can_edit = case tenant_agreement_live do
          [] -> true  # No agreement, so can edit (create new)
          [agreement] ->
            if agreement.submitted do
              false  # Agreement is already submitted, cannot edit
            else
              true  # Agreement exists but not submitted, can edit
            end
        end

        # Return socket with the correct page title and editing permissions
        {:ok, socket |> assign(:can_edit, can_edit) |> assign(:page_title, if(can_edit, do: "New Tenancy Agreement", else: "View Tenancy Agreement"))}

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
    |> assign(:page_title, "Edit Tenant agreement live")
    |> assign(:tenant_agreement_live, Agreements.get_tenant_agreement_live!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Tenant agreement live")
    |> assign(:tenant_agreement_live, %TenantAgreementLive{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Tenant agreements")
    |> assign(:tenant_agreement_live, nil)
  end

  @impl true
  def handle_info({KejaDigitalWeb.TenantAgreementLive.FormComponent, {:saved, tenant_agreement_live}}, socket) do
    {:noreply, stream_insert(socket, :tenant_agreements, tenant_agreement_live)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    tenant_agreement_live = Agreements.get_tenant_agreement_live!(id)
    {:ok, _} = Agreements.delete_tenant_agreement_live(tenant_agreement_live)

    {:noreply, stream_delete(socket, :tenant_agreements, tenant_agreement_live)}
  end
end
