defmodule ECMS.Repo.Migrations.AddQoutaToCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :qouta, :integer
    end
  end
end
