defmodule ECMS.Notifications do
  import Ecto.Query, warn: false
  alias ECMS.Repo
  alias ECMS.Notifications.StudentNotifications
  alias ECMS.Notifications.AdminNotifications
  alias ECMS.Courses.CourseApplication


  def create_notification(attrs) do
    %StudentNotifications{}
    |> StudentNotifications.changeset(attrs)
    |> Repo.insert()
  end

  def list_notifications_for_student(student_id) do
    Repo.all(
      from n in StudentNotifications,
        where: n.student_id == ^student_id,
        order_by: [desc: n.inserted_at],
        preload: [course_application: [:course]]
    )
  end

  def mark_as_read(%StudentNotifications{} = notification) do
    Repo.transaction(fn ->
      # update student notification
      {:ok, notif} =
        notification
        |> Ecto.Changeset.change(read: true)
        |> Repo.update()

      # kalau ada admin_notification_id → update admin juga
      if notif.admin_notification_id do
        admin_notif = Repo.get!(AdminNotifications, notif.admin_notification_id)

        admin_notif
        |> Ecto.Changeset.change(read: true)
        |> Repo.update()
      end

      notif
    end)
  end

  def get_by_application(course_app_id) do
    from(n in StudentNotifications,
    where: n.course_application_id == ^course_app_id,
    limit: 1
  )
  |> Repo.one()
  end

  def get_student_notification!(id) do
    Repo.get!(StudentNotifications, id)
    |> Repo.preload(course_application: :course)
  end

  def delete_notification(%StudentNotifications{} = notification) do
    Repo.delete(notification)
  end


  # List all admin notifications
  def list_admin_notifications_paginated(_admin_id, %{"page" => page, "status" => status}) do
    per_page = 10
    page = if is_binary(page), do: String.to_integer(page), else: page

    base_query =
      from n in AdminNotifications,
        order_by: [desc: n.inserted_at],
        preload: [:course, :user]

      filtered_query =
      case status do
        "read" -> from n in base_query, where: n.read == true
        "unread" -> from n in base_query, where: n.read == false
        _ -> base_query
      end

      total_entries = Repo.aggregate(filtered_query, :count)
      total_pages =
        if total_entries == 0 do
        1
        else
        Float.ceil(total_entries / per_page) |> trunc()
      end

      entries =
        filtered_query
        |> limit(^per_page)
        |> offset(^((page - 1) * per_page))
        |> Repo.all()

      %{
        entries: entries,
        page: page,
        per_page: per_page,
        total_entries: total_entries,
        total_pages: total_pages,
        status: status
      }
  end


# Get single admin notification
def get_admin_notification!(id) do
  Repo.get!(AdminNotifications, id)
  |> Repo.preload([:course, :user])
end

# Create
def create_admin_notification(attrs \\ %{}) do
  attrs = Map.put_new(attrs, "sent_at", NaiveDateTime.utc_now())

  Repo.transaction(fn ->
    # 1. Simpan notification untuk admin
    {:ok, admin_notif} =
      %AdminNotifications{}
      |> AdminNotifications.changeset(attrs)
      |> Repo.insert()

    # 2. Cari semua student yang apply course ni
    course_apps =
      Repo.all(
        from ca in ECMS.Courses.CourseApplication,
          where: ca.course_id == ^attrs["course_id"],
          preload: [:user]
      )

    # 3. Simpan student notifications untuk setiap student
    student_notifs =
    Enum.each(course_apps, fn app ->
      %StudentNotifications{}
      |> StudentNotifications.changeset(%{
        student_id: app.user_id,
        course_application_id: app.id,
        course_id: app.course_id,
        admin_notification_id: admin_notif.id,
        message: attrs["message"],
        sent_at: NaiveDateTime.utc_now()
      })
      |> Repo.insert()
    end)

    {admin_notif, student_notifs}
  end)
end

# Mark as read
def mark_admin_as_read(notification) do
  notification
  |> Ecto.Changeset.change(read: true)
  |> Repo.update()
end

# Resend
def resend_admin_notification(id) do
  notif = get_admin_notification!(id)
  attrs = %{
    "user_id" => notif.user_id,
    "course_id" => notif.course_id,
    "message" => notif.message,
    "sent_at" => NaiveDateTime.utc_now()
  }

  create_admin_notification(attrs)
end

# Delete
def delete_admin_notification(%AdminNotifications{} = notification) do
  Repo.delete(notification)
end

# Changeset helper (for forms)
def change_admin_notification(%AdminNotifications{} = notif, attrs \\ %{}) do
  AdminNotifications.changeset(notif, attrs)
end


def send_notification(course_app_id, message) when is_binary(course_app_id) do
  send_notification(String.to_integer(course_app_id), message)
end
def send_notification(course_app_id, message) when is_integer(course_app_id) do
  course_app = Repo.get!(CourseApplication, course_app_id) |> Repo.preload([:user, :course])

  # 1. Insert ke admin_notifications

    Repo.transaction(fn ->
      {:ok, admin_notif} =
    %AdminNotifications{}
    |> AdminNotifications.changeset(%{
      user_id: course_app.user_id,
      course_id: course_app.course_id,
      course_application_id: course_app.id,
      message: message,
      sent_at: NaiveDateTime.utc_now()
    })
    |> Repo.insert()

  # 2. Insert ke student_notifications
  {:ok, student_notif} =
  %StudentNotifications{}
  |> StudentNotifications.changeset(%{
    student_id: course_app.user_id,
    course_application_id: course_app.id,
    course_id: course_app.course_id,
    admin_notification_id: admin_notif.id,
    message: message,
  })
  |> Repo.insert()

 {admin_notif, student_notif}
  end)
end
end
