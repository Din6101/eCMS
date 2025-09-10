defmodule ECMS.Repo.Migrations.UpdateScheduleStatusConstraint do
  use Ecto.Migration

  def change do
    drop constraint(:schedules, :status_must_be_valid)

    create constraint(:schedules, :status_must_be_valid,
      check: "status IN ('assigned', 'invited', 'confirmed', 'declined', 'completed')"
    )
  end
end
