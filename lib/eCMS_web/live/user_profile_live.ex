defmodule ECMSWeb.UserProfileLive do
  use ECMSWeb, :live_view

  alias ECMS.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-[#06A295]">
      <div class="flex">
        <!-- Sidebar Menu (role-aware) -->
        <aside class="w-40 bg-[#04675F] text-white hidden md:flex md:flex-col">
          <div class="px-6 py-6 border-b border-gray-700 text-center">
            <img src={~p"/images/logo-cms-5-29.png"} alt="e-CMS" class="w-[120px] h-[80px] rounded p-2 mx-auto object-contain" />
          </div>
          <nav class="flex-1 px-4 py-6 space-y-3">
            <%= case @current_user.role do %>
              <% "admin" -> %>
                <.link navigate={~p"/admin/dashboard_admin"} class="block px-3 py-2 rounded hover:bg-tealLight">Dashboard</.link>
              <% "trainer" -> %>
                <.link navigate={~p"/trainer/dashboard_trainer"} class="block px-3 py-2 rounded hover:bg-tealLight">Dashboard</.link>
              <% _ -> %>
                <.link navigate={~p"/student/dashboard_student"} class="block px-3 py-2 rounded hover:bg-tealLight">Dashboard</.link>
            <% end %>
            <.link navigate={~p"/users/settings"} class="block px-3 py-2 rounded bg-teal-600">Profile</.link>
            <.link navigate={~p"/users/settings"} class="block px-3 py-2 rounded hover:bg-tealLight">Settings</.link>
          </nav>
        </aside>

        <div class="flex-1 p-8">
          <div class="max-w-6xl mx-auto">
          <!-- Main Content Area -->
          <div>
              <div id="profile" class="text-center mb-8">
                <h1 class="text-3xl font-bold text-white mb-2">User Profile</h1>
                <p class="text-white/90">View and manage your personal information</p>
              </div>

              <div class="space-y-8">
                <!-- Profile Picture Section -->
                <div class="flex flex-col items-center space-y-4 p-6">
                  <div class="relative">
                    <%= if @current_user.avatar_url do %>
                      <img src={@current_user.avatar_url} alt="avatar" class="w-32 h-32 rounded-full object-cover border-4 border-white shadow-lg" />
                    <% else %>
                      <div class="w-32 h-32 rounded-full bg-gradient-to-br from-teal-400 to-teal-600 flex items-center justify-center border-4 border-white shadow-lg">
                        <span class="text-white text-4xl font-bold">
                          <%= String.first(String.upcase(@current_user.full_name || "U")) %>
                        </span>
                      </div>
                    <% end %>
                    <button class="absolute bottom-0 right-0 bg-teal-600 hover:bg-teal-700 text-white p-2 rounded-full shadow-lg transition-colors">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                      </svg>
                    </button>
                  </div>
                  <h3 class="text-2xl font-bold text-white"><%= @current_user.full_name %></h3>
                  <span class="px-3 py-1 bg-teal-600 text-white rounded-full text-sm font-medium">
                    <%= String.capitalize(@current_user.role) %>
                  </span>
                </div>

                <!-- Profile Information -->
                <div class="grid md:grid-cols-2 gap-8">
                  <!-- Personal Information -->
                  <div id="personal" class="p-6 space-y-6 bg-[#04675F] rounded-lg">
                    <h4 class="text-lg font-semibold text-white border-b border-white/30 pb-2">
                      Personal Information
                    </h4>

                    <.simple_form
                      for={@profile_form}
                      id="profile_form"
                      phx-submit="update_profile"
                      phx-change="validate_profile"
                      class= "bg-teal-600"
                    >
                      <div class="mb-4">
                        <.live_file_input upload={@uploads.avatar} />
                      </div>
                      <.input field={@profile_form[:full_name]} type="text" label="Full Name" required />
                      <.input field={@profile_form[:email]} type="email" label="Email" readonly />
                      <.input field={@profile_form[:phone]} type="tel" label="Phone Number" />
                      <.input field={@profile_form[:date_of_birth]} type="date" label="Date of Birth" />
                      <.input field={@profile_form[:address]} type="textarea" label="Address" rows="3" />

                      <:actions>
                        <.button class="w-full" phx-disable-with="Updating...">
                          Update Profile
                        </.button>
                      </:actions>
                    </.simple_form>
                  </div>

                  <!-- Account Information -->
                <div id="account" class="p-6 space-y-6 bg-[#04675F] rounded-lg">
                    <h4 class="text-lg font-semibold text-white border-b border-white/30 pb-2">
                      Account Information
                    </h4>

                    <div class="space-y-4">
                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">Role</label>
                        <p class="text-white capitalize font-semibold"><%= @current_user.role %></p>
                      </div>

                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">Member Since</label>
                        <p class="text-white font-semibold">
                          <%= Calendar.strftime(@current_user.inserted_at, "%B %d, %Y") %>
                        </p>
                      </div>

                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">Last Updated</label>
                        <p class="text-white font-semibold">
                          <%= Calendar.strftime(@current_user.updated_at, "%B %d, %Y at %I:%M %p") %>
                        </p>
                      </div>

                      <div class="p-4">
                        <label class="block text-sm font-medium text-black mb-1">Account Status</label>
                        <div class="flex items-center space-x-2">
                          <%= if @current_user.confirmed_at do %>
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                              <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
                              </svg>
                              Verified
                            </span>
                          <% else %>
                            <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                              <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                                <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                              </svg>
                              Pending Verification
                            </span>
                          <% end %>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                </div>

                <!-- Activity Summary (Role-specific) -->
                <div id="activity" class="mt-8">
                  <h4 class="text-lg font-semibold text-black border-b border-gray-300 pb-2 mb-6">
                    Activity Summary
                  </h4>

                  <%= case @current_user.role do %>
                    <% "admin" -> %>
                      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-blue-500 shadow-lg flex items-center justify-center hover:bg-blue-600 transition-colors">
                            <div class="text-4xl">👥</div>
                          </div>
                          <p class="mt-3 text-sm text-black">Total Users</p>
                          <p class="text-xl font-bold text-black"><%= @stats.total_users || 0 %></p>
                        </div>

                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-green-500 shadow-lg flex items-center justify-center hover:bg-green-600 transition-colors">
                            <div class="text-4xl">📚</div>
                          </div>
                          <p class="mt-3 text-sm text-black">Total Courses</p>
                          <p class="text-xl font-bold text-black"><%= @stats.total_courses || 0 %></p>
                        </div>

                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-purple-500 shadow-lg flex items-center justify-center hover:bg-purple-600 transition-colors">
                            <div class="text-4xl">📋</div>
                          </div>
                          <p class="mt-3 text-sm text-black">Applications</p>
                          <p class="text-xl font-bold text-black"><%= @stats.total_applications || 0 %></p>
                        </div>
                      </div>

                    <% "trainer" -> %>
                      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-teal-500 shadow-lg flex items-center justify-center hover:bg-teal-600 transition-colors">
                            <div class="text-4xl">🎓</div>
                          </div>
                          <p class="mt-3 text-sm text-black">My Courses</p>
                          <p class="text-xl font-bold text-black"><%= @stats.my_courses || 0 %></p>
                        </div>

                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-orange-500 shadow-lg flex items-center justify-center hover:bg-orange-600 transition-colors">
                            <div class="text-4xl">👨‍🎓</div>
                          </div>
                          <p class="mt-3 text-sm text-black">Students</p>
                          <p class="text-xl font-bold text-black"><%= @stats.my_students || 0 %></p>
                        </div>

                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-indigo-500 shadow-lg flex items-center justify-center hover:bg-indigo-600 transition-colors">
                            <div class="text-4xl">📝</div>
                          </div>
                          <p class="mt-3 text-sm text-black">Feedback Given</p>
                          <p class="text-xl font-bold text-black"><%= @stats.feedback_given || 0 %></p>
                        </div>
                      </div>

                    <% "student" -> %>
                      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-pink-500 shadow-lg flex items-center justify-center hover:bg-pink-600 transition-colors">
                            <div class="text-4xl">📖</div>
                          </div>
                          <p class="mt-3 text-sm text-black">Enrolled Courses</p>
                          <p class="text-xl font-bold text-black"><%= @stats.enrolled_courses || 0 %></p>
                        </div>

                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-cyan-500 shadow-lg flex items-center justify-center hover:bg-cyan-600 transition-colors">
                            <div class="text-4xl">🏆</div>
                          </div>
                          <p class="mt-3 text-sm text-black">Certificates</p>
                          <p class="text-xl font-bold text-black"><%= @stats.certificates || 0 %></p>
                        </div>

                        <div class="flex flex-col items-center">
                          <div class="w-24 h-32 rounded-lg bg-amber-500 shadow-lg flex items-center justify-center hover:bg-amber-600 transition-colors">
                            <div class="text-4xl">⭐</div>
                          </div>
                          <p class="mt-3 text-sm text-black">Average Score</p>
                          <p class="text-xl font-bold text-black"><%= @stats.average_score || "N/A" %></p>
                        </div>
                      </div>

                    <% _ -> %>
                      <div class="text-center py-8 text-gray-500">
                        <p>No activity data available</p>
                      </div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profile_changeset = Accounts.change_user_profile(user)
    stats = get_user_stats(user)

    socket =
      socket
      |> allow_upload(:avatar,
        accept: ~w(.jpg .jpeg .png),
        max_entries: 1,
        max_file_size: 2_000_000
      )
      |> assign(:profile_form, to_form(profile_changeset))
      |> assign(:stats, stats)

    {:ok, socket}
  end

  def handle_event("validate_profile", %{"user" => user_params}, socket) do
    profile_form =
      socket.assigns.current_user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, profile_form: profile_form)}
  end

  def handle_event("update_profile", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        original = entry.client_name || Path.basename(path)
        unique = Integer.to_string(System.system_time(:millisecond)) <> "-" <> original
        dest = Path.join(["priv/static/uploads", unique])
        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        {:ok, "/uploads/" <> unique}
      end)

    user_params =
      case uploaded_files do
        [avatar_url | _] -> Map.put(user_params, "avatar_url", avatar_url)
        _ -> user_params
      end

    case Accounts.update_user_profile(user, user_params) do
      {:ok, updated_user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profile updated successfully")
         |> assign(:current_user, updated_user)
         |> assign(:profile_form, to_form(Accounts.change_user_profile(updated_user)))}

      {:error, changeset} ->
        {:noreply, assign(socket, :profile_form, to_form(changeset))}
    end
  end

  defp get_user_stats(user) do
    case user.role do
      "admin" ->
        %{
          total_users: ECMS.Accounts.count_users(),
          total_courses: ECMS.Courses.count_courses(),
          total_applications: ECMS.Courses.count_applications()
        }

      "trainer" ->
        %{
          my_courses: ECMS.Courses.count_courses_by_trainer(user.id),
          my_students: ECMS.Training.count_students_by_trainer(user.id),
          feedback_given: ECMS.Training.count_feedback_by_trainer(user.id)
        }

      "student" ->
        %{
          enrolled_courses: ECMS.Training.count_enrollments_by_student(user.id),
          certificates: ECMS.Training.count_certifications_by_student(user.id),
          average_score: ECMS.Training.get_average_score_by_student(user.id)
        }

      _ ->
        %{}
    end
  end
end
