defmodule ECMSWeb.CertificationLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Training.Certification
  alias ECMS.Accounts

  @impl true
  def mount(_params, %{"user_token" => token} = _session, socket) do
    case Accounts.get_user_by_session_token(token) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Access denied")
         |> redirect(to: "/")}

      current_user ->
        if current_user.role == "admin" do
          {:ok,
           socket
           |> assign(:current_user, current_user)
           |> assign(:page_title, "Listing Certifications")
           |> assign(:certification, nil)
           |> stream(:certifications, Training.list_certifications())}
        else
          {:ok,
           socket
           |> put_flash(:error, "Access denied")
           |> redirect(to: "/")}
        end
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Certification")
    |> assign(:certification, Training.get_certification!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Certification")
    |> assign(:certification, %Certification{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Certifications")
    |> assign(:certification, nil)
  end

  @impl true
  def handle_info({ECMSWeb.CertificationLive.FormComponent, {:saved, certification}}, socket) do
    {:noreply, stream_insert(socket, :certifications, certification)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    certification = Training.get_certification!(id)
    {:ok, _} = Training.delete_certification(certification)

    {:noreply, stream_delete(socket, :certifications, certification)}
  end
end
