---
title: 'SOP : openQA – Mises à niveau du système'
author: Trevor Cooper
revision_date: 2026-04-17
render_macros: true
---

Cette procédure opérationnelle standard détaille les étapes nécessaires pour effectuer une mise à niveau du système sur un hôte openQA.

{% include "teams/testing/contacts_top.md" %}

## Fedora

1. Assurez-vous que l'installation actuelle est bien mise à jour

    ```bash linenums="1"
    dnf upgrade --refresh
    ```

2. Installez le plugiciel de mise à niveau du système

    ```bash linenums="1"
    dnf install dnf-plugin-system-upgrade
    ```

3. Téléchargez les « packages » de mise à niveau pour la prochaine version

    ```bash linenums="1"
    dnf system-upgrade download --releasever=[newversion]
    ```

4. Redémarrez en mode de mise à niveau hors ligne

    ```bash linenums="1"
    dnf system-upgrade reboot
    ```

5. Nettoyage après le redémarrage

    ```bash linenums="1"
    dnf system-upgrade clean
    dnf clean packages
    ```

## Tâches Post-Upgrade après la mise à niveau

Ces étapes peuvent aussi être nécessaires dans certains cas (mais pas tous).

### Mise à jour de PostgreSQL

1. Installez le paquet postgresql-upgrade

    ```bash linenums="1"
    dnf install postgresql-upgrade
    ```

2. Mettez à jour votre base de données PostgreSQL

    ```bash linenums="1"
    sudo -iu postgres
    postgresql-setup --upgrade
    ```

### Renouvèlement du `branding` de Rocky Linux

1. Téléchargez le [dépôt de déploiement Ansible openQA](https://git.resf.org/infrastructure/ansible-openqa-management){target=_blank}

2. Lancez les tâches liées au branding de Rocky Linux

    ```bash linenums="1"
    ansible-playbook init-openqa-rocky-developer-host.yml -t branding
    ```

## Références

- [Upgrading Fedora using the DNF system upgrade](https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/){target=_blank}
- [How to Easily Upgrade to Fedora Workstation 36](https://www.makeuseof.com/how-to-upgrade-to-fedora-workstation-36/){target=_blank}

{% include "teams/testing/content_bottom.md" %}
