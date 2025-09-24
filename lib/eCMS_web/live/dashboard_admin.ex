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

    # If no real data exists, show sample data for demonstration
    application_stats = if Enum.empty?(application_stats) or Enum.all?(application_stats, &(&1.count == 0)) do
      today = Date.utc_today()
      # Start from Monday of current week
      days_from_monday = Date.day_of_week(today) - 1
      monday = Date.add(today, -days_from_monday)

      [
        %{day: "Mon", date: Date.add(monday, 0), count: 0},
        %{day: "Tue", date: Date.add(monday, 1), count: 2},
        %{day: "Wed", date: Date.add(monday, 2), count: 5},
        %{day: "Thu", date: Date.add(monday, 3), count: 8},
        %{day: "Fri", date: Date.add(monday, 4), count: 3},
        %{day: "Sat", date: Date.add(monday, 5), count: 1},
        %{day: "Sun", date: Date.add(monday, 6), count: 6}
      ]
    else
      application_stats
    end

    feedback_list = Training.list_feedback()

    today = Date.utc_today()

    # Get upcoming courses with enrollment statistics (admin view)
    all_enrollments = Training.list_enrollments()
    upcoming_courses =
      courses.entries
      |> Enum.filter(fn course -> Date.compare(course.start_date, today) in [:eq, :gt] end)
      |> Enum.sort_by(& &1.start_date)
      |> Enum.map(fn course ->
        # Count enrollments for this course
        enrollment_count = Enum.count(all_enrollments, fn enrollment ->
          enrollment.course_id == course.id
        end)
        %{course: course, enrollment_count: enrollment_count}
      end)
      |> Enum.take(3)

      latest_notifications =
        notifications
        |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
        |> Enum.take(3)

    # Get latest applications for admin dashboard
    latest_applications = get_latest_applications(applications.entries, 3)

    # Get result statistics
    all_results = Training.list_results()
    result_stats = get_result_statistics(all_results)


    {:ok,
     assign(socket,
       page_title: "Admin Dashboard",
       trainer_count: length(trainers),
       trainee_count: length(trainees),
       course_count: length(courses.entries),
       application_count: length(applications.entries),
       upcoming_courses: upcoming_courses,
       latest_notifications: latest_notifications,
       latest_applications: latest_applications,
       live_events: live_events,
       activities: activities,
       application_stats: application_stats,
       feedback_list: feedback_list,
       feedback_count: length(feedback_list),
       urgent_feedback: Enum.filter(feedback_list, & &1.need_support),
       result_stats: result_stats,
       show_video_modal: false,
       selected_video: nil
     )}
  end

  @impl true
  def handle_event("show_video", %{"video_url" => video_url, "platform" => platform, "title" => title}, socket) do
    {:noreply,
     assign(socket,
       show_video_modal: true,
       selected_video: %{url: video_url, platform: platform, title: title}
     )}
  end

  @impl true
  def handle_event("close_video", _params, socket) do
    {:noreply, assign(socket, show_video_modal: false, selected_video: nil)}
  end

  @impl true
  def handle_event("close_modal_button", _params, socket) do
    {:noreply, assign(socket, show_video_modal: false, selected_video: nil)}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Admin Dashboard")}

  end

  @impl true
  def render(assigns) do
    ~H"""

    <div class="min-h-screen bg-[#06A295] text-white p-6 font-sans">
    <!-- Header -->
      <div class="mb-8">
        <h1 class="text-4xl font-bold mb-2">Admin Dashboard</h1>
        <p class="text-xl opacity-90">
          Welcome back, <%= @current_user && @current_user.full_name || "admin" %>! 👋 Here's your overview.
        </p>
      </div>
      <!-- Header Cards -->
      <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
        <%= for {label, count, icon} <- [
              {"Trainer", @trainer_count, "👨‍🏫"},
              {"Trainee", @trainee_count, "👨‍🎓"},
              {"Courses", @course_count, "📚"},
              {"Applications", @application_count, "📝"},
              {"Feedback", @feedback_count, "💬"}
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
            <h3 class="text-lg font-semibold mb-4 flex items-center justify-between">
              <span class="flex items-center">
                <span class="text-2xl mr-2">📊</span>
                Application Statistics
              </span>
              <span class="text-sm text-gray-500">Last 7 Days</span>
            </h3>

            <!-- Chart Container -->
            <div class="relative overflow-hidden">
              <!-- Y-axis labels -->
              <div class="absolute left-0 top-0 h-40 flex flex-col justify-between text-xs text-gray-400 w-8">
                <%= for i <- [16, 12, 8, 4, 0] do %>
                  <span class="text-right pr-2"><%= i %></span>
                <% end %>
              </div>

              <!-- Chart area with proper boundaries -->
              <div class="ml-10 mr-4">
                <!-- Chart bars container -->
                <div class="h-40 flex items-end justify-between border-l-2 border-b-2 border-gray-200 px-2 py-2">
                  <%= for stat <- @application_stats do %>
                    <div class="flex flex-col items-center flex-1 group">
                      <!-- Bar container -->
                      <div class="relative w-8 mx-1">
                        <div class="w-full bg-gradient-to-t from-[#06A295] to-[#08C2A8] rounded-t-sm transition-all duration-300 hover:from-[#058a7a] hover:to-[#06A295] cursor-pointer shadow-sm flex items-center justify-center"
                             style={"height: #{if stat.count == 0, do: 4, else: max(stat.count * 10, 16)}px;"}>

                          <!-- Count label INSIDE the bar -->
                          <%= if stat.count > 0 do %>
                            <span class="text-xs font-bold text-white">
                              <%= stat.count %>
                            </span>
                          <% end %>
                        </div>

                        <!-- Tooltip -->
                        <div class="absolute bottom-full left-1/2 transform -translate-x-1/2 mb-2 px-2 py-1 bg-gray-800 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity duration-200 whitespace-nowrap z-10">
                          <%= stat.count %> application<%= if stat.count != 1, do: "s" %>
                          <div class="absolute top-full left-1/2 transform -translate-x-1/2 w-0 h-0 border-l-2 border-r-2 border-t-2 border-transparent border-t-gray-800"></div>
                        </div>
                      </div>
                    </div>
                  <% end %>
                </div>

                <!-- Day labels positioned under the X-axis -->
                <div class="flex justify-between px-2 mt-1">
                  <%= for stat <- @application_stats do %>
                    <div class="flex-1 text-center">
                      <span class="text-xs font-medium text-gray-600"><%= stat.day %></span>
                    </div>
                  <% end %>
                </div>

                <!-- X-axis label -->
                <div class="text-center text-xs text-gray-400 mt-2">Days of the Week</div>
              </div>
            </div>

            <!-- Summary info -->
            <div class="mt-4 flex justify-between items-center text-xs text-gray-500 border-t pt-3">
              <span>📈 Total: <%= Enum.sum(Enum.map(@application_stats, & &1.count)) %> applications</span>
              <span>📅 Period: <%= Calendar.strftime(List.first(@application_stats).date, "%d/%m") %> - <%= Calendar.strftime(List.last(@application_stats).date, "%d/%m") %></span>
            </div>
          </div>

          <!-- Latest Applications -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-3 flex items-center">
              <span class="text-2xl mr-2">📝</span>
              Latest Course Applications
            </h3>
            <div class="overflow-x-auto">
              <table class="w-full text-sm">
                <thead>
                  <tr class="border-b-2 border-gray-200">
                    <th class="text-left py-2 font-semibold text-gray-700">Student</th>
                    <th class="text-left py-2 font-semibold text-gray-700">Course</th>
                    <th class="text-left py-2 font-semibold text-gray-700">Status</th>
                    <th class="text-left py-2 font-semibold text-gray-700">Applied</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                  <%= for app <- @latest_applications do %>
                    <tr class="hover:bg-gray-50">
                      <td class="py-2">
                        <div class="flex items-center">
                          <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center text-white text-xs font-bold mr-2">
                            <%= String.first(app.user.full_name) %>
                          </div>
                          <%= app.user.full_name %>
                        </div>
                      </td>
                      <td class="py-2 text-gray-800"><%= app.course.title %></td>
                      <td class="py-2">
                        <span class={["px-3 py-1 text-xs font-medium rounded-full",
                          case app.status do
                            :approved -> "bg-green-100 text-green-800 border border-green-200"
                            :rejected -> "bg-red-100 text-red-800 border border-red-200"
                            _ -> "bg-yellow-100 text-yellow-800 border border-yellow-200"
                          end
                        ]}>
                          <%= String.capitalize(to_string(app.status)) %>
                        </span>
                      </td>
                      <td class="py-2 text-gray-600">
                        <div class="text-xs">
                          <%= Calendar.strftime(app.inserted_at, "%d %b %Y") %>
                          <br>
                          <span class="text-gray-400"><%= Calendar.strftime(app.inserted_at, "%H:%M") %></span>
                        </div>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>

            <%= if Enum.empty?(@latest_applications) do %>
              <div class="text-center py-8 text-gray-500">
                <div class="text-4xl mb-2">📝</div>
                <p>No recent applications</p>
              </div>
            <% end %>
          </div>

          <!-- Upcoming Courses -->
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h3 class="text-xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">📅</span>
              Upcoming Courses
            </h3>
            <%= if @upcoming_courses == [] do %>
              <div class="text-center py-8 text-gray-500">
                <div class="text-4xl mb-2">📅</div>
                <p class="text-lg">No upcoming courses</p>
                <p class="text-sm">All courses have started or ended</p>
              </div>
            <% else %>
              <div class="space-y-4">
                <%= for item <- @upcoming_courses do %>
                  <%
                    course = item.course
                    enrollment_count = item.enrollment_count
                    has_enrollments = enrollment_count > 0
                  %>
                  <div class={[
                    "border-l-4 pl-4 py-3 rounded-r-lg",
                    if(has_enrollments, do: "border-green-500 bg-green-50", else: "border-orange-500 bg-orange-50")
                  ]}>
                    <div class="flex items-start justify-between">
                      <div class="flex-1">
                        <h4 class="text-lg font-semibold text-gray-800"><%= course.title %></h4>
                        <div class="text-sm text-gray-600 mt-1">
                          <p>📍 Venue: <%= course.venue || "TBA" %></p>
                          <p>📅 Starts: <%= Calendar.strftime(course.start_date, "%d %B %Y") %></p>
                          <p>🏁 Ends: <%= Calendar.strftime(course.end_date, "%d %B %Y") %></p>
                        </div>
                      </div>
                      <div class="flex flex-col items-end gap-2">
                        <div class={[
                          "text-xs px-2 py-1 rounded-full font-medium",
                          if(has_enrollments, do: "bg-green-100 text-green-800", else: "bg-orange-100 text-orange-800")
                        ]}>
                          <%= Date.diff(course.start_date, Date.utc_today()) %> days to go
                        </div>
                        <div class={[
                          "text-sm px-3 py-1 rounded-full font-medium",
                          if(has_enrollments, do: "bg-blue-100 text-blue-800", else: "bg-gray-200 text-gray-700")
                        ]}>
                          <%= if has_enrollments do %>
                            👥 <%= enrollment_count %> enrolled
                          <% else %>
                            📝 No enrollments
                          <% end %>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
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
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h3 class="text-xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">🎥</span>
              Live Events
            </h3>
            <%= if @live_events == [] do %>
              <div class="text-center py-6 text-gray-500">
                <div class="text-4xl mb-2">🎥</div>
                <p>No live events</p>
              </div>
            <% else %>
              <div class="space-y-3">
                <%= for event <- @live_events do %>
                  <div class="border border-gray-200 rounded-lg p-3 hover:bg-gray-50">
                    <div class="flex items-start justify-between">
                      <div class="flex-1">
                        <h4 class="font-semibold text-gray-800"><%= event.title %></h4>
                        <p class="text-sm text-gray-600">By <%= event.presenter %></p>
                        <%= if event.live do %>
                          <span class="inline-flex items-center px-2 py-1 text-xs font-medium bg-red-100 text-red-800 rounded-full mt-1">
                            🔴 LIVE NOW
                          </span>
                        <% end %>
                      </div>
                      <%= if event.video_url do %>
                        <button
                          phx-click="show_video"
                          phx-value-video_url={event.video_url}
                          phx-value-platform={event.platform}
                          phx-value-title={event.title}
                          class="ml-2 px-3 py-1 bg-blue-500 text-white text-xs rounded hover:bg-blue-600 transition-colors"
                        >
                          ▶️ Watch
                        </button>
                      <% end %>
                    </div>
                  </div>
                <% end %>
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

          <!-- Result Statistics -->
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h3 class="text-xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">📊</span>
              Result Statistics
            </h3>

            <!-- Statistics Cards -->
            <div class="grid grid-cols-2 gap-4 mb-4">
              <div class="bg-blue-50 p-4 rounded-lg text-center">
                <div class="text-2xl font-bold text-blue-600"><%= @result_stats.total_results %></div>
                <div class="text-sm text-gray-600">Total Results</div>
              </div>
              <div class="bg-green-50 p-4 rounded-lg text-center">
                <div class="text-2xl font-bold text-green-600"><%= @result_stats.pass_rate %>%</div>
                <div class="text-sm text-gray-600">Pass Rate</div>
              </div>
              <div class="bg-purple-50 p-4 rounded-lg text-center">
                <div class="text-2xl font-bold text-purple-600"><%= @result_stats.average_score %></div>
                <div class="text-sm text-gray-600">Avg Score</div>
              </div>
              <div class="bg-yellow-50 p-4 rounded-lg text-center">
                <div class="text-2xl font-bold text-yellow-600"><%= @result_stats.passed_count %>/<%= @result_stats.failed_count %></div>
                <div class="text-sm text-gray-600">Pass/Fail</div>
              </div>
            </div>

            <!-- Latest Results -->
            <%= if @result_stats.latest_results != [] do %>
              <div class="border-t pt-4">
                <h4 class="font-semibold text-gray-700 mb-3">Latest Results</h4>
                <div class="space-y-2">
                  <%= for result <- @result_stats.latest_results do %>
                    <div class="flex items-center justify-between text-sm">
                      <div class="flex-1">
                        <span class="font-medium"><%= result.user.full_name %></span>
                        <span class="text-gray-500 mx-2">•</span>
                        <span class="text-gray-600"><%= result.course.title %></span>
                      </div>
                      <div class="flex items-center gap-2">
                        <span class="font-bold text-gray-800"><%= result.final_score %>%</span>
                        <span class={[
                          "px-2 py-1 text-xs rounded-full font-medium",
                          case result.status do
                            status when status in ["passed", "pass"] -> "bg-green-100 text-green-800"
                            status when status in ["failed", "fail"] -> "bg-red-100 text-red-800"
                            _ -> "bg-gray-100 text-gray-800"
                          end
                        ]}>
                          <%= String.capitalize(result.status) %>
                        </span>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>

          <!-- Feedback from Trainers -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-3 flex items-center justify-between">
              <span class="flex items-center">
                <span class="text-2xl mr-2">💬</span>
                FEEDBACK FROM TRAINERS
              </span>
              <.link navigate={~p"/admin/admin_feedback"} class="text-sm text-blue-600 hover:text-blue-800">
                View All
              </.link>
            </h3>

            <%= if Enum.empty?(@feedback_list) do %>
              <div class="text-center py-6">
                <div class="text-gray-400 text-4xl mb-2">📝</div>
                <p class="text-gray-500 text-sm">No feedback yet</p>
              </div>
            <% else %>
              <div class="space-y-3 max-h-64 overflow-y-auto">
                <%= for feedback <- Enum.take(@feedback_list, 3) do %>
                  <div class={["p-3 rounded border-l-4", if(feedback.need_support, do: "border-red-500 bg-red-50", else: "border-green-500 bg-green-50")]}>
                    <div class="flex items-start justify-between mb-2">
                      <p class="font-semibold text-sm"><%= feedback.student.full_name %></p>
                      <%= if feedback.need_support do %>
                        <span class="px-2 py-1 text-xs bg-red-100 text-red-800 rounded-full">⚠️ Support Needed</span>
                      <% end %>
                    </div>
                    <p class="text-xs text-gray-600 mb-1"><%= feedback.course.title %></p>
                    <p class="text-sm text-gray-800 line-clamp-2"><%= String.slice(feedback.feedback, 0, 80) %><%= if String.length(feedback.feedback) > 80, do: "..." %></p>
                    <p class="text-xs text-gray-500 mt-2">
                      <%= Calendar.strftime(feedback.inserted_at, "%d %B %Y") %>
                    </p>
                  </div>
                <% end %>
              </div>

              <%= if length(@urgent_feedback) > 0 do %>
                <div class="mt-3 p-2 bg-red-50 border border-red-200 rounded">
                  <p class="text-sm font-medium text-red-800">
                    ⚠️ <%= length(@urgent_feedback) %> student(s) need support
                  </p>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>

      <!-- Video Modal -->
      <%= if @show_video_modal and @selected_video do %>
        <div
          class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50"
          phx-click="close_video"
          phx-window-keydown="close_video"
          phx-key="Escape"
        >
          <div
            class="bg-white rounded-lg shadow-xl max-w-4xl w-full mx-4 max-h-[90vh] overflow-hidden"
            role="dialog"
            aria-modal="true"
            aria-labelledby="modal-title"
            onclick="event.stopPropagation()"
          >
            <!-- Modal Header -->
            <div class="flex items-center justify-between p-4 border-b">
              <h3 id="modal-title" class="text-lg font-semibold text-gray-900">
                <%= @selected_video.title %>
              </h3>
              <button
                phx-click="close_modal_button"
                type="button"
                class="text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-full p-2 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
                <span class="sr-only">Close modal</span>
              </button>
            </div>

            <!-- Modal Body -->
            <div class="p-4">
              <div class="aspect-video bg-gray-100 rounded-lg overflow-hidden">
                <%= case @selected_video.platform do %>
                  <% "facebook" -> %>
                    <iframe
                      src={"https://www.facebook.com/plugins/video.php?href=#{URI.encode(@selected_video.url)}&show_text=false&width=560"}
                      width="100%"
                      height="100%"
                      style="border:none;overflow:hidden"
                      scrolling="no"
                      frameborder="0"
                      allowfullscreen="true">
                    </iframe>
                  <% "youtube" -> %>
                    <iframe
                      src={get_youtube_embed_url(@selected_video.url)}
                      width="100%"
                      height="100%"
                      frameborder="0"
                      allowfullscreen>
                    </iframe>
                  <% "tiktok" -> %>
                    <div class="flex items-center justify-center h-full bg-gray-200">
                      <div class="text-center">
                        <p class="text-gray-600 mb-4">TikTok videos are best viewed directly on the platform</p>
                        <a
                          href={@selected_video.url}
                          target="_blank"
                          class="inline-block px-4 py-2 bg-black text-white rounded-lg hover:bg-gray-800"
                        >
                          🎵 Open TikTok
                        </a>
                      </div>
                    </div>
                  <% "instagram" -> %>
                    <div class="flex items-center justify-center h-full bg-gray-200">
                      <div class="text-center">
                        <p class="text-gray-600 mb-4">Instagram videos are best viewed directly on the platform</p>
                        <a
                          href={@selected_video.url}
                          target="_blank"
                          class="inline-block px-4 py-2 bg-pink-500 text-white rounded-lg hover:bg-pink-600"
                        >
                          📷 Open Instagram
                        </a>
                      </div>
                    </div>
                  <% _ -> %>
                    <div class="flex items-center justify-center h-full bg-gray-200">
                      <div class="text-center">
                        <p class="text-gray-600 mb-4">Click to view the live stream</p>
                        <a
                          href={@selected_video.url}
                          target="_blank"
                          class="inline-block px-4 py-2 bg-[#06A295] text-white rounded-lg hover:bg-[#058a7a]"
                        >
                          📺 Open Live Stream
                        </a>
                      </div>
                    </div>
                <% end %>
              </div>

              <div class="mt-4 flex justify-between items-center">
                <span class="text-sm text-gray-600">
                  Platform:
                  <span class="capitalize font-medium"><%= @selected_video.platform %></span>
                </span>
                <a
                  href={@selected_video.url}
                  target="_blank"
                  class="text-sm text-blue-600 hover:text-blue-800 underline"
                >
                  Open in new tab →
                </a>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Helper functions
  defp get_latest_applications(applications, limit) do
    applications
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
    |> Enum.take(limit)
  end

  # Helper function to calculate result statistics
  defp get_result_statistics(results) do
    total_results = length(results)

    if total_results == 0 do
      %{
        total_results: 0,
        passed_count: 0,
        failed_count: 0,
        pass_rate: 0,
        average_score: 0,
        latest_results: []
      }
    else
      passed_results = Enum.filter(results, &(&1.status in ["passed", "pass"]))
      failed_results = Enum.filter(results, &(&1.status in ["failed", "fail"]))

      passed_count = length(passed_results)
      failed_count = length(failed_results)
      pass_rate = if total_results > 0, do: round(passed_count / total_results * 100), else: 0

      average_score =
        results
        |> Enum.map(& &1.final_score)
        |> Enum.sum()
        |> Kernel./(total_results)
        |> round()

      latest_results = results |> Enum.take(5)

      %{
        total_results: total_results,
        passed_count: passed_count,
        failed_count: failed_count,
        pass_rate: pass_rate,
        average_score: average_score,
        latest_results: latest_results
      }
    end
  end

  # Helper function to convert YouTube URLs to embed format
  defp get_youtube_embed_url(url) do
    cond do
      String.contains?(url, "youtube.com/watch?v=") ->
        video_id = url |> String.split("v=") |> List.last() |> String.split("&") |> List.first()
        "https://www.youtube.com/embed/#{video_id}"

      String.contains?(url, "youtu.be/") ->
        video_id = url |> String.split("/") |> List.last()
        "https://www.youtube.com/embed/#{video_id}"

      true ->
        url
    end
  end

    <div class="min-h-screen w-full bg-[#06A295] text-white p-8">
      <h1 class="text-4xl font-bold mb-4">Admin Dashboard</h1>
      <p>Welcome, admin! Here you can see stats and quick links.</p>
    </div>
    """
  end

end
