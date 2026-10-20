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

1. Explain the **ETL** pattern and **batch processing**, and use them to process large amounts of data
2. Build a report that summarizes data over a date range, and pick the right techniques for **large datasets**
3. Understand why **memory** runs out, and choose memory-friendly ways to read data
4. Choose between **CSV, Excel, and PDF** for a need, and know the libraries that produce them
5. Recognize when a task should be handed off to a **queue**, and make it resilient to failure

<div class="tip-box">
These slides cover the concepts. Applying reports, export/import, and queues to Simple POS is done in the lab jobsheet.
</div>

---

## Meeting Map: Think of a Restaurant Kitchen

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
Picture a restaurant kitchen. Raw ingredients come in (<b>extract</b>), get cooked into dishes (<b>transform</b>), and are served at the table (<b>load</b>). When orders pile up, the kitchen does not make guests stand next to the stove: they get a table number, and the food is brought over later. That is the big picture of this meeting.
</div>

---

<!-- _class: divider -->

# Part 1
## ETL and Batch Processing

---

## Four Basic Terms

<div class="term-box">
<b>ETL (Extract, Transform, Load):</b> a common pattern: take raw data, reshape it, then store or present it in a new form.
</div>

<div class="term-box">
<b>Batch Processing:</b> processing lots of data together in groups, not one record at a time.
</div>

<div class="term-box">
<b>Queue:</b> a mechanism for handing heavy work to a separate process that runs it in the background, instead of during the user's request.
</div>

<div class="term-box">
<b>Import/Export:</b> bringing data in from an external format (CSV, Excel) into the database, or sending it out to an external format (CSV, Excel, PDF) to be read outside the app.
</div>

---

## ETL: Three Stages That Always Show Up

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

Almost all data processing follows this order, for imports and exports alike. Separating the stages keeps each part easy to test and replace: the source can change, the validation rules can change, the destination can change.

---

## Import and Export Are Two-Way ETL

| | Extract | Transform | Load |
|---|---|---|---|
| **Import** | read a CSV / Excel file | validate each row, map columns | save to the database |
| **Export** | query the database | pick columns, format dates and numbers | write CSV / Excel / PDF |

<div class="tip-box">
Useful questions for every import or export feature: where does the data come from (extract), what must be cleaned or changed (transform), and where does the result go (load)?
</div>

---

## Batch: One by One vs One Truck

A courier who delivers one parcel per trip loses to a courier who carries a full truckload. The same applies to databases: every query pays the cost of a trip (round trip) to the database.

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

<div class="warn-box">
A bulk <code>insert()</code> does not fill <code>created_at</code>/<code>updated_at</code> automatically and does not fire model events. Fill the timestamps yourself if you need them.
</div>

---

## Batch Size and Reading in Batches

<div class="cols">
<div>

**Batch too small**
- Too many round trips
- Slow, like a motorbike courier

**Batch too large**
- Memory balloons
- One failure fails many rows

</div>
<div>

**Reading in batches**

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
A reasonable starting point: hundreds to a thousand rows per batch, then measure. Wrap each batch in <code>DB::transaction()</code> if a batch must succeed or fail as a whole.
</div>

---

## Idempotent: Safe to Run Many Times

What if the same import file is uploaded twice? Without a safeguard, every row is recorded twice. Think of an attendance sheet: if your name is already there, the clerk updates your line instead of writing the same name again.

```php
Article::updateOrCreate(
    ['slug' => $row['slug']],     // lookup key
    ['title' => $row['title']],   // values to update
);

// batch version: one query for many rows
Article::upsert($batch, ['slug'], ['title']);
```

<div class="warn-box">
<code>upsert()</code> requires a <b>unique index</b> on the key column. Without it, the database can't tell which rows count as the same.
</div>

---

<!-- _class: divider -->

# Part 2
## Reports and Large Datasets

---

## List vs Report: A Pile of Receipts vs a Month-End Summary

A list page is like a pile of receipts in the cash drawer: everything is there, but you have to add it up yourself. A report page is like the month-end summary: already totaled and ready to read. The question is narrower but heavier: "what is the total of X over a given period".

