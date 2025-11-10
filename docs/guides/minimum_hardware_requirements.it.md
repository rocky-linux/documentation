# Rocky Linux 10 (Red Quartz) - Requisiti hardware minimi

Rocky Linux 10 è stato progettato per garantire una stabilità enterprise-grade e una compatibilità con l'hardware moderno. Queste specifiche minime si applicano a **minimal server installations**. Per ambienti GUI o di produzione, si consigliano specifiche più elevate.

---

## ✅ Architetture CPU Supportate

Secondo le note di rilascio di Rocky Linux 10.0, Rocky Linux 10 supporta ufficialmente le seguenti architetture:

- **x86_64-v3** (CPU Intel/AMD a 64 bit con almeno Haswell o supporto AVX equivalente)
- **aarch64** (ARMv8-A 64-bit)
- **ppc64le** (IBM Power, Little Endian)
- **s390x** (IBM Z mainframes)
- **riscv64** (RISC‑V 64-bit)

### ⚠️ Requisiti della CPU

- **x86_64-v3** richiede AVX, AVX2, BMI1/2 e FMA, corrispondenti a Intel Haswell o successivi o AMD Excavator o più recenti.
- Le vecchie revisioni x86_64 (v1/v2) non sono **supportate** a meno che non vengano ricostruite dai SIG della comunità.

---

## 🧠 CPU (Processore)

- **1 GHz a 64 bit (x86_64-v3)** o equivalente per altre architetture
- Le CPU multi-core sono consigliate per l'utilizzo in ambito server, desktop o virtualizzazione.

---

## 💾 Memoria (RAM)

- **2 GB** minimo (installazione in modalità testo)
- **4 GB+** raccomandati per le installazioni con interfaccia grafica
- **4-8 GB+** per carichi di lavoro di produzione o virtualizzazione

---

## 💽 Storage

- **10 GB** di spazio minimo su disco
- **20 GB+** consigliati per ospitare aggiornamenti, registri e applicazioni.
- Per l'interfaccia grafica (GUI): **40 GB+** per garantire spazio sufficiente

---

## 🌐 Rete

- Almeno una scheda di rete Ethernet o wireless funzionante
- Supporta la configurazione IP statica o DHCP tramite NetworkManager.

---

## 🖥️ Display (per installazioni con GUI)

- Risoluzione minima **1024×768** tramite VGA, HDMI o DisplayPort
- Non è necessario per le installazioni di server minimali

---

## 📀 Media Access

- Porta USB (per il programma di installazione live USB) o unità DVD-ROM
- Le installazioni in cloud supportano installazioni basate su ISO o PXE

---

## 🔒 Firmware

- È supportato l'avvio UEFI o BIOS; si consiglia **UEFI**.
- Secure Boot supportato (può richiedere la registrazione manuale della chiave)

---

## 🗃️ Supporto per la virtualizzazione

- Ambienti virtuali (KVM, VMware, VirtualBox, Hyper-V) supportati
- Strumenti guest (ad esempio, open-vm-tools, qemu-guest-agent) consigliati per ottimizzare le prestazioni

---

## 📝 Tabella riassuntiva

| Componente          | Requisito minimo                                                                                                   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **CPU**             | 1 GHz a 64 bit (AVX-capace x86_64-v3) o equivalente per ARM/POWER/Z/RISC-V |
| **RAM**             | 1 GB (2 GB per la GUI)                                                                          |
| **Spazio su disco** | 10 GB (consigliati 20 GB o più; 40 GB o più per la GUI)                                         |
| **Rete**            | Adattatore Ethernet o wireless                                                                                     |
| **Display**         | Capacità di 1024×768 (solo per la GUI)                                                          |
| **Media Access**    | USB or DVD-ROM                                                                                                     |
| **Firmware**        | UEFI/BIOS (UEFI recommended); Secure Boot optional                                              |

---

## 🎯 Specifiche consigliate per caso d'uso

### 🏗️ Server minimale

- CPU: 1 core x86_64-v3 (or ARM/POWER/Z/RISC‑V)
- RAM: 1 GB
- Storage: 10–20 GB

### 🖥️ Desktop con GUI

- CPU: 2+ cores x86_64-v3 (or equivalent)
- RAM: 2–4 GB
- Storage: 20–40 GB

### 🛠️ Server di sviluppo/produzione

- CPU: 4+ cores
- AM: 4–8 GB+
- Storage: 40 GB+ (in base alle esigenze di workload)

---

## 🧩 Note aggiuntive

- Allocare sempre uno spazio di archiviazione supplementare per i log, gli aggiornamenti dei pacchetti e i backup.
- Per il cloud o la virtualizzazione, scegliete tipi di istanza che soddisfino o superino le specifiche di cui sopra.
- Gli aggiornamenti da versioni precedenti di Rocky (ad esempio, 8 o 9) a Rocky 10 non sono supportati: è necessaria una nuova installazione.

---

**Ultimo aggiornamento**: June 2025  
**Riguardante**: Rocky Linux 10.0 Initial Release
