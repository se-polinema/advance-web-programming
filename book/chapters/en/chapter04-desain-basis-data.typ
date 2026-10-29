#import "/template.typ": *

= Database Design, Migrations, and Seeding <ch:desain-basis-data>

#chapterhero("teal", [Design the Simple POS database schema, fill it with realistic-scale seed data, then prove why a foreign key index is not optional.], [#icon("database")#h(1em)the Simple POS schema], [#icon("table")#h(1em)migrations & seeding], [#icon("key")#h(1em)FK indexes])

A well-run grocery warehouse puts every item on a labeled shelf, backed
by a card catalog recording which shelf holds what. A new worker
looking for a bag of sugar just reads the catalog, walks straight to the
right shelf, no need to comb through the entire warehouse row by row.
A warehouse without that catalog still works, the item is somewhere in
there, but finding it means walking down shelf after shelf until it
turns up. The Simple POS database runs on the same logic: the table
schema is the shelf layout itself, and an index is the card catalog.
Without the right index on a frequently searched column, the database
engine can still find the row, just by walking through the whole table
one row at a time, and on a table holding thousands of transaction rows
that difference is no longer theoretical.

#strong[What You'll Learn]

+ design the Simple POS database schema (`categories`, `products`, `transactions`, `transaction_details`) and its relationships;
+ write migrations and a realistic-scale seeder (300 products, 2,500 transactions) using bulk inserts through `DB::table()->insert()` in batches, rather than `Model::create()` one row at a time;
+ explain why `constrained()` on SQLite does not automatically index a foreign key column, its impact on the product listing query, and how to verify it with `EXPLAIN QUERY PLAN`.

== Designing the Simple POS Schema <sec:desain-basis-data-1>

#istilahpenting[
/ Migration: A PHP file describing a structural change to a table (creating, altering, or dropping columns) programmatically, so the database schema has a history that can be replayed on any other machine.
/ Schema: The design of a table's structure: column names, data types, and constraints (nullable, default, unique) that apply to every row in it.
/ Foreign Key: A column on one table pointing to the `id` of a row on another table, guaranteeing a `transaction_details` row can never point at a product that does not exist.
/ Index: An additional data structure the database engine builds over one or more columns, speeding up lookups on that column without scanning the entire table.
/ Seeder: A PHP class that fills a table with initial or test data, run through `db:seed` or as part of `migrate:fresh --seed`.
]

Simple POS rests on four core tables, and their relationships are
straightforward enough to sketch on paper before a single line of
migration gets written. One `categories` has many
`products`. One `products` can show up across many
`transaction_details`, and one `transactions` also has
many `transaction_details`, each recording one line item that
was purchased. `transactions` itself points back to
`users`, recording which cashier processed that transaction.

