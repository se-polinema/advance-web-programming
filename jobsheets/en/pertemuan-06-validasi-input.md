# Group Practicum Jobsheet: Meeting 6
## Input Validation and Security (Group Work)

| | |
|---|---|
| **Course** | Advanced Web Programming (SIB245007) |
| **Meeting** | 6 (Week 6) |
| **Duration** | 2 sessions &times; 170 minutes |
| **Sub-CPMK** | Sub-CPMK 2: Students can apply models, templating, and CRUD operations in framework-based web application development. |
| **Work Mode** | Group (same as Meeting 3-5), one shared GitHub repository per group |
| **Starting Code** | your group's repository from Meeting 5 (continue its `main`) |

## A. Practicum Outcomes

After completing this group jobsheet, you'll be able to:

1. Protect a model from unwanted mass assignment via `$fillable`.
2. Write `StoreProductRequest` and `StoreTransactionRequest` to validate input before the controller receives it.
3. Recompute a transaction's total on the server from prices stored in the database, never from client input.
4. Show per-field error messages and a success flash message in Blade.

## B. Preparation and Prerequisites

- **Tools**: same as Meeting 5 (PHP 8.2+, Composer, Node.js, Git).
- **Git identity**: already set up since Meeting 3. If you switch laptops or use a lab machine, redo the `git config --global user.name`/`user.email` check from that jobsheet.
- **Continuing the code**: the group continues from its shared GitHub repository from Meeting 5, from a `main` that already contains `increment 5`. If your group's repository has problems, start from the `simple-pos-ch05` template (`https://github.com/se-polinema/simple-pos-ch05`, created via **Use this template** as in Meeting 3's Step 1). This template already matches Meeting 5's end state exactly, so there's no need to redo any step before continuing this jobsheet.
- **Quick check** before starting:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  ```
  > ✅ **Checkpoint:** the top line shows the `increment 5: ...` commit (or a single starting commit if you used the template).

## C. Work Steps

Same workflow as Meeting 3-5: each build step (Step 2 through 5) happens on its own branch off `main`, gets merged via a Pull Request using **Create a merge commit** (not squash), then everyone `git pull`s before starting the next branch.

### Step 1: Mapping validation rules on paper

Before writing code, agree on the validation rules for the two forms you're about to build:

| Form | Field | Rule |
|---|---|---|
| Add product | `name` | required, string, max 255 characters |
| Add product | `category_id` | required, must exist in the `categories` table |
| Add product | `price`, `stock` | required, integer, minimum 0 |
| Cashier transaction | `items` | required, array, minimum 1 row |
| Cashier transaction | `items.*.product_id` | required, must exist in the `products` table |
| Cashier transaction | `items.*.qty` | required, integer, minimum 1 |

> ✅ **Checkpoint:** the group has the rule table above sketched on paper/whiteboard, and Steps 2-5 are divided up and agreed on.

### Step 2: `$fillable` on the models

Try opening `php artisan tinker` right now and running `Product::create(['name' => 'Test'])`. You'll get a `MassAssignmentException`, because none of these three models have `$fillable` yet. Fix that before moving on.

Create a new branch off the latest `main`, e.g. `fillable-models`:

```bash
git checkout main
git pull
git checkout -b fillable-models
```

Add one line near the top of each model's class body. Fill in `app/Models/Product.php`, adding it right below the `class Product extends Model` line:

```php
protected $fillable = ['category_id', 'name', 'price', 'stock'];
```

Fill in `app/Models/Transaction.php`, right below `class Transaction extends Model`:

```php
protected $fillable = ['user_id', 'total'];
```

Fill in `app/Models/TransactionDetail.php`, right below `class TransactionDetail extends Model`:

```php
protected $fillable = ['transaction_id', 'product_id', 'qty', 'subtotal'];
```

```bash
git add .
git commit -m "tambah fillable pada product, transaction, dan transaction detail"
git push -u origin fillable-models
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** repeat `Product::create(['category_id' => 1, 'name' => 'Test', 'price' => 1000, 'stock' => 5])` in tinker, this time it succeeds with no exception.

