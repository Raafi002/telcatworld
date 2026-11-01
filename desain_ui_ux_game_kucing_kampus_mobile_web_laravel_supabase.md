# Spesifikasi Desain Frontend: Modul Game Kucing Kampus (`design.md`)

*Spesifikasi UI/UX & Desain Sistem untuk Google Stitch (Target: Mobile-first Web / PWA dengan Laravel Blade & Supabase)*

---

## 1. Project Overview & Platform Architecture

* **Nama Modul:** Game Berburu Kucing & Cat-dex (Sub-fitur Super App Kucing Kampus)
* **Target Platform:** Mobile-First Web Application / Progressive Web App (PWA)
* **Acuan Viewport:** $390 \times 844\text{ px}$ (iPhone viewport standar, elastis untuk $360\text{ px} - 430\text{ px}$; desktop diapit *mobile container wrapper* `max-w-md mx-auto`)
* **Tech Stack Frontend:** 
  * **Framework View:** Laravel 11+ Blade Components
  * **Styling Engine:** Tailwind CSS v3 / v4
  * **Interaktivitas Klien:** Alpine.js (komponen scanner, bottom sheet, state reaktif ringan)
  * **PWA Engine:** Service Worker (offline cache shell, manifest untuk *Add to Home Screen*)
* **Backend & Database:**
  * **Server Layer:** Laravel PHP (Routing, Controller, Auth Middleware, Geofencing validation)
  * **Database & BaaS:** Supabase (PostgreSQL, Row Level Security, Supabase Storage untuk foto kucing, Realtime Presence/Broadcast untuk spot feeding)
* **Konsep Game:** Gamifikasi pencarian kucing kampus. Mahasiswa memindai QR kalung (*Kalung Karilik*) menggunakan kamera mobile web, mengoleksi profil ke "Cat-dex", mengumpulkan poin berburu, dan memantau status pakan di *Adopt Feeding Spot* (AFS).

---

## 2. Design Tokens & Visual Language

Mengadopsi nuansa hangat oranye khas maskot kucing kampus yang bersih, ramah, dan dioptimalkan untuk ergonomi sentuhan jari (*thumb-friendly*).

### 2.1 Color Palette (Tailwind Tokens)

| Token Name | Hex Code | Tailwind Class | Penggunaan & Konteks UI |
| :--- | :--- | :--- | :--- |
| `brand-primary` | `#F95700` | `bg-amber-600` / `#F95700` | CTA Utama ("Pindai QR", "Koleksi Kucing"), status aktif bottom bar |
| `brand-primary-hover` | `#E04D00` | `bg-[#E04D00]` | State active/pressed pada tombol utama |
| `brand-warm-tint` | `#FFF4EC` | `bg-[#FFF4EC]` | Container ikon, kartu info latar belakang, chip aktif |
| `brand-warm-surface`| `#FFFBF8` | `bg-[#FFFBF8]` | Gradien lembut top header & surface card |
| `cat-rarity-common` | `#64748B` | `text-slate-500` | Kucing sering terlihat / domestik umum |
| `cat-rarity-rare` | `#8B5CF6` | `text-purple-600` | Kucing corak unik / ras khusus kampus |
| `cat-rarity-legend` | `#D97706` | `text-amber-600` | Kucing maskot ikonik kampus |
| `surface-canvas` | `#F8FAFC` | `bg-slate-50` | Background canvas utama aplikasi |
| `surface-card` | `#FFFFFF` | `bg-white` | Kartu kucing, bottom sheet, header sticky |
| `text-headline` | `#0F172A` | `text-slate-900` | Nama kucing, judul level, headline perolehan poin |
| `text-muted` | `#64748B` | `text-slate-500` | Deskripsi ciri fisik, timestamp, sub-teks lokasi |
| `border-subtle` | `#E2E8F0` | `border-slate-200` | Divider kartu, stroke outline reticle scanner |
| `status-healthy` | `#10B981` | `text-emerald-500` | Tag steril & vaksinasi lengkap |
| `status-cooldown` | `#F59E0B` | `text-amber-500` | Cooldown pemindaian $24\text{ jam}$ |
| `status-danger` | `#EF4444` | `text-red-500` | Laporan kucing sakit / darurat medis |

### 2.2 Typography Scale (Inter / Plus Jakarta Sans)

* **Display / Game Header:** $22\text{ px}$ | Bold ($700$) | Line Height $1.2$ (`text-xl font-bold`)
* **Card Heading (Nama Kucing):** $18\text{ px}$ | Bold ($700$) | Line Height $1.3$ (`text-lg font-bold`)
* **Sub-Heading / Section:** $15\text{ px}$ | Semi-Bold ($600$) | Line Height $1.4$ (`text-sm font-semibold`)
* **Body Text (Deskripsi & Catatan):** $13\text{ px}$ | Regular ($400$) | Line Height $1.5$ (`text-xs md:text-sm`)
* **Metric & Poin Badge:** $12\text{ px}$ | Bold ($700$) | Tracking Wide (`text-xs font-bold uppercase`)
* **Caption / Timestamp:** $11\text{ px}$ | Medium ($500$) | Line Height $1.3$ (`text-[11px] text-slate-400`)

