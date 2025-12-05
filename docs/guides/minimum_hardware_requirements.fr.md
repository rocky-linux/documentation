# RL10 (Red Quartz) — Configuration Minimum

Rocky Linux 10  est conçu pour une stabilité de niveau entreprise et une compatibilité avec du matériel moderne. Ces spécifications minimum s'appliquent aux **installations minimales de serveur**. Pour les environnements d'interface utilisateur graphique ou de production, des spécifications plus élevées sont recommandées.

---

## Architectures Prises en Charge

Selon les notes de publication officielles de Rocky Linux 10.0, RL10 prend en charge les architectures suivantes :

- **x86_64-v3** (processeurs Intel/AMD 64 bits avec au moins la prise en charge Haswell ou équivalente d'AVX)
- **aarch64** (ARMv8-A 64-bit)
- **ppc64le** (IBM Power, Little Endian)
- **s390x** (IBM Z mainframes)
- **riscv64** (RISC‑V 64-bit)

### ⚠️ Exigences relatives aux fonctionnalités du processeur

- **x86_64-v3** nécessite AVX, AVX2, BMI1/2 et FMA, correspondant à Intel Haswell ou version ultérieure, ou AMD Excavator ou plus récent.
- Les anciennes révisions x86_64 (v1/v2) ne sont **pas prises en charge**, à moins qu'elles ne soient reconstruites par les SIG de la communauté.

---

## 🧠 CPU (Processeur)

- **1 GHz 64 bits (x86_64‑v3)** ou équivalent pour d'autres architectures
- Les processeurs multicœurs sont recommandés pour une utilisation sur serveur, sur desktop ou en virtualisation

---

## 💾 Mémoire (RAM)

- **2 Go** minimum (installation en mode texte, sans GUI)
- **4 Go+** recommandé pour les installations d'interface graphique
- **4–8 Go+** pour les charges de travail de production ou la virtualisation

---

## 💽 Stockage

- **10 Go** d'espace disque minimum
- **20 Go+** recommandés pour héberger les mises à jour, les journaux et les applications
- Pour l'interface graphique : **40 Go+** pour garantir un espace suffisant

---

## 🌐 Réseau

- Au moins un adaptateur réseau Ethernet ou sans fil fonctionnel
- Prend en charge la configuration DHCP ou IP statique par l'intermédiaire de NetworkManager

---

## 🖥️ Affichage (pour les installations avec GUI)

- Résolution minimale **1024×768** via VGA, HDMI ou DisplayPort
- Non requis pour les installations de serveur minimales

---

## 📀 Accès aux Médias

- Port USB (pour l'installateur USB en direct) ou lecteur de DVD-ROM
- Les installations infonuagiques prennent en charge les installations ISO ou PXE

---

## 🔒 Firmware

- Le démarrage UEFI ou BIOS est pris en charge ; **UEFI est recommandé**
- Démarrage sécurisé pris en charge (peut nécessiter une inscription manuelle de la clé)

---

## 🗃️ Support de Virtualisation

- Prise en charge d'environnements virtuels (KVM, VMware, VirtualBox, Hyper-V)
- Outils supplémentaires `guest` (par exemple, open-vm-tools, qemu-guest-agent) recommandés pour des performances optimisées

---

## 📝 Tableau Récapitulatif

| Composant         | Exigences Minimales                                                                                                |
| ----------------- | ------------------------------------------------------------------------------------------------------------------ |
| **CPU**           | 1 GHz 64-bit (AVX-capable x86_64-v3) ou équivalent pour ARM/POWER/Z/RISC-V |
| **RAM**           | 1 Go (2 Go pour le GUI)                                                                         |
| **Espace Disque** | 10 Go (20 Go+ recommandés ; 40 Go+ pour l'interface graphique)                                  |
| **Réseau**        | Adaptateur Ethernet ou sans fil                                                                                    |
| **Écran**         | Compatible 1024×768 (seulement pour l'interface graphique)                                      |
| **Media Access**  | USB ou DVD-ROM                                                                                                     |
| **Firmware**      | UEFI/BIOS (UEFI recommandé) ; démarrage sécurisé en option                                      |

---

## 🎯 Spécifications recommandées par cas d'utilisation

### 🏗️ Serveur Minimal

- CPU : 1 core x86_64-v3 (ou ARM/POWER/Z/RISC‑V)
- RAM : 1 Go
- Stockage : 10–20 Go

### 🖥️ Desktop avec GUI

- CPU : 2 cœurs ou plus x86_64-v3 (ou équivalent)
- RAM : 2–4 Go
- Stockage : 20–40 Go

### 🛠️ Serveur de Développement ou Production

- CPU : 4+ cœurs
- RAM : 4–8 Go +
- Stockage : 40 Go ou plus (selon les besoins de la charge de travail)

---

## 🧩 Notes Supplémentaires

- Always allocate extra storage for logs, package updates, and backups.
- Pour l'infonuagique ou la virtualisation, choisissez des types d'instances qui répondent ou dépassent les spécifications ci-dessus.
- Les mises à niveau des versions antérieures de Rocky (par exemple, 8 ou 9) vers Rocky 10 ne sont pas prises en charge — **une nouvelle installation est requise**.

---

**Mise à Jour**: 2025-06-30  
**Concerne**: Rocky Linux 10 Release Initial
**Traductions**: <a href="https://crowdin.com/project/rockydocs/activity-stream">2025-09-04 20h15</a>
