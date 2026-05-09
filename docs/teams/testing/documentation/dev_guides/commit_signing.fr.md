---
title: Git Commit avec Signature
author: Al Bowles
contributors: Lukas Magauer
tested_with:
tags:
  - testing
  - git
revision_date: 2026-05-08
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

## Création de votre paire de clés principales

1. Lancez l'assistant de génération de paires de clés

   ```bash
   gpg --full-generate-key --expert
   ```

2. Sélectionnez l'option `(9) ECC et ECC` pour le type de clé

3. Sélectionnez l'option `(1) Curve 25519` pour la courbe elliptique

4. Définissez la période de validité de votre choix, idéalement inférieure à 1 an

5. Veuillez indiquer votre nom réel et votre adresse courriel à associer à cette paire de clés. L'adresse courriel doit correspondre à votre adresse courriel Github vérifiée ou être définie sur `your-github-username@users.noreply.github.com`.

6. Entrez une phrase secrète (deux fois)

## Création d'une paire de clés de signature

1. Ajoutez une sous-clé de signature

   ```bash
   gpg --expert --edit-key my@email.addr
   gpg> addkey
   ```

2. Sélectionnez l'option `(10) ECC (sign only)` pour le type de clé

3. Sélectionnez l'option `(1) Curve 25519` pour la courbe elliptique

4. Définissez la période de validité de votre choix, idéalement inférieure à 1 an

5. Confirmez les invites et saisissez une phrase secrète (deux fois)

6. Sauvegarder et quitter

   ```bash
   gpg> save
   ```

## Création d'un certificat de révocation

```bash
gpg --output my_email_addr.gpg-revocation-certificate --gen-revoke my@email.addr
```

## Sauvegardez votre paire de clés

Exportez la paire de clés primaires (conservez-les dans un endroit très sûr avec le certificat de révocation)

```bash
gpg --export-secret-keys --armor my@email.addr > my_email_addr.private.gpg-key
gpg --export --armor my@email.addr > my_email_addr.public.gpg-key
```

## Enlevez la paire de clés principale de votre porte-clés

1. Exportez toutes les sous-clés de la nouvelle paire de clés dans un fichier

   ```bash
   gpg --export-secret-subkeys my@email.addr > $HOME/.gnupg/subkeys
   ```

2. Supprimer la clé principale du porte-clés - _ASSUREZ-VOUS DE SAUVEGARDER VOTRE PAIRE DE CLÉS PRINCIPALES AU PRÉALABLE !_

   ```bash
   gpg --delete-secret-key my@email.addr
   ```

3. Réimportez les clés précédemment exportées

   ```bash
   gpg --import $HOME/.gnupg/subkeys
   ```

4. Cherchez `sec#` au lieu de `sec` dans le résultat ; le symbole dièse (#) indique que la sous-clé de signature ne fait _pas_ partie de la paire de clés située dans le trousseau.

   ```bash
   gpg --list-secret-keys $HOME/.gnupg/secring.gpg
   ```

## Révocation d'une _paire de clés de signature_

Trouvez la _paire de clés principales_ et importez-la (de préférence dans un système éphémère comme une clé USB live)

```bash
gpg --import /path/to/my_email_addr.public.gpg-key /path/to/my_email_addr.private.gpg-key
gpg --edit-key my@email.addr
gpg> revkey
[ passphrase twice ]
gpg> save
```

## Renouveler une paire de clés expirée ou sur le point d'expirer

```bash
gpg --edit-key my@email.addr
[select a key]
gpg> expire
[specify an expiration]
gpg> save
```

## Création d'un commit Git signé unique

```bash
git commit -S -m "my awesome signed commit"
```

## Configuration de Git afin de toujours signer les commits avec une clé spécifiée

```bash
$ gpg --list-secret-keys --keyid-format=long # grab the fingerprint from the 'sec' line
git config [--global] commit.gpgsign true
git config [--global] user.signingkey DEADB33FBAD1D3A
```

## Configuration de VSCode pour signer les commits

```bash
# User or workspace setting
"git.enableCommitSigning": true
```

## Téléchargement de votre clé publique sur un serveur de clés

```bash
gpg --keyserver pgp.mit.edu --send-keys 0xDEADB33FBAD1D3A
```

## Assurez-vous que votre clé a été publiée

```bash
gpg --keyserver pgp.mit.edu --search-key my@email.addr
```

## Références

[OpenPGP Best Practices](https://riseup.net/en/security/message-security/openpgp/best-practices#key-configuration)
[Github: Signing Commits](https://docs.github.com/en/enterprise-server@3.5/authentication/managing-commit-signature-verification/signing-commits)
[Braincoke's Log: Create a GPG Key](https://blog.braincoke.fr/security/create-a-gpg-key/)
[Creating the Perfect GPG Keypair](https://alexcabal.com/creating-the-perfect-gpg-keypair)
[Digital Neanderthal: Generate GPG Keys With Curve Ed25519](https://web.archive.org/web/20240512060111/https://www.digitalneanderthal.com/post/gpg/)

{% include 'teams/testing/content_bottom.md' %}
