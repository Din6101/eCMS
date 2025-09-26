# Gmail SMTP Setup Guide for eCMS

## Prerequisites

1. **Gmail Account**: You need a Gmail account
2. **2-Factor Authentication**: Must be enabled on your Gmail account
3. **App Password**: Generate an app-specific password (not your regular Gmail password)

## Step 1: Enable 2-Factor Authentication

1. Go to [Google Account Security](https://myaccount.google.com/security)
2. Under "Signing in to Google", click "2-Step Verification"
3. Follow the setup process to enable 2FA

## Step 2: Generate App Password

1. Go to [Google Account Security](https://myaccount.google.com/security)
2. Under "Signing in to Google", click "App passwords"
3. Select "Mail" as the app and "Other" as the device
4. Enter "eCMS Application" as the device name
5. Click "Generate"
6. **Copy the 16-character password** (you won't see it again!)

## Step 3: Set Environment Variables

### For Development (Windows PowerShell):
```powershell
$env:SMTP_USERNAME="your-gmail@gmail.com"
$env:SMTP_PASSWORD="your-16-character-app-password"
$env:SMTP_RELAY="smtp.gmail.com"
$env:SMTP_PORT="587"
```

### For Production:
Set these environment variables in your production environment:
- `SMTP_USERNAME`: your-gmail@gmail.com
- `SMTP_PASSWORD`: your-16-character-app-password
- `SMTP_RELAY`: smtp.gmail.com
- `SMTP_PORT`: 587

## Step 4: Test the Configuration

Run this in your Phoenix console:
```elixir
# Start the Phoenix console
iex -S mix

# Test email sending
ECMS.Email.send_test_email()
```

## Troubleshooting

### Common Issues:

1. **"Invalid credentials"**: 
   - Make sure you're using the app password, not your regular Gmail password
   - Ensure 2FA is enabled

2. **"TLS failed"**:
   - Check that port 587 is not blocked by firewall
   - Verify TLS configuration in config files

3. **"Authentication failed"**:
   - Double-check the app password
   - Ensure the Gmail account has "Less secure app access" disabled (use app passwords instead)

### Security Notes:

- Never commit app passwords to version control
- Use environment variables for all credentials
- Consider using a dedicated Gmail account for your application
- Regularly rotate app passwords

## Configuration Summary

Your application is now configured with:
- **SMTP Server**: smtp.gmail.com
- **Port**: 587 (STARTTLS)
- **Authentication**: App password
- **TLS**: v1.2/v1.3 with proper SNI
- **Retries**: 3 attempts
