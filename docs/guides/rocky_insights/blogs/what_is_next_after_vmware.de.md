---
title: Was kommt nach VMware
author: Antoine Le Morvan
contributors:
tags:
  - Virtualisierung
  - VMware
  - Open Source
---

Seit Broadcoms Übernahme von VMware hat die Virtualisierungsbranche bedeutende Veränderungen erlebt, insbesondere bei der Lizenzpreisgestaltung. Die neue Preispolitik von Broadcom (dies ist keine Wertung) hat zu erheblichen Kostensteigerungen geführt, insbesondere für kleine und mittlere Unternehmen, die VMware nutzen. Infolgedessen sahen sich viele Organisationen veranlasst, ihre technologischen Entscheidungen zu überdenken.

Diese Preisanpassungen haben die betroffenen Unternehmen dazu veranlasst, nach Alternativen zu suchen, insbesondere nach Open-Source-Lösungen.

Ziel dieses Beitrags ist es, die Machbarkeit, die Vorteile und die Leistungsfähigkeit einer Virtualisierungslösung auf Basis von Open-Source-Technologien aufzuzeigen und damit eine praktikable Alternative zu VMware zu bieten.

Der Autor möchte klarstellen, dass weder er noch das Dokumentationsteam in irgendeiner Verbindung zu den im Folgenden genannten Lösungen stehen.

## Funktionen, die zu erwarten sind

Bevor wir die auf dem Markt verfügbaren Lösungen besprechen, wollen wir kurz über die Funktionen sprechen, die wir von einer Virtualisierungslösung erwarten können.

Ein wichtiger Punkt, der in vielen Diskussionen zu diesem Thema immer wieder zur Sprache kam und der zunächst oft übersehen wird, ist die Datensicherung. Der entscheidende Faktor bei der Auswahl einer Lösung wird sein: Verfügt diese Lösung über eine zuverlässige Backup-Lösung? Und der Autor würde sogar angeben, ob eine Lösung wie Veeam Backup, die Sie bereits verwenden und nicht wechseln möchten (aus Kostengründen, aufgrund erworbener Kenntnisse oder aus Sicherheitsgründen), von der aktuellen Software des Autors unterstützt wird.

Weitere zu berücksichtigende Merkmale sind:

- Sicherung und Wiederherstellung, VM-Snapshots
- Containerisierung und/oder integriertes Kubernetes
- verwaltete Datenbanken
- IAAS: VPC, Netzwerkvirtualisierung und Self-Service-Portal
- DevOps-Integrationsreife (Terraform, Ansible) – API
- S3-Objektspeicher (Ceph...)
- Integriertes VPN (insbesondere Site-to-Site)
- Sicherheitsgruppen (virtuelle Firewall)
- IPAM, verwaltetes DHCP, Lastausgleich, SNAT
- Monitoring

Einige Lösungen bieten außerdem:

- Integrierte Migration von VMware

## Auswahl des Hypervisor

Bevor wir uns mit den bestehenden Lösungen befassen, werfen wir einen Blick auf die Auswahl des Hypervisor aus den verfügbaren Optionen:

- **ESXi**, der Hypervisor von VMware. Wenn dies berücksichtigt wird, dürfte es die Migration vereinfachen.
- **KVM (QEMU/libvirt)**: Integriert in den Kernel, ist dies eine der fortschrittlichsten Open-Source-Lösungen hinsichtlich ihrer Funktionen und wird häufig eingesetzt.
- **Xen (XCP-ng)**: Der Nachfolger von Citrix. Es handelt sich um einen robusten, älteren Hypervisor, der möglicherweise noch einige technische Altlasten aufweist, aber anscheinend aktiv weiterentwickelt wird und den Rückstand wahrscheinlich bald aufholen wird.
- **AHV (Nutanix)**: Wir wenden uns hier von Open-Source-Lösungen ab, aber wir werden später über Nutanix sprechen.
- **Hyper-V**: Erwähnenswert ist auch, dass viele kleine Unternehmen sich trotz der proprietären Technologie für Microsoft entscheiden könnten, wenn deren Preise niedriger sind als die von VMware.

Zu den Funktionen, die Sie von einem Hypervisor erwarten können, sollten Sie Folgendes überprüfen:

