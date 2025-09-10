defmodule ECMS.TrainingTest do
  use ECMS.DataCase

  alias ECMS.Training

  describe "schedules" do
    alias ECMS.Training.Schedule

    import ECMS.TrainingFixtures

    @invalid_attrs %{status: nil, notes: nil}

    test "list_schedules/0 returns all schedules" do
      schedule = schedule_fixture()
      assert Training.list_schedules() == [schedule]
    end

    test "get_schedule!/1 returns the schedule with given id" do
      schedule = schedule_fixture()
      assert Training.get_schedule!(schedule.id) == schedule
    end

    test "create_schedule/1 with valid data creates a schedule" do
      valid_attrs = %{status: "some status", notes: "some notes"}

      assert {:ok, %Schedule{} = schedule} = Training.create_schedule(valid_attrs)
      assert schedule.status == "some status"
      assert schedule.notes == "some notes"
    end

    test "create_schedule/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Training.create_schedule(@invalid_attrs)
    end

    test "update_schedule/2 with valid data updates the schedule" do
      schedule = schedule_fixture()
      update_attrs = %{status: "some updated status", notes: "some updated notes"}

      assert {:ok, %Schedule{} = schedule} = Training.update_schedule(schedule, update_attrs)
      assert schedule.status == "some updated status"
      assert schedule.notes == "some updated notes"
    end

    test "update_schedule/2 with invalid data returns error changeset" do
      schedule = schedule_fixture()
      assert {:error, %Ecto.Changeset{}} = Training.update_schedule(schedule, @invalid_attrs)
      assert schedule == Training.get_schedule!(schedule.id)
    end

    test "delete_schedule/1 deletes the schedule" do
      schedule = schedule_fixture()
      assert {:ok, %Schedule{}} = Training.delete_schedule(schedule)
      assert_raise Ecto.NoResultsError, fn -> Training.get_schedule!(schedule.id) end
    end

    test "change_schedule/1 returns a schedule changeset" do
      schedule = schedule_fixture()
      assert %Ecto.Changeset{} = Training.change_schedule(schedule)
    end
  end
end
