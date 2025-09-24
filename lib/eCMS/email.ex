defmodule ECMS.Email do
  import Swoosh.Email
  alias ECMS.Mailer

  def send_test_email do
    # Check if we're using Local adapter
    case Application.get_env(:eCMS, ECMS.Mailer) do
      [adapter: Swoosh.Adapters.Local] ->
        # Development: Use Local adapter
        send_test_email_local()
      _ ->
        # Use SMTP for production
        send_test_email_smtp()
    end
  end

  defp send_test_email_local do
    email =
      new()
      |> from({"ECMS System", "myecms2025@gmail.com"})
      |> to({"User Test", "recipient@example.com"})
      |> subject("ECMS Test Email (Development - Local Adapter)")
      |> text_body("Hello, this is a test email sent from ECMS using Local adapter for development.")
      |> html_body("""
      <p>Hello, this is a <b>test email</b> sent from ECMS using Local adapter for development.</p>
      <p>View this email at: <a href="http://localhost:4000/dev/mailbox">http://localhost:4000/dev/mailbox</a></p>
      """)

    Mailer.deliver(email)
  end

  defp send_test_email_smtp do
    email =
      new()
      |> from({"ECMS System", "myecms2025@gmail.com"})
      |> to({"User Test", "myecms2025@gmail.com"})
      |> subject("ECMS Test Email via Gmail SMTP")
      |> text_body("Hello, this is a test email sent from ECMS using Gmail SMTP.")
      |> html_body("""
      <p>Hello, this is a <b>test email</b> sent from ECMS using Gmail SMTP.</p>
      <p>This email was sent via Gmail SMTP with regular authentication.</p>
      <p>If you receive this, your Gmail configuration is working correctly!</p>
      """)

    # Use the configured Mailer (which will use SMTP settings from config)
    Mailer.deliver(email)
  end
end
