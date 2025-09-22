defmodule ECMS.Training do
  @moduledoc """
  The Training context.
  """

  import Ecto.Query, warn: false
  alias ECMS.Repo

  alias ECMS.Training.{Enrollment, Schedule, LiveEvent, Activities, Result, Certification}
  alias ECMS.Accounts.User


  # --------------------
  # Enrollments
  # --------------------




  def list_enrollments_by_student(student_id) do
    from(e in Enrollment, where: e.user_id == ^student_id, preload: [:course])
    |> Repo.all()
  end


  def list_enrollments do
    Repo.all(Enrollment)
    |> Repo.preload([:user, :course])
  end

  def get_enrollment!(id) do
    Repo.get!(Enrollment, id)
    |> Repo.preload([:user, :course])
  end


  def create_enrollment(attrs \\ %{}) do
    %Enrollment{}
    |> Enrollment.changeset(attrs)
    |> Repo.insert()
  end

  def update_enrollment(%Enrollment{} = enrollment, attrs) do
    enrollment
    |> Enrollment.changeset(attrs)
    |> Repo.update()
  end

  def delete_enrollment(%Enrollment{} = enrollment), do: Repo.delete(enrollment)

  def change_enrollment(%Enrollment{} = enrollment, attrs \\ %{}) do
    Enrollment.changeset(enrollment, attrs)
  end

  # --------------------
  # Live Events
  # --------------------

  def list_live_events, do: Repo.all(LiveEvent)

  def get_live_event!(id), do: Repo.get!(LiveEvent, id)

  def create_live_event(attrs \\ %{}) do
    %LiveEvent{}
    |> LiveEvent.changeset(attrs)
    |> Repo.insert()
  end

  def update_live_event(%LiveEvent{} = live_event, attrs) do
    live_event
    |> LiveEvent.changeset(attrs)
    |> Repo.update()
  end

  def delete_live_event(%LiveEvent{} = live_event), do: Repo.delete(live_event)

  def change_live_event(%LiveEvent{} = live_event, attrs \\ %{}) do
    LiveEvent.changeset(live_event, attrs)
  end

  # --------------------
  # Activities
  # --------------------

  def list_activities, do: Repo.all(Activities)

  def get_activities!(id), do: Repo.get!(Activities, id)

  def create_activities(attrs \\ %{}) do
    %Activities{}
    |> Activities.changeset(attrs)
    |> Repo.insert()
  end

  def update_activities(%Activities{} = activities, attrs) do
    activities
    |> Activities.changeset(attrs)
    |> Repo.update()
  end

  def delete_activities(%Activities{} = activities), do: Repo.delete(activities)

  def change_activities(%Activities{} = activities, attrs \\ %{}) do
    Activities.changeset(activities, attrs)
  end

  # --------------------
  # Schedules
  # --------------------

  def list_schedules do
    Repo.all(Schedule)
    |> Repo.preload([:course, :trainer])
  end

  def list_schedules_by_trainer(trainer_id) do
    from(s in Schedule,
      where: s.trainer_id == ^trainer_id,
      order_by: [asc: s.schedule_date, asc: s.schedule_time],
      preload: [:course]
    )
    |> Repo.all()
  end


  def get_schedule!(id) do
    Repo.get!(Schedule, id)
    |> Repo.preload([:course, :trainer])
  end

  def create_schedule(attrs \\ %{}) do
    %Schedule{}
    |> Schedule.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schedule} ->
        send_admin_schedule_notification(schedule)
        {:ok, schedule}

      error -> error
    end
  end

  def update_schedule(%Schedule{} = schedule, attrs) do
    schedule
    |> Schedule.changeset(attrs)
    |> Repo.update()
  end

  def delete_schedule(%Schedule{} = schedule), do: Repo.delete(schedule)

  def change_schedule(%Schedule{} = schedule, attrs \\ %{}) do
    Schedule.changeset(schedule, attrs)
  end

  def update_schedule_status(schedule, status) do
    schedule
    |> Schedule.changeset(%{status: status})
    |> Repo.update()
    |> case do
      {:ok, updated_schedule} ->
        send_status_notification_to_admin(updated_schedule, status)
        {:ok, updated_schedule}

      error -> error
    end
  end

  def get_status_description(status) do
    case status do
      "assigned" -> "Has been assigned to trainer but no acceptance yet"
      "invited" -> "Trainer has been invited and is reviewing the schedule"
      "confirmed" -> "Trainer has accepted and confirmed the schedule"
      "completed" -> "The scheduled course has been completed"
      "declined" -> "Trainer has declined this schedule"
      _ -> "Unknown status"
    end
  end

  def recent_schedules_for_admin(limit \\ 5) do
    from(s in Schedule,
      preload: [:course, :trainer],
      order_by: [desc: s.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  # --------------------
  # Private Helpers
  # --------------------

  defp send_admin_schedule_notification(schedule) do
    schedule = Repo.preload(schedule, [:course, :trainer])

    message = """
    New schedule created:

    Course: #{schedule.course.title}
    Trainer: #{schedule.trainer.full_name}
    Status: #{schedule.status}
    Notes: #{schedule.notes || "No additional notes"}
    """

    ECMS.Notifications.create_admin_notification(%{
      "user_id" => 1,
      "course_id" => schedule.course_id,
      "message" => message,
    })
  end

  defp send_status_notification_to_admin(schedule, status) do
    schedule = Repo.preload(schedule, [:course, :trainer])

    action =
      case status do
        "confirmed" -> "accepted"
        "declined" -> "declined"
        _ -> "updated"
      end

    message = """
    Trainer #{action} schedule:

    Course: #{schedule.course.title}
    Trainer: #{schedule.trainer.full_name}
    Status: #{String.capitalize(to_string(status))}

    Please check the schedule status in the admin panel.
    """

    ECMS.Notifications.create_admin_notification(%{
      "user_id" => 1,
      "course_id" => schedule.course_id,
      "message" => message,
      "notify_students" => false
    })
  end

  # --------------------
# Trainer Schedule Wrappers
# --------------------

def list_trainer_schedules_for_trainer(trainer_id) do
  list_schedules_by_trainer(trainer_id)
end

def get_trainer_schedule!(id), do: get_schedule!(id)

def update_trainer_schedule(%Schedule{} = schedule, attrs) do
  update_schedule(schedule, attrs)
end


  alias ECMS.Training.Result


  def list_results_for_student(user_id) do
    ECMS.Repo.all(
      from r in ECMS.Training.Result,
        where: r.user_id == ^user_id,
        preload: [:course]
    )
  end


  @doc """
  Returns the list of results.

  ## Examples

      iex> list_results()
      [%Result{}, ...]

  """
  def list_results do
    Repo.all(Result) |> Repo.preload([:user, :course])
  end

  @doc """
  Gets a single result.

  Raises `Ecto.NoResultsError` if the Result does not exist.

  ## Examples

      iex> get_result!(123)
      %Result{}

      iex> get_result!(456)
      ** (Ecto.NoResultsError)

  """
  def get_result!(id) do
    Repo.get!(Result, id) |> Repo.preload([:user, :course])
  end


  @doc """
  Creates a result.

  ## Examples

      iex> create_result(%{field: value})
      {:ok, %Result{}}

      iex> create_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_result(attrs \\ %{}) do
    %Result{}
    |> Result.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, result} ->
        {:ok, Repo.preload(result, [:user, :course])}

      error ->
        error
    end
  end

  @doc """
  Updates a result.

  ## Examples

      iex> update_result(result, %{field: new_value})
      {:ok, %Result{}}

      iex> update_result(result, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_result(%Result{} = result, attrs) do
    result
    |> Result.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, result} ->
        {:ok, Repo.preload(result, [:user, :course])}

      error ->
        error
    end
  end

  @doc """
  Deletes a result.

  ## Examples

      iex> delete_result(result)
      {:ok, %Result{}}

      iex> delete_result(result)
      {:error, %Ecto.Changeset{}}

  """
  def delete_result(%Result{} = result) do
    Repo.delete(result)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking result changes.

  ## Examples

      iex> change_result(result)
      %Ecto.Changeset{data: %Result{}}

  """
  def change_result(%Result{} = result, attrs \\ %{}) do
    Result.changeset(result, attrs)
  end

  alias ECMS.Training.Certification

  @doc """
  Returns the list of certifications.

  ## Examples

      iex> list_certifications()
      [%Certification{}, ...]

  """
  def list_certifications do
    Certification
    |> Repo.all()
    |> Repo.preload([:user, :course])
  end

  def list_certifications_for_student(user_id) do
    ECMS.Training.Certification
    |> where([c], c.user_id == ^user_id)
    |> Repo.all()
    |> Repo.preload(:course)
  end


  @doc """
  Gets a single certification.

  Raises `Ecto.NoResultsError` if the Certification does not exist.

  ## Examples

      iex> get_certification!(123)
      %Certification{}

      iex> get_certification!(456)
      ** (Ecto.NoResultsError)

  """
  def get_certification!(id), do:
  Certification
  |> Repo.get!(id)
  |> Repo.preload([:user, :course])

  @doc """
  Creates a certification.

  ## Examples

      iex> create_certification(%{field: value})
      {:ok, %Certification{}}

      iex> create_certification(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_certification(attrs \\ %{}) do
    %Certification{}
    |> Certification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a certification.

  ## Examples

      iex> update_certification(certification, %{field: new_value})
      {:ok, %Certification{}}

      iex> update_certification(certification, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_certification(%Certification{} = certification, attrs) do
    certification
    |> Certification.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a certification.

  ## Examples

      iex> delete_certification(certification)
      {:ok, %Certification{}}

      iex> delete_certification(certification)
      {:error, %Ecto.Changeset{}}

  """
  def delete_certification(%Certification{} = certification) do
    Repo.delete(certification)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking certification changes.

  ## Examples

      iex> change_certification(certification)
      %Ecto.Changeset{data: %Certification{}}

  """
  def change_certification(%Certification{} = certification, attrs \\ %{}) do
    Certification.changeset(certification, attrs)
  end

  def list_students do
    from(u in User, where: u.role == "student") # assuming students are stored in users table
    |> Repo.all()
  end

  def list_courses do
    Repo.all(ECMS.Courses.Course)
  end

end
