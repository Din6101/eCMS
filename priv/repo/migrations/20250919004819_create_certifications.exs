defmodule ECMS.Repo.Migrations.CreateCertifications do
  use Ecto.Migration

  def change do
    create table(:certifications) do
      add :certificate_url, :string
      add :issued_at, :utc_datetime
      add :student_id, references(:users, on_delete: :nothing)
      add :course_id, references(:courses, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:certifications, [:student_id])
    create index(:certifications, [:course_id])
  end
end
