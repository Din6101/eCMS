defmodule ECMSWeb.ResultLive.FormComponent do
  use ECMSWeb, :live_component

  alias ECMS.Training

  @impl true
  def render(assigns) do
    ~H"""
    <div class="text-black">
      <.header>
        {@title}
        <:subtitle>Use this form to manage result records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="result-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="text-black"
      >
        <!-- Student -->
        <.input
          field={@form[:user_id]}
          type="select"
          label="Student"
          options={for u <- @users, do: {u.full_name, u.id}}
        />

        <!-- Course -->
        <.input
          field={@form[:course_id]}
          type="select"
          label="Course"
          options={for c <- @courses, do: {c.title, c.id}}
        />

        <!-- Final Score -->
        <div class="flex items-center space-x-2 mt-4">
          <.input
            field={@form[:final_score]}
            type="range"
            label="Final Score"
            min="0"
            max="100"
            step="1"
          />
          <span class="font-semibold"><%= (@form[:final_score].value || 0) %>%</span>
        </div>

        <!-- Status -->
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={[
            {"Completed", "completed"},
            {"In-completed", "in-completed"}
          ]}
        />

        <!-- Certification -->
        <.input
          field={@form[:certification]}
          type="select"
          label="Certification"
          options={[
            {"Recommended", "recommended"},
            {"Not eligible", "not eligible"}
          ]}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Result</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{result: result} = assigns, socket) do
    users = ECMS.Accounts.list_students()
    courses = ECMS.Courses.list_all_courses()

    changeset = Training.change_result(result)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:users, users)
     |> assign(:courses, courses)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"result" => result_params}, socket) do
    changeset =
      socket.assigns.result
      |> Training.change_result(result_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"result" => result_params}, socket) do
    case socket.assigns.action do
      :new -> create_result(socket, result_params)
      :edit -> update_result(socket, result_params)
    end
  end

  defp create_result(socket, params) do
    case Training.create_result(params) do
      {:ok, result} ->
        notify_parent({:saved, result})

        {:noreply,
         socket
         |> put_flash(:info, "Result created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp update_result(socket, params) do
    case Training.update_result(socket.assigns.result, params) do
      {:ok, result} ->
        notify_parent({:saved, result})

        {:noreply,
         socket
         |> put_flash(:info, "Result updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
