defmodule ECMS.Training.Activities do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activity" do
    field :date, :date
    field :time, :time
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(activities, attrs) do
    activities
    |> cast(attrs, [:description, :date, :time])
    |> validate_required([:description, :date, :time])
  end
end
