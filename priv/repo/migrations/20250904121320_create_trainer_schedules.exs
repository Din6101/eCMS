defmodule ECMS.Repo.Migrations.CreateTrainerSchedules do
  use Ecto.Migration

  def change do
    create table(:trainer_schedules) do
      add :schedule_id, references(:schedules, on_delete: :delete_all), null: false
      add :trainer_id, references(:users, on_delete: :delete_all), null: false
      add :status, :string, default: "pending"
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:trainer_schedules, [:schedule_id])
    create index(:trainer_schedules, [:trainer_id])
  end
end
