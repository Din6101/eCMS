defmodule ECMS.Repo.Migrations.AddProfileFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :phone, :string
      add :date_of_birth, :date
      add :address, :text
    end
  end
end
