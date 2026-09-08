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

1. Explain the **schema** concept and table relationships through **foreign keys**

2. Understand **migrations** as a replayable history of schema changes, and **seeders** for filling in large amounts of initial data

3. Explain the **index** concept and how to verify its impact on query speed

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

- One `authors` row has many `articles`
- One `articles` row has many `comments`
- The relationships are simple enough to sketch on paper before writing any code

---

## Values That Are Stored, Not Recomputed

- Some columns deliberately store a value as of one point in time, instead of recomputing it every time it's read
- Example: a comment count at the moment an article was published, or a price as it stood when a transaction happened
- That value has to stay exactly what it was at that moment, even if the source data changes later

<div class="tip-box">
The validation & security meeting later covers why a value like this must still be recalculated on the server when it's saved, not just trusted from input.
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

## The Golden Rule: Don't Edit, Add a New One

<div class="warn-box">
If the schema needs to change, create a new migration, don't edit an old migration that's already run. An old migration edited after it has run leaves the schema history on another machine out of sync with the history on yours.
</div>

- Treat migrations like version control for the schema: a new change always means a new migration file

---

## Seeders: Filling in Initial Data

<div class="term-box">
<b>Seeder:</b> a PHP class that fills a table with initial or test data, run through <code>db:seed</code> or as part of <code>migrate:fresh --seed</code>.
</div>

- Useful for sample data during development, and realistic-scale test data for practicing performance work

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

## Applying This to Simple POS

- You'll apply the schema, migration, and index concepts directly to the Simple POS case study in the practicum jobsheet
- Designing the category-product-transaction tables, writing a seeder at hundreds-to-thousands-row scale, and proving the index with `EXPLAIN QUERY PLAN`

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos</code>, branch <code>chapter-04</code></div>

---

## Summary

- A table's schema is defined through migrations; a migration is a history of changes that can be replayed on another machine, and the golden rule is: add a new migration, never edit an old one

- Foreign keys keep one-to-many relationships between tables consistent; seeders fill in initial data, and large-scale seeding uses `DB::table()->insert()` in batches, far more efficient than `Model::create()` one row at a time

- An index speeds up lookups on frequently filtered columns; a foreign key constraint doesn't automatically mean there's an index, depending on the database engine in use

- `EXPLAIN QUERY PLAN` proves an index's impact directly: from `SCAN` (scanning every row) to `SEARCH` (jumping to the relevant rows)

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Migrations, Query Builder, Seeding)

Full code: `github.com/se-polinema/simple-pos`

**Next meeting:** ORM & Data Relations
