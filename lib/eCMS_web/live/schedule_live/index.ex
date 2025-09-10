defmodule ECMSWeb.ScheduleLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.Schedule

  @impl true
  def mount(_params, _session, socket) do
    # bila connected, setup timer untuk auto refresh
    if connected?(socket), do: :timer.send_interval(5_000, self(), :reload)

    schedules =
      Training.list_schedules()
      |> ECMS.Repo.preload([
        :course,
        trainer_schedules: [:trainer]
      ])


    {:ok,
     socket
     |> stream(:schedules, schedules)
     |> assign(:schedule, nil)
     |> assign(:page_title, "Listing Schedules")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Schedule")
    |> assign(:schedule, Training.get_schedule!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Schedule")
    |> assign(:schedule, %Schedule{})
  end

  defp apply_action(socket, :index, _params) do
    schedules = Training.list_schedules()
    |> ECMS.Repo.preload([
      :course,
      trainer_schedules: [:trainer]
    ])

    socket
    |> assign(:page_title, "Listing Schedules")
    |> assign(:schedule, nil)
    |> stream(:schedules, schedules, reset: true)
  end

  @impl true
  def handle_info(:reload, socket) do
    schedules = Training.list_schedules()
    |> ECMS.Repo.preload([:course, :trainer, trainer_schedules: [:trainer]])
    {:noreply, stream(socket, :schedules, schedules, reset: true)}
  end

  @impl true
  def handle_info({ECMSWeb.ScheduleLive.FormComponent, {:saved, schedule}}, socket) do
    schedule = ECMS.Repo.preload(schedule, [:course, :trainer])
    {:noreply, stream_insert(socket, :schedules, schedule)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    schedule = Training.get_schedule!(id)
    {:ok, _} = Training.delete_schedule(schedule)

    {:noreply, stream_delete(socket, :schedules, schedule)}
  end
end
