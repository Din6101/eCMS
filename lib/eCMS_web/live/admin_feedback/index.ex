defmodule ECMSWeb.AdminFeedback.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training

  @impl true
  def mount(_params, _session, socket) do
    feedback_list = Training.list_feedback()
    {:ok, assign(socket, :feedback_list, feedback_list)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, assign(socket, :page_title, "Feedback from Trainers")}
  end
end
