RL 10 (Red Quarz) —
Mindest-Hardware-Anforderungen
==============================

Rocky Linux 10 ist auf Stabilität auf Unternehmensniveau mit moderner Hardwarekompatibilität ausgelegt. Diese Mindestspezifikationen gelten für **minimale Serverinstallationen**. Für GUI- oder Produktionsumgebungen werden höhere Spezifikationen empfohlen.

---

## ✅ Supported CPU Architekturen

Laut den Versionshinweisen zu Rocky Linux 10.0 unterstützt RL10 offiziell die folgenden Architekturen:

- **x86_64-v3** (Intel/AMD 64-Bit-CPUs mit mindestens Haswell oder gleichwertiger AVX-Unterstützung)
- **aarch64** (ARMv8-A 64-bit)
- **ppc64le** (IBM Power, Little Endian)
- **s390x** (IBM Z Mainframes)
- **riscv64** (RISC‑V 64-bit)

### ⚠️ CPU Voraussetzungen

- **x86_64-v3** erfordert AVX, AVX2, BMI1/2 und FMA, entsprechend Intel Haswell oder höher oder AMD Excavator oder neuer.
- Ältere x86_64-Revisionen (v1/v2) werden **nicht unterstützt**, sofern sie nicht von Community-SIGs neu erstellt werden.

---

## 🧠 CPU (Prozessor)

- **1 GHz 64-Bit (x86_64‑v3)** oder gleichwertig für andere Architekturen
- Für den Einsatz auf Servern, Desktops oder in der Virtualisierung werden Multi-Core-CPUs empfohlen

---

## 💾 Memory (RAM)

- **2 GB** mindestens (Installation im Textmodus ohne GUI)
- **4 GB+** empfohlen für GUI-Installationen
- **4–8 GB+** für Produktions-Workloads oder Virtualisierung

---

## 💽 Speicher

- **10 GB** Mindestspeicherplatz
- **20 GB+** empfohlen, um Updates, Protokolle und Anwendungen unterzubringen
- Für GUI: **40 GB+**, um ausreichend Speicherplatz sicherzustellen

---

## 🌐 Netzwerk

- Mindestens ein funktionsfähiger Ethernet- oder WLAN-Netzwerkadapter
- Unterstützt DHCP oder statische IP-Konfiguration über NetworkManager

---

## 🖥️ Display (für Installationen mit GUI)

- Mindestauflösung **1024×768** über VGA, HDMI oder DisplayPort
- Für minimale Serverinstallationen nicht erforderlich

---

## 📀 Media Access

- USB-Anschluss (für Live-USB-Installer) oder DVD-ROM-Laufwerk
- Cloud-Installationen unterstützen ISO- oder PXE-basierte Installationen

---

## 🔒 Firmware

- UEFI- oder BIOS-Booten wird unterstützt; **UEFI empfohlen**
- Secure Boot wird unterstützt (erfordert möglicherweise eine manuelle Schlüsselregistrierung)

---

## 🗃️ Virtualisierung–Support

- Virtuelle Umgebungen (KVM, VMware, VirtualBox, Hyper-V) werden unterstützt
- Guest-Tools (z. B. Open-VM-Tools, QEMU-Guest-Agent) werden für eine optimierte Leistung empfohlen

---

## 📝 Zusammenfassung

| Komponente       | Mindestanforderungen                                                                                                |
| ---------------- | ------------------------------------------------------------------------------------------------------------------- |
| **CPU**          | 1 GHz 64-Bit (AVX-fähig x86_64-v3) oder gleichwertig für ARM/POWER/Z/RISC-V |
| **RAM**          | 1 GB (2 GB mit GUI)                                                                              |
| **Disk Space**   | 10 GB (20 GB+ empfohlen; 40 GB+ für GUI)                                                         |
| **Netzwerk**     | Ethernet- oder Wireless-Adapter                                                                                     |
| **Display**      | 1024×768-fähig (nur für GUI)                                                                     |
| **Media Access** | USB oder DVD-ROM                                                                                                    |
| **Firmware**     | UEFI/BIOS (UEFI empfohlen); Secure Boot optional                                                 |

---

## 🎯 Empfohlene Spezifikationen nach Anwendungsfall

### 🏗️ Minimal Server

- CPU: 1 Kern x86_64-v3 (oder ARM/POWER/Z/RISC‑V)
- RAM: 1 GB
- Speicher: 10–20 GB

### 🖥️ Desktop mit GUI

- CPU: 2+ Kerne x86_64-v3 (oder gleichwertig)
- RAM: 2–4 GB
- Speicher: 20–40 GB

### 🛠️ Entwicklung–/Produktions–Server

- CPU: 4+ cores
- RAM: 4–8 GB+
- Speicher: 40 GB+ (je nach Arbeitslastbedarf)

---

## 🧩 Zusätzliche Anmerkungen

- Weisen Sie Protokollen, Paketaktualisierungen und Sicherungen immer zusätzlichen Speicherplatz zu.
- Wählen Sie für die Cloud oder Virtualisierung Instanz-Typen, die die oben genannten Spezifikationen erfüllen oder übertreffen.
- Upgrades von früheren Rocky-Versionen (z. B. 8 oder 9) auf Rocky 10 werden nicht unterstützt – **Neuinstallation erforderlich**.

---

**Update**: 2025-06-30\
**Betrifft**: Rocky Linux 10 Release Initial
**Übersetzung**: <a href="https://crowdin.com/project/rockydocs/activity-stream">2025-09-04 20h25</a>
