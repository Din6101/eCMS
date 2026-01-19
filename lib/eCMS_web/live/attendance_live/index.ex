defmodule ECMSWeb.AttendanceLive.Index do
  use ECMSWeb, :live_view

  alias ECMS.Training
  alias ECMS.Repo
  alias ECMS.Accounts
  alias ECMS.DateTimeHelper
  alias Phoenix.LiveView.JS
  import Ecto.Query
  require Jason

  @impl true
  def mount(_params, _session, socket) do
    # Get students with avatars for face recognition
    students = Accounts.list_students()
    |> Enum.filter(& &1.avatar_url)
    |> Enum.map(&%{id: &1.id, name: &1.full_name, avatar_url: &1.avatar_url})

    socket =
      socket
      |> assign(:active_tab, "scanner")
      |> assign(:attendances_by_month, [])
      |> assign(:students_with_avatars, students)
      |> assign(:students_json, Jason.encode!(students))
      |> assign(:scanner_mode, "both")

    if connected?(socket) do
      attendances = Training.list_attendances()
      socket =
        socket
        |> stream(:attendances, attendances)
        |> assign(:attendances_by_month, group_attendances_by_month(attendances))
      {:ok, socket}
    else
      socket = stream(socket, :attendances, [])
      {:ok, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Attendance")
    |> assign(:attendance, nil)
  end

  @impl true
  def handle_info({ECMSWeb.AttendanceLive.FormComponent, {:saved, _attendance}}, socket) do
    attendances = Training.list_attendances()
    {:noreply,
     socket
     |> stream(:attendances, attendances)
     |> assign(:attendances_by_month, group_attendances_by_month(attendances))}
  end

  @impl true
  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    # Reload attendances when switching tabs to ensure fresh data
    attendances = Training.list_attendances()
    socket =
      socket
      |> assign(:active_tab, tab)
      |> assign(:attendances_by_month, group_attendances_by_month(attendances))
      |> stream(:attendances, attendances)

    {:noreply, socket}
  end

  @impl true
  def handle_event("change_scanner_mode", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, :scanner_mode, mode)}
  end

  @impl true
  def handle_event("start_scanner", _params, socket) do
    # Scanner is handled by JavaScript, just acknowledge the event
    {:noreply, socket}
  end

  @impl true
  def handle_event("stop_scanner", _params, socket) do
    # Scanner is handled by JavaScript, just acknowledge the event
    {:noreply, socket}
  end

  @impl true
  def handle_event("recognize_face", %{"user_id" => user_id} = params, socket) do
    require Logger
    Logger.info("=== FACE RECOGNITION EVENT RECEIVED ===")
    Logger.info("Full params: #{inspect(params)}")
    Logger.info("User ID: #{user_id}")
    Logger.info("Socket ID: #{inspect(socket.id)}")
    Logger.info("Socket connected?: #{inspect(connected?(socket))}")

    # Safely get current_user
    current_user_id = if socket.assigns[:current_user], do: socket.assigns.current_user.id, else: nil
    Logger.info("Current User ID: #{inspect(current_user_id)}")
    Logger.info("Current User exists?: #{inspect(socket.assigns[:current_user] != nil)}")

    case Integer.parse(user_id) do
      {parsed_user_id, _} ->
        # Verify current_user exists
        if socket.assigns[:current_user] do
          scanned_by_id = socket.assigns.current_user.id

          # Verify user exists
          case Repo.get(Accounts.User, parsed_user_id) do
            nil ->
              Logger.warning("Student not found: user_id=#{parsed_user_id}")
              socket = put_flash(socket, :error, "Student not found")
              {:noreply, socket}

            user ->
              # Verify scanner exists
              case Repo.get(Accounts.User, scanned_by_id) do
                nil ->
                  Logger.error("Scanner not found: scanned_by_id=#{scanned_by_id}")
                  socket = put_flash(socket, :error, "Scanner account not found")
                  {:noreply, socket}

                _scanner ->
                  Logger.info("Creating attendance: user_id=#{parsed_user_id} (#{user.full_name}), scanned_by=#{scanned_by_id}")

                  # Check if attendance already exists for this student today (Malaysia time)
                  today = DateTimeHelper.today_malaysia()
                  start_of_day = DateTimeHelper.start_of_day_malaysia(today)
                  end_of_day = DateTimeHelper.end_of_day_malaysia(today)

                  # Convert to UTC for database query
                  start_of_day_utc = DateTime.shift_zone!(start_of_day, "Etc/UTC")
                  end_of_day_utc = DateTime.shift_zone!(end_of_day, "Etc/UTC")

                  existing_attendance =
                    from(a in ECMS.Training.Attendance,
                      where: a.user_id == ^parsed_user_id and a.scanned_at >= ^start_of_day_utc and a.scanned_at <= ^end_of_day_utc,
                      order_by: [desc: a.scanned_at],
                      limit: 1
                    )
                    |> Repo.one()

                  if existing_attendance do
                    Logger.info("Attendance already exists for student #{parsed_user_id} today, skipping duplicate")
                    student_name = if user.full_name, do: user.full_name, else: "Unknown"
                    socket = put_flash(socket, :info, "Attendance already recorded for #{student_name} today")
                    {:noreply, socket}
                  else
                    Logger.info("About to call Training.create_attendance_from_face")
                    Logger.info("Parameters: user_id=#{parsed_user_id}, scanned_by_id=#{scanned_by_id}")

                    result = Training.create_attendance_from_face(parsed_user_id, scanned_by_id)
                    Logger.info("create_attendance_from_face result: #{inspect(result)}")

                    case result do
                      {:ok, attendance} ->
                        Logger.info("Attendance created successfully!")
                        Logger.info("Attendance ID: #{attendance.id}")
                        Logger.info("Attendance user_id: #{attendance.user_id}")
                        Logger.info("Attendance scanned_by: #{attendance.scanned_by}")
                        Logger.info("Attendance scanned_at: #{inspect(attendance.scanned_at)}")

                        # Reload attendance with all associations
                        attendance =
                          attendance.id
                          |> Training.get_attendance!()

                        attendance =
                          if Ecto.assoc_loaded?(attendance.user) do
                            attendance
                          else
                            Repo.preload(attendance, [:user, :scanner, :course])
                          end

                        # Reload all attendances
                        attendances = Training.list_attendances()
                        Logger.info("Total attendances in database: #{length(attendances)}")

                        student_name = if attendance.user, do: attendance.user.full_name, else: "Unknown"

                        Logger.info("Updating socket with attendance for: #{student_name}")

                        socket =
                          socket
                          |> put_flash(:info, "Face recognized! Attendance recorded for #{student_name}")
                          |> stream(:attendances, attendances, reset: true)
                          |> assign(:attendances_by_month, group_attendances_by_month(attendances))

                        Logger.info("Socket updated, returning noreply")

                        # Use noreply since we're updating the stream which will trigger a UI update
                        # This is more reliable than waiting for a reply with connection issues
                        {:noreply, socket}

                      {:error, changeset} ->
                        Logger.error("=== ATTENDANCE CREATION FAILED ===")
                        Logger.error("Changeset valid?: #{inspect(changeset.valid?)}")
                        Logger.error("Changeset errors: #{inspect(changeset.errors)}")
                        Logger.error("Changeset changes: #{inspect(changeset.changes)}")
                        Logger.error("Changeset data: #{inspect(changeset.data)}")

                        error_message =
                          changeset
                          |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
                            Enum.reduce(opts, msg, fn {key, value}, acc ->
                              String.replace(acc, "%{#{key}}", to_string(value))
                            end)
                          end)
                          |> Enum.map(fn {field, errors} -> "#{field}: #{Enum.join(errors, ", ")}" end)
                          |> Enum.join("; ")

                        error_msg = if error_message != "", do: "Failed to record attendance: #{error_message}", else: "Failed to record attendance"
                        Logger.error("Error message: #{error_msg}")

                        socket = put_flash(socket, :error, error_msg)

                        {:noreply, socket}
                    end
                  end
              end
          end
        else
          Logger.error("No current_user in socket assigns")
          socket = put_flash(socket, :error, "You must be logged in to recognize faces")
          {:noreply, socket}
        end

      :error ->
        Logger.warning("Invalid user ID format: #{user_id}")
        socket = put_flash(socket, :error, "Invalid user ID format")
        {:noreply, socket}
    end
  end

  def handle_event("scan_qr", %{"qr_data" => qr_data}, socket) do
    require Logger
    Logger.info("=== SCAN_QR EVENT RECEIVED ===")
    Logger.info("QR Data: #{qr_data}")
    Logger.info("Current User ID: #{socket.assigns.current_user.id}")

    case parse_qr_data(qr_data) do
      {:ok, user_id} ->
        # Verify current_user exists
        if socket.assigns[:current_user] do
          scanned_by_id = socket.assigns.current_user.id

          # Verify user exists
          case Repo.get(Accounts.User, user_id) do
            nil ->
              Logger.warning("Student not found: user_id=#{user_id}")
              {:noreply, put_flash(socket, :error, "Student not found with ID: #{user_id}")}

            user ->
              # Verify scanner exists
              case Repo.get(Accounts.User, scanned_by_id) do
                nil ->
                  Logger.error("Scanner not found: scanned_by_id=#{scanned_by_id}")
                  {:noreply, put_flash(socket, :error, "Scanner account not found")}

                _scanner ->
                  # Debug: Log the parameters
                  Logger.info("Creating attendance: user_id=#{user_id} (#{user.full_name}), scanned_by=#{scanned_by_id}")

                  # Check if attendance already exists for this student today (Malaysia time)
                  today = DateTimeHelper.today_malaysia()
                  start_of_day = DateTimeHelper.start_of_day_malaysia(today)
                  end_of_day = DateTimeHelper.end_of_day_malaysia(today)

                  # Convert to UTC for database query
                  start_of_day_utc = DateTime.shift_zone!(start_of_day, "Etc/UTC")
                  end_of_day_utc = DateTime.shift_zone!(end_of_day, "Etc/UTC")

                  existing_attendance =
                    from(a in ECMS.Training.Attendance,
                      where: a.user_id == ^user_id and a.scanned_at >= ^start_of_day_utc and a.scanned_at <= ^end_of_day_utc,
                      order_by: [desc: a.scanned_at],
                      limit: 1
                    )
                    |> Repo.one()

                  if existing_attendance do
                    Logger.info("Attendance already exists for student #{user_id} today, skipping duplicate")
                    student_name = if user.full_name, do: user.full_name, else: "Unknown"
                    {:noreply, put_flash(socket, :info, "Attendance already recorded for #{student_name} today")}
                  else
                    case Training.create_attendance_from_qr(user_id, scanned_by_id) do
                    {:ok, attendance} ->
                      Logger.info("Attendance created successfully: #{attendance.id}")

                      # Reload attendance with all associations to ensure we have fresh data
                      attendance =
                        attendance.id
                        |> Training.get_attendance!()

                      # Verify associations are loaded
                      attendance =
                        if Ecto.assoc_loaded?(attendance.user) do
                          attendance
                        else
                          Repo.preload(attendance, [:user, :scanner, :course])
                        end

                      # Reload all attendances to ensure we have the latest data
                      attendances = Training.list_attendances()

                      # Get student name safely
                      student_name = if attendance.user, do: attendance.user.full_name, else: "Unknown"

                      # Reload stream with all attendances to prevent duplicates
                      {:noreply,
                       socket
                       |> put_flash(:info, "QR detected. Thank you! Attendance recorded for #{student_name}")
                       |> stream(:attendances, attendances, reset: true)
                       |> assign(:attendances_by_month, group_attendances_by_month(attendances))}

                    {:error, changeset} ->
                      # Extract validation errors
                      Logger.error("Failed to create attendance: #{inspect(changeset.errors)}")
                      Logger.error("Changeset changes: #{inspect(changeset.changes)}")
                      Logger.error("Changeset data: #{inspect(changeset.data)}")

                      error_message =
                        changeset
                        |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
                          Enum.reduce(opts, msg, fn {key, value}, acc ->
                            String.replace(acc, "%{#{key}}", to_string(value))
                          end)
                        end)
                        |> Enum.map(fn {field, errors} -> "#{field}: #{Enum.join(errors, ", ")}" end)
                        |> Enum.join("; ")

                      error_msg = if error_message != "", do: "Failed to record attendance: #{error_message}", else: "Failed to record attendance"

                      {:noreply, put_flash(socket, :error, error_msg)}
                    end
                  end
              end
          end
        else
          Logger.error("No current_user in socket assigns")
          {:noreply, put_flash(socket, :error, "You must be logged in to scan QR codes")}
        end

      {:error, reason} ->
        Logger.warning("Failed to parse QR data: #{reason}, QR Data: #{qr_data}")
        {:noreply, put_flash(socket, :error, "Invalid QR code: #{reason}")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    attendance = Training.get_attendance!(id)
    {:ok, _} = Training.delete_attendance(attendance)

    attendances = Training.list_attendances()
    {:noreply,
     socket
     |> stream_delete(:attendances, attendance)
     |> assign(:attendances_by_month, group_attendances_by_month(attendances))}
  end

  defp group_attendances_by_month(attendances) when is_list(attendances) do
    attendances
    |> Enum.filter(& &1)  # Filter out any nil values
    # Deduplicate: keep only the latest attendance per user per day
    |> Enum.group_by(& &1.user_id)
    |> Enum.map(fn {_user_id, user_attendances} ->
      # For each user, group by date (in Malaysia timezone) and take the latest one per day
      user_attendances
      |> Enum.group_by(fn att ->
        if att.scanned_at do
          att.scanned_at
          |> DateTimeHelper.to_malaysia_time()
          |> NaiveDateTime.to_date()
        else
          att.inserted_at
          |> DateTimeHelper.to_malaysia_time()
          |> NaiveDateTime.to_date()
        end
      end)
      |> Enum.map(fn {_date, day_attendances} ->
        # Take the latest attendance for this day
        day_attendances
        |> Enum.sort_by(& &1.scanned_at || &1.inserted_at, {:desc, DateTime})
        |> List.first()
      end)
    end)
    |> List.flatten()
    |> Enum.group_by(fn attendance ->
      if attendance.scanned_at do
        scanned_at =
          attendance.scanned_at
          |> DateTimeHelper.to_malaysia_time()
          |> NaiveDateTime.to_date()
        {scanned_at.year, scanned_at.month}
      else
        inserted_at =
          attendance.inserted_at
          |> DateTimeHelper.to_malaysia_time()
          |> NaiveDateTime.to_date()
        {inserted_at.year, inserted_at.month}
      end
    end)
    |> Enum.map(fn {{year, month}, atts} ->
      month_name = Date.new!(year, month, 1) |> Calendar.strftime("%B %Y")
      sorted_atts = atts |> Enum.sort_by(& &1.scanned_at || &1.inserted_at, {:desc, DateTime})
      {{year, month}, {month_name, sorted_atts}}
    end)
    |> Enum.sort(fn {{year1, month1}, _}, {{year2, month2}, _} ->
      {year1, month1} > {year2, month2}
    end)
    |> Enum.map(fn {_, {month_name, atts}} -> {month_name, atts} end)
  end

  defp group_attendances_by_month(_), do: []

  defp parse_qr_data(qr_data) do
    # QR code format: "STUDENT_ID:user_id"
    case String.split(qr_data, ":") do
      ["STUDENT_ID", user_id] ->
        case Integer.parse(user_id) do
          {id, _} -> {:ok, id}
          :error -> {:error, "Invalid user ID format"}
        end

      _ ->
        {:error, "Invalid QR code format"}
    end
  end

end
