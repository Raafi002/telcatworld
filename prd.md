# PRODUCT REQUIREMENT DOCUMENT (PRD)
## Modul: TelCat World (Gamified Citizen Science & Cat-Dex)
* **Ekosistem Induk:** Super App Kucing Kampus (Telkom University)
* **Tim Pengembang:** Kelompok SUPER-SUB (S1 Sistem Informasi)
* **Arsitektur Klien:** Mobile Application (Flutter / WebView Hybrid)
* **Arsitektur Backend:** Laravel 11 (PHP 8.2+) RESTful API & Supabase (PostgreSQL + PostGIS)
* **Metodologi:** Game Development Life Cycle (GDLC)

---

## 1. Tujuan & Ringkasan Modul
**TelCat World** adalah sub-modul permainan interaktif berbasis lokasi (*location-based game*) dan sains warga (*citizen science*) di dalam Super App Kucing Kampus. Modul ini memfasilitasi mahasiswa dan civitas akademika untuk memantau kondisi kesehatan kucing kampus melalui mekanisme pemindaian kalung QR, kuis observasi fisik singkat, sesi pendekatan berbasis giliran (*Elus, Beri Ruang, Luluhkan* dengan *Horizontal Timing Bar*), serta pengumpulan kartu koleksi digital (*Cat-Dex*).

---

## 2. Alur Pengguna Utama (Core User Flow — 5 Layar Inti)
1. **Layar 1 (Pindai QR Kalung & Validasi Lokasi):** Pengguna menemukan kucing berkalung di area kampus, membaca *callout* etika satwa, dan memindai QR Code pada kalung. Sistem memvalidasi hash QR dan koordinat GPS pengguna (geofencing area kampus).
2. **Layar 2 (Kuis Observasi Fisik & Kondisi Terkini):** Setelah QR valid, pengguna wajib menjawab 3 pertanyaan observasi cepat mengenai ciri fisik dan kondisi terkini kucing (kebersihan mata/bulu, indikasi luka, dan tingkat keaktifan).
3. **Layar 3 (Arena Sesi Pendekatan & Horizontal Timing Bar):** Pengguna berinteraksi dengan avatar 2D kucing menggunakan 3 tombol aksi (*Elus*, *Beri Ruang*, *Luluhkan*). Saat *Trust Bar* cukup dan pengguna menekan *Luluhkan*, muncul *Horizontal Timing Bar* di mana pengguna harus mengetuk tepat saat indikator berada di zona hijau (*Sweet Spot*).
4. **Layar 4 (Hasil Pendekatan & Klaim Poin):** Menampilkan status keberhasilan meluluhkan kucing, perolehan poin ekspedisi, status *review* data observasi, dan pratinjau kartu kucing baru.
5. **Layar 5 (Galeri Koleksi / Cat-Dex):** Menampilkan katalog seluruh kucing kampus dalam format *grid* (kucing yang sudah dikoleksi tampil berwarna penuh, sedangkan yang belum ditemukan tampil sebagai siluet).

---

## 3. Spesifikasi Fungsional per Layar (Functional Requirements)

### 3.1 Layar 1: Pindai QR Kalung (QR Scanner)
* **FR-SCAN-01:** Menampilkan *Top App Bar* konsisten dengan identitas Super App ("Kucing Kampus — TelCat World") dan badge status GPS ("Di Area Kampus" / "Luar Area").
* **FR-SCAN-02:** Menampilkan kotak *viewfinder* kamera dengan bingkai sudut berwarna oranye, tombol lampu kilat (*flash*), dan indikator status pembacaan QR.
* **FR-SCAN-03:** Menampilkan kartu peringatan etika satwa (*Animal Welfare Info Box*): *"Amati dari jarak aman. Jangan mengejar, memegang paksa, atau menyalakan flash tepat di mata kucing."*
* **FR-SCAN-04:** Mengirim payload `{ qr_hash, latitude, longitude, is_mocked }` ke endpoint API Laravel/Supabase.