#figure(
  table(
    columns: (0.9fr, 2.1fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [Table], [Main columns],
    table.hline(stroke: 0.5pt),
    [`categories`], [`id`, `name`],
    [`products`], [`id`, `category_id` (fk), `name`, `price`, `stock`],
    [`transactions`], [`id`, `user_id` (fk), `total`, `created_at`],
    [`transaction_details`], [`id`, `transaction_id` (fk), `product_id` (fk), `qty`, `subtotal`],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Column schema of Simple POS's four core tables],
) <tab:skema-inti>

Notice that `transactions.total` and
`transaction_details.subtotal` are stored columns, not values
recomputed every time they're read. That's a deliberate choice: a
transaction's total must stay exactly what it was at the moment that
transaction happened, even if a product's price changes later.
Chapter~6 covers why this value also has to be recalculated on the
server when the transaction gets saved, rather than trusted outright
from input.

#listing(file: "database/migrations/2026_08_20_122440_create_products_table.php", ```php
Schema::create('products', function (Blueprint $table) {
    $table->id();
    $table->foreignId('category_id')->constrained();
    $table->string('name');
    $table->unsignedInteger('price');
    $table->unsignedInteger('stock')->default(0);
    $table->timestamps();
});
```)

`foreignId('category_id')->constrained()` is a pairing used
together often: the first line creates a `category_id` column as
an unsigned big integer, the second adds a foreign key constraint
pointing at `categories.id` based on Laravel's naming
convention. This constraint protects data integrity, preventing a
product row from pointing at a category that was already deleted, but
as the Practice section shows, that does not automatically mean the
column already has an index.

== Migrations and Realistic-Scale Seeding <sec:desain-basis-data-2>

The Simple POS seeder fills the database with 300 products and 2,500
transactions, each with several `transaction_details` rows.
Writing that seeder by calling `Product::create()` 300 times
inside a loop would run, but every `Model::create()` call
opens its own `INSERT` query against the database, plus the
overhead of building an Eloquent object, firing model events, and
recomputing attributes. For a seed at the scale of hundreds or
thousands of rows, that overhead piles up fast.

#listing(file: "database/seeders/DatabaseSeeder.php", ```php
$products = [];
foreach ($categoryIds as $categoryId) {
    for ($i = 0; $i < 30; $i++) {
        $products[] = [
            'category_id' => $categoryId,
            'name' => fake()->words(2, true),
            'price' => fake()->numberBetween(5000, 50000),
            'stock' => fake()->numberBetween(0, 200),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }
}

foreach (array_chunk($products, 50) as $chunk) {
    DB::table('products')->insert($chunk);
}
```)

`DB::table()->insert()` skips the Eloquent layer entirely: it
builds a single `INSERT` statement that writes many rows at
once, far fewer database round-trips than one query per row.
`array_chunk()` splits the large array into smaller groups before
inserting, because some database engines cap the number of rows or
parameters allowed in a single `INSERT` statement; SQLite itself
is fairly forgiving, but the habit of chunking by batch still pays off
the day the same seeder runs against MySQL or PostgreSQL instead.

#warningbox[
Seeding transactions needs extra care: one transaction consists of a
`transactions` row plus several `transaction_details`
rows that must stay consistent with each other. Wrap the transaction
insert and its details in a single
`DB::transaction(function () { ... })`. If the process fails
partway through, say because randomly generated data turned out
invalid, every change inside that block rolls back together, so the
database never ends up with a transaction recorded but half its details
missing.
]

== Practice: Foreign Key Indexes and EXPLAIN QUERY PLAN <sec:desain-basis-data-3>

`foreignId()->constrained()` on MySQL does automatically create an
index on that column as a side effect, but Simple POS uses SQLite for
development, and on SQLite `constrained()` only adds the foreign
key constraint, not an index. The constraint protects data integrity
(rejecting an insert that points at a row that doesn't exist), but it
doesn't speed up lookups. The product listing query behind the
`/products` page filters on `WHERE category_id = ?`.
Without an explicit index on that column, SQLite is forced to scan the
entire `products` table row by row to find the matching rows.

`EXPLAIN QUERY PLAN` is a SQLite command that shows the strategy
the database engine would use to run a query, without actually
executing it. The steps below prove the difference before and after
adding the index, using the database already filled by the seeder from
the previous section.

+ Make sure the database is already seeded (if not, run
      `php artisan migrate:fresh --seed` first), then look at the
      state #emph[before] an explicit index exists:

  #listing(```bash
  sqlite3 database/database.sqlite \
    "EXPLAIN QUERY PLAN SELECT * FROM products WHERE category_id = 3;"
    
  ```)

  #strong[What to expect]: the result row includes the words
      `SCAN products`, a sign SQLite is scanning the whole table
      from the first row to the last to find a match.
+ Create a new migration dedicated to the index (don't edit an
      old migration that already ran):

  #listing(```bash
  php artisan make:migration add_index_to_products_and_transactions_table
    
  ```)
+ Open the newly created migration file in
      `database/migrations/`, and fill in its `up()` method:

  #listing(```php
  public function up(): void
  {
      Schema::table('products', function (Blueprint $table) {
          $table->index('category_id');
      });

      Schema::table('transactions', function (Blueprint $table) {
          $table->index('user_id');
          $table->index('created_at');
      });
  }
    
  ```)
+ Run that migration. Use `php artisan migrate`, not
      `php artisan migrate:fresh`, so the index gets added on top
      of the existing seeded data instead of wiping everything again:

  #listing(```bash
  php artisan migrate
    
  ```)
+ Run the exact same `EXPLAIN QUERY PLAN` command from step 1
      again. #strong[What to expect]: the result row now changes to
      `SEARCH products USING INDEX
      products_category_id_index`, a sign SQLite jumped straight to
      the relevant rows through the index structure, never touching the
      other rows at all.
+ #strong[If the `sqlite3` command isn't recognized] (not
      installed on the system), use the alternative route through Tinker
      with nothing extra to install:

  #listing(```bash
  php artisan tinker
  >>> DB::select("EXPLAIN QUERY PLAN SELECT * FROM products WHERE category_id = 3");
    
  ```)

  The result is an associative array; its `detail` column
      holds the same `SCAN`/`SEARCH` text as the
      `sqlite3` CLI.

#warningbox[
On a table with a few dozen rows, the difference between `SCAN`
and `SEARCH` is barely noticeable. On a table with thousands of
rows, like Simple POS's `transactions` table after a full seed,
`SCAN` means every row gets examined on every single query, and
that time grows linearly as the table grows. An index isn't premature
optimization here; it's a fix for a performance bug that's already real
the moment data approaches production scale.
]

#branchref("chapter-04")

== Summary <sec:desain-basis-data-rangkuman>

- Simple POS consists of four core tables,
      `categories`--`products`--`transactions`--
      `transaction_details`, connected by foreign keys, with
      `total` and `subtotal` stored as fixed values rather
      than recomputed every time they're read.
- Realistic-scale seeding (300 products, 2,500 transactions) uses
      `DB::table()->insert()` in batches through
      `array_chunk()`, far more efficient than calling
      `Model::create()` one row at a time, and inserting a
      transaction alongside its details is wrapped in a single
      `DB::transaction()`.
- `constrained()` on SQLite does not automatically create an
      index; a foreign key index has to be added explicitly through
      `$table->index()`, and the difference can be proven directly
      with `EXPLAIN QUERY PLAN`, which changes from `SCAN` to
      `SEARCH ... USING INDEX` once the index is added.

== Exercises

+ Add an index on `transaction_details.product_id`, then
      run `EXPLAIN QUERY PLAN` on a query that looks up every
      transaction detail row for one particular product. Compare the
      result before and after the index is added.
+ Work it out: if the seeder were changed to 1,000 products and
      10,000 transactions, roughly how many `transaction_details`
      rows would that produce, assuming an average of 3 items per
      transaction?
+ Write one new listing query for Simple POS (for example,
      transactions within a date range), then run `EXPLAIN QUERY
      PLAN` on that query itself to check whether it uses an existing
      index.
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) why a transaction's `total`
      is stored instead of recomputed, (b) why bulk inserts were chosen
      for large-scale seeding, and (c) what `constrained()` actually
      adds on SQLite. Check your answers against this chapter.

#challengebox[
Add a new `sku` column (string, unique, nullable) to the
`products` table through a new migration, not by editing an old
migration that already ran. Run `migrate` and confirm the
schema changes with no need for `migrate:fresh`.
]

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for migration, query builder, and seeder
conventions.
