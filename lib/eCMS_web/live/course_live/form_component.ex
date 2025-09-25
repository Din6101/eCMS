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

      <!-- Start Date -->
  <.input
    field={@form[:start_date]}
    type="date"
    label="Start Date"
    class="w-full"
  />

  <!-- End Date -->
  <.input
    field={@form[:end_date]}
    type="date"
    label="End Date"
    class="w-full"
  />

  <!-- Venue -->
  <.input
    field={@form[:venue]}
    type="text"
    label="Venue"
    placeholder="Enter venue (e.g. Hall A)"
    class="w-full"
  />

      <!-- Qouta -->
      <.input
        field={@form[:qouta]}
        type="number"
        label="Qouta"
        min="1"
        placeholder="Enter maximum participants"
        class="w-full"
      />

      <:actions>
        <.button
          class="bg-[#2D9CDB] text-white px-4 py-2 rounded-lg font-semibold shadow"
          phx-disable-with="Saving..."
        >
          Save
        </.button>

        <!-- Show delete only if editing an existing course -->
        <%= if @course.id do %>
        <.button
          class="bg-[#FF0404] text-white px-4 py-2 rounded-lg font-semibold shadow"
          phx-click="delete"
          phx-value-id={@course.id}
          data-confirm="Are you sure?"
          >
          Delete
        </.button>
        <% end %>

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

  def handle_event("delete", %{"id" => id}, socket) do
    course = ECMS.Courses.get_course!(id)
    {:ok, _} = ECMS.Courses.delete_course(course)

    {:noreply,
     socket
     |> put_flash(:info, "Course deleted successfully.")
     |> push_navigate(to: ~p"/admin/courses")}
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
