# Group Practicum Jobsheet: Meeting 7
## Authentication, Authorization, and RBAC (Group Work)

| | |
|---|---|
| **Course** | Advanced Web Programming (SIB245007) |
| **Meeting** | 7 (Week 7) |
| **Duration** | 2 sessions &times; 170 minutes |
| **Sub-CPMK** | Sub-CPMK 3: Students can apply authentication, authorization, and API development mechanisms in web applications. |
| **Work Mode** | Group (same as Meeting 3-6), one shared GitHub repository per group |
| **Starting Code** | your group's repository from Meeting 6 (continue its `main`). If the group's repository has problems, create a copy of the template `github.com/se-polinema/simple-pos-ch06` via **Use this template** |

## A. Practicum Outcomes

After completing this group jobsheet, you'll be able to:

1. Add `role` and `is_active` columns to the `users` table through a new migration.
2. Build login and logout using `Auth::attempt()`, then regenerate the session after a successful login.
3. Write your own `role:admin` middleware, and register it as an alias in `bootstrap/app.php`.
4. Restrict the product and category pages to the admin role only, and prove it with two accounts that have different roles.
5. Explain why passwords are stored as hashes and why `401` and `403` are different.

## B. Preparation and Prerequisites

- **Tools**: same as Meeting 3-6 (PHP 8.2+, Composer, Node.js, Git), plus an active GitHub account for every group member.
- **Per-member git identity**: already set up since Meeting 3. On a shared lab computer, use `git config --local` inside the project folder, not `--global`.
- **Group assignment**: work in the group your instructor assigned. This jobsheet doesn't decide who does which step, that's the group's own call. Make sure the split gives every member at least one meaningful commit recorded through their own Pull Request.
- **Quick check** before starting:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  php artisan migrate:fresh --seed
  ```
  > ✅ **Checkpoint:** the top line shows the `increment 6: ...` commit, and `migrate:fresh --seed` runs with no error.

## C. Work Steps

Same workflow as Meeting 3-6: each step happens on its own branch off `main`, gets merged through a Pull Request with **Create a merge commit** (not squash), then everyone runs `git pull` before starting the next branch.

Each file that is changed in the steps below is shown with its full contents. If a file already matches what you wrote earlier, outside the changed parts, make sure its final contents match the version shown exactly.

### Step 1: Setting up a branch and dividing the work

Create a new branch off the latest `main`, e.g. `user-role-migration`:

```bash
git checkout main
git pull
git checkout -b user-role-migration
```

Agree on how steps 2 to 8 are divided among the members. Do steps 2 and 3 first, because the later steps depend on the `role` column and the `User` model being correct.

> ✅ **Checkpoint:** the task division is agreed on and the `user-role-migration` branch is active.

### Step 2: Adding `role` and `is_active` to the `users` table

A user's role (`admin` or `kasir`) and account status are stored in the `users` table, through new migrations. Don't edit the existing migration of the `users` table.

```bash
php artisan make:migration add_role_to_users_table
php artisan make:migration add_is_active_to_users_table
```

Replace the contents of the `add_role_to_users_table` migration file with:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role')->default('kasir')->after('email');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('role');
        });
    }
};
```

Replace the contents of the `add_is_active_to_users_table` migration file with:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_active')->default(true)->after('role');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('is_active');
        });
    }
};
```

The default of `kasir` means every new user automatically gets the kasir role, unless they're created as an admin explicitly. That's deliberate: a role with more rights should always be chosen consciously, never granted silently.

```bash
git add .
git commit -m "tambah kolom role dan is_active pada users"
git push -u origin user-role-migration
```

Open a Pull Request to `main`, merge it with **Create a merge commit**, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** `php artisan migrate:fresh` runs with no error, and `php artisan tinker` followed by `Schema::hasColumns('users', ['role', 'is_active'])` returns `true`.

> ⚠️ **If it fails:** a `duplicate column name: role` error means the same migration was already created on this computer. Delete the duplicate file in `database/migrations/` (only the one you just created in this step), then run `php artisan migrate:fresh` again.

### Step 3: Updating the `User` model

The `User` model needs to allow the new columns to be filled in bulk, hash the password automatically, and read `is_active` as a boolean.

Create a new branch off the latest `main`, e.g. `user-model`:

```bash
git checkout main
git pull
git checkout -b user-model
```

Replace the contents of `app/Models/User.php` with:

```php
<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