```php
$totalWords = Article::whereBetween('published_at', [
    $from, $to,
])->sum('word_count');
```

`whereBetween` keeps rows whose date falls between two bounds, then `sum()` adds up one column of the filtered result.

---

## Common Pitfall: The Day That Gets Cut Off

<div class="warn-box">
A filter of "August 1 to August 31" taken literally means "up to 00:00:00 on the 31st". Every transaction made during the 31st disappears, like a shop that tallies August revenue but stops counting the moment it opens its doors on the last day.
</div>

```php
$from = $request->date('from')->startOfDay();
$to = $request->date('to')->endOfDay();
```

`startOfDay()` turns the start date into 00:00:00, and `endOfDay()` turns the end date into 23:59:59, so the whole last day is counted.

---

## The Day-Boundary Pitfall on a Timeline

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

## Calculate in the Database, Not in PHP

Imagine asking for your account balance. You could ask the bank to send every transaction and add them up yourself, or simply ask the bank for the balance. The database is the bank.

```php
// heavy: every row is loaded into memory and summed in PHP
$total = Article::all()->sum('word_count');

// light: the database does the summing
$total = Article::sum('word_count');

// summary per author: the 5 authors with the most words
Article::selectRaw('author_id, COUNT(*) AS total, SUM(word_count) AS total_words')
    ->groupBy('author_id')
    ->orderByDesc('total_words')
    ->limit(5)
    ->get();
```

---

## Stored Totals Are Not Recomputed

Meeting 6 made the point: a derived value like a total must not be trusted when it comes from client input, and must be recomputed on the server when the data is created. Once it is stored correctly, a report can use it as is. It is like the total printed on a receipt: when summarizing, you add up the receipt totals instead of re-checking every item on them.

```php
// word_count is computed once when the article is saved
$article->word_count = str_word_count($article->body);

// the report just sums the stored column
$totalWords = Article::whereBetween('published_at', [$from, $to])
    ->sum('word_count');
```

<div class="tip-box">
Recomputing a value from raw data (for example counting the words of every article body) each time the report opens burdens the server for no reason: the number has been correct since the article was saved.
</div>

---

## Toolbox for Large Datasets

| Technique | Use when | Notes |
|---|---|---|
| `paginate()` | showing a list to the user | one page per request |
| `chunkById()` | processing or updating many rows | memory per chunk, safe when rows change |
| `lazyById()` | reading many rows like a `foreach` | flat memory, simple code |
| `cursor()` | reading one long query | convenient, but less safe if data changes |
| `select([...])` | only some columns are needed | each model gets smaller |
| `with()` | using relations inside a loop | avoids N+1 queries |
| index | filtering or sorting on a column | query doesn't scan the whole table |

---

## Index: A Table of Contents for a Table

The date filter on the report runs again and again. Without an index on that column, the database has to read the whole table row by row, like finding one topic by flipping through the book page by page. With an index, the database jumps straight to the right page through the table of contents.

```php
Schema::table('articles', function (Blueprint $table) {
    $table->index('published_at');
});
```

```sql
EXPLAIN SELECT * FROM articles WHERE published_at BETWEEN '2026-08-01' AND '2026-08-31';
-- type: ALL    = scans the whole table (slow)
-- type: range  = uses the index (fast)
```

<div class="ref-link">Recall Meeting 4: index strategy and <code>EXPLAIN</code></div>

---

<!-- _class: divider -->

# Part 3
## Memory Management

---

## Why Memory Runs Out

PHP has a `memory_limit` (commonly 128 MB). Every row Eloquent loads becomes a full **model object** with attributes and metadata, much bigger than the raw data. Picture a workbench: `get()` puts every document on the bench at once. Once there are thousands of documents, the bench is full and work stops.

<div class="warn-box">
Example measurement from the jobsheet: reading 52,500 transactions with <code>get()</code> uses about 96 MB, while <code>lazyById()</code> uses only about 38 MB. Add a bit more data and <code>get()</code> hits <code>memory_limit</code>: the error <i>Allowed memory size exhausted</i>.
</div>

---

## `get` vs `chunk` vs `lazy` vs `cursor`

