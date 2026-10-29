#import "/template.typ": *

= Pengolahan Data: Impor, Ekspor, dan Antrean <ch:pengolahan-data>

#chapterhero("purple", [Susun laporan penjualan dengan filter tanggal, ekspor dan impor lewat CSV, lalu kenali kapan pekerjaan berat sebaiknya dipindah ke antrean.], [#icon("file-csv")#h(1em)ekspor & impor CSV], [#icon("cloud-upload-alt")#h(1em)laporan penjualan], [#icon("tasks")#h(1em)antrean])

Pabrik pengepakan dengan jalur konveyor menangani ratusan paket sejam:
barang berjalan otomatis dari satu stasiun ke stasiun berikutnya, dan
pekerja di ujung jalur cukup menunggu paket yang sudah jadi tiba di
depannya. Bandingkan dengan pos suplai kecil yang melayani satu pembeli
sekaligus dari awal sampai akhir, ambil barang, timbang, bungkus, baru
layani pembeli berikutnya. Pos suplai satu-satu itu cukup untuk toko
kecil dengan sedikit pembeli, tapi memaksanya menangani volume pabrik
akan membuat antrean pembeli mengular sampai ke luar pintu. Simple POS
menghadapi pilihan serupa setiap kali memproses data dalam jumlah
banyak: laporan dan impor kecil cukup ditangani langsung dalam satu
siklus request, seperti pos suplai satu-satu, tapi begitu volumenya
mendekati skala pabrik, pemrosesan itu perlu dipindah ke jalur konveyor
tersendiri: antrean.

#strong[Yang Akan Kamu Pelajari]

+ menyusun halaman laporan penjualan Simple POS dengan filter rentang tanggal dan total penjualan yang dihitung dari data transaksi;
+ mengekspor laporan penjualan ke CSV dan mengimpor data produk dari berkas CSV, termasuk penanganan galat pada baris yang tidak valid;
+ menjelaskan kapan pemrosesan data sebaiknya dipindah ke antrean (queue) alih-alih dijalankan langsung pada siklus request, memakai contoh impor produk berskala besar pada Simple POS.

== Laporan Penjualan dan Filter Tanggal <sec:pengolahan-data-1>

#istilahpenting[
/ ETL: #emph[Extract, Transform, Load], pola umum mengambil data mentah, mengubah bentuknya, lalu menyimpan atau menyajikannya dalam bentuk baru, seperti laporan penjualan yang diringkas dari baris transaksi.
/ Batch Processing: Memproses banyak data sekaligus dalam kelompok, bukan satu per satu, dipakai baik pada seeding (Bab~4) maupun impor CSV.
/ Antrean (Queue): Mekanisme menunda pekerjaan berat agar dijalankan di latar belakang oleh proses terpisah, bukan langsung selama request pengguna berlangsung.
/ Import/Export: Proses membawa data masuk dari format eksternal (CSV, Excel) ke basis data, atau mengeluarkannya dari basis data ke format eksternal untuk dibaca di luar aplikasi.
]

Halaman laporan Simple POS menjawab pertanyaan yang berbeda dari
halaman transaksi biasa: bukan "transaksi apa saja yang terjadi", tapi
"berapa total penjualan pada rentang waktu tertentu". Siapkan dulu
kerangkanya:

+ Buat controller-nya: `php artisan make:controller
      ReportController`.
+ Buka `routes/web.php`, daftarkan route
      `GET /reports` yang mengarah ke
      `ReportController@index`, di dalam grup
      `role:admin` dari Bab~7.
+ Buat berkas view-nya di
      `resources/views/reports/index.blade.php`, minimal berisi
      form filter dengan dua input tanggal (`name="from"` dan
      `name="to"`) dan area menampilkan `$totalPenjualan`.

`ReportController@index` menerima parameter tanggal awal dan
akhir dari form filter, lalu memfilter transaksi lewat
`whereBetween`.

#listing(file: "app/Http/Controllers/ReportController.php", ```php
$transactions = Transaction::whereBetween('created_at', [
    $request->date('from')->startOfDay(),
    $request->date('to')->endOfDay(),
])->get();

