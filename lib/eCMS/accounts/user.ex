defmodule ECMS.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :full_name, :string
    field :email, :string
    field :role, :string, default: "student"
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime

    # Profile fields
    field :phone, :string
<<<<<<< HEAD
    field :ic_number, :string
=======
>>>>>>> f4cc723b89c09c3d7c28070dd4612ddd0b11a9bf
    field :date_of_birth, :date
    field :address, :string
    field :avatar_url, :string

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
def registration_changeset(user, attrs, opts \\ []) do
<<<<<<< HEAD
  # Normalize attrs to string keys and set default role to "student" if not provided
  attrs =
    attrs
    |> Enum.map(fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
    |> Map.new()
    |> Map.put_new("role", "student")

  user
  |> cast(attrs, [:full_name, :email, :password, :role]) # 👈 allow :role
  |> validate_required([:full_name, :email, :password])
=======
  user
  |> cast(attrs, [:full_name, :email, :password, :role]) # 👈 allow :role
  |> validate_required([:full_name, :email, :password, :role])
>>>>>>> f4cc723b89c09c3d7c28070dd4612ddd0b11a9bf
  |> validate_inclusion(:role, ["student", "trainer", "admin"])
  |> validate_email(opts)
  |> validate_password(opts)
end

defp validate_email(changeset, opts) do
  changeset
  |> validate_required([:email])
  |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
  |> validate_length(:email, max: 160)
  |> maybe_validate_unique_email(opts)
end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, ECMS.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Pbkdf2.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%ECMS.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Pbkdf2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  @doc """
  A user changeset for updating profile information.
  """
  def profile_changeset(user, attrs) do
    user
<<<<<<< HEAD
    |> cast(attrs, [:full_name, :phone, :ic_number, :date_of_birth, :address, :avatar_url])
    |> validate_required([:full_name])
    |> validate_length(:full_name, min: 2, max: 100)
    |> validate_length(:phone, min: 10, max: 20)
    |> validate_length(:ic_number, min: 10, max: 20)
=======
    |> cast(attrs, [:full_name, :phone, :date_of_birth, :address, :avatar_url])
    |> validate_required([:full_name])
    |> validate_length(:full_name, min: 2, max: 100)
    |> validate_length(:phone, min: 10, max: 20)
>>>>>>> f4cc723b89c09c3d7c28070dd4612ddd0b11a9bf
    |> validate_length(:address, max: 500)
  end
end