| Way | Memory | Queries | Fits |
|---|---|---|---|
| `get()` | all rows at once | 1 | small data, shown on screen |
| `chunkById(n)` | n rows per turn | many (per chunk) | bulk updates, per-batch processing |
| `lazyById(n)` | n rows per turn | many (per chunk) | exports, a plain `foreach` |
| `cursor()` | one row per turn | 1 | a one-time read, data doesn't change |

<div class="tip-box">
Rule of thumb: if the data can reach hundreds of thousands of rows or more, don't <code>get()</code>. Use <code>lazyById()</code> to read and <code>chunkById()</code> to update.
</div>

---

## Bucket vs Tap: Two Ways to Send a Big File

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

The tap way: fetch data in small chunks, write it to the output, then forget it.

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

`lazyById()` reads the database in chunks, and `streamDownload()` sends each row as it goes, so memory stays flat.

<div class="ref-link">Laravel docs: <code>HTTP Responses &rarr; File Downloads</code> and <code>Eloquent &rarr; Chunking / lazyById()</code></div>

---

## Don't Guess, Measure

```php
gc_collect_cycles();
memory_reset_peak_usage();      // restart the peak counter from zero

foreach (Article::lazyById() as $a) {
    // ... work ...
}

printf("peak %.1f MB\n", memory_get_peak_usage() / 1048576);
```

- `memory_get_peak_usage()` records the highest point of memory use
- `memory_reset_peak_usage()` (PHP 8.2+) makes each measurement stand on its own
- Compare two approaches on the same data, and write the numbers down

<div class="tip-box">
Optimization without measurement is just a guess. Numbers before and after make the decision "use <code>lazyById()</code>" defensible.
</div>

---

## The `chunk()` Trap: Skipped Rows

```php
// DANGEROUS: filters by 'draft', then changes 'draft' itself
Article::where('status', 'draft')->chunk(100, function ($articles) {
    foreach ($articles as $a) {
        $a->update(['status' => 'published']);
    }
});
```

Every updated row drops out of the filter, so the list shifts and the next chunk skips some rows. Like a ticket queue: when served people leave right away, everyone behind them moves up a number.

<div class="tip-box">
The fix is <code>chunkById(100, ...)</code>: it uses the last <code>id</code> as the page marker instead of a position, so it is safe even when rows change.
</div>

---

<!-- _class: divider -->

# Part 4
## Formats and Libraries: CSV, Excel, PDF

---

## Choosing a Format: CSV, Excel, or PDF

| | CSV | Excel (.xlsx) | PDF |
|---|---|---|---|
| **Best for** | raw data, exchange between systems | analysis, financial reports | reading or printing, not processed again |
| **Format** | plain text | zip of XML, supports styling | fixed document |
| **Memory** | very light (stream) | medium (library handles chunks) | heavy (whole document in memory) |
| **Library** | built-in PHP (`fputcsv`) | Laravel Excel | DomPDF |
| **Big data** | yes | yes (use `FromQuery`) | no, limit the rows |

---

## CSV: Simple but Full of Traps

- **Delimiter**: Excel with an Indonesian locale often uses a semicolon (`;`) instead of a comma
- **Quoting**: values containing a comma or newline must be wrapped in quotes (`fputcsv` handles this)
- **Encoding**: UTF-8 files from Excel often start with an invisible character (**BOM**) that breaks the first header
- **No types**: every value is text, type validation is still your job

<div class="warn-box">
If every row is suddenly rejected during an import, check the header first: the delimiter and the BOM are the prime suspects.
</div>

---

## Laravel Excel: Export

A spreadsheet library handles the complicated `.xlsx` format. You only describe the content through small interfaces (`concerns`).

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
By default, <code>WithValidation</code> stops the import at the first invalid row. To skip bad rows and collect them, add <code>SkipsOnFailure</code>.
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

return $pdf->download('articles.pdf');
```

- The view is plain Blade, so `@foreach`, `{{ }}`, and basic CSS work right away
- `download()` forces a file download, `stream()` shows it in the browser

<div class="warn-box">
DomPDF supports only part of CSS and holds the whole document in memory. Use it for summaries and small tables, not for tens of thousands of rows: for big data choose CSV or Excel.
</div>

---

## Import: Like a Cashier Scanning Groceries

Import goes the other way: read a CSV file, then turn each of its rows into a new database row. Think of a cashier scanning groceries. If one barcode is damaged, the cashier sets that item aside and keeps scanning the rest, instead of sending every customer home.

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
        continue; // skip this row, move on to the next one
    }

    Article::updateOrCreate(['slug' => $data['slug']], $validator->validated());
}
```

