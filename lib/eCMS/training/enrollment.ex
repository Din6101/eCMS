defmodule ECMS.Training.Enrollment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "enrollments" do
    field :status, :string, default: "pending"
    field :progress, :integer, default: 0
    field :milestone, :string

    belongs_to :user, ECMS.Accounts.User
    belongs_to :course, ECMS.Courses.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, [:user_id, :course_id, :status, :progress, :milestone])
    |> maybe_join_milestone(attrs)
    |> validate_required([:user_id, :course_id, :status, :progress, :milestone])
    |> unique_constraint([:user_id, :course_id])

  end

  defp maybe_join_milestone(changeset, attrs) do
    milestones =
      Map.get(attrs, "milestone") || Map.get(attrs, :milestone)

    case milestones do
      nil ->
        changeset

      milestones when is_list(milestones) ->
        put_change(changeset, :milestone, Enum.join(milestones, ","))

      _ ->
        changeset
    end
  end

end
