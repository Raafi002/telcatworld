# DESIGN SYSTEM & UI SPECIFICATION (`desain.md`) — Versi 2
## Proyek: Super App Kucing Kampus — Modul TelCat World

> Sinkron dengan `docs/prd.md` (V2). Referensi visual: `stitch_export/stitch_telcat_world_mobile_app_v2/` — `transisi_jinakkan_kucing_game_splash`, `sesi_elus_pose_kepala_35`, `sesi_elus_pose_perut_80`, `selebrasi_jinak_sepenuhnya_game_victory`.

---

## 1. Identitas Visual & Filosofi Desain
Gaya visual mengusung tema **Clean, Warm, Playful, & Modern Utility**. Layar utilitas (Cat-Dex, Peta, Profil, Pemindai) memakai kartu putih bersih di atas latar abu-abu sangat muda dengan sudut membulat dan aksen oranye hangat. Layar **permainan** (transisi, mini-game mengelus, selebrasi) memakai gaya **hangat bergaya Neko Atsume**: latar gradasi pastel lembut, sprite kucing 2D besar di tengah, partikel hati/bintang tipis, dan **teks instruksi seminimal mungkin**.

**Dihapus dari sistem desain V1:** komponen *Horizontal Timing Bar* (zona Miss/Good/Sweet Spot), *Trust Bar* bergiliran, indikator giliran "Giliran X/3", kartu pilihan kuis observasi, *Point Pill Badge* ("✨ Estimasi: +35-50 Poin"), dan segala elemen terkait poin.

---

## 2. Palet Warna (Color Tokens)

### 2.1 Token Dasar (tidak berubah)
* **Background Primary:** `#F8F9FA`
* **Surface / Card:** `#FFFFFF`, border tipis `#EDEDED`
* **Brand Primary (Vibrant Cat Orange):** `#F26A1B` hingga `#FF7A00`
* **Brand Secondary (Soft Peach):** `#FFF3EB`
* **Terracotta (teks di atas peach):** `#9A3412`
* **Text Primary:** `#18181B` — **Text Secondary:** `#71717A`
* **Info / Guide Gray:** `#F4F4F5`
* **Catbook Cream:** `#FFFDF5` (kartu profil polaroid)

### 2.2 Token Status
* **Success:** `#16A34A` (latar `#DCFCE7`) — dipakai pada indikator status terhubung/terkunci dan pita sukses.
* **Warning:** `#EAB308` (latar `#FEF9C3`)
* **Danger:** `#DC2626` (latar `#FEE2E2`) — dipakai untuk galat validasi (mis. nama sudah dipakai).

### 2.3 Token Layar Game (baru)
| Token | Nilai (acuan Stitch) | Penggunaan |
| :--- | :--- | :--- |
| `game-splash-gradient` | Oranye `#F26A1B` → `#FF7A00` (atas–bawah), pusat memudar ke peach terang | Latar transisi "Jinakkan Kucing!" |
| `game-sunburst` | Peach `#FFF3EB` opasitas ±40% | Sinar radial di splash & selebrasi |
| `petting-bg-head` | Gradasi kuning krem lembut (±`#FDEBC8` → `#EFE3B5`) | Latar sesi pose kepala |
| `petting-bg-belly` | Gradasi peach muda (±`#FCE3D2` → `#FBEDEA`) | Latar sesi pose perut |
| `celebration-bg` | Gradasi pastel salmon/peach (±`#FFD9CC` → `#FBEFE6`) | Latar layar selebrasi |
| `swipe-orb` | Gradasi oranye `#F97316` → `#F26A1B`, halo kuning `#FACC15` | Lingkaran target swipe |
| `swipe-path` | Oranye `#FDBA74` putus-putus | Jalur swipe |
| `heart-accent` | Merah muda–merah `#EF4444` / `#FB7185` | Ikon progres & partikel hati |

### 2.4 Token Mode Gelap (Cozy Warm Espresso)
| Token | Nilai | Penggunaan |
| :--- | :--- | :--- |
| Background / Scaffold | `#1C1917` | Latar layar |
| Card / Surface / Modal | `#292524` | Kartu, dialog, bottom sheet, bottom bar |
| Elevated Surface / Pill | `#35302E` | Pill badge, segmented tab, input |
| Border / Divider | `#44403C` | Garis tepi halus |
| Primary Accent | `#FB923C` | Aksen oranye hangat |
| Text Primary / Secondary | `#FAF5EE` / `#D6CFC7` | Teks utama / pendukung |
| Latar avatar kucing | `#3A3532` | Lingkaran avatar agar kucing hitam tetap terlihat (+ pendaran lembut) |

