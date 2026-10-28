# Group Practicum Jobsheet: Meeting 10
## Designing and Building a REST API (Group Work)

| | |
|---|---|
| **Course** | Advanced Web Programming (SIB245007) |
| **Meeting** | 10 (Week 10) |
| **Duration** | 2 sessions &times; 170 minutes |
| **Sub-CPMK** | Sub-CPMK 3: Students are able to apply authentication, authorization, and API development mechanisms in a web application. |
| **Work Mode** | Group (same as Meeting 3-9), one shared GitHub repository per group |
| **Starting Code** | your group's repository from Meeting 9 (continue its `main`). If your group's repository has problems, create a copy from the template `github.com/se-polinema/simple-pos-ch08` via **Use this template** |

## A. Practicum Outcomes

After completing this group jobsheet, you'll be able to:

1. Install Sanctum and design a `POST /api/login` endpoint that issues a token for clients that don't have a cookie jar.
2. Build a `GET /api/products` endpoint protected by a token, curating its response shape with an API Resource.
3. Build a `POST /api/transactions` endpoint that distinguishes handling 401 and 422 errors, and consume all three endpoints from a real HTTP client outside the web request cycle.
4. Document all three endpoints using the OpenAPI specification.
5. Tidy the API design: pagination with a cap, filtering and sorting through the query string, a consistent JSON 404 error, and a rate limit on login.
6. Prevent duplicate transactions when a request is repeated with an idempotency key: reserve the key, replay the old result, and handle 400, 409, and 422.
7. Call a JSON endpoint from your own web page through `fetch` (AJAX): a route in `web.php`, the CSRF token, the `Accept: application/json` header, and handling the 201 and 422 statuses.

## B. Preparation and Prerequisites

- **Tools**: same as Meeting 3-9 (PHP 8.2+, Composer, Node.js, Git).
- **Git identity**: already set up since Meeting 3.
- **Quick check** before starting:
  ```bash
  git checkout main
  git pull
  git log --oneline -1
  php artisan migrate:fresh --seed
  ```
  > ✅ **Checkpoint:** the top line shows the `increment 9: ...` commit, and `migrate:fresh --seed` runs with no error.

## C. Work Steps

Same workflow as Meeting 3-9: each step happens on its own branch off `main`, gets merged through a Pull Request with **Create a merge commit** (not squash), then everyone runs `git pull` before starting the next branch.

### Step 1: Installing Sanctum

Simple POS's web pages use cookie-based sessions (Meeting 7), which suits a browser that stores cookies automatically. An API client (a mobile app, an external script) doesn't have a cookie jar like that, so it needs a different authentication mechanism: a token the client stores itself and sends back explicitly with every request.

Create a new branch off the latest `main`, then install Sanctum:

```bash
git checkout main
git pull
git checkout -b api-auth
composer require laravel/sanctum
php artisan install:api
```

`install:api` creates `routes/api.php`, registers the `auth:sanctum` middleware, and prepares the `personal_access_tokens` table migration. Run the migration:

```bash
php artisan migrate
```

Add the `HasApiTokens` trait to `app/Models/User.php` so the `User` model can issue tokens. Replace the contents of `app/Models/User.php` with:

```php
<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'is_active',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

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

```bash
git add .
git commit -m "pasang sanctum untuk autentikasi api"
git push -u origin api-auth
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** `php artisan migrate:status` shows `create_personal_access_tokens_table` with status `Ran`.

### Step 2: Login endpoint and token issuance

Create a new branch off the latest `main`, e.g. `api-login`:

```bash
git checkout main
git pull
git checkout -b api-login
php artisan make:controller Api/AuthController
```

Replace the contents of `app/Http/Controllers/Api/AuthController.php` with:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required'],
        ]);

        if (! Auth::attempt($credentials)) {
            return response()->json(['message' => 'Kredensial tidak valid.'], 401);
        }

        $user = Auth::user();
        $token = $user->createToken('mobile-kasir')->plainTextToken;

        return response()->json(['token' => $token]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logout berhasil.']);
    }
}
```

`createToken('mobile-kasir')` generates a new token stored as a hash in the `personal_access_tokens` table, and `->plainTextToken` is the only chance that raw token is ever visible. After this response, the server can never show that same token in readable form again.

Replace the contents of `routes/api.php` with:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);
```

The login route is registered outside the `auth:sanctum` middleware, because the client doesn't have a token yet when logging in.

