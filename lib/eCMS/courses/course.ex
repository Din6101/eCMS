defmodule ECMS.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :description, :string
    field :title, :string
    field :course_id, :string
    field :start_date, :date
    field :end_date, :date
    field :venue, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:course_id, :title, :description, :start_date, :end_date, :venue])
    |> validate_required([:course_id, :title, :description, :start_date, :end_date, :venue])
  end
end