* Tombol ikon bulan/matahari (`Icons.dark_mode_outlined` / `Icons.light_mode_outlined`) di header dan switch "Mode Gelap" di tab Profil mengganti tema; Kafe Kucing otomatis ke `cafe_bg_night.png` dan peta ke suasana Malam.

---

## 3. Tipografi (Typography Scale)
Font **Plus Jakarta Sans** (Inter sebagai cadangan):
* **App Bar Title:** 16px, Bold (700), `#18181B`
* **App Bar Subtitle:** 13px, Regular (400), `#71717A`
* **Section Eyebrow:** 11px, Bold, Uppercase, letter-spacing 0.8px, `#71717A`
* **Hero Heading (H1):** 26px, ExtraBold (800), line-height 1.25
* **Card Title (H2):** 20px, Bold (700)
* **Body Copy:** 14px, Regular, `#71717A`, line-height 1.5
* **Button Label:** 16px, Bold, putih (Primary) / `#18181B` (Secondary)
* **Splash Title (baru):** 40–48px, ExtraBold (800), warna terracotta tua (`#9A3412`/`#7C2D12`) dengan bayangan teks bertumpuk berwarna coklat dan kontur putih tebal (efek stiker/sticker).
* **Celebration Title (baru):** 28–30px, ExtraBold (800), coklat tua (`#501C00`), rata tengah.
* **Game HUD Label (baru):** 14–16px, Bold (nama kucing); 12–13px, SemiBold (persentase, level, mood).

---

## 4. Komponen Inti Layar Utilitas

### 4.1 Top Header Bar
* **Kiri:** ikon maskot dalam kotak membulat (40×40px, radius 10px). **Tengah-kiri:** teks vertikal 2 baris ("Kucing Kampus" / "TelCat World"). **Kanan:** *Status Pill Badge* putih berborder `#E4E4E7` (radius 999px, padding 6×12px).

### 4.2 Kartu Konten Utama
* Radius 20px, border `1px #EFEFEF`, padding 20px, shadow `0 4px 20px rgba(0,0,0,0.03)`.

### 4.3 Kotak Info Etika ("Sebelum Mulai")
* Latar `#F4F4F5`, radius 16px, padding 16px, ikon `i` dan judul tebal; dipakai pada layar pemindai QR.

### 4.4 Tombol Aksi
* **Primary:** tinggi 54px, lebar penuh, `#F26A1B`, radius 14px, teks putih tebal.
* **Secondary:** tinggi 54px, lebar penuh, putih, border `1.5px #E4E4E7`, radius 14px, teks hitam tebal.

### 4.5 Shell Navigasi
* *Bottom navigation* tetap dengan 3 menu (Cat-Dex, Peta, Profil) dan FAB kapsul oranye "Pindai QR" berikon kamera, melayang minimal 24px di atas bottom bar.

---

## 5. Spesifikasi Layar Game (Baru — Acuan Stitch V2)

### 5.1 Pop-up "Sudah Menyapa Hari Ini" (Daily Cooldown)
* **Bentuk:** modal putih di tengah, radius 24px, latar belakang gelap semi-transparan.
* **Isi (berurutan):** ilustrasi 2D kucing sedih (`cat_<variasi>_sad.png`, ±140px); pesan **"Kamu sudah menyapa kucing ini hari ini, coba lagi besok!"** (16px, SemiBold, rata tengah); tombol **Primary "Lihat Profil Kucing"**.
* **Perilaku:** tombol menutup modal, berpindah ke tab Cat-Dex, dan membuka kartu profil (*Catbook*) kucing terkait. Menutup di luar modal kembali ke beranda tanpa efek.

### 5.2 Layar Transisi "Jinakkan Kucing!" (Splash)
* **Latar:** gradasi oranye penuh layar dengan pusat memudar peach, sinar radial (*sunburst*) berpusat di tengah, tapak kucing pudar dan bintang kontur sebagai dekorasi tepi.
* **Konten tunggal:** teks **"Jinakkan Kucing!"** dua baris, tipografi Splash Title (§3), diapit dua ikon bulat putih berisi tapak oranye dengan percikan ✨.
* **Aturan:** **tanpa tombol dan tanpa teks lain**; durasi tampil **1,5 detik**, lalu navigasi otomatis ke mini-game. Animasi masuk: skala pop (0.8 → 1.0, *ease-out-back*) disertai rotasi lambat sunburst.

