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

From summary reports and CSV files to heavy work handed off to the background

---

## What You'll Learn

1. Build a report that summarizes data over a date range, and avoid a common pitfall when filtering by date

2. Export data to CSV without overloading server memory, and import CSV while handling bad rows without stopping the whole process

3. Recognize when a job should be handed off to a **queue** instead of being done while the user waits

<div class="tip-box">
These slides cover the concepts. Applying reports, export/import, and queues to Simple POS is done in the lab jobsheet.
</div>

---

## Meeting Map: Think of a Restaurant Kitchen

<div class="flow">
  <div class="box">Raw data</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Report</div>
  <div class="arrow">&rarr;</div>
  <div class="box">CSV out / in</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Queue</div>
</div>

<div class="tip-box">
Picture a restaurant kitchen. Raw ingredients come in (<b>extract</b>), get cooked into dishes (<b>transform</b>), and are served at the table (<b>load</b>). When orders pile up, the kitchen does not make guests stand next to the stove: they get a table number, and the food is brought over later. That is the big picture of this meeting.
</div>

---

<!-- _class: divider -->

# Part 1
## Reports and Data Aggregation

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
<b>Import/Export:</b> bringing data in from an external format (CSV, Excel) into the database, or sending it out to an external format to be read outside the app.
</div>

---

## List vs Report: A Pile of Receipts vs a Month-End Summary

A list page is like a pile of receipts in the cash drawer: everything is there, but you have to add it up yourself. A report page is like the month-end summary: already totaled and ready to read. The question is narrower but heavier: "what is the total of X over a given period".

```php
$totalKata = Article::whereBetween('published_at', [
    $from, $to,
])->sum('word_count');
```

`whereBetween` keeps rows whose date falls between two bounds, then `sum()` adds up one column of the filtered result. The database does the adding, so Laravel does not need to load thousands of rows into memory just to total them.

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

<svg viewBox="0 0 1000 270" width="100%" style="display:block;margin:0 auto;max-height:400px" font-family="Helvetica Neue, Arial, sans-serif" font-size="17">
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
<text x="500" y="84" text-anchor="middle" fill="#dc2626" font-size="16">transactions on the 31st are lost</text>
<text x="300" y="164" text-anchor="middle" fill="#64748b" font-size="15">00:00</text>
<text x="700" y="164" text-anchor="middle" fill="#64748b" font-size="15">24:00</text>
<text x="170" y="196" text-anchor="middle" fill="#64748b">Aug 30</text>
<text x="500" y="196" text-anchor="middle" fill="#1d4ed8" font-weight="bold">Aug 31</text>
<text x="830" y="196" text-anchor="middle" fill="#64748b">Sep 1</text>
<line x1="40" y1="224" x2="700" y2="224" stroke="#16a34a" stroke-width="7"/>
<line x1="700" y1="212" x2="700" y2="236" stroke="#16a34a" stroke-width="5"/>
<text x="40" y="256" fill="#16a34a" font-weight="bold">With endOfDay(): the filter stops at Aug 31, 23:59:59, the whole day is counted</text>
</svg>

---

## Stored Totals Are Not Recomputed

Meeting 6 made the point: a value like a transaction total must not be trusted when it comes from client input, and must be recomputed on the server when the transaction is created. Once it is stored correctly, a report can use it as is. It is like the total printed on a receipt: when summarizing, you add up the receipt totals instead of re-checking every item on them.

```php
// The report just sums the stored column
$totalPenjualan = Transaction::whereBetween('created_at', [$from, $to])
    ->sum('total');
```

<div class="tip-box">
Recomputing the total from detail rows every time the report opens burdens the server for no reason: the number has been correct since the transaction was created.
</div>

---

<!-- _class: divider -->

# Part 2
## CSV Export and Import

---

## Bucket vs Tap: Two Ways to Send a Big File

