defmodule ECMS.Repo.Migrations.CreateEnrollments do
  use Ecto.Migration

  def change do
    create table(:enrollments) do
      add :user_id, references(:users, on_delete: :nothing)
      add :course_id, references(:courses, on_delete: :nothing)
      add :status, :string
      add :progress, :integer
      add :milestone, :map

      timestamps(type: :utc_datetime)
    end
  end
end