```bash
git add .
git commit -m "tambah endpoint login api"
git push -u origin api-login
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** run `php artisan serve`, then in another terminal:
> ```bash
> curl -X POST http://127.0.0.1:8000/api/login \
>   -d "email=kasir@pos.test&password=password"
> ```
> **Expected:** a JSON response containing `{"token":"1|xxxxxxxxxxxxxxxxxxxx"}`. Copy that token value (including the number and the `|` before it), you'll use it in the next step.

> ⚠️ **If it fails:** a `{"message":"Kredensial tidak valid."}` message means a typo in the email or password, not a code problem; make sure the database was reseeded via `migrate:fresh --seed` in step B.

### Step 3: Products endpoint protected by a token

Create a new branch off the latest `main`, e.g. `api-products`:

```bash
git checkout main
git pull
git checkout -b api-products
php artisan make:resource ProductResource
php artisan make:controller Api/ProductController
```

Replace the contents of `app/Http/Resources/ProductResource.php` with:

```php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'price' => $this->price,
            'category' => $this->category->name,
        ];
    }
}
```

`JsonResource` ensures the endpoint returns a curated JSON shape, instead of a raw Eloquent model `toJson()` that could leak internal columns like `created_at` or relationships the client has no use for.

Replace the contents of `app/Http/Controllers/Api/ProductController.php` with:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Models\Product;

class ProductController extends Controller
{
    public function index()
    {
        return ProductResource::collection(Product::with('category')->get());
    }
}
```

Replace the contents of `routes/api.php` with:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/products', [ProductController::class, 'index']);
});
```

A route that needs protection just gets wrapped in the `auth:sanctum` middleware, similar to the `role:admin` pattern from Meeting 7, except what's checked this time is the presence and validity of a token via the `Authorization` header, not a cookie session.

```bash
git add .
git commit -m "tambah endpoint produk terproteksi token"
git push -u origin api-products
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** try it without a token first:
> ```bash
> curl -i -H "Accept: application/json" http://127.0.0.1:8000/api/products
> ```
> **Expected:** a `401 Unauthorized` response with the message `{"message":"Unauthenticated."}`. Then try it with the token from Step 2:
> ```bash
> curl -H "Accept: application/json" \
>   -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx" \
>   http://127.0.0.1:8000/api/products
> ```
> **Expected:** a JSON response containing the product list, wrapped in `{"data": [...]}`.

> ⚠️ **If a request without a token returns a redirect to `/login` instead of 401:** check whether the `Accept: application/json` header was included in the `curl` command. Without this header, Laravel has no way to know the client expects JSON and treats it as an ordinary browser request, redirecting to the web login page instead of returning 401. Every request to an API endpoint, including ones sent through an HTTP client, should always include this header.

### Step 4: Transactions endpoint

Create a new branch off the latest `main`, e.g. `api-transactions`:

```bash
git checkout main
git pull
git checkout -b api-transactions
php artisan make:controller Api/TransactionController
```

This endpoint reuses the `StoreTransactionRequest` that already exists for the web transaction page, since its validation rules (an `items` array with `product_id` and `qty`) are exactly the same. Replace the contents of `app/Http/Controllers/Api/TransactionController.php` with:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Models\Product;
use App\Models\Transaction;
use App\Models\TransactionDetail;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function store(StoreTransactionRequest $request)
    {
        $validated = $request->validated();

        $transaction = DB::transaction(function () use ($validated, $request) {
            $transaction = Transaction::create([
                'user_id' => $request->user()->id,
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

            return $transaction;
        });

        return response()->json([
            'data' => [
                'id' => $transaction->id,
                'total' => $transaction->total,
            ],
        ], 201);
    }
}
```

`$request->user()->id` takes the identity from the token being used, not from input the client sends, so a transaction is always recorded under the real owner of the token.

Replace the contents of `routes/api.php` with:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\TransactionController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/products', [ProductController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store']);
});
```

```bash
git add .
git commit -m "tambah endpoint transaksi api"
git push -u origin api-transactions
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** first find a valid `product_id` via `php artisan tinker` and `Product::first()->id`, then:
> ```bash
> curl -i -H "Accept: application/json" \
>   -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx" \
>   -H "Content-Type: application/json" \
>   -X POST http://127.0.0.1:8000/api/transactions \
>   -d '{"items":[{"product_id":1,"qty":2}]}'
> ```
> **Expected:** a `201 Created` response containing `{"data":{"id":...,"total":...}}`. Also try a `product_id` that doesn't exist (e.g. `99999`); **expected:** a `422 Unprocessable Content` response with a validation message, not a 500.

> ⚠️ **If it fails with 401 even though you just got a token:** the token shown above is just an example, it isn't actually valid in your database; use the real token from a `curl` call to `/api/login` in Step 2, not a copy of this example as-is.

### Step 5: A real HTTP client for mobile cashiers

The endpoints built so far are useless if nothing ever actually calls them. This step builds a client that calls them through Laravel's `Http` facade, the same pattern used from any other language or framework (Flutter, React Native, and the like); only how the HTTP call itself is made changes.

Create a new branch off the latest `main`, e.g. `api-client-demo`:

```bash
git checkout main
git pull
git checkout -b api-client-demo
php artisan make:command ApiClientDemo
```

Replace the contents of `app/Console/Commands/ApiClientDemo.php` with:

```php
<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class ApiClientDemo extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'api:demo';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Demonstrate consuming the Simple POS API as an external client';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $baseUrl = 'http://127.0.0.1:8000';

        $login = Http::acceptJson()->post("{$baseUrl}/api/login", [
            'email' => 'kasir@pos.test',
            'password' => 'password',
        ]);

        if ($login->failed()) {
            $this->error('Login gagal: '.$login->json('message'));

            return self::FAILURE;
        }

        $token = $login->json('token');
        $this->info("Login berhasil, token: {$token}");

        $products = Http::acceptJson()->withToken($token)->get("{$baseUrl}/api/products");

        if ($products->failed()) {
            $this->error('Token kedaluwarsa/dicabut, atau server sedang bermasalah.');

            return self::FAILURE;
        }

        $this->info('Jumlah produk: '.count($products->json('data')));

        $productId = Product::first()->id;

        $transaction = Http::acceptJson()->withToken($token)->post("{$baseUrl}/api/transactions", [
            'items' => [['product_id' => $productId, 'qty' => 1]],
        ]);

        match ($transaction->status()) {
            201 => $this->info('Transaksi tersimpan: '.json_encode($transaction->json('data'))),
            401 => $this->error('Token tidak valid, login ulang.'),
            422 => $this->error('Input ditolak: '.$transaction->json('message')),
            default => $this->error('Galat lain: '.$transaction->status()),
        };

        return self::SUCCESS;
    }
}
```

`$login->failed()` is checked before the code goes on to read `$login->json('token')`; without this check, wrong credentials (401) would make `$token` end up `null` with no clear reason why, and the error would only explode a few steps later somewhere confusing. `Http::acceptJson()` automatically adds the `Accept: application/json` header to every request, preventing the redirect-to-login problem found in Step 3.

```bash
git add .
git commit -m "tambah klien http demo untuk konsumsi api"
git push -u origin api-client-demo
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** make sure `php artisan serve` is running on port 8000, then in another terminal:
> ```bash
> php artisan api:demo
> ```
> **Expected:** three lines of output in order, "Login berhasil, token: ...", "Jumlah produk: ...", and "Transaksi tersimpan: {...}", exactly like when called via `curl` in the previous steps, only this time from PHP code that can be extended into a real client application.

