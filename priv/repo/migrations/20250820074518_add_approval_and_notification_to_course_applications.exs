defmodule ECMS.Repo.Migrations.AddApprovalAndNotificationToCourseApplications do
  use Ecto.Migration

  def change do
    alter table(:course_applications) do
      add :approval, :boolean, default: false
      add :notification, :string
    end
  end
end
