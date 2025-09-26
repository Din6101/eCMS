defmodule ECMS.Courses do
  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false
  alias ECMS.Repo

  alias ECMS.Courses.{Course, CourseApplication}
  alias ECMS.Training.Schedule
  alias ECMS.Notifications.{AdminNotifications, StudentNotifications}

  # Student applies to a course
  def apply_course(user, course_id) do
    %CourseApplication{}

    |> CourseApplication.changeset(%{user_id: user.id, course_id: course_id})

    |> CourseApplication.changeset(%{user_id: user.id, course_id: course_id, status: :pending})

    |> Repo.insert()
  end

# List all applications (admin view)
def list_applications(params \\ %{}) do
  import Ecto.Query

  query =
    from a in CourseApplication,
      join: c in assoc(a, :course),
      join: u in assoc(a, :user),
      preload: [course: c, user: u]


  # Search by student name or course title

  query =
    case Map.get(params, "search") do
      nil -> query
      "" -> query
      search ->
        from [a, c, u] in query,

          where: ilike(u.full_name, ^"%#{search}%") or ilike(c.title, ^"%#{search}%")
    end

  # Filter by status (approved/pending) - default to pending if no status specified
  query =
    case Map.get(params, "status") do
      nil -> from [a, c, u] in query, where: a.status == :pending
      "" -> from [a, c, u] in query, where: a.status == :pending
      "approved" -> from [a, c, u] in query, where: a.status == :approved
      "pending" -> from [a, c, u] in query, where: a.status == :pending
      _ -> from [a, c, u] in query, where: a.status == :pending
    end

  # Default sorting by date (newest first)
  query = from [a, c, u] in query, order_by: [desc: a.inserted_at]


          where: ilike(c.title, ^"%#{search}%") or ilike(u.full_name, ^"%#{search}%")
    end

  query =
    case Map.get(params, "sort") do
      "title_asc" -> from [a, c, u] in query, order_by: [asc: c.title]
      "title_desc" -> from [a, c, u] in query, order_by: [desc: c.title]
      "id_asc" -> from a in query, order_by: [asc: a.id]
      "id_desc" -> from a in query, order_by: [desc: a.id]
      _ -> query
    end


  # Pagination
  page_number =
    case Map.get(params, "page", "1") do
      n when is_binary(n) -> String.to_integer(n)
      n when is_integer(n) -> n
      _ -> 1
    end

    Repo.paginate(query, page: page_number, page_size: 10)

end

# List all applications without pagination (for student course view)
def list_all_applications do
  from(a in CourseApplication,
    join: c in assoc(a, :course),
    join: u in assoc(a, :user),
    preload: [course: c, user: u]
  )
  |> Repo.all()
end

# Count functions for profile stats
# (Use the consolidated implementations further below)

def get_application_stats do
  # Get current week starting from Monday
  today = Date.utc_today()
  days_from_monday = Date.day_of_week(today) - 1
  monday = Date.add(today, -days_from_monday)

  # Generate all 7 days of the current week (Monday to Sunday)
  days = for i <- 0..6, do: Date.add(monday, i)

  # Get actual application counts grouped by date
  actual_stats = from(a in CourseApplication,
    where: fragment("date(inserted_at)") >= ^monday and fragment("date(inserted_at)") <= ^Date.add(monday, 6),
    group_by: fragment("date(inserted_at)"),
    select: %{
      date: fragment("date(inserted_at)"),
      count: count(a.id)
    }
  )
  |> Repo.all()
  |> Map.new(fn stat -> {stat.date, stat.count} end)

  # Create stats for all 7 days, filling in 0 for days with no applications
  Enum.map(days, fn date ->
    day_name = case Date.day_of_week(date) do
      1 -> "Mon"
      2 -> "Tue"
      3 -> "Wed"
      4 -> "Thu"
      5 -> "Fri"
      6 -> "Sat"
      7 -> "Sun"
    end

    %{
      day: day_name,
      date: date,
      count: Map.get(actual_stats, date, 0)
    }
  end)
end



# Get one application
def get_application!(id) do
  Repo.get!(CourseApplication, id) |> Repo.preload([:user, :course])
end

# Approve an application
def approve_application(%CourseApplication{} = app) do
  app

  |> CourseApplication.status_changeset(%{status: :approved, approval: :approved})

  |> CourseApplication.changeset(%{status: :approved})

  |> Repo.update()
end

# Reject an application
def reject_application(%CourseApplication{} = app) do
  app

  |> CourseApplication.status_changeset(%{status: :rejected, approval: :unapproved})

  |> CourseApplication.changeset(%{status: :rejected})

  |> Repo.update()
end

def update_application(%CourseApplication{} = app, attrs) do
  app
  |> CourseApplication.changeset(attrs)
  |> Repo.update()
end

def delete_application(%CourseApplication{} = app) do
  Repo.delete(app)
