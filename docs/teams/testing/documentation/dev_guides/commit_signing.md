---
title: Git Commit Signing
author: Al Bowles
revision_date: 2026-04-16
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---
# Creating your primary keypair

1. Initiate the keypair generation wizard

        gpg --full-generate-key --expert

1. Select option `(9) ECC and ECC` for the key type
1. Select option `(1) Curve 25519` for the elliptic curve
1. Set a validity period of your choice, ideally less than 1 year
1. Specify real name and email address to associate with this keypair. The email address must match your verified Github email address or be set to `your-github-username@users.noreply.github.com`.
1. Type a passphrase (twice)

# Create a signing keypair

1. Add a signing subkey

        gpg --expert --edit-key my@email.addr
        gpg> addkey

1. Select option `(10) ECC (sign only)` for the key type
1. Select option `(1) Curve 25519` for the elliptic curve
1. Set a validity period of your choice, ideally less than 1 year
1. Accept the prompts and type a passphrase (twice)
1. Save and exit

        gpg> save

# Create revocation certificate

    gpg --output my_email_addr.gpg-revocation-certificate --gen-revoke my@email.addr

# Back up your keypair
Export the *primary keypair* (put these somewhere very safe along with revocation certificate)

    gpg --export-secret-keys --armor my@email.addr > my_email_addr.private.gpg-key
    gpg --export --armor my@email.addr > my_email_addr.public.gpg-key

# Remove the *primary keypair* from your keyring

1. Export all subkeys from the new keypair to a file

        gpg --export-secret-subkeys my@email.addr > $HOME/.gnupg/subkeys

1. Delete primary key from keyring - *BE SURE TO BACK UP YOUR PRIMARY KEYPAIR FIRST!*

        gpg --delete-secret-key my@email.addr

1. Re-import the previously exported keys

        gpg --import $HOME/.gnupg/subkeys

1. Look for `sec#` instead of `sec` in the output - pound sign means signing subkey is *not* in the keypair located in the keyring

        gpg --list-secret-keys $HOME/.gnupg/secring.gpg

# Revoking a *signing keypair*

Find the *primary keypair* and import it (preferably into an ephemeral system like a liveUSB)

    gpg --import /path/to/my_email_addr.public.gpg-key /path/to/my_email_addr.private.gpg-key
    gpg --edit-key my@email.addr
    gpg> revkey
    [ passphrase twice ]
    gpg> save

# Renew an expired or expiring keypair

    gpg --edit-key my@email.addr
    [select a key]
    gpg> expire
    [specify an expiration]
    gpg> save

# Create a single signed git commit

    git commit -S -m "my awesome signed commit"

# Configure git to always sign commits with a specified key

    $ gpg --list-secret-keys --keyid-format=long # grab the fingerprint from the 'sec' line
    git config [--global] commit.gpgsign true
    git config [--global] user.signingkey DEADB33FBAD1D3A

# Configure VSCode to sign commits

    # User or workspace setting
    "git.enableCommitSigning": true

# Upload your public key to a keyserver

    gpg --keyserver pgp.mit.edu --send-keys 0xDEADB33FBAD1D3A

# Verify your key has been published

    gpg --keyserver pgp.mit.edu --search-key my@email.addr

# References

[OpenPGP Best Practices](https://riseup.net/en/security/message-security/openpgp/best-practices#key-configuration)<br>
[Github: Signing Commits](https://docs.github.com/en/enterprise-server@3.5/authentication/managing-commit-signature-verification/signing-commits)<br>
[Braincoke's Log: Create a GPG Key](https://blog.braincoke.fr/security/create-a-gpg-key/)<br>
[Creating the Perfect GPG Keypair](https://alexcabal.com/creating-the-perfect-gpg-keypair)<br>
[Digital Neanderthal: Generate GPG Keys With Curve Ed25519](https://www.digitalneanderthal.com/post/gpg/)<br>

{% include 'teams/testing/content_bottom.md' %}

