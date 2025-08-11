defmodule ECMS.Repo do
  use Ecto.Repo,
    otp_app: :eCMS,
    adapter: Ecto.Adapters.Postgres
end
