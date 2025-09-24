defmodule ECMS.Training.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feedback" do
    field :feedback, :string
    field :remarks, :string
    field :need_support, :boolean, default: false

    belongs_to :student, ECMS.Accounts.User, foreign_key: :student_id
    belongs_to :course, ECMS.Courses.Course, foreign_key: :course_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(feedback, attrs) do
    feedback
    |> cast(attrs, [:student_id, :course_id, :feedback, :remarks, :need_support])
    |> validate_required([:student_id, :course_id, :feedback])
    |> assoc_constraint(:student)
    |> assoc_constraint(:course)
  end
end
