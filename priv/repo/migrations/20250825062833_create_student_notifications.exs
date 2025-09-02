defmodule ECMS.Repo.Migrations.CreateStudentNotifications do
  use Ecto.Migration

  def change do
    create table(:student_notifications) do
      add :message, :text
      add :start_date, :date
      add :end_date, :date
      add :venue, :string
      add :read, :boolean, default: false

      add :student_id, references(:users, on_delete: :delete_all)
      add :course_application_id, references(:course_applications, on_delete: :delete_all)


      timestamps()
    end

    create index(:student_notifications, [:student_id])
    create index(:student_notifications, [:course_application_id])
  end
end
