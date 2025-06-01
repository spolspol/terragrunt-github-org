# GPG Commit Signing Configuration

This guide explains how to configure GPG commit signing for GitHub to verify the authenticity of your commits.

## Overview

Commit signing allows you to cryptographically sign your commits and tags, providing verification that they actually came from you. GitHub will display a "Verified" badge next to signed commits.

## Prerequisites

- Git installed on your system
- A GitHub account
- GPG (GNU Privacy Guard) installed

### Installing GPG

**macOS:**
```bash
# Using Homebrew
brew install gnupg

# Using MacPorts
sudo port install gnupg2
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install gnupg
```

**Windows:**
- Download and install [Gpg4win](https://www.gpg4win.org/)
- Or use Windows Subsystem for Linux (WSL)

## Step 1: Generate a GPG Key

1. **Generate a new GPG key pair:**
   ```bash
   gpg --full-generate-key
   ```

2. **Select key type:** Choose `RSA and RSA` (option 1)

3. **Set key size:** Enter `4096` for maximum security

4. **Set expiration:** Choose an appropriate expiration (e.g., `1y` for 1 year, or `0` for no expiration)

5. **Enter user information:**
   - **Real name:** Your full name
   - **Email address:** The email associated with your GitHub account
   - **Comment:** Optional description

6. **Set a strong passphrase** when prompted

## Step 2: List and Export Your GPG Key

1. **List your GPG keys:**
   ```bash
   gpg --list-secret-keys --keyid-format=long
   ```

2. **Find your key ID** (the string after `sec rsa4096/`):
   ```
   sec   rsa4096/ABC123DEF456 2024-01-01 [SC]
   ```
   In this example, `ABC123DEF456` is your key ID.

3. **Export your public key:**
   ```bash
   gpg --armor --export ABC123DEF456
   ```

4. **Copy the entire output** including:
   ```
   -----BEGIN PGP PUBLIC KEY BLOCK-----
   [key content]
   -----END PGP PUBLIC KEY BLOCK-----
   ```

## Step 3: Add GPG Key to GitHub

1. **Go to GitHub Settings:**
   - Navigate to [GitHub.com](https://github.com)
   - Click your profile picture → **Settings**

2. **Access SSH and GPG keys:**
   - In the left sidebar, click **SSH and GPG keys**

3. **Add new GPG key:**
   - Click **New GPG key**
   - Paste your public key in the text area
   - Click **Add GPG key**

4. **Confirm with your password** if prompted

## Step 4: Configure Git to Use GPG

1. **Tell Git about your GPG key:**
   ```bash
   git config --global user.signingkey ABC123DEF456
   ```

2. **Set your Git email** (must match the email in your GPG key):
   ```bash
   git config --global user.email "your-email@example.com"
   ```

3. **Enable commit signing by default:**
   ```bash
   git config --global commit.gpgsign true
   ```

4. **Enable tag signing by default:**
   ```bash
   git config --global tag.gpgsign true
   ```

## Step 5: Configure GPG for Your Shell

Add this to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# GPG Configuration
export GPG_TTY=$(tty)
```

**For macOS users with GPG Suite:**
```bash
# Use GPG Suite's pinentry
export GPG_TTY=$(tty)
export PATH="/usr/local/MacGPG2/bin:$PATH"
```

## Step 6: Test Your Configuration

1. **Create a test commit:**
   ```bash
   # Make a change
   echo "test" > test-file.txt
   git add test-file.txt
   git commit -m "Test signed commit"
   ```

2. **Verify the commit is signed:**
   ```bash
   git log --show-signature -1
   ```

3. **Push to GitHub and check for the "Verified" badge**

## Manual Signing (if not enabled globally)

If you haven't enabled global signing, you can sign individual commits:

```bash
# Sign a commit
git commit -S -m "Your commit message"

# Sign a tag
git tag -s v1.0.0 -m "Version 1.0.0"
```

## Troubleshooting

### Common Issues

**1. "gpg: signing failed: No such file or directory"**
```bash
export GPG_TTY=$(tty)
```

**2. "gpg: signing failed: Inappropriate ioctl for device"**
```bash
export GPG_TTY=$(tty)
# or configure pinentry
echo "pinentry-program /usr/bin/pinentry-curses" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
```

**3. "error: gpg failed to sign the data"**
- Verify your key exists: `gpg --list-secret-keys`
- Check Git configuration: `git config --global user.signingkey`
- Test GPG directly: `echo "test" | gpg --clearsign`

**4. Passphrase prompt issues on macOS:**
```bash
# Install pinentry-mac
brew install pinentry-mac

# Configure GPG to use it
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
```

### Verifying Your Setup

**Check Git configuration:**
```bash
git config --global --list | grep -E "(user|signing|gpg)"
```

**Verify GPG is working:**
```bash
echo "test" | gpg --clearsign
```

**Check GitHub recognizes your key:**
- Go to your GitHub profile
- Look for the "Verified" badge on recent commits

## Key Management Best Practices

1. **Backup your private key:**
   ```bash
   gpg --export-secret-keys ABC123DEF456 > private-key-backup.gpg
   ```

2. **Store the backup securely** (encrypted external drive, password manager, etc.)

3. **Set key expiration** and renew before expiry

4. **Revoke compromised keys:**
   ```bash
   gpg --gen-revoke ABC123DEF456 > revoke-certificate.asc
   ```

5. **Use a strong passphrase** and consider using a hardware security key

## Additional Resources

- [GitHub Documentation: Signing Commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
- [GitHub Documentation: Adding a GPG Key](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)
- [GPG Documentation](https://gnupg.org/documentation/)

## Repository-Specific Notes

For this repository (`tg-github-org`), commit signing helps ensure:
- Infrastructure changes are from verified contributors
- Terragrunt configurations maintain integrity
- GitHub organization management changes are authenticated

Contributors are encouraged to set up commit signing to maintain the security and integrity of the infrastructure management codebase.