### 5.3 Layar Mini-Game Mengelus
**Tata letak (atas → bawah):**
1. **Header HUD** (margin 16–20px dari tepi): tombol kembali bulat putih (±44px) · lencana nama kucing berikon tapak (pose perut menambahkan chip level, mis. "Level 4") · kapsul progres.
2. **Kapsul progres:** ikon hati dalam lingkaran merah, bar progres oranye (tinggi 8–10px, radius penuh) dan persentase (mis. "35%"). Pose perut dapat menampilkan label mood kecil (mis. "MANJA") di atas bar.
3. **Panggung kucing:** sprite kucing besar di tengah layar (±75% lebar layar, rasio persegi), dengan bayangan elips lembut di bawahnya dan partikel hati/bintang tipis melayang di sekitar.
4. **Footer kontrol:** tombol suara bulat (kiri) · indikator fase (kapsul putih berisi titik-titik dan ikon tapak; titik aktif oranye, belum aktif peach) · tombol jeda bulat (kanan).

**Latar per pose:** pose kepala memakai `petting-bg-head` (kuning krem), pose perut memakai `petting-bg-belly` (peach), dengan *blur blob* lembut sebagai dekorasi.

**Elemen swipe (Charged Attack):**
* **Orb target:** lingkaran 56–72px bergradasi oranye berikon tapak/hati, border putih tebal, halo kuning/oranye berpendar. Orb pertama bergaya lebih besar sebagai "kepala jalur".
* **Jalur:** busur/cincin putus-putus (`swipe-path`) yang melewati area kepala (pose kepala) atau mengitari perut (pose perut); beberapa orb kecil (ikon hati/kilau) berjajar sepanjang jalur sebagai penanda progres swipe.
* **Petunjuk tangan:** ikon tangan menyapu pada orb pertama, hanya muncul di swipe awal (satu-satunya "instruksi" pada layar).
* **Asal kemunculan:** orb muncul dari tengah atau sisi kiri layar secara bergantian.

**Umpan balik & animasi:**
* **Haptic:** getaran ringan tiap swipe berhasil; getaran lebih kuat saat berpindah fase dan saat 100%.
* **Partikel:** hati kecil melayang naik dan memudar (durasi ±800ms) pada titik sentuh.
* **Animasi sprite:** *squish/bounce* (skala Y 0.96 ↔ 1.04, ±200ms) pada tiap swipe; *wiggle* halus (rotasi ±2°) saat disentuh; *idle breathing* (skala 1.0 ↔ 1.02, siklus ±3 dtk) saat tidak ada interaksi.
* **Transisi fase:** pada 50%, sprite *cross-fade* ke pose berikutnya (±400ms) dan latar berganti halus; indikator fase berpindah titik.
* **Tanpa kondisi gagal:** tidak ada layar kalah atau pengurangan progres.

### 5.4 Layar Selebrasi (Journey Reward)
* **Latar:** `celebration-bg` dengan sinar radial pastel, bintang, hati, kilau, dan semanggi dekoratif; konfeti/hati jatuh pelan.
* **Susunan (atas → bawah):**
  1. **Pita judul** kapsul oranye gradasi bertepi gelap berisi bintang + teks kapital tebal (mis. "IKATAN TERJALIN!").
  2. **Judul besar** (Celebration Title), mis. "Kucing Kampus Resmi Jadi Sahabatmu!", disusul subjudul 14px.
  3. **Sprite kucing bahagia** melompat (`cat_<variasi>_happy.png`) di tengah, dengan sorot lembut dan hati di sekitarnya; animasi lompat naik-turun berulang.
  4. **Lencana pertemuan:** kapsul putih bertepi halus berikon tapak dan teks **"Pertemuan X / 5"** disertai titik status hijau.
  5. **Tombol aksi bawah:** Primary **"✏️ Beri Nama"** (hanya jika `encounterCount >= 5` dan `isNameLocked == false`) dan tautan teks sekunder **"Selesai"**. Bila belum memenuhi syarat, hanya "Selesai" yang tampil sebagai tombol utama.
