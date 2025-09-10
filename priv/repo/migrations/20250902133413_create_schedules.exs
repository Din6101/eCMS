defmodule ECMS.Repo.Migrations.CreateSchedules do
  use Ecto.Migration

  def change do
    create table(:schedules) do
      add :status, :string
      add :notes, :text
      add :course_id, references(:courses, on_delete: :nothing)
      add :trainer_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:schedules, [:course_id])
    create index(:schedules, [:trainer_id])

    create constraint(:schedules, :status_must_be_valid,
      check: "status IN ('pending','completed','cancelled')"
    )
  end
end
