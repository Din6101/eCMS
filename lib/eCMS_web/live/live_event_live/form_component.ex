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
        class= "text-black"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:live]} type="checkbox" label="Live" />
        <.input field={@form[:presenter]} type="text" label="Presenter" />

        <div class="space-y-4 border-t pt-4 mt-4">
          <h3 class="text-lg font-medium text-gray-900">Video Link (Optional)</h3>
          <p class="text-sm text-gray-600">Add a link to your live video from social media platforms</p>

          <.input
            field={@form[:platform]}
            type="select"
            label="Platform"
            prompt="Choose a platform"
            options={[
              {"Facebook", "facebook"},
              {"YouTube", "youtube"},
              {"TikTok", "tiktok"},
              {"Instagram", "instagram"}
            ]}
          />

          <.input
            field={@form[:video_url]}
            type="url"
            label="Video URL"
            placeholder="https://www.facebook.com/username/videos/123456789/"
          />
          <p class="text-xs text-gray-500 mt-1">Paste the full URL of your live video or post</p>

          <div class="bg-blue-50 border border-blue-200 rounded-lg p-3">
            <h4 class="text-sm font-medium text-blue-900 mb-2">Platform Examples:</h4>
            <ul class="text-xs text-blue-800 space-y-1">
              <li><strong>Facebook:</strong> https://www.facebook.com/username/videos/123456789/</li>
              <li><strong>YouTube:</strong> https://www.youtube.com/watch?v=dQw4w9WgXcQ</li>
              <li><strong>TikTok:</strong> https://www.tiktok.com/@username/video/123456789</li>
              <li><strong>Instagram:</strong> https://www.instagram.com/p/ABC123DEF/</li>
            </ul>
          </div>
        </div>

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
