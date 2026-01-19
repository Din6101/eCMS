defmodule ECMS.Notifications.StudentNotifications do
  use Ecto.Schema
  import Ecto.Changeset

  schema "student_notifications" do
    field :message, :string
    field :start_date, :date
    field :end_date, :date
    field :venue, :string
    field :read, :boolean, default: false

    belongs_to :course, ECMS.Courses.Course
    belongs_to :course_application, ECMS.Courses.CourseApplication
    belongs_to :student, ECMS.Accounts.User
    belongs_to :admin_notification, ECMS.Notifications.AdminNotifications
    timestamps()
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:message, :start_date, :end_date, :venue, :read, :student_id, :course_id, :course_application_id, :admin_notification_id])
    |> validate_required([:message, :student_id, :course_id, :course_application_id])
  end
end