end


  # Approve all applications matching optional filters (defaults to pending)
  def approve_all_applications(params \\ %{}) do
    import Ecto.Query

    # Base query
    query = from a in CourseApplication

    # Optional search by student name or course title
    query =
      case Map.get(params, "search") do
        nil -> query
        "" -> query
        search ->
          from a in query,
            join: c in assoc(a, :course),
            join: u in assoc(a, :user),
            where: ilike(u.full_name, ^"%#{search}%") or ilike(c.title, ^"%#{search}%")
      end

    # Filter by status; default to pending if not provided
    query =
      case Map.get(params, "status") do
        nil -> from a in query, where: a.status == :pending
        "" -> from a in query, where: a.status == :pending
        "approved" -> from a in query, where: a.status == :approved
        "pending" -> from a in query, where: a.status == :pending
        _ -> from a in query, where: a.status == :pending
      end

    Repo.update_all(query, set: [status: :approved, approval: :approved])
  end



  def generate_course_id do
    last_id =
      Repo.one(from c in Course, order_by: [desc: c.inserted_at], limit: 1, select: c.course_id)

    next_num =
      case last_id do
        "CID" <> num -> String.to_integer(num) + 1
        _ -> 1
      end

    "CID" <> String.pad_leading(Integer.to_string(next_num), 3, "0")
  end

  def list_all_courses do
    Repo.all(Course)
  end

  # Simple counters used by dashboard
  def count_courses do
    Repo.aggregate(Course, :count, :id)
  end

  def count_applications do
    Repo.aggregate(CourseApplication, :count, :id)
  end

  def count_courses_by_trainer(trainer_id) do
    from(c in Course,
      join: s in Schedule,
      on: s.course_id == c.id and s.trainer_id == ^trainer_id,
      select: count(fragment("DISTINCT ?", c.id))
    )
    |> Repo.one!()
  end


  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses(params \\ %{}) do
    search   = Map.get(params, "search", "")
    page     = Map.get(params, "page", "1") |> String.to_integer()
    per_page = 10  # adjust as needed
    sort = Map.get(params, "sort", "title_desc")

    query =
      from c in Course,
        where: ilike(c.title, ^"%#{search}%") or ilike(c.description, ^"%#{search}%")

    query =
      case sort do
        "title_asc"  -> from c in query, order_by: [asc: c.title]
        "title_desc" -> from c in query, order_by: [desc: c.title]
        "id_asc"     -> from c in query, order_by: [asc: c.course_id]
        "id_desc"    -> from c in query, order_by: [desc: c.course_id]
        _ -> from c in query, order_by: [desc: c.inserted_at]
      end
    total = Repo.aggregate(query, :count, :id)

    entries =
      query
      |> limit(^per_page)
      |> offset(^((page - 1) * per_page))
      |> Repo.all()

    %{
      entries: entries,
      total: total,
      page: page,
      per_page: per_page,
      total_pages: div(total + per_page - 1, per_page)
    }
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    attrs =
      Map.put_new(attrs, "course_id", generate_course_id())
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.transaction(fn ->
      # First, delete all related admin notifications
      from(an in AdminNotifications, where: an.course_id == ^course.id)
      |> Repo.delete_all()

      # Then delete all related student notifications
      from(sn in StudentNotifications, where: sn.course_id == ^course.id)
      |> Repo.delete_all()

      # Delete all results for this course
      from(r in ECMS.Training.Result, where: r.course_id == ^course.id)
      |> Repo.delete_all()

      # Delete all certifications for this course
      from(c in ECMS.Training.Certification, where: c.course_id == ^course.id)
      |> Repo.delete_all()

      # Delete all course applications for this course
      from(ca in CourseApplication, where: ca.course_id == ^course.id)
      |> Repo.delete_all()

      # Delete all schedules for this course
      from(s in ECMS.Training.Schedule, where: s.course_id == ^course.id)
      |> Repo.delete_all()

      # Finally, delete the course
      Repo.delete(course)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end



  # Quota helpers (fixed 20 per course)
  def count_approved_applications_for_course(course_id) do
    import Ecto.Query
    from(a in CourseApplication,
      where: a.course_id == ^course_id and a.status == :approved,
      select: count(a.id)
    )
    |> Repo.one()
  end

  def course_full?(course_id, quota \\ 20) do
    count_approved_applications_for_course(course_id) >= quota
  end

  # Removed quota helpers (no per-course quota logic)


  # Suggest related courses by shared keywords in title/description
  def suggest_related_courses(%ECMS.Courses.Course{} = course, limit \\ 3) do
    candidates = list_all_courses()
    text = String.downcase("#{course.title} #{course.description}")
    keywords =
      text
      |> String.replace(~r/[^a-z0-9\s]/, "")
      |> String.split(~r/\s+/, trim: true)
      |> Enum.reject(&(&1 in ["the","and","of","to","in","for","with","a","an","on","by","is","it"]))
      |> Enum.uniq()

    candidates
    |> Enum.reject(&(&1.id == course.id))
    |> Enum.map(fn c ->
      ctext = String.downcase("#{c.title} #{c.description}")
      score = Enum.count(keywords, fn k -> String.contains?(ctext, k) end)
      {c, score}
    end)
    |> Enum.filter(fn {_c, score} -> score > 0 end)
    |> Enum.sort_by(fn {_c, score} -> -score end)
    |> Enum.take(limit)
    |> Enum.map(fn {c, _} -> c end)
  end

end
