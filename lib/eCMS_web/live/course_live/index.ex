defmodule ECMSWeb.CourseLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Courses
  alias ECMS.Courses.Course

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_defaults(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    courses_page = Courses.list_courses(params)

    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> assign(:courses, courses_page)
     |> assign(:search, Map.get(params, "search", ""))
     |> assign(:sort, Map.get(params, "sort", "id_desc"))}
  end

  defp assign_defaults(socket) do
    courses_page = Courses.list_courses(%{"page" => "1"})
    socket
    |> assign(:page_title, "Listing Courses")
    |> assign(:courses, courses_page)
    |> assign(:search, "")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Course")
    |> assign(:course, Courses.get_course!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Course")
    |> assign(:course, %Course{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Courses")
    |> assign(:course, nil)
  end

  @impl true
  def handle_info({ECMSWeb.CourseLive.FormComponent, {:saved, course}}, socket) do
    {:noreply, stream_insert(socket, :courses, course)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Courses.get_course!(id)
    {:ok, _} = Courses.delete_course(course)

    # reload page after deletion
    courses_page =
      Courses.list_courses(%{"search" => socket.assigns.search, "page" => "#{socket.assigns.courses.page}"})

    {:noreply, assign(socket, :courses, courses_page)}
  end

  def handle_event("search", %{"search" => search}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/admin/courses?search=#{search}&sort=#{socket.assigns.sort}&page=1"
     )}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         ~p"/admin/courses?search=#{socket.assigns.search}&sort=#{socket.assigns.sort}&page=#{page}"
     )}
  end

  def handle_event("sort", %{"sort" => sort}, socket) do
    {:noreply,
     push_patch(socket,
       to: ~p"/admin/courses?search=#{socket.assigns.search}&sort=#{sort}&page=1"
     )}
  end
end
