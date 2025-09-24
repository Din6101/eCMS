defmodule ECMS.Repo.Migrations.AddVideoFieldsToLiveEvents do
  use Ecto.Migration

  def change do
    alter table(:live_events) do
      add :video_url, :string
      add :platform, :string, default: "facebook"
    end
  end
end
