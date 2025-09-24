# Test clean email system
IO.puts("🧪 Testing Clean Email System...")

# Check configuration
config = Application.get_env(:eCMS, ECMS.Mailer)
IO.puts("\n📋 Current Configuration:")
IO.inspect(config, label: "Config")

# Test email sending
IO.puts("\n📧 Sending test email...")
try do
  result = ECMS.Email.send_test_email()
  IO.puts("🎉 SUCCESS! Email sent successfully!")
  IO.inspect(result, label: "Result")

  IO.puts("\n📬 View emails in development mailbox:")
  IO.puts("   - Start your Phoenix server: mix phx.server")
  IO.puts("   - Visit: http://localhost:4000/dev/mailbox")
  IO.puts("   - You'll see all sent emails there!")

rescue
  e ->
    IO.puts("❌ Error sending email: #{inspect(e)}")
end

IO.puts("\n✅ Clean email system test completed!")
