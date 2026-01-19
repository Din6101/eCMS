defmodule ECMSWeb.CertificationLive.FormComponent do
  use ECMSWeb, :live_component
  alias ECMS.Training

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage certification records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="certification-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        multipart
        class="text-black"
      >
        <.input
          type="select"
          field={@form[:user_id]}
          label="Student"
          options={for s <- @students, do: {s.full_name, s.id}}
        />

        <.input
          type="select"
          field={@form[:course_id]}
          label="Course"
          options={for c <- @courses, do: {c.title, c.id}}
        />

        <div class="mb-4">
          <label class="block text-sm font-medium text-gray-700">Upload Certificate</label>

          <!-- Live file input -->
          <.live_file_input upload={@uploads.certificate} />

          <!-- Preview -->
          <%= for entry <- @uploads.certificate.entries do %>
          <div class="mt-2">
          <%= if entry.client_type in ["image/png", "image/jpeg", "image/jpg"] do %>
          <img src={entry.path} class="h-32 border" />
          <% else %>
          <p class="text-gray-700 text-sm">Uploaded file: <%= entry.client_name %></p>
          <% end %>
          </div>
          <% end %>

          <!-- Upload errors -->
          <%= for err <- upload_errors(@uploads.certificate) do %>
          <p class="text-red-600 text-sm"><%= Phoenix.Naming.humanize(err) %></p>
          <% end %>
        </div>


        <.input field={@form[:issued_at]} type="datetime-local" label="Issued at" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Certification</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{certification: certification} = assigns, socket) do
    students = ECMS.Accounts.list_users_by_role("student")
    courses = Training.list_courses()

    changeset = Training.change_certification(certification)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:students, students)
     |> assign(:courses, courses)
     |> assign(:form, to_form(changeset))
     |> allow_upload(:certificate,
       accept: ~w(.pdf .png .jpg .jpeg),
       max_entries: 1
     )}
  end

  @impl true
  def handle_event("validate", %{"certification" => params}, socket) do
    changeset =
      Training.change_certification(socket.assigns.certification, params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"certification" => params}, socket) do
    save_certification(socket, socket.assigns.action, params)
  end

  defp save_certification(socket, action, params) do
    uploaded_files =
      consume_uploaded_entries(socket, :certificate, fn %{path: path}, entry ->
        # Ensure the uploads folder exists
        uploads_dir = Path.join(["priv", "static", "uploads"])
        File.mkdir_p!(uploads_dir)

        # Get the original file extension
        original_ext = Path.extname(entry.client_name)

        # Generate destination path with proper extension
        filename = "#{System.system_time(:millisecond)}-#{Path.basename(path)}#{original_ext}"
        dest = Path.join(uploads_dir, filename)

        # Copy the file
        File.cp!(path, dest)

        {:ok, "/uploads/#{filename}"}
      end)

    certificate_url =
      case uploaded_files do
        [url] -> url
        _ -> Map.get(params, "certificate_url") || ""
      end

    params = Map.put(params, "certificate_url", certificate_url)

    case action do
      :edit ->
        case Training.update_certification(socket.assigns.certification, params) do
          {:ok, cert} ->
            notify_parent({:saved, cert})

            {:noreply,
             socket
             |> put_flash(:info, "Certification updated successfully")
             |> push_patch(to: socket.assigns.patch)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      :new ->
        case Training.create_certification(params) do
          {:ok, cert} ->
            notify_parent({:saved, cert})

            {:noreply,
             socket
             |> put_flash(:info, "Certification created successfully")
             |> push_patch(to: socket.assigns.patch)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end
    end
  end


  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
