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

Meeting 4: **Database Design, Migrations, and Seeding**

Schema, Schema Change History, and Query Speed

---

## What You'll Learn

1. Design a database schema and its **foreign key** relationships, along with design principles that keep data consistent and efficient

2. Master a **migration**'s lifecycle (`make:migration`, `up()`/`down()`, `migrate`, `rollback`) as a replayable history of schema evolution

3. Fill in data through **seeders** and **factories**, including large-scale bulk inserts

4. Build an **index** strategy and prove its impact with `EXPLAIN QUERY PLAN`

5. Place this approach on the bigger map: SQL vs. NoSQL, and Laravel's schema builder compared with other ecosystems

<div class="tip-box">
This slide deck covers concepts. Designing the schema, writing migrations, and seeders for Simple POS happens in the practicum jobsheet.
</div>

---

<!-- _class: divider -->

# Part 1
## Schema and Table Relationships

---

## A Warehouse With a Catalog vs. Without One

<div class="cols">
<div>

**A warehouse with a card catalog**
- Every item sits on a labeled shelf
- The catalog records which shelf holds what
- Looking for an item: read the catalog, go straight to the right shelf

</div>
<div>

**A warehouse without one**
- The item is still there, somewhere
- Searching means walking every shelf one by one
- In a large warehouse, this eats a lot of time

</div>
</div>

<div class="tip-box">
A database table's schema is the shelf layout itself; an index is the card catalog. Without the right index, the database engine can still find the data, just by scanning the entire table one row at a time.
</div>

---

## Schema: A Table's Structural Design

<div class="term-box">
<b>Schema:</b> the design of a table's structure: column names, data types, and constraints (nullable, default, unique) that apply to every row in it.
</div>

- A schema gets sketched on paper before a single migration file gets written
- Every column has a data type (number, text, date) and constraints that keep the data valid

---

## Designing a Good Schema

- **One fact, one place**: if a customer's name lives in five different tables, fixing one typo means chasing five rows at once, and all five can end up disagreeing with each other
- Pick the most specific data type available (a number for numbers, a date for dates), not `string` for everything, so the database itself rejects invalid data
- Constraints (`nullable`, `default`, `unique`) are a fence at the database level: they apply to every row that comes in, from any path, not only through one form that happens to validate it

<div class="tip-box">
A deliberate exception: a <b>snapshot</b> column (a value frozen at one moment, covered in full after the example schema below) intentionally stores a copy of a value, not for the sake of "one place", but because that value has to freeze at a particular moment.
</div>

---

## Foreign Key: Keeping Relationships Consistent

<div class="term-box">
<b>Foreign Key:</b> a column on one table pointing to the <code>id</code> of a row on another table, guaranteeing a row can never point at a parent row that doesn't exist.
</div>

<div class="flow">
  <div class="box">authors (one)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">articles (many)</div>
</div>

- One `authors` row has many `articles`; every `articles` row stores an `author_id` pointing back to its author

---

## Example Schema: A One-to-Many Relationship

| Table | Main Columns |
|---|---|
| `authors` | `id`, `name` |
| `articles` | `id`, `author_id` (fk), `title`, `published_at` |
| `comments` | `id`, `article_id` (fk), `body` |

- The `authors`→`articles` relationship is already covered; the `comments` table adds one more level: one `articles` row has many `comments`
- A diagram like this is called a simple **ERD** (Entity-Relationship Diagram), used to validate a design before writing a migration

---

## Snapshot Columns: Values Frozen in Time

- A **snapshot** column computes its value **once**, at the moment the row is created (e.g. when an article is published, when a transaction happens), instead of recomputing it every time the row is **read** later
- Example: a comment count is recorded when an article is published; the per-item price on a transaction stays what it was at that moment, even if the product's catalog price changes afterward
- This value deliberately doesn't change even if its source data changes later, that's why it's called a **snapshot**: a picture of the past, not the present

<div class="tip-box">
Computing a snapshot column doesn't mean the server can just trust whatever number the client (browser/app) sends. The validation & security meeting later covers why the server must compute this value itself before saving it, regardless of what the client submitted.
</div>

---

## SQL vs. NoSQL: When a Schema Still Wins

<div class="cols">
<div>

**Relational databases (SQL)**
- A strict schema: columns, types, and FK relationships are decided up front
- ACID transactions keep several tables consistent at once
- The default choice for business applications with structured, interconnected data, like Simple POS

</div>
<div>

**NoSQL databases (document/key-value)**
- A flexible schema: every document can take a different shape
- Easier to scale out horizontally across many servers
- Shines when the data's shape shifts constantly, or the volume is massive

</div>
</div>

<div class="tip-box">
The two aren't mutually exclusive: many systems pick relational for transactions and NoSQL elsewhere. This book stays relational, since Simple POS needs consistent transactions.
</div>

---

<!-- _class: divider -->

# Part 2
## Migrations and Seeding

Schema change history, and filling in initial data

---

## Migrations: A Replayable Schema History

<div class="term-box">
<b>Migration:</b> a PHP file describing a structural change to a table (creating, altering, or dropping columns) programmatically, so the database schema has a history that can be replayed on any other machine.
</div>

