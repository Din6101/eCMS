# Script untuk mendapatkan OAuth2 authorization URL
IO.puts("🔗 Gmail OAuth2 Setup")
IO.puts("===================")

# Get authorization URL
url = ECMS.GmailOAuth.get_authorization_url()

IO.puts("\n📋 Langkah-langkah:")
IO.puts("1. Buka URL di bawah ini di browser:")
IO.puts("2. Login dengan Gmail account: myecms2025@gmail.com")
IO.puts("3. Approve permissions")
IO.puts("4. Google akan redirect ke: http://localhost:4000/?code=XXXX")
IO.puts("5. Copy code=XXXX dari URL")
IO.puts("6. Jalankan: mix run exchange_code.exs CODE_DARI_URL")

IO.puts("\n🔗 Authorization URL:")
IO.puts(url)

IO.puts("\n💡 Setelah dapat code, jalankan:")
IO.puts("mix run exchange_code.exs YOUR_CODE_HERE")
