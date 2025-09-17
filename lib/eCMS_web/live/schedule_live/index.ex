defmodule ECMSWeb.ScheduleLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.Schedule

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :course_schedules, Training.list_schedules())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Course Schedule")
    |> assign(:course_schedule, Training.get_schedule!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Course Schedule")
    |> assign(:schedule, %Schedule{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Course Schedules")
    |> assign(:course_schedule, nil)
  end

  @impl true
  def handle_info({ECMSWeb.ScheduleLive.FormComponent, {:saved, schedule}}, socket) do
    {:noreply, stream_insert(socket, :schedules, schedule)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    schedule = Training.get_schedule!(id)
    {:ok, _} = Training.delete_schedule(schedule)

    {:noreply, stream_delete(socket, :schedules, schedule)}
  end

end
