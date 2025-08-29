defmodule ECMS.Notifications.AdminNotifications do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admin_notifications" do
    field :message, :string
    field :read, :boolean, default: false
    field :sent_at, :naive_datetime

    belongs_to :user, ECMS.Accounts.User   # add association
    belongs_to :course, ECMS.Courses.Course  # add association
    belongs_to :course_application, ECMS.Courses.CourseApplication
    has_many :student_notifications, ECMS.Notifications.StudentNotifications,
      foreign_key: :admin_notification_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(admin_notifications, attrs) do
    admin_notifications
    |> cast(attrs, [:message, :read, :sent_at, :user_id, :course_id, :course_application_id])
    |> validate_required([:message, :read, :sent_at, :user_id, :course_id])
  end
end
