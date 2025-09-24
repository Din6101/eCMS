defmodule ECMS.Training.Certification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "certifications" do
    field :certificate_url, :string
    field :issued_at, :utc_datetime
    belongs_to :user, ECMS.Accounts.User
    belongs_to :course, ECMS.Courses.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(certification, attrs) do
    certification
    |> cast(attrs, [:certificate_url, :issued_at, :user_id, :course_id])
    |> validate_required([:certificate_url, :issued_at, :user_id, :course_id])
  end
end
