defmodule ECMSWeb.DashboardStudent do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Notifications

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    enrollments = Training.list_enrollments_by_student(current_user.id)
    notifications = Notifications.list_notifications_for_student(current_user.id)
    live_events = Training.list_live_events()
    activities = Training.list_activities() # <- This must be implemented if not yet

    {:ok,
     socket
     |> assign(:page_title, "Trainee Dashboard")
     |> assign(:enrollments, enrollments)
     |> assign(:notifications, notifications)
     |> assign(:live_events, live_events)
     |> assign(:activities, activities)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen w-full bg-[#06A295] text-black p-6 font-sans">
      <h1 class="text-3xl font-bold mb-6 text-white">Trainee Dashboard</h1>
      <p class="text-xl font-bold mb-6 text-white">
        Welcome, <%= @current_user && @current_user.full_name || "trainee" %>. Here are your dashboard overviews.
      </p>


      <div class="flex gap-x-6">
        <!-- Left: Enrollments + Notifications -->
        <div class="flex-1 space-y-6">
          <!-- Enrollments -->
          <div class="bg-white text-black rounded p-6 shadow">
            <h2 class="text-2xl font-semibold mb-4">📚 My Enrollments</h2>
            <%= if @enrollments == [] do %>
              <p>You are not enrolled in any courses yet.</p>
            <% else %>
              <div class="space-y-4">
                <%= for enrollment <- @enrollments do %>
                  <div class="border p-4 rounded bg-gray-100">
                    <h3 class="text-xl font-semibold"><%= enrollment.course.title %></h3>
                    <p><strong>Status:</strong> <%= enrollment.status %></p>
                    <p><strong>Progress:</strong> <%= enrollment.progress %>%</p>

                    <%
                      milestone =
                        case enrollment.milestone do
                          nil -> []
                          list when is_list(list) -> list
                          str when is_binary(str) -> String.split(str, ",") |> Enum.map(&String.trim/1)
                        end
                    %>
                    <p><strong>Milestones:</strong> <%= Enum.join(milestone, ", ") %></p>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <!-- Notifications -->
          <div class="bg-white text-black rounded p-6 shadow">
            <h2 class="text-2xl font-semibold mb-4">🔔 Notifications</h2>
            <%= if @notifications == [] do %>
              <p>No notifications at the moment.</p>
            <% else %>
              <ul class="list-disc pl-5 space-y-2">
                <%= for note <- @notifications do %>
                  <li>[<%= Calendar.strftime(note.inserted_at, "%Y-%m-%d") %>] <%= note.message %></li>
                <% end %>
              </ul>
            <% end %>
          </div>
        </div>

        <!-- Right Sidebar: Live Events + Activities -->
        <div class="w-80 space-y-6">
          <!-- Live Events -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-3 flex items-center">
              <span class="text-2xl mr-2">📺</span>
              LIVE EVENTS
            </h3>
            <%= if @live_events && @live_events != [] do %>
              <%= for event <- @live_events do %>
                <div class="mb-3 p-3 bg-gray-50 rounded">
                  <div class="flex items-start justify-between">
                    <div class="flex-1">
                      <p class="font-semibold text-sm mb-1">🎤 <%= event.title %></p>
                      <div class="flex items-center text-xs text-gray-600">
                        <span class="inline-block w-2 h-2 bg-red-500 rounded-full mr-2"></span>
                        <span class="font-medium text-red-600">Live</span>
                        <span class="mx-2">–</span>
                        <span class="italic"><%= event.presenter %></span>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>
            <% else %>
              <div class="text-gray-500 text-sm">No live events available.</div>
            <% end %>
          </div>

          <!-- Activities -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-3 flex items-center">
              <span class="text-2xl mr-2">📋</span>
              ACTIVITY
            </h3>
            <%= if @activities && @activities != [] do %>
              <div class="space-y-3">
                <%= for activity <- @activities do %>
                  <div class="border-l-4 border-blue-500 pl-3 py-2">
                    <p class="font-semibold text-sm mb-1"><%= activity.description %></p>
                    <p class="text-xs text-gray-600">
                      <span class="inline-block w-2 h-2 bg-blue-500 rounded-full mr-2"></span>
                      <%= Calendar.strftime(activity.date, "%d %B %Y") %> @ <%= activity.time %>
                    </p>
                  </div>
                <% end %>
              </div>
            <% else %>
              <div class="text-gray-500 text-sm">No upcoming activities.</div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
