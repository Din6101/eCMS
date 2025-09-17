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

  @doc """
  Generate a enrollment.
  """
  def enrollment_fixture(attrs \\ %{}) do
    {:ok, enrollment} =
      attrs
      |> Enum.into(%{
        course_id: "some course_id",
        milestone: %{},
        progress: 42,
        status: "some status",
        user_id: "some user_id"
      })
      |> ECMS.Training.create_enrollment()

    enrollment
  end

  @doc """
  Generate a live_event.
  """
  def live_event_fixture(attrs \\ %{}) do
    {:ok, live_event} =
      attrs
      |> Enum.into(%{
        live: true,
        presenter: "some presenter",
        title: "some title"
      })
      |> ECMS.Training.create_live_event()

    live_event
  end

  @doc """
  Generate a activities.
  """
  def activities_fixture(attrs \\ %{}) do
    {:ok, activities} =
      attrs
      |> Enum.into(%{
        date: ~D[2025-09-15],
        description: "some description",
        time: ~T[14:00:00]
      })
      |> ECMS.Training.create_activities()

    activities
  end
end
