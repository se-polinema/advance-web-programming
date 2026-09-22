# Group Practicum Jobsheet: Meeting 5
## Eloquent ORM, Relationship, and Pagination (Group Work)

| | |
|---|---|
| **Course** | Advanced Web Programming (SIB245007) |
| **Meeting** | 5 (Week 5) |
| **Duration** | 2 sessions &times; 170 minutes |
| **Sub-CPMK** | Sub-CPMK 2: Students can apply models, templating, and CRUD operations in framework-based web application development. |
| **Work Mode** | Group (same as Meeting 3 and 4), one shared GitHub repository per group |
| **Starting Code** | your group's repository from Meeting 4 (continue its `main`) |

## A. Practicum Outcomes

After completing this group jobsheet, you'll be able to:

1. Define `hasMany`/`belongsTo` relationships on the `Category`, `Product`, `Transaction`, and `TransactionDetail` models.
2. Display a product listing and a transaction history with eager loading and `paginate()`.
3. Prove the N+1 problem via a query log, then fix it with eager loading.
4. Prove `paginate()` works correctly by comparing IDs across pages in tinker.

## B. Preparation and Prerequisites

- **Tools**: same as Meeting 4 (PHP 8.2+, Composer, Node.js, Git).
- **Git identity**: already set up since Meeting 3. If you switch laptops or use a lab machine, redo the `git config --global user.name`/`user.email` check from that jobsheet.
- **Continuing the code**: the group continues from its shared GitHub repository from Meeting 4, from a `main` that already contains `increment 4`. If your group's repository has problems, start from the `simple-pos-ch04` template (`https://github.com/se-polinema/simple-pos-ch04`, created via **Use this template** as in Meeting 3's Step 1). This template already matches Meeting 4's end state exactly, so there's no need to redo any step before continuing this jobsheet, just keep in mind that a repository created from a template only has a single commit in its history, not the full `increment 1` through `increment 4` history a real group repository has.
- **Quick check** before starting:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  ```
  > ✅ **Checkpoint:** the top line shows the `increment 4: ...` commit (or a single starting commit if you used the template).

## C. Work Steps

Same workflow as Meeting 3 and 4: each build step (Step 2 through 5) happens on its own branch off `main`, gets merged via a Pull Request using **Create a merge commit** (not squash), then everyone `git pull`s before starting the next branch.

### Step 1: Mapping relationships on paper

Before writing code, sketch the following relationship table on paper or a whiteboard, and agree who will work on which model:

| Model | Relationship | Related Model |
|---|---|---|
| `Category` | `hasMany` | `Product` |
| `Product` | `belongsTo` | `Category` |
| `Transaction` | `hasMany` | `TransactionDetail` |
| `Transaction` | `belongsTo` | `User` (the cashier who processed it) |
| `TransactionDetail` | `belongsTo` | `Transaction` and `Product` |

> ✅ **Checkpoint:** the group has a relationship table sketched on paper/whiteboard, and Steps 2-5 are divided up and agreed on.

### Step 2: `Category` and `Product` relationships

Create a new branch off the latest `main`, e.g. `category-product-relationships`:

```bash
git checkout main
git pull
git checkout -b category-product-relationships
```

Both models already exist since Meeting 4, but are still empty (no relationships). Replace the entire contents of `app/Models/Category.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }
}
```

Replace the entire contents of `app/Models/Product.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Product extends Model
{
    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
```

```bash
git add .
git commit -m "tambah relationship category dan product"
git push -u origin category-product-relationships
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** open `php artisan tinker`, then:
> ```
> >>> Category::first()->products()->count();
> => 75
> >>> Product::find(1)->category->name;
> => "Makanan"
> ```

> ⚠️ **If it fails:** a `Call to undefined method` error means the relationship method name is misspelled, or the `use` for the relation class (`HasMany`/`BelongsTo`) is missing at the top of the file.

### Step 3: `Transaction` and `TransactionDetail` models

Create a new branch, e.g. `transaction-models`:

```bash
git checkout main
git pull
git checkout -b transaction-models
php artisan make:model Transaction
php artisan make:model TransactionDetail
```

Neither model has been created before, their migrations have existed since Meeting 4 but not the models themselves. Fill in `app/Models/Transaction.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Transaction extends Model
{
    public function details(): HasMany
    {
        return $this->hasMany(TransactionDetail::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
```

Fill in `app/Models/TransactionDetail.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

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
```

The `transaction_details` table name is already guessed automatically by Eloquent from the `TransactionDetail` class name: converted to snake_case (`transaction_detail`), then pluralized (`transaction_details`), exactly the convention already covered in the slides.

```bash
git add .
git commit -m "tambah model transaction dan transaction detail beserta relationship-nya"
git push -u origin transaction-models
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** open `php artisan tinker`, then:
> ```
> >>> Transaction::first()->user->name;
> => "Test User"
> ```

### Step 4: Product listing with pagination

`ProductController` has existed since the `simple-pos-ch02` template (Meeting 2), containing a production version that calls a few things you haven't built yet (form requests, image upload, stock adjustment). Just like `TransactionController` in Meeting 3, simplify it first so it matches what you've actually built.

Create a new branch, e.g. `product-listing`:

```bash
git checkout main
git pull
git checkout -b product-listing
```

Replace the entire contents of `app/Http/Controllers/ProductController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Product;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::with('category')
            ->orderBy('name')
            ->paginate(10);

        return view('products.index', compact('products'));
    }

    public function create()
    {
        return 'Form tambah produk (belum dibuat)';
    }

    public function store()
    {
        return 'Produk disimpan (belum ada logika penyimpanan)';
    }

    public function edit(string $id)
    {
        return "Form edit produk #{$id} (belum dibuat)";
    }

    public function update(string $id)
    {
        return "Produk #{$id} diperbarui (belum ada logika penyimpanan)";
    }
}
```

Create the view via artisan:

```bash
php artisan make:view products.index
```

Fill in `resources/views/products/index.blade.php`:

```php
@extends('layouts.app')

