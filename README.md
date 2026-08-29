# Kontainer_boot
Still in development stage
# Kontainer_boot

Launcher modular untuk boot container (systemd-nspawn) di Android/Termux (aarch64).

## Persyaratan
- Device root (KernelSU/Magisk dengan kernel support namespace + cgroup)
- Jalankan `check-kernel.sh` dulu untuk cek kompatibilitas kernel Anda

## Kernel yang direkomendasikan
Kalau kernel bawaan device Anda tidak lolos cek (`check-kernel.sh` FAIL banyak item), gunakan kernel custom berikut:

**Aetherium-linux_v3 (5.10.264, KernelSU-Next + SuSFS, Neutron Clang)**
👉 [Download di sini](https://github.com/kepentokpiker-commits/aetherium/releases/tag/Aetherium-linux_v3-5.10-base-only-KSU-Next-SuSFS-Neutron-20260825-8)

Cara pasang:
1. Download zip dari link di atas
2. Flash via TWRP / EXKM / FKM atau KernelSU Manager
3. Reboot

## Cara pakai launcher
```bash
git clone https://github.com/kepentokpiker-commits/Kontainer_boot.git
cd Kontainer_boot
chmod +x check-kernel.sh launcher.sh
./check-kernel.sh
./launcher.sh
## ☕ Support / Donasi

Kalau proyek ini membantu Anda, boleh traktir kopi:

**GoPay:** 089520865457

Terima kasih atas dukungannya! 🙏
