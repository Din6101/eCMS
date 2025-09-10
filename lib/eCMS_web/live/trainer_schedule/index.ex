defmodule ECMSWeb.TrainerScheduleLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        ECMS.Accounts.get_user_by_session_token(session["user_token"])
      end)

    trainer_id = socket.assigns.current_user && socket.assigns.current_user.id

    trainer_schedules =
      Training.list_trainer_schedules_for_trainer(trainer_id)

    {:ok,
     socket
     |> assign(:page_title, "My Assigned Schedules")
     |> assign(:trainer_id, trainer_id)
     |> stream(:trainer_schedules, trainer_schedules, reset: true)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("confirm", %{"id" => id}, socket) do
    ts = Training.get_trainer_schedule!(id)

    case Training.update_trainer_schedule(ts, %{status: "confirmed"}) do
      {:ok, _updated} ->
        schedules = Training.list_trainer_schedules_for_trainer(socket.assigns.trainer_id)

        {:noreply,
         socket
         |> put_flash(:info, "Schedule confirmed")
         |> stream(:trainer_schedules, schedules, reset: true)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to confirm schedule")}
    end
  end

  @impl true
  def handle_event("decline", %{"id" => id}, socket) do
    ts = Training.get_trainer_schedule!(id)

    case Training.update_trainer_schedule(ts, %{status: "declined"}) do
      {:ok, _updated} ->
        schedules = Training.list_trainer_schedules_for_trainer(socket.assigns.trainer_id)

        {:noreply,
         socket
         |> put_flash(:info, "Schedule declined")
         |> stream(:trainer_schedules, schedules, reset: true)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to decline schedule")}
    end
  end
end
