defmodule ECMS.Training.Result do
  use Ecto.Schema
  import Ecto.Changeset

  schema "results" do
    field :status, :string
    field :final_score, :integer
    field :certification, :string

    belongs_to :user, ECMS.Accounts.User
    belongs_to :course, ECMS.Courses.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(result, attrs) do
    result
    |> cast(attrs, [:user_id, :course_id, :final_score, :status, :certification])
    |> validate_required([:user_id, :course_id, :final_score, :status, :certification])
    |> assoc_constraint(:user)
    |> assoc_constraint(:course)
  end

end
