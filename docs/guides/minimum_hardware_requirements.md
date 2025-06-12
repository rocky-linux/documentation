# Rocky Linux 10 (Red Quartz) – Minimum Hardware Requirements

Rocky Linux 10 is designed for enterprise-grade stability with modern hardware compatibility. These minimum specifications apply to **minimal server installations**. For GUI or production environments, higher specifications are recommended.

---

## ✅ Supported CPU Architectures

According to the Rocky Linux 10.0 Release Notes, Rocky Linux 10 officially supports the following architectures :

- **x86_64-v3** (Intel/AMD 64-bit CPUs with at least Haswell or equivalent AVX support)  
- **aarch64** (ARMv8-A 64-bit)  
- **ppc64le** (IBM Power, Little Endian)  
- **s390x** (IBM Z mainframes)  
- **riscv64** (RISC‑V 64-bit)

### ⚠️ CPU Feature Requirements

- **x86_64‑v3** requires AVX, AVX2, BMI1/2, FMA, etc., corresponding to Intel Haswell or later, AMD Excavator or newer .
- Older x86_64 revisions (v1/v2) are **not supported** unless rebuilt by community SIGs.

---

## 🧠 CPU (Processor)

- **1 GHz 64-bit (x86_64‑v3)** or equivalent for other architectures  
- Multi-core CPUs recommended for server, desktop, or virtualization use

---

## 💾 Memory (RAM)

- **2 GB** minimum (text-mode install)  
- **4 GB+** recommended for GUI installs  
- **4–8 GB+** for production workloads or virtualization

---

## 💽 Storage

- **10 GB** minimum disk space  
- **20 GB+** recommended to accommodate updates, logs, applications  
- For GUI: **40 GB+** to ensure sufficient space

---

## 🌐 Network

- At least one functional Ethernet or wireless network adapter  
- Supports DHCP or static IP configuration via NetworkManager

---

## 🖥️ Display (for GUI installations)

- Minimum **1024×768** resolution via VGA, HDMI, or DisplayPort  
- Not required for minimal server installs

---

## 📀 Media Access

- USB port (for live USB installer) or DVD-ROM drive  
- Cloud installs support ISO or PXE-based installations

---

## 🔒 Firmware

- UEFI or BIOS booting is supported; **UEFI recommended**  
- Secure Boot supported (may require manual key enrollment)

---

## 🗃️ Virtualization Support

- Virtual environments (KVM, VMware, VirtualBox, Hyper-V) supported  
- Guest tools (e.g., open-vm-tools, qemu-guest-agent) recommended for optimized performance

---

## 📝 Summary Table

| Component       | Minimum Requirement                                    |
|------------------|--------------------------------------------------------|
| **CPU**         | 1 GHz 64-bit (AVX-capable x86_64-v3) or equivalent for ARM/POWER/Z/RISC-V |
| **RAM**         | 1 GB (2 GB for GUI)                                    |
| **Disk Space**  | 10 GB (20 GB+ recommended; 40 GB+ for GUI)             |
| **Network**     | Ethernet or wireless adapter                           |
| **Display**     | 1024×768 capable (only for GUI)                        |
| **Media Access**| USB or DVD-ROM                                         |
| **Firmware**    | UEFI/BIOS (UEFI recommended); Secure Boot optional     |

---

## 🎯 Recommended Specs by Use‑Case

### 🏗️ Minimal Server  

- CPU: 1 core x86_64-v3 (or ARM/POWER/Z/RISC‑V)  
- RAM: 1 GB  
- Storage: 10–20 GB

### 🖥️ Desktop with GUI  

- CPU: 2+ cores x86_64-v3 (or equivalent)  
- RAM: 2–4 GB  
- Storage: 20–40 GB

### 🛠️ Development/Production Server  

- CPU: 4+ cores  
- RAM: 4–8 GB+  
- Storage: 40 GB+ (based on workload needs)

---

## 🧩 Additional Notes

- Always allocate extra storage for logs, package updates, and backups.
- For cloud or virtualization, choose instance types meeting or exceeding the above specs.
- Upgrades from earlier Rocky releases (e.g., 8 or 9) to Rocky 10 aren’t supported—**clean installation required**.

---

**Last updated**: June 2025  
**Applies to**: Rocky Linux 10.0 Initial Release  
