defmodule ECMSWeb.LiveEventLive.FormComponent do
  use ECMSWeb, :live_component

  alias ECMS.Training

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage live_event records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="live_event-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:live]} type="checkbox" label="Live" />
        <.input field={@form[:presenter]} type="text" label="Presenter" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Live event</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{live_event: live_event} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Training.change_live_event(live_event))
     end)}
  end

  @impl true
  def handle_event("validate", %{"live_event" => live_event_params}, socket) do
    changeset = Training.change_live_event(socket.assigns.live_event, live_event_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"live_event" => live_event_params}, socket) do
    save_live_event(socket, socket.assigns.action, live_event_params)
  end

  defp save_live_event(socket, :edit, live_event_params) do
    case Training.update_live_event(socket.assigns.live_event, live_event_params) do
      {:ok, live_event} ->
        notify_parent({:saved, live_event})

        {:noreply,
         socket
         |> put_flash(:info, "Live event updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_live_event(socket, :new, live_event_params) do
    case Training.create_live_event(live_event_params) do
      {:ok, live_event} ->
        notify_parent({:saved, live_event})

        {:noreply,
         socket
         |> put_flash(:info, "Live event created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
