---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    padding: 56px 72px;
    justify-content: center;
  }
  section.lead {
    background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 55%, #2563eb 100%);
    color: #fff;
    justify-content: center;
  }
  section.lead h1, section.lead h2, section.lead p {
    color: #fff;
  }
  section.divider {
    background: #1d4ed8;
    color: #fff;
  }
  section.divider h1 {
    color: #fff;
    font-size: 2.2em;
  }
  section.divider h2 {
    color: #fff;
  }
  section.divider p {
    color: #bfdbfe;
  }
  h1 {
    color: #1d4ed8;
    font-size: 1.6em;
  }
  h2 {
    color: #1d4ed8;
  }
  table {
    font-size: 0.72em;
    width: 100%;
  }
  table.small {
    font-size: 0.75em;
  }
  th, td {
    padding: 4px 10px;
  }
  th {
    background: #1d4ed8;
    color: #fff;
  }
  code {
    background: #f1f5f9;
    color: #0f172a;
  }
  pre {
    font-size: 0.68em;
  }
  .term-box {
    border-left: 6px solid #1d4ed8;
    background: #eff6ff;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.82em;
  }
  .term-box b {
    color: #1d4ed8;
  }
  .tip-box {
    border-left: 6px solid #16a34a;
    background: #f0fdf4;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.8em;
  }
  .warn-box {
    border-left: 6px solid #dc2626;
    background: #fef2f2;
    padding: 10px 18px;
    margin: 10px 0;
    font-size: 0.8em;
  }
  .cols {
    display: flex;
    gap: 24px;
  }
  .cols > div {
    flex: 1;
  }
  .flow {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    margin-top: 30px;
    flex-wrap: wrap;
  }
  .flow .box {
    background: #1d4ed8;
    color: #fff;
    padding: 12px 18px;
    border-radius: 8px;
    font-weight: bold;
    font-size: 0.85em;
  }
  .flow .arrow {
    font-size: 1.4em;
    color: #1d4ed8;
  }
  .stack .box {
    background: #1d4ed8;
    color: #fff;
    padding: 10px;
    border-radius: 6px;
    text-align: center;
    margin: 4px 0;
    font-weight: bold;
  }
  .footnote {
    font-size: 0.55em;
    color: #64748b;
    position: absolute;
    bottom: 20px;
  }
  .ref-link {
    display: inline-block;
    font-size: 0.62em;
    color: #1d4ed8;
    background: #eff6ff;
    border-left: 4px solid #93c5fd;
    border-radius: 0 6px 6px 0;
    padding: 6px 14px;
    margin-top: 14px;
  }
  .ref-link code {
    background: transparent;
    color: #1d4ed8;
  }
---

<!-- _class: lead -->

# Advanced Web Programming
## SIB245007 &nbsp;|&nbsp; D-IV Sistem Informasi Bisnis

Meeting 9: **Data Processing: Import, Export, and Queues**

From the ETL pipeline, large datasets, and memory, to heavy work handed off to the background

---

## What You'll Learn

1. Explain the **ETL** pattern and **batch processing** for handling large amounts of data
2. Build a date-range report, and pick the right techniques for **large datasets**
3. Understand why **memory** runs out, and choose memory-friendly ways to read data
4. Choose between **CSV, Excel, and PDF** for a need
5. Follow a **job** through a queue, from creation to execution by a worker, and run it in **production**

<div class="tip-box">
These slides cover the concepts. Applying reports, export/import, and queues to Simple POS is done in the lab jobsheet.
</div>

---

## Meeting Map

<div class="flow">
  <div class="box">Raw data</div>
  <div class="arrow">&rarr;</div>
  <div class="box">ETL + Batch</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Report</div>
  <div class="arrow">&rarr;</div>
  <div class="box">CSV / Excel / PDF</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Queue</div>
</div>

<div class="tip-box">
Like a restaurant kitchen: ingredients come in (<b>extract</b>), get cooked (<b>transform</b>), then are served (<b>load</b>). When orders pile up, guests get a table number and the food is brought over later. That is a queue.
</div>

---

<!-- _class: divider -->

# Part 1
## ETL and Batch Processing

---

## Four Basic Terms

| Term | Meaning |
|---|---|
| **ETL** | Extract (take), Transform (reshape), Load (store or present) |
| **Batch processing** | processing data in groups, not one by one |
| **Import / Export** | data in from CSV/Excel to the database, or out to CSV/Excel/PDF |
| **Queue** | heavy work handed off, done by another process in the background |

---

## ETL: Three Stages That Always Appear

<svg viewBox="0 0 1000 300" width="100%" style="display:block;margin:0 auto;max-height:340px" font-family="Helvetica Neue, Arial, sans-serif" font-size="20">
<defs><marker id="e1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#1d4ed8"/></marker></defs>
<rect x="30" y="40" width="270" height="130" rx="14" fill="#1d4ed8"/>
<text x="165" y="92" text-anchor="middle" fill="#fff" font-size="30" font-weight="bold">Extract</text>
<text x="165" y="132" text-anchor="middle" fill="#bfdbfe" font-size="20">CSV, database, API</text>
<rect x="365" y="40" width="270" height="130" rx="14" fill="#1d4ed8"/>
<text x="500" y="92" text-anchor="middle" fill="#fff" font-size="30" font-weight="bold">Transform</text>
<text x="500" y="132" text-anchor="middle" fill="#bfdbfe" font-size="20">validate, clean, map</text>
<rect x="700" y="40" width="270" height="130" rx="14" fill="#1d4ed8"/>
<text x="835" y="92" text-anchor="middle" fill="#fff" font-size="30" font-weight="bold">Load</text>
<text x="835" y="132" text-anchor="middle" fill="#bfdbfe" font-size="20">database, CSV, Excel, PDF</text>
<line x1="304" y1="105" x2="359" y2="105" stroke="#1d4ed8" stroke-width="4" marker-end="url(#e1)"/>
<line x1="639" y1="105" x2="694" y2="105" stroke="#1d4ed8" stroke-width="4" marker-end="url(#e1)"/>
<text x="165" y="222" text-anchor="middle" fill="#64748b" font-size="22">raw ingredients</text>
<text x="500" y="222" text-anchor="middle" fill="#64748b" font-size="22">cooked</text>
<text x="835" y="222" text-anchor="middle" fill="#64748b" font-size="22">served</text>
</svg>

