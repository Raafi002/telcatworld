# PRODUCT REQUIREMENT DOCUMENT (PRD)
## Modul: TelCat World (Gamified Cat Bonding & Cat-Dex) — Versi 2

* **Ekosistem Induk:** Super App Kucing Kampus (Telkom University)
* **Tim Pengembang:** Kelompok SUPER-SUB (S1 Sistem Informasi)
* **Arsitektur Klien:** Mobile Application (Flutter 3.19.6 / Dart 3.3.4 — SDK terisolasi di `C:\src\flutter_3.19.6`)
* **Arsitektur Backend:** Laravel 11 (PHP 8.2+) RESTful API & Supabase (PostgreSQL + PostGIS)
* **Metodologi:** Game Development Life Cycle (GDLC)
* **Referensi Visual:** `stitch_export/stitch_telcat_world_mobile_app_v2/` (4 layar: transisi, sesi elus pose kepala, sesi elus pose perut, selebrasi)

---

## 0. Riwayat Perubahan (Changelog Konsep V2)

| Aspek | Konsep Lama (V1) | Konsep Baru (V2) |
| :--- | :--- | :--- |
| Setelah scan QR | Kuis observasi 3 pertanyaan | Cek batas scan harian, lalu transisi "Jinakkan Kucing!" |
| Mekanik utama | Sesi pendekatan 3 giliran + *Horizontal Timing Bar* | Mini-game mengelus 2 fase dengan swipe lingkaran berkilau |
| Sistem poin | Poin Ekspedisi (+35/+50) | **Dihapus** dari modul game (menghindari tumpang tindih dengan modul feeding spot/adopsi) |
| Layar hasil | Pop-up hasil + ringkasan observasi | Layar selebrasi penuh + lencana "Pertemuan X / 5" |
| Penamaan kucing | Nama tetap dari data awal | Nama sementara (placeholder); nama permanen dapat diberikan setelah 5x pertemuan |
| Pembatasan | Tidak ada | Maksimal 1x scan per kucing per hari (*daily cooldown*) |

**Fitur yang dihapus dari spesifikasi:** modul `quiz_observation` (kuis observasi 3 pertanyaan), `approach_session` versi giliran/Trust Bar, komponen *Horizontal Timing Bar*, serta seluruh sistem poin pada modul game.

---

## 1. Tujuan & Ringkasan Modul
**TelCat World** adalah sub-modul permainan interaktif berbasis lokasi (*location-based game*) di dalam Super App Kucing Kampus. Modul ini mendorong mahasiswa dan civitas akademika untuk membangun kedekatan dengan kucing kampus melalui pemindaian kalung QR dan mini-game mengelus yang lembut, tanpa kontak paksa terhadap satwa sungguhan. Setiap pertemuan dicatat sehingga terbentuk katalog kucing kampus terpusat (*Cat-Dex*) dan hubungan jangka panjang antara pengguna dan kucing (*journey*), yang puncaknya adalah hak memberi nama permanen pada kucing.

Modul ini **tidak** mengelola poin atau hadiah ekonomi; fungsi tersebut menjadi tanggung jawab modul lain di Super App (feeding spot/adopsi).

---

## 2. Alur Pengguna Utama (Core User Flow)

```
Scan QR + Validasi GPS
        │
        ▼
Cek batas scan harian (kucing yang sama, hari ini?)
   ├── SUDAH ──► Pop-up kucing sedih ──► "Lihat Profil Kucing" ──► Cat-Dex + kartu profil terbuka
   └── BELUM ──► Layar transisi "Jinakkan Kucing!" (1,5 detik)
                        │
                        ▼
              Mini-game Mengelus (Fase 1: 0–50%, Fase 2: 50–100%)
                        │
                        ▼
              Layar Selebrasi (Pertemuan X / 5)
                   ├── Pertemuan ke-5 & nama belum terkunci ──► "Beri Nama"
                   └── Selain itu ──► "Selesai"
                        │
                        ▼
              Cat-Dex (Kafe Kucing / Katalog) & Peta Teritorial
```

1. **Layar 1 — Pindai QR & Validasi Lokasi.** Pengguna memindai QR kalung kucing; sistem memvalidasi hash QR dan koordinat GPS (geofencing area kampus).
2. **Gerbang Batas Harian.** Sistem memeriksa apakah kucing tersebut sudah dipindai oleh pengguna yang sama hari ini.
3. **Layar 2 — Transisi "Jinakkan Kucing!"** (hanya jika belum dipindai hari ini).
4. **Layar 3 — Mini-Game Mengelus** (2 fase acak).
5. **Layar 4 — Selebrasi, Pencatatan Pertemuan, & (opsional) Beri Nama.**
6. **Layar 5 — Cat-Dex** (Kafe Kucing & Katalog) dan **Peta Teritorial**.

