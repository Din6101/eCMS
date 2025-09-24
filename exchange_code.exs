# Script untuk exchange authorization code dengan refresh token
code = System.argv() |> List.first()

if code do
  IO.puts("🔄 Exchanging code for tokens...")
  IO.puts("Code: #{code}")

  case ECMS.GmailOAuth.exchange_code_for_token(code) do
    {:ok, response} ->
      IO.puts("\n✅ SUCCESS! Tokens received:")
      IO.inspect(response.body, label: "Response")

      # Parse the response to get refresh token
      case Jason.decode(response.body) do
        {:ok, %{"refresh_token" => refresh_token}} ->
          IO.puts("\n🎉 Refresh Token:")
          IO.puts(refresh_token)
          IO.puts("\n💾 Simpan refresh token ini:")
          IO.puts("export GMAIL_REFRESH_TOKEN=\"#{refresh_token}\"")
          IO.puts("\nAtau tambahkan ke config:")
          IO.puts("config :eCMS, gmail_refresh_token: \"#{refresh_token}\"")
        {:ok, response_data} ->
          IO.puts("\n⚠️  No refresh token in response:")
          IO.inspect(response_data, label: "Response Data")
        {:error, reason} ->
          IO.puts("\n❌ Error parsing response: #{reason}")
      end
    {:error, reason} ->
      IO.puts("\n❌ Error exchanging code:")
      IO.inspect(reason, label: "Error")
  end
else
  IO.puts("❌ Usage: mix run exchange_code.exs YOUR_CODE")
  IO.puts("\n💡 Dapatkan code dari:")
  IO.puts("mix run get_oauth_url.exs")
end