<div class="flow">
  <div class="box">Migration 1: create table</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Migration 2: add column</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Migration 3: add index</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Current schema</div>
</div>

<div class="tip-box" style="margin-top:30px;">
Similar to a git commit history for code: a migration is a commit history for the database schema, run in order according to its filename timestamp.
</div>

---

## Creating a New Migration

```bash
php artisan make:migration create_articles_table
```

- This command creates a new, timestamped file under `database/migrations/`, e.g. `2026_08_20_122440_create_articles_table.php`
- That file holds two methods: `up()` (the change being applied) and `down()` (how to undo it)
- Schema code goes inside `up()`; the full example is on the `up()` and `down()` slide after this

---

## Running Migrations

```bash
php artisan migrate
```

- Runs every migration that hasn't run yet, in order by its filename timestamp
- `php artisan migrate:status` shows which migrations have and haven't run, useful before running `migrate` on a fresh server

<div class="tip-box">
A migration only ever runs once. One already recorded as run is skipped on later <code>migrate</code> calls, unless it's rolled back first.
</div>

---

## `up()` and `down()`: Forward and Back

```php
public function up(): void
{
    Schema::create('articles', function (Blueprint $table) {
        $table->id();
        $table->string('title');
        $table->timestamps();
    });
}

public function down(): void
{
    Schema::dropIfExists('articles');
}
```

- `down()` is the exact inverse of `up()`: if `up()` creates a table, `down()` drops it
- `php artisan migrate:rollback` runs `down()` for the last migration batch, useful when a new migration turns out to be wrong

---

## Why a Correct `down()` Is Worth Writing

- An honest `down()`, one that truly reverses `up()`, makes it safe to try a schema experiment and back out of it without a trace
- Without a correct `down()`, the only way back is editing the schema by hand, the exact thing migrations exist to avoid

<div class="warn-box">
<code>php artisan migrate:fresh</code> runs <code>down()</code> on every migration, then <code>up()</code> again from scratch, a convenient shortcut during development. Never run it against a production database: every row of data is gone, not just the schema.
</div>

---

## Writing a Migration for a Table

```php
Schema::create('articles', function (Blueprint $table) {
    $table->id();
    $table->foreignId('author_id')->constrained();
    $table->string('title');
    $table->timestamps();
});
```

- `foreignId('author_id')` creates an `author_id` column as an unsigned big integer
- `->constrained()` adds a foreign key pointing to `authors.id`, following Laravel's naming convention
- This constraint protects data integrity, but doesn't necessarily mean the column already has an index (see Part 3)

<div class="tip-box">
The plural, snake_case table name (<code>articles</code>) isn't a coincidence: the upcoming ORM &amp; Data Relations meeting shows the singular model <code>Article</code> mapping to it through the same convention <code>constrained()</code> relies on above.
</div>

---

## A Schema Evolves Through New Migrations

A requirement shows up after `articles` is already in use: it now needs a subtitle column. Don't edit the old migration that already ran, create a new one instead:

```bash
php artisan make:migration add_subtitle_to_articles_table
```

```php
public function up(): void
{
    Schema::table('articles', function (Blueprint $table) {
        $table->string('subtitle')->nullable();
    });
}
```

- `Schema::table()` (not `Schema::create()`) alters a table that already exists, here adding a column

---

## The Golden Rule: A New Migration, Never an Edit

- A database design is rarely right on the first try: the schema grows alongside the features, and migrations are the neatly recorded mechanism for that evolution
- The pattern repeats forever: need a new column, write a new migration; need to drop one, write another new migration that drops it

<div class="warn-box">
An old migration edited after it has run leaves the schema history on another machine out of sync with the history on yours, that other machine has no idea anything changed, because the migration is already recorded as "already run". If the schema needs to change, a new migration is always the answer, not editing an old one.
</div>

---

## Seeders and Factories: Filling in Initial Data

<div class="term-box">
<b>Seeder:</b> a PHP class that fills a table with initial or test data, run through <code>db:seed</code> or as part of <code>migrate:fresh --seed</code>.
</div>

<div class="term-box">
<b>Factory:</b> a blueprint for generating one realistic fake row of data for a Model, e.g. <code>User::factory()->create()</code> creates one new `users` row with sensible random values.
</div>

- A seeder usually orchestrates: it calls a factory for data that needs per-Model uniqueness (e.g. users), and does a direct bulk insert for large volumes (see the next slide)

---

## Seeding at Scale: Row-by-Row vs. Bulk Insert

<div class="cols">
<div>

**`Model::create()` in a loop**
- One `INSERT` query per row
- Overhead: building an Eloquent object, firing model events
- Slow for hundreds or thousands of rows

</div>
<div>

**`DB::table()->insert()` in batches**
- One `INSERT` statement for many rows at once
- Far fewer round-trips to the database
- `array_chunk()` splits the batch because some database engines cap the number of rows per `INSERT`

</div>
</div>

