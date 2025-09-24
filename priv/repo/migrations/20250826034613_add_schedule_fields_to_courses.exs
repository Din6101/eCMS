defmodule ECMS.Repo.Migrations.AddScheduleFieldsToCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :start_date, :date
      add :end_date, :date
      add :venue, :string
    end
  end
end
