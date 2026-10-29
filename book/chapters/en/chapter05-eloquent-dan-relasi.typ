#import "/template.typ": *

= Eloquent ORM and Relationships <ch:eloquent-dan-relasi>

#chapterhero("teal", [Map out how Simple POS's models relate to each other, dodge the N+1 query trap, then prove pagination works correctly across 2,500 transactions.], [#icon("link")#h(1em)Eloquent relationships], [#icon("layer-group")#h(1em)eager loading], [#icon("tachometer-alt")#h(1em)pagination at scale])

A large family tree is usually drawn on a single sheet: grandparents'
names at the top, lines running down to their children, more lines down
to the grandchildren. Anyone reading that tree instantly knows whose
child is whose, no need to dig through a stack of separate birth
records one at a time. Eloquent models in Simple POS work like that
family tree: `Category` is the grandparent, `Product`
is the child, `Transaction` and `TransactionDetail`
are the grandchildren. A relationship between models declares that line
of descent once, in the model class, and after that any code anywhere
can ask "which products belong to this category" or "which detail rows
belong to this transaction" without hand-writing a join query every
single time.

#strong[What You'll Learn]

+ map `hasOne`, `hasMany`, `belongsTo`, and `belongsToMany` relationships onto Simple POS's four models (`Category`, `Product`, `Transaction`, `TransactionDetail`);
+ use eager loading (`with()`) to avoid the N+1 query problem when listing transactions alongside their details and products;
+ apply `paginate()` to a listing of 300 products and 2,500 transactions, and prove that the second page genuinely returns different rows than the first.

== Eloquent Relationships in the Simple POS Models <sec:eloquent-dan-relasi-1>

#istilahpenting[
/ Relationship: A method on an Eloquent model describing how one table connects to another, used like an ordinary property (`$product->category`) even though it's really running a query behind the scenes.
/ Eager Loading: Loading a relationship up front through `with()`, in a fixed, small number of queries, instead of loading it one row at a time only when it's needed.
/ N+1: A problematic query pattern: one query for the main listing, plus one separate query for every single row to load its relationship.
/ Lazy Loading: The opposite of eager loading: a relationship only loads once that property is actually accessed, row by row, the root cause of the N+1 problem.
/ Pagination: A technique for splitting a large query result into small pages, returning only a subset of rows at a time along with metadata about the total page count.
]

Simple POS's four models connect through mirrored relationship pairs.
`Category` has many `Product` through
`hasMany`, and every `Product` points back to one
`Category` through `belongsTo`. `Transaction`
has many `TransactionDetail` through `hasMany`, and
every `TransactionDetail` points back to one
`Transaction` as well as one `Product`, each through
`belongsTo`.

#listing(```php
class Category extends Model
{
    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }
}

class TransactionDetail extends Model
{
    public function transaction(): BelongsTo
    {
        return $this->belongsTo(Transaction::class);
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(Product::class);
    }
}
```)

The relationship method's name, `products()` on
`Category`, or `product()` on
`TransactionDetail`, isn't just cosmetic convention. That name
becomes the key used everywhere that relationship gets requested, both
through a method call (`$category->products()`), which returns
a query builder, and through property access
(`$category->products`), which returns the resulting collection
directly, and also through a string inside
`with('products')`, covered in the next section.

== Eager Loading and the N+1 Problem <sec:eloquent-dan-relasi-2>

Picture a transaction history page listing 15 transactions, each with
the names of the products purchased. Written without eager loading,
Blade would loop over `$transaction->details` for each
transaction, and every time that property gets accessed, Eloquent only
then runs a `SELECT * FROM transaction_details WHERE
transaction_id = ?` query right there, one query per transaction. Then
inside that details loop, accessing `$detail->product` triggers
one more query per detail row. For 15 transactions averaging 3 items
each, that's 1 query for the transaction list, plus 15 detail queries,
plus around 45 product queries: 61 queries total to render a single
page.

#figure(
  table(
    columns: (1.4fr, 0.8fr, 0.8fr),
    align: (left, center, center),
    table.hline(stroke: 0.8pt),
    [Approach], [List query], [Relationship queries],
    table.hline(stroke: 0.5pt),
    [Lazy loading (no `with()`)], [1], [∼60 (repeated N+1)],
    [Eager loading (`with('details.product')`)], [1], [2],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Query count: lazy loading vs eager loading for 15 transactions],
) <tab:lazy-vs-eager>

`with('details.product')` flips that order around: Eloquent
runs one query for the transaction list, one extra query that loads
every `TransactionDetail` belonging to those transactions all
at once (through `WHERE transaction_id IN (...)`), and one more
query that loads every related `Product` all at once. The dot
in `details.product` tells Eloquent to load a nested
relationship: transaction details, then the product on each of those
details, all within the same batch of queries.

#listing(```php
$transactions = Transaction::with('details.product')
    ->latest()
    ->paginate(15);
