# TelCat World — Modul Gamifikasi dan Pemantauan Kucing Kampus
### *Super App Kucing Kampus Universitas Telkom*

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Laravel](https://img.shields.io/badge/Laravel-11.x-FF2D20?logo=laravel&logoColor=white)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-%3E%3D8.2-777BB4?logo=php&logoColor=white)](https://php.net)
[![Supabase](https://img.shields.io/badge/Database-Supabase%20%2F%20PostgreSQL-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-Academic%20MIT-orange)](#-lisensi-dan-hak-cipta)

> **Judul Proyek Capstone:**  
> *"Optimalisasi Pemantauan Kondisi dan Kesejahteraan Kucing Kampus melalui Pendekatan Sistem Informasi Berbasis Gamifikasi dalam Kolaborasi Civitas Akademika"*  
> **Program Studi S1 Sistem Informasi — Fakultas Rekayasa Industri, Universitas Telkom (2026)**

---

## 🚀 Panduan Memulai & Cara Menjalankan Proyek

Repositori ini memuat implementasi klien mobile berbasis **Flutter** dan skema antarmuka layanan backend berbasis **Laravel RESTful API**. Ikuti langkah-langkah di bawah untuk menjalankan lingkungan pengembangan lokal.

### 1. Klien Mobile (Frontend — Flutter)

Modul frontend telah dilengkapi dengan arsitektur *offline-first mock repository* (`MockCatRepository`), sehingga seluruh alur permainan, navigasi, dan antarmuka dapat langsung diuji secara komprehensif tanpa ketergantungan koneksi backend aktif.

#### Prasyarat Sistem
* Flutter SDK (Versi `>= 3.22.0` / Dart `>= 3.4.0`)
* Android Studio / VS Code dengan ekstensi resmi Flutter & Dart
* Emulator Android (API Level 30+), Simulator iOS, atau Perangkat Fisik (dengan mode USB Debugging aktif)

#### Langkah Menjalankan
1. **Buka Terminal / PowerShell** pada direktori root proyek:
   ```bash
   cd "telcat world"
   ```
2. **Unduh seluruh dependensi aplikasi:**
   ```bash
   flutter pub get
   ```
3. **Verifikasi kepatuhan kode dan analisis lint:**
   ```bash
   flutter analyze
   ```
4. **Jalankan pengujian unit dan pengujian widget:**
   ```bash
   flutter test
   ```
5. **Eksekusi aplikasi pada perangkat / emulator:**
   ```bash
   flutter run
   ```

---

### 2. Layanan Antarmuka Pemrograman Aplikasi (Backend — Laravel API)

Modul backend bertugas menangani otentikasi token JWT, validasi kriptografi hash QR kalung kucing, perhitungan geofencing kampus Telkom University, serta rekapitulasi data agregat kesehatan satwa.

#### Prasyarat Sistem
* PHP `>= 8.2` (dengan ekstensi `pdo`, `mbstring`, `openssl`, `curl`)
* Composer (Manajer Dependensi PHP)
* Basis Data PostgreSQL (Lokal atau *Instance Managed* Supabase)

#### Langkah Menjalankan
1. **Arahkan terminal ke direktori backend (jika dipisahkan):**
   ```bash
   cd backend
   ```
2. **Pasang paket dependensi PHP:**
   ```bash
   composer install
   ```
3. **Konfigurasikan berkas lingkungan (`.env`):**
   Salin berkas template lingkungan dan sesuaikan kredensial basis data:
   ```bash
   cp .env.example .env
   ```
   *Sesuaikan variabel `DB_CONNECTION=pgsql`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, dan `DB_PASSWORD` dengan kredensial Supabase / PostgreSQL Anda.*

4. **Bentuk kunci enkripsi aplikasi:**
   ```bash
   php artisan key:generate
   ```
5. **Jalankan migrasi tabel dan seeding data master:**
   ```bash
   php artisan migrate --seed
   ```
6. **Mulai server pengembangan lokal:**
   ```bash
   php artisan serve --port=8000
   ```
   Layanan API siap menerima permintaan HTTP pada alamat: `http://127.0.0.1:8000/api/v1/telcat/`.

---

## 📖 Deskripsi & Latar Belakang Modul

Populasi kucing liar di lingkungan kampus Universitas Telkom telah menjadi bagian tak terpisahkan dari ekosistem kehidupan civitas akademika. Meskipun demikian, keterbatasan personel pengelola kampus dan ketiadaan instrumen pemantauan terpadu sering kali menyebabkan kondisi satwa yang sakit, malnutrisi, atau membutuhkan pertolongan medis terlambat teridentifikasi.

**TelCat World** hadir sebagai modul partisipatif (*citizen science*) berbasis permainan lokasi (*location-based game*) di dalam ekosistem **Super App Kucing Kampus**. Modul ini mengubah interaksi rutin mahasiswa saat menjumpai kucing kampus menjadi aksi pengumpulan data kesehatan yang bernilai ilmiah dan aplikatif bagi pengelola satwa kampus.

### Prinsip Etika Kesejahteraan Satwa (*Animal Welfare First*)
Sistem dirancang dengan mematuhi prinsip etika satwa secara ketat:
* **Tanpa Kekerasan atau Kontak Paksa:** Mekanik permainan tidak mengadopsi elemen pertempuran (*combat-free*). Seluruh interaksi difokuskan pada pembangunan rasa percaya (*Trust*) dari jarak aman.
* **Protokol Lapangan Berjarak:** Modul kamera dilengkapi kotak edukasi etika satwa (*Animal Welfare Callout*) yang melarang civitas mengejar kucing, memegang paksa, atau menyorotkan lampu kilat kamera (*flash*) langsung ke mata kucing.

---

## 🎮 Alur Permainan & Fitur Fungsional Utama

Alur inti (*Core Game Loop*) terdiri dari 5 tahapan yang saling terintegrasi:

```
[1. Pindai QR Kalung] ──► [2. Kuis Sains Warga] ──► [3. Arena Pendekatan] ──► [4. Klaim Poin] ──► [5. Koleksi Cat-Dex]
```

### 1. Pemindaian Kalung QR & Validasi Geolokasi
* Pengguna memindai kode QR fisik yang terpasang pada kalung kucing kampus.
* Sistem memvalidasi hash QR dan mengonfirmasi radius geolokasi GPS pengguna di dalam area kampus Universitas Telkom (Geofencing TULT, GKU, Asrama, atau Danau Situ Techno).

### 2. Observasi Kesehatan Fisik (Citizen Science Stepper)
* Setelah QR terverifikasi, pengguna mengisi 3 pertanyaan observasi kondisi fisik secara bertahap:
  1. **Kondisi Mata & Wajah:** Bersih & Cerah / Berair atau Belekan / Terluka.
  2. **Kondisi Tubuh & Bulu:** Sehat & Terawat / Tampak Kurus / Ada Jamur atau Luka.
  3. **Perilaku Terkini:** Tenang & Bersahabat / Sedang Tidur Pulas / Waspada atau Lemas.
* Setiap pertanyaan yang dijawab memberikan modal awal sebesar **+25% Trust Bar** (mengumpulkan modal awal hingga 75% sebelum masuk ke arena).

### 3. Arena Sesi Pendekatan Berbasis Giliran (Interactive Approach Arena)
* Sesi pendekatan membatasi pemain dalam **maksimal 3 giliran aksi** (*Turns 1/3, 2/3, 3/3*).
* Menampilkan avatar 2D, indikator suasana hati dinamis (*Waspada 👀*, *Tenang 😌*, *Nyaman & Siap Luluh 💖*), serta meteran *Trust Bar*.
* **Taktik Pendekatan:**
  * `👋 Elus Dagu`: Menambah rasa percaya kucing (+20% Trust jika kucing tenang).
  * `🐾 Beri Ruang`: Menjaga jarak aman etis, menenangkan emosi kucing dari status waspada kembali tenang (+10% Trust).
  * `💖 Luluhkan`: Mengunci giliran dan memicu minigame ketepatan waktu.
* **Horizontal Timing Bar:**
  * Jarum indikator meluncur secara osilasi melewati zona: **Miss** (*Merah di tepi*), **Good** (*Kuning di sisi tengah*), dan **Sweet Spot** (*Hijau 18% tepat di tengah*).
  * Mengetuk tombol *'Ketuk Sekarang! (Luluhkan)'* tepat pada Sweet Spot menyelesaikan sesi secara instan dengan keberhasilan 100%.

### 4. Modal Hasil Berhasil & Perolehan Poin
* Tampilan pop-up berlatar belakang semi-transparan gelap yang mengapresiasi partisipasi sains warga.
* Menyerahkan reward `+50 Poin Ekspedisi`, mencatat suvenir kampus yang berhasil dibuka (*memento*), dan merangkum laporan kesehatan.

### 5. Modul Cat-Dex (Sanctuary & Koleksi Digital)
* **Tab 1: ☕ Kafe Kucing (*Neko Atsume Style*):** Kanvas diorama 2D isometrik suasana ruangan kafe yang hangat, menampilkan 5 hingga 8 kucing aktif yang sudah diluluhkan. Interaktif saat disentuh (memunculkan efek hati `❤️` dan balon kutipan suvenir).
* **Tab 2: 📋 Katalog Cat-Dex:** Grid 2 kolom dengan filter chip (*Semua*, *Terkoleksi*, *Belum Ditemukan*). Kucing terkoleksi tampil penuh warna, sedangkan kucing yang belum dijumpai berwujud siluet gelap bertanda tanya `???` disertai petunjuk lokasi area kampus.
* **Buku Profil Kucing (*Catbook Polaroid Modal*):** Kartu berlatar krem hangat (`#FFFDF5`) dengan foto polaroid, statistik level luluh kumulatif, frekuensi observasi, dan catatan suvenir khas kampus (*misal: Daun Emas Situ Techno, Bunga Kamboja Deli*).

### 6. Peta Teritorial Kampus
* Peta isometrik kampus Universitas Telkom dengan pin zona teritorial (TULT & Asrama, GKU & Perkuliahan Bersama, Situ Techno & Open Library, Student Center).
* Menyajikan informasi daftar kucing penghuni wilayah serta tombol pintas pemindaian cepat.

---

## 🏗️ Arsitektur Sistem & Spesifikasi Teknologi

Sistem TelCat World mengadopsi pola arsitektur modular terdistribusi (*Decoupled Client-Server Architecture*):

```
┌─────────────────────────────────────────┐
│         Klien Mobile (Flutter)          │
│   (State Management, Canvas, Animation) │
└────────────────────┬────────────────────┘
                     │ HTTP / RESTful API (JSON)
                     │ Authorization: Bearer <JWT>
┌────────────────────▼────────────────────┐
│      Backend Service (Laravel 11)       │
│  - QR & Geofence Verification Service   │
│  - Citizen Science Aggregation Engine   │
│  - Gamification & Point Transaction     │
└────────────────────┬────────────────────┘
                     │ SQL / PostGIS
┌────────────────────▼────────────────────┐
│  Database (Supabase / PostgreSQL)       │
│  - users & user_cat_collections         │
│  - campus_cats & observations_log       │
│  - expedition_points_ledger             │
└─────────────────────────────────────────┘
```

### Spesifikasi Tumpukan Teknologi (*Tech Stack*)

| Lapisan Arsitektur | Teknologi / Pustaka | Peran Fungsional |
| :--- | :--- | :--- |
| **Mobile Client** | Flutter 3.19+ & Dart 3.3+ | *Multiplatform mobile runtime*, manajemen render 60fps, kanvas isometrik. |
| **Desain & Tipografi** | Google Fonts (*Plus Jakarta Sans*) | Hierarki tipografi modern ramah civitas akademika. |
| **Pola Arsitektur Frontend** | Feature-First Clean Architecture | Pemisahan fungsional modular antara `core/` dan `features/`. |
| **Backend Framework** | Laravel 11.x (PHP 8.2+) | Penyedia API RESTful, validasi token, *middleware security*, rate-limiting. |
| **Autentikasi & Sesi** | JWT (JSON Web Token) | Integrasi Single Sign-On (SSO) modul induk Super App Kucing Kampus. |
| **Basis Data Relasional** | PostgreSQL 15+ / Supabase | Penyimpanan entitas kucing, relasi koleksi, dan riwayat observasi satwa. |
| **Spasial / Geofencing** | PostGIS Functions / Haversine | Validasi radius presensi fisik pemindaian QR di area kampus. |

---

## 📂 Struktur Direktori Repositori

```text
telcat-world/
├── assets/                                 # Aset grafis statis dan multimedia
│   ├── images/                             # Maskot Tel-U, background kafe, denah kampus, avatar kucing
│   └── icons/                              # Ikon tapak (paw), memento suvenir, dan penanda peta
├── docs/                                   # Dokumentasi rekayasa sistem & capstone
│   ├── prd.md                              # Product Requirement Document & spesifikasi fungsional
│   ├── desain.md                           # Panduan sistem desain UI, palet token, & komponen
│   └── logo.jpeg                           # Identitas visual resmi maskot kucing kampus
├── stitch_export/                          # Artefak visual hasil ekstraksi desain antarmuka
├── lib/                                    # Kode sumber aplikasi Flutter
│   ├── main.dart                           # Entry point aplikasi & konfigurasi SystemChrome
│   ├── core/                               # Komponen inti transversal (Cross-cutting Concerns)
│   │   ├── constants/
│   │   │   ├── app_colors.dart             # Definisi token warna (Orange, Peach, Sweet Spot Green)
│   │   │   ├── app_dimensions.dart         # Standar dimensi spacing, radius kartu, & elevasi
│   │   │   └── app_assets.dart             # Path konstan seluruh berkas aset lokal
│   │   ├── theme/
│   │   │   └── app_theme.dart              # Konfigurasi ThemeData Plus Jakarta Sans
│   │   └── widgets/
│   │       ├── app_header_bar.dart         # Top App Bar konsisten (Mascot Box + Status Pill)
│   │       ├── primary_button.dart         # Tombol aksi utama 54px oranye (#F26A1B)
│   │       └── secondary_button.dart       # Tombol sekunder putih berbingkai
│   └── features/                           # Modul fungsional (Feature-Driven Structure)
│       ├── navigation/                     # Shell navigasi utama 3 tab + FAB 'Pindai QR'
│       │   └── views/
│       │       └── main_navigation_screen.dart
│       ├── qr_scan/                        # Layar 1: Pemindai QR & validasi lokasi
│       │   ├── views/
│       │   │   ├── qr_scan_screen.dart
│       │   │   └── widgets/
│       │   │       └── animal_welfare_card.dart
│       ├── quiz_observation/               # Layar 2: Kuis observasi 3 pertanyaan fisik
│       │   ├── models/
│       │   │   └── observation_answer.dart
│       │   └── views/
│       │       ├── quiz_observation_screen.dart
│       │       └── widgets/
│       │           └── quiz_option_card.dart
│       ├── approach_session/               # Layar 3: Arena interaktif giliran & timing bar
│       │   └── views/
│       │       ├── approach_arena_screen.dart
│       │       └── widgets/
│       │           └── horizontal_timing_bar.dart
│       ├── encounter_result/               # Layar 4: Modal keberhasilan & klaim +50 poin
│       │   └── views/
│       │       └── result_modal_dialog.dart
│       ├── cat_dex/                        # Layar 5: Galeri sanctuary & katalog koleksi
│       │   ├── data/
│       │   │   ├── models/cat_model.dart
│       │   │   └── repositories/mock_cat_repository.dart
│       │   └── views/
│       │       ├── cat_dex_tab_screen.dart
│       │       ├── profile_tab_screen.dart
│       │       └── widgets/
│       │           ├── cafe_sanctuary_view.dart
│       │           ├── catalog_grid_view.dart
│       │           └── catbook_polaroid_modal.dart
│       └── map_territory/                  # Modul peta teritorial & detail kawasan kampus
│           ├── models/territory_model.dart
│           └── views/
│               ├── territory_map_screen.dart
│               └── territory_detail_screen.dart
├── test/                                   # Pengujian otomatis widget dan unit
│   └── widget_test.dart
├── pubspec.yaml                            # Konfigurasi dependensi dan aset Flutter
└── README.md                               # Dokumentasi utama repositori
```

---

## 👥 Identitas Tim Pengembang

Proyek Capstone ini dikembangkan dan disusun oleh **Kelompok SUPER-SUB**:

| NIM | Nama Lengkap | Peminatan / Konsentrasi | Peran Tanggung Jawab (*Role*) |
| :---: | :--- | :---: | :--- |
| **102022300053** | **Raafi Naufal Fadhillah** | EISD | **Game & Frontend Lead** |
| **102022300253** | **Fitriansyah** | EISD | **Backend, Data & Architecture Lead** |
| **102022330238** | **Feriangga Arkaan Prayetno** | ERP | **Business, Process & Project Lead** |

* **Program Studi:** S1 Sistem Informasi  
* **Fakultas:** Fakultas Rekayasa Industri (FRI)  
* **Institusi:** Universitas Telkom, Bandung  
* **Tahun Akademik:** 2026  

---

## 📄 Lisensi dan Hak Cipta

Proyek ini dikembangkan untuk kepentingan akademik dan penelitian tugas akhir Capstone di Universitas Telkom. Seluruh kode sumber dilisensikan di bawah lisensi [MIT License](LICENSE), dengan hak moral nama satwa dan citra kampus tetap menjadi milik civitas akademika Universitas Telkom.
