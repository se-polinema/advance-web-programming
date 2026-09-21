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

Meeting 5: **Eloquent ORM and Relationships**

Mapping Objects to Tables, Model Relationships, and Efficient Queries

---

## What You'll Learn

1. Explain the **ORM** concept and how Eloquent maps classes to database tables

2. Define **relationships** between models (`hasOne`, `hasMany`, `belongsTo`, `belongsToMany`)

3. Understand **eager loading** and how to avoid the **N+1** problem

4. Apply **pagination** to large-scale data listings

<div class="tip-box">
This slide deck covers concepts. Applying relationships, eager loading, and pagination to Simple POS happens in the practicum jobsheet.
</div>

---

<!-- _class: divider -->

# Part 1
## ORM and Model Relationships

---

## Without a Relationship vs. With an Eloquent Relationship

<div class="cols">
<div>

**Without an Eloquent relationship**
- Every time related data is needed, hand-write a join query again
- Prone to typos in join column names, repeated in many places

</div>
<div>

**With an Eloquent relationship**
- Declared once, in the model
- Used anywhere through a property or method, no rewriting the join

</div>
</div>

<div class="tip-box">
Similar to a family tree: the line of descent gets drawn once, and anyone reading that tree instantly understands the relationship, no digging through separate records.
</div>

---

## The ORM Concept: Mapping Classes to Tables

<div class="term-box">
<b>ORM (Object-Relational Mapping):</b> a technique that maps a class in code to a table in the database, and an object to a row, so database operations are written through methods and object properties instead of raw SQL queries.
</div>

<div class="flow">
  <div class="box">Class (Model)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">ORM</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Table (rows)</div>
</div>

- Eloquent uses the **Active Record** pattern: one model class both represents a table AND provides the methods to query, save, and delete its own data

---

## Relationships: Connecting Models

<div class="term-box">
<b>Relationship:</b> a method on an Eloquent model describing how one table connects to another, used like an ordinary property even though it's really running a query behind the scenes.
</div>

```php
class Author extends Model
{
    public function articles(): HasMany
    {
        return $this->hasMany(Article::class);
    }
}

class Article extends Model
{
    public function author(): BelongsTo
    {
        return $this->belongsTo(Author::class);
    }
}
```

<div class="flow">
  <div class="box">authors (one)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">articles (many)</div>
</div>

---

## hasOne: A One-to-One Relationship

```php
class Author extends Model
{
    public function profile(): HasOne
    {
        return $this->hasOne(Profile::class);
    }
}
```

- Similar to `hasMany`, but guarantees only **one** related row, not many
- Example: one author has one profile, not several

---

## belongsToMany: A Many-to-Many Relationship

```php
class Article extends Model
{
    public function tags(): BelongsToMany
    {
        return $this->belongsToMany(Tag::class);
    }
}
```

- One article can have many tags, one tag can be used by many articles
- Needs a pivot table in between, e.g. `article_tag`, following the convention: both singular model names, alphabetical order, joined by an underscore

---

## Four Relationship Types: A Summary

| Relationship | Meaning | Example |
|---|---|---|
| `hasOne` | One parent row has one related row | Author has one Profile |
| `hasMany` | One parent row has many related rows | Author has many Articles |
| `belongsTo` | This row points back to one parent row | Article points to one Author |
| `belongsToMany` | Many-to-many through a pivot table | Article and Tag connect both ways |

---

## A Relationship's Name Isn't Just Cosmetic

- That name becomes the key used in three different places:
  - **Method call** `$author->articles()`: returns a query builder, chainable with `->where()`, `->orderBy()`, etc.
  - **Property access** `$author->articles`: returns the loaded collection directly
  - **String inside** `with('articles')`: tells Eloquent which relationship to load up front

---

<!-- _class: divider -->

# Part 2
## Eager Loading and the N+1 Problem

---

## The N+1 Problem

<div class="term-box">
<b>Lazy Loading:</b> a relationship only loads once that property is actually accessed, row by row, the root cause of the N+1 problem.
</div>

<div class="term-box">
<b>N+1:</b> a problematic query pattern, one query for the main listing, plus one separate query for every single row to load its relationship.
</div>

- Displaying 15 articles with each one's author name, without eager loading: 1 list query + 15 author queries = **16 queries**

| Approach | Query Count |
|---|---|
| Lazy loading (no `with()`) | 1 list query + N relationship queries (N+1) |
| Eager loading (`with('author')`) | 2 queries total |

---

## Eager Loading

<div class="term-box">
<b>Eager Loading:</b> loading a relationship up front through <code>with()</code>, in a fixed, small number of queries, instead of loading it one row at a time only when it's needed.
</div>

```php
$articles = Article::with('author')
    ->latest()
    ->paginate(15);
```

<div class="tip-box">
The query count under eager loading doesn't depend on how many rows get displayed, only on how many relationship levels get loaded. Displaying 15 articles or 150 articles with <code>with('author')</code> both cost 2 queries total, not 2 multiplied by the row count.
</div>

---

## Nested Eager Loading: Dot Notation

```php
$authors = Author::with('articles.comments')->get();
```

- Loads every author, their `articles` relationship, **and** the `comments` relationship inside each article, all at once
- Still a fixed query count, not growing with the number of rows

---

<!-- _class: divider -->

# Part 3
## Pagination for Large-Scale Data

---

## Pagination

<div class="term-box">
<b>Pagination:</b> a technique for splitting a large query result into small pages, returning only a subset of rows at a time along with metadata about the total page count.
</div>

```php
public function index()
{
    $articles = Article::with('author')
        ->orderBy('title')
        ->paginate(10);

    return view('articles.index', compact('articles'));
}
```

```php
<!-- resources/views/articles/index.blade.php -->
<div class="mt-4">
    {{ $articles->links() }}
</div>
```

---

## When to Use Pagination

<div class="tip-box">
Reach for <code>paginate()</code> whenever a row count could keep growing without bound over time, like an article listing or a comment history. A plain <code>get()</code> is still fine for a listing that's genuinely small and stays small, like a tag dropdown for a filter.
</div>

---

## Proving Pagination Works

```bash
php artisan tinker
>>> Article::orderBy('title')->paginate(10)->pluck('id');
>>> Article::orderBy('title')->paginate(10, ['*'], 'page', 2)->pluck('id');
```

- Compare the results of both commands
- Overlapping IDs between page 1 and page 2 signal a problem with the `orderBy` or the data

---

## Applying This to Simple POS

- You'll apply the relationship, eager loading, and pagination concepts directly to the Simple POS case study in the practicum jobsheet
- Mapping the `Category`-`Product` and `Transaction`-`TransactionDetail`-`Product` relationships, avoiding N+1 on a 2,500-transaction listing, and proving pagination across 300 products

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos-ch05</code></div>

---

## Summary

- Relationships (`hasOne`, `hasMany`, `belongsTo`, `belongsToMany`) are declared once in a model, then used through a method call, property access, or a string inside `with()`

- Lazy loading triggers one extra query per row per relationship (the N+1 problem); eager loading, including nested dot notation, loads a relationship in a fixed query count, independent of row count

- An ORM like Eloquent (using the Active Record pattern) maps classes to tables and objects to rows, replacing raw SQL queries with object methods and properties

- `paginate()` splits a large listing into small pages; different pages can be proven to genuinely differ by comparing result IDs across pages

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Eloquent, Relationships, Pagination)

Full code: `github.com/se-polinema/simple-pos`

**Next meeting:** Input Validation & Security
