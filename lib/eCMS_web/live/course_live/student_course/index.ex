defmodule ECMSWeb.CourseLive.StudentCourse do
  use ECMSWeb, :live_view
  alias ECMS.Courses

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:courses, Courses.list_courses(%{"page" => "1"}))
     |> assign(:applications, Courses.list_all_applications())
     |> assign(:search, "")
     |> assign(:sort, "id_desc")
     |> assign(:applying_course_id, nil)}
  end

  @impl true
  def handle_event("apply", %{"id" => id}, socket) do
    user = socket.assigns.current_user
    course_id = String.to_integer(id)

    # Set loading state
    socket = assign(socket, :applying_course_id, course_id)

    case Courses.apply_course(user, course_id) do
      {:ok, _app} ->
        {:noreply,
         socket
         |> put_flash(:info, "Applied successfully")
         |> assign(:applications, Courses.list_all_applications())
         |> assign(:applying_course_id, nil)}

      {:error, changeset} ->
        error_message = case changeset.errors do
          [{:course_id, {"You have already applied to this course", _}}] ->
            "You have already applied to this course"
          [{:user_id, {msg, _}}] ->
            msg
          [{:course_id, {msg, _}}] ->
            msg
          _ ->
            "Application failed. Please try again."
        end

        {:noreply,
         socket
         |> put_flash(:error, error_message)
         |> assign(:applying_course_id, nil)}
    end
  end


  def handle_event("search", %{"search" => search}, socket) do
    {:noreply,
     assign(socket, :courses, Courses.list_courses(%{
       "search" => search,
       "sort" => socket.assigns.sort,
       "page" => "1"
     }))
     |> assign(:search, search)}
  end

  def handle_event("sort", %{"sort" => sort}, socket) do
    {:noreply,
     assign(socket, :courses, Courses.list_courses(%{
       "search" => socket.assigns.search,
       "sort" => sort,
       "page" => "1"
     }))
     |> assign(:sort, sort)}
  end

  def handle_event("paginate", %{"page" => page}, socket) do
    {:noreply,
     assign(socket, :courses, Courses.list_courses(%{
       "search" => socket.assigns.search,
       "sort" => socket.assigns.sort,
       "page" => page
     }))}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="min-h-screen w-full bg-[#06A295] flex flex-col">

      <header class="flex justify-between items-center px-8 py-6">
        <h1 class="text-3xl font-bold text-white">🎓 Available Courses</h1>
      </header>

      <!-- Flash messages -->
      <%= if msg = Phoenix.Flash.get(@flash, :info) do %>
        <div
        x-data="{ show: true }"
        x-init="setTimeout(() => show = false, 3000)"
        x-show="show"
        x-transition
        class="mb-4 p-3 rounded bg-green-100 text-green-800"
        >
        <%= msg %>
        </div>
      <% end %>

      <%= if msg = Phoenix.Flash.get(@flash, :error) do %>
        <div
        x-data="{ show: true }"
        x-init="setTimeout(() => show = false, 3000)"
        x-show="show"
        x-transition
        class="mb-4 p-3 rounded bg-red-100 text-red-800"
        >
        <%= msg %>
        </div>
      <% end %>
      <!-- Search + Filter -->
      <div class="flex justify-start items-center px-8 py-4">
      <form phx-submit="search" class="flex gap-2 items-center">
        <input
        type="text"
        name="search"
        placeholder="Search courses..."
        value={@search}
        class="px-3 text-black py-2 rounded border border-gray-300 w-64"
      />
      <button type="submit" class="px-4 py-2 bg-white text-black rounded shadow">
        🔍 Search
      </button>
      </form>

      <!-- Sorting -->
      <form phx-change="sort" class="ml-4">
        <select name="sort" class="px-7 py-2 rounded border border-gray-300 text-black">
          <option value="title_asc" selected={@sort == "title_asc"}>Title ↓</option>
          <option value="title_desc" selected={@sort == "title_desc"}>Title ↑</option>
          <option value="id_asc" selected={@sort == "id_asc"}>Course ID ↓</option>
          <option value="id_desc" selected={@sort == "id_desc"}>Course ID ↑</option>
        </select>
      </form>
    </div>

    <!-- Courses Table -->
    <main class="flex-1 flex justify-center items-start p-6 w-full">
      <div class="w-full px-6 py-8">
        <table class="min-w-full text-black bg-white border divide-y divide-gray-200">
          <thead class="bg-gray-100">
            <tr>
              <th class="px-4 py-2 text-left">Course ID</th>
              <th class="px-4 py-2 text-left">Title</th>

              <th class="px-4 py-2 text-left">Description</th>
              <th class="px-4 py-2 text-right">Action</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={course <- @courses.entries}>
              <td class="px-4 py-2"><%= course.course_id %></td>
              <td class="px-4 py-2"><%= course.title %></td>

              <td class="px-4 py-2"><%= course.description %></td>
              <td class="px-4 py-2 text-right">
                <%= case Enum.find(@applications, &(&1.course_id == course.id && &1.user_id == @current_user.id)) do %>
                <% nil -> %>
                  <%= if @applying_course_id == course.id do %>
                    <button type="button" disabled class="px-3 py-1 bg-gray-400 text-white rounded cursor-not-allowed">
                      Applying...
                    </button>
                  <% else %>
                    <button type="button" phx-click="apply" phx-value-id={course.id} class="px-3 py-1 bg-blue-500 hover:bg-blue-600 text-white rounded transition-colors">
                      Apply
                    </button>
                  <% end %>
                <% app -> %>
                  <span class={[
                    "px-3 py-1 text-xs font-medium rounded-full",
                    case app.status do
                      :approved -> "bg-green-100 text-green-800"
                      :pending -> "bg-yellow-100 text-yellow-800"
                      :rejected -> "bg-red-100 text-red-800"
                      _ -> "bg-gray-100 text-gray-800"
                    end
                  ]}>
                    <%= String.capitalize(to_string(app.status)) %>
                  </span>
                <% end %>
              </td>
          </tr>
        </tbody>
      </table>

      <!-- Pagination -->
      <div class="flex justify-between items-center mt-4">
        <button
          :if={@courses.page > 1}
          phx-click="paginate"
          phx-value-page={@courses.page - 1}
          class="px-3 py-1 bg-white text-black rounded shadow"
        >
          ◀ Prev
        </button>

        <span class="text-white">
          Page <%= @courses.page %> of <%= @courses.total_pages %>
        </span>

        <button
          :if={@courses.page < @courses.total_pages}
          phx-click="paginate"
          phx-value-page={@courses.page + 1}
          class="px-3 py-1 bg-white text-black rounded shadow"
        >
          Next ▶
        </button>
      </div>
    </div>
    </main>
    </div>

    """
  end
end
