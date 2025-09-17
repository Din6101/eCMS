defmodule ECMSWeb.ScheduleLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.Schedule

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :course_schedules, Training.list_course_schedules())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Course Schedule")
    |> assign(:course_schedule, Training.get_course_schedule!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Course Schedule")
    |> assign(:course_schedule, %CourseSchedule{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Course Schedules")
    |> assign(:course_schedule, nil)
  end

  @impl true
  def handle_info({ECMSWeb.CourseScheduleLive.FormComponent, {:saved, course_schedule}}, socket) do
    {:noreply, stream_insert(socket, :course_schedules, course_schedule)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course_schedule = Training.get_course_schedule!(id)
    {:ok, _} = Training.delete_course_schedule(course_schedule)

    {:noreply, stream_delete(socket, :course_schedules, course_schedule)}
  end

end
