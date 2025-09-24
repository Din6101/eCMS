# Test Gmail API email sending
IO.puts("🧪 Testing Gmail API Integration...")

# Check if refresh token is set
refresh_token = System.get_env("GMAIL_REFRESH_TOKEN")

if refresh_token do
  IO.puts("✅ Refresh token found: #{String.slice(refresh_token, 0, 10)}...")

  IO.puts("\n📧 Sending test email via Gmail API...")

  try do
    result = ECMS.Email.send_test_email()
    IO.puts("🎉 SUCCESS! Email sent via Gmail API!")
    IO.inspect(result, label: "Result")

    IO.puts("\n📬 Check your Gmail inbox:")
    IO.puts("   - Email: myecms2025@gmail.com")
    IO.puts("   - Subject: ECMS Test Email via Gmail API")
    IO.puts("   - Look in Inbox or Spam folder")

  rescue
    e ->
      IO.puts("❌ Error sending email: #{inspect(e)}")
      IO.puts("\n💡 Make sure your refresh token is valid and Gmail API is enabled")
  end
else
  IO.puts("❌ No refresh token found!")
  IO.puts("\n🔧 Please set the refresh token:")
  IO.puts("   $env:GMAIL_REFRESH_TOKEN=\"your_refresh_token_here\"")
  IO.puts("\n📋 To get refresh token:")
  IO.puts("   1. Run: mix run get_oauth_url.exs")
  IO.puts("   2. Complete OAuth2 flow")
  IO.puts("   3. Run: mix run exchange_code.exs YOUR_CODE")
end

IO.puts("\n✅ Gmail API test completed!")
