defmodule ECMSWeb.FeedbackLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.Feedback

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :feedback_collection, Training.list_feedback())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Feedback")
    |> assign(:feedback, Training.get_feedback!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Feedback")
    |> assign(:feedback, %Feedback{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Feedback")
    |> assign(:feedback, nil)
  end

  @impl true
  def handle_info({ECMSWeb.FeedbackLive.FormComponent, {:saved, feedback}}, socket) do
    {:noreply, stream_insert(socket, :feedback_collection, feedback)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    feedback = Training.get_feedback!(id)
    {:ok, _} = Training.delete_feedback(feedback)

    {:noreply, stream_delete(socket, :feedback_collection, feedback)}
  end
end
