defmodule ECMSWeb.Router do
  use ECMSWeb, :router

  import ECMSWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ECMSWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end


  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/admin", ECMSWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live_session :admin,
      on_mount: [{ECMSWeb.UserAuth, :ensure_authenticated}],
      layout: {ECMSWeb.Layouts, :admin} do   # 👈 force admin layout here

      live "/courses", CourseLive.Index, :index
      live "/courses/new", CourseLive.Index, :new
      live "/courses/:id/edit", CourseLive.Index, :edit

      live "/courses/:id", CourseLive.Show, :show
      live "/courses/:id/show/edit", CourseLive.Show, :edit

      live "/dashboard_admin", DashboardAdmin, :index
      live "/course_application", CourseApplicationLive.Index, :index
    end
  end

  scope "/", ECMSWeb do



    pipe_through [:browser, :require_authenticated_user, :require_student]

    get "/", PageController, :home

    live_session :student,
      on_mount: [{ECMSWeb.UserAuth, :ensure_authenticated}],
      layout: {ECMSWeb.Layouts, :student} do

    live "/dashboard_student", DashboardStudent, :index
    live "/course_live/student_course", CourseLive.StudentCourse, :index

    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ECMSWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:eCMS, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ECMSWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ECMSWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ECMSWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ECMSWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ECMSWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", ECMSWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ECMSWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
