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

Date-filtered reports, CSV export and import, and when heavy work belongs in the background

---

## What You'll Learn

1. Build a report that aggregates data over a date range, and avoid a common pitfall when filtering by date

2. Export data to CSV without overloading server memory, and import CSV while handling bad rows without stopping the whole process

3. Recognize when a process should move to a **queue** instead of running directly inside the request cycle

<div class="tip-box">
This deck covers concepts. Applying reports, export/import, and queues to Simple POS happens in the practicum jobsheet.
</div>

---

<!-- _class: divider -->

# Part 1
## Reports and Data Aggregation

---

## Four Basic Terms

<div class="term-box">
<b>ETL (Extract, Transform, Load):</b> a common pattern of taking raw data, reshaping it, then storing or presenting it in a new form.
</div>

<div class="term-box">
<b>Batch Processing:</b> processing many records at once in a group, rather than one at a time.
</div>

<div class="term-box">
<b>Queue:</b> a mechanism for deferring heavy work so it runs in the background by a separate process, instead of directly during a user's request.
</div>

<div class="term-box">
<b>Import/Export:</b> bringing data in from an external format (CSV, Excel) into the database, or sending it out to an external format to be read outside the application.
</div>

---

## Reports Answer a Different Question

An ordinary list page answers "what exists": show every article, every transaction, every user. A report page answers a narrower but heavier question: "what's the total X over a given time range".

```php
$articles = Article::whereBetween('published_at', [
    $from, $to,
])->get();

$totalKata = $articles->sum('word_count');
```

`whereBetween` filters rows whose date falls between two bounds, then `sum()` adds up one column from that filtered result. The same pattern works for totaling anything already stored per row.

---

## A Common Pitfall: The Cut-Off Last Day

<div class="warn-box">
A date filter for "August 1 through August 31" written literally means "through 00:00:00 on the 31st", which excludes every transaction that happens during the 31st itself.
</div>

```php
$from = $request->date('from')->startOfDay();
$to = $request->date('to')->endOfDay();
```

`startOfDay()` turns the start date into 00:00:00, and `endOfDay()` turns the end date into 23:59:59, so the whole last day counts, instead of being cut off at midnight.

---

## Stored Aggregates, Not Recomputed

Meeting 6 established: a value like a transaction total can't be trusted when it arrives directly from client input, and must be recomputed on the server when the transaction is created. Once that value is correctly stored, a report may use it as-is.

```php
// The report just sums a column that's already stored
$totalPenjualan = $transactions->sum('total');
```

<div class="tip-box">
Recomputing a total from detail rows one by one, every single time a report is opened, burdens the server for no reason: the number has already been correct since the transaction was created.
</div>

---

<!-- _class: divider -->

# Part 2
## CSV Export and Import

---

## Exporting Without Overloading Memory

The simplest way to export CSV is to collect every row into one large string, then send it all at once. That works for a few dozen rows, but once the row count reaches the tens of thousands, the entire file has to fit in server memory before anything is sent at all.

```php
return response()->streamDownload(function () {
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Title', 'Author', 'Date']);
    foreach ($articles as $a) {
        fputcsv($out, [$a->title, $a->author->name, $a->published_at]);
    }
    fclose($out);
}, 'article-report.csv');
```

`streamDownload()` writes each row straight to the output stream while sending it to the browser, without holding the entire file in server memory first.

---

## Importing: A Bad Row Shouldn't Stop Everything

Import runs the opposite direction: reading an uploaded CSV file, then turning each row into a new database row. The risky part isn't the reading and writing, it's handling a bad row without stopping the entire process because of it.

```php
foreach ($rows as $row) {
    $validator = Validator::make($row, [
        'title' => ['required', 'string'],
        'author_id' => ['required', 'exists:authors,id'],
    ]);

    if ($validator->fails()) {
        continue; // skip this row, move to the next one
    }

    Article::create($validator->validated());
}
```

---

<!-- _class: divider -->

# Part 3
## When to Use a Queue

---

## Two Ways to Process Work

<div class="cols">
<div>

**Directly (in the request)**
- The user waits until it's done
- If it fails, the user finds out right away
- Suits short work, where the result is needed immediately

</div>
<div>

**Through a Queue (a job)**
- Instant response, work happens in the background
- The user isn't left waiting in the browser
- Suits heavy work or work with unpredictable duration

</div>
</div>

<div class="tip-box">
Importing a few dozen rows finishes in seconds, fine to run directly. Once the volume climbs into the thousands, the same process can take tens of seconds or more, and HTTP requests have a timeout.
</div>

---

## Signs a Process Belongs in a Queue

- Its duration can't be predicted in advance, depending on the size of the data being processed
- The result doesn't need to be seen by the user instantly on the same page
- It involves calling a slow external service, such as sending an email or calling a third-party API

<div class="warn-box">
A report that's opened and read directly on the page is usually still better processed directly, because the user is genuinely waiting for the result right then. A queue isn't a solution for all heavy work, only for work that doesn't need an instant result.
</div>

---

## The Job Flow in Laravel

<div class="flow">
  <div class="box">Controller</div>
  <div class="arrow">&rarr;</div>
  <div class="box">dispatch() a job</div>
  <div class="arrow">&rarr;</div>
  <div class="box">jobs table</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Worker (queue:work)</div>
</div>

```php
php artisan make:job ProcessArticleImport
```

```php
ProcessArticleImport::dispatch($csvPath);

return back()->with('success', 'Import is being processed in the background.');
```

The controller just saves the file and sends one job to the queue, then immediately responds to the user, without ever waiting for the process to finish. The actual work (the validate-and-save loop) moves into the job class's `handle()` method.

---

## Worker: A Separate Process That Runs Jobs

<div class="term-box">
<b>Worker:</b> a separate, continuously running PHP process that picks up jobs from the <code>jobs</code> table one at a time, then runs their <code>handle()</code> method.
</div>

```bash
php artisan queue:work
```

Without a running worker, jobs just pile up in the `jobs` table and never get processed, because dispatching only saves the job to the queue, it doesn't run it directly.

<div class="warn-box">
If <code>QUEUE_CONNECTION</code> in <code>.env</code> is set to <code>sync</code>, a job runs immediately in place and never actually enters a real queue, erasing the entire benefit of moving it to the background.
</div>

---

## Applying This to Simple POS

You'll apply the report, CSV export/import, and queue concepts directly to Simple POS in the practicum jobsheet: building a sales report with a date filter, exporting that report to CSV, building a product import from CSV, then moving that import to a queued job so users don't wait in the browser.

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos-ch08</code></div>

---

## Summary (1/2)

- A report aggregates data over a date range via `whereBetween`, with `startOfDay()`/`endOfDay()` so the last day isn't cut off at midnight
- A value that's already correctly stored (like a transaction total) can be used as-is in a report, no need to recompute it every time the report opens
- CSV export uses `streamDownload()` to write rows straight to the output without holding the entire file in memory

---

## Summary (2/2)

- CSV import validates each row one at a time and skips a failing row via `continue`, instead of stopping the entire process
- A process with unpredictable duration or large volume should move to a queued job, so the user gets an instant response while the process runs in the background
- A dispatched job only enters the `jobs` table, and doesn't actually run until a worker (`queue:work`) processes it

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Queues, File Storage, HTTP Responses)

Full code: `github.com/se-polinema/simple-pos-ch08`

**Next meeting:** Designing and Building a REST API
