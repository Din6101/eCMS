defmodule ECMS.Training.Schedule do
  use Ecto.Schema
  import Ecto.Changeset

  schema "schedules" do
    field :status, :string
    field :notes, :string
    belongs_to :course, ECMS.Courses.Course
    belongs_to :trainer, ECMS.Accounts.User

    has_many :trainer_schedules, ECMS.Training.TrainerSchedule

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:status, :notes, :course_id, :trainer_id])
    |> validate_required([:status, :notes, :course_id, :trainer_id])
    |> validate_inclusion(:status, ["assigned", "invited", "confirmed", "declined", "completed"])
    |> assoc_constraint(:course)
    |> assoc_constraint(:trainer)
  end
end