<svg viewBox="0 0 1000 310" width="100%" style="display:block;margin:0 auto;max-height:400px" font-family="Helvetica Neue, Arial, sans-serif" font-size="16">
<text x="40" y="28" font-size="19" font-weight="bold" fill="#1d4ed8">Bucket: collect first, send later</text>
<text x="40" y="50" font-size="14" fill="#64748b">get() then build one big string</text>
<line x1="60" y1="60" x2="60" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="60" y1="260" x2="460" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="60" y1="84" x2="460" y2="84" stroke="#dc2626" stroke-width="2" stroke-dasharray="8 6"/>
<text x="458" y="76" text-anchor="end" font-size="14" fill="#dc2626">memory limit</text>
<polyline points="60,250 160,218 260,172 360,124 436,88" fill="none" stroke="#1d4ed8" stroke-width="5"/>
<circle cx="436" cy="88" r="8" fill="#dc2626"/>
<text x="330" y="108" text-anchor="end" font-weight="bold" fill="#dc2626">out of memory</text>
<text x="260" y="288" text-anchor="middle" font-size="14" fill="#64748b">rows processed &rarr;</text>
<text transform="rotate(-90 32 160)" x="32" y="160" text-anchor="middle" font-size="14" fill="#64748b">server memory</text>
<text x="540" y="28" font-size="19" font-weight="bold" fill="#16a34a">Tap: let it flow row by row</text>
<text x="540" y="50" font-size="14" fill="#64748b">lazyById() + streamDownload()</text>
<line x1="560" y1="60" x2="560" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="560" y1="260" x2="960" y2="260" stroke="#1e293b" stroke-width="2"/>
<line x1="560" y1="84" x2="960" y2="84" stroke="#dc2626" stroke-width="2" stroke-dasharray="8 6"/>
<text x="958" y="76" text-anchor="end" font-size="14" fill="#dc2626">memory limit</text>
<polyline points="560,236 660,232 760,237 860,231 936,235" fill="none" stroke="#16a34a" stroke-width="5"/>
<text x="760" y="214" text-anchor="middle" font-weight="bold" fill="#16a34a">stays flat</text>
<text x="760" y="288" text-anchor="middle" font-size="14" fill="#64748b">rows processed &rarr;</text>
<text transform="rotate(-90 532 160)" x="532" y="160" text-anchor="middle" font-size="14" fill="#64748b">server memory</text>
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

## Import: Like a Cashier Scanning Groceries

Import goes the other way: read a CSV file, then turn each of its rows into a new database row. Think of a cashier scanning groceries. If one barcode is damaged, the cashier sets that item aside and keeps scanning the rest, instead of sending every customer home.

<svg viewBox="0 0 1000 285" width="100%" style="display:block;margin:0 auto;max-height:330px" font-family="Helvetica Neue, Arial, sans-serif" font-size="16">
<defs>
<marker id="g1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
<marker id="g2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="g3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#dc2626"/></marker>
</defs>
<text x="40" y="28" font-size="14" fill="#64748b">CSV file: name, category_id, price</text>
<rect x="40" y="44" width="260" height="38" rx="5" fill="#f0fdf4" stroke="#16a34a" stroke-width="2"/>
<text x="56" y="69" font-family="monospace" font-size="15">Kopi Hitam,1,15000</text>
<rect x="40" y="94" width="260" height="38" rx="5" fill="#f0fdf4" stroke="#16a34a" stroke-width="2"/>
<text x="56" y="119" font-family="monospace" font-size="15">Teh Manis,1,10000</text>
<rect x="40" y="144" width="260" height="38" rx="5" fill="#fef2f2" stroke="#dc2626" stroke-width="2"/>
<text x="56" y="169" font-family="monospace" font-size="15">No Category,999,5000</text>
<line x1="304" y1="113" x2="376" y2="113" stroke="#64748b" stroke-width="3" marker-end="url(#g1)"/>
<rect x="380" y="53" width="170" height="120" rx="10" fill="#1d4ed8"/>
<text x="465" y="108" text-anchor="middle" fill="#fff" font-size="21" font-weight="bold">Validator</text>
<text x="465" y="134" text-anchor="middle" fill="#bfdbfe" font-size="15">checks each row</text>
<line x1="554" y1="90" x2="676" y2="78" stroke="#16a34a" stroke-width="3" marker-end="url(#g2)"/>
<line x1="554" y1="140" x2="676" y2="198" stroke="#dc2626" stroke-width="3" marker-end="url(#g3)"/>
<rect x="700" y="50" width="130" height="70" fill="#dcfce7"/>
<ellipse cx="765" cy="120" rx="65" ry="14" fill="#dcfce7" stroke="#16a34a" stroke-width="2.5"/>
<line x1="700" y1="50" x2="700" y2="120" stroke="#16a34a" stroke-width="2.5"/>
<line x1="830" y1="50" x2="830" y2="120" stroke="#16a34a" stroke-width="2.5"/>
<ellipse cx="765" cy="50" rx="65" ry="14" fill="#bbf7d0" stroke="#16a34a" stroke-width="2.5"/>
<text x="765" y="92" text-anchor="middle" font-weight="bold" fill="#166534">database</text>
<text x="860" y="90" font-weight="bold" fill="#16a34a" font-size="18">2 saved</text>
<path d="M690 186 L690 236 L850 236 L850 186" fill="#fef2f2" stroke="#dc2626" stroke-width="3.5"/>
<text x="770" y="218" text-anchor="middle" fill="#dc2626" font-weight="bold">skipped</text>
<text x="870" y="218" font-weight="bold" fill="#dc2626" font-size="18">1 skipped</text>
<text x="500" y="272" text-anchor="middle" font-size="14" fill="#64748b">one bad row does not stop the others</text>
</svg>

