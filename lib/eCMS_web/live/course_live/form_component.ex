defmodule ECMSWeb.CourseLive.FormComponent do
  use ECMSWeb, :live_component

  alias ECMS.Courses

  @impl true
  def render(assigns) do
  ~H"""
  <div class="p-6">
    <.header>
      <%= @title %>
      <:subtitle>Use this form to manage course records in your database.</:subtitle>
    </.header>

    <.simple_form
      for={@form}
      id="course-form"
      phx-target={@myself}
      phx-change="validate"
      phx-submit="save"
      class="space-y-6"
    >


      <.input
        field={@form[:title]}
        type="text"
        label="Title"
        placeholder="Enter course title"
        class="w-full"
      />

      <.input
        field={@form[:description]}
        type="textarea"
        label="Description"
        placeholder="Enter course description"
        class="w-full h-32 resize-none"
      />

      <:actions>
        <.button
          class="bg-[#5fd6cf] text-black px-4 py-2 rounded-lg font-semibold shadow"
          phx-disable-with="Saving..."
        >
          Save Course
        </.button>
      </:actions>
    </.simple_form>
  </div>
  """
end

  @impl true
  def update(%{course: course} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Courses.change_course(course))
     end)}
  end

  @impl true
  def handle_event("validate", %{"course" => course_params}, socket) do
    changeset = Courses.change_course(socket.assigns.course, course_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"course" => course_params}, socket) do
    save_course(socket, socket.assigns.action, course_params)
  end

  defp save_course(socket, :edit, course_params) do
    case Courses.update_course(socket.assigns.course, course_params) do
      {:ok, course} ->
        notify_parent({:saved, course})

        {:noreply,
         socket
         |> put_flash(:info, "Course updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_course(socket, :new, course_params) do
    case Courses.create_course(course_params) do
      {:ok, course} ->
        notify_parent({:saved, course})

        {:noreply,
         socket
         |> put_flash(:info, "Course created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
