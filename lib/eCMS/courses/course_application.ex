
defmodule ECMS.Courses.CourseApplication do
  use Ecto.Schema
  import Ecto.Changeset

  schema "course_applications" do
    belongs_to :course, ECMS.Courses.Course
    belongs_to :user, ECMS.Accounts.User

    field :status, Ecto.Enum, values: [:pending, :approved, :rejected], default: :pending
    field :approval, Ecto.Enum, values: [:unapproved, :approved], default: :unapproved
    field :notification, Ecto.Enum, values: [:unsent, :sent], default: :unsent

    timestamps(type: :utc_datetime)
  end

  def changeset(application, attrs) do
    application
    |> cast(attrs, [:course_id, :user_id, :status, :approval, :notification])
    |> validate_required([:course_id, :user_id, :status, :approval, :notification])
    |> unique_constraint([:course_id, :user_id, :status, :approval, :notification])
  end
end
