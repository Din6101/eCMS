defmodule ECMS.Repo.Migrations.AddScheduleFieldsToSchedules do
  use Ecto.Migration

  def change do
    alter table(:schedules) do
      add :schedule_date, :date
      add :schedule_time, :time
      add :duration, :integer, default: 60
      add :venue, :string
    end
  end
end