> ⚠️ **If the second or third step always fails with 401** even though login in the first step succeeded, check whether the token is actually being passed to `withToken()` (not an empty variable because the first step actually failed but wasn't checked).

### Step 6: Documenting the API with OpenAPI

API documentation that's just plain text notes in a README goes stale fast: the moment one response field gets renamed, nothing forces anyone to update that note. OpenAPI describes endpoints in a structured format other tools can read.

Create a new branch off the latest `main`, e.g. `api-docs`:

```bash
git checkout main
git pull
git checkout -b api-docs
```

Create the file `docs/openapi.yaml` at the project root (not something Laravel ships with; this is a new, standalone file the application doesn't read automatically) containing:

```yaml
openapi: 3.0.0
info:
  title: Simple POS API
  version: 1.0.0
paths:
  /api/login:
    post:
      summary: Login dan dapatkan token
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                email: { type: string }
                password: { type: string }
      responses:
        '200':
          description: Token berhasil diterbitkan
          content:
            application/json:
              schema:
                type: object
                properties:
                  token: { type: string }
        '401':
          description: Kredensial tidak valid
          content:
            application/json:
              schema:
                type: object
                properties:
                  message: { type: string }
  /api/products:
    get:
      summary: Ambil daftar produk
      security:
        - bearerAuth: []
      responses:
        '200':
          description: Daftar produk
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      type: object
                      properties:
                        id: { type: integer }
                        name: { type: string }
                        price: { type: integer }
                        category: { type: string }
        '401':
          description: Token tidak ada atau tidak valid
  /api/transactions:
    post:
      summary: Buat transaksi baru
      security:
        - bearerAuth: []
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                items:
                  type: array
                  items:
                    type: object
                    properties:
                      product_id: { type: integer }
                      qty: { type: integer }
      responses:
        '201':
          description: Transaksi berhasil disimpan
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: object
                    properties:
                      id: { type: integer }
                      total: { type: integer }
        '401':
          description: Token tidak ada atau tidak valid
        '422':
          description: Input tidak valid, misalnya product_id tidak ditemukan
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
```

The `paths` structure maps a URL path to an HTTP method, and each method describes the `requestBody` shape it accepts along with the `responses` it might return, including the HTTP status code.

```bash
git add .
git commit -m "tambah dokumentasi openapi"
git push -u origin api-docs
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** open `editor.swagger.io`, paste the contents of `docs/openapi.yaml` into it. **Expected:** the preview panel on the right shows all three endpoints as a clickable, interactive list, with no YAML syntax error.

> ⚠️ **If the preview panel shows an error:** it's almost always wrong YAML indentation (YAML uses spaces, not tabs, and every indentation level must be consistent); compare each line's indentation against the example above again.

### Step 7: Tidying the API design

The `GET /api/products` endpoint from Step 3 sends every product at once. For a shop with thousands of products, that makes the response large and slow. In this step you apply several design decisions from the slides: the list is paginated with a cap, can be filtered and sorted through the query string, the 404 error has a consistent JSON shape, and the login endpoint gets a rate limit so password guessing is slowed down.

Create a new branch from the latest `main`, for example `api-design`:

```bash
git checkout main
git pull
git checkout -b api-design
```

Change `app/Http/Controllers/Api/ProductController.php` to. The `category_id`, `q`, `sort`, and `per_page` parameters are validated first. The `in:` rule on `sort` is an allow list, so client input never goes straight into `orderBy()`, and `max:100` on `per_page` stops a client from asking for thousands of rows at once:

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ProductResource;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'category_id' => ['sometimes', 'integer', 'exists:categories,id'],
            'q' => ['sometimes', 'string', 'min:2'],
            'sort' => ['sometimes', 'in:name,-name,price,-price'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $sort = $request->input('sort', 'name');
        $direction = str_starts_with($sort, '-') ? 'desc' : 'asc';

        $products = Product::with('category')
            ->when($request->filled('category_id'), fn ($query) => $query->where('category_id', $request->integer('category_id')))
            ->when($request->filled('q'), fn ($query) => $query->where('name', 'like', '%'.$request->input('q').'%'))
            ->orderBy(ltrim($sort, '-'), $direction)
            ->paginate($request->integer('per_page', 15))
            ->withQueryString();

        return ProductResource::collection($products);
    }
}
```

Change `bootstrap/app.php` to. Errors under `api/*` are always JSON, and a route that doesn't exist is answered with a `404` in the same message shape as other errors:

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
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
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        $exceptions->render(function (NotFoundHttpException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json(['message' => 'Resource tidak ditemukan.'], 404);
            }
        });
    })->create();
