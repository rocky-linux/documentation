---
title: 'SOP: openQA - System Upgrades'
author: Trevor Cooper
revision_date: 2026-04-17
render_macros: true
---

This SOP details the necessary steps for performing a system upgrade on an openQA host.

{% include "teams/testing/contacts_top.md" %}

## Fedora

1. Verify current installation is fully upgraded

    ``` bash linenums="1"
    dnf upgrade --refresh
    ```

1. Install system upgrade plugin

    ``` bash linenums="1"
    dnf install dnf-plugin-system-upgrade
    ```

1. Download the upgrade packages for next version

    ``` bash linenums="1"
    dnf system-upgrade download --releasever=[newversion]
    ```

1. Reboot into offline upgrade mode

    ``` bash linenums="1"
    dnf system-upgrade reboot
    ```

1. Post-reboot cleanup

    ``` bash linenums="1"
    dnf system-upgrade clean
    dnf clean packages
    ```

## Post-Upgrade Tasks

These steps may also be necessary in some (but not all) cases.

### Upgrade the PostgreSQL database

1. Install postgresql-upgrade package

    ``` bash linenums="1"
    dnf install postgresql-upgrade
    ```

1. Upgrade your postgres database

    ``` bash linenums="1"
    sudo -iu postgres
    postgresql-setup --upgrade
    ```

### Re-apply Rocky branding

1. Obtain the [Ansible openQA deployment repository](https://git.resf.org/infrastructure/ansible-openqa-management){target=_blank}

1. Run the branding related tasks

    ``` bash linenums="1"
    ansible-playbook init-openqa-rocky-developer-host.yml -t branding
    ```

## References
- [Upgrading Fedora using the DNF system upgrade](https://docs.fedoraproject.org/en-US/quick-docs/dnf-system-upgrade/){target=_blank}
- [How to Easily Upgrade to Fedora Workstation 36](https://www.makeuseof.com/how-to-upgrade-to-fedora-workstation-36/){target=_blank}

{% include "teams/testing/content_bottom.md" %}
