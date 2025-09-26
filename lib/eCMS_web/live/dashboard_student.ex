defmodule ECMSWeb.DashboardStudent do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Notifications

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user

    enrollments = Training.list_enrollments_by_student(current_user.id)
                   |> Enum.filter(& &1.course != nil)
    notifications = Notifications.list_notifications_for_student(current_user.id)
    latest_notifications = Notifications.list_notifications_for_student(current_user.id) |> Enum.take(3)
    live_events = Training.list_live_events()
    activities = Training.list_activities()

    # Get upcoming courses (both enrolled and available courses)
    today = Date.utc_today()

    # Get enrolled upcoming courses
    enrolled_upcoming = enrollments
                       |> Enum.filter(fn enrollment ->
                         enrollment.course && Date.compare(enrollment.course.start_date, today) in [:eq, :gt]
                       end)

    # Get all upcoming courses (for students to see what's available)
    all_courses = Training.list_courses()
    available_upcoming = all_courses
                        |> Enum.filter(fn course ->
                          Date.compare(course.start_date, today) in [:eq, :gt]
                        end)
                        |> Enum.map(fn course ->
                          # Check if student is already enrolled
                          is_enrolled = Enum.any?(enrollments, fn enrollment ->
                            enrollment.course_id == course.id
                          end)
                          %{course: course, enrolled: is_enrolled}
                        end)
                        |> Enum.take(3)

    upcoming_courses = if Enum.empty?(enrolled_upcoming), do: available_upcoming, else: enrolled_upcoming

    # Get latest results and certifications for this student
    latest_results = Training.list_results_for_student(current_user.id) |> Enum.take(3)
    certifications = Training.list_certifications_for_student(current_user.id) |> Enum.take(3)

    {:ok,
     socket
     |> assign(:page_title, "Trainee Dashboard")
     |> assign(:enrollments, enrollments)
     |> assign(:notifications, notifications)
     |> assign(:latest_notifications, latest_notifications)
     |> assign(:live_events, live_events)
     |> assign(:activities, activities)
     |> assign(:upcoming_courses, upcoming_courses)
     |> assign(:latest_results, latest_results)
     |> assign(:certifications, certifications)
     |> assign(:show_video_modal, false)
     |> assign(:selected_video, nil)}
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
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen w-full bg-[#06A295] text-white p-6 font-sans">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-4xl font-bold mb-2">Trainee Dashboard</h1>
        <p class="text-xl opacity-90">
          Welcome back, <%= @current_user && @current_user.full_name || "trainee" %>! 👋 Here's your overview.
        </p>
      </div>

      <!-- Stats Cards -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div class="bg-white text-black p-6 rounded-lg shadow-lg">
          <div class="flex items-center">
            <div class="text-3xl mr-4">📚</div>
            <div>
              <p class="text-2xl font-bold"><%= length(@enrollments) %></p>
              <p class="text-gray-600">Active Enrollments</p>
            </div>
          </div>
        </div>

        <div class="bg-white text-black p-6 rounded-lg shadow-lg">
          <div class="flex items-center">
            <div class="text-3xl mr-4">📅</div>
            <div>
              <p class="text-2xl font-bold"><%= length(@upcoming_courses) %></p>
              <p class="text-gray-600">Upcoming Courses</p>
            </div>
          </div>
        </div>

        <div class="bg-white text-black p-6 rounded-lg shadow-lg">
          <div class="flex items-center">
            <div class="text-3xl mr-4">🏆</div>
            <div>
              <p class="text-2xl font-bold"><%= length(@latest_results) %></p>
              <p class="text-gray-600">Recent Results</p>
            </div>
          </div>
        </div>

        <div class="bg-white text-black p-6 rounded-lg shadow-lg">
          <div class="flex items-center">
            <div class="text-3xl mr-4">🎓</div>
            <div>
              <p class="text-2xl font-bold"><%= length(@certifications) %></p>
              <p class="text-gray-600">Certifications</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Content Grid -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <!-- Left Side - 2 columns -->
        <div class="lg:col-span-2 space-y-6">
          <!-- Upcoming Courses -->
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h2 class="text-2xl font-bold mb-4 flex items-center">
              <span class="text-3xl mr-3">📅</span>
              Upcoming Courses
            </h2>
            <%= if @upcoming_courses == [] do %>
              <div class="text-center py-8 text-gray-500">
                <div class="text-6xl mb-4">📅</div>
                <p class="text-lg">No upcoming courses</p>
                <p class="text-sm">Check back for new course schedules</p>
              </div>
            <% else %>
              <div class="space-y-4">
                <%= for item <- @upcoming_courses do %>
                  <%
                    # Handle both enrolled courses and available courses
                    {course, is_enrolled} = case item do
                      %{course: course, enrolled: enrolled} -> {course, enrolled}
                      enrollment -> {enrollment.course, true}
                    end
                  %>
                  <div class={[
                    "border-l-4 pl-4 py-3 rounded-r-lg",
                    if(is_enrolled, do: "border-green-500 bg-green-50", else: "border-blue-500 bg-blue-50")
                  ]}>
                    <div class="flex items-start justify-between">
                      <div class="flex-1">
                        <h3 class="text-lg font-semibold text-gray-800"><%= course.title %></h3>
                        <div class="text-sm text-gray-600 mt-1">
                          <p>📍 Venue: <%= course.venue || "TBA" %></p>
                          <p>📅 Starts: <%= Calendar.strftime(course.start_date, "%d %B %Y") %></p>
                          <p>🏁 Ends: <%= Calendar.strftime(course.end_date || course.start_date, "%d %B %Y") %></p>
                        </div>
                      </div>
                      <div class="flex flex-col items-end gap-2">
                        <div class={[
                          "text-xs px-2 py-1 rounded-full font-medium",
                          if(is_enrolled, do: "bg-green-100 text-green-800", else: "bg-blue-100 text-blue-800")
                        ]}>
                          <%= Date.diff(course.start_date, Date.utc_today()) %> days to go
                        </div>
                        <div class={[
                          "text-xs px-2 py-1 rounded-full font-medium",
                          if(is_enrolled, do: "bg-green-200 text-green-900", else: "bg-gray-200 text-gray-700")
                        ]}>
                          <%= if(is_enrolled, do: "✓ Enrolled", else: "Available") %>
                        </div>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <!-- My Enrollments with Progress Bars -->
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h2 class="text-2xl font-bold mb-4 flex items-center">
              <span class="text-3xl mr-3">📚</span>
              My Course Progress
            </h2>
            <%= if @enrollments == [] do %>
              <div class="text-center py-8 text-gray-500">
                <div class="text-6xl mb-4">📚</div>
                <p class="text-lg">No active enrollments</p>
                <p class="text-sm">Start your learning journey today!</p>
              </div>
            <% else %>
              <div class="space-y-4">
                <%= for enrollment <- @enrollments do %>
                  <div class="border border-gray-200 rounded-lg p-4">
                    <div class="flex items-start justify-between">
                      <div>
                        <h3 class="text-lg font-semibold text-gray-800"><%= enrollment.course.title %></h3>
                        <p class="text-sm text-gray-600">Milestone: <%= enrollment.milestone || "-" %></p>
                      </div>
                      <div class="text-sm text-gray-600">
                        <p>📅 <%= Calendar.strftime(enrollment.course.start_date, "%d %b %Y") %> - <%= Calendar.strftime(enrollment.course.end_date, "%d %b %Y") %></p>
                        <p>📍 <%= enrollment.course.venue || "TBA" %></p>
                      </div>
                    </div>
                    <div class="mt-3">
                      <div class="flex justify-between text-sm text-gray-600">
                        <span>Progress</span>
                        <span><%= enrollment.progress || 0 %>%</span>
                      </div>
                      <div class="w-full bg-gray-200 rounded-full h-2 mt-1">
                        <div class="bg-[#06A295] h-2 rounded-full" style={"width: #{enrollment.progress || 0}%"}></div>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>

          <!-- Latest Results -->
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h2 class="text-2xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">🏆</span>
              Latest Results
            </h2>
            <%= if @latest_results == [] do %>
              <div class="text-center py-6 text-gray-500">
                <div class="text-4xl mb-2">🏆</div>
                <p>No results yet</p>
              </div>
            <% else %>
              <div class="space-y-3">
                <%= for result <- @latest_results do %>
                  <div class="border border-gray-200 rounded-lg p-3">
                    <h4 class="font-semibold text-gray-800"><%= result.course.title %></h4>
                    <div class="flex justify-between items-center mt-2">
                      <div class="text-sm text-gray-600">
                        Score: <span class="font-bold text-lg text-green-600"><%= result.final_score %>%</span>
                      </div>
                      <span class={[
                        "px-2 py-1 text-xs rounded-full font-medium",
                        case result.status do
                          "passed" -> "bg-green-100 text-green-800"
                          "failed" -> "bg-red-100 text-red-800"
                          _ -> "bg-yellow-100 text-yellow-800"
                        end
                      ]}>
                        <%= String.capitalize(result.status) %>
                      </span>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>

        <!-- Right Side - 1 column -->
        <div class="space-y-6">
          <!-- Live Events -->
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h2 class="text-xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">🎥</span>
              Live Events
            </h2>
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
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h2 class="text-xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">📋</span>
              Activity
            </h2>
            <%= if @activities == [] do %>
              <div class="text-center py-6 text-gray-500">
                <div class="text-4xl mb-2">📋</div>
                <p>No recent activities</p>
              </div>
            <% else %>
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
            <% end %>
          </div>

          <!-- Latest Notifications -->
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h2 class="text-xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">🔔</span>
              Latest Notifications
            </h2>
            <%= if @latest_notifications == [] do %>
              <div class="text-center py-6 text-gray-500">
                <div class="text-4xl mb-2">🔔</div>
                <p>No notifications yet</p>
              </div>
            <% else %>
              <div class="space-y-3">
                <%= for notification <- @latest_notifications do %>
                  <div class={[
                    "border-l-4 pl-3 py-2 rounded-r-lg",
                    if(notification.read, do: "border-gray-300 bg-gray-50", else: "border-blue-500 bg-blue-50")
                  ]}>
                    <div class="flex items-start justify-between">
                      <div class="flex-1">
                        <p class="font-semibold text-sm mb-1 text-gray-800"><%= notification.message %></p>
                        <%= if notification.course_application && notification.course_application.course do %>
                          <p class="text-xs text-gray-600 mb-1">
                            Course: <span class="font-medium"><%= notification.course_application.course.title %></span>
                          </p>
                        <% end %>
                        <%= if notification.start_date do %>
                          <p class="text-xs text-gray-600 mb-1">
                            📅 <%= Calendar.strftime(notification.start_date, "%d %b %Y") %>
                            <%= if notification.end_date do %>
                              - <%= Calendar.strftime(notification.end_date, "%d %b %Y") %>
                            <% end %>
                          </p>
                        <% end %>
                        <%= if notification.venue do %>
                          <p class="text-xs text-gray-600">
                            📍 <%= notification.venue %>
                          </p>
                        <% end %>
                        <p class="text-xs text-gray-500 mt-1">
                          <%= Calendar.strftime(notification.inserted_at, "%d %b %Y at %H:%M") %>
                        </p>
                      </div>
                      <%= if not notification.read do %>
                        <div class="ml-2">
                          <span class="inline-block w-2 h-2 bg-blue-500 rounded-full"></span>
                        </div>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
              <div class="mt-4 text-center">
                <a href="/student/student_notifications" class="text-sm text-blue-600 hover:text-blue-800 font-medium">
                  View All Notifications →
                </a>
              </div>
            <% end %>
          </div>

          <!-- Certifications -->
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h2 class="text-xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">🎓</span>
              My Certifications
            </h2>
            <%= if @certifications == [] do %>
              <div class="text-center py-6 text-gray-500">
                <div class="text-4xl mb-2">🎓</div>
                <p>No certifications yet</p>
              </div>
            <% else %>
              <div class="space-y-3">
                <%= for cert <- @certifications do %>
                  <div class="border border-gray-200 rounded-lg p-3 bg-gradient-to-r from-yellow-50 to-yellow-100">
                    <div class="flex items-start justify-between">
                      <div>
                        <h4 class="font-semibold text-gray-800"><%= cert.course.title %></h4>
                        <%= if cert.certificate_url do %>
                          <a href={cert.certificate_url} target="_blank" class="text-sm text-blue-600 hover:text-blue-800 font-medium">
                            📄 View Certificate
                          </a>
                        <% else %>
                          <p class="text-sm text-gray-600">Certificate: Pending</p>
                        <% end %>
                        <p class="text-xs text-gray-500 mt-1">
                          Issued: <%= Calendar.strftime(cert.issued_at || cert.inserted_at, "%d %b %Y") %>
                        </p>
                      </div>
                      <div class="text-right">
                        <span class="inline-flex items-center px-2 py-1 text-xs font-medium bg-yellow-100 text-yellow-800 rounded-full">🎖️ Certified</span>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>

      <!-- Video Modal -->
      <%= if @show_video_modal and @selected_video do %>
        <div
          class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
          phx-click="close_video"
          phx-window-keydown="close_video"
          phx-key="Escape"
        >
          <div class="bg-white rounded-lg shadow-xl max-w-4xl w-full mx-4 max-h-[90vh] overflow-hidden" onclick="event.stopPropagation()">
            <!-- Modal Header -->
            <div class="flex items-center justify-between p-4 border-b">
              <h3 class="text-lg font-semibold text-gray-900"><%= @selected_video.title %></h3>
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

            <!-- Modal Content -->
            <div class="p-4">
              <%= case @selected_video.platform do %>
                <% "facebook" -> %>
                  <div class="aspect-video">
                    <iframe
                      src={"https://www.facebook.com/plugins/video.php?href=#{URI.encode(@selected_video.url)}&show_text=false&width=560&height=315"}
                      width="100%"
                      height="100%"
                      style="border:none;overflow:hidden"
                      scrolling="no"
                      frameborder="0"
                      allowtransparency="true"
                      allow="encrypted-media"
                    ></iframe>
                  </div>

                <% "youtube" -> %>
                  <div class="aspect-video">
                    <iframe
                      src={get_youtube_embed_url(@selected_video.url)}
                      width="100%"
                      height="100%"
                      frameborder="0"
                      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                      allowfullscreen
                    ></iframe>
                  </div>

                <% platform when platform in ["tiktok", "instagram"] -> %>
                  <div class="text-center py-8">
                    <p class="text-gray-600 mb-4">This content opens in a new window</p>
                    <a
                      href={@selected_video.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      class="inline-flex items-center px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
                    >
                      Open <%= String.capitalize(platform) %> Video
                      <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"></path>
                      </svg>
                    </a>
                  </div>

                <% _ -> %>
                  <div class="text-center py-8">
                    <p class="text-gray-600 mb-4">Video content</p>
                    <a
                      href={@selected_video.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      class="text-blue-500 hover:text-blue-600"
                    >
                      Open Video Link
                    </a>
                  </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Helper function to convert YouTube URLs to embed format
  defp get_youtube_embed_url(url) do
    cond do
      String.contains?(url, "youtube.com/watch?v=") ->
        video_id = url |> String.split("v=") |> List.last() |> String.split("&") |> List.first()
        "https://www.youtube.com/embed/#{video_id}"

      String.contains?(url, "youtu.be/") ->
        video_id = url |> String.split("/") |> List.last() |> String.split("?") |> List.first()
        "https://www.youtube.com/embed/#{video_id}"

      true ->
        url
    end
  end
end
