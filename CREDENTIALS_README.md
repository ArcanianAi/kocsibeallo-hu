# Production Credentials Management

## 🔐 Storing Production Credentials

This project uses a `.credentials` file to store production environment information securely.

---

## 📝 Setup Instructions

### 1. Copy the Example File

```bash
cp .credentials.example .credentials
```

### 2. Fill in Your Production Values

Edit `.credentials` and add your actual Cloudways production credentials:

```bash
nano .credentials
# or
code .credentials
```

### 3. Never Commit the Real Credentials File

The `.credentials` file is in `.gitignore` and will **never** be committed to Git.

**Only `.credentials.example` is committed** (with placeholder values).

---

## 📋 What's Stored in .credentials

### Production Site Information
- Live site URL
- Admin URL
- Environment name

### Cloudways Platform Access
- Platform login URL
- Email address
- API key

### SSH/SFTP Access
- Server hostname/IP
- Port number
- Username
- Password
- SSH key path

### Database Credentials
- Host
- Port
- Database name
- Username
- Password

### Redis Cache
- Host (localhost)
- Port (6379)
- Password (if set)
- Enabled status

### phpMyAdmin Access
- URL
- Username
- Password

### Git Deployment Info
- Repository URL
- Branch name
- Deployment path

---

## 🔍 Where to Find Credentials

All Cloudways credentials can be found at:

**Cloudways Platform > Your Application > Access Details**

This includes:
- SSH/SFTP credentials
- Database credentials
- Redis credentials
- Application URL

---

## 🔒 Security Best Practices

### DO ✅
- Keep `.credentials` file locally only
- Update credentials when they change
- Share credentials securely (1Password, LastPass, etc.)
- Use environment variables in production settings.php
- Regularly rotate passwords

### DON'T ❌
- Commit `.credentials` to Git (it's in .gitignore)
- Share credentials via email or chat
- Use the same password for multiple services
- Store credentials in plain text elsewhere
- Commit real database passwords to Git

---

## 📚 Using Credentials in Scripts

Scripts can read from `.credentials` file:

```bash
#!/bin/bash
# Load credentials
source .credentials

# Use in commands
ssh $SSH_USER@$SSH_HOST -p $SSH_PORT
```

---

## 🔄 Updating Credentials

When production credentials change:

1. Update `.credentials` locally
2. Update production `settings.php` if needed
3. Notify team members securely
4. Document changes if necessary

---

## 🆘 If Credentials Are Compromised

1. **Immediately** change all affected passwords in Cloudways
2. Rotate SSH keys if compromised
3. Update `.credentials` with new values
4. Review access logs for unauthorized access
5. Update production settings.php

---

## 📁 File Structure

```
project-root/
├── .credentials                  # ❌ NOT in Git (your real credentials)
├── .credentials.example          # ✅ IN Git (template with placeholders)
├── CREDENTIALS_README.md         # ✅ IN Git (this file)
└── .gitignore                    # Ensures .credentials is never committed
```

---

## 🔗 Related Documentation

- **Cloudways Deployment:** `docs/CLOUDWAYS_DEPLOYMENT.md`
- **Environment URLs:** `docs/ENVIRONMENT_URLS.md`
- **Production Settings:** Settings.php configuration in deployment guide

---

**Security Note:** Never commit real credentials to version control. Always use the .example template for reference only.

**Last Updated:** 2025-11-16
