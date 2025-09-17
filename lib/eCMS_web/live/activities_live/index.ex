defmodule ECMSWeb.ActivitiesLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.Activities

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :activity, Training.list_activities())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Activities")
    |> assign(:activities, Training.get_activities!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Activities")
    |> assign(:activities, %Activities{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Activity")
    |> assign(:activities, nil)
  end

  @impl true
  def handle_info({ECMSWeb.ActivitiesLive.FormComponent, {:saved, activities}}, socket) do
    {:noreply, stream_insert(socket, :activity, activities)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    activities = Training.get_activities!(id)
    {:ok, _} = Training.delete_activities(activities)

    {:noreply, stream_delete(socket, :activity, activities)}
  end
end