$totalPenjualan = $transactions->sum('total');
```)

`startOfDay()` dan `endOfDay()` penting di sini:
tanpa keduanya, filter tanggal "2026-08-01 sampai 2026-08-31" secara
harfiah berarti "sampai jam 00:00:00 tanggal 31", yang justru
mengecualikan seluruh transaksi yang terjadi sepanjang tanggal 31 itu
sendiri. `$transactions->sum('total')` menjumlahkan kolom
`total` yang memang sudah tersimpan per transaksi (dibahas di
Bab~6), bukan menghitung ulang dari harga produk satu per satu.

== Ekspor dan Impor CSV <sec:pengolahan-data-2>

Mengekspor laporan ke CSV berarti mengubah koleksi Eloquent menjadi
baris teks yang dipisah koma, siap dibuka di aplikasi spreadsheet mana
pun.

#listing(file: "app/Http/Controllers/ReportController.php", ```php
public function export(Request $request)
{
    $transactions = $this->filteredTransactions($request);

    return response()->streamDownload(function () use ($transactions) {
        $out = fopen('php://output', 'w');
        fputcsv($out, ['ID', 'Tanggal', 'Kasir', 'Total']);
        foreach ($transactions as $t) {
            fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
        }
        fclose($out);
    }, 'laporan-penjualan.csv');
}
```)

`response()->streamDownload()` menulis baris CSV langsung ke
output stream sambil mengirimkannya ke browser, tanpa menyimpan seluruh
berkas di memori server terlebih dahulu; ini penting begitu jumlah baris
laporan mulai besar.

Impor berjalan ke arah sebaliknya: membaca berkas CSV yang diunggah,
lalu mengubah tiap barisnya menjadi baris `products`. Bagian
yang lebih rawan di sini bukan proses baca-tulisnya, melainkan
menangani baris yang cacat tanpa menghentikan seluruh proses impor
gara-gara satu baris bermasalah.

#listing(file: "app/Http/Controllers/ReportController.php", ```php
$errors = [];
foreach ($rows as $lineNumber => $row) {
    $validator = Validator::make($row, [
        'name' => ['required', 'string'],
        'category_id' => ['required', 'exists:categories,id'],
        'price' => ['required', 'integer', 'min:0'],
    ]);

    if ($validator->fails()) {
        $errors[$lineNumber] = $validator->errors()->first();
        continue;
    }

    Product::create($validator->validated());
}
```)

`continue` pada baris yang gagal validasi memastikan proses
impor tetap berjalan ke baris berikutnya, mengumpulkan pesan error per
nomor baris di array `$errors`, alih-alih melempar exception
yang menghentikan seluruh impor hanya karena satu baris di tengah
berkas salah ketik harga.

== Praktik: Kapan Memakai Antrean <sec:pengolahan-data-3>

Impor beberapa puluh produk selesai dalam hitungan detik, cukup
dijalankan langsung dalam siklus request seperti kode di atas: pengguna
mengunggah berkas, menunggu sebentar, dan halaman berikutnya menampilkan
hasilnya. Begitu volumenya naik ke ribuan baris, misalnya toko yang
memigrasikan seluruh katalog dari sistem lama sekaligus, proses yang
sama bisa memakan waktu puluhan detik atau lebih, dan permintaan HTTP
punya batas waktu tunggu. Pengguna yang menunggu di depan browser tanpa
tahu prosesnya masih berjalan atau sudah gagal diam-diam adalah
pengalaman yang buruk, dan pada beberapa server permintaan itu bahkan
bisa dipotong paksa sebelum sempat selesai.

#figure(
  table(
    columns: (1.1fr, 1.1fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Pendekatan], [Waktu respons pengguna], [Cocok untuk],
    table.hline(stroke: 0.5pt),
    [Proses langsung (request)], [Menunggu sampai selesai], [Impor kecil, kurang dari beberapa ratus baris],
    [Job antrean], [Instan, diproses di latar belakang], [Impor besar, laporan berat, kirim email massal],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Proses langsung pada request vs job antrean],
) <tab:queue-vs-langsung>

Memindahkan impor ke antrean berarti controller hanya menyimpan berkas
dan mengirim satu job ke antrean, lalu segera merespons pengguna dengan
pesan "impor sedang diproses", tanpa menunggu prosesnya selesai sama
sekali. Langkah-langkah berikut memindahkan impor produk dari kode pada
bagian sebelumnya ke job antrean.

+ Siapkan driver antrean. Buka `.env`, pastikan
      `QUEUE_CONNECTION=database` (bukan `sync`, yang
      menjalankan job langsung tanpa antrean sungguhan). Kalau tabel
      antrean belum ada, buat migrasinya:

  #listing(```bash
  php artisan queue:table
  php artisan migrate
    
  ```)
+ Buat kelas job-nya:

  #listing(```bash
  php artisan make:job ProcessProductImport
    
  ```)
+ Buka `app/Jobs/ProcessProductImport.php`. Pindahkan loop
      validasi-dan-simpan dari potongan kode sebelumnya ke metode
      `handle()`, dengan path berkas CSV disimpan lewat constructor:

  #listing(file: "app/Jobs/ProcessProductImport.php", ```php
  public function __construct(private string $csvPath) {}

  public function handle(): void
  {
      $rows = /* baca $this->csvPath jadi array baris */;
      foreach ($rows as $lineNumber => $row) {
          // ...loop validasi dan Product::create() dari sebelumnya
      }
  }
    
  ```)
+ Buka `ReportController` (atau controller impor yang
      sesuai), ganti pemanggilan langsung loop impor dengan pengiriman job:

  #listing(file: "app/Http/Controllers/ReportController.php", ```php
  ProcessProductImport::dispatch($request->file('csv')->store('imports'));

  return back()->with('success', 'Impor sedang diproses di latar belakang.');
    
  ```)
+ Jalankan worker antrean di terminal terpisah (biarkan tetap
      berjalan selama pengujian):

  #listing(```bash
  php artisan queue:work
    
  ```)
+ Unggah berkas CSV lewat form impor. #strong[Yang diharapkan]:
      halaman langsung merespons dengan pesan "impor sedang diproses"
      (bukan menunggu), dan di terminal `queue:work`, muncul baris log
      `Processing: App\Jobs\ProcessProductImport`
      diikuti `Processed` beberapa saat kemudian.
+ Buka `/products`, refresh halamannya. #strong[Yang
      diharapkan]: produk-produk dari berkas CSV sudah tersimpan, meski
      proses penyimpanannya terjadi setelah controller sudah selesai
      merespons.
+ #strong[Kalau job tidak pernah diproses] (terminal
      `queue:work` diam saja), periksa dua hal: (a)
      `QUEUE_CONNECTION` di `.env` masih bertuliskan
      `sync`, sehingga job dijalankan langsung tanpa pernah masuk
      tabel antrean; (b) worker di langkah 5 belum dijalankan sama sekali,
      atau sempat dihentikan sebelum job dikirim di langkah 6.

#tipbox[
Tanda-tanda sebuah proses layak dipindah ke antrean: durasinya tidak
bisa diprediksi di muka (tergantung ukuran berkas yang diunggah
pengguna), ia tidak perlu hasil instan yang langsung dilihat pengguna
di halaman yang sama, atau ia melibatkan panggilan ke layanan eksternal
yang lambat (mengirim email, memanggil API pihak ketiga). Laporan yang
dibuka dan dibaca langsung di halaman, sebaliknya, biasanya tetap lebih
baik diproses langsung, karena pengguna memang menunggu hasilnya saat
itu juga.
]

#branchref("chapter-08")

== Rangkuman <sec:pengolahan-data-rangkuman>

- Laporan penjualan Simple POS memfilter transaksi lewat
      `whereBetween` dengan `startOfDay()`/`endOfDay()`
      pada rentang tanggal, dan menjumlahkan kolom `total` yang
      sudah tersimpan, bukan menghitung ulang dari nol.
- Ekspor CSV memakai `streamDownload()` untuk menulis
      baris langsung ke output tanpa menahan seluruh berkas di memori;
      impor CSV memvalidasi tiap baris satu per satu dan melewati baris
      yang gagal lewat `continue`, mengumpulkan pesan error per
      baris alih-alih menghentikan seluruh proses.
- Proses berdurasi tidak terprediksi atau melibatkan volume besar,
      seperti impor produk berskala ribuan baris, sebaiknya dipindah ke
      job antrean agar pengguna mendapat respons instan sementara
      prosesnya berjalan di latar belakang.

== Latihan

+ Ubah filter laporan untuk mendukung filter per kategori produk,
      selain rentang tanggal yang sudah ada.
+ Uji impor dengan berkas CSV berisi campuran baris valid dan
      tidak valid (misalnya `category_id` yang tidak ada), lalu
      periksa apakah baris valid tetap tersimpan dan pesan error baris
      yang gagal tampil dengan jelas.
+ Identifikasi satu proses lain di Simple POS, selain impor
      produk, yang menurutmu layak dipindah ke job antrean, dan jelaskan
      alasannya.
+ #strong[Self-check:] tanpa membuka ulang bab ini, coba jelaskan
      dengan kata-katamu sendiri: (a) mengapa `startOfDay()`/`endOfDay()`
      dibutuhkan pada filter tanggal, (b) mengapa baris CSV yang gagal
      tidak boleh menghentikan seluruh impor, dan (c) tanda-tanda sebuah
      proses layak dipindah ke antrean. Cocokkan jawabanmu dengan isi bab
      ini.

#challengebox[
Tambahkan bagian ringkasan produk terlaris pada halaman laporan,
menampilkan lima produk dengan quantity terjual tertinggi pada rentang
tanggal yang sedang difilter.
]

== Referensi

Bab ini mengacu pada dokumentasi resmi Laravel #cite(<laraveldocs>) untuk
query builder, streaming response, dan antrean.