- Keep the three stages separate so each part is easy to test and replace
- Source, validation rules, and destination can change without touching the others

---

## Import and Export Are Two-Way ETL

| | Extract | Transform | Load |
|---|---|---|---|
| **Import** | read CSV / Excel file | validate each row, map columns | save to database |
| **Export** | query the database | pick columns, format dates and numbers | write CSV / Excel / PDF |

<div class="tip-box">
For every feature, ask: where does the data come from, what changes, where does the result go?
</div>

---

## Batch: One by One vs One Truckload

```php
// 10,000 rows = 10,000 queries
foreach ($rows as $row) {
    Article::create($row);
}

// 10,000 rows = 20 queries (batches of 500 rows)
foreach (array_chunk($rows, 500) as $batch) {
    Article::insert($batch);
}
```

Every query pays a trip to the database. One full truck beats 10,000 motorbike couriers.

<div class="warn-box">
Bulk <code>insert()</code> does not fill <code>created_at</code>/<code>updated_at</code> and does not fire model events. Fill timestamps yourself if needed.
</div>

---

## Batch Size and Reading in Batches

<div class="cols">
<div>

**Too small**
- Too many round trips
- Slow

**Too large**
- Memory balloons
- One failure fails many rows

</div>
<div>

```php
Article::where('status', 'draft')
    ->chunkById(500, function ($articles) {
        foreach ($articles as $a) {
            // process each row
        }
    });
```

</div>
</div>

<div class="tip-box">
Start with hundreds to a thousand rows per batch, then measure. Wrap each batch in <code>DB::transaction()</code> if it must succeed or fail together.
</div>

---

## Idempotent: Safe to Run Many Times

Uploading the same import file twice must not create duplicates.

```php
Article::updateOrCreate(
    ['slug' => $row['slug']],     // lookup key
    ['title' => $row['title']],   // values to update
);

// batch version: one query for many rows
Article::upsert($batch, ['slug'], ['title']);
```

<div class="warn-box">
<code>upsert()</code> needs a <b>unique index</b> on the key columns. Without it, the database cannot tell which rows count as the same.
</div>

---

<!-- _class: divider -->

# Part 2
## Reports and Large Datasets

---

## List vs Report

- **List**: shows rows one by one
- **Report**: summarizes, for example "total X in a date range"

```php
$totalWords = Article::whereBetween('published_at', [$from, $to])
    ->sum('word_count');   // filter by date, then sum one column
```

---

## Common Trap: The Cut-Off Last Day

<div class="warn-box">
A filter "1 to 31 August" means "up to 31 August 00:00:00". Every transaction on the 31st is lost.
</div>

```php
$from = $request->date('from')->startOfDay();   // 00:00:00
$to = $request->date('to')->endOfDay();         // 23:59:59
```

---

## The Day-Boundary Trap, Drawn on a Timeline

<svg viewBox="0 0 1000 270" width="100%" style="display:block;margin:0 auto;max-height:400px" font-family="Helvetica Neue, Arial, sans-serif" font-size="23">
<line x1="40" y1="40" x2="300" y2="40" stroke="#dc2626" stroke-width="7"/>
<line x1="300" y1="28" x2="300" y2="52" stroke="#dc2626" stroke-width="5"/>
<text x="40" y="24" fill="#dc2626" font-weight="bold">Without endOfDay(): the filter stops at Aug 31, 00:00</text>
<rect x="300" y="92" width="400" height="56" fill="#eff6ff"/>
<line x1="40" y1="120" x2="960" y2="120" stroke="#1e293b" stroke-width="3"/>
<line x1="300" y1="104" x2="300" y2="136" stroke="#1e293b" stroke-width="3"/>
<line x1="700" y1="104" x2="700" y2="136" stroke="#1e293b" stroke-width="3"/>
<circle cx="200" cy="120" r="9" fill="#16a34a"/>
<circle cx="380" cy="120" r="9" fill="#dc2626"/>
<circle cx="500" cy="120" r="9" fill="#dc2626"/>
<circle cx="620" cy="120" r="9" fill="#dc2626"/>
<text x="500" y="84" text-anchor="middle" fill="#dc2626" font-size="22">transactions on the 31st are lost</text>
<text x="300" y="164" text-anchor="middle" fill="#64748b" font-size="21">00:00</text>
<text x="700" y="164" text-anchor="middle" fill="#64748b" font-size="21">24:00</text>
<text x="170" y="196" text-anchor="middle" fill="#64748b">Aug 30</text>
<text x="500" y="196" text-anchor="middle" fill="#1d4ed8" font-weight="bold">Aug 31</text>
<text x="830" y="196" text-anchor="middle" fill="#64748b">Sep 1</text>
<line x1="40" y1="224" x2="700" y2="224" stroke="#16a34a" stroke-width="7"/>
<line x1="700" y1="212" x2="700" y2="236" stroke="#16a34a" stroke-width="5"/>
<text x="40" y="256" fill="#16a34a" font-weight="bold">With endOfDay(): the filter stops at Aug 31, 23:59:59, the whole day is counted</text>
</svg>

---

## Compute in the Database, Not in PHP

