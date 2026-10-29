#import "/template.typ": *

= Data Processing: Import, Export, and Queues <ch:pengolahan-data>

#chapterhero("purple", [Build a sales report with date filtering, export and import through CSV, then learn when heavy work belongs on a queue instead.], [#icon("file-csv")#h(1em)CSV export & import], [#icon("cloud-upload-alt")#h(1em)sales reports], [#icon("tasks")#h(1em)queues])

A packing plant with a conveyor line handles hundreds of parcels an
hour: goods move automatically from one station to the next, and the
worker at the end of the line just waits for a finished parcel to
arrive in front of her. Compare that to a small supply counter serving
one customer at a time, start to finish, pick the item, weigh it, wrap
it, only then serve the next customer. That one-at-a-time counter works
fine for a small shop with few customers, but forcing it to handle
plant-scale volume would leave a line of customers snaking out the
door. Simple POS faces the same choice every time it processes data in
bulk: small reports and imports are fine handled directly within a
single request cycle, like the one-at-a-time counter, but once the
volume approaches plant scale, that processing needs to move onto its
own conveyor line: a queue.

#strong[What You'll Learn]

+ build Simple POS's sales report page with date-range filtering and a total computed from transaction data;
+ export the sales report to CSV and import product data from a CSV file, including handling errors on invalid rows;
+ explain when data processing should move to a queue instead of running directly in the request cycle, using Simple POS's large-scale product import as an example.

== Sales Reports and Date Filtering <sec:pengolahan-data-1>

#istilahpenting[
/ ETL: #emph[Extract, Transform, Load], a common pattern for pulling raw data, reshaping it, then storing or presenting it in a new form, like a sales report summarized from transaction rows.
/ Batch Processing: Processing many pieces of data at once in groups, rather than one at a time, used both in seeding (Chapter~4) and CSV import.
/ Queue: A mechanism for deferring heavy work to run in the background through a separate process, rather than directly during a user's request.
/ Import/Export: The process of bringing data in from an external format (CSV, Excel) into a database, or taking it out of the database into an external format to be read outside the application.
]

Simple POS's report page answers a different question from the
ordinary transaction page: not "which transactions happened", but "what
was the total sales figure over a given period". Scaffold it first:

+ Create the controller: `php artisan make:controller
      ReportController`.
+ Open `routes/web.php`, register a `GET /reports`
      route pointing at `ReportController@index`, inside
      Chapter~7's `role:admin` group.
+ Create the view file at
      `resources/views/reports/index.blade.php`, at minimum a
      filter form with two date inputs (`name="from"` and
      `name="to"`) and an area displaying `$totalSales`.

`ReportController@index` accepts a start and end date from a
filter form, then filters transactions through `whereBetween`.

#listing(file: "app/Http/Controllers/ReportController.php", ```php
$transactions = Transaction::whereBetween('created_at', [
    $request->date('from')->startOfDay(),
    $request->date('to')->endOfDay(),
])->get();

