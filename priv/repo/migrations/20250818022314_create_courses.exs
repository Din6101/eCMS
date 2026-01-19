defmodule ECMS.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :course_id, :string
      add :title, :string
      add :description, :text

      timestamps(type: :utc_datetime)
    end
  end
end