```php
// heavy: all rows loaded into memory, summed in PHP
$total = Article::all()->sum('word_count');

// light: the database does the summing
$total = Article::sum('word_count');

// per-author summary: top 5 authors by word count
Article::selectRaw('author_id, COUNT(*) AS total, SUM(word_count) AS total_words')
    ->groupBy('author_id')
    ->orderByDesc('total_words')
    ->limit(5)
    ->get();
```

<div class="tip-box">
Like asking the bank for your balance, instead of requesting every transaction and adding them up yourself.
</div>

---

## Use the Stored Total

```php
// word_count is computed once, when the article is saved
$article->word_count = str_word_count($article->body);

// the report just sums the stored column
Article::whereBetween('published_at', [$from, $to])->sum('word_count');
```

- Derived values are computed on the server at creation time (Meeting 6)
- Reports do not recompute from raw data every time they open

---

## Tools for Large Datasets

| Technique | Use when | Note |
|---|---|---|
| `paginate()` | showing a list | one page per request |
| `chunkById()` | updating many rows | safe when rows change |
| `lazyById()` | reading many rows like a `foreach` | flat memory |
| `cursor()` | one long query | less safe if data changes |
| `select([...])` | only some columns needed | smaller models |
| `with()` | using relations in a loop | avoids N+1 |
| index | filter or sort on a column | no full table scan |

---

## Index: A Table of Contents for the Table

```php
Schema::table('articles', function (Blueprint $table) {
    $table->index('published_at');
});
```

```sql
EXPLAIN SELECT * FROM articles WHERE published_at BETWEEN '2026-08-01' AND '2026-08-31';
-- type: ALL    = full table scan (slow)
-- type: range  = uses the index (fast)
```

Without an index, the database reads the table row by row. With one, it jumps straight to the rows it needs.

<div class="ref-link">Recall Meeting 4: index strategy and <code>EXPLAIN</code></div>

---

<!-- _class: divider -->

# Part 3
## Memory Management

---

## Why Memory Runs Out

- PHP has a `memory_limit` (commonly 128 MB)
- Each Eloquent row becomes a **model object**, much bigger than the raw data
- `get()` loads every row at once

<div class="warn-box">
Jobsheet example: reading 52,500 transactions with <code>get()</code> uses about 96 MB, while <code>lazyById()</code> uses only about 38 MB. Add a bit more data and <code>get()</code> hits <i>Allowed memory size exhausted</i>.
</div>

---

## `get` vs `chunk` vs `lazy` vs `cursor`

| Method | Memory | Queries | Good for |
|---|---|---|---|
| `get()` | all rows | 1 | small data |
| `chunkById(n)` | n rows | many | bulk updates |
| `lazyById(n)` | n rows | many | export, plain `foreach` |
| `cursor()` | 1 row | 1 | one-pass reads, data not changing |

<div class="tip-box">
Could be hundreds of thousands of rows? Do not <code>get()</code>. Read with <code>lazyById()</code>, update with <code>chunkById()</code>.
</div>

---

## Bucket vs Tap

<svg viewBox="0 0 1000 310" width="100%" style="display:block;margin:0 auto;max-height:400px" font-family="Helvetica Neue, Arial, sans-serif" font-size="22">
<text x="40" y="28" font-size="23" font-weight="bold" fill="#1d4ed8">Bucket: collect first</text>
<text x="40" y="50" font-size="20" fill="#64748b">get() then build one big string</text>
<line x1="60" y1="60" x2="60" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="60" y1="260" x2="460" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="60" y1="84" x2="460" y2="84" stroke="#dc2626" stroke-width="2" stroke-dasharray="8 6"/>
<text x="458" y="76" text-anchor="end" font-size="20" fill="#dc2626">memory limit</text>
<polyline points="60,250 160,218 260,172 360,124 436,88" fill="none" stroke="#1d4ed8" stroke-width="5"/>
<circle cx="436" cy="88" r="8" fill="#dc2626"/>
<text x="330" y="108" text-anchor="end" font-weight="bold" fill="#dc2626">out of memory</text>
<text x="260" y="288" text-anchor="middle" font-size="20" fill="#64748b">rows processed &rarr;</text>
<text transform="rotate(-90 32 160)" x="32" y="160" text-anchor="middle" font-size="20" fill="#64748b">server memory</text>
<text x="540" y="28" font-size="23" font-weight="bold" fill="#16a34a">Tap: flow row by row</text>
<text x="540" y="50" font-size="20" fill="#64748b">lazyById() + streamDownload()</text>
<line x1="560" y1="60" x2="560" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="560" y1="260" x2="960" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="560" y1="84" x2="960" y2="84" stroke="#dc2626" stroke-width="2" stroke-dasharray="8 6"/>
<text x="958" y="76" text-anchor="end" font-size="20" fill="#dc2626">memory limit</text>
<polyline points="560,236 660,232 760,237 860,231 936,235" fill="none" stroke="#16a34a" stroke-width="5"/>
<text x="760" y="214" text-anchor="middle" font-weight="bold" fill="#16a34a">stays flat</text>
<text x="760" y="288" text-anchor="middle" font-size="20" fill="#64748b">rows processed &rarr;</text>
<text transform="rotate(-90 532 160)" x="532" y="160" text-anchor="middle" font-size="20" fill="#64748b">server memory</text>
</svg>

---

## Export with `streamDownload()` and `lazyById()`

```php
$articles = Article::with('author')
    ->whereBetween('published_at', [$from, $to]);

return response()->streamDownload(function () use ($articles) {
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Title', 'Author', 'Date']);
    foreach ($articles->lazyById() as $a) {
        fputcsv($out, [$a->title, $a->author->name, $a->published_at]);
    }
    fclose($out);
}, 'articles-report.csv');
```