@section('title', 'Produk')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Daftar Produk</h1>
    <table class="w-full text-left border-collapse">
        <thead>
            <tr class="border-b">
                <th class="py-2 pr-4">Nama</th>
                <th class="py-2 pr-4">Kategori</th>
                <th class="py-2 pr-4">Harga</th>
                <th class="py-2 pr-4">Stok</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($products as $product)
                <tr class="border-b">
                    <td class="py-2 pr-4">{{ $product->name }}</td>
                    <td class="py-2 pr-4">{{ $product->category->name }}</td>
                    <td class="py-2 pr-4">Rp {{ number_format($product->price) }}</td>
                    <td class="py-2 pr-4">{{ $product->stock }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <div class="mt-4">
        {{ $products->links() }}
    </div>
@endsection
```

Add a navigation link to `resources/views/components/nav.blade.php`, inserting one new line before the closing `</nav>`:

```php
<a href="{{ route('products.index') }}" class="hover:underline">Produk</a>
```

```bash
git add .
git commit -m "tambah listing produk dengan eager loading dan pagination"
git push -u origin product-listing
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** opening `/products` shows a table of 10 products with the category name filled in (not an error), along with page navigation below it. Open `php artisan tinker`:
> ```
> >>> $p1 = Product::orderBy('name')->paginate(10)->pluck('id');
> >>> $p2 = Product::orderBy('name')->paginate(10, ['*'], 'page', 2)->pluck('id');
> >>> $p1->intersect($p2)->count();
> => 0
> ```

> ⚠️ **If it fails:** `View [products.index] not found` means `make:view` wasn't run or the folder name is wrong. An `Undefined property: $product->category` error means Step 2's relationship (`Product::category()`) hasn't been merged or pulled yet.

### Step 5: Transaction history and the N+1 problem

The `index()` method in `TransactionController` is still the placeholder `return 'Daftar transaksi';` from Meeting 3. It's time to fill it in with a real query, and prove the N+1 problem already covered in the slides along the way.

Create a new branch, e.g. `transaction-history`:

```bash
git checkout main
git pull
git checkout -b transaction-history
```

Replace the `index()` method in `app/Http/Controllers/TransactionController.php` (the `create`, `store`, and `show` methods stay as they were), and add `use App\Models\Transaction;` at the top of the file:

```php
public function index()
{
    $transactions = Transaction::latest()->paginate(15);

    return view('transactions.index', compact('transactions'));
}
```

Create the view via artisan:

```bash
php artisan make:view transactions.index
```

Fill in `resources/views/transactions/index.blade.php`:

```php
@extends('layouts.app')

@section('title', 'Riwayat Transaksi')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Riwayat Transaksi</h1>

    @foreach ($transactions as $transaction)
        <div class="border rounded-md p-3 mb-3">
            <p class="font-medium">
                Transaksi #{{ $transaction->id }}
                &middot; {{ $transaction->created_at->format('d M Y H:i') }}
                &middot; Rp {{ number_format($transaction->total) }}
            </p>
            <ul class="text-sm text-slate-500 mt-1">
                @foreach ($transaction->details as $detail)
                    <li>{{ $detail->product->name }} &times; {{ $detail->qty }} = Rp {{ number_format($detail->subtotal) }}</li>
                @endforeach
            </ul>
        </div>
    @endforeach

    <div class="mt-4">
        {{ $transactions->links() }}
    </div>
@endsection
```

```bash
git add .
git commit -m "tambah riwayat transaksi dengan pagination"
```

Don't push yet. Open `/transactions` in the browser (the page still works, because the `details`/`product` relationships are already defined, just not eager-loaded yet), then prove the N+1 problem via a query log:

```bash
php artisan tinker
>>> use Illuminate\Support\Facades\DB;
>>> DB::enableQueryLog();
>>> $transactions = Transaction::latest()->paginate(15);
>>> foreach ($transactions as $t) { foreach ($t->details as $d) { $d->product->name; } }
>>> count(DB::getQueryLog());
```

> ✅ **Checkpoint:** the result is dozens of queries (the exact number varies depending on data order, around 57 in our test run), far more than the 15 transactions being displayed. This is the N+1 problem: one separate relationship query per row, plus one for every detail inside it.

Now fix it with eager loading. Change the `Transaction::latest()->paginate(15)` line in `TransactionController::index()` to:

```php
$transactions = Transaction::with('details.product')
    ->latest()
    ->paginate(15);
```

```bash
git add .
git commit -m "perbaiki n+1 dengan eager loading"
git push -u origin transaction-history
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** repeat the same query log measurement (with `with('details.product')` this time). The result drops to 4 total queries: one to count the total transactions (used by `paginate()` to compute the page count), one for the transaction list, one for all their details, and one for all their products at once, not dozens of separate queries. This number is a bit higher than the 2 queries in the slide's simple example, because `paginate()` adds one count query on top of the basic eager loading.

> ⚠️ **If it fails:** if the query count is still in the dozens after adding `with()`, check whether `$d->product->name` inside the foreach really accesses `$detail->product` (the loaded relationship), rather than silently triggering a new query because of a typo in the property name.

### Step 6: Together, integration test and code review

Everyone runs `git checkout main && git pull`, `php artisan migrate:fresh --seed`, then repeats every checkpoint on their own laptop: the relationships in tinker, `/products` with pagination, and the `/transactions` query log before/after eager loading. After that, the group reads through the code together: each member explains one model or controller that they **didn't** write themselves.

> ✅ **Checkpoint:** every checkpoint above can be repeated and shows exactly the same result on every member's laptop.

### Step 7: Group independent challenges and the `increment 5` commit

Split the following tasks among the group's members, so each member gets at least one meaningful commit recorded through their own Pull Request:

- Show the cashier's name on `/transactions` by adding `'user'` to `with(['details.product', 'user'])`, then display `$transaction->user->name` in the view.
- Add a `belongsToMany` relationship from `Product` to `Transaction` via the `transaction_details` pivot, then prove it in tinker via `Product::find(1)->transactions()->count()`.
- Add a `Product::details(): HasMany` method (to `TransactionDetail`), then compute a product's total units sold via `Product::find(1)->details()->sum('qty')` in tinker.
- Change the product grid on `/pos` from `Product::take(12)->get()` to `Product::paginate(12)` along with `{{ $products->links() }}` in the view, then prove page 2 shows different products.
- Show the item count per transaction on `/transactions` via `$transaction->details->sum('qty')` (no extra query needed, since `details` is already eager-loaded).

For each task: create a new branch (e.g. `cashier-name`), do the work, commit, push, then open and merge its Pull Request (follow Meeting 3's Step 3 workflow).

Once every Pull Request is in and merged, one member closes out the group's work:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 5: relationship eloquent, eager loading, dan pagination simple pos"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** the top line of `git log --pretty="%h %an %s"` shows `increment 5: ...`, and the lines below it show every group member's name.

## D. Deliverables

Submit the following in the format your instructor requests:

- Link to the group's GitHub repository.
- Screenshot of the `/products` page (with page numbers visible) and `/transactions`.
- Screenshot of tinker output: the relationship check (`Category::first()->products()->count()`), the two-page pluck comparison, and the query log count before/after eager loading.
- Output of `git log --pretty="%h %an %s"` showing at least one commit per member.
- A task-division table: member name | step/task done | commit hash.

## E. Grading Rubric

| Component | Weight | Full Marks (100%) | Minimum Marks |
|---|---:|---|---|
| Work steps completed (group) | 40% | Steps 1-7 done, `/products` and `/transactions` work with eager loading | Most steps done, both pages display |
| Checkpoints verified (group) | 25% | Tinker screenshots, query log, and a complete, correct git log | Some checkpoints proven |
| Per-member contribution (individual) | 25% | At least one meaningful commit under each member's name, matching the task-division table | Commits exist but are small or their relevance is unclear |
| Repository and commit hygiene | 10% | `increment 5` message exact, no `vendor/`, `node_modules/`, `.env`, PRs merged cleanly (not squashed) | Commits exist, but the message is messy or a PR was squashed |
