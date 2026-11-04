# DESIGN SYSTEM & UI SPECIFICATION (`design.md`)
## Proyek: Super App Kucing Kampus — Modul TelCat World

---

## 1. Identitas Visual & Filosofi Desain (Berdasarkan `ref.pdf`)
Gaya visual mengusung tema **Clean, Warm, Playful, & Modern Utility**. Antarmuka mengutamakan ruang putih (*whitespace*) yang lega, kartu putih bersih di atas latar belakang abu-abu sangat muda, sudut membulat (*rounded corners*), serta aksen warna oranye hangat khas kucing kampus.

---

## 2. Palet Warna (Color Tokens)
* **Background Primary:** `#F8F9FA` (Off-White / Soft Gray — warna latar belakang layar utama).
* **Surface / Card Background:** `#FFFFFF` (Pure White — warna kartu konten dengan border tipis `#EDEDED`).
* **Brand Primary (Vibrant Cat Orange):** `#F26A1B` hingga `#FF7A00` (Digunakan untuk tombol CTA utama, badge aktif, dan ikon sorotan).
* **Brand Secondary (Soft Peach / Cream):** `#FFF3EB` (Digunakan untuk latar belakang *pill badge* poin, kotak ikon, dan *highlight card*).
* **Text Primary:** `#18181B` (Charcoal Black — untuk judul besar dan nama spot/kucing).
* **Text Secondary:** `#71717A` (Muted Gray — untuk subjudul, deskripsi, dan keterangan waktu).
* **Semantic Status Colors (Untuk Timing Bar & Status):**
  * **Success / Sweet Spot Green:** `#16A34A` (Latar lembut: `#DCFCE7`)
  * **Warning / Good Zone Yellow:** `#EAB308` (Latar lembut: `#FEF9C3`)
  * **Danger / Miss Zone Red:** `#DC2626` (Latar lembut: `#FEE2E2`)
  * **Info / Guide Gray-Blue:** `#F4F4F5` (Kotak informasi "Sebelum mulai" dengan ikon `i`).

---

## 3. Tipografi (Typography Scale)
Menggunakan font sans-serif modern seperti **Plus Jakarta Sans** atau **Inter**:
* **App Bar Title:** `16px`, Bold (`700`), `#18181B` ("Kucing Kampus").
* **App Bar Subtitle:** `13px`, Regular (`400`), `#71717A` ("TelCat World • Area TULT").
* **Section Eyebrow:** `11px`, Bold (`700`), Uppercase, Letter-spacing `0.8px`, `#71717A` (Contoh: `SESI PENDEKATAN KUCING`).
* **Hero Heading (H1):** `26px`, ExtraBold (`800`), `#18181B`, Line-height `1.25` (Contoh: `"Luluhkan hati si Oyen."` atau `"Kucing berhasil diluluhkan."`).
* **Card Title (H2):** `20px`, Bold (`700`), `#18181B`.
* **Body Copy:** `14px`, Regular (`400`), `#71717A`, Line-height `1.5`.
* **Button Label:** `16px`, Bold (`700`), `#FFFFFF` (Primary) atau `#18181B` (Secondary).
* **Point Badge Text:** `13px`, SemiBold (`600`), `#9A3412` dengan ikon bintang kilau (`✨`).

---

## 4. Komponen Inti & Dimensi (Component Specifications)

### 4.1 Top Header Bar (Konsisten di Semua Layar)
* **Kiri:** Ikon maskot kucing oranye-putih dalam kotak membulat (`40x40px`, `border-radius: 10px`).
* **Tengah-Kiri:** Teks vertikal 2 baris: Baris 1 `"Kucing Kampus"` (Bold), Baris 2 `"TelCat World"` (Muted Gray).
* **Kanan:** *Status Pill Badge* berlatar putih dengan border `#E4E4E7`, ikon centang/titik dalam lingkaran, dan teks `"Aktif"` atau `"Area TULT"` (`border-radius: 999px`, `padding: 6px 12px`).

### 4.2 Kartu Konten Utama (Main Content Card)
* **Radius & Border:** `border-radius: 20px`, `border: 1px solid #EFEFEF`, `background: #FFFFFF`.
* **Padding Internal:** `20px`.
* **Shadow:** `0 4px 20px rgba(0, 0, 0, 0.03)` (Sangat halus).
* **Point Pill Badge:** Kotak kecil `background: #FFF3EB`, `border-radius: 8px`, `padding: 6px 10px`, teks `"✨ Estimasi: +35-50 Poin"`.

### 4.3 Kotak Info Etika / Instruksi ("Sebelum Mulai" Callout)
* **Bentuk:** `background: #F4F4F5`, `border-radius: 16px`, `padding: 16px`.
* **Ikon:** Lingkaran informasi (`i`) di kiri atas, diikuti judul tebal `"Sebelum mulai"` dan teks deskripsi abu-abu di bawahnya.

### 4.4 Komponen Horizontal Timing Bar (Khusus Layar 3)
* **Container Bar:** Lebar `100%`, tinggi `28px`, `border-radius: 14px`, `background: #FEE2E2` (Zona Miss di ujung kiri-kanan), bagian tengah `40%` berwarna `#FEF08A` (Zona Good), dan titik tengah `18%` berwarna `#22C55E` (Zona Hijau *Sweet Spot*).
* **Indikator Jarum (Slider Knob):** Garis vertikal tebal atau kapsul putih berbingkai hitam (`width: 10px`, `height: 36px`, `border-radius: 5px`, `box-shadow: 0 2px 6px rgba(0,0,0,0.25)`) yang berada di atas bar.

### 4.5 Tombol Aksi Bawah (Bottom Action Buttons)
* **Primary Button:** Tinggi `54px`, lebar penuh (`100%`), `background: #F26A1B`, `border-radius: 14px`, teks putih tebal di tengah.
* **Secondary Button:** Tinggi `54px`, lebar penuh (`100%`), `background: #FFFFFF`, `border: 1.5px solid #E4E4E7`, `border-radius: 14px`, teks hitam tebal di tengah.