defmodule ECMSWeb.AdminNotificationsLive.Index do
  use ECMSWeb, :live_view
  alias ECMS.Notifications
  alias ECMS.Notifications.AdminNotifications
  alias ECMS.Accounts
  alias ECMS.Courses

  def mount(_params, _session, socket) do
    IO.inspect(socket.assigns.current_user, pretty: true, limit: :infinity)
IO.puts("CURRENT USER IN MOUNT ABOVE")

    admin_id =
      case Map.get(socket.assigns, :current_user) do
        nil -> nil
        user -> user.id
      end

    notifications =
      if admin_id do
        Notifications.list_admin_notifications_paginated(admin_id, %{"page" => 1, "status" => ""})
      else
        # Kalau current_user belum load, bagi fallback kosong
        %{entries: [], page: 1, total_pages: 1, total_entries: 0, per_page: 10, status: ""}
      end

      changeset = Notifications.change_admin_notification(%AdminNotifications{})

      {:ok, socket
      |> assign(:notifications, notifications) # yg kau ambil awal-awal
      |> assign(:status, "")
     |> assign(:changeset, changeset)
     |> assign(:form, to_form(changeset))
     |> assign(:show_modal, false)
     |> assign(:users, Accounts.list_users())   # ✅ preload users for the form
     |> assign(:courses, Courses.list_all_courses()) # ✅ preload courses for the form
    }
  end

  def handle_event("new_notification", _params, socket) do
    changeset = Notifications.change_admin_notification(%AdminNotifications{})
    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:form, to_form(changeset))
     |> assign(:show_modal, true)}
  end

  def handle_event("validate", %{"admin_notifications" => params}, socket) do
    changeset =
      %AdminNotifications{}
      |> Notifications.change_admin_notification(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)
    |> assign(:form, to_form(changeset))}
  end

  def handle_event("save", %{"admin_notifications" => params}, socket) do
    case Notifications.create_admin_notification(params) do
      {:ok, _notif} ->
      admin_id = socket.assigns.current_user.id
      status   = socket.assigns.status
      notifications =
        Notifications.list_admin_notifications_paginated(admin_id, %{"page" => 1, "status" => status})
        {:noreply,
         socket
         |> put_flash(:info, "Notification created successfully.")
         |> assign(:notifications, notifications)
         |> assign(:show_modal, false)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)
        |> assign(:form, to_form(changeset))}
    end
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, :show_modal, false)}
  end

  def handle_event("resend", %{"id" => id}, socket) do
    admin_id = socket.assigns.current_user.id
    status   = socket.assigns.status

    case Notifications.resend_admin_notification(String.to_integer(id)) do
      {:ok, _notif} ->
    notifications =
      Notifications.list_admin_notifications_paginated(admin_id, %{"page" => 1, "status" => status})

         {:noreply,
        socket
       |> put_flash(:info, "Notification resent.")
       |> assign(:notifications, notifications)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
          socket
          |> put_flash(:error, "Failed to resend notification.")
          |> assign(:changeset, changeset)
          |> assign(:form, to_form(changeset))}
      end
  end

  def handle_event("mark_as_read", %{"id" => id}, socket) do
    admin_id = socket.assigns.current_user.id
    status   = socket.assigns[:status] || ""

    notif = Notifications.get_admin_notification!(String.to_integer(id))
    {:ok, _} = Notifications.mark_admin_as_read(notif)

    notifications =
      Notifications.list_admin_notifications_paginated(
        admin_id,
        %{"page" => 1, "status" => status}
      )

    {:noreply,
     socket
     |> put_flash(:info, "Notification marked as read.")
     |> assign(:notifications, notifications)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    admin_id = socket.assigns.current_user.id
    status   = socket.assigns[:status] || ""

    notif = Notifications.get_admin_notification!(String.to_integer(id))
    {:ok, _} = Notifications.delete_admin_notification(notif)

    notifications =
      Notifications.list_admin_notifications_paginated(
        admin_id,
        %{"page" => 1, "status" => status}
      )

    {:noreply,
     socket
     |> put_flash(:info, "Notification deleted.")
     |> assign(:notifications, notifications)}
  end

  def handle_event("filter_status", %{"status" => status}, socket) do
    admin_id = socket.assigns.current_user.id

    notifications =
      Notifications.list_admin_notifications_paginated(admin_id, %{"page" => 1, "status" => status})

      {:noreply,
 socket
 |> assign(:notifications, notifications)
 |> assign(:status, status)}

    end

  def handle_event("paginate", %{"page" => page}, socket) do
    admin_id = socket.assigns.current_user.id
    status = socket.assigns.status
    notifications = Notifications.list_admin_notifications_paginated(admin_id, %{"page" => String.to_integer(page), "status" => status})

    {:noreply, assign(socket, notifications: notifications)}
  end
end
