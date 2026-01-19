defmodule ECMS.Training.Schedule do
  use Ecto.Schema
  import Ecto.Changeset

  schema "schedules" do
    field :status, Ecto.Enum,
      values: [:assigned, :invited, :confirmed, :declined, :completed],
      default: :assigned

    field :notes, :string
    field :venue, :string
    field :schedule_date, :date
    field :schedule_time, :time
    field :duration, :integer, default: 60

    belongs_to :course, ECMS.Courses.Course
    belongs_to :trainer, ECMS.Accounts.User

    has_many :trainer_schedules, ECMS.Training.TrainerSchedule

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [
      :status,
      :notes,
      :venue,
      :schedule_date,
      :schedule_time,
      :duration,
      :course_id,
      :trainer_id
    ])
    |> validate_required([:status, :schedule_date, :schedule_time, :course_id, :trainer_id])
    |> validate_number(:duration, greater_than: 0)
    |> assoc_constraint(:course)
    |> assoc_constraint(:trainer)
  end
end