#[Fillable(['name', 'email', 'password', 'role', 'is_active'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'is_active' => 'boolean',
        ];
    }

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }
}
```

The `password => hashed` cast means every time you assign `password` to the model, Laravel hashes it first. The original password never reaches the database.

```bash
git add .
git commit -m "perbarui model User dengan role, is_active, dan hash kata sandi"
git push -u origin user-model
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** `php artisan tinker` followed by `App\Models\User::make(['password' => 'rahasia'])->password` prints a long hash string, not `rahasia`.

### Step 4: Demo accounts for admin and kasir

Simple POS needs two demo accounts to test with: one admin, one kasir. These accounts are created through a separate seeder, so the Meeting 4 seeder stays intact.

Create a new branch off the latest `main`, e.g. `demo-users`:

```bash
git checkout main
git pull
git checkout -b demo-users
php artisan make:seeder DemoUserSeeder
```

Replace the contents of `database/seeders/DemoUserSeeder.php` with:

```php
<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DemoUserSeeder extends Seeder
{
    public function run(): void
    {
        User::firstOrCreate(
            ['email' => 'admin@pos.test'],
            ['name' => 'Admin Kafe', 'role' => 'admin', 'password' => 'password'],
        );

        User::firstOrCreate(
            ['email' => 'kasir@pos.test'],
            ['name' => 'Kasir Kafe', 'role' => 'kasir', 'password' => 'password'],
        );
    }
}
```

The password `password` above is for local demo use only. The `User` model from step 3 hashes it automatically.

Call this seeder from `DatabaseSeeder`. Replace the contents of `database/seeders/DatabaseSeeder.php` with the following (one line, `$this->call(DemoUserSeeder::class);`, is added at the start of the `run()` method, the rest is the same as Meeting 4):

```php
<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call(DemoUserSeeder::class);

        $user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        $categoryIds = collect(['Makanan', 'Minuman', 'Snack', 'Lainnya'])
            ->map(fn (string $name) => Category::create(['name' => $name])->id)
            ->all();

        $products = [];
        foreach ($categoryIds as $categoryId) {
            for ($i = 0; $i < 75; $i++) {
                $products[] = [
                    'category_id' => $categoryId,
                    'name' => fake()->words(2, true),
                    'price' => fake()->numberBetween(3000, 50000),
                    'stock' => fake()->numberBetween(0, 200),
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
        }

        foreach (array_chunk($products, 50) as $chunk) {
            DB::table('products')->insert($chunk);
        }

        $productPrices = DB::table('products')->pluck('price', 'id');
        $productIds = $productPrices->keys()->all();

        for ($t = 0; $t < 2500; $t++) {
            DB::transaction(function () use ($user, $productIds, $productPrices) {
                $itemCount = fake()->numberBetween(1, 4);
                $total = 0;
                $details = [];

                for ($i = 0; $i < $itemCount; $i++) {
                    $productId = fake()->randomElement($productIds);
                    $qty = fake()->numberBetween(1, 3);
                    $subtotal = $productPrices[$productId] * $qty;
                    $total += $subtotal;

                    $details[] = [
                        'product_id' => $productId,
                        'qty' => $qty,
                        'subtotal' => $subtotal,
                    ];
                }

                $transactionId = DB::table('transactions')->insertGetId([
                    'user_id' => $user->id,
                    'total' => $total,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                foreach ($details as &$detail) {
                    $detail['transaction_id'] = $transactionId;
                    $detail['created_at'] = now();
                    $detail['updated_at'] = now();
                }

                DB::table('transaction_details')->insert($details);
            });
        }
    }
}
```