```

The rate limiters are defined in `AppServiceProvider`. The `api` limiter allows 60 requests per minute per user (or per IP when not logged in), while the `login` limiter is much stricter: 5 attempts per minute for the same email and IP combination. Change `app/Providers/AppServiceProvider.php` to:

```php
<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
        });

        RateLimiter::for('login', function (Request $request) {
            return Limit::perMinute(5)->by($request->input('email').'|'.$request->ip());
        });
    }
}
```

Attach the limiters to the routes. Change `routes/api.php` to:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\TransactionController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');

Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/products', [ProductController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store']);
});
```

```bash
git add .
git commit -m "rapikan desain api: pagination, filter, galat konsisten, rate limit"
git push -u origin api-design
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** get a fresh token through `/api/login` (Step 2), then ask for the five most expensive products (price descending):
> ```bash
> curl -i -H "Accept: application/json" \
>   -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx" \
>   "http://127.0.0.1:8000/api/products?per_page=5&sort=-price"
> ```
> **Expected:** status `200`, `data` holds at most 5 products ordered from the highest price, plus `links` and `meta` (`meta.per_page` is 5 and `meta.total` holds the total number of products).

> ✅ **Checkpoint:** ask for a page with a `per_page` over the cap:
> ```bash
> curl -i -H "Accept: application/json" \
>   -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx" \
>   "http://127.0.0.1:8000/api/products?per_page=500"
> ```
> **Expected:** status `422` with `errors.per_page`, not a product list. Then try a route that doesn't exist:
> ```bash
> curl -i -H "Accept: application/json" http://127.0.0.1:8000/api/tidak-ada
> ```
> **Expected:** status `404` with the body `{"message":"Resource tidak ditemukan."}`.

> ✅ **Checkpoint:** send six logins with a wrong password:
> ```bash
> for i in 1 2 3 4 5 6; do
>   curl -s -o /dev/null -w "%{http_code}\n" -X POST http://127.0.0.1:8000/api/login \
>     -H "Accept: application/json" -H "Content-Type: application/json" \
>     -d '{"email":"kasir@pos.test","password":"salah"}'
> done
> ```
> **Expected:** the first five lines are `401`, the sixth is `429` (Too Many Requests). Wait a minute, and the next attempt is answered with `401` again.

> ⚠️ **If it fails:** (a) `per_page=500` returns a list or a redirect: the `Accept: application/json` header wasn't sent, so `validate()` redirects back instead of returning 422; (b) `links` and `meta` don't appear: make sure you use `->paginate()`, not `->get()`; (c) `429` never appears: the limiter name in `routes/api.php` (`throttle:login`) must match the name in `RateLimiter::for('login', ...)`; (d) a route that doesn't exist still shows an HTML page: make sure the line `api: __DIR__.'/../routes/api.php'` is in `bootstrap/app.php`. Note: `php artisan api:demo` from Step 5 still runs, it just now sees the first 15 products because the list is paginated.

### Step 8: Idempotency key on transactions

Picture a cashier pressing **Pay**, the signal is slow, the screen freezes, so they press it again. Without a safeguard, the customer pays twice. The same happens with `POST /api/transactions`: a mobile client that hits a timeout repeats the request, and the server creates a second transaction. `GET`, `PUT`, and `DELETE` are safe to repeat, but `POST` is not. The fix is an **idempotency key**: the client gives each action one unique number (a UUID), and the server remembers the result. The same request with the same number is not processed again, the old result is replayed.

The flow, with `Idempotency-Key` as a request header:

| Request | Result |
|---|---|
| New key | processed, the result is stored |
| Same key, same body | the old result is **replayed** (header `Idempotent-Replayed: true`), no second transaction |
| Same key, different body | **422**: a key must not be reused for another request |
| Same key, first request still running | **409**: wait, then try again |
| No header | **400** |

Create a new branch off the latest `main`, e.g. `api-idempotency`, then generate the migration, model, and middleware with artisan:

```bash
git checkout main
git pull
git checkout -b api-idempotency
php artisan make:migration create_idempotency_keys_table
php artisan make:model IdempotencyKey
php artisan make:middleware EnsureIdempotency
```

Replace the contents of the newest migration file (`database/migrations/xxxx_xx_xx_xxxxxx_create_idempotency_keys_table.php`, the number prefix differs on every laptop) with the code below. A `response_status` that is still `null` means the first request hasn't finished, and the unique index on `user_id` + `key` is the main guard: if two requests with the same key arrive at the same time, only one manages to create the row.

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('idempotency_keys', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('key', 64);
            $table->string('request_hash', 64);
            $table->unsignedSmallInteger('response_status')->nullable();
            $table->longText('response_body')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('idempotency_keys');
    }
};
```