```)

#notebox[
The query count under eager loading doesn't depend on how many rows get
displayed; it depends on how many relationship levels get loaded.
Displaying 15 transactions or 150 transactions with
`with('details.product')` both cost 3 queries total, not 3
multiplied by the row count.
]

== Practice: Pagination at Realistic Scale <sec:eloquent-dan-relasi-3>

Rendering all 300 products or all 2,500 transactions on a single page
at once, through a plain `get()`, would still run, but it
loads down both the server and the browser with thousands of rows of
HTML most of which a user would never look at in one sitting.
`paginate()` splits that query result into small chunks,
reading only the requested number of rows based on the `page`
parameter in the URL, plus metadata like total page count and
previous/next links, ready to be consumed directly by the Blade
component `{{ $products->links() }}`.

+ Open `app/Http/Controllers/ProductController.php`, the
      `index()` method. Replace the existing `get()` call
      with `paginate()`:

  #listing(file: "app/Http/Controllers/ProductController.php", ```php
  public function index()
  {
      $products = Product::with('category')
          ->orderBy('name')
          ->paginate(10);

      return view('products.index', compact('products'));
  }
    
  ```)
+ Open `resources/views/products/index.blade.php`. Below
      the existing product table or grid, add one line to render page
      navigation:

  #listing(file: "resources/views/products/index.blade.php", ```php
  <div class="mt-4">
      {{ $products->links() }}
  </div>
    
  ```)

  `$products->links()` automatically renders
      previous/next links and page numbers; no extra view file needs to
      be built by hand.
+ Run `php artisan serve` if it isn't running yet, then
      open `http://127.0.0.1:8000/products`. #strong[What to
      expect]: only the first 10 products show up, followed by a row of
      page-number links underneath.
+ Click the page 2 link (or manually change the URL to
      `?page=2`). #strong[What to expect]: 10 different products
      show up compared to the first page, and the browser's address bar
      shows `?page=2`.
+ #strong[If a `Method links does not exist` error shows
      up], that's a sign the controller from step 1 is still calling
      `get()`, not `paginate()`; `links()` is
      only available on a `paginate()` result, not a plain
      collection.

#tipbox[
Reach for `paginate()` whenever a row count could keep growing
without bound over time, like a product listing or a transaction
history. A plain `get()` is still fine for a listing that's
genuinely small and stays small, like a category dropdown for a filter.
]

Proving pagination actually works, not just chopping up the display but
leaving the underlying data intact, can be verified further through
Tinker, by comparing the row IDs on two different pages:

#listing(```bash
php artisan tinker
>>> Product::orderBy('name')->paginate(10)->pluck('id');
>>> Product::orderBy('name')->paginate(10, ['*'], 'page', 2)->pluck('id');
```)

The fourth argument to `paginate()` above forces the page
number manually (it's normally pulled automatically from the
`?page=2` query string on a real request). The two printed ID
lists should never overlap at all; if the same ID shows up on both
pages, that's a sign of a bug in the `orderBy` used before
pagination, since pagination assumes the query's result order stays
consistent between requests.

#branchref("chapter-05")

== Summary <sec:eloquent-dan-relasi-rangkuman>

- Simple POS's four models connect through mirrored
      `hasMany`/`belongsTo` pairs: `Category`
      to `Product`, and `Transaction` to
      `TransactionDetail`, which also points to `Product`.
- Lazy loading triggers one extra query per row per relationship
      (the N+1 problem), while `with('details.product')` loads a
      nested relationship in a fixed query count, independent of how many
      rows get displayed.
- `paginate()` splits a listing of 300 products or 2,500
      transactions into small pages, and different pages can be proven to
      genuinely return different rows by comparing result IDs across
      pages.

== Exercises

+ Remove `with('details.product')` from the transaction
      history query, turn on Laravel's query log, and count the
      difference in query count before and after eager loading is
      restored.
+ Add a new relationship: `Product::belongsToMany` to
      the `Transaction` model through the
      `transaction_details` pivot table, as an alternative way to
      access every transaction that ever purchased one product.
+ Apply `paginate()` to one other listing endpoint in
      Simple POS that doesn't use it yet, then prove its second page
      doesn't overlap the first, the same way as in the Practice section.
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) the difference between
      `hasMany` and `belongsTo`, (b) why N+1 counts as a
      performance problem, and (c) how to prove two pagination pages
      don't overlap. Check your answers against this chapter.

#challengebox[
Write one query that returns the five best-selling products by total
quantity sold, using the `TransactionDetail` relationship and
aggregate functions (`sum`, `groupBy`), not by
pulling every row and tallying it manually in PHP.
]

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for Eloquent relationships, eager loading, and
pagination.