---

## What to Do with a Bad Row?

| Strategy | How it works | Fits |
|---|---|---|
| **Skip without a trace** | bad rows are skipped with no record | almost never: data vanishes and nobody knows |
| **Skip and log** | bad rows are skipped, their row numbers and reasons saved | general imports (recommended): the user can fix the file |
| **Abort everything** | one bad row cancels the whole import (`DB::transaction`) | financial data or data that must stay whole |

<div class="tip-box">
Like the cashier earlier: the item with the damaged barcode is set aside, <b>and</b> noted on a "could not scan" slip so the customer knows what to sort out.
</div>

---

<!-- _class: divider -->

# Part 5
## Queues: Work in the Background

---

## Two Ways to Process Work

<div class="cols">
<div>

**Directly (inside the request)**
- The user waits until it finishes
- If it fails, the user knows right away
- Fits short tasks whose result is needed immediately

</div>
<div>

**Via a queue (job)**
- Instant response, work runs in the background
- The user does not wait in front of the browser
- Fits heavy tasks or tasks with unpredictable duration

</div>
</div>

<div class="tip-box">
Laundry analogy: one T-shirt, you gladly wait at the counter. A whole sack, you drop it off, get a ticket, and go home. Importing a few dozen rows is one T-shirt. Importing thousands of rows is a whole sack, and HTTP requests have a timeout.
</div>

---

## A Queue = A Laundry Drop-Off

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

## The Journey of a Job

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

## The Job Flow in Laravel

<div class="flow">
  <div class="box">Controller</div>
  <div class="arrow">&rarr;</div>
  <div class="box">dispatch() job</div>
  <div class="arrow">&rarr;</div>
  <div class="box">jobs table</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Worker (queue:work)</div>
</div>

```bash
php artisan make:job ProcessArticleImport
```

```php
ProcessArticleImport::dispatch($csvPath);

return back()->with('success', 'The import is being processed in the background.');
```

The controller only saves the file and sends one job to the queue, then responds to the user right away. The real work (the validation and saving loop) moves into the `handle()` method of that job class.

---

## Worker: The Person Who Works Through the Ticket Pile

<div class="term-box">
<b>Worker:</b> a separate PHP process that keeps running, takes jobs from the <code>jobs</code> table one at a time, and runs each one's <code>handle()</code> method.
</div>

```bash
php artisan queue:work
```

Without a worker, jobs just pile up in the `jobs` table. It is a laundry with no one to wash: tickets keep growing, but no laundry gets done, because `dispatch()` only stores the ticket, it does not wash anything.

<div class="warn-box">
A worker is a long-lived process, so it does <b>not</b> pick up new code automatically. After changing a job class, restart the worker (on a production server: <code>php artisan queue:restart</code>).
</div>

---

## Queue Drivers and Workers in Production

| Driver | Storage | Fits |
|---|---|---|
| `sync` | none: the job runs right there | development and testing |
| `database` | the `jobs` table | small to medium projects, easiest setup |
| `redis` | Redis (in-memory) | high traffic, high throughput needs |

In production, `queue:work` must **stay alive**. A program like **Supervisor** watches the worker and starts it again when it dies, like a shift supervisor making sure the washer is always at their post.

<div class="ref-link">Laravel docs: <code>Queues &rarr; Supervisor Configuration</code></div>

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
If <code>QUEUE_CONNECTION</code> in <code>.env</code> says <code>sync</code>, the job never enters a real queue. It is like a clerk telling you to wait until the laundry is dry even though you are already holding a ticket.
</div>

---

## A Job That Survives Failure

A job runs in the background, so no user sees its errors. That is why a job must be designed to fail gracefully.

```php
class ProcessArticleImport implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;               // at most 3 attempts
    public array $backoff = [10, 60];    // wait 10 seconds, then 60 seconds
    public int $timeout = 120;           // cancel if it runs longer than 120 seconds
}
```

