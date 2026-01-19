defmodule ECMS.Training.Attendance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "attendances" do
    field :scanned_at, :utc_datetime
    field :status, :string, default: "present"

    belongs_to :user, ECMS.Accounts.User
    belongs_to :course, ECMS.Courses.Course
    belongs_to :scanner, ECMS.Accounts.User, foreign_key: :scanned_by

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:user_id, :course_id, :scanned_at, :scanned_by, :status])
    |> validate_required([:user_id, :scanned_at, :scanned_by])
    |> put_scanned_at()
  end

  defp put_scanned_at(changeset) do
    case get_change(changeset, :scanned_at) do
      nil -> put_change(changeset, :scanned_at, DateTime.utc_now() |> DateTime.truncate(:second))
      _ -> changeset
    end
  end
end
