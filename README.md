# TelCat World — Modul Gamifikasi dan Pemantauan Kucing Kampus
### *Super App Kucing Kampus Universitas Telkom*

[![Flutter](https://img.shields.io/badge/Flutter-3.19.6-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3.4-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Laravel](https://img.shields.io/badge/Laravel-11.x-FF2D20?logo=laravel&logoColor=white)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-%3E%3D8.2-777BB4?logo=php&logoColor=white)](https://php.net)
[![Supabase](https://img.shields.io/badge/Database-Supabase%20%2F%20PostgreSQL-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-Academic%20MIT-orange)](#-lisensi-dan-hak-cipta)

> **Judul Proyek Capstone:**  
> *"Optimalisasi Pemantauan Kondisi dan Kesejahteraan Kucing Kampus melalui Pendekatan Sistem Informasi Berbasis Gamifikasi dalam Kolaborasi Civitas Akademika"*  
> **Program Studi S1 Sistem Informasi — Fakultas Rekayasa Industri, Universitas Telkom (2026)**

---

## 🚀 Panduan Memulai & Cara Menjalankan Proyek

Repositori ini memuat implementasi klien mobile berbasis **Flutter** (versi V2) dan kontrak integrasi layanan backend berbasis **Laravel RESTful API**. Ikuti langkah-langkah di bawah untuk menjalankan lingkungan pengembangan lokal.

### 1. Klien Mobile (Frontend — Flutter 3.19.6)

Modul frontend telah dilengkapi *offline-first mock repository* (`MockCatRepository`), sehingga seluruh alur pemindaian, batas harian, mini-game mengelus, selebrasi, penamaan permanen, Cat-Dex, dan peta teritorial dapat diuji langsung tanpa koneksi backend aktif.

#### Prasyarat Sistem
* Flutter SDK **3.19.6** (Dart **3.3.4**) sudah terpasang dan tersedia di `PATH` sistem *(jika memakai SDK terpisah/non-PATH, sesuaikan `dart.flutterSdkPath` pada `.vscode/settings.json`)*
* Android Studio / VS Code dengan ekstensi resmi Flutter & Dart
* Konfigurasi Android Gradle `7.6.3` / AGP `7.3.0` / Kotlin `1.8.22` (sudah terkonfigurasi di `android/`)
* Emulator Android (API Level 30+), Simulator iOS, atau Perangkat Fisik (USB Debugging aktif)

#### Langkah Menjalankan (Terminal / PowerShell)
1. **Arahkan ke direktori root proyek:**
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
4. **Jalankan pengujian unit dan widget:**
   ```bash
   flutter test
   ```
5. **Eksekusi aplikasi pada perangkat / emulator:**
   ```bash
   flutter run
   ```

> **Mode Demo / Debug Pengujian:** Tekan dan tahan (**long-press 2 detik**) judul header pada layar **Pemindai QR** atau tab **Profil** untuk membuka panel simulasi **Mode Demo / Debug** (*Reset Cooldown Hari Ini* dan *Simulasi 4x Pertemuan* agar pertemuan ke-5 dan fitur penamaan dapat langsung diuji).

---

### 2. Layanan Antarmuka Pemrograman Aplikasi (Backend — Laravel API)

Modul backend bertugas menangani autentikasi token JWT, validasi kriptografi hash QR kalung kucing, perhitungan geofencing kampus Telkom University, pencatatan pertemuan (`encounter_count`), validasi cooldown harian (1x/hari), serta penguncian nama permanen unik.

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

Populasi kucing di lingkungan kampus Universitas Telkom telah menjadi bagian tak terpisahkan dari kehidupan civitas akademika. **TelCat World** hadir sebagai sub-modul permainan interaktif berbasis lokasi (*location-based game*) di dalam ekosistem **Super App Kucing Kampus** untuk mendorong mahasiswa mengenal, menyapa, dan memetakan persebaran kucing kampus secara terstruktur melalui katalog digital terpusat (*Cat-Dex*).

### Prinsip Etika Kesejahteraan Satwa (*Animal Welfare First*)
* **Tanpa Kekerasan atau Kontak Paksa:** Mekanik permainan bebas pertempuran (*combat-free*). Interaksi difokuskan pada mini-game mengelus lembut tanpa menekan atau mengejar kucing sungguhan.
* **Protokol Lapangan Berjarak:** Layar pemindai dilengkapi kotak edukasi etika satwa (*Animal Welfare Callout*) yang melarang civitas mengejar kucing, memegang paksa, atau menyalakan flash kamera langsung ke mata kucing.
* **Pemisahan Ekonomi Poin:** Modul game TelCat World **tidak** menggunakan sistem poin agar tidak tumpang tindih dengan modul *feeding spot* dan adopsi pada Super App induk.

---

## 🎮 Alur Permainan & Fitur Fungsional Utama (V2)

Alur inti (*Core Game Loop*) berjalan sebagai berikut:

```
[1. Pindai QR & GPS] ──► [Cek Cooldown Harian (1x/hari/kucing)]
                              ├── SUDAH ──► Pop-up Kucing Sedih ──► Cat-Dex (Profil Kucing)
                              └── BELUM ──► [2. Splash "Jinakkan Kucing!" (1,5 dtk)]
                                                   │
                                                   ▼
                                            [3. Mini-Game Mengelus (2 Fase Acak)]
                                                   │
                                                   ▼
                                            [4. Selebrasi (Pertemuan X / 5) & Beri Nama]
                                                   │
                                                   ▼
                                            [5. Koleksi Cat-Dex & Peta Teritorial]
```

### 1. Pemindaian Kalung QR & Batas Scan Harian (Daily Cooldown)
* Pengguna memindai kode QR pada kalung kucing kampus disertai validasi radius GPS Universitas Telkom.
* Sistem menerapkan batas **maksimal 1x scan per hari per kucing**:
  * **Jika sudah di-scan hari ini:** Muncul pop-up ilustrasi 2D kucing sedih (`_sad.png`), pesan *"Kamu sudah menyapa kucing ini hari ini, coba lagi besok!"*, dan tombol **"Lihat Profil Kucing"** yang langsung membuka Catbook kucing tersebut.
  * **Jika belum di-scan hari ini:** Muncul layar transisi penuh bertuliskan **"Jinakkan Kucing!"** selama **1,5 detik** sebelum masuk otomatis ke arena mengelus.

### 2. Mini-Game Mengelus (2 Fase Acak)
* **Dua Fase Otomatis:** Progres `0%–50%` menampilkan pose pertama yang dipilih secara acak (pose **kepala siap diusap** `_head.png` atau pose **tiduran telentang** `_belly.png`), lalu pada `50%–100%` otomatis bertransisi ke pose lainnya.
* **Mekanik Swipe Lingkaran Berkilau:** Lingkaran interaktif muncul dari tengah atau sisi kiri layar melintasi area kucing ala *Charged Attack* Pokémon GO untuk disapu jari pemain (`GestureDetector`).
* **Umpan Balik & Animasi:** Setiap sapuan memicu `HapticFeedback.lightImpact()`, partikel hati melayang, animasi *squish/bounce* & *wiggle* halus, serta animasi *idle* bernapas pelan. Antarmuka dirancang hangat bergaya *Neko Atsume* dengan teks seminimal mungkin.

### 3. Layar Selebrasi, Encounter Tracking, & Fitur Beri Nama
* Setelah progres mencapai `100%`, `encounterCount` bertambah 1 dan `lastScannedDate` diperbarui.
* Layar selebrasi penuh tampil dengan konfeti/hati, sprite melompat bahagia (`_happy.png`), serta lencana **"Pertemuan X / 5"**.
* **Penamaan Permanen Unik:** Kucing baru memakai nama sementara (*placeholder*). Setelah mencapai **5x pertemuan** (`encounterCount >= 5`) dan `isNameLocked == false`, tombol **"Beri Nama"** terbuka. Nama permanen bersifat unik secara global (*case-insensitive*) dan langsung terkunci (`isNameLocked = true`).

### 4. Modul Cat-Dex & Peta Teritorial
* **Tab ☕ Kafe Kucing (*Neko Atsume Style*):** Kanvas diorama isometrik 2D (menampilkan hingga 5 kucing aktif) dengan **3 tema ruangan** (*Kafe Hangat*, *Taman Pastel*, *Kafe Malam*), animasi **jalan loop independen** antar waypoint, **drag-and-drop** ke perabotan (*Cat Tree*, bantal, kardus → `Zzz... 💤`; mangkuk makanan → `🐟`), obrolan simbol antarkucing, serta **Mode Full Screen** dengan **Pinch-to-Zoom**, **Photo Mode**, dan mainan (**Snack Ikan** & **Laser Pointer**).
* **Tab 📋 Katalog Cat-Dex & Catbook Polaroid:** Grid 2 kolom (*Semua*, *Terkoleksi*, *Belum Ditemukan* dengan siluet `???`). Kartu profil polaroid (`#FFFDF5` di Mode Terang / `#302B29` di Mode Gelap) menampilkan progres pertemuan, waktu sapaan terakhir, gelembung kutipan lucu kucing (`quote`), kondisi kesehatan dari data pengelola kampus (*read-only*), serta tombol **"Beri Nama Permanen"** bila syarat 5x pertemuan terpenuhi.
* **Peta Teritorial:** Denah isometrik `campus_map.png` (rasio 1:1, `InteractiveViewer` zoom `1.0x`–`2.6x`) dengan **4 zona** berpin presisi (**TULT & Asrama**, **GKU**, **Cacuk**, **Fakultas Depan**), 3 kucing mini patroli di jalan kampus, gelembung celoteh di zona yang kucingnya belum disapa hari ini, awan melayang, suasana **Pagi / Senja / Malam** (otomatis sesuai jam atau tombol manual), serta 3 *easter egg* lingkungan (Danau Situ Techno, Taman Tugu, Taman Bangku Kampus).
* **Mode Gelap (Cozy Warm Espresso):** Tombol ikon bulan/matahari di header dan switch **Mode Gelap** di tab Profil. Saat aktif, Kafe Kucing otomatis memakai tema *Kafe Malam* dan peta memakai suasana Malam.
* **Shell Navigasi & Profil:** Bottom bar dengan 3 menu (**Cat-Dex**, **Peta**, **Profil**) + FAB kapsul oranye **"Pindai QR"** melayang 24px di atas bottom bar. Tab Profil menampilkan **avatar kucing interaktif** (dapat dipilih dari kucing yang ditemui), **gelar dinamis**, pill **Best Buddy**, statistik **Kucing Terkoleksi** dan **Total Pertemuan** (tanpa poin), **grid medali visual 3 kolom**, serta tombol ikon info (`ℹ️`) di header.

---

## 🏗️ Arsitektur Sistem & Spesifikasi Teknologi

```
┌─────────────────────────────────────────┐
│         Klien Mobile (Flutter)          │
│ (Feature-First, Canvas, Swipe Gestures) │
└────────────────────┬────────────────────┘
                     │ HTTP / RESTful API (JSON)
                     │ Authorization: Bearer <JWT>
┌────────────────────▼────────────────────┐
│      Backend Service (Laravel 11)       │
│  - QR & Geofence Verification Service   │
│  - Daily Cooldown & Encounter Logger    │
│  - Global Unique Cat Naming Service     │
└────────────────────┬────────────────────┘
                     │ SQL / PostGIS
┌────────────────────▼────────────────────┐
│  Database (Supabase / PostgreSQL)       │
│  - cats (name, is_name_locked, variant) │
│  - user_cat_collections (encounter_cnt) │
└─────────────────────────────────────────┘
```

| Lapisan Arsitektur | Teknologi / Pustaka | Peran Fungsional |
| :--- | :--- | :--- |
| **Mobile Client** | Flutter **3.19.6** & Dart **3.3.4** | *Multiplatform mobile runtime*, animasi 2D 60fps, *swipe* partikel, kanvas kafe. |
| **Desain & Tipografi** | Google Fonts (*Plus Jakarta Sans*) | Hierarki tipografi modern ramah civitas akademika. |
| **Pola Arsitektur Frontend** | Feature-First Clean Architecture | Pemisahan fungsional modular antara `core/` dan `features/`. |
| **Konfigurasi Android** | Gradle `7.6.3` • AGP `7.3.0` • Kotlin `1.8.22` | Kompatibilitas build Android penuh untuk Flutter 3.19.6. |
| **Backend Framework** | Laravel 11.x (PHP 8.2+) | Penyedia API RESTful, validasi cooldown harian, & penguncian nama unik. |
| **Autentikasi & Sesi** | JWT (JSON Web Token) | Integrasi Single Sign-On (SSO) modul induk Super App Kucing Kampus. |
| **Basis Data Relasional** | PostgreSQL 15+ / Supabase (+ PostGIS) | Penyimpanan katalog kucing, riwayat pertemuan, & geofencing kampus. |

---

## 📂 Struktur Direktori Repositori

```text
telcat-world/
├── .vscode/
│   └── settings.json                       # Konfigurasi lokal path Flutter SDK workspace (opsional)
├── android/                                # Konfigurasi Android Groovy (Gradle 7.6.3 / AGP 7.3.0)
├── assets/
│   ├── images/                             # 12 pose kucing + 6 sprite walk cycle (oren, putih, hitam),
│   │                                       # 3 tema kafe (cafe_bg_cozy/pastel/night.png), cafe_background.png,
│   │                                       # campus_map.png, zone_tult.png, & logo
│   └── icons/                              # Direktori ikon tambahan
├── docs/
│   ├── prd.md                              # Product Requirement Document (V2)
│   ├── desain.md                           # Panduan sistem desain UI & spesifikasi aset V2
│   └── logo.jpeg                           # Identitas visual resmi maskot kucing kampus
├── stitch_export/                          # Artefak visual desain Stitch V1 & V2
├── lib/
│   ├── main.dart                           # Entry point aplikasi & konfigurasi SystemChrome
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_assets.dart             # Konstanta path 12 pose, 6 walk cycle, 3 tema kafe, & aset lain
│   │   │   ├── app_colors.dart             # Token warna dasar & palet game pastel V2
│   │   │   └── app_dimensions.dart         # Standar spacing, radius, & elevasi
│   │   ├── theme/
│   │   │   ├── app_theme.dart              # ThemeData terang & gelap (Cozy Warm Espresso), Plus Jakarta Sans
│   │   │   └── theme_controller.dart       # ValueNotifier<ThemeMode> pengubah mode terang/gelap
│   │   └── widgets/
│   │       ├── app_header_bar.dart         # Top App Bar + pemicu tahan 2 detik Mode Demo
│   │       ├── demo_debug_sheet.dart       # Panel Mode Demo/Debug (Reset Cooldown & Simulasi 4x)
│   │       ├── primary_button.dart         # Tombol aksi utama 54px oranye (#F26A1B)
│   │       └── secondary_button.dart       # Tombol sekunder putih berbingkai
│   └── features/
│       ├── navigation/
│       │   └── views/
│       │       └── main_navigation_screen.dart # Shell navigasi 3 menu + FAB 'Pindai QR'
│       ├── qr_scan/
│       │   └── views/
│       │       ├── qr_scan_screen.dart     # Pemindai QR, geofence, & pop-up cooldown harian
│       │       └── widgets/
│       │           └── animal_welfare_card.dart
│       ├── approach_session/
│       │   └── views/
│       │       ├── tame_splash_screen.dart # Layar transisi 1,5 dtk "Jinakkan Kucing!"
│       │       └── approach_arena_screen.dart # Mini-game mengelus 2 fase & swipe orb
│       ├── encounter_result/
│       │   └── views/
│       │       └── celebration_screen.dart # Layar selebrasi "Pertemuan X / 5" & Beri Nama
│       ├── cat_dex/
│       │   ├── data/
│       │   │   ├── models/cat_model.dart   # Model kucing V2 (CatVariant, encounterCount, isNameLocked)
│       │   │   └── repositories/mock_cat_repository.dart
│       │   └── views/
│       │       ├── cat_dex_tab_screen.dart
│       │       ├── profile_tab_screen.dart
│       │       └── widgets/
│       │           ├── cafe_room_stage.dart     # Stage isometrik kafe, loop jalan, drag-drop, mainan, & obrolan
│       │           ├── cafe_sanctuary_view.dart # Tab Kafe Kucing, mode Full Screen, zoom, & Photo Mode
│       │           ├── catalog_grid_view.dart
│       │           ├── catbook_polaroid_modal.dart
│       │           └── rename_cat_dialog.dart
│       └── map_territory/
│           ├── models/territory_model.dart
│           └── views/
│               ├── territory_map_screen.dart
│               └── territory_detail_screen.dart
├── test/
│   └── widget_test.dart                    # Pengujian shell navigasi, Kafe Kucing (drag/Full Screen/fitur), & repo V2
├── pubspec.yaml                            # Konfigurasi dependensi (Dart >=3.3.0) & aset
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