---

## 3. Spesifikasi Fungsional per Layar (Functional Requirements)

### 3.1 Layar 1: Pindai QR Kalung (QR Scanner)
* **FR-SCAN-01:** Menampilkan *Top App Bar* konsisten dengan identitas Super App ("Kucing Kampus — TelCat World") dan badge status GPS ("Di Area Kampus" / "Luar Area").
* **FR-SCAN-02:** Menampilkan kotak *viewfinder* kamera dengan bingkai sudut oranye, tombol lampu kilat (*flash*), dan indikator status pembacaan QR.
* **FR-SCAN-03:** Menampilkan kartu peringatan etika satwa (*Animal Welfare Info Box*): *"Amati dari jarak aman. Jangan mengejar, memegang paksa, atau menyalakan flash tepat di mata kucing."*
* **FR-SCAN-04:** Mengirim payload `{ qr_hash, latitude, longitude, is_mocked }` ke endpoint verifikasi; respons memuat data kucing, status `already_scanned_today`, dan `encounter_count` pengguna terhadap kucing tersebut.
* **FR-SCAN-05:** Bila lokasi tidak valid atau QR tidak dikenal, tampilkan pesan galat yang ramah tanpa memulai sesi.

### 3.2 Batas Scan Harian (Daily Cooldown)
* **FR-CD-01:** Pengguna dapat memindai QR kucing yang sama berulang kali pada hari-hari berbeda, **maksimal 1x per hari per kucing**.
* **FR-CD-02:** Batas dihitung per pasangan (`user_id`, `cat_id`) berdasarkan tanggal kalender zona waktu WIB (UTC+7) dari `lastScannedDate`. Pergantian hari mengikuti pukul 00:00 WIB.
* **FR-CD-03 (Kucing SUDAH di-scan hari ini):** Tampilkan pop-up berisi:
  * ilustrasi 2D kucing sedih (aset `_sad.png` sesuai variasi kucing);
  * pesan: **"Kamu sudah menyapa kucing ini hari ini, coba lagi besok!"**;
  * tombol **"Lihat Profil Kucing"** yang langsung menavigasi ke tab Cat-Dex dan membuka kartu profil (*Catbook*) kucing tersebut.
* **FR-CD-04 (Kucing BELUM di-scan hari ini):** Lanjut ke layar transisi (3.3).
* **FR-CD-05:** Pencobaan scan yang ditolak karena batas harian **tidak** menambah `encounterCount` dan **tidak** mengubah `lastScannedDate`.

### 3.3 Layar 2: Transisi "Jinakkan Kucing!" (Game Splash)
* **FR-SPL-01:** Layar penuh (*full-screen*) berlatar gradasi oranye dengan motif sinar (*sunburst*), ikon tapak kucing, dan bintang dekoratif.
* **FR-SPL-02:** Hanya menampilkan teks **"Jinakkan Kucing!"**; **tanpa** tombol dan tanpa teks lain.
* **FR-SPL-03:** Tampil selama **1,5 detik**, kemudian otomatis berpindah ke layar mini-game mengelus (tanpa interaksi pengguna).

### 3.4 Layar 3: Mini-Game Mengelus (Petting Session)

#### 3.4.1 Struktur Dua Fase Acak
* **FR-PET-01:** Progres sesi berjalan dari 0% hingga 100% dan dibagi menjadi dua fase:
  * **Fase 1 (0%–50%)**: pose pertama dipilih **secara acak** oleh sistem dari dua kemungkinan: **pose kepala siap diusap** (`_head`) atau **pose tiduran telentang memperlihatkan perut** (`_belly`).
  * **Fase 2 (50%–100%)**: sistem otomatis berganti ke **pose lainnya** (yang tidak dipakai pada Fase 1).
