---
title: Git-Commit – Signierung
author: Al Bowles
revision_date: 2026-04-16
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

# Erstellen Ihres primären Schlüsselpaares

1. Starten Sie den Assistenten zur Schlüsselpaargenerierung

        ```
         gpg --full-generate-key --expert
        ```

2. Wählen Sie für den Schlüsseltyp die Option `(9) ECC and ECC`

3. Wählen Sie Option `(1) Curve 25519` für die elliptische Kurve

4. Legen Sie eine Gültigkeitsdauer Ihrer Wahl fest, idealerweise weniger als 1 Jahr

5. Geben Sie Ihren echten Namen und Ihre E-Mail-Adresse an, die diesem Schlüsselpaar zugeordnet werden sollen. Die E-Mail-Adresse muss mit Ihrer verifizierten GitHub-E-Mail-Adresse übereinstimmen oder auf `your-github-username@users.noreply.github.com` gesetzt sein.

6. Geben Sie eine Passphrase ein (zweimal)

# Erstellen eines Signaturschlüsselpaares

1. Fügen Sie einen Signatur-Unterschlüssel hinzu

        ```
         gpg --expert --edit-key my@email.addr
         gpg> addkey
        ```

2. Wählen Sie für den Schlüsseltyp die Option `(10) ECC (sign only)`.

3. Wählen Sie Option `(1) Curve 25519` für die elliptische Kurve

4. Legen Sie eine Gültigkeitsdauer Ihrer Wahl fest, idealerweise weniger als 1 Jahr

5. Bestätigen Sie die Eingabeaufforderungen und geben Sie eine Passphrase ein (zweimal)

6. Speichern und Beenden

        ```
         gpg> save
        ```

# Erstellung eines Widerrufszertifikats

    ```
    gpg --output my_email_addr.gpg-revocation-certificate --gen-revoke my@email.addr
    ```

# Sicherungskopie Ihres Schlüsselpaares

Exportieren Sie das _primäre Schlüsselpaar_ (bewahren Sie diese zusammen mit dem Widerrufszertifikat an einem sehr sicheren Ort auf)

    ```
    gpg --export-secret-keys --armor my@email.addr > my_email_addr.private.gpg-key
    gpg --export --armor my@email.addr > my_email_addr.public.gpg-key
    ```

# Entfernen des _primären Schlüsselpaares_ von Ihrem Schlüsselbund

1. Export aller Unterschlüssel des neuen Schlüsselpaares in eine Datei

        ```
         gpg --export-secret-subkeys my@email.addr > $HOME/.gnupg/subkeys
        ```

2. Primärschlüssel aus dem Schlüsselbund löschen – _SICHERN SIE ZUERST IHR PRIMÄRES KEYPAAR!_

        ```
         gpg --delete-secret-key my@email.addr
        ```

3. Die zuvor exportierten Schlüssel erneut importieren

        ```
         gpg --import $HOME/.gnupg/subkeys
        ```

4. Suchen Sie in der Ausgabe nach `sec#` anstelle von `sec` – das Raute-Zeichen bedeutet, dass der Signatur-Unterschlüssel _nicht_ im Schlüsselpaar aus dem Schlüsselring enthalten ist

        ```
         gpg --list-secret-keys $HOME/.gnupg/secring.gpg
        ```

# Widerruf eines _Signaturschlüsselpaares_

Suchen Sie das _primäre Schlüsselpaar_ und importieren Sie es (vorzugsweise in ein temporäres System wie einen Live-USB-Stick)

    ```
    gpg --import /path/to/my_email_addr.public.gpg-key /path/to/my_email_addr.private.gpg-key
    gpg --edit-key my@email.addr
    gpg> revkey
    [ passphrase twice ]
    gpg> save
    ```

# Erneuern Sie ein abgelaufenes oder demnächst ablaufendes Schlüsselpaar

    ```
    gpg --edit-key my@email.addr
    [select a key]
    gpg> expire
    [specify an expiration]
    gpg> save
    ```

# Einen einzelnen signierten Git-Commit erstellen

    ```
    git commit -S -m "my awesome signed commit"
    ```

# Konfigurieren Sie Git so, dass Commits immer mit einem bestimmten Schlüssel signiert werden

    ```
    $ gpg --list-secret-keys --keyid-format=long # grab the fingerprint from the 'sec' line
    git config [--global] commit.gpgsign true
    git config [--global] user.signingkey DEADB33FBAD1D3A
    ```

# Konfigurieren Sie VSCode so, dass Commits signiert werden

    ```
    # User or workspace setting
    "git.enableCommitSigning": true
    ```

# Laden Sie Ihren öffentlichen Schlüssel auf einen Schlüsselserver hoch

    ```
    gpg --keyserver pgp.mit.edu --send-keys 0xDEADB33FBAD1D3A
    ```

# Überprüfen Sie, ob Ihr Schlüssel veröffentlicht wurde.

    ```
    gpg --keyserver pgp.mit.edu --search-key my@email.addr
    ```

# Referenzen

[OpenPGP Best Practices](https://riseup.net/en/security/message-security/openpgp/best-practices#key-configuration)<br>
[Github: Signing Commits](https://docs.github.com/en/enterprise-server@3.5/authentication/managing-commit-signature-verification/signing-commits)<br>
[Braincoke's Log: Create a GPG Key](https://blog.braincoke.fr/security/create-a-gpg-key/)<br>
[Creating the Perfect GPG Keypair](https://alexcabal.com/creating-the-perfect-gpg-keypair)<br>
[Digital Neanderthal: Generate GPG Keys With Curve Ed25519](https://web.archive.org/web/20240512060111/https://www.digitalneanderthal.com/post/gpg/)<br>

{% include 'teams/testing/content_bottom.md' %}