```php
$articles = [];
foreach ($authorIds as $authorId) {
    for ($i = 0; $i < 30; $i++) {
        $articles[] = [
            'author_id' => $authorId,
            'title' => fake()->sentence(),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }
}

foreach (array_chunk($articles, 50) as $chunk) {
    DB::table('articles')->insert($chunk);
}
```

---

## Consistency Across Tables: `DB::transaction()`

<div class="warn-box">
When one operation touches more than one table that must stay consistent with each other (e.g. saving an order along with its line items), wrap it in a single <code>DB::transaction(function () { ... })</code>. If the process fails partway through, every change inside that block rolls back together, so the data never ends up half-saved.
</div>

---

<!-- _class: divider -->

# Part 3
## Indexes and Query Speed

Proving the impact with EXPLAIN QUERY PLAN

---

## Index: A Data Structure for Fast Lookups

<div class="term-box">
<b>Index:</b> an additional data structure the database engine builds over one or more columns, speeding up lookups on that column without scanning the entire table.
</div>

<div class="cols">
<div>

**Without an index (SCAN)**
- The database engine checks every row one by one
- Time grows linearly as the table grows

</div>
<div>

**With an index (SEARCH)**
- The database engine jumps straight to the relevant rows
- Barely affected by table size

</div>
</div>

---

## Index Strategy: Which Columns Deserve One?

- Strong candidates: columns that show up often in `WHERE`, `JOIN`, or `ORDER BY`, foreign keys almost always qualify
- An index isn't free: every `INSERT`/`UPDATE` on that table also rewrites the index's structure, and an index takes up extra storage
- So don't index every column "just in case": measure first with `EXPLAIN QUERY PLAN` (covered in full after the next slide), then add only the indexes that prove necessary
- If two columns are always filtered together (e.g. `category_id` and `is_active`), a composite index on both can outperform two separate single-column indexes

---

## `constrained()` Doesn't Always Mean There's an Index

- On some database engines (e.g. MySQL), `foreignId()->constrained()` automatically creates an index as a side effect
- On SQLite, `constrained()` only adds a foreign key constraint, not an index
- The constraint protects data integrity (rejecting inserts that point at a nonexistent row), but doesn't speed up lookups

---

## Proving It With `EXPLAIN QUERY PLAN`

- `EXPLAIN QUERY PLAN`: a SQLite command that shows the strategy the database engine will use to run a query, without actually running it

```bash
sqlite3 database/database.sqlite \
  "EXPLAIN QUERY PLAN SELECT * FROM articles WHERE author_id = 3;"
```

- **Before an index**: the result includes `SCAN articles`
- **After an index is added**: the result changes to `SEARCH articles USING INDEX articles_author_id_index`

<div class="tip-box">
If the <code>sqlite3</code> command isn't found, the alternative path is <code>php artisan tinker</code> with <code>DB::select("EXPLAIN QUERY PLAN ...")</code>.
</div>

---

## An Index Isn't Premature Optimization

<div class="warn-box">
On a table with a few dozen rows, the difference between SCAN and SEARCH is barely noticeable. On a table with thousands of rows, SCAN means every row gets examined on every single query, and that time grows linearly as the table grows. An index isn't premature optimization here; it's a fix for a performance bug that's already real the moment data approaches production scale.
</div>

---

## Schema Builders Across Ecosystems

| Ecosystem | How the Schema Is Defined | Migrations |
|---|---|---|
| Laravel (Eloquent) | Imperative PHP schema builder (`Schema::create()`) | Migration files written by hand, run via `artisan migrate` |
| Prisma (Node.js) | A declarative schema in one `schema.prisma` file | Migrations auto-generated from the schema diff |
| SQLAlchemy + Alembic (Python) | Python models (one class per table) | Semi-automatic migrations via Alembic, diffing models against the current schema |

<div class="tip-box">
The syntax differs, but the concept is the same: a database schema is code with a history that can be replayed on another machine. Once migrations click in Laravel, moving to another ecosystem is mostly a matter of syntax.
</div>

---

## Applying This to Simple POS

- You'll apply the schema, migration, and index concepts directly to the Simple POS case study in the practicum jobsheet
- Designing the category-product-transaction tables, writing a seeder at hundreds-to-thousands-row scale, and proving the index with `EXPLAIN QUERY PLAN`

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos</code>, branch <code>chapter-04</code></div>

---

## Summary (1/2)

- A good schema stores each fact once, with the right data types and constraints; a relational database suits transactional data like Simple POS's, while NoSQL suits data whose shape keeps shifting or whose scale is massive

- A migration is a replayable schema history: `up()` applies a change, `down()` reverses it, and a schema evolves through new migrations, never by editing an old one

---

## Summary (2/2)

- Seeders fill in initial data, factories mint fake data per Model; large-scale seeding uses `DB::table()->insert()` in batches, far more efficient than `Model::create()` one row at a time

- An index speeds up lookups (`SCAN` to `SEARCH`, proven with `EXPLAIN QUERY PLAN`), but it isn't free: pick candidates from `WHERE`/`JOIN`/`ORDER BY` columns, don't index everything

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Migrations, Query Builder, Seeding)

Full code: `github.com/se-polinema/simple-pos`

**Next meeting:** ORM & Data Relations
