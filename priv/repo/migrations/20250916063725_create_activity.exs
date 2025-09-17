defmodule ECMS.Repo.Migrations.CreateActivity do
  use Ecto.Migration

  def change do
    create table(:activity) do
      add :description, :string
      add :date, :date
      add :time, :time

      timestamps(type: :utc_datetime)
    end
  end
end
