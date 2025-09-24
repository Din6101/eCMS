defmodule ECMSWeb.StudentCertification.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training

  @impl true
def mount(_params, session, socket) do
  # Dapatkan current_user dari session
  user_token = session["user_token"]

  current_user =
    if user_token do
      # panggil function dari Accounts untuk dapatkan user
      ECMS.Accounts.get_user_by_session_token(user_token)
    else
      socket.assigns[:current_user]
    end

  cond do
    current_user && current_user.role == "student" ->
      certs = Training.list_certifications_for_student(current_user.id)

      {:ok,
       socket
       |> assign(:current_user, current_user)
       |> assign(:page_title, "My Certifications")
       |> assign(:certifications, certs)}

    true ->
      {:ok,
       socket
       |> put_flash(:error, "Access denied")
       |> redirect(to: "/")}
  end
end




  @impl true
  def handle_params(_params, _url, socket), do: {:noreply, socket}

  @impl true
  def handle_event("view", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: "/student/student_certification/#{id}")}
  end
end
