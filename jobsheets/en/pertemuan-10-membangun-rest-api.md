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

### Step 7: Together, integration test and code review

Everyone runs `git checkout main && git pull`, runs `php artisan migrate:fresh --seed`, then repeats every checkpoint above in order: login, products without a token (401), products with a token, a valid transaction (201), an invalid transaction (422), `php artisan api:demo`, and previewing `docs/openapi.yaml` in the Swagger editor. Every checkpoint must show exactly the same result on each member's laptop.

> ✅ **Checkpoint:** every checkpoint above is repeated successfully and shows the same result on every group member's laptop.

### Step 8: Group independent challenges and the `increment 10` commit

Split the following tasks among the group's members, so each member gets at least one meaningful commit recorded through their own Pull Request.

- Add a new `GET /api/categories` endpoint, complete with its own `CategoryResource`.
- Complete the OpenAPI documentation for the `GET /api/products` endpoint, including a query parameter schema for pagination.
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
- Output of `git log --pretty="%h %an %s"` showing at least one commit per member.
- A short table of independent challenges: member, challenge worked on, and Pull Request link.

## E. Grading Rubric

| Component | Weight | Full Marks (100%) | Minimum Marks |
|---|---|---|---|
| Work steps completed (group) | 40% | Steps 1-7 done: login, products, transactions, HTTP client, and OpenAPI all work as the checkpoints show | Most steps done, at minimum login and one protected endpoint work |
| Per-member contribution (individual) | 25% | At least one meaningful commit from each member, matching the task-division table | Commits exist but are small or their relevance is unclear |
| Repository and commit hygiene | 10% | The `increment 10` message is exact, no `vendor/`, `node_modules/`, `.env` included, PRs merged cleanly (not squashed) | Commits exist, but the message is messy or a PR was squashed |
| Checkpoints verified (group) | 25% | Screenshots of `api:demo` and the Swagger editor are complete and show correct results | Some checkpoints proven |
