---
title: DISA STIG Di Rocky Linux 8 - Bagian 1
author: Scott Shinn
contributors: Firdaus Siregar
tested_with: 8.6
tags:
  - DISA
  - STIG
  - keamanan
  - enterprise
---

# HOWTO: STIG Rocky Linux 8 Cepat - Bagian 1

## Referensi Terminologi

* DISA - Badan Sistem Informasi Pertahanan
* RHEL8 - Red Hat Enterprise Linux 8
* STIG - Panduan Implementasi Teknis yang Aman
* SCAP - Protokol Otomasi Konten Aman
* DoD - Departemen Pertahanan

## Perkenalan

Dalam panduan ini kita akan membahas cara menerapkan [DISA STIG untuk RHEL8](https://www.stigviewer.com/stig/red_hat_enterprise_linux_8/) untuk Instalasi Baru Rocky Linux 8. Sebagai rangkaian multi-bagian, kami juga akan membahas cara menguji kepatuhan STIG, mengadaptasi pengaturan STIG, dan menerapkan konten STIG lainnya di lingkungan ini.

Rocky Linux adalah bug untuk turunan bug dari RHEL dan dengan demikian konten yang diterbitkan untuk DISA RHEL8 STIG setara untuk kedua sistem operasi.  Berita yang lebih baik lagi, menerapkan pengaturan STIG dibangun ke dalam penginstal anaconda Rocky Linux 8, di bawah Profil Keamanan.  Di bawah terpal ini semua didukung oleh alat yang disebut [OpenSCAP](https://www.open-scap.org/), yang memungkinkan Anda mengonfigurasi sistem agar sesuai dengan DISA STIG (cepat!), dan juga uji kepatuhan sistem setelah Anda menginstal.

Saya akan melakukan ini pada mesin virtual di lingkungan saya, tetapi semua yang ada di sini akan menerapkan cara yang persis sama pada besi kosong.

### Langkah 1: Buat Mesin Virtual

* memori 2G
* disk 30G
* 1 core

![Mesin virtual](images/disa_stig_pt1_img1.jpg)

### Langkah 2: Unduh DVD ISO Rocky Linux 8

[Unduh DVD Rocky Linux](https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.6-x86_64-dvd1.iso).  **Catatan:** ISO minimal tidak berisi konten yang diperlukan untuk menerapkan STIG untuk Rocky Linux 8, Anda perlu menggunakan DVD atau instalasi jaringan.

![Unduh Rocky](images/disa_stig_pt1_img2.jpg)

### Langkah 3: Boot Penginstal

![Boot Pemasang](images/disa_stig_pt1_img3.jpg)

### Langkah 4: Pilih Partisi PERTAMA

Ini mungkin langkah yang paling rumit dalam instalasi, dan persyaratan untuk mematuhi STIG. Anda perlu mempartisi sistem file sistem operasi dengan cara yang mungkin akan menimbulkan masalah baru. Dengan kata lain: Anda harus tahu persis kebutuhan penyimpanan Anda.

!!! tip "Pro-Tip"

    Linux memungkinkan Anda mengubah ukuran sistem file, yang akan kami bahas di artikel lain. Cukup untuk mengatakan, ini adalah salah satu masalah yang lebih besar menerapkan DISA STIG pada besi kosong, seringkali membutuhkan penginstalan ulang penuh untuk menyelesaikannya, jadi spesifikasikan ukuran yang Anda butuhkan di sini.

![Mempartisi](images/disa_stig_pt1_img4.jpg)

* Pilih "Kustom" dan kemudian "Selesai"

![Partisi Kustom](images/disa_stig_pt1_img5.jpg)

* Mulai Menambahkan Partisi

![Tambahkan Partisi](images/disa_stig_pt1_img6.jpg)

Skema partisi DISA STIG untuk disk 30G. Kasus penggunaan saya adalah sebagai server web sederhana:

* /  (10G)
* /boot (500m)
* /var (10G)
* /var/log (4G)
* /var/log/audit (1G)
* /home (1G)
* /tmp  (1G)
* /var/tmp (1G)
* Swap (2G)

!!! tip "Pro-Tip"

     Konfigurasikan / terakhir dan berikan angka yang sangat tinggi, ini akan membuat semua ruang disk kendur tersisa di / dan Anda tidak perlu menghitung apa pun.

![Partisi Slash](images/disa_stig_pt1_img7.jpg)

!!! tip "Pro-Tip"

    Ulangi dari Pro-Tip sebelumnya: OVER SPEC filesystem Anda, bahkan jika Anda harus mengembangkannya lagi nanti.

* Klik "Selesai", dan "Terima Perubahan"

![Konfirmasi Partisi](images/disa_stig_pt1_img8.jpg)

![Terima Perubahan](images/disa_stig_pt1_img9.jpg)

### Langkah 5: Konfigurasi perangkat lunak untuk lingkungan Anda: Instal server tanpa GUI.

Langkah 5: Konfigurasi perangkat lunak untuk lingkungan Anda: Instal server tanpa GUI.

![Pemilihan Perangkat Lunak](images/disa_stig_pt1_img10.jpg)

### Langkah 6: Pilih Profil Keamanan

Ini akan mengonfigurasi sejumlah pengaturan keamanan pada sistem berdasarkan kebijakan yang dipilih, memanfaatkan kerangka kerja SCAP. Ini akan mengubah paket yang Anda pilih di **Langkah 5**, menambahkan atau menghapus komponen yang diperlukan.  Jika Anda _melakukan_ memilih pemasangan GUI pada **Langkah 5**, dan Anda menggunakan STIG non-GUI pada langkah ini, itu akan menghapus GUI. Sesuaikan seperlunya!

![Profil Keamanan](images/disa_stig_pt1_img11.jpg)

Pilih DISA STIG untuk Red Hat Enterprise Linux 8:

![DISA STIG](images/disa_stig_pt1_img12.jpg)

Klik "Pilih Profil", dan catat perubahan yang akan dilakukan pada sistem. Ini akan menetapkan opsi pada titik pemasangan, menambah/menghapus aplikasi, dan membuat perubahan konfigurasi lainnya:

![Pilih Profil_A](images/disa_stig_pt1_img13.jpg)

![Pilih_Profile_B](images/disa_stig_pt1_img14.jpg)

### Langkah 7: Klik "Selesai", dan Lanjutkan Ke Penyetelan Akhir

![Selesaikan Profil](images/disa_stig_pt1_img15.jpg)

### Langkah 8: Buat akun pengguna, dan setel pengguna itu ke administrator

Dalam tutorial selanjutnya kita bisa bergabung dengan ini ke konfigurasi perusahaan FreeIPA. Untuk saat ini, kami akan memperlakukan ini sebagai standalone. Perhatikan bahwa saya tidak menyetel kata sandi root, melainkan kami memberikan akses `sudo` pengguna default kami.

![Pengaturan Pengguna](images/disa_stig_pt1_img16.jpg)

### Langkah 9: Klik "Selesai", lalu "Mulai Instalasi"

![Mulai Instalasi](images/disa_stig_pt1_img17.jpg)

### Langkah 10: Setelah instalasi selesai, klik "Reboot System"

![Memulai ulang](images/disa_stig_pt1_img18.jpg)

### Langkah 11: Masuk ke Sistem Rocky Linux 8 STIG'd Anda!

![Peringatan DoD](images/disa_stig_pt1_img19.jpg)

Jika semuanya berjalan dengan baik, Anda akan melihat spanduk peringatan DoD default di sini.

![Layar Akhir](images/disa_stig_pt1_img20.jpg)

## Tentang Penulis

Scott Shinn adalah CTO untuk Atomicorp, dan bagian dari tim Keamanan Rocky Linux. Dia telah terlibat dengan sistem informasi federal di Gedung Putih, Departemen Pertahanan, dan Komunitas Intelijen sejak tahun 1995. Bagian dari itu adalah membuat STIG dan persyaratan agar Anda menggunakannya dan saya sangat menyesal tentang itu.
