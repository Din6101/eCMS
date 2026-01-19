defmodule ECMSWeb.StudentNotifications.Index do
  use ECMSWeb, :live_view
  alias ECMS.Notifications

  def mount(_params, session, socket) do
    student_id = session["user_id"] || socket.assigns.current_user.id
    notifications = Notifications.list_notifications_for_student(student_id)
    {:ok, assign(socket, notifications: notifications, selected: nil, status: "")}
  end


  def handle_event("show_details", %{"id" => id}, socket) do
    notification =
      Notifications.get_student_notification!(id)

    {:noreply, assign(socket, selected: notification)}
  end

  def handle_event("delete_notification", %{"id" => id}, socket) do
    notification = Notifications.get_student_notification!(id)
    {:ok, _} = Notifications.delete_notification(notification)

    student_id = socket.assigns.current_user.id
  notifications = Notifications.list_notifications_for_student(student_id)

  {:noreply,
   socket
   |> put_flash(:info, "Notification deleted successfully.")
   |> assign(%{notifications: notifications, selected: nil})}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, selected: nil)}
  end

  def handle_event("mark_as_read", %{"id" => id}, socket) do
    notif = Notifications.get_student_notification!(id)
    {:ok, _} = Notifications.mark_as_read(notif)

    {:noreply,
     socket
     |> put_flash(:info, "Marked as read.")
     |> assign(:notifications, Notifications.list_notifications_for_student(socket.assigns.current_user.id))}
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    student_id = socket.assigns.current_user.id

    notifications =
      case status do
        "read" -> Enum.filter(Notifications.list_notifications_for_student(student_id), & &1.read)
        "unread" -> Enum.filter(Notifications.list_notifications_for_student(student_id), &(not &1.read))
        _ -> Notifications.list_notifications_for_student(student_id)
      end

    {:noreply, assign(socket, notifications: notifications, status: status)}
  end

end