`lazyById()` reads per chunk, `streamDownload()` sends per row. Memory stays flat.

<div class="ref-link">Laravel docs: <code>HTTP Responses &rarr; File Downloads</code> and <code>Eloquent &rarr; Chunking</code></div>

---

## Don't Guess, Measure

```php
gc_collect_cycles();
memory_reset_peak_usage();      // start counting the peak from zero

foreach (Article::lazyById() as $a) {
    // ... work ...
}

printf("peak %.1f MB\n", memory_get_peak_usage() / 1048576);
```

- `memory_get_peak_usage()`: the highest memory use so far
- `memory_reset_peak_usage()` (PHP 8.2+): each measurement stands alone
- Compare two approaches on the same data, then write down the numbers

---

## The `chunk()` Trap: Skipped Rows

```php
// DANGEROUS: filters on 'draft', then changes 'draft' itself
Article::where('status', 'draft')->chunk(100, function ($articles) {
    foreach ($articles as $a) {
        $a->update(['status' => 'published']);
    }
});
```

Updated rows leave the filter, the list shifts, and the next chunk skips some rows.

<div class="tip-box">
Fix: <code>chunkById(100, ...)</code>. It uses the last <code>id</code> as a marker, so it is safe even when rows change.
</div>

---

<!-- _class: divider -->

# Part 4
## Formats and Libraries: CSV, Excel, PDF

---

## Choosing a Format: CSV, Excel, or PDF

| | CSV | Excel (.xlsx) | PDF |
|---|---|---|---|
| **Best for** | raw data, between systems | analysis, financial reports | reading or printing |
| **Memory** | very light (stream) | medium | heavy (whole document) |
| **Library** | `fputcsv` (built into PHP) | Laravel Excel | DomPDF |
| **Large data** | yes | yes (`FromQuery`) | no, limit rows |

---

## CSV: Simple but Full of Traps

- **Delimiter**: Indonesian-locale Excel often uses a semicolon (`;`)
- **Quoting**: values with commas or newlines need quotes (`fputcsv` handles it)
- **Encoding**: UTF-8 from Excel often starts with an invisible character (**BOM**) that breaks the first header
- **No types**: every value is text, type validation is still your job

<div class="warn-box">
Every row rejected on import? Check the header first: delimiter and BOM are the usual suspects.
</div>

---

## Laravel Excel: Export

```php
class ArticlesExport implements FromQuery, WithHeadings, WithMapping, ShouldAutoSize
{
    public function query()
    {
        return Article::with('author')->orderBy('id');
    }

    public function headings(): array { return ['Title', 'Author', 'Date']; }

    public function map($article): array
    {
        return [$article->title, $article->author->name, $article->published_at];
    }
}

return Excel::download(new ArticlesExport, 'articles.xlsx');
```

You only describe the contents through small interfaces (`concerns`). The library handles the `.xlsx` format.

<div class="ref-link">docs.laravel-excel.com &rarr; Exports</div>

---

## Laravel Excel: Import

```php
class ArticlesImport implements ToModel, WithHeadingRow, WithValidation,
    WithChunkReading, WithBatchInserts
{
    public function model(array $row): Article
    {
        return new Article(['title' => $row['title'], 'author_id' => $row['author_id']]);
    }

    public function rules(): array
    {
        return ['title' => ['required'], 'author_id' => ['exists:authors,id']];
    }

    public function chunkSize(): int { return 1000; }   // read 1000 rows per turn
    public function batchSize(): int { return 500; }    // insert 500 rows per query
}

Excel::import(new ArticlesImport, $request->file('file'));
```

<div class="warn-box">
By default, <code>WithValidation</code> stops at the first bad row. Add <code>SkipsOnFailure</code> to skip and collect bad rows.
</div>

---

## PDF with DomPDF: HTML Becomes a Document

<div class="flow">
  <div class="box">Blade view</div>
  <div class="arrow">&rarr;</div>
  <div class="box">HTML + CSS</div>
  <div class="arrow">&rarr;</div>
  <div class="box">DomPDF</div>
  <div class="arrow">&rarr;</div>
  <div class="box">PDF file</div>
</div>

```php
$pdf = Pdf::loadView('reports.articles', ['articles' => $articles])
    ->setPaper('a4', 'landscape');   // wide table: use landscape

return $pdf->download('articles.pdf');   // stream() to show in the browser
```

<div class="warn-box">
DomPDF supports only part of CSS and holds the whole document in memory. Use it for small summaries. For large data, pick CSV or Excel.
</div>

---

## Import: One Bad Row Does Not Stop the Others

Like a cashier scanning groceries: a broken barcode is set aside, the rest keep scanning.

