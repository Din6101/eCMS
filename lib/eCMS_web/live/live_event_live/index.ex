defmodule ECMSWeb.LiveEventLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.LiveEvent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :live_events, Training.list_live_events())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Live event")
    |> assign(:live_event, Training.get_live_event!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Live event")
    |> assign(:live_event, %LiveEvent{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Live events")
    |> assign(:live_event, nil)
  end

  @impl true
  def handle_info({ECMSWeb.LiveEventLive.FormComponent, {:saved, live_event}}, socket) do
    {:noreply, stream_insert(socket, :live_events, live_event)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    live_event = Training.get_live_event!(id)
    {:ok, _} = Training.delete_live_event(live_event)

    {:noreply, stream_delete(socket, :live_events, live_event)}
  end
end