$totalSales = $transactions->sum('total');
```)

`startOfDay()` and `endOfDay()` matter here: without
them, a date filter of "2026-08-01 through 2026-08-31" literally means
"up to 00:00:00 on the 31st", which excludes every transaction that
happened during that same 31st entirely.
`$transactions->sum('total')` sums the `total` column
that's already stored per transaction (covered in Chapter~6), not
recomputed from product prices one at a time.

== CSV Export and Import <sec:pengolahan-data-2>

Exporting the report to CSV means turning an Eloquent collection into
comma-separated text rows, ready to open in any spreadsheet
application.

#listing(file: "app/Http/Controllers/ReportController.php", ```php
public function export(Request $request)
{
    $transactions = $this->filteredTransactions($request);

    return response()->streamDownload(function () use ($transactions) {
        $out = fopen('php://output', 'w');
        fputcsv($out, ['ID', 'Date', 'Cashier', 'Total']);
        foreach ($transactions as $t) {
            fputcsv($out, [$t->id, $t->created_at, $t->user->name, $t->total]);
        }
        fclose($out);
    }, 'sales-report.csv');
}
```)

`response()->streamDownload()` writes CSV rows straight to the
output stream while sending it to the browser, with no need to hold the
entire file in server memory first; this matters once the report's row
count starts to grow.

Import runs in the opposite direction: read an uploaded CSV file, then
turn each of its rows into a `products` row. The trickier part
here isn't the reading and writing itself, it's handling a malformed
row without aborting the whole import because of a single bad line.

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

`continue` on a row that fails validation makes sure the
import keeps moving to the next row, collecting an error message per
line number in the `$errors` array, instead of throwing an
exception that stops the entire import just because one line in the
middle of the file had a mistyped price.

== Practice: When to Reach for a Queue <sec:pengolahan-data-3>

Importing a few dozen products finishes in a matter of seconds, fine to
run directly within the request cycle like the code above: a user
uploads a file, waits briefly, and the next page shows the result. Once
that volume climbs into the thousands of rows, say a shop migrating its
entire old catalog in one go, that same process can take tens of
seconds or longer, and an HTTP request has a timeout. A user staring at
a browser with no idea whether the process is still running or already
failed silently is a bad experience, and on some servers that request
can even get forcibly cut off before it finishes.

#figure(
  table(
    columns: (1.1fr, 1.1fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Approach], [User response time], [Fits],
    table.hline(stroke: 0.5pt),
    [Direct processing (request)], [Waits until finished], [Small imports, under a few hundred rows],
    [Queued job], [Instant, processed in the background], [Large imports, heavy reports, bulk email],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Direct request processing vs a queued job],
) <tab:queue-vs-langsung>

Moving import to a queue means the controller only stores the file and
dispatches one job to the queue, then immediately responds to the user
with an "import is being processed" message, with no wait for the
process to finish at all. The steps below move the product import from
the previous section's code onto a queued job.

+ Set up the queue driver. Open `.env`, make sure
      `QUEUE_CONNECTION=database` (not `sync`, which runs
      a job directly with no real queue involved). If the queue table
      doesn't exist yet, create its migration:

  #listing(```bash
  php artisan queue:table
  php artisan migrate
    
  ```)
+ Create the job class:

  #listing(```bash
  php artisan make:job ProcessProductImport
    
  ```)
+ Open `app/Jobs/ProcessProductImport.php`. Move the
      validate-and-save loop from the previous section's code into the
      `handle()` method, with the CSV file path stored through the
      constructor:

  #listing(file: "app/Jobs/ProcessProductImport.php", ```php
  public function __construct(private string $csvPath) {}

  public function handle(): void
  {
      $rows = /* read $this->csvPath into an array of rows */;
      foreach ($rows as $lineNumber => $row) {
          // ...the validation loop and Product::create() from before
      }
  }
    
  ```)
+ Open `ReportController` (or whichever import controller
      applies), replace the direct import-loop call with dispatching the
      job:

  #listing(file: "app/Http/Controllers/ReportController.php", ```php
  ProcessProductImport::dispatch($request->file('csv')->store('imports'));

  return back()->with('success', 'Import is being processed in the background.');
    
  ```)
+ Run the queue worker in a separate terminal (leave it running
      for the rest of testing):

  #listing(```bash
  php artisan queue:work
    
  ```)
+ Upload a CSV file through the import form. #strong[What to
      expect]: the page responds immediately with an "import is being
      processed" message (no waiting), and in the `queue:work`
      terminal, a log line appears reading
      `Processing: App\Jobs\ProcessProductImport`
      followed by `Processed` a moment later.
+ Open `/products`, refresh the page. #strong[What to
      expect]: the products from the CSV file are already saved, even
      though the saving happened after the controller had already
      finished responding.
+ #strong[If the job never gets processed] (the
      `queue:work` terminal stays silent), check two things: (a)
      `QUEUE_CONNECTION` in `.env` still reads
      `sync`, so the job runs directly and never enters the queue
      table; (b) the worker from step 5 was never actually started, or
      got stopped before the job was dispatched in step 6.

#tipbox[
Signs a process is worth moving to a queue: its duration can't be
predicted upfront (depends on how large a file a user uploads), it
doesn't need an instant result the user has to see on that same page
right away, or it involves a slow call to an external service (sending
email, calling a third-party API). A report that's opened and read
directly on the page, by contrast, is usually still better processed
directly, since the user really is waiting for the result right then.
]

#branchref("chapter-08")

== Summary <sec:pengolahan-data-rangkuman>

- Simple POS's sales report filters transactions through
      `whereBetween` with `startOfDay()`/`endOfDay()`
      on a date range, and sums the already-stored `total` column
      rather than recomputing from scratch.
- CSV export uses `streamDownload()` to write rows
      straight to output without holding the entire file in memory; CSV
      import validates each row one at a time and skips a failing row
      through `continue`, collecting a per-row error message
      instead of aborting the whole process.
- A process with unpredictable duration or large volume, like a
      product import at the scale of thousands of rows, should move to a
      queued job so the user gets an instant response while the process
      runs in the background.

== Exercises

+ Change the report filter to also support filtering by product
      category, alongside the existing date range.
+ Test the import with a CSV file containing a mix of valid and
      invalid rows (for example, a `category_id` that doesn't
      exist), then check whether the valid rows still get saved and the
      failing rows' error messages show up clearly.
+ Identify one other process in Simple POS, besides product
      import, that you think is worth moving to a queued job, and explain
      why.
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) why `startOfDay()`/`endOfDay()`
      are needed on a date filter, (b) why a failing CSV row must not
      abort the whole import, and (c) the signs a process is worth moving
      to a queue. Check your answers against this chapter.

#challengebox[
Add a best-selling products summary section to the report page, showing
the five products with the highest quantity sold within the currently
filtered date range.
]

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for the query builder, streaming responses, and
queues.
