defmodule ECMS.Repo.Migrations.RenameStudentIdToUserIdInCertifications do
  use Ecto.Migration

  def change do
    rename table(:certifications), :student_id, to: :user_id
  end
end
