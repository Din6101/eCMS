defmodule ECMS.Repo.Migrations.AddIcNumberToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :ic_number, :string
    end
  end
end
