defmodule ECMSWeb.ActivitiesLive.Show do
  use ECMSWeb, :live_view

  alias ECMS.Training

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:activities, Training.get_activities!(id))}
  end

  defp page_title(:show), do: "Show Activities"
  defp page_title(:edit), do: "Edit Activities"
end