<svg viewBox="0 0 1000 285" width="100%" style="display:block;margin:0 auto;max-height:330px" font-family="Helvetica Neue, Arial, sans-serif" font-size="19">
<defs>
<marker id="g1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
<marker id="g2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="g3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#dc2626"/></marker>
</defs>
<text x="40" y="28" font-size="17" fill="#64748b">CSV file: name, category_id, price</text>
<rect x="40" y="44" width="260" height="38" rx="5" fill="#f0fdf4" stroke="#16a34a" stroke-width="2"/>
<text x="56" y="69" font-family="monospace" font-size="18">Kopi Hitam,1,15000</text>
<rect x="40" y="94" width="260" height="38" rx="5" fill="#f0fdf4" stroke="#16a34a" stroke-width="2"/>
<text x="56" y="119" font-family="monospace" font-size="18">Teh Manis,1,10000</text>
<rect x="40" y="144" width="260" height="38" rx="5" fill="#fef2f2" stroke="#dc2626" stroke-width="2"/>
<text x="56" y="169" font-family="monospace" font-size="18">No Category,999,5000</text>
<line x1="304" y1="113" x2="376" y2="113" stroke="#64748b" stroke-width="3" marker-end="url(#g1)"/>
<rect x="380" y="53" width="170" height="120" rx="10" fill="#1d4ed8"/>
<text x="465" y="108" text-anchor="middle" fill="#fff" font-size="25" font-weight="bold">Validator</text>
<text x="465" y="134" text-anchor="middle" fill="#bfdbfe" font-size="18">checks each row</text>
<line x1="554" y1="90" x2="676" y2="78" stroke="#16a34a" stroke-width="3" marker-end="url(#g2)"/>
<line x1="554" y1="140" x2="676" y2="198" stroke="#dc2626" stroke-width="3" marker-end="url(#g3)"/>
<rect x="700" y="50" width="130" height="70" fill="#dcfce7"/>
<ellipse cx="765" cy="120" rx="65" ry="14" fill="#dcfce7" stroke="#16a34a" stroke-width="2.5"/>
<line x1="700" y1="50" x2="700" y2="120" stroke="#16a34a" stroke-width="2.5"/>
<line x1="830" y1="50" x2="830" y2="120" stroke="#16a34a" stroke-width="2.5"/>
<ellipse cx="765" cy="50" rx="65" ry="14" fill="#bbf7d0" stroke="#16a34a" stroke-width="2.5"/>
<text x="765" y="92" text-anchor="middle" font-weight="bold" fill="#166534">database</text>
<text x="860" y="90" font-weight="bold" fill="#16a34a" font-size="22">2 saved</text>
<path d="M690 186 L690 236 L850 236 L850 186" fill="#fef2f2" stroke="#dc2626" stroke-width="3.5"/>
<text x="770" y="218" text-anchor="middle" fill="#dc2626" font-weight="bold">skipped</text>
<text x="870" y="218" font-weight="bold" fill="#dc2626" font-size="22">1 skipped</text>
<text x="500" y="272" text-anchor="middle" font-size="17" fill="#64748b">one bad row does not stop the others</text>
</svg>

---

## Import: Validate Each Row, Skip the Bad Ones

```php
$rows = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
$rows = array_map('str_getcsv', $rows);
$header = array_shift($rows);

foreach ($rows as $row) {
    $data = array_combine($header, $row);

    $validator = Validator::make($data, [
        'slug' => ['required', 'string'],
        'title' => ['required', 'string'],
        'author_id' => ['required', 'exists:authors,id'],
    ]);

    if ($validator->fails()) {
        continue; // skip this row, go on to the next one
    }

    Article::updateOrCreate(['slug' => $data['slug']], $validator->validated());
}
```

---

## What to Do with Bad Rows?

| Strategy | How it works | Good for |
|---|---|---|
| **Skip silently** | skipped with no record | almost never: data vanishes quietly |
| **Skip and log** | skipped, row number and reason saved | general imports (recommended) |
| **Abort all** | one bad row cancels everything (`DB::transaction`) | financial or must-be-complete data |

---

<!-- _class: divider -->

# Part 5
## Queue: The Journey of a Job

---

## When Does Work Go to a Queue?

<div class="cols">
<div>

**Directly (in the request)**
- The user waits until it finishes
- Fits short work

</div>
<div>

**Through a queue (job)**
- Instant response, work in the background
- Fits heavy work

</div>
</div>

A task belongs in a queue when:
- its duration is unpredictable (depends on data size)
- the result is not needed immediately
- it calls a slow service (email, third-party API)
- it is safe to retry (idempotent)

<div class="tip-box">
Laundry: one shirt you wait for, a whole sack you drop off with a ticket. An HTTP request has a time limit.
</div>

---

## Queue = Laundry by the Kilo

<svg viewBox="0 0 1000 400" width="100%" style="display:block;margin:0 auto;max-height:440px" font-family="Helvetica Neue, Arial, sans-serif" font-size="19">
<defs>
<marker id="q1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#1e293b"/></marker>
<marker id="q2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="q3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
</defs>
<rect x="70" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="160" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="22">Browser</text>
<text x="160" y="58" text-anchor="middle" fill="#bfdbfe" font-size="17">customer</text>
<rect x="310" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="400" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="22">Controller</text>
<text x="400" y="58" text-anchor="middle" fill="#bfdbfe" font-size="17">laundry clerk</text>
<rect x="550" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="640" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="22">jobs table</text>
<text x="640" y="58" text-anchor="middle" fill="#bfdbfe" font-size="17">ticket rack</text>
<rect x="790" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="880" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="22">Worker</text>
<text x="880" y="58" text-anchor="middle" fill="#bfdbfe" font-size="17">washer</text>
<line x1="160" y1="72" x2="160" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="400" y1="72" x2="400" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="640" y1="72" x2="640" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="880" y1="72" x2="880" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="30" y1="90" x2="30" y2="380" stroke="#64748b" stroke-width="2.5" marker-end="url(#q3)"/>
<text transform="rotate(-90 16 235)" x="16" y="235" text-anchor="middle" font-size="17" fill="#64748b">time</text>
<line x1="162" y1="108" x2="396" y2="108" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="280" y="98" text-anchor="middle" font-size="18">POST /import</text>
<line x1="402" y1="150" x2="636" y2="150" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="520" y="140" text-anchor="middle" font-size="18">dispatch(): store the job</text>
<line x1="398" y1="192" x2="164" y2="192" stroke="#16a34a" stroke-width="2.5" stroke-dasharray="7 5" marker-end="url(#q2)"/>
<text x="280" y="182" text-anchor="middle" font-size="18" fill="#16a34a">instant response</text>
<rect x="68" y="214" width="184" height="40" rx="6" fill="#f1f5f9" stroke="#94a3b8" stroke-dasharray="5 4"/>
<text x="160" y="239" text-anchor="middle" font-size="17" fill="#475569">the user has already left</text>
<text x="520" y="248" text-anchor="middle" font-size="17" font-style="italic" fill="#64748b">... a while later ...</text>
<line x1="878" y1="290" x2="644" y2="290" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="760" y="280" text-anchor="middle" font-size="18">fetch the next job</text>
<rect x="790" y="314" width="180" height="56" rx="6" fill="#eff6ff" stroke="#1d4ed8" stroke-width="2"/>
<text x="880" y="338" text-anchor="middle" font-weight="bold" fill="#1d4ed8" font-size="19">handle()</text>
<text x="880" y="358" text-anchor="middle" font-size="16" fill="#475569">validate &amp; save</text>
</svg>

