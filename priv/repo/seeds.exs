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
{:ok, _admin} =
  Accounts.register_user(%{
    full_name: "Default Admin",
    email: "admin00@test.com",
    password: "123456789abcd",
    role: "admin"
  })

# Default Trainer
{:ok, _trainer} =
  Accounts.register_user(%{
    full_name: "Default Trainer",
    email: "trainer00@test.com",
    password: "123456789abcd",
    role: "trainer"
  })
