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
    |> CourseApplication.changeset(%{
      user_id: user.id,
      course_id: course_id,
      status: :pending
    })
    |> Repo.insert()
  end

  # List all applications (admin view) with search, status filter, sorting and pagination
  def list_applications(params \\ %{}) do
    # base query with joins + preload
    base_query =
      from a in CourseApplication,
        join: c in assoc(a, :course),
        join: u in assoc(a, :user),
        preload: [course: c, user: u]

    # search
    query =
      case Map.get(params, "search") do
        nil -> base_query
        "" -> base_query
        search ->
          from [a, c, u] in base_query,
            where: ilike(u.full_name, ^"%#{search}%") or ilike(c.title, ^"%#{search}%")
      end

    # status filter (default pending)
    query =
      case Map.get(params, "status") do
        nil -> from [a, c, u] in query, where: a.status == :pending
        "" -> from [a, c, u] in query, where: a.status == :pending
        "approved" -> from [a, c, u] in query, where: a.status == :approved
        "pending" -> from [a, c, u] in query, where: a.status == :pending
        _ -> from [a, c, u] in query, where: a.status == :pending
      end

    # default sorting by newest
    query = from [a, _c, _u] in query, order_by: [desc: a.inserted_at]

    # sorting overrides
    query =
      case Map.get(params, "sort") do
        "title_asc" -> from [a, c, u] in query, order_by: [asc: c.title]
        "title_desc" -> from [a, c, u] in query, order_by: [desc: c.title]
        "id_asc" -> from a in query, order_by: [asc: a.id]
        "id_desc" -> from a in query, order_by: [desc: a.id]
        _ -> query
      end

    # pagination
    page_number =
      case Map.get(params, "page", "1") do
        n when is_binary(n) ->
          case Integer.parse(n) do
            {i, _} -> i
            :error -> 1
          end

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

  # Application stats for current week (Mon-Sun)
  def get_application_stats do
    today = Date.utc_today()
    days_from_monday = Date.day_of_week(today) - 1
    monday = Date.add(today, -days_from_monday)

    days = for i <- 0..6, do: Date.add(monday, i)

    actual_stats =
      from(a in CourseApplication,
        where:
          fragment("date(?)", a.inserted_at) >= ^monday and
            fragment("date(?)", a.inserted_at) <= ^Date.add(monday, 6),
        group_by: fragment("date(?)", a.inserted_at),
        select: %{
          date: fragment("date(?)", a.inserted_at),
          count: count(a.id)
        }
      )
      |> Repo.all()
      |> Map.new(fn stat -> {stat.date, stat.count} end)

    Enum.map(days, fn date ->
      day_name =
        case Date.day_of_week(date) do
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
    |> Repo.update()
  end

  # Reject an application
  def reject_application(%CourseApplication{} = app) do
    app
    |> CourseApplication.status_changeset(%{status: :rejected, approval: :unapproved})
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
    query = from a in CourseApplication

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

  # Generate course_id like "CID001"
  def generate_course_id do
    last_id =
      Repo.one(from c in Course, order_by: [desc: c.inserted_at], limit: 1, select: c.course_id)

    next_num =
      case last_id do
        "CID" <> num ->
          case Integer.parse(num) do
            {i, _} -> i + 1
            :error -> 1
          end

        _ ->
          1
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
  """
  def list_courses(params \\ %{}) do
    search = Map.get(params, "search", "")
    page = Map.get(params, "page", "1") |> case do
      n when is_binary(n) -> case Integer.parse(n) do {i, _} -> i; :error -> 1 end
      n when is_integer(n) -> n
      _ -> 1
    end
    per_page = 10
    sort = Map.get(params, "sort", "title_desc")

    query =
      from c in Course,
        where: ilike(c.title, ^"%#{search}%") or ilike(c.description, ^"%#{search}%")

    query =
      case sort do
        "title_asc" -> from c in query, order_by: [asc: c.title]
        "title_desc" -> from c in query, order_by: [desc: c.title]
        "id_asc" -> from c in query, order_by: [asc: c.course_id]
        "id_desc" -> from c in query, order_by: [desc: c.course_id]
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
  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Creates a course.
  """
  def create_course(attrs \\ %{}) do
    attrs = Map.put_new(attrs, "course_id", generate_course_id())

    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.
  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course along with related records inside a transaction.
  """
  def delete_course(%Course{} = course) do
    Repo.transaction(fn ->
      # Admin notifications
      from(an in AdminNotifications, where: an.course_id == ^course.id)
      |> Repo.delete_all()

      # Student notifications
      from(sn in StudentNotifications, where: sn.course_id == ^course.id)
      |> Repo.delete_all()

      # Results
      from(r in ECMS.Training.Result, where: r.course_id == ^course.id)
      |> Repo.delete_all()

      # Certifications
      from(c in ECMS.Training.Certification, where: c.course_id == ^course.id)
      |> Repo.delete_all()

      # Course applications
      from(ca in CourseApplication, where: ca.course_id == ^course.id)
      |> Repo.delete_all()

      # Schedules
      from(s in ECMS.Training.Schedule, where: s.course_id == ^course.id)
      |> Repo.delete_all()

      # Finally delete the course
      Repo.delete(course)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.
  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  # Quota helpers (fixed 20 per course)
  def count_approved_applications_for_course(course_id) do
    from(a in CourseApplication,
      where: a.course_id == ^course_id and a.status == :approved,
      select: count(a.id)
    )
    |> Repo.one()
  end

  def course_full?(course_id, quota \\ 20) do
    count_approved_applications_for_course(course_id) >= quota
  end

  # Suggest related courses by shared keywords in title/description
  def suggest_related_courses(%Course{} = course, limit \\ 3) do
    candidates = list_all_courses()
    text = String.downcase("#{course.title} #{course.description}")

    keywords =
      text
      |> String.replace(~r/[^a-z0-9\s]/, "")
      |> String.split(~r/\s+/, trim: true)
      |> Enum.reject(&(&1 in ["the", "and", "of", "to", "in", "for", "with", "a", "an", "on", "by", "is", "it"]))
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