---

## One Example from Start to Finish

We follow one task: **importing articles from a CSV**.

<div class="flow">
  <div class="box">1. Job</div>
  <div class="arrow">&rarr;</div>
  <div class="box">2. dispatch</div>
  <div class="arrow">&rarr;</div>
  <div class="box">3. jobs</div>
  <div class="arrow">&rarr;</div>
  <div class="box">4. Worker</div>
  <div class="arrow">&rarr;</div>
  <div class="box">5. Result</div>
</div>

<div class="tip-box">
The next five steps use the same job: <code>ProcessArticleImport</code>.
</div>

---

## Step 1: Create the Job Class

```bash
php artisan make:job ProcessArticleImport
```

```php
class ProcessArticleImport implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;               // at most 3 attempts
    public array $backoff = [10, 60];    // wait 10 seconds, then 60 seconds
    public int $timeout = 60;            // cancel if it runs over 60 seconds

    public function __construct(public string $path) {}   // carry the path, not the file contents

    public function handle(): void
    {
        $rows = array_map('str_getcsv', file(Storage::path($this->path), FILE_IGNORE_NEW_LINES));
        $header = array_shift($rows);

        foreach ($rows as $row) {
            $data = array_combine($header, $row);
            Article::updateOrCreate(['slug' => $data['slug']], ['title' => $data['title']]);
        }
    }
}
```

---

## Step 2: The Controller Sends the Job

```php
public function store(Request $request)
{
    $request->validate(['file' => ['required', 'file', 'mimes:csv,txt']]);

    $path = $request->file('file')->store('imports');   // save the file first

    ProcessArticleImport::dispatch($path);               // hand the job to the queue

    return back()->with('success', 'The import is being processed in the background.');
}
```

- The controller only saves the file and sends the job, then responds right away
- The validate-and-save loop lives in `handle()` and has **not run yet**

---

## Step 3: The Job Waits in the `jobs` Table

`dispatch()` only writes one row. No article has been imported yet.

| id | queue | payload (short) | attempts | reserved_at |
|---|---|---|---|---|
| 1 | default | `{"displayName":"App\\Jobs\\ProcessArticleImport", ... "path":"imports/abc.csv"}` | 0 | NULL |

- `payload`: the job class name and the data it carries (file path)
- `attempts = 0`: never tried
- `reserved_at = NULL`: no worker has picked it up

<div class="warn-box">
Without a worker, these rows pile up. Tickets keep growing, but no laundry gets done.
</div>

---

## Step 4: A Worker Executes the Job

```bash
php artisan queue:work
```

```text
  2026-10-21 10:00:00 App\Jobs\ProcessArticleImport ........ RUNNING
  2026-10-21 10:00:07 App\Jobs\ProcessArticleImport ... 7s DONE
```

1. The worker takes the row from `jobs`, sets `reserved_at`, and `attempts` becomes 1
2. It rebuilds the job object from `payload`, then calls `handle()`
3. On success the row is deleted from `jobs`. The articles are now in the database

<div class="term-box">
<b>Worker:</b> a long-running PHP process that takes jobs one by one and runs their <code>handle()</code>.
</div>

---

## Step 5: When the Job Fails

<svg viewBox="0 0 1000 380" width="100%" style="display:block;margin:0 auto;max-height:440px" font-family="Helvetica Neue, Arial, sans-serif" font-size="22">
<defs>
<marker id="l1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#1e293b"/></marker>
<marker id="l2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="l3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#dc2626"/></marker>
<marker id="l4" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#ca8a04"/></marker>
</defs>
<rect x="130" y="120" width="160" height="76" rx="12" fill="#1d4ed8"/>
<text x="210" y="168" text-anchor="middle" fill="#fff" font-size="26" font-weight="bold">pending</text>
<rect x="470" y="120" width="160" height="76" rx="12" fill="#1d4ed8"/>
<text x="550" y="168" text-anchor="middle" fill="#fff" font-size="26" font-weight="bold">reserved</text>
<rect x="790" y="20" width="190" height="70" rx="12" fill="#dcfce7" stroke="#16a34a" stroke-width="3"/>
<text x="885" y="64" text-anchor="middle" fill="#166534" font-size="26" font-weight="bold">done</text>
<rect x="770" y="226" width="220" height="70" rx="12" fill="#fee2e2" stroke="#dc2626" stroke-width="3"/>
<text x="880" y="270" text-anchor="middle" fill="#991b1b" font-size="24" font-weight="bold">failed_jobs</text>
<rect x="470" y="280" width="160" height="70" rx="12" fill="#fef9c3" stroke="#ca8a04" stroke-width="3"/>
<text x="550" y="324" text-anchor="middle" fill="#854d0e" font-size="26" font-weight="bold">retry</text>
<line x1="12" y1="158" x2="126" y2="158" stroke="#1e293b" stroke-width="3" marker-end="url(#l1)"/>
<text x="12" y="142" font-size="20">dispatch()</text>
<line x1="294" y1="158" x2="466" y2="158" stroke="#1e293b" stroke-width="3" marker-end="url(#l1)"/>
<text x="380" y="144" text-anchor="middle" font-size="20">worker picks up</text>
<line x1="634" y1="136" x2="786" y2="70" stroke="#16a34a" stroke-width="3" marker-end="url(#l2)"/>
<text x="690" y="96" text-anchor="end" fill="#16a34a" font-size="22">success</text>
<line x1="634" y1="180" x2="766" y2="240" stroke="#dc2626" stroke-width="3" marker-end="url(#l3)"/>
<text x="758" y="268" text-anchor="end" fill="#dc2626" font-size="20">out of attempts</text>
<line x1="550" y1="200" x2="550" y2="276" stroke="#ca8a04" stroke-width="3" marker-end="url(#l4)"/>
<text x="538" y="244" text-anchor="end" fill="#854d0e" font-size="20">failed, attempts left</text>
<path d="M466 315 L210 315 L210 200" fill="none" stroke="#ca8a04" stroke-width="3" marker-end="url(#l4)"/>
<text x="338" y="302" text-anchor="middle" fill="#854d0e" font-size="20">backoff over</text>
<text x="990" y="372" text-anchor="end" font-size="20" fill="#64748b" font-family="monospace">$tries = 3, $backoff = [10, 60]</text>
</svg>

