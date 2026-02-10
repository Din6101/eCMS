defmodule ECMSWeb.EnrollmentLive.FormComponent do
  use ECMSWeb, :live_component

  alias ECMS.Training

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage enrollment records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="enrollment-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="text-black">
          <!-- Student (user_id) -->
          <.input field={@form[:user_id]} type="select" label="Student"
            options={for s <- @students, do: {s.full_name, s.id}}
            class="!text-black !bg-white"/>

          <!-- Course -->
          <.input field={@form[:course_id]} type="select" label="Course"
            options={for c <- @courses, do: {c.title, c.id}}
            class="!text-black !bg-white"/>

          <!-- Status -->
          <.input field={@form[:status]} type="select" label="Status"
            options={["pending", "active", "completed", "cancelled"]}
            class="!text-black !bg-white"/>

          <!-- Progress (SLIDER) -->
          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">Progress (%)</label>
            <input type="range"
                   name="enrollment[progress]"
                   value={@form[:progress].value || 0}
                   min="0" max="100" step="1"
                   class="w-full accent-[#06A295]" />
            <div class="text-sm text-gray-700 mt-1">
              Value: {@form[:progress].value || 0}%
            </div>
          </div>

          <!-- Milestone (Checkbox group) -->
          <div class="mt-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">Milestones</label>

            <% selected_milestones =
              case @form[:milestone].value do
              val when is_binary(val) -> String.split(val, ",")
              val when is_list(val) -> val
              _ -> []
            end
            %>

            <div class="grid grid-cols-2 gap-2 text-sm">
              <%= for milestone <- [
              "Completed Module 1",
              "Completed Module 2",
              "Completed Module 3",
              "Completed Module 4",
              "Completed Module 5",
              "Submitted Assignment 1",
              "Submitted Assignment 2",
              "Mini Project Submitted",
              "Final Project Submitted",
              "Certificate Issued"
            ] do %>
            <label class="flex items-center space-x-2">
              <input
              type="checkbox"
              name="enrollment[milestone][]"
              value={milestone}
              checked={milestone in selected_milestones}
              class="accent-[#06A295]"
            />
              <span><%= milestone %></span>
            </label>
            <% end %>
          </div>
        </div>



        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Enrollment</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
def update(%{enrollment: enrollment} = assigns, socket) do
  students = ECMS.Accounts.list_users_by_role("student")
  courses = ECMS.Courses.list_all_courses()

  milestone_list =
    case enrollment.milestone do
      nil -> []
      str when is_binary(str) -> String.split(str, ",") |> Enum.map(&String.trim/1)
    end

  enrollment = %{enrollment | milestone: milestone_list, progress: enrollment.progress || 0}
  changeset = Training.change_enrollment(enrollment)

  {:ok,
   socket
   |> assign(assigns)
   |> assign(:students, students)
   |> assign(:courses, courses)
   |> assign(:form, to_form(changeset))}
end


@impl true
def handle_event("validate", %{"enrollment" => enrollment_params}, socket) do
  enrollment_params =
    case Map.get(enrollment_params, "milestone") do
      milestones when is_list(milestones) ->
        Map.put(enrollment_params, "milestone", Enum.join(milestones, ","))
      _ -> enrollment_params
    end

  changeset =
    socket.assigns.enrollment
    |> Training.change_enrollment(enrollment_params)
    |> Map.put(:action, :validate)

  {:noreply, assign(socket, form: to_form(changeset))}
end


  @impl true
  def handle_event("save", %{"enrollment" => enrollment_params}, socket) do
    save_enrollment(socket, socket.assigns.action, enrollment_params)
  end

  defp save_enrollment(socket, :new, enrollment_params) do
    # Convert milestone list to comma-separated string
    enrollment_params =
      case Map.get(enrollment_params, "milestone") do
        milestones when is_list(milestones) ->
          Map.put(enrollment_params, "milestone", Enum.join(milestones, ","))
        _ ->
          enrollment_params
      end

    # Convert numeric fields to integers
    enrollment_params =
      enrollment_params
      |> Map.update!("progress", fn
        val when is_binary(val) -> String.to_integer(val)
        val -> val
      end)
      |> Map.update!("user_id", fn
        val when is_binary(val) -> String.to_integer(val)
        val -> val
      end)
      |> Map.update!("course_id", fn
        val when is_binary(val) -> String.to_integer(val)
        val -> val
      end)

    case ECMS.Training.create_enrollment(enrollment_params) do
      {:ok, enrollment} ->
        send(self(), {__MODULE__, {:saved, enrollment}})

        {:noreply,
         socket
         |> put_flash(:info, "Enrollment created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_enrollment(socket, :edit, enrollment_params) do
    # Convert milestone list to comma-separated string
    enrollment_params =
      case Map.get(enrollment_params, "milestone") do
        milestones when is_list(milestones) ->
          Map.put(enrollment_params, "milestone", Enum.join(milestones, ","))
        _ ->
          enrollment_params
      end

    # Convert numeric fields to integers
    enrollment_params =
      enrollment_params
      |> Map.update!("progress", fn
        val when is_binary(val) -> String.to_integer(val)
        val -> val
      end)
      |> Map.update!("user_id", fn
        val when is_binary(val) -> String.to_integer(val)
        val -> val
      end)
      |> Map.update!("course_id", fn
        val when is_binary(val) -> String.to_integer(val)
        val -> val
      end)

    case Training.update_enrollment(socket.assigns.enrollment, enrollment_params) do
      {:ok, enrollment} ->
        send(self(), {__MODULE__, {:saved, enrollment}})

        {:noreply,
         socket
         |> put_flash(:info, "Enrollment updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end


end
