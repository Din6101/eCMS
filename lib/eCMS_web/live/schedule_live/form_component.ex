defmodule ECMSWeb.ScheduleLive.FormComponent do
  use ECMSWeb, :live_component

  alias ECMS.Training
  alias ECMS.Courses
  alias ECMS.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-white p-6 rounded-lg shadow-lg">
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage schedules</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="schedule-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-6"
      >
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Course -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Course *</label>
            <select
              name="schedule[course_id]"
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-[#06A295] focus:border-[#06A295] text-gray-900 bg-white"
              required
            >
              <option value="">Select a course</option>
              <%= for {title, id} <- course_options() do %>
                <option value={id} selected={@form[:course_id].value == id}><%= title %></option>
              <% end %>
            </select>
            <.error :for={ {msg, _opts} <- @form[:course_id].errors }><%= msg %></.error>
          </div>

          <!-- Trainer -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Trainer *</label>
            <select
              name="schedule[trainer_id]"
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-[#06A295] focus:border-[#06A295] text-gray-900 bg-white"
              required
            >
              <option value="">Select a trainer</option>
              <%= for {name, id} <- trainer_options() do %>
                <option value={id} selected={@form[:trainer_id].value == id}><%= name %></option>
              <% end %>
            </select>
            <.error :for={ {msg, _opts} <- @form[:trainer_id].errors }><%= msg %></.error>
          </div>
        </div>

        <!-- Status & Venue -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Status *</label>
            <select
              name="schedule[status]"
              phx-change="status_changed"
              phx-target={@myself}
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-[#06A295] focus:border-[#06A295] text-gray-900 bg-white"
              required
            >
              <option value="">Select status</option>
              <option value="assigned"  selected={to_string(@form[:status].value) == "assigned"}>Assigned</option>
              <option value="invited"   selected={to_string(@form[:status].value) == "invited"}>Invited</option>
              <option value="confirmed" selected={to_string(@form[:status].value) == "confirmed"}>Confirmed</option>
              <option value="completed" selected={to_string(@form[:status].value) == "completed"}>Completed</option>
              <option value="declined"  selected={to_string(@form[:status].value) == "declined"}>Declined</option>
            </select>
            <.error :for={ {msg, _opts} <- @form[:status].errors }><%= msg %></.error>

            <.status_note form={@form} />
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Venue</label>
            <input
              type="text"
              name="schedule[venue]"
              value={@form[:venue].value || ""}
              placeholder="Enter venue location..."
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-[#06A295] focus:border-[#06A295] text-gray-900 bg-white"
            />
            <.error :for={ {msg, _opts} <- @form[:venue].errors }><%= msg %></.error>
          </div>
        </div>

        <!-- Schedule Date / Time / Duration -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mt-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Schedule Date *</label>
            <input type="date" name="schedule[schedule_date]"
                   value={@form[:schedule_date].value || ""}
                   class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-[#06A295] focus:border-[#06A295] text-gray-900 bg-white"
                   required />
            <.error :for={ {msg, _opts} <- @form[:schedule_date].errors }><%= msg %></.error>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Schedule Time *</label>
            <select
              name="schedule[schedule_time]"
              class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-[#06A295] focus:border-[#06A295] text-gray-900 bg-white"
              required
            >
              <%= time_value = (@form[:schedule_time].value || "") %>
              <option value="" selected={time_value == ""}>Select time</option>
              <%= for t <- time_options() do %>
                <option value={t} selected={time_value == t}><%= t %></option>
              <% end %>
            </select>
            <.error :for={ {msg, _opts} <- @form[:schedule_time].errors }><%= msg %></.error>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Duration (minutes) *</label>
            <input type="number" name="schedule[duration]"
                   value={@form[:duration].value || 60}
                   min="1"
                   class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-[#06A295] focus:border-[#06A295] text-gray-900 bg-white"
                   required />
            <.error :for={ {msg, _opts} <- @form[:duration].errors }><%= msg %></.error>
          </div>
        </div>

        <!-- Notes -->
        <div class="mt-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">Notes</label>
          <textarea name="schedule[notes]"
                    rows="4"
                    placeholder="Additional notes for this schedule..."
                    class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-2 focus:ring-[#06A295] focus:border-[#06A295] text-gray-900 bg-white"><%= @form[:notes].value || "" %></textarea>
          <.error :for={ {msg, _opts} <- @form[:notes].errors }><%= msg %></.error>
        </div>

        <!-- Submit -->
        <div class="mt-8 flex justify-end">
          <.button type="submit"
                   class="bg-[#06A295] hover:bg-[#058a7a] text-white font-medium py-2 px-6 rounded-md transition-colors duration-200"
                   phx-disable-with="Saving...">
            Save Schedule
          </.button>
        </div>
      </.simple_form>
    </div>
    """
  end

  # Component: status note with safe fallback
  attr :form, :any, required: true
  def status_note(assigns) do
    ~H"""
    <div id="status-notes"
         class="mt-2 p-3 bg-emerald-50 border border-emerald-200 rounded-md"
         style={if @form[:status].value in [nil, ""], do: "display: none", else: "display: block"}>
      <p class="text-sm text-emerald-800">
        <span class="font-medium">Status:</span>
        <%= status_description(@form[:status].value) %>
      </p>
    </div>
    """
  end

  defp status_description(nil), do: "Please choose a status"
  defp status_description(""), do: "Please choose a status"
  defp status_description(status) when is_binary(status), do: Training.get_status_description(status)
  defp status_description(status) when is_atom(status), do: Training.get_status_description(Atom.to_string(status))
  defp status_description(_), do: "Unknown status"

  @impl true
  def update(%{schedule: schedule} = assigns, socket) do
    changeset = Training.change_schedule(schedule)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"schedule" => schedule_params}, socket) do
    schedule_params = auto_populate_fields(schedule_params)

    changeset =
      socket.assigns.schedule
      |> Training.change_schedule(schedule_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"schedule" => schedule_params}, socket) do
    schedule_params = auto_populate_fields(schedule_params)
    save_schedule(socket, socket.assigns.action, schedule_params)
  end

  def handle_event("status_changed", %{"schedule" => %{"status" => status}}, socket) do
    changeset =
      socket.assigns.schedule
      |> Training.change_schedule(%{"status" => status})
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  # -----------------
  # Private helpers
  # -----------------

  defp save_schedule(socket, :edit, schedule_params) do
    case Training.update_schedule(socket.assigns.schedule, schedule_params) do
      {:ok, schedule} ->
        notify_parent({:saved, schedule})

        {:noreply,
         socket
         |> put_flash(:info, "Schedule updated successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_schedule(socket, :new, schedule_params) do
    case Training.create_schedule(schedule_params) do
      {:ok, schedule} ->
        notify_parent({:saved, schedule})

        {:noreply,
         socket
         |> put_flash(:info, "Schedule created successfully")
         |> push_patch(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # Auto-populate title based on selected course
  defp auto_populate_fields(params) do
    params
    |> maybe_populate_title()
  end

  defp maybe_populate_title(params) do
    case Map.get(params, "course_id") do
      nil -> params
      "" -> params
      course_id ->
        course = Courses.get_course!(course_id)
        Map.put(params, "title", course.title)
    end
  end

  # Helper functions for select options
  defp course_options do
    Courses.list_all_courses()
    |> Enum.map(fn course -> {course.title, course.id} end)
  end

  defp trainer_options do
    Accounts.list_users_by_role("trainer")
    |> Enum.map(fn trainer -> {trainer.full_name, trainer.id} end)
  end

  # Predefined time options in 15-minute increments between 07:00 and 20:00
  defp time_options do
    start_minutes = 7 * 60
    end_minutes = 20 * 60
    step = 15

    for m <- start_minutes..end_minutes//step do
      hours = div(m, 60)
      minutes = rem(m, 60)
      :io_lib.format("~2..0B:~2..0B", [hours, minutes]) |> IO.iodata_to_binary()
    end
  end

  # Normalize string/atom status
end