```bash
php artisan migrate
```

Replace the contents of `app/Models/IdempotencyKey.php` with:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IdempotencyKey extends Model
{
    protected $fillable = ['user_id', 'key', 'request_hash', 'response_status', 'response_body'];
}
```

Replace the contents of `app/Http/Middleware/EnsureIdempotency.php` with the code below. This middleware **reserves the key first**, before running the request. `request_hash` is a fingerprint of the request body, used to detect a key reused with a different body. If the request fails (not 2xx), the row is deleted so the client may try again with the same key:

```php
<?php

namespace App\Http\Middleware;

use App\Models\IdempotencyKey;
use Closure;
use Illuminate\Database\UniqueConstraintViolationException;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureIdempotency
{
    public function handle(Request $request, Closure $next): Response
    {
        $key = $request->header('Idempotency-Key');

        if (! $key) {
            return response()->json(['message' => 'Header Idempotency-Key wajib diisi.'], 400);
        }

        $userId = $request->user()->id;
        $hash = hash('sha256', $request->getContent());

        try {
            // reservasi key: kalau sudah ada, unique index menolak dan masuk ke catch
            $record = IdempotencyKey::create([
                'user_id' => $userId,
                'key' => $key,
                'request_hash' => $hash,
            ]);
        } catch (UniqueConstraintViolationException) {
            $record = IdempotencyKey::where('user_id', $userId)->where('key', $key)->firstOrFail();

            if ($record->request_hash !== $hash) {
                return response()->json(['message' => 'Key ini sudah dipakai untuk request lain.'], 422);
            }

            if ($record->response_status === null) {
                return response()->json(['message' => 'Request dengan key ini masih diproses.'], 409);
            }

            // request yang sama: putar ulang hasil lama, jangan jalankan lagi
            return response($record->response_body, $record->response_status)
                ->header('Content-Type', 'application/json')
                ->header('Idempotent-Replayed', 'true');
        }

        $response = $next($request);

        if ($response->isSuccessful()) {
            $record->update([
                'response_status' => $response->getStatusCode(),
                'response_body' => $response->getContent(),
            ]);
        } else {
            // gagal: bebaskan key supaya klien boleh mencoba lagi
            $record->delete();
        }

        return $response;
    }
}
```

Register the middleware alias. Replace the contents of `bootstrap/app.php` with:

```php
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->alias([
            'role' => \App\Http\Middleware\EnsureUserHasRole::class,
            'idempotent' => \App\Http\Middleware\EnsureIdempotency::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        $exceptions->render(function (NotFoundHttpException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json(['message' => 'Resource tidak ditemukan.'], 404);
            }
        });
    })->create();
```

Attach it to the transactions route only, because only `POST` creates new data. Replace the contents of `routes/api.php` with:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\TransactionController;
use Illuminate\Support\Facades\Route;

Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:login');

Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/products', [ProductController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store'])->middleware('idempotent');
});
```

The client must now send the `Idempotency-Key` header, including the demo client from Step 5. Replace the contents of `app/Console/Commands/ApiClientDemo.php` with the code below. The UUID is made **once** per action (`Str::uuid()`), then reused on the retry: if every attempt made a new key, the safeguard would be useless.

```php
<?php

namespace App\Console\Commands;

use App\Models\Product;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class ApiClientDemo extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'api:demo';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Demonstrate consuming the Simple POS API as an external client';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $baseUrl = 'http://127.0.0.1:8000';

        $login = Http::acceptJson()->post("{$baseUrl}/api/login", [
            'email' => 'kasir@pos.test',
            'password' => 'password',
        ]);

        if ($login->failed()) {
            $this->error('Login gagal: '.$login->json('message'));

            return self::FAILURE;
        }

        $token = $login->json('token');
        $this->info("Login berhasil, token: {$token}");

        $products = Http::acceptJson()->withToken($token)->get("{$baseUrl}/api/products");

        if ($products->failed()) {
            $this->error('Token kedaluwarsa/dicabut, atau server sedang bermasalah.');

            return self::FAILURE;
        }

        $this->info('Jumlah produk: '.count($products->json('data')));

        $productId = Product::first()->id;
        $payload = ['items' => [['product_id' => $productId, 'qty' => 1]]];
        $key = (string) Str::uuid();

        $transaction = Http::acceptJson()->withToken($token)
            ->withHeaders(['Idempotency-Key' => $key])
            ->post("{$baseUrl}/api/transactions", $payload);

        match ($transaction->status()) {
            201 => $this->info('Transaksi tersimpan: '.json_encode($transaction->json('data'))),
            401 => $this->error('Token tidak valid, login ulang.'),
            422 => $this->error('Input ditolak: '.$transaction->json('message')),
            default => $this->error('Galat lain: '.$transaction->status()),
        };

        // simulasi retry setelah timeout: request yang sama dengan key yang sama
        $retry = Http::acceptJson()->withToken($token)
            ->withHeaders(['Idempotency-Key' => $key])
            ->post("{$baseUrl}/api/transactions", $payload);

        $this->info('Ulang dengan key yang sama: '.$retry->status().', replayed = '.$retry->header('Idempotent-Replayed'));

        return self::SUCCESS;
    }
}
```

