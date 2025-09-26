defmodule ECMSWeb.DashboardTrainer do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Courses
  alias ECMS.Accounts

  @impl true
  def mount(_params, _session, socket) do
    # Get statistics for trainer dashboard
    trainees = Accounts.list_users_by_role("student")
    courses = Courses.list_all_courses()
    applications = Courses.list_applications()
    live_events = Training.list_live_events()
    activities = Training.list_activities()

    # Get latest data (removed applications - moved to admin dashboard)
    latest_enrollments = Training.list_enrollments()
                         |> Enum.filter(& &1.course != nil)
                         |> Enum.take(3)
    all_results = Training.list_results()
    result_stats = get_result_statistics(all_results)
    latest_schedules = Training.list_schedules()
                     |> Enum.map(&ECMS.Repo.preload(&1, :course))
                     |> Enum.take(3)
    latest_feedback = Training.list_feedback() |> Enum.take(3)

    {:ok,
     assign(socket,
       page_title: "Trainer Dashboard",
       trainee_count: length(trainees),
       course_count: length(courses),
       application_count: length(applications.entries),
       live_events: live_events,
       activities: activities,
       latest_enrollments: latest_enrollments,
       result_stats: result_stats,
       latest_schedules: latest_schedules,
       latest_feedback: latest_feedback,
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
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#06A295] text-white p-6 font-sans">
      <!-- Header -->
      <div class="mb-6">
        <h1 class="text-3xl font-bold mb-2">Trainer Dashboard</h1>
        <p class="text-xl opacity-90">
          Welcome back, <%= @current_user && @current_user.full_name || "trainer" %>! 👋 Here's your overview.
        </p>
      </div>

      <!-- Statistics Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <%= for {label, count, icon} <- [
              {"Trainees", @trainee_count, "👨‍🎓"},
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

          <!-- Latest Schedules -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-3 flex items-center">
              <span class="text-2xl mr-2">📅</span>
              Latest Schedules
            </h3>
            <div class="space-y-3">
              <%= for schedule <- @latest_schedules do %>
                <div class="border-l-4 border-green-500 pl-3 py-2">
                  <p class="font-semibold text-sm mb-1"><%= schedule.course.title %></p>
                  <p class="text-xs text-gray-500 mb-1">Venue: <%= schedule.venue || "TBA" %></p>
                  <p class="text-xs text-gray-600">
                    <span class="inline-block w-2 h-2 bg-green-500 rounded-full mr-2"></span>
                    <%= Calendar.strftime(schedule.schedule_date, "%d %B %Y") %> @ <%= Calendar.strftime(schedule.schedule_time, "%H:%M") %>
                  </p>
                  <p class="text-xs text-gray-500">
                    Status: <span class="capitalize text-green-600"><%= schedule.status %></span>
                  </p>
                </div>
              <% end %>
            </div>
          </div>

          <!-- Latest Enrollments -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-2 flex items-center">
              <span class="text-2xl mr-2">📚</span>
              Latest Enrollments
            </h3>
            <table class="w-full text-sm">
              <thead>
                <tr class="font-bold border-b">
                  <th class="text-left py-1">Student</th>
                  <th class="text-left py-1">Course</th>
                  <th class="text-left py-1">Progress</th>
                  <th class="text-left py-1">Status</th>
                </tr>
              </thead>
              <tbody>
                <%= for enrollment <- @latest_enrollments do %>
                  <tr>
                    <td><%= enrollment.user.full_name %></td>
                    <td><%= if enrollment.course, do: enrollment.course.title, else: "Course not found" %></td>
                    <td>
                      <div class="w-full bg-gray-200 rounded-full h-2">
                        <div class="bg-[#06A295] h-2 rounded-full" style={"width: #{enrollment.progress}%"}></div>
                      </div>
                      <span class="text-xs text-gray-600"><%= enrollment.progress %>%</span>
                    </td>
                    <td>
                      <span class={["px-2 py-1 text-xs rounded-full",
                        case enrollment.status do
                          "completed" -> "bg-green-100 text-green-800"
                          "in_progress" -> "bg-blue-100 text-blue-800"
                          _ -> "bg-gray-100 text-gray-800"
                        end
                      ]}>
                        <%= String.capitalize(enrollment.status) %>
                      </span>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
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
          <div class="bg-white text-black p-6 rounded-lg shadow-lg">
            <h3 class="text-xl font-bold mb-4 flex items-center">
              <span class="text-2xl mr-2">📋</span>
              Activity
            </h3>
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

          <!-- Latest Feedback -->
          <div class="bg-white text-black p-4 rounded shadow">
            <h3 class="text-lg font-semibold mb-3 flex items-center">
              <span class="text-2xl mr-2">💬</span>
              Latest Feedback
            </h3>
            <div class="space-y-3">
              <%= for feedback <- @latest_feedback do %>
                <div class={["p-3 rounded border-l-4", if(feedback.need_support, do: "border-red-500 bg-red-50", else: "border-blue-500 bg-blue-50")]}>
                  <p class="font-semibold text-sm"><%= feedback.student.full_name %></p>
                  <p class="text-xs text-gray-600 mb-1"><%= feedback.course.title %></p>
                  <p class="text-sm text-gray-800 line-clamp-2"><%= String.slice(feedback.feedback, 0, 50) %><%= if String.length(feedback.feedback) > 50, do: "..." %></p>
                  <%= if feedback.need_support do %>
                    <span class="text-xs text-red-600 font-medium">⚠️ Support needed</span>
                  <% end %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>

      <!-- Video Modal (same as admin dashboard) -->
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
end
