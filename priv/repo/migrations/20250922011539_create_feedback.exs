defmodule ECMS.Repo.Migrations.CreateFeedback do
  use Ecto.Migration

  def change do
    create table(:feedback) do
      add :student_id, references(:users, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :feedback, :text, null: false
      add :remarks, :text
      add :need_support, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:feedback, [:student_id])
    create index(:feedback, [:course_id])
    create unique_index(:feedback, [:student_id, :course_id])
  end
end