---

## Step 5: Fail, Retry, then `failed_jobs`

```text
  App\Jobs\ProcessArticleImport ........ RUNNING
  App\Jobs\ProcessArticleImport ... 1s FAIL     <- attempt 1, wait 10 seconds
  App\Jobs\ProcessArticleImport ........ RUNNING
  App\Jobs\ProcessArticleImport ... 1s FAIL     <- attempt 2, wait 60 seconds
  App\Jobs\ProcessArticleImport ........ RUNNING
  App\Jobs\ProcessArticleImport ... 1s FAIL     <- attempt 3 = $tries, goes to failed_jobs
```

```bash
php artisan queue:failed         # list failed jobs, with the exception
php artisan queue:retry all      # run them again after fixing the cause
php artisan queue:flush          # delete the failed job records
```

---

## Summary of One Job's Flow

<div class="flow">
  <div class="box">make:job</div>
  <div class="arrow">&rarr;</div>
  <div class="box">dispatch()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">row in jobs</div>
  <div class="arrow">&rarr;</div>
  <div class="box">queue:work</div>
  <div class="arrow">&rarr;</div>
  <div class="box">handle()</div>
</div>

<div class="cols">
<div>

**Success**
- the `jobs` row is deleted
- the data is saved

</div>
<div>

**Failure**
- retry per `$tries` and `$backoff`
- exhausted: moves to `failed_jobs`

</div>
</div>

---

## `sync` vs `database`: Who Waits?

<svg viewBox="0 0 1000 250" width="100%" style="display:block;margin:0 auto;max-height:340px" font-family="Helvetica Neue, Arial, sans-serif" font-size="19">
<defs>
<marker id="s1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
</defs>
<text x="20" y="76" font-size="23" font-weight="bold" fill="#dc2626">sync</text>
<rect x="200" y="45" width="600" height="50" rx="6" fill="#fee2e2" stroke="#dc2626" stroke-width="2"/>
<text x="500" y="76" text-anchor="middle" fill="#991b1b">job runs in place, the user waits</text>
<line x1="800" y1="95" x2="800" y2="108" stroke="#dc2626" stroke-width="2"/>
<text x="800" y="126" text-anchor="middle" font-size="17" fill="#dc2626">response arrives only now</text>
<text x="20" y="166" font-size="23" font-weight="bold" fill="#16a34a">database</text>
<rect x="200" y="140" width="76" height="50" rx="6" fill="#dcfce7" stroke="#16a34a" stroke-width="2"/>
<text x="238" y="170" text-anchor="middle" font-size="17" fill="#166534">response</text>
<text x="238" y="212" text-anchor="middle" font-size="17" fill="#16a34a">user is free</text>
<rect x="420" y="140" width="380" height="50" rx="6" fill="#eff6ff" stroke="#1d4ed8" stroke-width="2"/>
<text x="610" y="171" text-anchor="middle" fill="#1e3a8a">worker runs the job in the background</text>
<line x1="200" y1="232" x2="960" y2="232" stroke="#64748b" stroke-width="2.5" marker-end="url(#s1)"/>
<text x="960" y="222" text-anchor="end" font-size="17" fill="#64748b">time</text>
</svg>

<div class="warn-box">
If <code>QUEUE_CONNECTION=sync</code> in <code>.env</code>, the job runs inside the request. There is no real queue.
</div>

---

## Rules for Designing Jobs

<div class="cols">
<div>

**Do**
- Make it **idempotent** (`updateOrCreate`)
- Carry an ID or path, not big data
- Set `$tries`, `$backoff`, `$timeout`
- Use `->afterCommit()` if the job depends on data in a transaction

</div>
<div>

**Avoid**
- `request()`, session, or the logged-in user inside `handle()`: none exist in the background
- File contents in the job payload
- Relying on job order without designing for it
- Letting jobs fail with nobody watching

</div>
</div>

---

## Keeping the User Informed

- **Status column** (`pending`, `processing`, `done`, `failed`) updated by the job and shown on a page
- **Notification** (email or in-app) when the job finishes or fails
- **Job batch**: `Bus::batch($jobs)->dispatch()` tracks many jobs, `$batch->progress()` gives a percentage

<div class="ref-link">Laravel docs: <code>Queues &rarr; Job Batching</code></div>

---

<!-- _class: divider -->

# Part 6
## Queues in Production

---

## Setup: `.env` and the Queue Tables