```bash
git add .
git commit -m "tambah idempotency key pada endpoint transaksi"
git push -u origin api-idempotency
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main`, pulls, and runs `php artisan migrate`.

> ✅ **Checkpoint 1 (repeated request):** get a fresh token through `/api/login` (Step 2). Check the transaction count in `php artisan tinker` with `App\Models\Transaction::count()`, then send the same request twice:
> ```bash
> curl -i -X POST http://127.0.0.1:8000/api/transactions \
>   -H "Accept: application/json" -H "Content-Type: application/json" \
>   -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx" \
>   -H "Idempotency-Key: kunci-uji-1" \
>   -d '{"items":[{"product_id":1,"qty":2}]}'
> ```
> **Expected:** the first request is `201 Created` with `{"data":{"id":...,"total":...}}`. The second request (the exact same command) is also `201` with the same `id` and the header `Idempotent-Replayed: true`. Check `Transaction::count()` again: it grew by only **one**.

> ✅ **Checkpoint 2 (error cases):** (a) send without the `Idempotency-Key` header: **expected** `400`. (b) Send `kunci-uji-1` again but with `"qty":5`: **expected** `422` with the message "Key ini sudah dipakai untuk request lain.". (c) Send a new key `kunci-uji-3` with a `product_id` that doesn't exist (for example `99999`): **expected** a `422` validation error. Send `kunci-uji-3` again with a valid `product_id`: **expected** `201`, because the key is freed after a failed request.

> ✅ **Checkpoint 3 (first request still running):** simulate it in `php artisan tinker`:
> ```php
> App\Models\IdempotencyKey::create([
>     'user_id' => App\Models\User::where('email', 'kasir@pos.test')->value('id'),
>     'key' => 'kunci-uji-2',
>     'request_hash' => hash('sha256', '{"items":[{"product_id":1,"qty":2}]}'),
> ]);
> ```
> Then send the `curl` from Checkpoint 1 with `Idempotency-Key: kunci-uji-2` and the exact same `-d` body. **Expected:** `409 Conflict` with the message "Request dengan key ini masih diproses.", because the row exists but its `response_status` is still `null`.

> ✅ **Checkpoint 4 (demo client):** run `php artisan api:demo` (the server is still running on port 8000). **Expected:** four lines of output, the last two being "Transaksi tersimpan: {...}" and "Ulang dengan key yang sama: 201, replayed = true". The fourth line simulates a retry after a timeout: the request is repeated with the same key, and no second transaction is created.

> ⚠️ **If it fails:** (a) every `POST /api/transactions` gets `400`: the `Idempotency-Key` header was not sent, including on the old `curl` commands from Step 4; (b) the error `Target class [idempotent] does not exist` or the middleware doesn't run: the `idempotent` alias in `bootstrap/app.php` is missing; (c) the error `no such table: idempotency_keys`: run `php artisan migrate`; (d) the second request always creates a new transaction: the key differs every time, make sure the UUID is made once and reused; (e) a permanent `409` after a process died midway: a row with a `null` `response_status` was left behind. Delete it in tinker (`App\Models\IdempotencyKey::whereNull('response_status')->delete()`). In production, such rows get an expiry time.

### Step 9: AJAX from a web page

A Sanctum token is used by clients outside the browser. The Simple POS web pages can also call the server in the background through `fetch`, with no reload, using the same session cookie as in Meeting 7. The difference from the API in Steps 1-8: the route lives in `routes/web.php` (not `api.php`), a request that changes data needs a CSRF token, and the client must ask for JSON through the `Accept` header so validation errors come back as a 422 JSON response, not a redirect.

The feature: a `/quick-categories` page for admins. A form adds a category through `fetch`, the category list grows with no reload, and validation errors appear under the input.

Create a new branch from the latest `main`, for example `ajax-quick-category`, then create the controller and the view through artisan:

```bash
git checkout main
git pull
git checkout -b ajax-quick-category
php artisan make:controller QuickCategoryController
php artisan make:view quick-categories.index
```