* **Varian pertemuan 1–4:** judul dan subjudul menyesuaikan (mis. "Kamu Berhasil Menjinakkannya!"), lencana menunjukkan X < 5, tanpa tombol "Beri Nama".
* **Tanpa poin:** tidak ada pill poin, hadiah, atau ringkasan data.

### 5.5 Dialog "Beri Nama"
* Modal putih radius 24px; judul "Beri Nama Kucing Ini"; kolom input bernama (radius 14px, tinggi 54px, penghitung karakter 2–20); teks bantu kecil: "Nama tidak dapat diubah setelah disimpan."
* **Tombol:** Primary "Simpan Nama" dan Secondary "Batal".
* **Keadaan galat:** teks merah `#DC2626` di bawah kolom (mis. "Nama ini sudah dipakai kucing lain").
* **Sukses:** nama tampil di kartu profil dengan ikon gembok kecil; lencana "Pertemuan X / 5" digantikan penanda **"Nama terkunci"**.

---

## 6. Komponen Cat-Dex & Peta (Disesuaikan V2)
* **Segmented Tab:** Kafe Kucing / Katalog Cat-Dex (tab aktif oranye, tidak aktif transparan di atas kapsul `#F4F4F5`).
* **Tab Kafe Kucing (`CafeSanctuaryView` & `CafeRoomStage`):**
  * **Header Ruangan:** indikator status jumlah kucing aktif + *pill* pemilih tema ruangan (*Kafe Hangat*, *Taman Pastel*, *Kafe Malam*).
  * **Kanvas Isometrik (4:3):** sprite kucing transparan berdiri/berjalan langsung di lantai tanpa bingkai lingkaran besar, dengan *pill* nama kecil di atas kepala, tombol **Full Screen** (`Icons.fullscreen`) di kanan atas panggung, dan transisi tema via `AnimatedSwitcher`.
  * **Keadaan Drag & Interaksi:** saat diangkat, sprite membesar `1.15x` dengan bayangan bawah lembut, goyangan halus, dan pose `_happy`; menjatuhkan ke *Cat Tree* / bantal / kardus memunculkan gelembung `Zzz... 💤`, ke mangkuk makanan memunculkan `🐟`, dan kucing berdekatan menampilkan gelembung simbol (`❤️`, `🐾`, `❓`, `🎵`).
  * **Mode Full Screen (`_CafeFullScreenPage`):** menyembunyikan seluruh navigasi induk; menyediakan **InteractiveViewer** (`1.0x`–`2.5x`, *pan* nonaktif saat drag kucing atau mode laser), tombol **Keluar** (`Icons.fullscreen_exit`) di kiri atas, **Ganti Tema** (`Icons.palette_outlined`), **Photo Mode** (`Icons.camera_alt_rounded` dengan HUD tersembunyi 1,5 dtk + kilatan putih + `SnackBar` `'📸 Foto Kafe Tersimpan!'`), serta bar mainan bawah (**Snack Ikan** & **Laser Pointer**).
* **Kartu Katalog:** terkoleksi → avatar berwarna, nama (sementara/permanen), indikator pertemuan; belum ditemukan → siluet gelap `???` dengan petunjuk lokasi.
* **Kartu Profil (Catbook Polaroid):** latar `#FFFDF5` (`#302B29` di Mode Gelap); foto polaroid di kiri atas; kanan atas: kepribadian, **jumlah pertemuan**, **tanggal pertemuan terakhir**, serta catatan kondisi dari pengelola (*read-only*); bawah: kotak gelembung kutipan lucu kucing (`quote`) tanpa label judul tambahan; progres "Pertemuan X / 5" atau ikon gembok jika nama terkunci; tombol "Kunjungi di Kafe Kucing".
* **Peta Teritorial:** kartu berbingkai membulat (radius 20px) berisi `campus_map.png` 1:1 di dalam `InteractiveViewer`; 4 pin zona (TULT & Asrama, GKU, Cacuk, Fakultas Depan) dengan gelembung celoteh melayang; kucing mini patroli; awan semi-transparan; filter suasana Pagi (tanpa filter), Senja (`deepOrange` opasitas 0,16), Malam (`#1A237E` opasitas 0,28 + titik lampu hangat); pill tombol suasana di kanan atas; 3 hotspot *easter egg*; daftar zona dan layar detail zona dengan pintasan "Pindai QR".
* **Profil Pengguna:** avatar lingkaran wajah kucing (`_head.png`) dengan badge edit pembuka *bottom sheet* pemilih avatar, **gelar dinamis** + pill **Best Buddy**, statistik **kucing terkoleksi** dan **total pertemuan** (tanpa poin), **grid medali visual 3 kolom** (berwarna cerah saat terbuka, *greyscale*/redup saat terkunci, dengan dialog detail saat diketuk), serta ikon `Icons.info_outline` di kanan atas header untuk dialog info Capstone.

