defmodule ECMS.GmailAuth do
  @moduledoc """
  Handle OAuth2 token untuk Gmail API
  """

  def get_token! do
    {:ok, token} = Goth.fetch("https://mail.google.com/")
    token.token
  end
end