`Category::create()` needs `$fillable` (Meeting 6), and the `Category` model doesn't have one yet. Change `app/Models/Category.php` to:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    protected $fillable = ['name'];

    public function products(): HasMany
    {
        return $this->hasMany(Product::class);
    }
}
```

The browser needs to know the CSRF token of the active session. The usual way: put the token in a `<meta>` tag in the layout, then let JavaScript read it from there. Change `resources/views/layouts/app.blade.php` to:

```php
<!DOCTYPE html>
<html lang="id">
<head>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Simple POS')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <x-nav />
    <main>@yield('content')</main>
</body>
</html>
```

Change `routes/web.php` to (the two `quick-categories` routes are added inside the `role:admin` group, so only admins can open this page):

```php
<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\QuickCategoryController;
use App\Http\Controllers\ReportController;
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
        Route::get('/reports', [ReportController::class, 'index'])->name('reports.index');
        Route::get('/reports/export/csv', [ReportController::class, 'exportCsv'])->name('reports.export.csv');
        Route::get('/reports/export/xlsx', [ReportController::class, 'exportExcel'])->name('reports.export.xlsx');
        Route::get('/reports/export/pdf', [ReportController::class, 'exportPdf'])->name('reports.export.pdf');
        Route::get('/import', [ReportController::class, 'importForm'])->name('import.create');
        Route::post('/import', [ReportController::class, 'import'])->name('import.store');
        Route::get('/quick-categories', [QuickCategoryController::class, 'index'])->name('quick-categories.index');
        Route::post('/quick-categories', [QuickCategoryController::class, 'store'])->name('quick-categories.store');
    });
});
```

Change `app/Http/Controllers/QuickCategoryController.php` to. The `store` action validates with `validate()` as in Meeting 6, then returns JSON with the `201 Created` status code:

```php
<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class QuickCategoryController extends Controller
{
    public function index(): View
    {
        return view('quick-categories.index', [
            'categories' => Category::orderBy('name')->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:categories,name'],
        ]);

        $category = Category::create($data);

        return response()->json($category, 201);
    }
}
```

Change `resources/views/quick-categories/index.blade.php` to. The Alpine component inside `x-data` sends `fetch` with three headers (`Accept`, `Content-Type`, `X-CSRF-TOKEN`), then reads `res.status` before reading the response body:

```php
@extends('layouts.app')

@section('title', 'Kategori Cepat')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Tambah Kategori Cepat</h1>

    <div x-data="{
        name: '',
        errors: {},
        categories: {{ \Illuminate\Support\Js::from($categories) }},
        loading: false,

        async submit() {
            if (this.loading) return;
            this.loading = true;
            this.errors = {};

            try {
                const meta = document.head.querySelector('meta[name=csrf-token]');
                const res = await fetch('{{ route('quick-categories.store') }}', {
                    method: 'POST',
                    headers: {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': meta.content,
                    },
                    body: JSON.stringify({ name: this.name }),
                });

                if (res.status === 201) {
                    this.categories.push(await res.json());
                    this.name = '';
                } else if (res.status === 422) {
                    this.errors = (await res.json()).errors;
                } else if (res.status === 401 || res.status === 419) {
                    location.reload();
                } else {
                    this.errors = { name: ['Terjadi kesalahan, coba lagi.'] };
                }
            } catch (e) {
                this.errors = { name: ['Gagal terhubung ke server.'] };
            } finally {
                this.loading = false;
            }
        },
    }" class="max-w-md">
        <form @submit.prevent="submit()" class="flex gap-2 items-start mb-4">
            <div class="flex-1">
                <input type="text" x-model="name" placeholder="Nama kategori baru"
                       class="w-full border rounded-md px-3 py-2 text-sm">
                <p x-text="errors.name?.[0]" class="text-sm text-red-600 mt-1"></p>
            </div>
            <button type="submit" :disabled="loading"
                    class="bg-slate-900 text-white px-4 py-2 rounded-md text-sm disabled:opacity-50">
                <span x-show="!loading">Tambah</span>
                <span x-show="loading">Mengirim...</span>
            </button>
        </form>

        <ul class="list-disc pl-5 text-sm">
            <template x-for="c in categories" :key="c.id">
                <li x-text="c.name"></li>
            </template>
        </ul>
    </div>
