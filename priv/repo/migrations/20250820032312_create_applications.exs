defmodule ECMS.Repo.Migrations.CreateCourseApplications do
  use Ecto.Migration

  def change do
      create table(:course_applications) do
        add :status, :string, default: "pending"
        add :approval, :string, default: "unapproved"
        add :notification, :string, default: "unsent"

        add :course_id, references(:courses, on_delete: :delete_all)
        add :user_id, references(:users, on_delete: :delete_all)

        timestamps(type: :utc_datetime)
      end

      create index(:course_applications, [:course_id])
      create index(:course_applications, [:user_id])
      create unique_index(:course_applications, [:course_id, :user_id])
  end
end