### 2.3 Radius, Touch Targets, & Shadows

* **Touch Targets Minimum:** $44 \times 44\text{ px}$ untuk seluruh tombol dan navigation tap bar.
* **Border Radius:**
  * Card Cat-dex: `rounded-2xl` ($16\text{ px}$)
  * Floating Action Button (FAB): `rounded-full` ($999\text{ px}$)
  * Bottom Sheet Modal: `rounded-t-3xl` ($24\text{ px}$)
  * Scanner Reticle: `rounded-3xl` ($24\text{ px}$) dengan sudut bertitik fokus oranye
* **Shadows:**
  * `shadow-card`: `0 2px 10px rgba(249, 87, 0, 0.05)`
  * `shadow-nav`: `0 -4px 16px rgba(15, 23, 42, 0.06)`
  * `shadow-pop`: `0 12px 32px rgba(249, 87, 0, 0.2)` (pada modal reward poin)

---

## 3. Komponen Antarmuka Mobile-First (Laravel Blade Components)

### 3.1 Mobile Container Shell (`layouts/mobile.blade.php`)
Layout wrapper responsif untuk memastikan tampilan di desktop tetap berupa preview mobile app:
```html
<div class="min-h-screen bg-slate-200 flex justify-center selection:bg-orange-500 selection:text-white">
  <div class="w-full max-w-md bg-slate-50 min-h-screen flex flex-col relative pb-24 shadow-2xl overflow-x-hidden">
    <!-- Top Sticky Header -->
    <x-top-app-bar />
    
    <!-- Main Content Area -->
    <main class="flex-1 px-4 py-3">
      {{ $slot }}
    </main>

    <!-- Bottom Navigation Bar -->
    <x-bottom-nav active="game" />
  </div>
</div>
```

### 3.2 Web QR Scanner Component (`components/qr-scanner.blade.php`)
Memanfaatkan browser Web API (`navigator.mediaDevices.getUserMedia` atau library `@zxing/library` via CDN/Vite) yang diatur oleh Alpine.js:
* **Komponen Visual:**
  * Jendela video kamera fullscreen atau rasio $1:1$ di tengah layar.
  * *Overlay Reticle* kotak bersudut oranye menyala dengan laser horizontal berkedip (*pulsing line animation*).
  * Indikator Geolocation HTML5:
    * `Badge Hijau`: *"Terdeteksi di Lingkungan Kampus Telkom (Sah)"*
    * `Badge Kuning`: *"Di Luar Jangkauan Kampus (Poin Terkunci)"*
  * Tombol Senter (Flashlight toggle via track constraint browser).
  * Validasi form instan dikirim ke Laravel Route `/api/v1/scan-cat` via `fetch()` CSRF-tokenized.

### 3.3 Kartu Kucing Cat-dex (`components/cat-card.blade.php`)
Menampilkan entitas data yang bersumber dari tabel PostgreSQL Supabase:
* **Foto Profil Kucing:** Menggunakan URL publik Supabase Storage (`supabase.co/storage/v1/object/public/cats/...`) dengan lazy-load dan placeholder siluet oranye jika belum ditemukan (*undiscovered*).
* **Badge Kelangkaan:** Chip di sudut kanan atas foto (`Biasa`, `Langka`, `Legendaris`).
* **Tag Kesehatan:** Pill status ganda (`Steril ✓` dan `Vaksin ✓`).
* **Meta Info Terakhir Dilihat:** Teks wilayah gedung kampus dan jam *feeding* terakhir.
* **State Belum Terkunci:** Filter grayscale foto kucing dengan efek siluet gelap dan teks *"Belum Ditemukan"*.

### 3.4 Bottom Sheet Reward Poin (`components/reward-modal.blade.php`)
Ditampilkan menggunakan Alpine.js (`x-show="rewardOpen" x-transition.duration.300ms`):
* Animasi ilustrasi maskot kucing gembira.
* Penghitung Poin: Badge besar `+50 Poin` untuk scan perdana, atau `+5 Poin (Cooldown 24 Jam Aktif)`.
* Poin langsung diperbarui di UI header tanpa full reload (*optimistic UI*).
* Aksi Tombol:
  1. Tombol Oranye Utama: *"Lihat Profil di Cat-dex"* (Direct link ke `/cat-dex/{id}`)
  2. Tombol Outline: *"Lanjut Berburu"* (Tutup modal & reaktifkan kamera)

