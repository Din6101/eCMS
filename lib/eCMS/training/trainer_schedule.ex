defmodule ECMS.Training.TrainerSchedule do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trainer_schedules" do
    field :status, :string
    field :notes, :string

    belongs_to :schedule, ECMS.Training.Schedule
    belongs_to :trainer, ECMS.Accounts.User


    timestamps(type: :utc_datetime)
  end

  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:status, :notes, :schedule_id, :trainer_id])
    |> validate_required([:status, :schedule_id, :trainer_id])
    |> validate_inclusion(:status, ["assigned", "invited", "confirmed", "declined", "completed"])
    |> assoc_constraint(:schedule)
    |> assoc_constraint(:trainer)
  end
end
