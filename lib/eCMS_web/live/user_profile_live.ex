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
                    <button
                      phx-click="open_camera_modal"
                      class="absolute bottom-0 right-0 bg-teal-600 hover:bg-teal-700 text-white p-2 rounded-full shadow-lg transition-colors"
                      title="Capture Face"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                    </button>
                  </div>
                  <div class="flex gap-2">
                    <button
                      phx-click="open_camera_modal"
                      class="bg-teal-600 hover:bg-teal-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors flex items-center gap-2"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                      </svg>
                      Capture Face
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
                    <div class="flex justify-between items-center border-b border-white/30 pb-2">
                      <h4 class="text-lg font-semibold text-white">
                        Personal Information
                      </h4>
                      <button
                        phx-click="open_profile_modal"
                        class="bg-teal-600 hover:bg-teal-700 text-white font-semibold py-2 px-4 rounded-lg transition-colors flex items-center gap-2"
                      >
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                        Update Profile
                      </button>
                    </div>

                    <div class="space-y-4 mt-4">
                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">Full Name</label>
                        <p class="text-white font-semibold"><%= @current_user.full_name || "N/A" %></p>
                      </div>

                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">Email</label>
                        <p class="text-white font-semibold"><%= @current_user.email %></p>
                      </div>

                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">Phone Number</label>
                        <p class="text-white font-semibold"><%= @current_user.phone || "N/A" %></p>
                      </div>

                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">IC Number</label>
                        <p class="text-white font-semibold"><%= @current_user.ic_number || "N/A" %></p>
                      </div>

                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">Date of Birth</label>
                        <p class="text-white font-semibold">
                          <%= if @current_user.date_of_birth do %>
                            <%= Calendar.strftime(@current_user.date_of_birth, "%B %d, %Y") %>
                          <% else %>
                            N/A
                          <% end %>
                        </p>
                      </div>

                      <div class="p-4">
                        <label class="block text-sm font-medium text-white mb-1">Address</label>
                        <p class="text-white font-semibold"><%= @current_user.address || "N/A" %></p>
                      </div>
                    </div>
                  </div>

                  <!-- Account Information -->
                <div id="account" class="p-6 space-y-6 bg-[#04675F] rounded-lg">
                    <h4 class="text-lg font-semibold text-white border-b border-white/30 pb-2">
                      Account Information
                    </h4>

                    <!-- Student Card Section (for students only) -->
                    <%= if @current_user.role == "student" do %>
                      <div class="mb-6 pb-6 border-b border-white/30">
                        <div class="flex justify-center">
                          <%= render_student_card(assigns) %>
                        </div>
                        <div class="flex justify-center mt-4">
                          <button
                            onclick="printStudentCard()"
                            class="bg-teal-600 hover:bg-teal-700 text-white font-semibold py-2 px-6 rounded-lg transition-colors flex items-center gap-2"
                          >
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                            </svg>
                            Print Card
                          </button>
                        </div>
                        <p class="text-sm text-white/80 text-center mt-4">
                          Click the card to flip and view QR code.
                        </p>
                      </div>
                    <% end %>

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

      <!-- Camera Capture Modal -->
      <%= if assigns[:show_camera_modal] do %>
        <div id="camera-modal" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-75" phx-click="close_camera_modal" phx-hook="CameraCapture">
          <div class="bg-white rounded-lg shadow-xl p-6 max-w-md w-full mx-4" phx-click="stop_propagation">
            <div class="flex justify-between items-center mb-4">
              <h3 class="text-xl font-semibold text-gray-900">Capture Your Face</h3>
              <button
                phx-click="close_camera_modal"
                class="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <div class="mb-4">
              <video id="camera-video" autoplay playsinline class="w-full rounded-lg bg-black" style="max-height: 400px;"></video>
              <canvas id="camera-canvas" style="display: none;"></canvas>
            </div>

            <div class="flex gap-2 justify-center">
              <button
                id="capture-btn"
                class="bg-teal-600 hover:bg-teal-700 text-white font-semibold py-2 px-6 rounded-lg transition-colors flex items-center gap-2"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                Capture Photo
              </button>
              <button
                phx-click="close_camera_modal"
                class="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-6 rounded-lg transition-colors"
              >
                Cancel
              </button>
            </div>

            <div id="capture-preview" class="hidden mt-4">
              <p class="text-sm text-gray-600 mb-2">Preview:</p>
              <img id="preview-image" class="w-full rounded-lg" />
              <div class="flex gap-2 justify-center mt-4">
                <button
                  id="save-capture-btn"
                  phx-click="save_captured_face"
                  class="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-6 rounded-lg transition-colors"
                >
                  Save as Profile Picture
                </button>
                <button
                  id="retake-btn"
                  class="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-6 rounded-lg transition-colors"
                >
                  Retake
                </button>
              </div>
            </div>
          </div>
        </div>
      <% end %>

      <!-- Profile Update Modal -->
      <%= if assigns[:show_profile_modal] do %>
        <div id="profile-modal" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-75" phx-click="close_profile_modal">
          <div class="bg-white rounded-lg shadow-xl p-6 max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto" phx-click="stop_propagation">
            <div class="flex justify-between items-center mb-4">
              <h3 class="text-xl font-semibold text-gray-900">Update Profile</h3>
              <button
                phx-click="close_profile_modal"
                class="text-gray-400 hover:text-gray-600 transition-colors"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>

            <.simple_form
              for={@profile_form}
              id="profile_form"
              phx-submit="update_profile"
              phx-change="validate_profile"
            >
              <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 mb-2">Profile Picture</label>
                <.live_file_input upload={@uploads.avatar} />
              </div>
              <.input field={@profile_form[:full_name]} type="text" label="Full Name" required />
              <.input field={@profile_form[:email]} type="email" label="Email" readonly />
              <.input field={@profile_form[:phone]} type="tel" label="Phone Number" />
              <.input field={@profile_form[:ic_number]} type="text" label="IC Number" />
              <.input field={@profile_form[:date_of_birth]} type="date" label="Date of Birth" />
              <.input field={@profile_form[:address]} type="textarea" label="Address" rows="3" />

              <:actions>
                <div class="flex gap-2 justify-end">
                  <button
                    type="button"
                    phx-click="close_profile_modal"
                    class="bg-gray-600 hover:bg-gray-700 text-white font-semibold py-2 px-6 rounded-lg transition-colors"
                  >
                    Cancel
                  </button>
                  <.button phx-disable-with="Updating...">
                    Save Changes
                  </.button>
                </div>
              </:actions>
            </.simple_form>
          </div>
        </div>
      <% end %>
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
      |> assign(:show_camera_modal, false)
      |> assign(:captured_image_data, nil)
      |> assign(:show_profile_modal, false)

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
         |> assign(:profile_form, to_form(Accounts.change_user_profile(updated_user)))
         |> assign(:show_profile_modal, false)}

      {:error, changeset} ->
        {:noreply, assign(socket, :profile_form, to_form(changeset))}
    end
  end

  def handle_event("open_camera_modal", _params, socket) do
    {:noreply, assign(socket, :show_camera_modal, true)}
  end

  def handle_event("close_camera_modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_camera_modal, false)
     |> assign(:captured_image_data, nil)}
  end

  def handle_event("stop_propagation", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("open_profile_modal", _params, socket) do
    {:noreply, assign(socket, :show_profile_modal, true)}
  end

  def handle_event("close_profile_modal", _params, socket) do
    {:noreply, assign(socket, :show_profile_modal, false)}
  end

  def handle_event("save_captured_face", %{"image_data" => image_data}, socket) do
    user = socket.assigns.current_user

    # Decode base64 image data
    case decode_base64_image(image_data) do
      {:ok, image_binary, extension} ->
        # Save the image
        unique = Integer.to_string(System.system_time(:millisecond)) <> "-capture." <> extension
        dest = Path.join(["priv/static/uploads", unique])
        File.mkdir_p!(Path.dirname(dest))
        File.write!(dest, image_binary)

        avatar_url = "/uploads/" <> unique

        # Update user profile
        user_params = %{"avatar_url" => avatar_url}

        case Accounts.update_user_profile(user, user_params) do
          {:ok, updated_user} ->
            {:noreply,
             socket
             |> put_flash(:info, "Profile picture updated successfully")
             |> assign(:current_user, updated_user)
             |> assign(:show_camera_modal, false)
             |> assign(:captured_image_data, nil)
             |> assign(:profile_form, to_form(Accounts.change_user_profile(updated_user)))}

          {:error, changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "Failed to update profile picture")
             |> assign(:profile_form, to_form(changeset))}
        end

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to process image: #{reason}")
         |> assign(:show_camera_modal, false)}
    end
  end

  def handle_event("save_captured_face", _params, socket) do
    # Fallback if image_data is not provided
    {:noreply,
     socket
     |> put_flash(:error, "No image data received")
     |> assign(:show_camera_modal, false)}
  end

  defp decode_base64_image(data_url) do
    try do
      # Remove data URL prefix (e.g., "data:image/jpeg;base64,")
      base64_data = String.replace(data_url, ~r/^data:image\/[^;]+;base64,/, "")

      # Decode base64
      image_binary = Base.decode64!(base64_data)

      # Determine extension from data URL
      extension =
        cond do
          String.contains?(data_url, "image/jpeg") or String.contains?(data_url, "image/jpg") ->
            "jpg"
          String.contains?(data_url, "image/png") -> "png"
          true -> "jpg"
        end

      {:ok, image_binary, extension}
    rescue
      e -> {:error, "Invalid image data: #{inspect(e)}"}
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

  defp render_student_card(assigns) do
    assigns =
      assigns
      |> assign(:user, assigns.current_user)
      |> assign(:qr_data, "STUDENT_ID:#{assigns.current_user.id}")

    ~H"""
    <!-- Student Card Container -->
    <div class="student-card-container" style="perspective: 1000px;">
      <div id="student-card-profile" class="student-card" style="width: 200px; height: 320px; position: relative; transform-style: preserve-3d; transition: transform 0.6s; cursor: pointer;">
        <!-- Front of Card -->
        <div class="student-card-front absolute inset-0 w-full h-full bg-white rounded shadow-2xl overflow-hidden" style="backface-visibility: hidden; border: 1px solid #e5e7eb;">
          <!-- Background Pattern -->
          <div class="absolute inset-0 opacity-5" style="background-image: repeating-linear-gradient(45deg, transparent, transparent 10px, rgba(6, 162, 149, 0.1) 10px, rgba(6, 162, 149, 0.1) 20px);"></div>

          <!-- Header Section -->
          <div class="bg-gradient-to-r from-teal-600 to-teal-700 h-12 flex flex-col items-center justify-center px-3 relative">
            <div class="flex items-center gap-2 mb-0.5">
              <img src={~p"/images/logo-cms-5-29.png"} alt="Logo" class="h-5 w-5 object-contain" />
              <h3 class="text-white text-[10px] font-bold uppercase tracking-wide">e-CMS</h3>
            </div>
            <p class="text-teal-100 text-[6px] text-center">STUDENT IDENTIFICATION CARD</p>
            <div class="absolute top-1 right-2">
              <span class="text-white text-[6px] font-semibold">VALID</span>
            </div>
          </div>

          <!-- Main Content - Vertical Layout -->
          <div class="p-3 flex flex-col items-center gap-2" style="height: calc(100% - 4rem);">
            <!-- Student Photo -->
            <div class="flex-shrink-0">
              <%= if @user.avatar_url do %>
                <img src={@user.avatar_url} alt="Student Photo" class="w-24 h-28 object-cover border-2 border-gray-300 shadow-md rounded" />
              <% else %>
                <div class="w-24 h-28 bg-gradient-to-br from-teal-400 to-teal-600 flex items-center justify-center border-2 border-gray-300 shadow-md rounded">
                  <span class="text-white text-3xl font-bold">
                    <%= String.first(String.upcase(@user.full_name || "S")) %>
                  </span>
                </div>
              <% end %>
            </div>

            <!-- Student Info -->
            <div class="flex-1 flex flex-col justify-center w-full space-y-1.5 overflow-y-auto">
              <div>
                <p class="text-[7px] text-gray-500 uppercase tracking-wide mb-0.5 text-center">Name</p>
                <h2 class="text-xs font-bold text-gray-900 leading-tight text-center break-words"><%= @user.full_name %></h2>
              </div>
              <div>
                <p class="text-[7px] text-gray-500 uppercase tracking-wide mb-0.5 text-center">IC Number</p>
                <p class="text-[10px] font-semibold text-gray-800 text-center"><%= @user.ic_number || "N/A" %></p>
              </div>
              <div class="mt-1.5 pt-1.5 border-t border-gray-200">
                <p class="text-[7px] text-gray-500 uppercase tracking-wide mb-0.5 text-center">Student ID</p>
                <p class="text-[10px] font-mono font-semibold text-teal-700 text-center">#<%= @user.id %></p>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="absolute bottom-0 left-0 right-0 h-3 bg-gradient-to-r from-teal-600 to-teal-700 flex items-center justify-center">
            <p class="text-white text-[5px] font-semibold">Authorized Signature</p>
          </div>
        </div>

        <!-- Back of Card -->
        <div class="student-card-back absolute inset-0 w-full h-full bg-white rounded shadow-2xl overflow-hidden" style="backface-visibility: hidden; transform: rotateY(180deg); border: 1px solid #e5e7eb;">
          <!-- Background Pattern -->
          <div class="absolute inset-0 opacity-5" style="background-image: repeating-linear-gradient(45deg, transparent, transparent 10px, rgba(6, 162, 149, 0.1) 10px, rgba(6, 162, 149, 0.1) 20px);"></div>

          <!-- Header -->
          <div class="bg-gradient-to-r from-teal-600 to-teal-700 h-10 flex items-center justify-center px-3">
            <h3 class="text-white text-xs font-bold uppercase tracking-wide text-center">Attendance QR Code</h3>
          </div>

          <!-- QR Code Section -->
          <div class="flex flex-col items-center justify-center h-[calc(100%-2.5rem)] p-4">
            <div id="qrcode-profile" phx-hook="QRCode" data-qr-data={@qr_data} class="flex justify-center"></div>
            <p class="text-[7px] text-gray-500 mt-3 text-center">Scan for attendance verification</p>
            <p class="text-[6px] text-gray-400 mt-1 text-center">ID: <%= @user.id %></p>
          </div>

          <!-- Footer -->
          <div class="absolute bottom-0 left-0 right-0 h-4 bg-gradient-to-r from-teal-600 to-teal-700"></div>
        </div>
      </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script>
    <script>
      document.addEventListener('DOMContentLoaded', function() {
        const card = document.getElementById('student-card-profile');
        if (card) {
          card.addEventListener('click', function() {
            const isFlipped = card.style.transform === 'rotateY(180deg)';
            card.style.transform = isFlipped ? 'rotateY(0deg)' : 'rotateY(180deg)';
          });
        }
      });

      function printStudentCard() {
        const card = document.getElementById('student-card-profile');
        if (!card) return;

        // Get both front and back cards
        const frontCard = card.querySelector('.student-card-front');
        const backCard = card.querySelector('.student-card-back');

        if (!frontCard || !backCard) return;

        // Clone the cards for printing
        const frontClone = frontCard.cloneNode(true);
        const backClone = backCard.cloneNode(true);

        // Remove transform from cloned cards
        frontClone.style.transform = 'none';
        backClone.style.transform = 'none';
        frontClone.style.position = 'relative';
        backClone.style.position = 'relative';

        // Create print window
        const printWindow = window.open('', '_blank');

        // Get all styles from the current document
        let styles = '';
        Array.from(document.styleSheets).forEach(sheet => {
          try {
            Array.from(sheet.cssRules || []).forEach(rule => {
              styles += rule.cssText + '\n';
            });
          } catch (e) {
            // Cross-origin stylesheets might throw errors
          }
        });

        // Create print HTML using helper function to avoid HEEx parsing issues
        const tag = function(name, attrs) {
          const attrStr = attrs ? ' ' + attrs : '';
          return String.fromCharCode(60) + name + attrStr + String.fromCharCode(62);
        };
        const closeTag = function(name) {
          return String.fromCharCode(60, 47) + name + String.fromCharCode(62);
        };

        const printHTML = '<!DOCTYPE html>' +
          tag('html') +
          tag('head') +
          tag('title') + 'Student Identification Card' + closeTag('title') +
          tag('style') +
          styles +
          '@page { size: A4; margin: 15mm; }' +
          'body { margin: 0; padding: 20px; font-family: Arial, sans-serif; background: white; }' +
          '.print-container { display: flex; flex-direction: column; align-items: center; gap: 30px; }' +
          '.print-card { width: 200px; height: 320px; position: relative; page-break-inside: avoid; }' +
          '.print-card-front, .print-card-back { width: 100%; height: 100%; position: relative !important; transform: none !important; backface-visibility: visible !important; }' +
          '@media print { body { padding: 0; } .print-container { gap: 20mm; } .print-card-back { page-break-before: always; } }' +
          closeTag('style') +
          closeTag('head') +
          tag('body') +
          tag('div', 'class="print-container"') +
          tag('div', 'class="print-card"') +
          frontClone.outerHTML +
          closeTag('div') +
          tag('div', 'class="print-card"') +
          backClone.outerHTML +
          closeTag('div') +
          closeTag('div') +
          tag('script') +
          'window.onload = function() { setTimeout(function() { window.print(); }, 250); };' +
          'window.onafterprint = function() { window.close(); };' +
          closeTag('script') +
          closeTag('body') +
          closeTag('html');

        printWindow.document.write(printHTML);
        printWindow.document.close();
      }
    </script>

    <style>
      .student-card-container {
        perspective: 1000px;
      }

      .student-card {
        width: 200px;
        height: 320px;
        position: relative;
        transform-style: preserve-3d;
        transition: transform 0.6s;
      }

      .student-card-front,
      .student-card-back {
        position: absolute;
        width: 100%;
        height: 100%;
        backface-visibility: hidden;
        border-radius: 0.25rem;
      }

      .student-card-back {
        transform: rotateY(180deg);
      }

      @media print {
        .student-card {
          transform: none !important;
        }
        .student-card-back {
          page-break-before: always;
        }
      }
    </style>
    """
  end
end