```bash
# .env
QUEUE_CONNECTION=database
```

| Driver | Storage | Good for |
|---|---|---|
| `sync` | none, the job runs in place | development, testing |
| `database` | the `jobs` table | small to medium projects |
| `redis` | Redis (in-memory) | high traffic |

- A new Laravel project already has migrations for `jobs` and `failed_jobs`
- Older projects: `php artisan make:queue-table`, then `php artisan migrate`
- After changing `.env`: `php artisan config:clear` (or `config:cache` in production)

---

## `retry_after` vs `--timeout`

```php
// config/queue.php
'database' => [
    'driver' => 'database',
    'retry_after' => 90,    // after 90 seconds a job is seen as stuck and another worker takes it
],
```

<div class="cols">
<div>

**Right**
- `--timeout=60`
- `retry_after = 90`
- the job is stopped before it counts as stuck

</div>
<div>

**Wrong**
- `--timeout=120`
- `retry_after = 90`
- the job is still running, but a second worker takes it: **processed twice**

</div>
</div>

<div class="tip-box">
Rule: <code>timeout</code> must be smaller than <code>retry_after</code>.
</div>

---

## `queue:work` Options Worth Knowing

| Option | Purpose |
|---|---|
| `--queue=high,default` | process `high` first, then `default` |
| `--tries=3` | max attempts per job |
| `--timeout=60` | seconds limit per job |
| `--sleep=3` | seconds to wait when the queue is empty |
| `--max-jobs=1000` | stop after n jobs (memory is released) |
| `--max-time=3600` | stop after n seconds |
| `--stop-when-empty` | stop when the queue is empty |

<div class="tip-box">
A worker that stops itself (<code>--max-time</code>, <code>--max-jobs</code>) is started again by Supervisor, so memory does not pile up.
</div>

---

## Supervisor: Keeping Workers Alive

`queue:work` in a terminal dies when the terminal closes or the server restarts. Supervisor starts it again automatically.

```ini
; /etc/supervisor/conf.d/laravel-worker.conf
[program:laravel-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/app/artisan queue:work --sleep=3 --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/app/storage/logs/worker.log
stopwaitsecs=3600
```

---

## Activating Supervisor

```bash
sudo apt-get install supervisor

sudo supervisorctl reread                      # read the new config file
sudo supervisorctl update                      # apply it
sudo supervisorctl start "laravel-worker:*"    # start all workers
```

- `numprocs=2`: two workers run at the same time
- `autorestart=true`: a worker dies, Supervisor starts it again
- `stopwaitsecs`: must be larger than the longest job, so jobs are not cut off

<div class="ref-link">Laravel docs: <code>Queues &rarr; Supervisor Configuration</code></div>

---

## Deploy: Restart the Workers

Workers live long and keep the old code in memory. After a deploy, new code is not picked up until the workers restart.

```bash
git pull
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan queue:restart     # workers stop after their current job finishes
```

<div class="tip-box">
<code>queue:restart</code> does not cut off a running job. Workers stop cleanly, then Supervisor starts them with the new code.
</div>

---

## Level Up: Redis and Horizon

- Start with `database`. Move to `redis` when traffic or job volume is high
- Set `QUEUE_CONNECTION=redis` and prepare a Redis server
- **Horizon**: dashboard and configuration for Redis queues (metrics, failed jobs, automatic worker count)
- Horizon is Redis only, and Supervisor keeps it alive too (`php artisan horizon`)

<div class="ref-link">Laravel docs: <code>Horizon</code> and <code>Queues &rarr; Supervisor Configuration</code></div>

---

## Applying This to Simple POS

In the jobsheet you apply these concepts to Simple POS:

1. A sales report with a date filter, computed in the database
2. Report export to CSV (streaming), Excel, and PDF
3. Measuring memory for `get()` vs `lazyById()` on 50,000 rows
4. A product import from CSV that validates per row and is safe to repeat
5. Moving the import to a queued job with `$tries` and `backoff`, then tracing a failed job

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos-ch08</code></div>

---

## Summary (1/4): ETL, Batch, and Reports

- ETL: extract, transform, load. Import and export are two-way ETL
- Batching cuts round trips (`array_chunk` + `insert`, `chunkById`)
- Idempotent import: `updateOrCreate()` or `upsert()` (with a unique index)
- Reports: `whereBetween`, `startOfDay()`/`endOfDay()`, compute in the database, add an index

---

## Summary (2/4): Memory and Formats

- `get()` loads every row. Read with `lazyById()`, update with `chunkById()`
- Measure with `memory_get_peak_usage()`, do not guess
- CSV for raw data, Excel for analysis, PDF for short documents
- Bad rows on import: skip and log, or abort for data that must be complete

---

## Summary (3/4): The Journey of a Job

- `make:job`, then `dispatch()` only writes a row to the `jobs` table
- `queue:work` takes the row and runs `handle()`
- Failure: retry per `$tries` and `$backoff`, exhausted goes to `failed_jobs`, then `queue:retry`
- Idempotent jobs, carry an ID or path, never depend on the request or session

---

## Summary (4/4): Queues in Production

- `QUEUE_CONNECTION=database` (or `redis`), the `jobs` table comes from a migration
- `timeout` must be smaller than `retry_after`
- Supervisor keeps `queue:work` alive (`numprocs`, `autorestart`, `stopwaitsecs`)
- Deploy: `queue:restart`. Large scale: Redis and Horizon

---

<!-- _class: lead -->

# References & Discussion

Official Laravel docs (Queues, Horizon, File Storage, HTTP Responses, Eloquent Chunking), docs.laravel-excel.com, and laravel-dompdf

Full code: `github.com/se-polinema/simple-pos-ch08`

**Next meeting:** Designing and Building a REST API
