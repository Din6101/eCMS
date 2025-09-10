defmodule ECMS.TrainingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ECMS.Training` context.
  """

  @doc """
  Generate a schedule.
  """
  def schedule_fixture(attrs \\ %{}) do
    {:ok, schedule} =
      attrs
      |> Enum.into(%{
        notes: "some notes",
        status: "some status"
      })
      |> ECMS.Training.create_schedule()

    schedule
  end
end
