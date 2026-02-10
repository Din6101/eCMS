# Fix Elixir dependency build issues (run this script from PowerShell AFTER closing Cursor/VS Code)
# The ElixirLS language server holds file locks that prevent Mix from cleaning/rebuilding deps

Write-Host "Cleaning _build directory..." -ForegroundColor Yellow
if (Test-Path "_build") {
    Remove-Item -Recurse -Force "_build" -ErrorAction SilentlyContinue
    if (Test-Path "_build") {
        Write-Host "ERROR: Could not remove _build. Make sure Cursor/VS Code is fully closed." -ForegroundColor Red
        exit 1
    }
}
Write-Host "Done. Fetching and compiling dependencies..." -ForegroundColor Yellow
mix deps.get
mix deps.compile
Write-Host "Done! You can now reopen Cursor." -ForegroundColor Green
