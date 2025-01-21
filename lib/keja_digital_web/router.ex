defmodule KejaDigitalWeb.Router do
  #alias KejaDigitalWeb.AdminDashboardLive
  use KejaDigitalWeb, :router

  import KejaDigitalWeb.AdminAuth

  import KejaDigitalWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KejaDigitalWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KejaDigitalWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/properties/active", PropertiesLive.Active
    live "/properties/saved", PropertiesLive.Saved
    live "/messages", MessagesLive.Index
  end

  scope "/api", KejaDigitalWeb do
    pipe_through :api
    post "/mpesa/callback", MpesaWebhookController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", KejaDigitalWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:keja_digital, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KejaDigitalWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes for tenants

  scope "/", KejaDigitalWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{KejaDigitalWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", KejaDigitalWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{KejaDigitalWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email


      live "/tenant/profile", UserProfileLive
      live "/tenant_agreements", TenantAgreementLive.Index, :index
      live "/tenant_agreements/new", TenantAgreementLive.Index, :new
      live "/tenant_agreements/:id/edit", TenantAgreementLive.Index, :edit
      live "/tenant_agreements/:id", TenantShow, :show
      live "/tenant_agreements/:id/show/edit", TenantAgreementLive.Show, :edit
      live "/tenant_agreement_status/:tenant_id", TenantAgreementLive

      live "/tenant/reminders", UserPaymentLive
      live "/tenant/payments", MpesaPaymentLive
      live "/tenant/dashboard", Tenant.DashboardLive, :index
      live "/analytics/views", AnalyticsLive.Views
      live "/properties", PropertiesLive

    end
  end

  scope "/", KejaDigitalWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{KejaDigitalWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  ## Authentication routes for admins

  scope "/", KejaDigitalWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]

    live_session :redirect_if_admin_is_authenticated,
      on_mount: [{KejaDigitalWeb.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/admins/register", AdminRegistrationLive, :new
      live "/admins/log_in", AdminLoginLive, :new
      live "/admins/reset_password", AdminForgotPasswordLive, :new
      live "/admins/reset_password/:token", AdminResetPasswordLive, :edit
    end

    post "/admins/log_in", AdminSessionController, :create
  end

  scope "/", KejaDigitalWeb do
    pipe_through [:browser, :require_authenticated_admin]

    live_session :require_authenticated_admin,
      on_mount: [{KejaDigitalWeb.AdminAuth, :ensure_authenticated}] do

      live "/admins/settings", AdminSettingsLive, :edit
      live "/admins/settings/confirm_email/:token", AdminSettingsLive, :confirm_email

      live "/notifications", NotificationsLive, :show
      live "/agreement/status", AgreementStatusLive
      live "/tenant_agreement/:id", AdminShow, :show
      live "/agreements", AdminReviewLive
      live "/agreements/:id", AgreementDetailLive
      live "/dashboard", AdminDashboardLive
      live "/dashboard/audit_logs", Admin.AuditLogsLive, as: :audit_logs


      live "/payments/:tenant_id", PaymentLive
    end
  end

  scope "/", KejaDigitalWeb do
    pipe_through [:browser]

    delete "/admins/log_out", AdminSessionController, :delete

    live_session :current_admin,
      on_mount: [{KejaDigitalWeb.AdminAuth, :mount_current_admin}] do
      live "/admins/confirm/:token", AdminConfirmationLive, :edit
      live "/admins/confirm", AdminConfirmationInstructionsLive, :new
    end
  end
end