### 3.2 Layar 2: Kuis Observasi Fisik (Citizen Science Quiz)
* **FR-QUIZ-01:** Menampilkan *progress bar* tahapan kuis (Pertanyaan 1/3, 2/3, 3/3) dan nama/wilayah kucing yang berhasil dipindai.
* **FR-QUIZ-02:** Menyajikan 3 pertanyaan pilihan ganda berbasis kartu tombol (*selectable option cards*):
  1. *Kondisi Mata & Wajah:* Bersih & Cerah / Berair atau Belekan / Terluka.
  2. *Kondisi Tubuh & Bulu:* Sehat & Terawat / Tampak Kurus / Ada Luka atau Jamur.
  3. *Perilaku Saat Ini:* Tenang atau Bersahabat / Sedang Tidur / Waspada atau Lemas.
* **FR-QUIZ-03:** Tombol "Lanjut ke Sesi Pendekatan" hanya aktif setelah ketiga pertanyaan dijawab.

### 3.3 Layar 3: Arena Sesi Pendekatan (Turn-Based Approach & Timing Bar)
* **FR-GAME-01:** Menampilkan kartu arena tengah berisi ilustrasi Avatar 2D Kucing, badge suasana hati (*Mood Indicator*: Waspada / Nyaman / Siap Luluh), dan *Trust Bar* (0% – 100%).
* **FR-GAME-02:** Menyediakan 3 tombol aksi di bagian bawah:
  * **Elus (+25% Trust):** Menaikkan rasa percaya jika kucing sedang tenang.
  * **Beri Ruang (+15% Trust & Stabilkan Mood):** Menenangkan kucing jika statusnya waspada.
  * **Luluhkan (Aksi Penentu):** Memicu komponen **Horizontal Timing Bar**.
* **FR-GAME-03 (Horizontal Timing Bar):**
  * Berupa bar horizontal dengan 3 zona warna: Abu-abu/Merah di tepi (*Miss*), Kuning di sisi tengah (*Good*), dan Hijau di tengah (*Perfect Sweet Spot*).
  * Kursor/jarum bergerak bolak-balik secara horizontal. Pemain mengetuk tombol utama **"Ketuk Saat Hijau!"** untuk menghentikan jarum.
  * Jika berhenti di zona Hijau (*Perfect*): Kucing langsung luluh (+50 Poin). Jika Kuning (*Good*): Kucing luluh (+35 Poin). Jika Merah (*Miss*): *Trust Bar* turun 15% dan pemain mengulang giliran.

### 3.4 Layar 4: Hasil Pendekatan & Ringkasan Poin (Result Screen)
* **FR-RES-01:** Menampilkan judul keberhasilan ("Kucing Berhasil Diluluhkan!"), subjudul apresiasi, dan kartu perolehan poin (contoh: `+50 Poin Ekspedisi`).
* **FR-RES-02:** Menampilkan kartu ringkasan kiriman data observasi (Nama Kucing, Lokasi Spot Kampus, Ringkasan Kondisi Fisik yang dilaporkan).
* **FR-RES-03:** Menyediakan 2 tombol aksi bawah: Tombol utama oranye ("Buka Koleksi Cat-Dex") dan tombol sekunder putih ("Kembali ke Beranda").

### 3.5 Layar 5: Galeri Koleksi (Cat-Dex Catalog)
* **FR-DEX-01:** Menampilkan kartu ringkasan progres koleksi di bagian atas (contoh: *"12 dari 45 Kucing Kampus Terkoleksi"* beserta *filter pills*: Semua, Terkoleksi, Belum Ditemukan, Area TULT, Area GKU).
* **FR-DEX-02:** Menampilkan *grid* 2 kolom berisi kartu kucing:
  * **Status Terkoleksi:** Menampilkan ilustrasi avatar 2D penuh warna, nama kucing, lokasi gedung utama, dan badge status sehat/steril.
  * **Status Belum Ditemukan:** Menampilkan siluet kucing berwarna abu-abu gelap, label `"???"`, dan petunjuk lokasi area gedung.

---

## 4. Kontrak Endpoint RESTful API (Laravel 11 / Supabase)
* `POST /api/v1/telcat/scan-verify`: Validasi token QR kalung & geofencing PostGIS.
* `POST /api/v1/telcat/submit-encounter`: Mengirim jawaban kuis observasi fisik + hasil akurasi *Horizontal Timing Bar* (`perfect` / `good`), menyimpan koleksi ke tabel `user_cat_collections`, dan mencatat transaksi poin.
* `GET /api/v1/telcat/cat-dex`: Mengambil daftar seluruh kucing kampus beserta status kepemilikan koleksi pengguna yang sedang login.