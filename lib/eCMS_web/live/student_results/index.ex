defmodule ECMSWeb.StudentResults.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    results = Training.list_results_for_student(current_user.id)

    {:ok, assign(socket, results: results)}
  end
end
