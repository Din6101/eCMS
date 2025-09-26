defmodule ECMSWeb.ScheduleLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.Schedule
  alias ECMS.Email

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
    |> assign(:schedule, Training.get_schedule!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Course Schedule")
    |> assign(:schedule, %Schedule{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Course Schedules")
    |> assign(:schedule, nil)
  end

  @impl true
  def handle_info({ECMSWeb.ScheduleLive.FormComponent, {:saved, schedule}}, socket) do
    schedule = ECMS.Repo.preload(schedule, [:course, :trainer])
    {:noreply, stream_insert(socket, :course_schedules, schedule)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    schedule = Training.get_schedule!(id)
    {:ok, _} = Training.delete_schedule(schedule)

    {:noreply, stream_delete(socket, :course_schedules, schedule)}
  end

  @impl true
  def handle_event("send_notification", %{"id" => id}, socket) do
    schedule = Training.get_schedule!(id)

    case Email.send_schedule_notification(schedule) do
      {:ok, _resp} ->
        {:noreply, put_flash(socket, :info, "Email notification sent.")}
      {:error, :missing_recipient} ->
        {:noreply, put_flash(socket, :error, "Trainer email is missing.")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Failed to send email: #{inspect(reason)}")}
    end
  end

end
