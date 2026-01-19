defmodule ECMS.Repo.Migrations.AddRoleBackToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, default: "student"
    end
  end
end
