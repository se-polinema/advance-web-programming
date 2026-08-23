# Templat Rencana Konten per Bab

Templat ini direplikasi dari `cloud-computing/docs/chapter-plan-template.md`,
yang sendiri diturunkan dari `operating-system/os-book/docs/chapter01.md`.
**Salin berkas ini menjadi `docs/chapterNN.md`** untuk setiap bab (peta bab
final sudah tersedia di `outline.md`, disusun dari RPS resmi `RTI255003`),
lalu isi setiap placeholder `[...]` di bawah ini.

Jangan mengisi templat ini dengan konten final sekarang; ia adalah kerangka
kosong yang siap dipakai per bab.

---

# Rencana Konten: Bab [N] - [Judul Bab]

> **Scope:** [jumlah] sesi x [menit] menit = [total] menit instruksi
> **Target:** [X]-[Y] halaman
> **Pendekatan:** [ringkasan pendekatan, mis. "konsep Dart/Flutter umum +
> praktik langsung pada PasarKita"]

## Tujuan Pembelajaran

Setelah mempelajari bab ini, pembaca diharapkan mampu:
1. [tujuan 1, verb-led: menjelaskan/memahami/membandingkan/...]
2. [tujuan 2]
3. [tujuan 3]
4. [tujuan 4]
5. [tujuan 5, opsional]

---

## Struktur Bab (Compact)

### Session [N]: [Nama Sesi] ([X]-[Y] halaman)

#### [N.1] [Subtopik]
- [poin konten ringkas]
- [poin konten ringkas]

**Tabel komparasi (jika relevan):**
| [Kolom] | [Kolom] | [Kolom] |
|---|---|---|
| ... | ... | ... |

**Diagram:**
- [nama diagram 1, mis. "widget tree layar detail listing"]
- [nama diagram 2]

**Kotak Berwarna:**
- **notebox**: [catatan singkat]
- **tipbox**: [tips praktik terbaik]
- **warningbox**: [risiko yang perlu diwaspadai, mis. izin perangkat/kredensial]
- **examplebox**: [contoh konkret]
- **istilahpenting** (jika ini section pertama bab): [daftar istilah kunci]

**Code Listings / Perintah CLI:**
```bash
# [deskripsi]
[perintah, mis. flutter pub add ...]
```

**Cuplikan kode inline** (maks. ~15 baris, konsep spesifik saja; proyek
lengkap tetap di `\branchref{chapter-NN}`, lihat `authoring-guide.md`):
```dart
// [deskripsi cuplikan]
```

---

### Session [N]: [Nama Sesi Berikutnya] ([X]-[Y] halaman)

[ulangi pola di atas untuk tiap sesi]

---

## Estimasi Halaman

- **Session [N]**: [topik] - [X]-[Y] halaman
- **Session [N]**: [topik] - [X]-[Y] halaman
- ...

**Total: [X]-[Y] halaman** [tandai centang jika sesuai target sesi; Bab 8
dikecualikan dari batas 20 halaman, lihat `authoring-guide.md`]

---

## Visual Assets

**Diagrams ([jumlah] esensial):**
1. [nama diagram]
2. [nama diagram]

**Tables ([jumlah] esensial):**
1. [nama tabel]
2. [nama tabel]

**Code Listings / Perintah:**
- [kategori perintah 1, mis. perintah Flutter CLI]
- [kategori perintah 2, mis. cuplikan widget]

---

## Session Breakdown

| Session | Topik | Halaman | Aktivitas |
|---|---|---|---|
| 1 | [topik] | [X]-[Y] | [lecture/demo/hands-on] |
| 2 | [topik] | [X]-[Y] | [lecture/demo/hands-on] |

**Total: ~[X]-[Y] halaman** untuk [total menit] menit instruksi

---

## Implementation Notes

**Prioritas Konten:**
1. **Must-have**: [daftar]
2. **Should-have**: [daftar]
3. **Nice-to-have**: [daftar]

**Fokus Praktik:**
- [X]% teori (konsep Dart/Flutter/Supabase)
- [Y]% praktik (hands-on membangun PasarKita)
- Semua praktik idealnya dapat diikuti dengan Flutter SDK gratis dan tingkat
  gratis (free tier) Supabase

**Tone:**
- Formal namun mudah diakses
- Asumsikan pembaca belum pernah menulis aplikasi mobile atau mengintegrasikan
  backend
- Jelaskan istilah teknis pada penggunaan pertama
- Contoh nyata dari studi kasus PasarKita (lihat `authoring-guide.md`)

**Kode dan Branch GitHub:**
- Branch sumber: [`chapter-NN`, dibuat dari `chapter-[NN-1]`]
- Perubahan/berkas baru pada branch ini: [daftar]
- Cuplikan yang akan ditampilkan inline vs. yang cukup dirujuk lewat
  `\branchref{}`: [catatan]

**Latihan:**
- [jumlah] latihan, campuran teori dan praktik
- Semua latihan praktik idealnya dapat dilakukan tanpa perangkat fisik
  (emulator/simulator mencukupi)

---

**Status: DRAFT - [status penulisan, mis. "Belum Ditulis" / "Sedang Ditulis"]**
