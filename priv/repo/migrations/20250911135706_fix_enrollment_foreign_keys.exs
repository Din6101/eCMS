defmodule ECMS.Repo.Migrations.FixEnrollmentForeignKeys do
  use Ecto.Migration

  def change do
    alter table(:enrollments) do
      remove :user_id
      remove :course_id
    end

    alter table(:enrollments) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :course_id, references(:courses, on_delete: :nothing), null: false
    end
  end

  def down do
    alter table(:enrollments) do
      remove :user_id
      remove :course_id

      add :user_id, :string
      add :course_id, :string
    end
  end
end
