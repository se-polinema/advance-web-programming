#import "/template.typ": *

= Designing and Building a REST API <ch:membangun-rest-api>

#chapterhero("purple", [Design consistent REST endpoints for Simple POS, protect them with a Sanctum token, then document the contract in OpenAPI so other teams never have to read the controller.], [#icon("plug")#h(1em)REST endpoints], [#icon("key")#h(1em)Sanctum], [#icon("code")#h(1em)OpenAPI])

A well-run public service counter keeps a standard form for every kind
of request: a blue form for applications, a yellow form for complaints,
each with fixed fields and the same sequence of steps every single
time. A citizen never has to ask the clerk "which form do I fill out
for this", because the form type is already predictable from the kind
of request itself. A REST API runs on the same principle: the HTTP
method and URL structure already tell you what's going to happen before
a single line of documentation gets read. `GET /api/products`
already implies "fetch the product list, change nothing", and
`POST /api/transactions` already implies "create a new
transaction". Simple POS's mobile cashier client depends entirely on
this kind of consistency, because unlike a Blade page, no human reads
the API's output directly to guess what to do next.

#strong[What You'll Learn]

+ design Simple POS's REST API endpoints (`POST /api/login`, `GET /api/products`, `POST /api/transactions`) following consistent HTTP method semantics;
+ implement token-based authentication with Laravel Sanctum for a mobile cashier client, including the `Authorization: Bearer` header, and write a client that actually consumes that protected endpoint from outside the application;
+ document Simple POS's API using the OpenAPI specification so another frontend or mobile team can rely on the endpoint contract without reading the controller code.

== Designing the Simple POS REST Endpoints <sec:membangun-rest-api-1>

#istilahpenting[
/ REST: #emph[Representational State Transfer], an API architecture style that maps operations onto resources through standard HTTP methods (GET, POST, PUT, DELETE) and URLs that represent the resource itself.
/ Endpoint: One combination of an HTTP method and a URL path that performs one specific operation, such as `POST /api/login`.
/ Token: A random string representing a user's identity after a successful login, resent on every subsequent request as proof that user is already authenticated.
/ Sanctum: Laravel's built-in token-based API authentication package, designed for both SPA clients and pure mobile clients.
/ API Resource: A Laravel transformation class that turns an Eloquent model into a consistent JSON structure, decoupling the API response shape from the table's raw column structure.
]

HTTP method semantics aren't just cosmetic convention: `GET`
should be safe (changes no state on the server at all) and idempotent
(calling it repeatedly produces the same effect as calling it once),
while `POST` is allowed to change state, such as creating a new
row. The mobile cashier client can rely on this rule: retrying
`GET /api/products` repeatedly because the connection dropped
will never duplicate data, while `POST /api/transactions` getting
called twice because the first request timed out genuinely risks
creating two transactions, and the client has to handle that case
explicitly (say, through an idempotency key), not assume POST is safe
to repeat.

#listing(file: "app/Http/Resources/ProductResource.php", ```php
class ProductResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'price' => $this->price,
            'category' => $this->category->name,
        ];
    }
}
```)

`JsonResource` guarantees every endpoint returns a consistent,
curated JSON shape, rather than the raw output of an Eloquent model's
`toJson()`, which could easily leak internal columns like
`updated_at` or relationships that aren't relevant to the
client at all.

== Token Authentication with Sanctum <sec:membangun-rest-api-2>

Simple POS's web pages use cookie-based sessions (Chapter~7), a good
fit for a browser that stores cookies automatically. A mobile cashier
client has no cookie jar like that, so it needs a different
authentication mechanism: a token the mobile app stores itself and
resends explicitly on every request. Set up Sanctum and the API
skeleton first:

+ Install Sanctum, if the Simple POS project hasn't already:

  #listing(```bash
  php artisan install:api
    
  ```)

  This command creates `routes/api.php` (if it doesn't exist
      yet) and registers the `auth:sanctum` middleware.
+ Create the API auth controller:

  #listing(```bash
  php artisan make:controller Api/AuthController
    
  ```)
+ Open `routes/api.php`, register the login route outside
      the `auth:sanctum` middleware (the client has no token yet
      at login time):

  #listing(file: "routes/api.php", ```php
  Route::post('/login', [App\Http\Controllers\Api\AuthController::class, 'login']);
    
  ```)

#listing(file: "app/Http/Controllers/Api/AuthController.php", ```php
public function login(Request $request)
{
    $credentials = $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required'],
    ]);

    if (! Auth::attempt($credentials)) {
        return response()->json(['message' => 'Invalid credentials.'], 401);
    }

    $user = Auth::user();
    $token = $user->createToken('mobile-cashier')->plainTextToken;

    return response()->json(['token' => $token]);
}
```)

`createToken('mobile-cashier')` generates a new token stored
(as a hash) in the `personal_access_tokens` table, and
`->plainTextToken` is the only chance that raw token is ever
visible; after this response, the app can never ask for that same token
again in readable form. Every following protected request must carry
that token in a header:

Open `app/Http/Controllers/Api/AuthController.php` created in
step 2 above, fill in the `login()` method with the code just
shown, then run `php artisan serve` and test it with
`curl`:

#listing(```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -d "email=kasir@pos.test&password=password"
```)

#strong[What to expect]: a JSON response containing
`{"token":"1|xxxxxxxxxxxxxxxxxxxx"}`. Copy that token value
(including the number and the `|` in front of it), then use it
on the next request:

#listing(```bash
curl http://127.0.0.1:8000/api/products \
  -H "Authorization: Bearer 1|xxxxxxxxxxxxxxxxxxxx"
