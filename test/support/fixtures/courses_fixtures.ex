defmodule ECMS.CoursesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ECMS.Courses` context.
  """

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    {:ok, course} =
      attrs
      |> Enum.into(%{
        course_id: "some course_id",
        description: "some description",
        title: "some title"
      })
      |> ECMS.Courses.create_course()

    course
  end
end
