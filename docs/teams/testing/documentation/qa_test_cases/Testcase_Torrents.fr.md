---
title: QA:cas de test Torrents
author: Chris Stackpole
contributors:
tested_with: 8.10, 9.8, 10.2
tags:
  - test logiciel
  - qa
revision_date: 2026-10-20
rc:
  prod: Rocky Linux
  ver:
    - 8
    - 9
    - 10
  level: Final
render_macros: true
---

## Description

L'une des dernières étapes de la distribution consiste à générer des `torrents` pour les utilisateurs. Les fichiers `torrent` doivent être vérifiés avant d'être distribués au public.

- ⬇️ - moindre priorité. Il serait bon de tester cela, mais si ce n'est pas fait ou si le test échoue, ce n'est pas essentiel.
- ❗ - important. Il est préférable d'effectuer ce test, mais si ce n'est pas fait ou si le test échoue, cela n'empêchera pas la publication.

## Versions, architectures et fichiers ISO

| Distribution   | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | --------------------------- |
| Rocky Linux  9 | ❗       | ⬇️      | N/A     | ⬇️    | ❗                           |
| Rocky Linux 10 | ❗       | ⬇️      | ⬇️      | ⬇️    | ❗                           |

## Mise en place

1. Téléchargez les fichiers torrent. L’information sera diffusée dans le canal de diffusion de Mattermost.

## Marche à suivre

1. Téléchargez les torrents et le contenu.
2. Vérifiez les sommes de contrôle ;  
   `sha256sum -c *.CHECKSUM --ignore-missing`
3. Vérifiez la signature de clé GPG.

   ```
   # If you do not have the GPG keys already, please download the keys for each release from:-
   # https://rockylinux.org/resources/gpg-key-info
   #
   # Import those keys
   gpg --import RPM-GPG-KEY-Rocky-9
   gpg --import RPM-GPG-KEY-Rocky-10
   #
   # Alternatively, if you are on a Rocky system you can get the system key from:-
   sudo dnf install rocky-gpg-keys
   gpg --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Rocky-*
   #
   # Test that the GPG key matches that website
   gpg --list-keys
   #
   # Now test
   gpg --verify-file CHECKSUM.asc
   #
   # Output you are looking for is one of the following with keys that match the website above:-
   gpg: Good signature from "Rocky Enterprise Software Foundation - Release key 2022 <releng@rockylinux.org>"
   gpg: Good signature from "Release Engineering (Rocky Linux 10) <releng@rockylinux.org>"
   #
   # The following WARNING can be ignored for this test:-
   gpg: WARNING: This key is not certified with a trusted signature!
   ```

## Résultats escomptés

1. Tous les fichiers devraient se télécharger.
2. Les fichiers ISO doivent correspondre aux sommes de contrôle.
3. Les sommes de contrôle devraient être signées avec une clé GPG.

{% include 'teams/testing/qa_testcase_bottom.md' %}
