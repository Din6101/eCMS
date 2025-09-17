defmodule ECMS.Repo.Migrations.FixEnrollmentsForeignKeys do
  use Ecto.Migration

  def change do
    # Remove old columns if they exist
    alter table(:enrollments) do
      remove :user_id
      remove :course_id
    end

    # Add proper foreign key columns as integers
    alter table(:enrollments) do
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :course_id, references(:courses, on_delete: :nothing), null: false
    end

    # Optional: add unique index to prevent duplicate enrollments
    create unique_index(:enrollments, [:user_id, :course_id])
  end
end
