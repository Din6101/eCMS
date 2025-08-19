defmodule ECMS.Courses do
  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false
  alias ECMS.Repo

  alias ECMS.Courses.Course


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
    Repo.delete(course)
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
end