```)

#strong[What to expect]: a JSON response containing the product list.
Also try it with no `Authorization` header at all;
#strong[what to expect] this time: a `401 Unauthorized` response
with the message `{"message":"Unauthenticated."}`, proof the
`auth:sanctum` middleware is genuinely active.

A route that needs protecting just gets wrapped in the
`auth:sanctum` middleware, similar to the `role:admin`
pattern from Chapter~7, except here what's being checked is the
presence and validity of a token via the `Authorization` header,
not a cookie session.

#listing(file: "routes/api.php", ```php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/products', [ProductController::class, 'index']);
    Route::post('/transactions', [TransactionController::class, 'store']);
});
```)

== Consuming the API: A Simple Client for the Mobile Cashier <sec:membangun-rest-api-3>

The previous section built the API from the server side. The mobile
cashier client that actually calls it doesn't write a single line of
Laravel; it just throws HTTP requests and reads JSON responses,
whether that's a Flutter app, React Native, or, as in the steps below,
a plain PHP script using Laravel's own `Http` facade. The
pattern stays the same from any other language or framework; only the
way the HTTP call itself gets made changes.

+ Start with login to get a token, from code that stands
      entirely separate from the server (an Artisan command, a
      standalone script, or a whole other project):

  #listing(file: "app/Console/Commands/ApiClientDemo.php", ```php
  $login = Http::post("{$baseUrl}/api/login", [
      'email' => 'kasir@pos.test',
      'password' => 'password',
  ]);

  if ($login->failed()) {
      // handle the error here, don't move on to the next step
  }

  $token = $login->json('token');
    
  ```)

  `$login->failed()` checks the HTTP status code before
      the code goes on to read `$login->json('token')`;
      without this check, bad credentials (401) leave `$token`
      as `null` with no clear reason why, and that failure only
      surfaces several steps later somewhere confusing.
+ Use that token on the next request through
      `Http::withToken()`, which automatically adds the
      `Authorization: Bearer <token>` header:

  #listing(file: "app/Console/Commands/ApiClientDemo.php", ```php
  $products = Http::withToken($token)->get("{$baseUrl}/api/products");

  if ($products->failed()) {
      // token expired/revoked, or the server is having trouble
  }
    
  ```)
+ Submit a transaction, and tell apart two different kinds of
      failure that need different handling: 401 (invalid token) means
      the client needs to log in again, while 422 (validation failed,
      e.g. insufficient stock) means the request itself was wrong and
      logging in again won't help:

  #listing(file: "app/Console/Commands/ApiClientDemo.php", ```php
  $transaction = Http::withToken($token)->post("{$baseUrl}/api/transactions", [
      'items' => [['product_id' => $productId, 'qty' => 1]],
  ]);

  match ($transaction->status()) {
      201 => /* transaction saved, read $transaction->json('data') */,
      401 => /* invalid token, log in again */,
      422 => /* input rejected, show $transaction->json('message') */,
      default => /* some other failure, surface it to the user */,
  };
    
  ```)
+ Run `php artisan serve`, then try the code above
      against a running Simple POS instance. #strong[What to expect]:
      the token gets accepted, the product list reads back correctly,
      and the transaction saves with a 201 status, exactly like calling
      it through `curl` in the previous section, only this time from
      PHP code that can grow into a real client application.
+ #strong[If the second or third step always fails with 401]
      even though login in the first step succeeded, check whether the
      token is actually being passed into `withToken()` (not an
      empty variable because the first step silently failed without
      being checked), or whether that token was already revoked through
      `POST /api/logout` in an earlier attempt.

#warningbox[
A client that assumes every request always succeeds, reading
`$response->json('token')` directly without checking
`failed()` first, fails silently: not a clear error, but a
`null` value that propagates into the next request and only
blows up several steps later with a confusing message.
]

The full working version of this pattern already exists as a runnable
Artisan command, `php artisan api:demo`, walking through all three
steps above in sequence against a running Simple POS instance; see
`app/Console/Commands/ApiClientDemo.php` in this chapter's full
code.

== Practice: Documenting the API with OpenAPI <sec:membangun-rest-api-4>

API documentation that's just a text note in a README goes stale fast:
the moment one response field gets renamed, nothing forces anyone to
update that note. OpenAPI describes endpoints in a structured format
(YAML or JSON) that other tools can read, from interactive documentation
generators all the way to client code generators.

+ Create a `docs/openapi.yaml` file at the root of the
      Simple POS project (not something Laravel ships with; this is a
      new, standalone file the application never reads automatically).
+ Fill in the `paths` section for the login endpoint:

  #listing(```
  paths:
    /api/login:
      post:
        summary: Log in and receive a token
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
            description: Token issued successfully
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    token: { type: string }
    
  ```)

  The `paths` structure maps a URL path onto HTTP methods, and
      each method describes the `requestBody` shape it accepts
      along with the possible `responses`, complete with their
      HTTP status codes.
+ Add matching entries for `GET /api/products` and
      `POST /api/transactions` under the same `paths`
      section, following the same pattern as the login endpoint.
+ Open that file in the online Swagger editor
      (`editor.swagger.io`), paste `docs/openapi.yaml`'s
      content in. #strong[What to expect]: the preview panel on the
      right shows all three endpoints as a clickable, interactive list,
      with no YAML syntax errors.
+ #strong[If the preview panel shows an error], it's almost
      always bad YAML indentation (YAML uses spaces, never tabs, and
      every indentation level must stay consistent); compare each line's
      indentation against the example in step 2 again.

The table below summarizes the three endpoints just built and consumed
in the previous section, the method-and-path combination worth
remembering both when writing the controller server-side and when
calling it from a client.

#figure(
  table(
    columns: (0.5fr, 1.1fr, 1fr),
    align: (left, left, center),
    table.hline(stroke: 0.8pt),
    [Method], [Path], [Authentication],
    table.hline(stroke: 0.5pt),
    [POST], [`/api/login`], [No token needed],
    [GET], [`/api/products`], [`auth:sanctum`],
    [POST], [`/api/transactions`], [`auth:sanctum`],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Simple POS API endpoint summary],
) <tab:endpoint-summary>

#tipbox[
Treat an OpenAPI specification as a testable contract, not just a
passive note: a schema validator tool can check whether the
controller's actual response genuinely matches the documented schema,
so stale documentation shows up as a failing test, not as a frontend
team's complaint weeks later.
]

#branchref("chapter-09")

== Summary <sec:membangun-rest-api-rangkuman>

- Simple POS's REST endpoints follow consistent HTTP method
      semantics (`GET` safe and idempotent, `POST` changes
      state), with responses curated through `JsonResource` to
      avoid leaking the table's raw structure.
- Sanctum issues a token through `POST /api/login`, and
      every protected request carries that token through the
      `Authorization: Bearer` header, checked by the
      `auth:sanctum` middleware on API routes. A client consuming
      this API must check the response status (`failed()`)
      before reading its content, and handle a 401 (log in again)
      differently from a 422 (fix the input), rather than assuming every
      call succeeds.
- The OpenAPI specification documents each endpoint's
      `paths`, `requestBody`, and `responses` in a
      structured format, letting another frontend or mobile team rely on
      the API contract without reading controller code, and testable
      automatically instead of staying a passive note.

== Exercises

+ Test all three endpoints (`login`, `products`,
      `transactions`) through `curl`, including trying to reach
      `/api/products` with no `Authorization` header at all
      and observing the resulting error response.
+ Add a new `GET /api/categories` endpoint, complete with
      its own `JsonResource`.
+ Complete the OpenAPI documentation for the
      `GET /api/products` endpoint, including the query parameter
      schema for pagination.
+ Modify `php artisan api:demo` to try logging in with the
      wrong password first, and observe how the code stops at that first
      step instead of continuing on with an empty token.
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) why `GET` must stay safe
      and idempotent, (b) what `createToken()` actually returns,
      (c) why OpenAPI documentation is more reliable than a plain README
      note, and (d) why an API client must check `failed()`
      before reading a response's content. Check your answers against
      this chapter.

#challengebox[
Add a `GET /api/transactions/{id}` endpoint that returns one
transaction with its details and products, complete with its OpenAPI
documentation.
]

== References

This chapter draws on the official Laravel Sanctum documentation
#cite(<sanctumdocs>) for token-based authentication, the OpenAPI
specification #cite(<openapispec>) for the API documentation format, and
Fielding's dissertation #cite(<fielding2000rest>) for REST architectural
principles.
