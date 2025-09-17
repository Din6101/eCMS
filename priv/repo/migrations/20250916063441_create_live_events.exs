defmodule ECMS.Repo.Migrations.CreateLiveEvents do
  use Ecto.Migration

  def change do
    create table(:live_events) do
      add :title, :string
      add :live, :boolean, default: false, null: false
      add :presenter, :string

      timestamps(type: :utc_datetime)
    end
  end
end