---

## 7. Spesifikasi Aset Grafis 2D

| Berkas (`assets/images/`) | Variasi / Tema | Pose / Fungsi | Dipakai di |
| :--- | :--- | :--- | :--- |
| `cat_oren_head.png` / `cat_putih_head.png` / `cat_hitam_head.png` | oren / putih / hitam | Kepala siap diusap | Mini-game & pose diam kafe |
| `cat_oren_belly.png` / `cat_putih_belly.png` / `cat_hitam_belly.png` | oren / putih / hitam | Telentang, perut terlihat | Mini-game & pose tidur kafe |
| `cat_oren_happy.png` / `cat_putih_happy.png` / `cat_hitam_happy.png` | oren / putih / hitam | Melompat bahagia | Selebrasi, drag, & reaksi kafe |
| `cat_oren_sad.png` / `cat_putih_sad.png` / `cat_hitam_sad.png` | oren / putih / hitam | Sedih | Pop-up batas scan harian |
| `cat_oren_walk1/2.png` / `cat_putih_walk1/2.png` / `cat_hitam_walk1/2.png` | oren / putih / hitam | 2 frame langkah jalan | Animasi loop jalan di Kafe Kucing |
| `cafe_bg_cozy.png` / `cafe_bg_pastel.png` / `cafe_bg_night.png` | Hangat / Pastel / Malam | Latar ruangan isometrik 4:3 | 3 tema Kafe Kucing |

* **Total 18 aset PNG sprite kucing** (12 pose + 6 walk cycle, **latar transparan / alpha**) dan **3 latar tema kafe** (plus `cafe_background.png` awal), didaftarkan pada `pubspec.yaml` & `app_assets.dart`.
* Pemetaan variasi → kucing dilakukan lewat atribut `variant` pada `CatModel`.
* Rekomendasi optimasi: ekspor ulang ke resolusi ±1024px dan kompres (target ≤ 300 KB per aset); acuan Stitch awal masih berlatar putih persegi sehingga aset produksi harus dipastikan transparan.
* Aset lama `cat_mochi.png` dan `cat_photo_oyen.png` masih tersimpan di direktori untuk cadangan; katalog dan repository V2 sudah memetakan seluruh avatar ke aset pose V2 (`_head`, `_happy`, `_walk1/2`).

---

## 8. Prinsip Interaksi & Gerak (Motion)
* **Durasi baku:** splash 1500ms; transisi pose 400ms; squish 200ms; partikel hati 800ms; idle breathing siklus ±3000ms; frame jalan kafe ~220ms; transisi tema kafe `AnimatedSwitcher`; HUD Photo Mode sembunyi 1500ms.
* **Kurva:** `ease-out-back` untuk muncul (pop), `ease-in-out` untuk napas/idle dan perpindahan waypoint halus.
* **Haptic:** `lightImpact` per swipe berhasil & lepas drag kucing; `mediumImpact` saat pergantian fase & Photo Mode; `heavyImpact` saat 100%; `selectionClick` saat mulai mengangkat kucing.
* **Pengurangan gerak:** bila pengguna mengaktifkan *reduce motion* sistem, nonaktifkan rotasi sunburst, konfeti, dan partikel; pertahankan transisi esensial.

---

## 9. Lingkungan SDK & Konfigurasi Build
* **Flutter SDK Terisolasi:** Proyek diikat ke **Flutter 3.19.6 (Dart 3.3.4)** pada `C:\src\flutter_3.19.6` melalui `.vscode/settings.json` (`"dart.flutterSdkPath": "C:/src/flutter_3.19.6"`) tanpa mengubah `PATH` sistem.
* **Kompatibilitas Android:** Menggunakan konfigurasi Groovy (`settings.gradle`, `build.gradle`, `app/build.gradle`) dengan **Gradle 7.6.3**, **AGP 7.3.0**, dan **Kotlin 1.8.22**.
