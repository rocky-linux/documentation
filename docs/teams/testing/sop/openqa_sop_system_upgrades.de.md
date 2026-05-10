---
title: 'SOP: openQA – System-Upgrades'
author: Trevor Cooper
revision_date: 2026-04-17
render_macros: true
---

Diese Standardarbeitsanweisung beschreibt die notwendigen Schritte zur Durchführung eines System-Upgrades auf einem openQA-Host.

{% include "teams/testing/contacts_top.md" %}

## Fedora

1. Prüfen Sie, ob die aktuelle Installation vollständig aktualisiert ist

    ```bash linenums="1"
    dnf upgrade --refresh
    ```

2. Installieren Sie das System-Upgrade-Plugin

    ```bash linenums="1"
    dnf install dnf-plugin-system-upgrade
    ```

3. Laden Sie die Upgrade-Pakete für die nächste Version herunter

    ```bash linenums="1"
    dnf system-upgrade download --releasever=[newversion]
    ```

4. Neustart im Offline-Upgrade-Modus

    ```bash linenums="1"
    dnf system-upgrade reboot
    ```

5. Aufräumarbeiten nach dem Neustart

    ```bash linenums="1"
    dnf system-upgrade clean
    dnf clean packages
    ```

## Tasks nach dem Upgrade

Diese Schritte können in einigen (aber nicht allen) Fällen ebenfalls notwendig sein.

### Aktualisierung der PostgreSQL-Datenbank

1. Installieren Sie das Paket `postgresql-upgrade`

    ```bash linenums="1"
    dnf install postgresql-upgrade
    ```

2. Aktualisieren Sie Ihre PostgreSQL-Datenbank

    ```bash linenums="1"
    sudo -iu postgres
    postgresql-setup --upgrade
    ```

### Rocky-Branding erneut anwenden

1. Das [Ansible openQA Deployment-Repository](https://git.resf.org/infrastructure/ansible-openqa-management){target=_blank} abrufen

2. Führen Sie die Tasks im Zusammenhang mit Branding durch

    ```bash linenums="1"
    ansible-playbook init-openqa-rocky-developer-host.yml -t branding
    ```

## Referenzen

- [Upgrading Fedora using the DNF system upgrade](https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/){target=_blank}
- [How to Easily Upgrade to Fedora Workstation 36](https://www.makeuseof.com/how-to-upgrade-to-fedora-workstation-36/){target=_blank}

{% include "teams/testing/content_bottom.md" %}
