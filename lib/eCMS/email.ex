defmodule ECMS.Email do
  import Swoosh.Email
  alias ECMS.Mailer

  def send_test_email do
    email =
      new()
      |> from({"ECMS System", "noreply@ecms.com"})
      |> to({"User Test", "student@example.com"})
      |> subject("ECMS Test Email")
      |> text_body("Hello, this is a test email sent from ECMS.")
      |> html_body("""
      <p>Hello, this is a <b>test email</b> sent from ECMS.</p>
      <p>View this email at: <a href="http://localhost:4000/dev/mailbox">http://localhost:4000/dev/mailbox</a></p>
      """)

    Mailer.deliver(email)
  end
end
