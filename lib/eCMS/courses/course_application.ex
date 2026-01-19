
defmodule ECMS.Courses.CourseApplication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "course_applications" do
    belongs_to :course, ECMS.Courses.Course
    belongs_to :user, ECMS.Accounts.User
    has_many :student_notifications, ECMS.Notifications.StudentNotifications
    has_many :admin_notifications, ECMS.Notifications.AdminNotifications

    field :status, Ecto.Enum, values: [:pending, :approved, :rejected], default: :pending
    field :approval, Ecto.Enum, values: [:unapproved, :approved], default: :unapproved
    field :notification, Ecto.Enum, values: [:unsent, :sent], default: :unsent

    timestamps(type: :utc_datetime)
  end

  def changeset(application, attrs) do
    application
    |> cast(attrs, [:course_id, :user_id, :status, :approval, :notification])

    |> validate_required([:course_id, :user_id])
    |> put_change(:status, :pending)
    |> put_change(:approval, :unapproved)
    |> put_change(:notification, :unsent)
    |> unique_constraint([:course_id, :user_id], message: "You have already applied to this course")
  end

  def status_changeset(application, attrs) do
    application
    |> cast(attrs, [:status, :approval, :notification])
    |> validate_required([:status])

    |> validate_required([:course_id, :user_id, :status, :approval, :notification])
    |> unique_constraint([:course_id, :user_id, :status, :approval, :notification])

  end
end
