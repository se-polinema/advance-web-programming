#import "/template.typ": *

= Full Case Study: Building Simple POS From Scratch <ch:studi-kasus-menyeluruh>

#chapterhero("orange", [Reassemble the whole of Simple POS from schema to API, walk through the ten increments that built it, then take it as the opening map for a project of your own.], [#icon("store")#h(1em)Simple POS end to end], [#icon("cash-register")#h(1em)ten increments], [#icon("flag-checkered")#h(1em)a PBL reference])

Chapter 1 opened this book with a family restaurant growing into a food
court, and that small business ran into a real problem: one cook
keeping every order in her head no longer scaled once the customer
count grew. Eleven chapters later, Simple POS is finished, no longer a
design on paper but an application that genuinely stores products,
records transactions, restricts access by role, and serves a mobile
client through an API. A restaurant's opening day is a similar moment:
the kitchen is fully equipped, every recipe has been tested one at a
time, but only on that day does everything run together, in front of
real customers. This chapter is that opening day for Simple POS: not a
chapter that teaches anything new, but one that lights up the whole
kitchen at once and watches it work as a single system.

#strong[What You'll Learn]

+ assemble every component of Simple POS (schema, models, controllers/routes, views, validation, authentication, reports, API) into one coherent application flow;
+ walk through Simple POS's ten commit increments and map each increment onto the matching chapter of this book;
+ evaluate Simple POS as an architecture reference for a PBL project in a different business domain, and identify which parts need adapting.

== Assembling Simple POS from Scratch <sec:studi-kasus-menyeluruh-1>

Follow one cashier transaction from start to finish, and every layer it
passes through is a chapter already covered. The cashier opens
`/pos`, a page protected by the `auth` middleware and
rendered through a Blade layout with an interactive Alpine.js shopping
cart (Chapter~3). The products shown in the grid come from an Eloquent
query already carrying eager-loaded categories (Chapter~5), read from a
table whose schema was designed and filled with seed data as early as
Chapter~4.

The moment the cashier hits pay, the request lands in
`TransactionController@store`, rejected first by
`StoreTransactionRequest` if any item is invalid (Chapter~6),
then the total gets recomputed from the product prices stored in the
database, never from a number the client sent (Chapter~6). The
`transactions` and `transaction_details` rows get saved,
product stock drops, and this entire process only happens at all
because the logged-in cashier holds a genuinely valid session
(Chapter~7). Days later, an admin opens `/reports`, a page closed
to cashiers by the `role:admin` middleware (Chapter~7),
filters transactions across a date range (Chapter~8), and exports it to
CSV for a weekly meeting. Meanwhile, the mobile cashier app calls
`POST /api/login` to get a Sanctum token, then `GET
/api/products` and `POST /api/transactions` carrying an
`Authorization: Bearer` header on every request (Chapter~9).
Before any of this was ever declared done, 13 feature tests
(Chapter~10) verified the flow above genuinely runs as described, and
before this application was ever called ready to ship, foreign key
indexes got rechecked and `APP_DEBUG` confirmed off in
production (Chapter~11).

#notebox[
None of the layers above stand on their own. The role middleware from
Chapter~7 means nothing without the authentication system that comes
before it; the report from Chapter~8 means nothing without a
`total` column guaranteed accurate since Chapter~6. Simple POS
holds together not because each part is individually clever, but
because each part is built on a guarantee the part before it already
fulfilled.
]

== Walking Through Ten Increments <sec:studi-kasus-menyeluruh-2>

Simple POS, within the scope of this book, was built across ten
increments, and every increment maps directly onto a chapter already
read.

#figure(
  table(
    columns: (0.5fr, 0.6fr, 1.9fr),
    align: (center, left, left),
    table.hline(stroke: 0.8pt),
    [Increment], [Related chapter], [What got built],
    table.hline(stroke: 0.5pt),
    [1], [Chapter 1], [Laravel project setup, Git, SQLite],
    [2], [Chapter 2], [Routes and controllers],
    [3], [Chapter 3], [Blade layout and Tailwind],
    [4--5], [Chapters 4--5], [Schema, migrations, Eloquent relationships],
    [6], [Chapter 6], [Form validation],
    [7], [Chapter 7], [Authentication and RBAC],
    [9], [Chapter 8], [Reports, export/import],
    [10], [Chapter 9], [REST API and Sanctum],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Mapping Simple POS's ten increments onto this book's chapters],
) <tab:increment-mapping>

The increment numbers don't line up perfectly and neatly with the
chapter numbers, and that isn't a numbering mistake. Increments 4 and 5
both fall under Chapters~4 and~5 because schema and relationships
really are two sides of the same piece of work, large enough to split
into two chapters but still built as a tight run of adjacent commits.
Increment 8 has no row of its own in this table because it wasn't a new
feature addition, it was a full checkpoint over increments 1 through 7
already running, before moving on to increment 9. Real code history
rarely lines up as neatly as a book's chapter order; the book reorders
it for teachability, while the historical commits followed the order
the work actually happened in.

