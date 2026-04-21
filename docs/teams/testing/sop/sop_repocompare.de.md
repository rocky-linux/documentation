---
title: 'SOP: Repocompare'
author: Trevor Cooper
revision_date: 2026-04-17
render_macros: true
---

Diese Standardarbeitsanweisung beschreibt, wie der `repocompare`-Prozess durchgeführt wird, um sicherzustellen, dass die Paket-Repositories von Rocky mit den RHEL-Paket-Repositories auf dem neuesten Stand sind.

{% include "teams/testing/contacts_top.md" %}

Um herauszufinden, welche Pakete möglicherweise aktualisiert werden müssen, besuchen Sie die entsprechende [RepoCompare](https://repocompare.rockylinux.org){target=_blank}-Seite und konzentrieren Sie sich dabei auf die **SRPM Repo Comparison**-Seite für jede Version.
Pakete, bei denen die **Rocky**-Version **niedriger** ist als die **RHEL**-Version, benötigen wahrscheinlich ein Update – Sie können einen manuellen Vergleich durchführen, um sicherzugehen.

## Einrichtung

Von einer **RHEL8-Maschine mit gültiger Berechtigung** das `repocompare`-Repository abrufen:

```bash linenums="1"
git clone https://git.resf.org/testing/repocompare
cd repocompare/
```

Importieren Sie die RPM-GPG-Schlüssel für Rocky und RHEL

```bash linenums="1"
curl -O http://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-8
curl -O http://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-Rocky-9
rpm --import RPM-GPG-KEY-Rocky-8
rpm --import RPM-GPG-KEY-Rocky-9
rpm --import /etc/pki/rpm-gpg/redhat-official
```

## Vergleich der Pakete

Wenn die NEVR-Werte (Name/Epoche/Version/Release) des RHEL-Pakets neuer sind als die des Rocky-Pakets, muss das Paket aktualisiert werden. In diesem Fall wird es wahrscheinlich auch einen neueren Eintrag im Änderungsprotokoll für das RHEL-Paket geben, wie unten dargestellt:

```bash linenums="1"
./manual_compare.sh 9 AppStream golang
Rocky Linux 9.2    golang 1.19.9 2.el9_2 * Tue May 23 2023 Alejandro Sáez <asm@redhat.com> - 1.19.9-2
Red Hat            golang 1.19.10 1.el9_2 * Tue Jun 06 2023 David Benoit <dbenoit@redhat.com> - 1.19.10-1
```

Beachten Sie, dass das Red Hat `golang`-Paket eine höhere Version aufweist als das Rocky Linux 9.2-Paket. Es gibt auch einen neuen Eintrag im Änderungsprotokoll.

## Fallstricke

Einige Pakete werden für die Zwecke von `repocompare` als nicht relevant betrachtet. Dazu zählen:

```bash linenums="1"
rhc
shim-unsigned
# Any package that exists in RHEL but not in Rocky (denoted by **DOES NOT EXIST** in the Rocky column on the repocompare website)
```

{% include "teams/testing/content_bottom.md" %}