```bash
git add .
git commit -m "tambah akun demo admin dan kasir lewat seeder"
git push -u origin demo-users
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main`, pulls, and runs `php artisan migrate:fresh --seed` on their own laptop.

> ✅ **Checkpoint:** `php artisan tinker` followed by `App\Models\User::where('role', 'admin')->pluck('email')` shows `admin@pos.test`, and `...where('role', 'kasir')` shows `kasir@pos.test`.

> ⚠️ **If it fails:** a `Class "Database\Seeders\DemoUserSeeder" not found` error means `php artisan make:seeder DemoUserSeeder` wasn't run, or the file wasn't saved in `database/seeders/`.

### Step 5: Login and logout

Login uses `Auth::attempt()`. Once the credentials match, the server creates a new session ID (`session()->regenerate()`), so an old session ID that someone else may already know can't be used again. An account that is deactivated (`is_active = false`) is refused even when the password is correct.

Create a new branch off the latest `main`, e.g. `login-logout`:

```bash
git checkout main
git pull
git checkout -b login-logout
php artisan make:controller Auth/LoginController
php artisan make:view auth.login
```

Replace the contents of `app/Http/Controllers/Auth/LoginController.php` with:

```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class LoginController extends Controller
{
    public function create(): View
    {
        return view('auth.login');
    }

    public function store(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (! Auth::attempt($credentials)) {
            return back()->withErrors([
                'email' => 'Email atau kata sandi salah.',
            ])->onlyInput('email');
        }

        if (! Auth::user()->is_active) {
            Auth::logout();

            return back()->withErrors([
                'email' => 'Akun dinonaktifkan. Hubungi admin.',
            ])->onlyInput('email');
        }

        $request->session()->regenerate();

        return redirect()->intended(route('pos.create'));
    }

    public function destroy(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }
}
```

Replace the contents of `resources/views/auth/login.blade.php` with:

```php
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Login Simple POS</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="min-h-screen flex items-center justify-center bg-slate-100 px-4">
    <div class="w-full max-w-sm bg-white rounded-md shadow p-6">
        <h1 class="text-lg font-semibold mb-4">Masuk ke Simple POS</h1>

        <form method="POST" action="{{ route('login') }}" class="space-y-4">
            @csrf
            <div>
                <label class="block text-sm font-medium mb-1">Email</label>
                <input type="email" name="email" value="{{ old('email') }}" required autofocus
                       class="w-full border rounded-md px-3 py-2 text-sm">
                @error('email')
                    <p class="text-sm text-red-600 mt-1">{{ $message }}</p>
                @enderror
            </div>
            <div>
                <label class="block text-sm font-medium mb-1">Kata Sandi</label>
                <input type="password" name="password" required
                       class="w-full border rounded-md px-3 py-2 text-sm">
            </div>
            <button type="submit" class="w-full bg-slate-900 text-white rounded-md py-2 text-sm">Masuk</button>
        </form>

        <p class="mt-6 text-xs text-slate-500">
            Demo accounts: admin@pos.test or kasir@pos.test, password <code>password</code>.
        </p>
    </div>
</body>
</html>
```

The login view is deliberately simple and self-contained (no extra components), so this step can be repeated without depending on other files that don't exist yet.

```bash
git add .
git commit -m "tambah login dan logout dengan Auth::attempt"
git push -u origin login-logout
```

Don't open a Pull Request yet: step 6 is still done on the same `login-logout` branch.

> ✅ **Checkpoint:** `php artisan route:list` doesn't error, and the files `resources/views/auth/login.blade.php` and `app/Http/Controllers/Auth/LoginController.php` are saved. Logging in through the browser can only be tested after step 8, because that's where the `/login` route is registered.

> ⚠️ **If it fails:** if `/login` shows a 404 now, that's expected because the route isn't registered yet. If the correct password is still refused after step 8, check the demo accounts (step 4) and that `is_active` is `true`.

### Step 6: Navigation with a logout button

The navigation must show a logout button, and show admin menus only to admin users. Replace the contents of `resources/views/components/nav.blade.php` with:

```php
<nav class="bg-slate-900 text-white px-4 py-3 flex gap-4 items-center">
    <span class="font-semibold">Simple POS</span>
    <a href="{{ route('pos.create') }}" class="hover:underline">Kasir</a>
    <a href="{{ route('transactions.index') }}" class="hover:underline">Transaksi</a>
    @if (auth()->user()?->isAdmin())
        <a href="{{ route('products.index') }}" class="hover:underline">Produk</a>
        <a href="{{ route('categories.index') }}" class="hover:underline">Kategori</a>
    @endif
    <span class="ml-auto text-sm">{{ auth()->user()?->name }} ({{ auth()->user()?->role }})</span>
    <form method="POST" action="{{ route('logout') }}">
        @csrf
        <button class="hover:underline">Keluar</button>
    </form>
</nav>
```

Hiding the admin menu in the navigation is only visual. The real restriction is applied on the server in the next steps.

```bash
git add .
git commit -m "tambah tombol keluar dan menu admin di navigasi"
git push
```

> ✅ **Checkpoint:** after logging in as admin, the navigation shows `Produk` and `Kategori`. After logging in as kasir, those two menus disappear and the `Keluar` button is still there.

Once step 6 is done, open a Pull Request from `login-logout` to `main` (steps 5 and 6 are combined in one PR), merge it with **Create a merge commit**, then everyone goes back to `main` and pulls.

### Step 7: The `role:admin` middleware

Middleware checks every request before it reaches the controller. The `auth` middleware has already confirmed the user is logged in; `role:admin` checks their role. If the role isn't admin, the response is 403 Forbidden.

Create a new branch off the latest `main`, e.g. `role-middleware`:

```bash
git checkout main
git pull
git checkout -b role-middleware
php artisan make:middleware EnsureUserHasRole
```

Replace the contents of `app/Http/Middleware/EnsureUserHasRole.php` with:

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string $role): Response
    {
        if (! $request->user() || $request->user()->role !== $role) {
            abort(403, 'Anda tidak memiliki akses untuk halaman ini.');
        }

        return $next($request);
    }
}
```

The `$role` parameter is supplied by the route, for example `role:admin`. The middleware must be registered under the short name `role` in `bootstrap/app.php`. Replace the contents of `bootstrap/app.php` with:

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => \App\Http\Middleware\EnsureUserHasRole::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->expectsJson(),
        );
    })->create();
```

```bash
git add .
git commit -m "tambah middleware role untuk pembatasan halaman admin"
git push -u origin role-middleware
```

> ✅ **Checkpoint:** `php artisan tinker` followed by `app('router')->getMiddleware()['role']` shows the class name `EnsureUserHasRole`, not `null`.

> ⚠️ **If it fails:** a `Target class [role] does not exist` error means the alias in `bootstrap/app.php` wasn't saved or is misspelled. Check the `$middleware->alias([...])` block.

### Step 8: Attaching the middleware to the routes

The product and category routes are wrapped in a `role:admin` group, while the cashier pages are only protected by `auth`. Replace the contents of `routes/web.php` with:

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\TransactionController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return redirect()->route('pos.create');
});

Route::middleware('guest')->group(function () {
    Route::get('/login', [LoginController::class, 'create'])->name('login');
    Route::post('/login', [LoginController::class, 'store']);
});

Route::post('/logout', [LoginController::class, 'destroy'])
    ->middleware('auth')
    ->name('logout');

Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])->name('transactions.store');
    Route::get('/transactions', [TransactionController::class, 'index'])->name('transactions.index');

    Route::middleware('role:admin')->group(function () {
        Route::resource('categories', CategoryController::class)->except('show');
        Route::resource('products', ProductController::class)->except(['show', 'destroy']);
    });
});
```

Notice that the `/products` and `/categories` routes sit **inside** the `role:admin` group, not outside it. This matters, because a route outside the group isn't protected by anyone.

```bash
git add .
git commit -m "lindungi route produk dan kategori dengan role admin"
git push -u origin role-middleware
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** `php artisan route:list` shows the `auth` middleware on `/pos` and the `role:admin` middleware on `products` and `categories`.