- CPU und RAM im laufenden Betrieb zu Gästen hinzufügen
- Festplatten im laufenden Betrieb hinzufügen oder deren Größe ändern bei Gästen
- Live-Migration innerhalb oder zwischen Clustern
- Live-Speichermigration

An diesem Punkt ist der Vergleich von Hypervisoren schwierig, da die meisten in der Regel all diese Funktionen beinhalten. Die Wahl hängt letztlich von der Art des Managers ab, den Sie selektieren.

## Auswahl des Managers

Nun kommen wir zum Kern der Sache: der Wahl des besten Managers. Wer wird der große Gewinner sein, der ideale Ersatz für Ihr bewährtes vSphere? Diejenige, die Ihre Gäste nahtlos auf dem am besten geeigneten Hypervisor verwaltet?

### Features

Lassen Sie uns zunächst über die Funktionen dieser Lösungen sprechen, die Ihnen helfen werden, Ihre Optionen einzugrenzen und Proof-of-Concepts einzurichten, um Sie bei Ihrer endgültigen Entscheidung zu unterstützen.

Ein Manager sollte Folgendes bereitstellen:

- Clustermanagement: Hochverfügbarkeit (HA), Knotenwartung usw.
- Selbstbedienungsportal: Willkommen in der Welt der modernen Private Cloud und Infrastructure as a Service
- Netzwerkvirtualisierung (SDN), VPC
- API-Verwaltung
- Unterstützung für DevOps-Tools (Terraform, Ansible, Puppet usw.)
- Cluster-übergreifende Migration

### Vorhandene Lösungen

In diesem Abschnitt wird der Autor proprietäre Lösungen wie Hyper-V oder Nutanix nicht behandeln. Der Autor erwähnt lediglich, dass Nutanix viele Funktionen bietet, um mit VMware zu konkurrieren, und dass es einen reaktionsschnellen professionellen Support gibt. Es scheint immer noch eine teurere Lösung zu sein als die Unterstützung für die Lösungen, die der Autor im Folgenden vorstellen wird, aber er überlässt Ihnen den Preisvergleich.

Nach Ansicht des Autors ist **OpenStack** die fortschrittlichste Lösung, um etwas wie vSphere zu ersetzen. Es wird von vielen Anbietern unterstützt und bildet die Grundlage für zahlreiche öffentliche Cloud-Lösungen. Aber sie ist auch am schwierigsten umzusetzen. Vergessen Sie OpenStack, wenn Sie kein kompetentes Linux-Entwicklungsteam haben, das genügend Zeit dafür aufbringen kann. Aber wenn Sie diese Zeit investieren können, ist es die richtige Lösung für Sie. Ziehen Sie zur Unterstützung abgeleitete Lösungen wie **Virtuozzo** oder Anbieter wie RedHat und Suse in Betracht.

Nachdem der Autor zuerst **OpenStack** erwähnt hat, muss er nun mit dem Projekt fortfahren, das er schon lange bevorzugt: dem berühmten Top-Level-Projekt der Apache Foundation (niemand Geringeres), **CloudStack**. Mit ähnlichen Funktionen wie OpenStack bietet es alles, was für die Einrichtung eines Private-Cloud-Portals benötigt wird, einschließlich VPC-Unterstützung, Netzwerkvirtualisierung, Lastausgleich und sogar **Kubernetes**-Cluster, alles innerhalb eines gut gestalteten Self-Service-Portals. Es handelt sich um eine Java-Anwendung in einem rpm- oder deb-Paket, und die Installation ist unkompliziert. Der komplexeste Teil ist die Konfiguration virtueller Switches auf den Hosts (RockyLinux wird unterstützt), aber nichts ist unüberwindbar. Als Hostsysteme können KVM, Xen, Hyper-V oder ESXi verwendet werden, und seit Kurzem wird auch Proxmox unterstützt. Wie bereits erwähnt, ist CloudStack eine der wenigen Lösungen, die eine direkte Gastmigration von vSphere über die Benutzeroberfläche ermöglicht. Hinter CloudStack steht mit ShapeBlue ein aktiver Akteur, der Support für Unternehmen anbietet. Hinsichtlich der Skalierbarkeit existieren CloudStack-Instanzen mit über 35.000 Hosts, was auf eine solide Skalierbarkeit hinweist.

