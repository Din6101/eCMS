defmodule ECMSWeb.DashboardAdmin do
  use ECMSWeb, :live_view

  alias ECMS.Courses
  alias ECMS.Accounts
  alias ECMS.Notifications
  alias ECMS.Training

  @impl true
  def mount(_params, _session, socket) do
    # Paginated courses
    courses = Courses.list_courses()

    # Use role-based filtering
    trainers = Accounts.list_users_by_role("trainer")
    trainees = Accounts.list_users_by_role("student")

    applications = Courses.list_applications()
    notifications = Notifications.list_latest_notifications()
    live_events = Training.list_live_events()
    activities = Training.list_activities()
    application_stats = Courses.get_application_stats()

    today = Date.utc_today()

    upcoming_courses =
      courses.entries
      |> Enum.filter(fn course -> Date.compare(course.start_date, today) in [:eq, :gt] end)
      |> Enum.sort_by(& &1.start_date)
      |> Enum.take(2)

      latest_notifications =
        notifications
        |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
        |> Enum.take(3)


    {:ok,
     assign(socket,
       page_title: "Admin Dashboard",
       trainer_count: length(trainers),
       trainee_count: length(trainees),
       course_count: length(courses.entries),
       application_count: length(applications.entries),
       upcoming_courses: upcoming_courses,
       latest_notifications: latest_notifications,
       live_events: live_events,
       activities: activities,
       application_stats: application_stats
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#06A295] text-white p-6 font-sans">
      <!-- Header Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <%= for {label, count, icon} <- [
              {"Trainer", @trainer_count, "👨‍🏫"},
              {"Trainee", @trainee_count, "👨‍🎓"},
              {"Courses", @course_count, "📚"},
              {"Applications", @application_count, "📝"}
            ] do %>
          <div class="bg-white text-black rounded p-4 shadow">
            <h2 class="text-xl font-bold"><%= icon %> <%= label %></h2>
            <p class="text-2xl mt-2"><%= count %></p>
          </div>
        <% end %>
      </div>

      <!-- Main Content Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-6">
        <!-- Left Side - 2 columns -->
        <div class="lg:col-span-2 space-y-4">
          <!-- Application Static Chart -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-2 flex items-center">
              <span class="text-2xl mr-2">📊</span>
              Application Statistic
            </h3>
            <div class="w-full h-40 flex items-end justify-between px-2 py-4 border-b-2 border-gray-200">
              <%= for stat <- @application_stats do %>
                <div class="flex flex-col items-center flex-1">
                  <div class="w-full max-w-8 bg-[#06A295] rounded-t mb-2 transition-all duration-300 hover:bg-[#058a7a]"
                       style={"height: #{max(stat.count * 8, 4)}px;"}>
                  </div>
                  <span class="text-xs font-medium text-gray-600"><%= stat.day %></span>
                  <span class="text-xs text-gray-500"><%= stat.count %></span>
                </div>
              <% end %>
            </div>
            <div class="mt-2 text-xs text-gray-500 text-center">
              Applications received in the last 7 days
            </div>
          </div>

          <!-- Upcoming Courses -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-2 flex items-center">
              <span class="text-2xl mr-2">📅</span>
              Upcoming Course
            </h3>
            <table class="w-full text-sm">
              <thead>
                <tr class="font-bold border-b">
                  <th class="text-left py-1">Course</th>
                  <th class="text-left py-1">Start</th>
                  <th class="text-left py-1">End</th>
                </tr>
              </thead>
              <tbody>
                <%= for course <- @upcoming_courses do %>
                  <tr>
                    <td><%= course.title %></td>
                    <td><%= Calendar.strftime(course.start_date, "%d-%m-%Y") %></td>
                    <td><%= Calendar.strftime(course.end_date, "%d-%m-%Y") %></td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>

          <!-- Latest Notifications -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-2 flex items-center">
              <span class="text-2xl mr-2">🔔</span>
              Latest Notification
            </h3>
            <table class="w-full text-sm">
              <thead>
                <tr class="font-bold border-b">
                  <th class="text-left py-1">To</th>
                  <th class="text-left py-1">Course</th>
                  <th class="text-left py-1">Message</th>
                  <th class="text-left py-1">Date</th>
                </tr>
              </thead>
              <tbody>
                <%= for note <- @latest_notifications do %>
                  <tr>
                    <td><%= note.student.full_name %></td>
                    <td><%= note.course.title %></td>
                    <td><%= note.message %></td>
                    <td><%= Calendar.strftime(note.inserted_at, "%d-%m-%Y") %></td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Right Side - 1 column -->
        <div class="space-y-4">
          <!-- Live Events -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-3 flex items-center">
              <span class="text-2xl mr-2">📺</span>
              LIVE EVENTS
            </h3>
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
          </div>

          <!-- Activity -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-3 flex items-center">
              <span class="text-2xl mr-2">📋</span>
              ACTIVITY
            </h3>
            <div class="space-y-3">
              <%= for act <- @activities do %>
                <div class="border-l-4 border-blue-500 pl-3 py-2">
                  <p class="font-semibold text-sm mb-1"><%= act.description %></p>
                  <p class="text-xs text-gray-600">
                    <span class="inline-block w-2 h-2 bg-blue-500 rounded-full mr-2"></span>
                    <%= Calendar.strftime(act.date, "%d %B %Y") %> @ <%= act.time %>
                  </p>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
