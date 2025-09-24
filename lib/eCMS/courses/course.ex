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
    field :qouta, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:course_id, :title, :description, :start_date, :end_date, :venue, :qouta])
    |> validate_required([:course_id, :title, :description, :start_date, :end_date, :venue])
    |> validate_number(:qouta, greater_than: 0)
  end
end