### Step 9: Proving the restriction with two accounts

Test this step with both accounts, not only the admin. The most common mistake is invisible when the tester always logs in as admin.

1. Run `php artisan migrate:fresh --seed`, then `php artisan serve`.
2. Log in as `admin@pos.test`, open `/products`. **Expected:** the product list shows normally.
3. Log out, log in as `kasir@pos.test`, open `/products` again. **Expected:** a 403 error page with the message "Anda tidak memiliki akses untuk halaman ini.", not the product list.
4. While logged in as kasir, open `/pos`. **Expected:** the cashier page shows normally, since kasir is allowed there.
5. Try logging in with a wrong password. **Expected:** the message "Email atau kata sandi salah."

> ✅ **Checkpoint:** all five results match, and each member has tried at least step 3 or step 4 on their own laptop.

> ⚠️ **If kasir can still open `/products`:** check two possibilities. (a) The `/products` route is outside the `role:admin` group in step 8. (b) The routes were cached before the middleware was added. Run `php artisan route:clear`, then try again.

### Step 10: Deactivating an account

An account that's deactivated can't log in, even with the correct password. This is different from a role: the account still exists, only its access is revoked.

In `php artisan tinker`, run:

```php
App\Models\User::where('email', 'kasir@pos.test')->update(['is_active' => false]);
```

Try logging in as `kasir@pos.test`. **Expected:** the message "Akun dinonaktifkan. Hubungi admin.". Then turn it back on with `update(['is_active' => true])`.

> ✅ **Checkpoint:** kasir's login is refused while `is_active` is `false`, and works again after it's set back to `true`.

### Step 11: Group independent challenges and the `increment 7` commit

Split the following tasks among the group's members, so each member gets at least one meaningful commit recorded through their own Pull Request:

- Change the 403 message in `EnsureUserHasRole` so it names the required role, e.g. "Halaman ini hanya untuk peran admin.", instead of the generic message.
- Add a third role, `manager`, that may open `/transactions` but not `/products`. Decide for yourself how the routes need to be grouped so this rule holds.
- Add a page that only guests (not logged-in users) can open, e.g. an information page, and make sure logged-in users are redirected to `/pos`.
- Write one manual test scenario in the project's README for each role: the steps and the expected results.

For each task: create a new branch (e.g. `custom-forbidden-message`), do the work, commit, push, then open and merge its Pull Request (follow the workflow above).

Once every Pull Request is in and merged, one member closes out the group's work:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 7: autentikasi dan otorisasi rbac"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** the top line of `git log --pretty="%h %an %s"` shows `increment 7: ...`, and the lines below it show every group member's name.

## D. Tasks and Deliverables

Submit the following in the format your instructor requests:

- Link to the group's GitHub repository.
- Screenshot of the 403 page when kasir opens `/products`.
- Screenshot of the `/products` page displaying normally when admin opens it.
- Output of `git log --pretty="%h %an %s"` showing at least one commit per member.
- A task-division table: member name | step/task done | commit hash.

## E. Grading Rubric

| Component | Weight | Full Marks (100%) | Minimum Marks |
|---|---:|---|---|
| Work steps completed (group) | 40% | Steps 1-11 done, login, logout, and role restriction work as the two-account test shows | Most steps done, login and the admin restriction work |
| Checkpoints verified (group) | 25% | Screenshots of the 403 page and the admin page, task-division table, and a complete, correct git log | Some checkpoints proven |
| Per-member contribution (individual) | 25% | At least one meaningful commit under each member's name, matching the task-division table | Commits exist but are small or their relevance is unclear |
| Repository and commit hygiene | 10% | The `increment 7` message is exact, new migrations (not edits to old ones), no `vendor/`/`node_modules/`/`.env` included, PRs merged cleanly (not squashed) | Commits exist, but the message is messy or a PR was squashed |