== Practice: Simple POS as an Architecture Reference <sec:studi-kasus-menyeluruh-3>

Before evaluating Simple POS as a reference, run its complete form from
scratch first, exactly the way another developer would when opening
this project for the first time.

+ Clone the repository, then switch to the `chapter-12`
      branch (Simple POS's final state, as covered throughout this
      book):

  #listing(```bash
  git clone https://github.com/dhanifudin/simple-pos.git
  cd simple-pos
  git checkout chapter-12
    
  ```)
+ Install PHP dependencies and set up the environment file:

  #listing(```bash
  composer install
  cp .env.example .env
  php artisan key:generate
    
  ```)
+ Install JavaScript dependencies, then build production frontend
      assets (skip this and the layout's `@vite` directive throws a
      `ViteManifestNotFoundException` the moment `/pos` opens
      a few steps from now):

  #listing(```bash
  npm install
  npm run build
    
  ```)
+ Run migrations along with the seeder:

  #listing(```bash
  php artisan migrate:fresh --seed
    
  ```)

  #strong[What to expect]: the migration list prints one by one with
      no errors, followed by a message that the seeder finished running.
+ Run the whole test suite to confirm this checkout genuinely
      works (not just that it cloned):

  #listing(```bash
  php artisan test
    
  ```)

  #strong[What to expect]: every test passes, matching the anatomy
      covered in Chapter~10.
+ Start the server, then log in and record one real transaction
      through the browser:

  #listing(```bash
  php artisan serve
    
  ```)

  Open `http://127.0.0.1:8000`, log in as
      `admin@pos.test`, open `/pos`, add one product to the
      cart, then save the transaction. #strong[What to expect]: the
      transaction saves and shows up immediately on
      `/transactions`, with product stock dropping by the quantity
      purchased, exactly the end-to-end flow covered in the previous
      section.
+ #strong[If `migrate:fresh` fails with a
      `database file does not exist` message], create the SQLite
      database file manually before migrating: `touch
      database/database.sqlite`, then repeat step 4.

With this fully running Simple POS as proof, the following section
evaluates its structural pattern as a reference for other projects.

Simple POS was designed specifically for a retail sales case, but its
structural pattern, not its business detail, is the part worth reusing.
A PBL project in a different domain, say a meeting room booking system
or a library lending system, won't have a `products` or
`transactions` table, but the same skeleton, schema then model
then controller/route then view then validation then authentication
then report then API, still holds up as a starting point.

#figure(
  table(
    columns: (1.3fr, 1.7fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [Part], [Adapt or keep],
    table.hline(stroke: 0.5pt),
    [Core entities (`products`, `transactions`)], [Replaced entirely for the domain (e.g. `rooms`, `bookings`)],
    [Schema and relationships (Chapters~4--5)], [Redesigned, but the `hasMany`/`belongsTo` pattern and FK indexes still apply],
    [Server-side validation pattern (Chapter~6)], [Kept in full: any critical total/value still must be recomputed server-side],
    [Authentication and RBAC (Chapter~7)], [Kept, roles renamed to fit (e.g. `staff`/`member` instead of `admin`/`cashier`)],
    [Report and API structure (Chapters~8--9)], [Kept as a pattern, content and endpoints adapted to the domain],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Checklist for adapting Simple POS to another business domain],
) <tab:checklist-adaptasi>

#tipbox[
Use the order schema → model → controller/route → view
→ validation → authentication → report → API as the
starting skeleton for a new project, the exact order this book's
chapters followed. That order isn't a coincidence: every layer needs a
guarantee from the layer before it, and building out of that order
usually means rewriting something that should have already been correct
from the start.
]

#branchref("chapter-12")

== Summary <sec:studi-kasus-menyeluruh-rangkuman>

- One cashier transaction in Simple POS passes through every
      layer covered across the previous eleven chapters, from schema and
      models through validation, authentication, reports, and the API,
      and every layer depends on a guarantee the layer before it already
      fulfilled.
- Simple POS's ten increments map directly onto Chapters~1
      through~9, with increments 4--5 merging into two chapters and
      increment 8 serving as a checkpoint rather than a new feature.
- Simple POS's structural pattern, not its retail-sales business
      detail, is what's worth reusing as an architecture reference for a
      project in a different business domain.

== Exercises

+ Redraw the end-to-end flow diagram for one cashier transaction
      in your own words, naming which chapter is responsible for each
      step.
+ Pick a different business domain (booking, library lending,
      warehouse inventory, or one of your own choosing), then identify
      the three parts of Simple POS that would need adapting first for
      that domain.
+ Explain in your own words why the order schema → model
      → controller → view → validation → authentication
      → report → API makes more sense done in sequence than
      shuffled.

== References

This chapter draws together the references already cited across
Chapters~1 through~11, with no new citations of its own.
