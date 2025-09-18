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

  describe "enrollments" do
    alias ECMS.Training.Enrollment

    import ECMS.TrainingFixtures

    @invalid_attrs %{status: nil, progress: nil, user_id: nil, course_id: nil, milestone: nil}

    test "list_enrollments/0 returns all enrollments" do
      enrollment = enrollment_fixture()
      assert Training.list_enrollments() == [enrollment]
    end

    test "get_enrollment!/1 returns the enrollment with given id" do
      enrollment = enrollment_fixture()
      assert Training.get_enrollment!(enrollment.id) == enrollment
    end

    test "create_enrollment/1 with valid data creates a enrollment" do
      valid_attrs = %{status: "some status", progress: 42, user_id: "some user_id", course_id: "some course_id", milestone: %{}}

      assert {:ok, %Enrollment{} = enrollment} = Training.create_enrollment(valid_attrs)
      assert enrollment.status == "some status"
      assert enrollment.progress == 42
      assert enrollment.user_id == "some user_id"
      assert enrollment.course_id == "some course_id"
      assert enrollment.milestone == %{}
    end

    test "create_enrollment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Training.create_enrollment(@invalid_attrs)
    end

    test "update_enrollment/2 with valid data updates the enrollment" do
      enrollment = enrollment_fixture()
      update_attrs = %{status: "some updated status", progress: 43, user_id: "some updated user_id", course_id: "some updated course_id", milestone: %{}}

      assert {:ok, %Enrollment{} = enrollment} = Training.update_enrollment(enrollment, update_attrs)
      assert enrollment.status == "some updated status"
      assert enrollment.progress == 43
      assert enrollment.user_id == "some updated user_id"
      assert enrollment.course_id == "some updated course_id"
      assert enrollment.milestone == %{}
    end

    test "update_enrollment/2 with invalid data returns error changeset" do
      enrollment = enrollment_fixture()
      assert {:error, %Ecto.Changeset{}} = Training.update_enrollment(enrollment, @invalid_attrs)
      assert enrollment == Training.get_enrollment!(enrollment.id)
    end

    test "delete_enrollment/1 deletes the enrollment" do
      enrollment = enrollment_fixture()
      assert {:ok, %Enrollment{}} = Training.delete_enrollment(enrollment)
      assert_raise Ecto.NoResultsError, fn -> Training.get_enrollment!(enrollment.id) end
    end

    test "change_enrollment/1 returns a enrollment changeset" do
      enrollment = enrollment_fixture()
      assert %Ecto.Changeset{} = Training.change_enrollment(enrollment)
    end
  end

  describe "live_events" do
    alias ECMS.Training.LiveEvent

    import ECMS.TrainingFixtures

    @invalid_attrs %{title: nil, live: nil, presenter: nil}

    test "list_live_events/0 returns all live_events" do
      live_event = live_event_fixture()
      assert Training.list_live_events() == [live_event]
    end

    test "get_live_event!/1 returns the live_event with given id" do
      live_event = live_event_fixture()
      assert Training.get_live_event!(live_event.id) == live_event
    end

    test "create_live_event/1 with valid data creates a live_event" do
      valid_attrs = %{title: "some title", live: true, presenter: "some presenter"}

      assert {:ok, %LiveEvent{} = live_event} = Training.create_live_event(valid_attrs)
      assert live_event.title == "some title"
      assert live_event.live == true
      assert live_event.presenter == "some presenter"
    end

    test "create_live_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Training.create_live_event(@invalid_attrs)
    end

    test "update_live_event/2 with valid data updates the live_event" do
      live_event = live_event_fixture()
      update_attrs = %{title: "some updated title", live: false, presenter: "some updated presenter"}

      assert {:ok, %LiveEvent{} = live_event} = Training.update_live_event(live_event, update_attrs)
      assert live_event.title == "some updated title"
      assert live_event.live == false
      assert live_event.presenter == "some updated presenter"
    end

    test "update_live_event/2 with invalid data returns error changeset" do
      live_event = live_event_fixture()
      assert {:error, %Ecto.Changeset{}} = Training.update_live_event(live_event, @invalid_attrs)
      assert live_event == Training.get_live_event!(live_event.id)
    end

    test "delete_live_event/1 deletes the live_event" do
      live_event = live_event_fixture()
      assert {:ok, %LiveEvent{}} = Training.delete_live_event(live_event)
      assert_raise Ecto.NoResultsError, fn -> Training.get_live_event!(live_event.id) end
    end

    test "change_live_event/1 returns a live_event changeset" do
      live_event = live_event_fixture()
      assert %Ecto.Changeset{} = Training.change_live_event(live_event)
    end
  end

  describe "activity" do
    alias ECMS.Training.Activities

    import ECMS.TrainingFixtures

    @invalid_attrs %{date: nil, time: nil, description: nil}

    test "list_activity/0 returns all activity" do
      activities = activities_fixture()
      assert Training.list_activity() == [activities]
    end

    test "get_activities!/1 returns the activities with given id" do
      activities = activities_fixture()
      assert Training.get_activities!(activities.id) == activities
    end

    test "create_activities/1 with valid data creates a activities" do
      valid_attrs = %{date: ~D[2025-09-15], time: ~T[14:00:00], description: "some description"}

      assert {:ok, %Activities{} = activities} = Training.create_activities(valid_attrs)
      assert activities.date == ~D[2025-09-15]
      assert activities.time == ~T[14:00:00]
      assert activities.description == "some description"
    end

    test "create_activities/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Training.create_activities(@invalid_attrs)
    end

    test "update_activities/2 with valid data updates the activities" do
      activities = activities_fixture()
      update_attrs = %{date: ~D[2025-09-16], time: ~T[15:01:01], description: "some updated description"}

      assert {:ok, %Activities{} = activities} = Training.update_activities(activities, update_attrs)
      assert activities.date == ~D[2025-09-16]
      assert activities.time == ~T[15:01:01]
      assert activities.description == "some updated description"
    end

    test "update_activities/2 with invalid data returns error changeset" do
      activities = activities_fixture()
      assert {:error, %Ecto.Changeset{}} = Training.update_activities(activities, @invalid_attrs)
      assert activities == Training.get_activities!(activities.id)
    end

    test "delete_activities/1 deletes the activities" do
      activities = activities_fixture()
      assert {:ok, %Activities{}} = Training.delete_activities(activities)
      assert_raise Ecto.NoResultsError, fn -> Training.get_activities!(activities.id) end
    end

    test "change_activities/1 returns a activities changeset" do
      activities = activities_fixture()
      assert %Ecto.Changeset{} = Training.change_activities(activities)
    end
  end

  describe "results" do
    alias ECMS.Training.Result

    import ECMS.TrainingFixtures

    @invalid_attrs %{status: nil, final_score: nil, certification: nil}

    test "list_results/0 returns all results" do
      result = result_fixture()
      assert Training.list_results() == [result]
    end

    test "get_result!/1 returns the result with given id" do
      result = result_fixture()
      assert Training.get_result!(result.id) == result
    end

    test "create_result/1 with valid data creates a result" do
      valid_attrs = %{status: "some status", final_score: 42, certification: "some certification"}

      assert {:ok, %Result{} = result} = Training.create_result(valid_attrs)
      assert result.status == "some status"
      assert result.final_score == 42
      assert result.certification == "some certification"
    end

    test "create_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Training.create_result(@invalid_attrs)
    end

    test "update_result/2 with valid data updates the result" do
      result = result_fixture()
      update_attrs = %{status: "some updated status", final_score: 43, certification: "some updated certification"}

      assert {:ok, %Result{} = result} = Training.update_result(result, update_attrs)
      assert result.status == "some updated status"
      assert result.final_score == 43
      assert result.certification == "some updated certification"
    end

    test "update_result/2 with invalid data returns error changeset" do
      result = result_fixture()
      assert {:error, %Ecto.Changeset{}} = Training.update_result(result, @invalid_attrs)
      assert result == Training.get_result!(result.id)
    end

    test "delete_result/1 deletes the result" do
      result = result_fixture()
      assert {:ok, %Result{}} = Training.delete_result(result)
      assert_raise Ecto.NoResultsError, fn -> Training.get_result!(result.id) end
    end

    test "change_result/1 returns a result changeset" do
      result = result_fixture()
      assert %Ecto.Changeset{} = Training.change_result(result)
    end
  end
end
