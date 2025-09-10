defmodule ECMS.Training do
  @moduledoc """
  The Training context.
  """

  import Ecto.Query, warn: false
  alias ECMS.Repo

  alias ECMS.Training.{Schedule, TrainerSchedule}

  # ---------------------------------------------------------
  # SCHEDULE CRUD
  # ---------------------------------------------------------

  @doc "List all schedules with preload course + trainer"
  def list_schedules do
    Schedule
    |> Repo.all()
    |> Repo.preload([:course, :trainer, :trainer_schedules])
  end

  @doc "Get a single schedule (raise if not found)"
  def get_schedule!(id) do
    Repo.get!(Schedule, id)
    |> Repo.preload([:course, :trainer, :trainer_schedules])
  end

  @doc """
  Create a schedule (jika trainer_id diberi, auto-create trainer_schedule).
  Status ikut apa yang admin pilih dalam form (default: "assigned").
  """
  def create_schedule(attrs \\ %{}) do
    %Schedule{}
    |> Schedule.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schedule} ->
        if trainer_id = attrs["trainer_id"] || attrs[:trainer_id] do
          status = attrs["status"] || attrs[:status] || "assigned"

          %TrainerSchedule{}
          |> TrainerSchedule.changeset(%{
            schedule_id: schedule.id,
            trainer_id: trainer_id,
            status: status,
            notes: attrs["notes"] || attrs[:notes]
          })
          |> Repo.insert()
        end

        {:ok, schedule}

      error ->
        error
    end
  end

  @doc """
  Update schedule. Jika ada `notes` atau `status` dalam attrs,
  semua trainer_schedules yang berkait akan dikemaskini juga.
  """
  def update_schedule(%Schedule{} = schedule, attrs) do
    Repo.transaction(fn ->
      {:ok, updated_schedule} =
        schedule
        |> Schedule.changeset(attrs)
        |> Repo.update()

      updates = []
      updates =
        if notes = attrs["notes"] || attrs[:notes] do
          Keyword.put(updates, :notes, notes)
        else
          updates
        end

      updates =
        if status = attrs["status"] || attrs[:status] do
          Keyword.put(updates, :status, status)
        else
          updates
        end

      if updates != [] do
        from(ts in TrainerSchedule, where: ts.schedule_id == ^schedule.id)
        |> Repo.update_all(set: updates)
      end

      updated_schedule
    end)
  end

  @doc "Delete a schedule"
  def delete_schedule(%Schedule{} = schedule) do
    Repo.delete(schedule)
  end

  @doc "Return a changeset for schedule"
  def change_schedule(%Schedule{} = schedule, attrs \\ %{}) do
    Schedule.changeset(schedule, attrs)
  end

  # ---------------------------------------------------------
  # TRAINER SCHEDULE CRUD
  # ---------------------------------------------------------

  @doc "List all trainer schedules with preload"
  def list_trainer_schedules do
    Repo.all(TrainerSchedule)
    |> Repo.preload([
      :trainer,
      schedule: [:course, :trainer]
    ])
  end

  @doc "List trainer schedules untuk trainer tertentu"
  def list_trainer_schedules_for_trainer(nil), do: []

  def list_trainer_schedules_for_trainer(trainer_id) do
    from(ts in TrainerSchedule,
      where: ts.trainer_id == ^trainer_id,
      preload: [:trainer, schedule: [:course, :trainer]]
    )
    |> Repo.all()
  end

  @doc "Get a single trainer schedule (raise if not found)"
  def get_trainer_schedule!(id) do
    Repo.get!(TrainerSchedule, id)
    |> Repo.preload([
      :trainer,
      schedule: [:course, :trainer]
    ])
  end

  @doc "Create trainer schedule"
  def create_trainer_schedule(attrs \\ %{}) do
    %TrainerSchedule{}
    |> TrainerSchedule.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Update trainer schedule (contoh untuk tukar status)"
  def update_trainer_schedule(%TrainerSchedule{} = ts, attrs) do
    ts
    |> TrainerSchedule.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated} ->
        Phoenix.PubSub.broadcast(ECMS.PubSub, "trainer_schedules", {:updated, updated})
        {:ok, updated}

      error ->
        error
    end
  end

  @doc "Delete trainer schedule"
  def delete_trainer_schedule(%TrainerSchedule{} = ts) do
    Repo.delete(ts)
  end

  @doc "Return a changeset for trainer schedule"
  def change_trainer_schedule(%TrainerSchedule{} = ts, attrs \\ %{}) do
    TrainerSchedule.changeset(ts, attrs)
  end
end
