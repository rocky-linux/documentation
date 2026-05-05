---
title: openQA - Accès à la production Rocky
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Exigences du système

Pour accéder au système openQA de Rocky Production et réaliser les exemples ci-dessous, vous aurez besoin d'un accès à un système fournissant le client openQA. En règle générale, il s'agira d'un système/conteneur basé sur Fedora (mais cela pourrait être Rocky 9.6) avec le paquet `openqa-client` et ses (~239) dépendances installés.

Vous pouvez aussi installer le serveur openQA sur votre propre machine locale.  Cf. : [Manual Install](openqa_manual_install.md)

## Exigences en matière d'accès

### API `GET` access

Le système openQA {{ rc.prod }} permet un accès public sans restriction via son interface web ou en utilisant le `openqa-client` pour les opérations `GET` sur l'API.

### API `POST` access

Pour utiliser le client openQA afin d'interagir avec le système openQA {{ rc.prod }} pour les opérations `POST`, les éléments suivants sont requis :

- un compte en règle dans le système [{{ rc.prod }} Account Services](https://accounts.rockylinux.org),
- autorisation d'accès à l'API `POST` de la part de l'équipe de test {{ rc.prod }}, et
- une [clé API openQA](https://open.qa/docs/#_authentication) générée sur le système openQA {{ rc.prod }}.

## Configuration de votre client OpenQA

Selon la commande `help` du client openqa, vous pouvez configurer votre client pour utiliser votre clé API de plusieurs manières.

L'exemple suivant montre comment configurer votre client selon la méthode la plus courante. Il est possible de configurer
plusieurs clés API client OpenQA de cette manière.

```bash
$ mkdir -p ~/.config/openqa

$ vim ~/.config/openqa/client.conf

$ cat ~/.config/openqa/client.conf
[localhost]
key = your_localhost_api_key
secret = your_localhost_api_secret
[openqa.rockylinux.org]
key = your_api_key
secret = your_api_secret
```

## Test de votre installation client OpenQA

```bash
$ openqa-cli api --host https://openqa.rockylinux.org --pretty jobs/overview
```

devrait fournir une liste des `jobs` actuels, puis sélectionnez un numéro de tâche et affichez les informations relatives à cette tâche spécifique, par exemple :

```bash
$ openqa-cli api --host https://openqa.rockylinux.org --pretty jobs/1
{
   "job" : {
      "assets" : {
         "iso" : [
            "Rocky-8.6-x86_64-boot.iso"
         ]
      },
      "assigned_worker_id" : 2,
      "blocked_by_id" : null,
      "children" : {
         "Chained" : [],
         "Directly chained" : [],
         "Parallel" : []
      },
      "clone_id" : null,
      "group" : "Rocky",
      "group_id" : 2,
      "has_parents" : 0,
      "id" : 1,
      "name" : "rocky-8.6-boot-iso-x86_64-Build-8.6-boot-iso--20221110.223812.0-install_default@64bit",
      "parents" : {
         "Chained" : [],
         "Directly chained" : [],
         "Parallel" : []
      },
      "parents_ok" : 1,
      "priority" : 10,
      "result" : "failed",
      "settings" : {
         "ARCH" : "x86_64",
         "ARCH_BASE_MACHINE" : "64bit",
         "BACKEND" : "qemu",
         "BUILD" : "-8.6-boot-iso--20221110.223812.0",
         "DESKTOP" : "gnome",
         "DISTRI" : "rocky",
         "FLAVOR" : "boot-iso",
         "GRUB" : "ip=dhcp",
         "HDDSIZEGB" : "15",
         "ISO" : "Rocky-8.6-x86_64-boot.iso",
         "MACHINE" : "64bit",
         "NAME" : "00000001-rocky-8.6-boot-iso-x86_64-Build-8.6-boot-iso--20221110.223812.0-install_default@64bit",
         "PACKAGE_SET" : "default",
         "PART_TABLE_TYPE" : "mbr",
         "POSTINSTALL" : "_collect_data",
         "QEMUCPU" : "Nehalem",
         "QEMUCPUS" : "2",
         "QEMURAM" : "3072",
         "QEMUVGA" : "virtio",
         "QEMU_VIRTIO_RNG" : "1",
         "TEST" : "install_default",
         "TEST_SUITE_NAME" : "install_default",
         "TEST_TARGET" : "ISO",
         "VERSION" : "8.6",
         "WORKER_CLASS" : "qemu_x86_64"
      },
      "state" : "done",
      "t_finished" : "2022-11-10T22:44:19",
      "t_started" : "2022-11-10T22:38:12",
      "test" : "install_default"
   }
}
```

## Références

- [openQA Documentation](https://open.qa/documentation/)
- [Installation Info](https://github.com/rocky-linux/OpenQA-Fedora-Installation)
- [Tests for Rocky](https://git.resf.org/testing/os-autoinst-distri-rocky)

{% include 'teams/testing/content_bottom.md' %}
