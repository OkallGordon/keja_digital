defmodule KejaDigitalWeb.TenantAgreementLive.FormComponent do
  use KejaDigitalWeb, :live_component

  alias KejaDigital.Agreements

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage tenant_agreement_live records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="tenant_agreement_live-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <:actions>
          <.button phx-disable-with="Saving...">Save Tenant agreement live</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{tenant_agreement_live: tenant_agreement_live} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Agreements.change_tenant_agreement_live(tenant_agreement_live))
     end)}
  end

  @impl true
  def handle_event("validate", %{"tenant_agreement_live" => tenant_agreement_live_params}, socket) do
    changeset = Agreements.change_tenant_agreement_live(socket.assigns.tenant_agreement_live, tenant_agreement_live_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"tenant_agreement_live" => tenant_agreement_live_params}, socket) do
    save_tenant_agreement_live(socket, socket.assigns.action, tenant_agreement_live_params)
  end

  defp save_tenant_agreement_live(socket, :edit, tenant_agreement_live_params) do
    case Agreements.update_tenant_agreement_live(socket.assigns.tenant_agreement_live, tenant_agreement_live_params) do
      {:ok, tenant_agreement_live} ->
        notify_parent({:saved, tenant_agreement_live})

        {:noreply,
         socket
         |> put_flash(:info, "Tenant agreement live updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_tenant_agreement_live(socket, :new, tenant_agreement_live_params) do
    case Agreements.create_tenant_agreement_live(tenant_agreement_live_params) do
      {:ok, tenant_agreement_live} ->
        notify_parent({:saved, tenant_agreement_live})

        {:noreply,
         socket
         |> put_flash(:info, "Tenant agreement live created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
