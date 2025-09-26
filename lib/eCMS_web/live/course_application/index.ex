defmodule ECMSWeb.CourseApplicationLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Courses
  alias ECMS.Notifications

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:applications, Courses.list_applications(%{
       "page" => "1",
       "search" => "",

       "status" => "pending"
     }))
     |> assign(:search, "")
     |> assign(:status, "pending")

       "sort" => "id_desc"
     }))
     |> assign(:search, "")
     |> assign(:sort, "id_desc")

     |> assign(:page, 1)}
  end

  @impl true
  @spec handle_event(<<_::32, _::_*8>>, map(), map()) :: {:noreply, map()}
  def handle_event("approve", %{"id" => id}, socket) do
    app = Courses.get_application!(id)
    {:ok, _} = Courses.approve_application(app)

    {:noreply,
     assign(socket, :applications, Courses.list_applications(%{
       "search" => socket.assigns.search,

       "status" => socket.assigns.status,

       "sort" => socket.assigns.sort,

       "page" => socket.assigns.page
     }))}
  end

  def handle_event("reject", %{"id" => id}, socket) do
    app = Courses.get_application!(id)
    {:ok, _} = Courses.reject_application(app)

    {:noreply,
     assign(socket, :applications, Courses.list_applications(%{
       "search" => socket.assigns.search,

       "status" => socket.assigns.status,

       "sort" => socket.assigns.sort,

       "page" => socket.assigns.page
     }))}
  end

  def handle_event("delete_application", %{"id" => id}, socket) do
    app = Courses.get_application!(id)
    {:ok, _} = Courses.delete_application(app)

    {:noreply,
     socket
     |> put_flash(:info, "Application deleted")
     |> assign(:applications, Courses.list_applications(%{
       "search" => socket.assigns.search,

       "status" => socket.assigns.status,

       "sort" => socket.assigns.sort,

       "page" => socket.assigns.page
     }))}
  end

  def handle_event("send_notification", %{"course_app_id" => course_app_id}, socket) do

    case Notifications.send_notification(course_app_id, "Your course has been approved.") do
      {:ok, {_admin_notif, _student_notif}} ->

        {:noreply,
         socket
         |> put_flash(:info, "Notification sent to student.")
         |> assign(:applications, %{
          socket.assigns.applications
          | entries:
              Enum.map(socket.assigns.applications.entries, fn app ->
                if app.id == String.to_integer(course_app_id) do
                  %{app | notification: :sent}
                else
                  app
                end
              end)
        })}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to send notification: #{inspect(changeset.errors)}")}
    end
  end


  def handle_event("approve_all", _params, socket) do
    # Use current filters to approve only matching applications
    _count = Courses.approve_all_applications(%{
      "search" => socket.assigns.search,
      "status" => socket.assigns.status
    })

    {:noreply,
     socket
     |> put_flash(:info, "All matching applications approved")
     |> assign(:applications, Courses.list_applications(%{
       "search" => socket.assigns.search,
       "status" => socket.assigns.status,
       "page" => socket.assigns.page
     }))}
  end



  def handle_event("search", %{"search" => search}, socket) do
    {:noreply,
     socket
     |> assign(:applications, Courses.list_applications(%{
       "search" => search,

       "status" => socket.assigns.status,

       "sort" => socket.assigns.sort,

       "page" => "1"
     }))
     |> assign(:search, search)
     |> assign(:page, 1)}
  end


  def handle_event("paginate", %{"page" => page}, socket) do
    page_num = String.to_integer(page)


  def handle_event("sort", %{"sort" => sort}, socket) do

    {:noreply,
     socket
     |> assign(:applications, Courses.list_applications(%{
       "search" => socket.assigns.search,

       "status" => socket.assigns.status,
       "page" => page
     }))
     |> assign(:page, page_num)}
  end

  def handle_event("filter_status", %{"status" => status}, socket) do

       "sort" => sort,
       "page" => "1"
     }))
     |> assign(:sort, sort)
     |> assign(:page, 1)}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    page_num = String.to_integer(page)


    {:noreply,
     socket
     |> assign(:applications, Courses.list_applications(%{
       "search" => socket.assigns.search,

       "status" => status,
       "page" => "1"
     }))
     |> assign(:status, status)
     |> assign(:page, 1)}

       "sort" => socket.assigns.sort,
       "page" => page
     }))
     |> assign(:page, page_num)}

  end

  defp notification_status(app) do
    case Notifications.get_by_application(app.id) do
      nil -> :unsent
      _ -> :sent
    end
  end



end
