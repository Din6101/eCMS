defmodule ECMS.Email do
  import Swoosh.Email
  alias ECMS.Mailer
  alias ECMS.Training.Schedule

  def send_test_email do
    email =
      new()
      |> from({"ECMS System", "myecms2025@gmail.com"})
      |> to({"User Test", "airuddinardiyan.hq.aws@gmail.com"})
      |> subject("ECMS Test Email")
      |> text_body("Hello, this is a test email sent from ECMS.")
      |> html_body("""
      <p>Hello, this is a <b>test email</b> sent from ECMS.</p>
      <p>View this email at: <a href="http://localhost:4000/dev/mailbox">http://localhost:4000/dev/mailbox</a></p>
      """)

    Mailer.deliver(email)
  end

  @spec send_schedule_notification(ECMS.Training.Schedule.t()) ::
          {:error, any()} | {:ok, any()}
  def send_schedule_notification(%Schedule{} = schedule) do
    trainer_name = schedule.trainer && Map.get(schedule.trainer, :full_name) || "Trainer"
    trainer_email = schedule.trainer && Map.get(schedule.trainer, :email)

    if is_binary(trainer_email) do
      date_text =
        case schedule.schedule_date do
          nil -> "TBD"
          d -> Calendar.strftime(d, "%d %b %Y")
        end

      time_text =
        case schedule.schedule_time do
          nil -> "--:--"
          t -> Calendar.strftime(t, "%H:%M")
        end

      status_text = schedule.status |> Atom.to_string() |> String.capitalize()

      subject_text =
        case schedule.course do
          nil -> "Course Schedule"
          course -> course.title || "Course Schedule"
        end

      email =
        new()
        |> from({"ECMS Admin", "noreply@ecms.com"})
        |> to({trainer_name, trainer_email})
        |> subject("Schedule Notification: " <> subject_text)
        |> html_body("""
        <div style="font-family: Arial, sans-serif;">
          <h2>New/Updated Schedule</h2>
          <p>Dear #{trainer_name},</p>
          <p>You have a schedule with the following details:</p>
          <ul>
            <li><b>Course</b>: #{(schedule.course && schedule.course.title) || "-"}</li>
            <li><b>Date</b>: #{date_text}</li>
            <li><b>Time</b>: #{time_text}</li>
            <li><b>Duration</b>: #{schedule.duration || "-"} minutes</li>
            <li><b>Venue</b>: #{schedule.venue || "-"}</li>
            <li><b>Status</b>: #{status_text}</li>
          </ul>
          <p>Notes: #{schedule.notes || "-"}</p>
          <p>Thank you.</p>
        </div>
        """)

      Mailer.deliver(email)
    else
      {:error, :missing_recipient}
    end
  end
end