---

## Import: Validate Each Row, Skip the Bad Ones

```php
$rows = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
$rows = array_map('str_getcsv', $rows);
$header = array_shift($rows);

foreach ($rows as $row) {
    $validator = Validator::make(array_combine($header, $row), [
        'title' => ['required', 'string'],
        'author_id' => ['required', 'exists:authors,id'],
    ]);

    if ($validator->fails()) {
        continue; // skip this row, move on to the next one
    }

    Article::create($validator->validated());
}
```

<div class="warn-box">
CSV saved from Excel with an Indonesian locale often uses a semicolon (<code>;</code>) as the separator and adds an invisible character (BOM) at the start of the file. The first header then goes unrecognized and every row fails validation. Check the header first if every row is suddenly rejected.
</div>

---

<!-- _class: divider -->

# Part 3
## When to Use a Queue

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

<svg viewBox="0 0 1000 400" width="100%" style="display:block;margin:0 auto;max-height:440px" font-family="Helvetica Neue, Arial, sans-serif" font-size="16">
<defs>
<marker id="q1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#1e293b"/></marker>
<marker id="q2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#16a34a"/></marker>
<marker id="q3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
</defs>
<rect x="70" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="160" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="18">Browser</text>
<text x="160" y="58" text-anchor="middle" fill="#bfdbfe" font-size="14">customer</text>
<rect x="310" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="400" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="18">Controller</text>
<text x="400" y="58" text-anchor="middle" fill="#bfdbfe" font-size="14">laundry clerk</text>
<rect x="550" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="640" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="18">jobs table</text>
<text x="640" y="58" text-anchor="middle" fill="#bfdbfe" font-size="14">ticket rack</text>
<rect x="790" y="12" width="180" height="58" rx="8" fill="#1d4ed8"/>
<text x="880" y="38" text-anchor="middle" fill="#fff" font-weight="bold" font-size="18">Worker</text>
<text x="880" y="58" text-anchor="middle" fill="#bfdbfe" font-size="14">washer</text>
<line x1="160" y1="72" x2="160" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="400" y1="72" x2="400" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="640" y1="72" x2="640" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="880" y1="72" x2="880" y2="388" stroke="#94a3b8" stroke-width="2" stroke-dasharray="6 6"/>
<line x1="30" y1="90" x2="30" y2="380" stroke="#64748b" stroke-width="2.5" marker-end="url(#q3)"/>
<text transform="rotate(-90 16 235)" x="16" y="235" text-anchor="middle" font-size="14" fill="#64748b">time</text>
<line x1="162" y1="108" x2="396" y2="108" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="280" y="98" text-anchor="middle" font-size="15">POST /import</text>
<line x1="402" y1="150" x2="636" y2="150" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="520" y="140" text-anchor="middle" font-size="15">dispatch(): store the job</text>
<line x1="398" y1="192" x2="164" y2="192" stroke="#16a34a" stroke-width="2.5" stroke-dasharray="7 5" marker-end="url(#q2)"/>
<text x="280" y="182" text-anchor="middle" font-size="15" fill="#16a34a">instant response</text>
<rect x="68" y="214" width="184" height="40" rx="6" fill="#f1f5f9" stroke="#94a3b8" stroke-dasharray="5 4"/>
<text x="160" y="239" text-anchor="middle" font-size="14" fill="#475569">the user has already left</text>
<text x="520" y="248" text-anchor="middle" font-size="14" font-style="italic" fill="#64748b">... a while later ...</text>
<line x1="878" y1="290" x2="644" y2="290" stroke="#1e293b" stroke-width="2.5" marker-end="url(#q1)"/>
<text x="760" y="280" text-anchor="middle" font-size="15">fetch the next job</text>
<rect x="790" y="314" width="180" height="56" rx="6" fill="#eff6ff" stroke="#1d4ed8" stroke-width="2"/>
<text x="880" y="338" text-anchor="middle" font-weight="bold" fill="#1d4ed8" font-size="16">handle()</text>
<text x="880" y="358" text-anchor="middle" font-size="13" fill="#475569">validate &amp; save</text>
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
If <code>QUEUE_CONNECTION</code> in <code>.env</code> says <code>sync</code>, the job runs right there and never enters a real queue. It is like a clerk telling you to wait until the laundry is dry even though you are already holding a ticket.
</div>