* **FR-PET-02:** Transisi antarpose menggunakan animasi halus (*cross-fade*/*squish*) tanpa menghentikan sesi.
* **FR-PET-03:** Sesi selesai ketika progres mencapai 100% dan langsung berpindah ke layar selebrasi (3.5).
* **FR-PET-04:** Tidak ada kondisi gagal/kalah; pemain tidak dapat kehilangan progres. Sesi dapat dijeda (tombol jeda) atau ditinggalkan (tombol kembali); meninggalkan sesi sebelum 100% **tidak** dihitung sebagai pertemuan dan **tidak** memakai jatah scan harian.

#### 3.4.2 Mekanik Interaksi (Swipe Lingkaran Berkilau)
* **FR-PET-05:** Interaksi utama berupa **swipe** mengikuti lingkaran/jalur berkilau ala *Charged Attack* Pokémon GO. Target lingkaran muncul dari **tengah** atau **sisi kiri** layar dan harus disapu jari pemain sepanjang jalur putus-putus.
* **FR-PET-06:** Pada pose kepala, jalur berupa busur di sekitar kepala; pada pose perut, jalur berupa cincin melingkar di area perut (lihat acuan visual).
* **FR-PET-07:** Setiap swipe yang berhasil menambah progres dalam fase berjalan (nilai penambahan ditentukan saat implementasi, mis. 10–15% per swipe) dan memunculkan target berikutnya.
* **FR-PET-08:** Umpan balik pada setiap swipe berhasil: **getaran (haptic feedback)**, **partikel hati melayang**, serta animasi 2D ringan pada sprite kucing: *squish/bounce*, *wiggle* halus, dan animasi *idle* bernapas saat tidak disentuh.

#### 3.4.3 Antarmuka Sesi
* **FR-PET-09:** *Header* memuat tombol kembali, lencana nama kucing (nama sementara atau nama permanen), dan indikator progres berupa ikon hati dengan bar serta persentase (mis. 35%).
* **FR-PET-10:** Pose perut dapat menampilkan label mood singkat (mis. "MANJA") di samping bar progres.
* **FR-PET-11:** *Footer* memuat kontrol minimal: tombol suara (*mute/unmute*), indikator fase (titik-titik dengan ikon tapak), dan tombol jeda.
* **FR-PET-12:** Gaya visual bersih dan hangat (referensi *Neko Atsume*): latar gradasi pastel lembut, partikel hati/bintang tipis, bayangan lembut di bawah sprite. **Teks instruksi dibuat seminimal mungkin** (tanpa paragraf tutorial; petunjuk cukup berupa ikon tangan pada target pertama).

### 3.5 Layar 4: Selebrasi & Pencatatan Pertemuan (Journey Reward)
* **FR-CEL-01:** Menggantikan pop-up hasil lama dengan **layar selebrasi penuh**: latar pastel dengan sinar, konfeti/hati/bintang, dan sprite kucing melompat bahagia (aset `_happy.png`).
* **FR-CEL-02:** Menampilkan lencana **"Pertemuan X / 5"** (X = `encounterCount` setelah pertemuan ini dihitung; nilai maksimum tampilan 5).
* **FR-CEL-03:** Pada pertemuan ke-5 (dan seterusnya selama nama belum terkunci) tampilkan judul perayaan (mis. "Kucing Kampus Resmi Jadi Sahabatmu!") dan tombol utama **"Beri Nama"**, serta tombol sekunder **"Selesai"**. Pada pertemuan ke-1 s.d. ke-4 hanya tombol **"Selesai"** yang tampil.
* **FR-CEL-04:** Setelah pertemuan dicatat: `encounterCount` bertambah 1, `lastScannedDate` diperbarui ke waktu scan, dan data disinkronkan ke basis data katalog terpusat.
* **FR-CEL-05:** Tombol "Selesai" mengarahkan pengguna kembali ke beranda/Cat-Dex.
* **FR-CEL-06:** Layar selebrasi **tidak** menampilkan poin, hadiah ekonomi, maupun ringkasan observasi kesehatan.

### 3.6 Fitur Penamaan Kucing (Beri Nama)
* **FR-NAME-01:** Kucing yang baru terdaftar di katalog menggunakan **nama sementara (placeholder)**, mis. "Kucing Oren #12".
* **FR-NAME-02:** Hak memberi nama permanen diberikan kepada pengguna yang telah menemui kucing yang sama **sebanyak 5 kali** (`encounterCount >= 5`) **dan** `isNameLocked == false`.
* **FR-NAME-03:** Tombol "Beri Nama" membuka dialog input nama (validasi: panjang 2–20 karakter, tanpa konten tidak pantas, dengan konfirmasi akhir bahwa nama tidak dapat diubah).
* **FR-NAME-04:** Nama permanen bersifat **unik secara global** dan **terkunci (locked)** di basis data: tidak dapat dipakai kucing lain dan tidak dapat diubah lagi setelah disimpan (`isNameLocked = true`).
* **FR-NAME-05:** Jika nama sudah dipakai kucing lain, server menolak dengan galat `name_already_taken` dan dialog menampilkan pesan agar pengguna memilih nama lain.
* **FR-NAME-06:** Penanganan *race condition*: bila dua pengguna mengajukan nama yang sama bersamaan, hanya permintaan pertama yang berhasil (dijamin oleh *unique constraint* basis data). Bila nama kucing sudah terkunci oleh pengguna lain, tombol "Beri Nama" tidak ditampilkan.
* **FR-NAME-07:** Pengguna yang melewati dialog dapat kembali memberi nama pada pertemuan berikutnya selama nama belum terkunci.

### 3.7 Layar 5: Modul Cat-Dex (Koleksi & Sanctuary)
* **FR-DEX-01:** *Segmented tab switcher* di bagian atas: **☕ Kafe Kucing** dan **📋 Katalog Cat-Dex**.
* **FR-DEX-02 (Tab Kafe Kucing, gaya Neko Atsume):** Kanvas diorama isometrik 2D yang menampilkan hingga 5 kucing aktif yang sudah pernah ditemui, dengan kapabilitas interaktif berikut:
  * **Animasi Jalan Loop Independen:** Kucing bergerak bebas antar 10 titik waypoint lantai isometrik (`_walk1`/`_walk2` dengan auto-flip kiri/kanan) dan berhenti dengan variasi pose diam (`_head`/`_belly`), disertai badge nama kecil di atas kepala. Menyentuh kucing memunculkan reaksi hati ❤️ dan kutipan dialog pada kartu bawah.
  * **Drag-and-Drop & Interaksi Perabotan:** Pengguna dapat mengangkat (`1.15x` + bayangan + `_happy`) dan memindahkan kucing ke area lantai yang valid (bila dilepas di area terlarang akan bergeser ke waypoint terdekat). Menjatuhkan kucing ke zona **Cat Tree / Bantal / Kardus** memicu pose tidur (`_belly`/`_head`) dengan gelembung `Zzz... 💤`, sedangkan di **Mangkuk Makanan** memicu ekspresi bahagia dengan gelembung `🐟`.
  * **Obrolan Simbol Antarkucing:** Ketika dua kucing yang sedang diam berdekatan, keduanya saling menghadap dan menampilkan gelembung simbol singkat (`❤️`, `🐾`, `❓`, atau `🎵`).
  * **Mode Full Screen & 3 Tema Ruangan:** Tombol ikon Full Screen memperluas panggung kafe secara penuh (menyembunyikan header, tab bar, kartu kutipan, FAB, dan bottom bar), dilengkapi tombol **Keluar Full Screen**, **Ganti Tema Ruangan** (*Kafe Hangat*, *Taman Pastel*, *Kafe Malam*) dengan transisi halus, **Pinch-to-Zoom** (`1.0x`–`2.5x`), **Photo Mode** (menyembunyikan HUD sementara, kilatan putih, getaran haptic, dan notifikasi `'📸 Foto Kafe Tersimpan!'`), serta bar mainan bawah (**Snack Ikan** & **Laser Pointer**).
* **FR-DEX-03 (Tab Katalog):** *Filter chip* (Semua, Terkoleksi, Belum Ditemukan) dan grid 2 kolom. Kucing terkoleksi tampil berwarna dengan nama (sementara/permanen); kucing belum ditemukan tampil sebagai siluet gelap dengan label `???` dan petunjuk lokasi.
* **FR-DEX-04 (Kartu Profil / Catbook Polaroid):** Muncul saat kartu kucing ditekan (atau dibuka langsung dari tombol "Lihat Profil Kucing", FR-CD-03). Memuat foto polaroid, nama, kepribadian, **jumlah pertemuan (`encounterCount`)**, tanggal pertemuan terakhir (`lastScannedDate`), kotak gelembung kutipan lucu kucing (`quote`), catatan kondisi dari pengelola kampus (*read-only*), dan tombol "Kunjungi di Kafe Kucing". Indikator "Pertemuan X / 5" ditampilkan hingga nama terkunci; setelah terkunci, tampil ikon gembok di samping nama permanen.
* **FR-DEX-05:** Status/kondisi fisik kucing pada kartu profil bersumber dari data **pengelola kampus**, bukan dari masukan pengguna melalui kuis (fitur kuis dihapus).

### 3.8 Modul Peta Teritorial (Territory Map)
* **FR-MAP-01:** Peta isometrik `campus_map.png` (rasio 1:1, dapat dicubit/zoom) dalam kartu berbingkai membulat dengan tepat **4 pin zona**: **TULT & Asrama**, **GKU**, **Cacuk**, dan **Fakultas Depan**; seluruh kucing terdistribusi ke 4 zona tersebut.
* **FR-MAP-02:** Daftar zona beserta jumlah kucing penghuni; kucing mini berpatroli di jalan kampus (2–3 sprite `_walk1/_walk2`), gelembung celoteh (`Meow!`, `🐟`, `💤`) muncul di atas zona yang masih memiliki kucing belum disapa hari ini, serta awan melayang dekoratif.
* **FR-MAP-03:** Layar detail zona berisi daftar kucing penghuni dan tombol pintas "Pindai QR".
* **FR-MAP-04 (Suasana Waktu):** Pencahayaan peta otomatis sesuai jam perangkat (Pagi/Siang 06:00–15:59, Senja 16:00–18:29, Malam 18:30–05:59 dengan lampu kampus berpendar) dan dapat diganti manual lewat tombol (`🕒 Otomatis`, `☀️ Pagi`, `🌅 Senja`, `🌙 Malam`).
* **FR-MAP-05 (Easter Egg):** 3 hotspot tersembunyi (Danau Situ Techno, Taman Tugu & Lapangan Atas, Taman Bangku Kampus) yang memicu getaran haptic, riak, dan gelembung kucing mengintip selama 2,5 detik.

### 3.9 Shell Navigasi Utama
* **FR-NAV-01:** *Bottom Navigation Bar* tetap dengan tepat 3 menu: **Cat-Dex**, **Peta**, **Profil**.
* **FR-NAV-04 (Mode Gelap):** Aplikasi menyediakan **Mode Gelap** bernuansa *Cozy Warm Espresso* (latar `#1C1917`, kartu `#292524`, aksen `#FB923C`) yang dapat diubah lewat ikon di header dan switch di tab Profil (state in-memory). Saat aktif, Kafe Kucing beralih ke tema *Kafe Malam* dan peta ke suasana Malam.
* **FR-NAV-02:** *Floating Action Button* kapsul oranye "Pindai QR" berikon kamera, melayang minimal 24px di atas *bottom bar* tanpa menutupi ikon menu; menekannya langsung membuka Layar 1.
* **FR-NAV-03:** Tab Profil menampilkan **avatar kucing interaktif** (`_head.png` dari kucing yang sudah ditemui), **gelar dinamis** berdasarkan total pertemuan (*Pendatang Baru*, *Sahabat Kucing Kampus*, *Pawang Kucing Tel-U*), pill **Best Buddy**, statistik **jumlah kucing terkoleksi** serta **total pertemuan** (tanpa poin), **grid medali pencapaian 3 kolom**, dan ikon info (`ℹ️`) di header untuk dialog informasi proyek Capstone.

---

## 4. Model Data & Aturan Bisnis

### 4.1 Entitas Kucing (`CatModel`) — atribut yang relevan
| Atribut | Tipe | Keterangan |
| :--- | :--- | :--- |
| `id` | string/uuid | Pengenal kucing |
| `qrHash` | string | Hash QR kalung |
| `name` | string | Nama sementara atau nama permanen |
| `isNameLocked` | bool | `true` jika nama permanen telah dikunci |
| `variant` | enum | `oren` \| `putih` \| `hitam` (menentukan set aset 2D) |
| `zone` | string | Zona kampus utama |
| `encounterCount` | int | Jumlah pertemuan pengguna dengan kucing ini |
| `lastScannedDate` | datetime | Waktu scan terakhir yang sukses (basis cooldown harian) |
| `isCollected` | bool | `true` jika `encounterCount >= 1` |

### 4.2 Aturan Bisnis Utama
1. **Cooldown harian:** satu pertemuan sah per (`user`, `cat`) per hari kalender WIB.
2. **Pertemuan sah:** hanya dihitung bila mini-game mencapai 100%.
3. **Ambang nama:** `encounterCount >= 5` **dan** `isNameLocked == false`.
4. **Keunikan nama:** *case-insensitive*, global, tersimpan dengan *unique index* pada kolom nama ternormalisasi.
5. **Kolektibilitas:** kucing tampil di Cat-Dex sebagai terkoleksi sejak pertemuan pertama.
6. **Tanpa poin:** modul ini tidak membuat transaksi poin apa pun.

---

## 5. Spesifikasi Aset 2D

Digunakan **12 aset pose utama + 6 aset walk cycle PNG transparan** untuk **3 variasi kucing** serta **3 latar tema ruangan kafe**, disimpan di `assets/images/` dan didaftarkan pada `pubspec.yaml`.

| Variasi | Pose Kepala (`_head`) | Pose Perut (`_belly`) | Pose Bahagia (`_happy`) | Pose Sedih (`_sad`) | Walk Cycle (`_walk1`, `_walk2`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Oren | `cat_oren_head.png` | `cat_oren_belly.png` | `cat_oren_happy.png` | `cat_oren_sad.png` | `cat_oren_walk1/2.png` |
| Putih | `cat_putih_head.png` | `cat_putih_belly.png` | `cat_putih_happy.png` | `cat_putih_sad.png` | `cat_putih_walk1/2.png` |
| Hitam | `cat_hitam_head.png` | `cat_hitam_belly.png` | `cat_hitam_happy.png` | `cat_hitam_sad.png` | `cat_hitam_walk1/2.png` |

**Latar Ruangan Kafe (3 Tema):**
* `cafe_bg_cozy.png` (*Kafe Hangat* — default), `cafe_bg_pastel.png` (*Taman Pastel*), dan `cafe_bg_night.png` (*Kafe Malam*), dengan geometri isometrik seragam (rasio 4:3).

**Penggunaan pose:**
* `_head` & `_belly` → dua fase mini-game mengelus (urutan diacak) serta variasi pose diam/tidur di Kafe Kucing.
* `_happy` → layar selebrasi, saat kucing diangkat (*drag*), serta reaksi sentuh/makan di Kafe Kucing.
* `_sad` → pop-up batas scan harian.
* `_walk1` & `_walk2` → animasi berjalan bolak-balik di kanvas Kafe Kucing.

> **Catatan teknis:** acuan visual Stitch masih menampilkan sprite dengan latar putih persegi; aset produksi harus berlatar **transparan** (PNG alpha). Ukuran berkas saat ini ±0,6–0,8 MB per aset dan perlu dioptimalkan (kompresi/penyesuaian resolusi) sebelum rilis.

---

## 6. Kontrak Endpoint RESTful API (Laravel 11 / Supabase)
* `POST /api/v1/telcat/scan-verify`: Validasi token QR kalung & geofencing PostGIS; respons mencakup `cat`, `already_scanned_today` (bool), `encounter_count`, `is_name_locked`.
* `POST /api/v1/telcat/submit-encounter`: Dipanggil setelah mini-game mencapai 100%. Menolak (`409 already_scanned_today`) bila cooldown harian masih berlaku; bila sah, menaikkan `encounter_count`, memperbarui `last_scanned_at`, dan menyimpan koleksi ke tabel `user_cat_collections`. **Tidak ada pencatatan poin.**
* `POST /api/v1/telcat/cats/{id}/name`: Memberi nama permanen. Syarat: `encounter_count >= 5` dan `is_name_locked = false`. Respons galat: `403 not_eligible`, `409 name_already_taken`, `409 name_locked`. Sukses mengunci nama (`is_name_locked = true`).
* `GET /api/v1/telcat/cat-dex`: Mengambil daftar seluruh kucing kampus beserta status kepemilikan koleksi, `encounter_count`, `last_scanned_at`, dan status nama untuk pengguna yang sedang login.

**Catatan basis data:** tabel `cats` memiliki kolom `name`, `name_normalized` (*unique*), `is_name_locked`; tabel `user_cat_collections` memiliki `user_id`, `cat_id`, `encounter_count`, `last_scanned_at` dengan *unique constraint* (`user_id`, `cat_id`).

---

## 7. Kebutuhan Non-Fungsional
* **Etika satwa:** tidak ada mekanik kekerasan, pengejaran, atau kontak paksa; kartu etika satwa wajib tampil pada layar pemindai.
* **Kinerja:** animasi 2D dan partikel berjalan ≥ 60 fps pada perangkat menengah; transisi splash tepat 1,5 detik.
* **Aksesibilitas:** umpan balik haptic dan suara dapat dimatikan; tombol suara tersedia di layar mini-game.
* **Bahasa antarmuka:** Bahasa Indonesia yang ramah dan komunikatif.
* **Sinkronisasi:** pencatatan pertemuan idempoten; bila koneksi terputus, hasil sesi ditahan secara lokal dan dikirim ulang, tetapi tidak boleh melanggar batas scan harian di server.
