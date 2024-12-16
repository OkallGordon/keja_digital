defmodule KejaDigitalWeb.TenantAgreementLive.Index do
  use KejaDigitalWeb, :live_view

  alias KejaDigital.Agreements
  alias KejaDigital.Agreements.TenantAgreementLive

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tenant_agreement_live, Agreements.list_tenant_agreements())}
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
