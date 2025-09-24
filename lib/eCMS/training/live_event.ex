defmodule ECMS.Training.LiveEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "live_events" do
    field :title, :string
    field :live, :boolean, default: false
    field :presenter, :string

    field :video_url, :string
    field :platform, :string, default: "facebook"


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(live_event, attrs) do
    live_event

    |> cast(attrs, [:title, :live, :presenter, :video_url, :platform])
    |> validate_required([:title, :live, :presenter])
    |> validate_inclusion(:platform, ["facebook", "tiktok", "youtube", "instagram"])
    |> validate_format(:video_url, ~r/^https?:\/\//, message: "must be a valid URL")
=======
    |> cast(attrs, [:title, :live, :presenter])
    |> validate_required([:title, :live, :presenter])

  end
end
