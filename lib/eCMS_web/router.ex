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

  scope "/", ECMSWeb do
    pipe_through [:browser]

    get "/", PageController, :home
    get "/landing", PageController, :landing
    get "/home", PageController, :classic_home


  end

  scope "/admin", ECMSWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live_session :admin,
      on_mount: [{ECMSWeb.UserAuth, :mount_current_user}, {ECMSWeb.UserAuth, :ensure_authenticated}],
      layout: {ECMSWeb.Layouts, :admin} do   # 👈 force admin layout here

      live "/courses", CourseLive.Index, :index
      live "/courses/new", CourseLive.Index, :new
      live "/courses/:id/edit", CourseLive.Index, :edit

      live "/courses/:id", CourseLive.Show, :show
      live "/courses/:id/show/edit", CourseLive.Show, :edit

      live "/dashboard_admin", DashboardAdmin, :index
      live "/course_application", CourseApplicationLive.Index, :index
      live "/notifications", AdminNotificationsLive.Index, :index

      live "/schedules", ScheduleLive.Index, :index
      live "/schedules/new", ScheduleLive.Index, :new
      live "/schedules/:id/edit", ScheduleLive.Index, :edit

      live "/schedules/:id", ScheduleLive.Show, :show
      live "/schedules/:id/show/edit", ScheduleLive.Show, :edit

      live "/live_events", LiveEventLive.Index, :index
      live "/live_events/new", LiveEventLive.Index, :new
      live "/live_events/:id/edit", LiveEventLive.Index, :edit
      live "/live_events/:id", LiveEventLive.Show, :show
      live "/live_events/:id/show/edit", LiveEventLive.Show, :edit

      live "/activity", ActivitiesLive.Index, :index
      live "/activity/new", ActivitiesLive.Index, :new
      live "/activity/:id/edit", ActivitiesLive.Index, :edit

      live "/activity/:id", ActivitiesLive.Show, :show
      live "/activity/:id/show/edit", ActivitiesLive.Show, :edit


      # Certifications (admin)

      live "/certifications", CertificationLive.Index, :index
      live "/certifications/new", CertificationLive.Index, :new
      live "/certifications/:id/edit", CertificationLive.Index, :edit

      live "/certifications/:id", CertificationLive.Show, :show
      live "/certifications/:id/show/edit", CertificationLive.Show, :edit



      live "/admin_result", AdminResult.Index, :index
      live "/admin_feedback", AdminFeedback.Index, :index

    end
  end

  scope "/trainer", ECMSWeb do
    pipe_through [:browser, :require_authenticated_user, :require_trainer]

    live_session :trainer,
      on_mount: [{ECMSWeb.UserAuth, :mount_current_user}, {ECMSWeb.UserAuth, :ensure_authenticated}],
      layout: {ECMSWeb.Layouts, :trainer} do
      live "/dashboard_trainer", DashboardTrainer, :index
      live "/trainer_schedule", TrainerScheduleLive.Index, :index

      live "/enrollments", EnrollmentLive.Index, :index
      live "/enrollments/new", EnrollmentLive.Index, :new
      live "/enrollments/:id/edit", EnrollmentLive.Index, :edit

      live "/enrollments/:id", EnrollmentLive.Show, :show
      live "/enrollments/:id/show/edit", EnrollmentLive.Show, :edit

      live "/results", ResultLive.Index, :index
      live "/results/new", ResultLive.Index, :new
      live "/results/:id/edit", ResultLive.Index, :edit

      live "/results/:id", ResultLive.Show, :show
      live "/results/:id/show/edit", ResultLive.Show, :edit

      live "/feedback", FeedbackLive.Index, :index
      live "/feedback/new", FeedbackLive.Index, :new
      live "/feedback/:id/edit", FeedbackLive.Index, :edit

      live "/feedback/:id", FeedbackLive.Show, :show
      live "/feedback/:id/show/edit", FeedbackLive.Show, :edit

    end
  end

  scope "/student", ECMSWeb do
    pipe_through [:browser, :require_authenticated_user, :require_student]

    live_session :student,
      on_mount: [{ECMSWeb.UserAuth, :ensure_authenticated}],
      layout: {ECMSWeb.Layouts, :student} do

    live "/dashboard_student", DashboardStudent, :index
    live "/course_live/student_course", CourseLive.StudentCourse, :index
    live "/student_notifications", StudentNotifications.Index, :index
    live "/student_results", StudentResults.Index, :index
    live "/student_certification", StudentCertification.Index, :index


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
      live "/users/profile", UserProfileLive, :index
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
