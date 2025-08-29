defmodule ECMS.Repo.Migrations.CreateAdminNotifications do
  use Ecto.Migration

  def change do
    create table(:admin_notifications) do
      add :message, :string
      add :read, :boolean, default: false, null: false
      add :sent_at, :naive_datetime
      add :user_id, references(:users, on_delete: :nothing)
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:admin_notifications, [:user_id])
    create index(:admin_notifications, [:course_id])
  end
end