---

## 4. Integrasi Supabase & State Backend

### 4.1 Skema Data Utama (PostgreSQL Supabase)

1. **`cats` Table:**
   * `id` (UUID), `name` (varchar), `rarity` (common/rare/legendary), `gender` (male/female), `is_vaccinated` (bool), `is_neutered` (bool), `photo_url` (Supabase Storage path), `territory_zone` (varchar).
2. **`cat_sightings` Table (Riwayat Scan Mahasiswa):**
   * `id` (UUID), `cat_id` (FK to cats), `user_id` (FK to auth users), `scanned_at` (timestamp), `geo_lat`, `geo_long`, `points_awarded` (integer).
3. **`feeding_spots` Table (AFS Status):**
   * `id` (UUID), `spot_name` (varchar), `food_level` (low/medium/full), `last_refilled_at` (timestamp).

### 4.2 Alur Data pada Mobile Web
1. **Camera Capture:** Kamera browser memindai QR kalung $\rightarrow$ Alpine.js membaca teks payload (cth: `KAMPUS-CAT-UUID-08`).
2. **Kirim ke Laravel:** Request `POST` via AJAX ke Laravel Controller dengan koordinat GPS browser.
3. **Validasi Geofence & Cooldown:** Laravel mengecek batas polygon kampus dan memastikan cooldown $24\text{ jam}$ di Supabase.
4. **Respon Cepat:** Laravel mengembalikan payload JSON status kucing terbaru $\rightarrow$ Modal reward muncul secara instan.
5. **Realtime Broadcast (Opsional via Supabase Channel):** Feed aktivitas *"Mahasiswa X baru saja menemukan Si Belang di Gedung TULT!"* muncul di ticker beranda.

---

## 5. Blueprint Layar & Layout Wireframe

### Wireframe 1: Layar Utama Berburu (Scanner View)
```
+-------------------------------------------------------------+
| [Top Bar: Avatar User]   [Pts: 340 🪙]   [Level: 4 🐾]      |
+-------------------------------------------------------------+
| Banner Misi: "Temukan 1 Kucing Corak Belang Hari Ini (+25)" |
+-------------------------------------------------------------+
|                                                             |
|   +-----------------------------------------------------+   |
|   | [Video Stream Kamera Belakang via HTML5 API]        |   |
|   |                                                     |   |
|   |         + - - - - - - - - - - - - - - +             |   |
|   |         |      [ Reticle Oranye ]     |             |   |
|   |         |  Arahkan ke Kalung Karilik  |             |   |
|   |         + - - - - - - - - - - - - - - +             |   |
|   |                                                     |   |
|   |   Status: [ 📍 Dalam Area Kampus (Valid) ]          |   |
|   |   [🔦 Flash]                     [🔄 Balik Kamera]  |   |
|   +-----------------------------------------------------+   |
|                                                             |
| Mini Cat-dex Tracker:                                       |
| Koleksi Terkumpul: 18 / 45 Kucing Kampus                    |
| [Card Si Belang]  [Card Oyen]  [Card Siluet ?]              |
+-------------------------------------------------------------+
| Bottom Nav: [Beranda]  [Berburu (Active)]  [Peta AFS]  [Akun]
+-------------------------------------------------------------+
```

### Wireframe 2: Layar Koleksi Cat-dex (`/cat-dex`)
```
+-------------------------------------------------------------+
| [Top Bar: <- Kembali]      [Koleksi Cat-dex]    [🔍 Filter] |
+-------------------------------------------------------------+
| Tab Filter: [Semua (18)]  [Sering Terlihat]  [Langka]       |
+-------------------------------------------------------------+
| Grid 2 Kolom (Card List Kucing):                            |
| +-------------------------+     +-------------------------+ |
| | [Foto Oyen - TULT]      |     | [Siluet Abu-abu ?]      | |
| | "Oyen Preman TULT"      |     | "Kucing #19"            | |
| | [Vaksin ✓] [Steril ✓]   |     | Status: Belum Ditemukan | |
| | Ditemukan: 3 hari lalu  |     | Lokasi: Area Rektorat   | |
| +-------------------------+     +-------------------------+ |
|                                                             |
| +-------------------------+     +-------------------------+ |
| | [Foto Miko - Perpus]    |     | [Foto Snowy - FT]       | |
| | "Miko Putri Manja"      |     | "Snowy Putih"           | |
| | [Vaksin ✓] [Steril ✓]   |     | [Vaksin ✓] [Steril ✓]   | |
| +-------------------------+     +-------------------------+ |
+-------------------------------------------------------------+
| Bottom Nav: [Beranda]  [Berburu]  [Peta AFS]  [Cat-dex]     |
+-------------------------------------------------------------+
```

---
