---
title: 'SOP: Repocompare'
author: Trevor Cooper
revision_date: 2026-04-17
render_macros: true
---

Cette procédure opérationnelle standard (SOP) explique comment effectuer le processus `repocompare` afin de s'assurer que les dépôts de paquets de Rocky sont à jour par rapport aux dépôts de paquets RHEL.

{% include "teams/testing/contacts_top.md" %}

Pour identifier les paquets qui pourraient nécessiter des mises à jour, visionnez la page [RepoCompare](https://repocompare.rockylinux.org){target=_blank} appropriée, en vous concentrant sur la page **SRPM Repo Comparison** pour chaque version.
Les paquets dont la version **Rocky** est **inférieure** à la version **RHEL** nécessitent probablement une mise à jour ; vous pouvez faire une comparaison manuelle pour en être sûr.

## Mise en place

À partir d'une machine **RHEL8 ayant un titre valide**, obtenez le dépôt `repocompare` :

```bash linenums="1"
git clone https://git.resf.org/testing/repocompare
cd repocompare/
```

Importez les clés GPG RPM pour Rocky et RHEL

```bash linenums="1"
curl -O http://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-8
curl -O http://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9
rpm --import RPM-GPG-KEY-Rocky-8
rpm --import RPM-GPG-KEY-Rocky-9
rpm --import /etc/pki/rpm-gpg/redhat-official
```

## Comparaison de package

Si les données `Name/Epoch/Version/Release (NEVR)` du paquet RHEL sont plus récentes que celles du paquet Rocky, le paquet nécessite une mise à jour. Dans ce cas, une nouvelle entrée apparaîtra probablement dans le journal des modifications du paquet RHEL, comme indiqué ci-dessous :

```bash linenums="1"
./manual_compare.sh 9 AppStream golang
Rocky Linux 9.2    golang 1.19.9 2.el9_2 * Tue May 23 2023 Alejandro Sáez <asm@redhat.com> - 1.19.9-2
Red Hat            golang 1.19.10 1.el9_2 * Tue Jun 06 2023 David Benoit <dbenoit@redhat.com> - 1.19.10-1
```

Notez que le paquet `golang` de Red Hat a une version plus récente que le paquet Rocky Linux 9.2. Il comporte également une entrée plus récente dans son journal des modifications.

## Pièges

Certains paquets ne sont pas considérés comme pertinents aux fins de `repocompare`. Parmi ceux-ci, on trouve notamment :

```bash linenums="1"
rhc
shim-unsigned
# Any package that exists in RHEL but not in Rocky (denoted by **DOES NOT EXIST** in the Rocky column on the repocompare website)
```

{% include "teams/testing/content_bottom.md" %}
