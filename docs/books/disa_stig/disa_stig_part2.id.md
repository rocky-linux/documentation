---
title: Memverifikasi Kepatuhan DISA STIG dengan OpenSCAP - Bagian 2
author: Scott Shinn
contributors: Firdaus Siregar
tested_with: 8.6
tags:
  - DISA
  - STIG
  - keamanan
  - enterprise
---

# Perkenalan

Pada artikel terakhir kami menyiapkan sistem rocky linux 8 baru dengan stig DISA yang diterapkan menggunakan [OpenSCAP](https://www.openscap.org). Sekarang kita akan membahas cara menguji sistem menggunakan alat yang sama, dan melihat jenis laporan apa yang dapat kita hasilkan menggunakan alat oscap, dan mitra UI SCAP Workbench.

Rocky Linux 8 (dan 9!) menyertakan rangkaian konten [SCAP](https://csrc.nist.gov/projects/security-content-automation-protocol) untuk diuji, dan memulihkan kepatuhan terhadap berbagai standar. Jika Anda membangun sistem STIG di bagian 1, Anda telah melihat ini beraksi. Penginstal anaconda memanfaatkan konten ini untuk memodifikasi konfigurasi rocky 8 untuk mengimplementasikan berbagai kontrol, menginstal/menghapus paket, dan mengubah cara kerja titik pemasangan level OS.

Seiring waktu, hal-hal ini dapat berubah dan Anda pasti ingin mengawasinya. Seringkali, saya juga menggunakan laporan ini untuk menunjukkan bukti bahwa kontrol tertentu telah diterapkan dengan benar. Either way, itu dipanggang ke Rocky. Kita akan mulai dengan beberapa dasar.

## Daftar Profil Keamanan

Untuk mendaftar profil keamanan yang tersedia, kita perlu menggunakan perintah `oscap info` yang disediakan oleh paket `openscap-scanner`. Ini seharusnya sudah diinstal di sistem Anda jika Anda telah mengikuti sejak Bagian 1.  Untuk mendapatkan profil keamanan yang tersedia:

```
oscap info /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
```

!!! catatan

    Konten Rocky linux 8 akan menggunakan tag “rl8” di nama file. Di Rocky 9, itu akan menjadi "rl9".

Jika semuanya berjalan dengan baik, Anda akan menerima layar yang terlihat seperti ini:

![Profil Keamanan](images/disa_stig_pt2_img1.jpg)

DISA hanyalah salah satu dari banyak Profil Keamanan yang didukung oleh definisi Rocky Linux SCAP. Kami juga memiliki profil untuk:

* [ANSSI](https://www.ssi.gouv.fr/en/)
* [CIS](https://cisecurity.org)
* [Pusat Keamanan Siber Australia](https://cyber.gov.au)
* [NIST-800-171](https://csrc.nist.gov/publications/detail/sp/800-171/rev-2/final)
* [HIPAA](https://www.hhs.gov/hipaa/for-professionals/security/laws-regulations/index.html)
* [PCI-DSS](https://www.pcisecuritystandards.org/)

## Mengaudit kepatuhan DISA STIG

Ada dua jenis untuk dipilih di sini:

* stig - Tanpa GUI
* stig_gui - Dengan GUI

Jalankan pemindaian dan buat laporan HTML untuk DISA STIG:

```
sudo oscap xccdf eval --report unit-test-disa-scan.html --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
```

Ini akan menghasilkan laporan seperti ini:

![Hasil Scan](images/disa_stig_pt2_img2.jpg)

Dan akan menampilkan laporan HTML:

![Laporan HTML](images/disa_stig_pt2_img3.jpg)

## Menghasilkan Skrip Bash Remediasi

Selanjutnya, kami akan membuat pemindaian, dan kemudian menggunakan hasil pemindaian untuk menghasilkan skrip bash untuk memulihkan sistem berdasarkan profil stig DISA. Saya tidak menyarankan menggunakan remediasi otomatis, Anda harus selalu meninjau perubahan sebelum benar-benar menjalankannya.

1) Hasilkan pemindaian pada sistem:
    ```
    sudo oscap xccdf eval --results disa-stig-scan.xml --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
    ```
2) Gunakan hasil pemindaian ini untuk menghasilkan skrip:
    ```
    sudo oscap xccdf generate fix --output draft-disa-remediate.sh --profile stig disa-stig-scan.xml
    ```

Skrip yang dihasilkan akan mencakup semua perubahan yang akan dilakukan pada sistem.

!!! peringatan

    Tinjau ini sebelum menjalankannya! Ini akan membuat perubahan signifikan pada sistem.

![Konten Skrip](images/disa_stig_pt2_img4.jpg)

## Menghasilkan Remediasi Playbook yang Memungkinkan

Anda juga dapat menghasilkan tindakan remediasi dalam format pedoman yang memungkinkan. Mari ulangi bagian di atas, tetapi kali ini dengan keluaran yang memungkinkan:

1) Hasilkan pemindaian pada sistem:
    ```
    sudo oscap xccdf eval --results disa-stig-scan.xml --profile stig /usr/share/xml/scap/ssg/content/ssg-rl8-ds.xml
    ```
2) Gunakan hasil pemindaian ini untuk menghasilkan skrip:
    ```
    sudo oscap xccdf generate fix --fix-type ansible --output draft-disa-remediate.yml --profile stig disa-stig-scan.xml
    ```

!!! peringatan

    Sekali lagi, tinjau ini sebelum menjalankannya! Apakah Anda merasakan pola di sini? Langkah verifikasi pada semua prosedur ini sangat penting!

![Playbook yang memungkinkan](images/disa_stig_pt2_img5.jpg)

## Tentang Penulis

Scott Shinn adalah CTO untuk Atomicorp, dan bagian dari tim Keamanan Rocky Linux. Dia telah terlibat dengan sistem informasi federal di Gedung Putih, Departemen Pertahanan, dan Komunitas Intelijen sejak tahun 1995. Bagian dari itu adalah membuat STIG dan persyaratan agar Anda menggunakannya dan saya sangat menyesal tentang itu.

