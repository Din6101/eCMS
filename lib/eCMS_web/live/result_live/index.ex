defmodule ECMSWeb.ResultLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.Result

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :results, Training.list_results())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Results")
    |> assign(:live_action, :index)
    |> assign(:result, nil)
    |> assign(:patch, ~p"/trainer/results")
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Result")
    |> assign(:live_action, :new)
    |> assign(:result, %Result{})
    |> assign(:patch, ~p"/trainer/results")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Result")
    |> assign(:live_action, :edit)
    |> assign(:result, Training.get_result!(id))
    |> assign(:patch, ~p"/trainer/results")
  end

  @impl true
  def handle_info({ECMSWeb.ResultLive.FormComponent, {:saved, result}}, socket) do
    {:noreply, stream_insert(socket, :results, result)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    result = Training.get_result!(id)
    {:ok, _} = Training.delete_result(result)

    {:noreply, stream_delete(socket, :results, result)}
  end
end
