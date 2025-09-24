defmodule ECMS.GmailAPI do
  @moduledoc """
  Gmail API integration untuk mengirim email
  """

  alias ECMS.GmailOAuth

  def send_email(to, subject, body) do
    # Get access token using refresh token
    case get_access_token() do
      {:ok, access_token} ->
        send_email_with_token(access_token, to, subject, body)
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_access_token do
    # You need to store refresh_token in your database or config
    # For now, we'll use a placeholder
    refresh_token = System.get_env("GMAIL_REFRESH_TOKEN")

    if refresh_token do
      GmailOAuth.get_access_token(refresh_token)
    else
      {:error, "No refresh token found. Please set GMAIL_REFRESH_TOKEN environment variable."}
    end
  end

  defp send_email_with_token(access_token, to, subject, body) do
    # Build RFC822 email format
    raw_email = build_rfc822_email(to, subject, body)

    # Encode email for Gmail API
    encoded_email = Base.url_encode64(raw_email)

    # Send via Gmail API using HTTP request
    send_via_gmail_api(access_token, encoded_email)
  end

  defp build_rfc822_email(to, subject, body) do
    """
    From: "ECMS Team" <myecms2025@gmail.com>
    To: #{to}
    Subject: #{subject}
    Content-Type: text/html; charset=UTF-8
    MIME-Version: 1.0

    #{body}
    """
  end

  defp send_via_gmail_api(access_token, encoded_email) do
    url = "https://gmail.googleapis.com/gmail/v1/users/me/messages/send"

    headers = [
      {"Authorization", "Bearer #{access_token}"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{raw: encoded_email})

    Finch.build(:post, url, headers, body)
    |> Finch.request(ECMS.Finch)
  end

  # Helper function to get authorization URL for OAuth2 setup
  def get_oauth_url do
    GmailOAuth.get_authorization_url()
  end

  # Helper function to exchange authorization code for tokens
  def exchange_code(code) do
    GmailOAuth.exchange_code_for_token(code)
  end
end
