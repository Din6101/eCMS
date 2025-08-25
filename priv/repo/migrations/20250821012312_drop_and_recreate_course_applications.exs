defmodule ECMS.Repo.Migrations.DropAndRecreateCourseApplications do
  use Ecto.Migration

  def change do
    drop_if_exists table(:course_applications)

    create table(:course_applications) do
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      add :status, :string, null: false, default: "pending"
      add :approval, :string, null: false, default: "unapproved"
      add :notification, :string, null: false, default: "unsent"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:course_applications, [:course_id, :user_id])
  end
end
