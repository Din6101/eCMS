defmodule ECMSWeb.FeedbackLive.FormComponent do
  use ECMSWeb, :live_component

  alias ECMS.Training
  alias ECMS.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage feedback records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="feedback-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class= "text-black"
      >
        <.input
          field={@form[:student_id]}
          type="select"
          label="Student"
          prompt="Choose a student"
          options={@student_options}
        />
        <.input
          field={@form[:course_id]}
          type="select"
          label="Course"
          prompt="Choose a course"
          options={@course_options}
        />
        <.input field={@form[:feedback]} type="textarea" label="Feedback" rows="4" />
        <.input field={@form[:remarks]} type="textarea" label="Remarks" rows="3" />
        <.input field={@form[:need_support]} type="checkbox" label="Need Support" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Feedback</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{feedback: feedback} = assigns, socket) do
    changeset = Training.change_feedback(feedback)

    student_options = Training.list_students() |> Enum.map(&{&1.full_name, &1.id})
    course_options = Courses.list_all_courses() |> Enum.map(&{&1.title, &1.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:student_options, student_options)
     |> assign(:course_options, course_options)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"feedback" => feedback_params}, socket) do
    changeset =
      socket.assigns.feedback
      |> Training.change_feedback(feedback_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"feedback" => feedback_params}, socket) do
    save_feedback(socket, socket.assigns.action, feedback_params)
  end

  defp save_feedback(socket, :edit, feedback_params) do
    case Training.update_feedback(socket.assigns.feedback, feedback_params) do
      {:ok, feedback} ->
        notify_parent({:saved, feedback})

        {:noreply,
         socket
         |> put_flash(:info, "Feedback updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_feedback(socket, :new, feedback_params) do
    case Training.create_feedback(feedback_params) do
      {:ok, feedback} ->
        notify_parent({:saved, feedback})

        {:noreply,
         socket
         |> put_flash(:info, "Feedback created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