@endsection
```

`@submit.prevent` stops the form from submitting and the page from reloading. `:disabled="loading"` stops a category from being saved twice if the button is clicked twice.

```bash
git add .
git commit -m "tambah halaman kategori cepat dengan ajax"
git push -u origin ajax-quick-category
```

Open a Pull Request to `main`, merge it, then everyone goes back to `main` and pulls.

> ✅ **Checkpoint:** log in as admin, open `/quick-categories`, then open DevTools (F12) on the **Network** tab, filter **Fetch/XHR**. Type `Minuman Dingin` and click **Tambah**. **Expected:** one `quick-categories` request appears with method `POST` and status **201**; the **Response** tab holds the new category's JSON; the name appears in the list with no page reload (no new request of type `document`).

> ✅ **Checkpoint:** empty the input and click **Tambah**. **Expected:** the `POST` request has status **422**, the **Response** tab holds `{"message": ..., "errors": {"name": [...]}}`, and a red error message appears under the input. Also try sending `Minuman Dingin` once more: the `unique` rule rejects it with 422.

> ✅ **Checkpoint (experiment):** in `resources/views/quick-categories/index.blade.php`, temporarily delete the line `'Accept': 'application/json',`, save, reload the page, then submit the form with an empty input. **Expected:** in the **Network** tab the `POST` request has status **302** (a redirect to the previous page), and the error message under the input changes to "Gagal terhubung ke server." because `res.json()` fails to read HTML. Put the line back when you're done.

> ⚠️ **If it fails:** (a) status **419 Page Expired**: the `<meta name="csrf-token">` tag is missing from the layout, or the `'X-CSRF-TOKEN'` line has a typo; (b) status **405 Method Not Allowed**: make sure the `quick-categories.store` route uses `Route::post`; (c) status **401** even though you're logged in: make sure you logged in through the web page, not with a Sanctum token, and that the route is in `web.php`; (d) status **403** or the page won't open: the account used isn't an admin; (e) a console error `Alpine is not defined`: run `npm run dev` (Meeting 3).

### Step 10: Together, integration test and code review

Everyone runs `git checkout main && git pull`, runs `php artisan migrate:fresh --seed`, then repeats every checkpoint above in order: login, products without a token (401), products with a token, a valid transaction (201), an invalid transaction (422), `php artisan api:demo`, previewing `docs/openapi.yaml` in the Swagger editor, products with `per_page` and `sort`, the login rate limit (429), the idempotency key (201 then replayed, 400, 422, 409, and `php artisan api:demo` with four lines), and the `/quick-categories` page (201 and 422 in the Network tab). Because `POST /api/transactions` now requires an `Idempotency-Key` header, add that header (any unique value) to the transaction `curl` command from Step 4. Every checkpoint must show exactly the same result on each member's laptop.

> ✅ **Checkpoint:** every checkpoint above is repeated successfully and shows the same result on every group member's laptop.

### Step 11: Group independent challenges and the `increment 10` commit

Split the following tasks among the group's members, so each member gets at least one meaningful commit recorded through their own Pull Request.

- Add a new `GET /api/categories` endpoint, complete with its own `CategoryResource`.
- Complete the OpenAPI documentation for the `GET /api/products` endpoint, including a query parameter schema for pagination.
- Move all API routes under the `/api/v1` prefix (for example with `Route::prefix('v1')`), then update `php artisan api:demo` and `docs/openapi.yaml` so they still match.
- Write one feature test (`postJson` with `Sanctum::actingAs`) that proves a repeated request with the same key does not create a second transaction.
- Delete old keys automatically (for example after 24 hours) using the `Prunable` trait on the `IdempotencyKey` model and a scheduled `model:prune`.
- Change `php artisan api:demo` to try logging in with the wrong password first, then observe how the code stops at the first step instead of continuing with an empty token.
- Test all three endpoints via Postman or Insomnia (not `curl`), then write one paragraph comparing that experience to `curl` as a YAML comment in `docs/openapi.yaml`.

Once every Pull Request is in and merged, one group member closes out this meeting:

```bash
git checkout main
git pull
git commit --allow-empty -m "increment 10: sanctum, endpoint rest api, dan dokumentasi openapi"
git push
git log --pretty="%h %an %s"
```

> ✅ **Checkpoint:** the top line of `git log` shows the `increment 10: ...` commit, and the lines below it show every group member's name.

## D. Tasks and Deliverables

Submit the following in the format your instructor requests:

- Link to your group's GitHub repository.
- A screenshot of the terminal showing the full output of `php artisan api:demo`.
- A screenshot of the Swagger editor preview panel showing `docs/openapi.yaml`.
- The `curl` output showing a paginated `GET /api/products` response (with `links` and `meta`) and one `429` response from login.
- The `curl` output showing a transaction request repeated with the same `Idempotency-Key`: the first response `201`, the second `201` with the header `Idempotent-Replayed: true`, and a `Transaction::count()` that grew by only one.
- A screenshot of DevTools on the Network tab at `/quick-categories` showing a `POST` request with status 201 and one with status 422.
- Output of `git log --pretty="%h %an %s"` showing at least one commit per member.
- A short table of independent challenges: member, challenge worked on, and Pull Request link.

## E. Grading Rubric

| Component | Weight | Full Marks (100%) | Minimum Marks |
|---|---|---|---|
| Work steps completed (group) | 40% | Steps 1-10 done: login, products, transactions, HTTP client, OpenAPI, a tidy API design (pagination, errors, rate limit), the idempotency key, and AJAX quick categories all work as the checkpoints show | Most steps done, at minimum login and one protected endpoint work |
| Per-member contribution (individual) | 25% | At least one meaningful commit from each member, matching the task-division table | Commits exist but are small or their relevance is unclear |
| Repository and commit hygiene | 10% | The `increment 10` message is exact, no `vendor/`, `node_modules/`, `.env` included, PRs merged cleanly (not squashed) | Commits exist, but the message is messy or a PR was squashed |
| Checkpoints verified (group) | 25% | Screenshots of `api:demo`, the Swagger editor, and the Network tab (201 and 422) are complete and show correct results | Some checkpoints proven |
