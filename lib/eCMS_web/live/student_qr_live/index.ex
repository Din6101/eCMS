defmodule ECMSWeb.StudentQRLive.Index do
  use ECMSWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    qr_data = "STUDENT_ID:#{current_user.id}"

    {:ok,
     socket
     |> assign(:page_title, "My Student Card")
     |> assign(:qr_data, qr_data)
     |> assign(:user, current_user)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <.header>
        My Student Card
        <:subtitle>Show this card to your trainer for attendance</:subtitle>
      </.header>

      <div class="mt-8 flex justify-center">
        <%= render_student_card(assigns) %>
      </div>

      <!-- Flip Button -->
      <div class="mt-8 text-center">
        <button
          id="flip-card-btn"
          class="bg-teal-600 hover:bg-teal-700 text-white font-semibold py-3 px-8 rounded-lg transition-colors inline-flex items-center gap-2 shadow-lg"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          Flip Card
        </button>
      </div>

      <p class="text-sm text-gray-500 mt-4 text-center">
        Present this card to your trainer to mark your attendance
      </p>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script>
    <script>
      document.addEventListener('DOMContentLoaded', function() {
        const card = document.getElementById('student-card');
        const flipBtn = document.getElementById('flip-card-btn');
        let isFlipped = false;

        if (flipBtn && card) {
          flipBtn.addEventListener('click', function() {
            isFlipped = !isFlipped;
            card.style.transform = isFlipped ? 'rotateY(180deg)' : 'rotateY(0deg)';
            flipBtn.textContent = isFlipped ? 'Show Front' : 'Show QR Code';
          });
        }
      });
    </script>
    """
  end

  defp render_student_card(assigns) do
    ~H"""
    <!-- Student Card Container -->
    <div class="student-card-container" style="perspective: 1000px;">
      <div id="student-card" class="student-card" style="width: 280px; height: 176px; position: relative; transform-style: preserve-3d; transition: transform 0.6s;">
        <!-- Front of Card -->
        <div class="student-card-front absolute inset-0 w-full h-full bg-white rounded shadow-2xl overflow-hidden" style="backface-visibility: hidden; border: 1px solid #e5e7eb;">
          <!-- Background Pattern -->
          <div class="absolute inset-0 opacity-5" style="background-image: repeating-linear-gradient(45deg, transparent, transparent 10px, rgba(6, 162, 149, 0.1) 10px, rgba(6, 162, 149, 0.1) 20px);"></div>

          <!-- Header Section -->
          <div class="bg-gradient-to-r from-teal-600 to-teal-700 h-12 flex items-center justify-between px-4 relative">
            <div class="flex items-center gap-2">
              <img src={~p"/images/logo-cms-5-29.png"} alt="Logo" class="h-8 w-8 object-contain" />
              <div>
                <h3 class="text-white text-xs font-bold uppercase tracking-wide">e-CMS</h3>
                <p class="text-teal-100 text-[8px]">STUDENT IDENTIFICATION CARD</p>
              </div>
            </div>
            <div class="text-white text-[8px] font-semibold">VALID</div>
          </div>

          <!-- Main Content -->
          <div class="p-3 flex items-center gap-3 h-[calc(100%-3rem)]">
            <!-- Student Photo -->
            <div class="flex-shrink-0">
              <%= if @user.avatar_url do %>
                <img src={@user.avatar_url} alt="Student Photo" class="w-20 h-24 object-cover border-2 border-gray-300 shadow-md" />
              <% else %>
                <div class="w-20 h-24 bg-gradient-to-br from-teal-400 to-teal-600 flex items-center justify-center border-2 border-gray-300 shadow-md">
                  <span class="text-white text-2xl font-bold">
                    <%= String.first(String.upcase(@user.full_name || "S")) %>
                  </span>
                </div>
              <% end %>
            </div>

            <!-- Student Info -->
            <div class="flex-1 min-w-0">
              <div class="mb-1">
                <p class="text-[8px] text-gray-500 uppercase tracking-wide mb-0.5">Name</p>
                <h2 class="text-sm font-bold text-gray-900 leading-tight truncate"><%= @user.full_name %></h2>
              </div>
              <div class="mb-1">
                <p class="text-[8px] text-gray-500 uppercase tracking-wide mb-0.5">IC Number</p>
                <p class="text-xs font-semibold text-gray-800"><%= @user.ic_number || "N/A" %></p>
              </div>
              <div class="mt-2 pt-2 border-t border-gray-200">
                <p class="text-[8px] text-gray-500 uppercase tracking-wide mb-0.5">Student ID</p>
                <p class="text-xs font-mono font-semibold text-teal-700">#<%= @user.id %></p>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="absolute bottom-0 left-0 right-0 h-4 bg-gradient-to-r from-teal-600 to-teal-700 flex items-center justify-end px-2">
            <p class="text-white text-[7px] font-semibold">Authorized Signature</p>
          </div>
        </div>

        <!-- Back of Card -->
        <div class="student-card-back absolute inset-0 w-full h-full bg-white rounded shadow-2xl overflow-hidden" style="backface-visibility: hidden; transform: rotateY(180deg); border: 1px solid #e5e7eb;">
          <!-- Background Pattern -->
          <div class="absolute inset-0 opacity-5" style="background-image: repeating-linear-gradient(45deg, transparent, transparent 10px, rgba(6, 162, 149, 0.1) 10px, rgba(6, 162, 149, 0.1) 20px);"></div>

          <!-- Header -->
          <div class="bg-gradient-to-r from-teal-600 to-teal-700 h-8 flex items-center justify-center px-3">
            <h3 class="text-white text-xs font-bold uppercase tracking-wide">Attendance QR Code</h3>
          </div>

          <!-- QR Code Section -->
          <div class="flex flex-col items-center justify-center h-[calc(100%-2rem)] p-4">
            <div id="qrcode" phx-hook="QRCode" data-qr-data={@qr_data} class="flex justify-center"></div>
            <p class="text-[8px] text-gray-500 mt-2 text-center">Scan for attendance verification</p>
            <p class="text-[7px] text-gray-400 mt-1 text-center">ID: <%= @user.id %></p>
          </div>

          <!-- Footer -->
          <div class="absolute bottom-0 left-0 right-0 h-4 bg-gradient-to-r from-teal-600 to-teal-700"></div>
        </div>
      </div>
    </div>

    <style>
      .student-card-container {
        perspective: 1000px;
      }

      .student-card {
        width: 280px;
        height: 176px;
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
