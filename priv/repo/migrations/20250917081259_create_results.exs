defmodule ECMS.Repo.Migrations.CreateResults do
  use Ecto.Migration

  def change do
    create table(:results) do
      add :final_score, :integer
      add :status, :string
      add :certification, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:results, [:user_id])
    create index(:results, [:course_id])
  end
end
