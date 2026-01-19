defmodule ECMSWeb.EnrollmentLive.Index do
  use ECMSWeb, :live_view
  alias ECMS.Training
  alias ECMS.Training.Enrollment
  alias ECMSWeb.EnrollmentLive.FormComponent

  @impl true
  def mount(_params, _session, socket) do
  if connected?(socket) do
    # Stream only after LiveView is connected
    enrollments = Training.list_enrollments()
                   |> Enum.filter(& &1.course != nil)
    socket = stream(socket, :enrollments, enrollments)
    {:ok, socket}
  else
    # Avoid stream on disconnected mount
    {:ok, socket}
  end
  end


  @impl true
  def handle_params(params, _url, socket) do
    socket =
      socket
      |> apply_action(socket.assigns.live_action, params)
      |> ensure_enrollment_stream_loaded()

    {:noreply, socket}
  end

  @spec ensure_enrollment_stream_loaded(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
defp ensure_enrollment_stream_loaded(%{assigns: %{streams: %{enrollments: _}}} = socket), do: socket

defp ensure_enrollment_stream_loaded(socket) do
  stream(socket, :enrollments, Training.list_enrollments() |> Enum.filter(& &1.course != nil))
end




  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Enrollment")
    |> assign(:enrollment, %Enrollment{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Enrollment")
    |> assign(:enrollment, Training.get_enrollment!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Enrollments")
    |> assign(:enrollment, nil)
  end

  # update stream bila FormComponent save
  @impl true
  def handle_info({FormComponent, {:saved, enrollment}}, socket) do
    {:noreply, stream_insert(socket, :enrollments, enrollment)}
  end

  # delete dari stream
  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    enrollment = Training.get_enrollment!(id)
    {:ok, _} = Training.delete_enrollment(enrollment)

    {:noreply, stream_delete(socket, :enrollments, enrollment)}
  end
end