Als Nächstes wird der Autor Proxmox erwähnen, die Open-Source-Lösung, die in diesem Bereich voraussichtlich den größten Marktanteil gewinnen wird. Basierend auf Debian (kein RockyLinux hier ^^) muss der Autor zugeben, dass er nach dem Lesen der gut gemachten Administrationsanleitung von den Funktionen (IPAM, Netzwerkvirtualisierung, Speichermanagement, Containerunterstützung und insbesondere Ceph-Speicherintegration) beeindruckt war. Proxmox bietet eine integrierte Backup-Lösung mit der Option für externe Backups sowie eine neue Rechenzentrumsmanagementlösung (zur Verwaltung mehrerer Proxmox-Cluster). Wenn Sie kein Self-Service-Portal wie das von CloudStack benötigen, sich auf ein hyperkonvergentes Modell konzentrieren (der Speicher ist auf mehrere Hosts verteilt und nicht auf einem dedizierten SAN/NAS) und Ihr Umfang einige hundert Gäste umfasst, dann ist Proxmox wahrscheinlich die richtige Wahl.

Zu guter Letzt muss der Autor noch Vates und XCP-ng erwähnen, die auf dem Xen-Hypervisor und der Xen-Orchestra-Web-Administrationsoberfläche basieren. Nach Ansicht des Autors handelt es sich hierbei um Lösungen, die man im Auge behalten sollte, da sie auf soliden Grundlagen aufgebaut sind und aktiv weiterentwickelt werden (`Vates` wird von einem französischen Unternehmen entwickelt). Beachten Sie jedoch, dass Sie bei Vates mehr Geld ausgeben müssen, um auf hyperkonvergente Speicherlösungen (XOSTOR) oder Backup-Lösungen (XO Proxy) zugreifen zu können.

### Kostenkontrolle

Da es in diesem Artikel um die Kostensteigerungen aufgrund der Lizenzänderungen von Broadcom geht, wäre es ein Versäumnis des Autors, die finanziellen Aspekte einer Lösungsänderung nicht zu behandeln.

Neben den Support-Kosten, die Sie wahrscheinlich abonnieren möchten, wenn Sie ein Geschäftsmodell verfolgen, ist es auch wichtig, die Gesamtbetriebskosten (Total Cost of Ownership, TCO) zu berücksichtigen, die Folgendes umfassen:

- die Kosten für den Support,
- Wartungskosten
- Update-Kosten,
- Schulung Ihrer Teams und der Zeitaufwand für die Lösungsintegration,
- die für die Migration aufgewendete Zeit.

### Support und Community

Der letzte zu berücksichtigende Punkt, der oft ausschlaggebend sein kann, ist die Unterstützung, die sowohl von einem Unternehmen als auch von einer aktiven Gemeinschaft geleistet wird. Der Zugang zu einem reaktionsschnellen Support-Team kann beruhigend sein, ebenso wie die Möglichkeit, sich bei Fragen und Problemen auf eine starke Community verlassen zu können. Es ist jedoch wichtig zu beachten, dass mangelnde Gemeinschaftsaktivitäten oder unzureichende Unterstützung ein erheblicher Nachteil sein können.

## Zusammenfassung

Dieser kurze Artikel hat es dem Autor ermöglicht, die wichtigsten auf dem Markt erhältlichen Lösungen vorzustellen, und wie Sie sehen können, ist die Entscheidung nicht einfach. Alles hängt von der Fähigkeit Ihres Teams ab, das Tool zu verwalten, Ihrer Backup-Lösung, den von Ihnen benötigten Funktionen, Ihrer Reife im Umgang mit DevOps-Tools und Cloud-nativen Ansätzen sowie der Anzahl der zu verwaltenden Gäste.

Obwohl der Autor CloudStack schon lange bevorzugt, ist dieses Apache-Projekt immer noch relativ unbekannt (Apache bewirbt seine Projekte nicht so wie andere Anbieter) und der Autor empfiehlt Ihnen dringend, es bei Ihrer Entscheidung zu berücksichtigen. Proxmox und Vates sind auch hervorragende Lösungen für kleine Unternehmen oder sogar für größere Anforderungen, bevor man zu einer Lösung auf Basis von OpenStack (oder OpenShift) wechselt.

Der Autor hofft, dass Ihnen dieser kurze Überblick Zeit bei der Suche nach einer VMware-Ersatzlösung erspart.
