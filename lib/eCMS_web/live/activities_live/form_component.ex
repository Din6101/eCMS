defmodule ECMSWeb.ActivitiesLive.FormComponent do
  use ECMSWeb, :live_component

  alias ECMS.Training

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage activities records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="activities-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:time]} type="time" label="Time" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Activities</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{activities: activities} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Training.change_activities(activities))
     end)}
  end

  @impl true
  def handle_event("validate", %{"activities" => activities_params}, socket) do
    changeset = Training.change_activities(socket.assigns.activities, activities_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"activities" => activities_params}, socket) do
    save_activities(socket, socket.assigns.action, activities_params)
  end

  defp save_activities(socket, :edit, activities_params) do
    case Training.update_activities(socket.assigns.activities, activities_params) do
      {:ok, activities} ->
        notify_parent({:saved, activities})

        {:noreply,
         socket
         |> put_flash(:info, "Activities updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_activities(socket, :new, activities_params) do
    case Training.create_activities(activities_params) do
      {:ok, activities} ->
        notify_parent({:saved, activities})

        {:noreply,
         socket
         |> put_flash(:info, "Activities created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
