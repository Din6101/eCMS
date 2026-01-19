defmodule ECMS.Repo.Migrations.AddCourseIdToStudentNotifications do
  use Ecto.Migration

  def change do
    alter table(:student_notifications) do
      add :course_id, references(:courses, on_delete: :delete_all)
    end

    create index(:student_notifications, [:course_id])
  end
end
