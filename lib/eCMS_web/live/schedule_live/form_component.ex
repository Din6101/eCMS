defmodule ECMSWeb.ScheduleLive.FormComponent do
  use ECMSWeb, :live_component

  alias ECMS.{Courses, Accounts, Training}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 bg-white text-gray-900 rounded-lg shadow-md">
      <h2 class="text-xl font-semibold mb-2"><%= @title %></h2>
      <p class="text-sm text-gray-600 mb-6">
        Use this form to manage schedule records in your database.
      </p>

      <.simple_form
        for={@form}
        id="schedule-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4"
      >
        <.input
          field={@form[:course_id]}
          type="select"
          label="Course"
          options={for c <- @courses, do: {c.title, c.id}}
        />

        <.input
          field={@form[:trainer_id]}
          type="select"
          label="Trainer"
          options={for t <- @trainers, do: {t.full_name, t.id}}
        />

        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={~w(assigned invited confirmed declined completed)a}
        />

        <.input
          field={@form[:notes]}
          type="textarea"
          label="Notes"
        />

        <:actions>
          <.button class="w-full">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{schedule: schedule} = assigns, socket) do
    courses  = Courses.list_courses()
    trainers = Accounts.list_trainers()
    changeset = Training.change_schedule(schedule)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:courses, courses.entries)
     |> assign(:trainers, trainers)
     |> assign(:changeset, changeset)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"schedule" => params}, socket) do
    changeset =
      socket.assigns.schedule
      |> Training.change_schedule(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"schedule" => params}, socket) do
    save_schedule(socket, socket.assigns.action, params)
  end

  defp save_schedule(socket, :new, params) do
    case Training.create_schedule(params) do
      {:ok, schedule} ->
        schedule = ECMS.Repo.preload(schedule, [:course, :trainer])
        notify_parent({:saved, schedule})

        {:noreply,
         socket
         |> put_flash(:info, "Schedule created")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = cs} ->
        {:noreply,
         socket
         |> assign(:changeset, cs)
         |> assign(:form, to_form(cs))}
    end
  end

  defp save_schedule(socket, :edit, params) do
    case Training.update_schedule(socket.assigns.schedule, params) do
      {:ok, schedule} ->
        schedule = ECMS.Repo.preload(schedule, [:course, :trainer])
        notify_parent({:saved, schedule})

        {:noreply,
         socket
         |> put_flash(:info, "Schedule updated")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = cs} ->
        {:noreply,
         socket
         |> assign(:changeset, cs)
         |> assign(:form, to_form(cs))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
