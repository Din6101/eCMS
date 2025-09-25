defmodule ECMSWeb.TrainerScheduleLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    schedules = Training.list_schedules_by_trainer(current_user.id)

    {:ok, stream(socket, :trainer_schedules, schedules)}
  end

  @impl true
  def handle_event("accept_schedule", %{"id" => id}, socket) do
    schedule = Training.get_schedule!(id)

    case Training.update_schedule_status(schedule, :confirmed) do
      {:ok, _updated_schedule} ->
        current_user = socket.assigns.current_user
        schedules = Training.list_schedules_by_trainer(current_user.id)

        {:noreply,
         socket
         |> stream(:trainer_schedules, schedules, reset: true)
         |> put_flash(:info, "Schedule accepted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to accept schedule. Please try again.")}
    end
  end

  @impl true
  def handle_event("decline_schedule", %{"id" => id}, socket) do
    schedule = Training.get_schedule!(id)

    case Training.update_schedule_status(schedule, :decline) do
      {:ok, _updated_schedule} ->
        current_user = socket.assigns.current_user
        schedules = Training.list_schedules_by_trainer(current_user.id)

        {:noreply,
         socket
         |> stream(:trainer_schedules, schedules, reset: true)
         |> put_flash(:info, "Schedule declined.")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to decline schedule. Please try again.")}
    end
  end

  defp get_status_description(status) do
    case status do
      :assigned -> "Has been assigned to trainer but no acceptance yet"
      :invited -> "Trainer has been invited and is reviewing the schedule"
      :confirmed -> "Trainer has accepted and confirmed the schedule"
      :completed -> "The scheduled course has been completed"
      :decline -> "Trainer has declined this schedule"
      _ -> "Unknown status"
    end
  end
end
