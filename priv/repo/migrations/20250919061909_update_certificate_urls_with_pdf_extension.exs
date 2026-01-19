defmodule ECMS.Repo.Migrations.UpdateCertificateUrlsWithPdfExtension do
  use Ecto.Migration

  def up do
    # Update all certificate URLs to include .pdf extension
    execute """
    UPDATE certifications
    SET certificate_url = certificate_url || '.pdf'
    WHERE certificate_url NOT LIKE '%.pdf'
    """
  end

  def down do
    # Remove .pdf extension from certificate URLs
    execute """
    UPDATE certifications
    SET certificate_url = REPLACE(certificate_url, '.pdf', '')
    WHERE certificate_url LIKE '%.pdf'
    """
  end
end