```bash
php artisan queue:failed        # list failed jobs
php artisan queue:retry all     # run them all again
php artisan queue:flush         # delete the failed job records
```

<div class="ref-link">Laravel docs: <code>Queues &rarr; Dealing With Failed Jobs</code></div>

---

## Rules for Designing a Job

<div class="cols">
<div>

**Do**
- Make jobs **idempotent**: safe to retry (`updateOrCreate`)
- Carry an ID or file path, not big data
- Set `$tries`, `$backoff`, and `$timeout`
- Use `->afterCommit()` when the job depends on data inside a database transaction

</div>
<div>

**Avoid**
- Using `request()`, the session, or the logged-in user inside `handle()`: in the background, none of them exist
- Storing a whole file's contents in the job payload
- Relying on job order without designing for it
- Letting jobs fail with nobody watching

</div>
</div>

---

## Keeping the User Informed

A user who uploads a file and sees "being processed" wants to know when it is done. The options:

- **A status column** on the import table (`pending`, `processing`, `done`, `failed`) updated by the job and shown on the page
- **A notification** (email or an in-app notification) when the job finishes or fails
- **A job batch**: `Bus::batch($jobs)->dispatch()` tracks many jobs at once, and `$batch->progress()` gives the percentage done

<div class="ref-link">Laravel docs: <code>Queues &rarr; Job Batching</code></div>

---

## Signs a Task Belongs in a Queue

- Its duration cannot be predicted in advance, since it depends on the size of the data
- The user does not need to see the result immediately on the same page
- It calls a slow external service, such as sending email or calling a third-party API
- It can be retried safely (idempotent)

<div class="warn-box">
A report that is opened and read right on the page is usually still better done directly, because the user is waiting for the result at that moment. A queue is not the answer to every heavy task, only to those that do not need an instant result.
</div>

---

## Applying It to Simple POS

You will apply this meeting's concepts directly to Simple POS in the lab jobsheet:

1. A sales report with a date filter, computed in the database
2. Export the report to CSV (streaming), Excel (Laravel Excel), and PDF (DomPDF)
3. Measure memory of `get()` vs `lazyById()` on 50,000 rows
4. A product import from CSV that validates per row and is safe to repeat
5. Move the import to a queued job with `$tries` and `backoff`, then trace the failed jobs

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos-ch08</code></div>

---

## Summary (1/3): ETL, Batch, and Large Datasets

- ETL splits data processing into extract, transform, load; import and export are two-way ETL
- Batching cuts database round trips (`array_chunk` + `insert`, `chunkById`); batch size should be measured
- A good import is idempotent: `updateOrCreate()` or `upsert()` (with a unique index)
- Reports summarize through `whereBetween`, and `startOfDay()`/`endOfDay()` keep the last day from being cut off
- Calculate in the database (`sum`, `groupBy`), not in PHP; an index speeds up filters

---

## Summary (2/3): Memory and Formats

- Memory runs out because `get()` loads every row as an object; use `lazyById()` to read and `chunkById()` to update
- `chunk()` can skip rows when the filter column is also updated: use `chunkById()`
- Measure with `memory_get_peak_usage()`, don't guess
- CSV for raw data, Excel (Laravel Excel) for analysis, PDF (DomPDF) for compact documents
- Bad rows during an import: skip and log is the common choice, abort for data that must stay whole

---

## Summary (3/3): Queues

- Work with unpredictable duration or large volume goes to a queue: instant response, work follows
- `dispatch()` only stores the job in the `jobs` table; the worker (`queue:work`) runs it
- Resilient jobs: `$tries`, `$backoff`, `$timeout`, and the `failed_jobs` table with `queue:retry`
- Design idempotent jobs, carry an ID or path (not big data), and don't depend on the request or session
- In production, Supervisor keeps the worker alive and it is restarted on deploy

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Queues, File Storage, HTTP Responses, Eloquent Chunking), docs.laravel-excel.com, and laravel-dompdf

Full code: `github.com/se-polinema/simple-pos-ch08`

**Next meeting:** Designing and Building a REST API
