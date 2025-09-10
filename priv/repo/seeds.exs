# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ECMS.Repo.insert!(%ECMS.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ECMS.Accounts

# Default Admin
case Accounts.get_user_by_email("admin00@test.com") do
  nil ->
    Accounts.register_user(%{
      full_name: "Admin",
      email: "admin00@test.com",
      password: "123456789abcd",
      role: "admin"
    })
    IO.puts("✅ Admin created")

  _user ->
    IO.puts("⚠️ Admin already exists, skipping...")
end

# Default Trainers
trainers = [
  %{full_name: "Elvin",  email: "trainer00@test.com"},
  %{full_name: "Janet",  email: "trainer100@test.com"},
  %{full_name: "Ahmad",  email: "trainer200@test.com"},
  %{full_name: "Siti",   email: "trainer300@test.com"},
  %{full_name: "Rahman", email: "trainer400@test.com"}
]

for t <- trainers do
  case Accounts.get_user_by_email(t.email) do
    nil ->
      Accounts.register_user(%{
        full_name: t.full_name,
        email: t.email,
        password: "123456789abcd",
        role: "trainer"
      })
      IO.puts("✅ Created trainer #{t.full_name}")

    _user ->
      IO.puts("⚠️ Trainer #{t.full_name} already exists, skipping...")
  end
end
