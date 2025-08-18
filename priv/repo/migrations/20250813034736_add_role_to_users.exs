defmodule ECMS.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :role
    end
  end
end
