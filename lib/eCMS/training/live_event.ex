defmodule ECMS.Training.LiveEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "live_events" do
    field :title, :string
    field :live, :boolean, default: false
    field :presenter, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(live_event, attrs) do
    live_event
    |> cast(attrs, [:title, :live, :presenter])
    |> validate_required([:title, :live, :presenter])
  end
end
