defmodule ECMS.Repo.Migrations.AddLinksToNotifications do
  use Ecto.Migration

  def change do
    alter table(:admin_notifications) do
      add :course_application_id, references(:course_applications, on_delete: :delete_all)
    end

    alter table(:student_notifications) do
      add :admin_notification_id, references(:admin_notifications, on_delete: :delete_all)
    end

    create_if_not_exists index(:admin_notifications, [:course_application_id])
    create_if_not_exists index(:student_notifications, [:course_application_id])
  end
end