---

## `sync` vs `database`: Who Waits?

<svg viewBox="0 0 1000 250" width="100%" style="display:block;margin:0 auto;max-height:340px" font-family="Helvetica Neue, Arial, sans-serif" font-size="16">
<defs>
<marker id="s1" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#64748b"/></marker>
</defs>
<text x="20" y="76" font-size="19" font-weight="bold" fill="#dc2626">sync</text>
<rect x="200" y="45" width="600" height="50" rx="6" fill="#fee2e2" stroke="#dc2626" stroke-width="2"/>
<text x="500" y="76" text-anchor="middle" fill="#991b1b">job runs in place, the user waits</text>
<line x1="800" y1="95" x2="800" y2="108" stroke="#dc2626" stroke-width="2"/>
<text x="800" y="126" text-anchor="middle" font-size="14" fill="#dc2626">response arrives only now</text>
<text x="20" y="166" font-size="19" font-weight="bold" fill="#16a34a">database</text>
<rect x="200" y="140" width="76" height="50" rx="6" fill="#dcfce7" stroke="#16a34a" stroke-width="2"/>
<text x="238" y="170" text-anchor="middle" font-size="14" fill="#166534">response</text>
<text x="238" y="212" text-anchor="middle" font-size="14" fill="#16a34a">user is free</text>
<rect x="420" y="140" width="380" height="50" rx="6" fill="#eff6ff" stroke="#1d4ed8" stroke-width="2"/>
<text x="610" y="171" text-anchor="middle" fill="#1e3a8a">worker runs the job in the background</text>
<line x1="200" y1="232" x2="960" y2="232" stroke="#64748b" stroke-width="2.5" marker-end="url(#s1)"/>
<text x="960" y="222" text-anchor="end" font-size="14" fill="#64748b">time</text>
</svg>

---

## Signs a Task Belongs in a Queue

- Its duration cannot be predicted in advance, since it depends on the size of the data
- The user does not need to see the result immediately on the same page
- It calls a slow external service, such as sending email or calling a third-party API

<div class="warn-box">
A report that is opened and read right on the page is usually still better done directly, because the user is waiting for the result at that moment. A queue is not the answer to every heavy task, only to those that do not need an instant result.
</div>

---

## When a Job Fails: The Laundry Complaint Book

Problem laundry is not quietly thrown away. A failed job is recorded in the `failed_jobs` table along with its error message, and can be retried once the problem is fixed.

```bash
php artisan queue:failed        # list failed jobs
php artisan queue:retry all     # retry all of them
```

```php
class ProcessArticleImport implements ShouldQueue
{
    use Queueable;

    public int $tries = 3; // at most 3 attempts
}
```

<div class="tip-box">
If a job "ran but produced nothing", check <code>queue:failed</code> first: the error message is almost always there.
</div>

<div class="ref-link">Laravel docs: <code>Queues &rarr; Dealing With Failed Jobs</code></div>

---

## Applying It to Simple POS

You will apply these report, CSV export/import, and queue concepts directly to Simple POS in the lab jobsheet: build a sales report with a date filter, export it to CSV, build a product import from CSV, then move that import into a queued job so the user does not wait in front of the browser.

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos-ch08</code></div>

---

## Summary (1/2)

- Reports summarize data over a date range with `whereBetween`, and the aggregation (`sum()`) is best done by the database
- `startOfDay()`/`endOfDay()` keep the last day from being cut off at midnight
- Values stored correctly (like a transaction total) can be used as is, with no need to recompute them every time a report opens
- CSV export uses `lazyById()` and `streamDownload()`: a tap, not a bucket, so memory stays flat

---

## Summary (2/2)

- CSV import validates each row and skips failures with `continue`, instead of stopping the whole process
- Work with unpredictable duration or large volume belongs in a queued job, like a laundry drop-off: instant response, work follows
- A dispatched job only enters the `jobs` table, and runs only once a worker (`queue:work`) processes it
- Failed jobs are recorded in `failed_jobs` and can be retried with `queue:retry`

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Queues, File Storage, HTTP Responses)

Full code: `github.com/se-polinema/simple-pos-ch08`

**Next meeting:** Designing and Building a REST API
