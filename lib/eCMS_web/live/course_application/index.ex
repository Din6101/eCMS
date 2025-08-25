defmodule ECMSWeb.CourseApplicationLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Courses

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:applications, Courses.list_applications(%{
       "page" => "1",
       "search" => "",
       "sort" => "id_desc"
     }))
     |> assign(:search, "")
     |> assign(:sort, "id_desc")
     |> assign(:page, 1)}
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    app = Courses.get_application!(id)
    {:ok, _} = Courses.approve_application(app)

    {:noreply,
     assign(socket, :applications, Courses.list_applications(%{
       "search" => socket.assigns.search,
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
       "sort" => socket.assigns.sort,
       "page" => socket.assigns.page
     }))}
  end

  def handle_event("search", %{"search" => search}, socket) do
    {:noreply,
     socket
     |> assign(:applications, Courses.list_applications(%{
       "search" => search,
       "sort" => socket.assigns.sort,
       "page" => "1"
     }))
     |> assign(:search, search)
     |> assign(:page, 1)}
  end

  def handle_event("sort", %{"sort" => sort}, socket) do
    {:noreply,
     socket
     |> assign(:applications, Courses.list_applications(%{
       "search" => socket.assigns.search,
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
       "sort" => socket.assigns.sort,
       "page" => page
     }))
     |> assign(:page, page_num)}
  end
end