> ⚠️ **If it fails:** if it's still a `MassAssignmentException`, make sure the column names in `$fillable` match the migration's column names exactly, and that there's no typo in which model you edited.

### Step 3: `StoreProductRequest` and the add-product form

Create a new branch, e.g. `product-form-validation`:

```bash
git checkout main
git pull
git checkout -b product-form-validation
php artisan make:request StoreProductRequest
```

Replace the entire contents of `app/Http/Requests/StoreProductRequest.php`:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['required', 'exists:categories,id'],
            'price' => ['required', 'integer', 'min:0'],
            'stock' => ['required', 'integer', 'min:0'],
        ];
    }
}
```

The generator's default `authorize()` always returns `false` (rejecting everyone), so don't forget to change it to `true` as shown above, otherwise the form will always be rejected with a 403 error even when the data is valid.

Replace the entire contents of `app/Http/Controllers/ProductController.php`:

```php
<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreProductRequest;
use App\Models\Category;
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
        $categories = Category::orderBy('name')->get();

        return view('products.create', compact('categories'));
    }

    public function store(StoreProductRequest $request)
    {
        Product::create($request->validated());

        return redirect()
            ->route('products.index')
            ->with('success', 'Produk berhasil ditambahkan.');
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
php artisan make:view products.create
```

Fill in `resources/views/products/create.blade.php`:

```php
@extends('layouts.app')

@section('title', 'Tambah Produk')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Tambah Produk</h1>

    <form method="POST" action="{{ route('products.store') }}" class="max-w-md">
        @csrf

        <label class="block mb-3">
            <span class="text-sm font-medium">Nama</span>
            <input type="text" name="name" value="{{ old('name') }}" class="mt-1 block w-full rounded-md border-gray-300">
            @error('name')
                <p class="text-sm text-red-600">{{ $message }}</p>
            @enderror
        </label>

        <label class="block mb-3">
            <span class="text-sm font-medium">Kategori</span>
            <select name="category_id" class="mt-1 block w-full rounded-md border-gray-300">
                @foreach ($categories as $category)
                    <option value="{{ $category->id }}" @selected(old('category_id') == $category->id)>{{ $category->name }}</option>
                @endforeach
            </select>
            @error('category_id')
                <p class="text-sm text-red-600">{{ $message }}</p>
            @enderror
        </label>

        <label class="block mb-3">
            <span class="text-sm font-medium">Harga</span>
            <input type="number" name="price" value="{{ old('price') }}" class="mt-1 block w-full rounded-md border-gray-300">
            @error('price')
                <p class="text-sm text-red-600">{{ $message }}</p>
            @enderror
        </label>

        <label class="block mb-3">
            <span class="text-sm font-medium">Stok</span>
            <input type="number" name="stock" value="{{ old('stock') }}" class="mt-1 block w-full rounded-md border-gray-300">
            @error('stock')
                <p class="text-sm text-red-600">{{ $message }}</p>
            @enderror
        </label>

        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded-md">Simpan</button>
    </form>
@endsection
```

Add a flash message and a link to the new form in `resources/views/products/index.blade.php`, inserting it right before `<table class="w-full text-left border-collapse">`:

```php
@if (session('success'))
    <div class="bg-green-50 text-green-700 p-3 rounded-md mb-4">
        {{ session('success') }}
    </div>
@endif

<a href="{{ route('products.create') }}" class="inline-block mb-4 bg-blue-600 text-white px-4 py-2 rounded-md">Tambah Produk</a>
```

```bash
git add .
git commit -m "tambah validasi dan form tambah produk"
git push -u origin product-form-validation
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** open `/products/create`, click Simpan without filling in anything. The page returns to the same form with a red error message under each empty field. Fill in every field correctly, click Simpan again: the page moves to `/products` with a green "Produk berhasil ditambahkan." message, and your new product shows up in the table.

> ⚠️ **If it fails:** `Class "App\Http\Requests\StoreProductRequest" not found` means `use App\Http\Requests\StoreProductRequest;` wasn't added or has the wrong name. A blank white page with no error message means `authorize()` is still `false`.

### Step 4: Turning the cashier cart into a real form

Since Meeting 3, the `/pos` page has only ever collected items through Alpine without actually sending them to the server. It's time for that cart to become a real HTML form.

Create a new branch, e.g. `transaction-form-validation`:

```bash
git checkout main
git pull
git checkout -b transaction-form-validation
php artisan make:request StoreTransactionRequest
```

Replace the entire contents of `app/Http/Requests/StoreTransactionRequest.php`:

```php
<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'exists:products,id'],
            'items.*.qty' => ['required', 'integer', 'min:1'],
        ];
    }
}
```

Replace the entire contents of `resources/views/pos/create.blade.php`. Notice three additions compared to the Meeting 3 version: everything is wrapped in a `<form>` with `@csrf`, each cart item produces two hidden inputs (`items[index][product_id]` and `items[index][qty]`), and there's now a Bayar button:

```php
@extends('layouts.app')

@section('title', 'Kasir')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Transaksi Kasir</h1>

    @if (session('success'))
        <div class="bg-green-50 text-green-700 p-3 rounded-md mb-4">
            {{ session('success') }}
        </div>
    @endif

    @error('items')
        <div class="bg-red-50 text-red-700 p-3 rounded-md mb-4">{{ $message }}</div>
    @enderror

    <form method="POST" action="{{ route('transactions.store') }}" x-data="{
        cart: [],
        addToCart(id, name, price) {
            this.cart.push({ id, name, price });
        },
        subtotal() {
            return this.cart.reduce((sum, item) => sum + item.price, 0);
        }
    }">
        @csrf
        <div class="grid grid-cols-3 gap-4">
            @foreach ($products as $product)
                <div class="border rounded-md p-3 cursor-pointer"
                     @click="addToCart({{ $product->id }}, '{{ $product->name }}', {{ $product->price }})">
                    <p class="font-medium">{{ $product->name }}</p>
                    <p class="text-sm text-slate-500">Rp {{ number_format($product->price) }}</p>
                </div>
            @endforeach
        </div>

        <div class="mt-4 border-t pt-3">
            <template x-for="(item, index) in cart" :key="index">
                <div>
                    <p x-text="item.name + ' - Rp ' + item.price"></p>
                    <input type="hidden" :name="'items[' + index + '][product_id]'" :value="item.id">
                    <input type="hidden" :name="'items[' + index + '][qty]'" value="1">
                </div>
            </template>
            <p class="font-semibold mt-2">Subtotal: Rp <span x-text="subtotal()"></span></p>
            <button type="submit" class="mt-3 bg-blue-600 text-white px-4 py-2 rounded-md">Bayar</button>
        </div>
    </form>
@endsection
```

Every click on a product card adds one row to `cart` with qty fixed at 1, so clicking the same product twice produces two separate `items` rows rather than one row with qty 2. That's fine for this meeting; merging duplicate clicks into a single row with an incremented qty can be an independent challenge.

Replace the `store()` method in `app/Http/Controllers/TransactionController.php`, and add `use` statements for `StoreTransactionRequest`, `TransactionDetail`, and `DB` at the top of the file:

```php
use App\Http\Requests\StoreTransactionRequest;
use App\Models\TransactionDetail;
use Illuminate\Support\Facades\DB;

// ...

public function store(StoreTransactionRequest $request)
{
    $validated = $request->validated();

    DB::transaction(function () use ($validated) {
        $transaction = Transaction::create([
            'user_id' => 1, // temporarily hardcoded, no real login yet until Meeting 7
            'total' => 0,
        ]);

        $total = 0;

        foreach ($validated['items'] as $item) {
            $product = Product::findOrFail($item['product_id']);
            $subtotal = $product->price * $item['qty'];
            $total += $subtotal;

            TransactionDetail::create([
                'transaction_id' => $transaction->id,
                'product_id' => $product->id,
                'qty' => $item['qty'],
                'subtotal' => $subtotal,
            ]);
        }

        $transaction->update(['total' => $total]);
    });

    return redirect()
        ->route('pos.create')
        ->with('success', 'Transaksi berhasil disimpan.');
}
```

`user_id` is deliberately hardcoded to `1` (the seeder's Test User): Simple POS doesn't have a real login system yet, that's Meeting 7's topic. `DB::transaction()` wraps everything so that if any row fails to save, the whole transaction rolls back together instead of being saved half-finished.

```bash
git add .
git commit -m "tambah validasi dan total di server untuk transaksi"
git push -u origin transaction-form-validation
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** open `/pos`, click the Bayar button without clicking any product first. The page returns to `/pos` with a red "required" error message for `items`. Click two products, then click Bayar: the page returns to `/pos` with a green "Transaksi berhasil disimpan." message. Open `php artisan tinker`:
> ```
> >>> Transaction::latest()->first()->total;
> ```
> Compare that number against the two products' prices added together, it must match exactly.

> ⚠️ **If it fails:** a transaction that saves but has `total` of 0 means `$transaction->update(['total' => $total])` got called before the `foreach` loop finished, or it's outside the `DB::transaction()` closure. A `Call to undefined method items` error on the form means the hidden inputs' `:name` attribute has a typo.

### Step 5: Together, integration test and code review

Everyone runs `git checkout main && git pull`, `php artisan migrate:fresh --seed`, then repeats every checkpoint on their own laptop: `$fillable` in tinker, the add-product form, and the cashier form. After that, the group reads through the code together: each member explains one FormRequest or part of a controller that they **didn't** write themselves.

> ✅ **Checkpoint:** every checkpoint above can be repeated and shows exactly the same result on every member's laptop.

### Step 6: Group independent challenges and the `increment 6` commit

Split the following tasks among the group's members, so each member gets at least one meaningful commit recorded through their own Pull Request:

- Merge quantities per product in the cashier cart: if the same product is clicked twice, increase the `qty` on the existing `cart` row instead of adding a new one.
- Add a sufficient-stock validation rule to `StoreTransactionRequest` or the controller: reject the transaction if the requested `qty` exceeds that product's current `stock`, complete with an error message naming the product.
- Finish `ProductController::edit()`/`update()` following the `create()`/`store()` pattern: build `resources/views/products/edit.blade.php` and validate through the same `StoreProductRequest`.
- Send a `POST /pos` request via curl with `qty` set to `0` and a `product_id` that doesn't exist, then observe what error message Laravel returns for each case.
- Explain in your own words (write it in a README or a separate document): if the `total` field were still sent from the form and validated with a `numeric` rule, would that be enough to prevent total manipulation? Why or why not?

For each task: create a new branch (e.g. `merge-cart-qty`), do the work, commit, push, then open and merge its Pull Request (follow Meeting 3's Step 3 workflow).

Once every Pull Request is in and merged, one member closes out the group's work:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 6: validasi form request dan total di server simple pos"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** the top line of `git log --pretty="%h %an %s"` shows `increment 6: ...`, and the lines below it show every group member's name.

## D. Deliverables

Submit the following in the format your instructor requests:

- Link to the group's GitHub repository.
- Screenshot of the add-product form with an error message (a failed attempt) and with a success message (a successful attempt).
- Screenshot of the `/pos` page with the `items` error message (empty cart) and with the success message after a saved transaction.
- Screenshot of tinker output: the latest transaction's total compared against a manual calculation.
- Output of `git log --pretty="%h %an %s"` showing at least one commit per member.
- A task-division table: member name | step/task done | commit hash.

## E. Grading Rubric

| Component | Weight | Full Marks (100%) | Minimum Marks |
|---|---:|---|---|
| Work steps completed (group) | 40% | Steps 1-6 done, both the product and cashier forms are validated with the total recomputed on the server | Most steps done, both forms work |
| Checkpoints verified (group) | 25% | Error/success screenshots for both forms, tinker output, and a complete, correct git log | Some checkpoints proven |
| Per-member contribution (individual) | 25% | At least one meaningful commit under each member's name, matching the task-division table | Commits exist but are small or their relevance is unclear |
| Repository and commit hygiene | 10% | `increment 6` message exact, no `vendor/`, `node_modules/`, `.env`, PRs merged cleanly (not squashed) | Commits exist, but the message is messy or a PR was squashed |
