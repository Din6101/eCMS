defmodule ECMS.Repo.Migrations.CreateAttendances do
  use Ecto.Migration

  def change do
    create table(:attendances) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :course_id, references(:courses, on_delete: :nothing)
      add :scanned_at, :utc_datetime, null: false
      add :scanned_by, references(:users, on_delete: :nothing)
      add :status, :string, default: "present"

      timestamps(type: :utc_datetime)
    end

    create index(:attendances, [:user_id])
    create index(:attendances, [:course_id])
    create index(:attendances, [:scanned_at])
  end
end
