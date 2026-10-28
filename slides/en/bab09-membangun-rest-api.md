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
  section.divider h2 {
    color: #fff;
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

Meeting 10: **Designing and Building a REST API**

From use case to resource, consistent responses, token authentication, and clients that consume the API

---

## What You'll Learn

1. Explain the **REST** principles and follow the **API design process** from use case to contract
2. Model the right **resources, URLs, and HTTP methods** (safe, idempotent)
3. Design **responses**: status codes, JSON shape, pagination, error format, and versioning
4. Secure an API with **Sanctum tokens**, authorization, and rate limiting
5. Document with **OpenAPI**, test, and **consume** an API from clients (HTTP client and AJAX)

<div class="tip-box">
This deck is split into 5 self-contained parts. Applying them to Simple POS happens in the lab jobsheet.
</div>

---

## Meeting Map

<div class="flow">
  <div class="box">1. Basics</div>
  <div class="arrow">&rarr;</div>
  <div class="box">2. Resource</div>
  <div class="arrow">&rarr;</div>
  <div class="box">3. Response</div>
  <div class="arrow">&rarr;</div>
  <div class="box">4. Security</div>
  <div class="arrow">&rarr;</div>
  <div class="box">5. Consume</div>
</div>

<div class="tip-box">
An API is a restaurant menu: customers (clients) don't need to know what's in the kitchen, only what they can order and what the dish looks like. Designing an API means writing that menu well.
</div>

---

<!-- _class: divider -->

# Part 1
## REST Basics and the Design Process

---

## What Are an API and REST?

| Term | Meaning |
|---|---|
| **API** | an interface called by other programs, not by people |
| **REST** | an architectural style: resources accessed through URLs and standard HTTP methods |
| **Resource** | the thing the API manages (article, comment, author) |
| **Endpoint** | one combination of method and URL, e.g. `GET /api/v1/articles` |
| **Representation** | the form in which a resource is sent, usually JSON |
| **Contract** | a written agreement about endpoints, input, and output |

<div class="tip-box">
One backend, many clients (web, mobile, partners), and the business rules live in one place. API clients are often written by other people, so an API must be designed, not just "made to work".
</div>

---

## Five REST Principles

| Principle | What it means |
|---|---|
| **Client-server** | the client handles presentation, the server handles data and rules |
| **Stateless** | the server doesn't remember earlier requests, the token is sent every time |
| **Uniform interface** | resources and HTTP methods are used the same way on every endpoint |
| **Cacheable** | a response may state whether the client can store it |
| **Layered** | the client doesn't know whether it talks to the server directly or through a proxy |

<div class="tip-box">
REST is not a strict protocol, it is a set of conventions. What gets tested is whether your API is easy to guess.
</div>

---

## Anatomy of a Request and a Response

<div class="cols">
<div>

**Request**
```http
POST /api/v1/articles HTTP/1.1
Accept: application/json
Content-Type: application/json
Authorization: Bearer 1|abc...

{"title": "Learning REST"}
```

</div>
<div>

**Response**
```http
HTTP/1.1 201 Created
Content-Type: application/json
Location: /api/v1/articles/7

{"data": {"id": 7, "title": "Learning REST"}}
```

</div>
</div>

- Method + URL: what is asked. Headers: context. Body: data
- Status code: the outcome. Body: the resource representation or an error

---

## The API Design Process

<div class="flow">
  <div class="box">1. Use case</div>
  <div class="arrow">&rarr;</div>
  <div class="box">2. Resource</div>
  <div class="arrow">&rarr;</div>
  <div class="box">3. Operations</div>
  <div class="arrow">&rarr;</div>
  <div class="box">4. Representation</div>
</div>
<div class="flow">
  <div class="box">5. Errors</div>
  <div class="arrow">&rarr;</div>
  <div class="box">6. Security</div>
  <div class="arrow">&rarr;</div>
  <div class="box">7. Version</div>
  <div class="arrow">&rarr;</div>
  <div class="box">8. Docs</div>
</div>

<div class="tip-box">
Design on paper first, then write code. Changing a URL or JSON shape after clients use it costs far more than changing controller code.
</div>

---

## Our Running Example: a Blog API

A mobile blog app with **authors**, **articles**, and **comments**.

| Use case | Who | Resource |
|---|---|---|
| View the article list and details | anyone | `articles` |
| Write, edit, delete an article | author (owner) | `articles` |
| Publish an article | author (owner) | status on `articles` |
| View and write comments | view: anyone, write: logged-in user | `comments` (child of `articles`) |
| Log in and out | user | `login`, `logout` |

- Look for **nouns**, not verbs. One resource = one concept with an identity (ID)

---

## Part 1 Summary

- An API is an interface for other programs, and must be **designed** because you can't fix its clients
- REST: client-server, stateless, uniform interface, cacheable, layered
- Request = method + URL + headers + body. Response = status code + body
- Process: use case, resource, operations, representation, errors, security, version, docs
- Design on paper first: changing the contract after clients use it is expensive

---

<!-- _class: divider -->

# Part 2
## Resource, URL, and Method

---

## URL Naming Rules

| Rule | Good | Bad |
|---|---|---|
| Nouns, not verbs | `/articles` | `/getArticles` |
| Plural | `/articles/7` | `/article/7` |
| Lowercase, hyphens | `/article-tags` | `/ArticleTags` |
| No extension or trailing slash | `/articles` | `/articles.json/` |
| ID in the path, filter in the query | `/articles/7`, `?status=draft` | `/articles/status/draft` |

<div class="tip-box">
The HTTP method is already the verb. <code>GET /articles</code> reads as "fetch articles", so there is no need for <code>getArticles</code>.
</div>

---

## CRUD Becomes Method + URL

| Operation | Method + URL | Success |
|---|---|---|
| Article list | `GET /articles` | 200 |
| One article | `GET /articles/{id}` | 200 |
| Create an article | `POST /articles` | 201 |
| Replace entirely | `PUT /articles/{id}` | 200 |
| Change partially | `PATCH /articles/{id}` | 200 |
| Delete | `DELETE /articles/{id}` | 204 |

```php
Route::apiResource('articles', ArticleController::class);   // index, store, show, update, destroy
```

---

## Relations and Nesting

```text
GET  /articles/7/comments        comments of article 7
POST /articles/7/comments        add a comment to article 7
GET  /comments/31                one comment (the ID is already unique)
```

<div class="cols">
<div>

**Use nesting when**
- The child has no meaning without the parent
- You want the list of children of a parent

</div>
<div>

**Avoid**
- More than 2 levels: `/a/1/b/2/c/3/d`
- Copying every operation onto two paths

</div>
</div>

---

## Safe and Idempotent Methods

| Method | Safe (doesn't change data) | Idempotent (repeating = same effect) |
|---|---|---|
| `GET` | yes | yes |
| `PUT`, `DELETE` | no | yes |
| `PATCH` | no | depends on design |
| `POST` | no | **no** |

<div class="warn-box">
A <code>POST /transactions</code> repeated after a timeout can create two transactions. The fix is an <b>idempotency key</b>: the concept, the client side, and the complete implementation are on the next three slides.
</div>

---

## Idempotency Key: Flow and the Client Side

<div class="flow">
  <div class="box">Make a key</div>
  <div class="arrow">&rarr;</div>
  <div class="box">POST + header</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Store result</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Retry: same</div>
</div>

| Request | Result |
|---|---|
| New key | processed, the result is stored |
| Same key, same body | the old result is **replayed** (`Idempotent-Replayed: true`), no second record |
| Same key, different body | **422**: a key must not be reused for another request |
| Same key, first request still running | **409**: wait, then try again |

```php
$key = (string) Str::uuid();     // made ONCE per user action (JavaScript: crypto.randomUUID())

Http::withToken($token)->withHeaders(['Idempotency-Key' => $key])
    ->post("{$baseUrl}/api/v1/transactions", $payload);     // retries use the SAME key
```

---

## Idempotency Key in Laravel (1/2): Table and Route

```php
// php artisan make:migration create_idempotency_keys_table
Schema::create('idempotency_keys', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('key', 64);
    $table->string('request_hash', 64);                              // fingerprint of the request body
    $table->unsignedSmallInteger('response_status')->nullable();     // null = still processing
    $table->longText('response_body')->nullable();
    $table->timestamps();

    $table->unique(['user_id', 'key']);                              // guard against simultaneous requests
});
```

```php
// php artisan make:model IdempotencyKey  (fill in $fillable)  and  php artisan make:middleware EnsureIdempotency
// bootstrap/app.php
$middleware->alias(['idempotent' => \App\Http\Middleware\EnsureIdempotency::class]);

// routes/api.php
Route::post('/transactions', [TransactionController::class, 'store'])->middleware('idempotent');
```

- Delete old keys periodically (for example after 24 hours) with `Prunable` and a scheduled `model:prune`

---

## Idempotency Key in Laravel (2/2): Middleware

```php
// use App\Models\IdempotencyKey; use Illuminate\Database\UniqueConstraintViolationException;
public function handle(Request $request, Closure $next): Response
{
    $key = $request->header('Idempotency-Key');
    if (! $key) {
        return response()->json(['message' => 'The Idempotency-Key header is required.'], 400);
    }

    $userId = $request->user()->id;
    $hash = hash('sha256', $request->getContent());

    try {
        $record = IdempotencyKey::create(['user_id' => $userId, 'key' => $key, 'request_hash' => $hash]);   // reserve the key
    } catch (UniqueConstraintViolationException) {                                                         // key already exists
        $record = IdempotencyKey::where('user_id', $userId)->where('key', $key)->firstOrFail();

        if ($record->request_hash !== $hash) return response()->json(['message' => 'Key already used by another request.'], 422);
        if ($record->response_status === null) return response()->json(['message' => 'Still processing.'], 409);

        return response($record->response_body, $record->response_status)                                  // replay
            ->header('Content-Type', 'application/json')->header('Idempotent-Replayed', 'true');
    }

    $response = $next($request);

    $response->isSuccessful()
        ? $record->update(['response_status' => $response->getStatusCode(), 'response_body' => $response->getContent()])
        : $record->delete();                          // failed: free the key so the client may try again

    return $response;
}
```

---

## PUT vs PATCH

<div class="cols">
<div>

**PUT**: replace the whole resource
```json
PUT /articles/7
{ "title": "New", "body": "New body",
  "status": "draft" }
```
Fields that are not sent are treated as empty.

</div>
<div>

**PATCH**: change part of it
```json
PATCH /articles/7
{ "title": "New" }
```
Only the fields sent are changed.

</div>
</div>

```php
// PATCH validation: check a field only when it is sent
'title' => ['sometimes', 'required', 'string'],
'body'  => ['sometimes', 'required', 'string'],
```

<div class="tip-box">
Without <code>sometimes</code>, <code>PATCH {"title": "New"}</code> is rejected with 422 because <code>body</code> is required. When the field is sent, <code>required</code> still applies: <code>{"title": ""}</code> is still 422.
</div>

---

## Actions That Are Not CRUD

How do you model "publish an article" or "cancel a transaction"?

| Option | Example | When |
|---|---|---|
| Change the **status** through PATCH | `PATCH /articles/7` `{"status":"published"}` | status is an attribute of the resource (recommended) |
| The action as a **sub-resource** | `POST /articles/7/publication` | the action has side effects and a history |
| The action as a verb | `POST /articles/7/publish` | last resort when the other two don't fit |

<div class="warn-box">
Don't create <code>POST /publishArticle</code>. Look for a noun or a status that describes the result.
</div>

---

## Part 2 Summary

- URL = plural noun, HTTP method = verb, nesting at most 2 levels
- `apiResource` generates the 5 CRUD routes at once
- `GET`, `PUT`, `DELETE` are safe to repeat. `POST` is not, unless it uses an idempotency key (client UUID, middleware stores and replays the result)
- PUT replaces everything, PATCH changes part of it (validate with `sometimes`)
- Non-CRUD actions: change a status or create a sub-resource, no verbs in the URL

---

<!-- _class: divider -->

# Part 3
## Designing the Response

---

## Status Codes

Five groups: **2xx** success, **3xx** redirected, **4xx** client-side error, **5xx** server-side error.

| Code | Use when |
|---|---|
| **200** OK / **201** Created | GET, PUT, PATCH succeeded / POST created a resource (include `Location`) |
| **204** No Content | DELETE succeeded, no body |
| **400** / **422** | broken request (invalid JSON) / correct format but validation failed |
| **401** / **403** | no identity or invalid token / valid identity but not allowed |
| **404** / **409** | resource doesn't exist / conflicts with the current state |
| **429** | rate limit hit |

<div class="tip-box">
The client decides what to do from the <b>status code</b> first, then reads the body. Don't answer <code>200</code> with a body of <code>{"error": ...}</code>.
</div>

---

## 401 vs 403 vs 404 vs 422

<div class="cols">
<div>

**401: who are you?**
- The token is missing, wrong, or expired
- Client: log in again

**403: you're not allowed**
- The token is valid, but the role or ability isn't enough
- Client: show "no access"

</div>
<div>

**404: not found**
- The resource doesn't exist, or is deliberately hidden from those without rights (someone else's draft)

**422: bad content**
- Validation failed, say which field is wrong

</div>
</div>

<div class="warn-box">
Treating everything as "failed" leaves the client not knowing what to do: log in again, fix the input, or give up.
</div>

---

## Response Shape and JSON Conventions

```json
// GET /api/v1/articles
{
  "data": [ { "id": 7, "title": "Learning REST" } ],
  "links": { "next": "/api/v1/articles?page=2" },
  "meta": { "current_page": 1, "per_page": 15, "total": 42 }
}
```

- The same shape on every endpoint: data in `data`, extra info in `meta` and `links`. A collection is always an array (`[]`, not `null`)
- `snake_case` fields, ISO 8601 dates (`"2026-08-20T10:30:00Z"`), `true`/`false` booleans, empty values still shown as `null`
- Money as an integer in the smallest unit (`15000`), not a float: `0.1 + 0.2` is not equal to `0.3`

---

## API Resource: Filtering What Goes Out

Without a Resource, **every** column goes out (including internal ones). With a Resource, only the fields you choose.

```php
class ArticleResource extends JsonResource   // php artisan make:resource ArticleResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'author' => new AuthorResource($this->whenLoaded('author')),
            'comments_count' => $this->whenCounted('comments'),
        ];
    }
}
```

- `whenLoaded()` includes only relations that are already loaded (no silent N+1). Collections: `ArticleResource::collection($articles)`

---

## Pagination, Filter, Sort, and Search

| | Offset (`paginate`) | Cursor (`cursorPaginate`) |
|---|---|---|
| **Parameter** | `?page=3` | `?cursor=eyJpZCI6NDV9` |
| **Jump to page N** | yes | no |
| **Data changing / very large** | can skip rows or slow down | stable and fast (needs an index) |

```php
$request->validate([
    'sort' => ['sometimes', 'in:title,-title,published_at,-published_at'],   // allow list
    'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],              // upper limit
]);
$sort = $request->input('sort', '-published_at');

Article::query()
    ->when($request->status, fn ($q, $v) => $q->where('status', $v))                 // ?status=published
    ->orderBy(ltrim($sort, '-'), str_starts_with($sort, '-') ? 'desc' : 'asc')       // ?sort=-published_at
    ->paginate($request->integer('per_page', 15));        // cursor: ->orderBy('id')->cursorPaginate(15)
```

<div class="warn-box">
Input outside the allow list or over the limit gets a <b>422</b> and never reaches <code>orderBy()</code>. Cursor pagination needs a deterministic order, for example <code>orderBy('id')</code>.
</div>

---

## A Consistent Error Format

```json
// 422: validation failed
{ "message": "The title field is required.", "errors": { "title": ["The title field is required."] } }

// 404: not found
{ "message": "Resource not found." }
```

```php
// bootstrap/app.php: errors under api/* are always JSON
->withExceptions(function (Exceptions $exceptions): void {
    $exceptions->shouldRenderJsonWhen(fn (Request $request) => $request->is('api/*') || $request->expectsJson());
})
```

- `message` is for humans, `errors` per field only for 422. A failed route model binding also becomes a JSON 404
- Production: `APP_DEBUG=false`, never leak stack traces or table names
- A stricter standard: RFC 9457 (Problem Details for HTTP APIs)

---

## Versioning: The API Changes, Old Clients Must Not Break

| Change | Breaks old clients? |
|---|---|
| Adding a field or a new endpoint | no |
| Removing or renaming a field | **yes** |
| Changing a data type (`"15000"` to `15000`) | **yes** |
| Adding a required request field | **yes** |

```php
Route::prefix('v1')->middleware(AddSunsetHeaders::class)->group(function () {   // /api/v1/...; breaking change = /api/v2
    Route::apiResource('articles', ArticleController::class);
});

// php artisan make:middleware AddSunsetHeaders: flag a version that will be retired
$response = $next($request);
$response->headers->set('Deprecation', 'true');
$response->headers->set('Sunset', 'Wed, 31 Dec 2026 23:59:59 GMT');
return $response;
```

---

## Performance: Cheap Responses

| Technique | Effect |
|---|---|
| `with('author')` | avoids N+1 when relations are sent |
| `paginate()` + `per_page` cap | keeps response size under control |
| index on filter and sort columns | the query doesn't scan the whole table |
| gzip on the web server | smaller payload |
| `ETag` | the client sends `If-None-Match`, the server answers **304** with no body |

```php
public function show(Request $request, Article $article)
{
    $response = response()->json(['data' => new ArticleResource($article)]);

    $response->setEtag(md5($article->updated_at));    // fingerprint of the resource version
    $response->isNotModified($request);               // If-None-Match matches: automatically becomes 304 with no body

    return $response;
}
```

---

## Part 3 Summary

- Status codes tell the client what to do next: 201, 204, 401, 403, 404, 422, 429
- A consistent JSON shape: `data`, `meta`, `links`. Errors are always `message` and `errors`
- API Resource filters fields, `whenLoaded()` prevents N+1
- `paginate` or `cursorPaginate` with a `per_page` cap. Filter and sort through the query string with an allow list
- A version prefix (`/v1`) and `Deprecation`/`Sunset` headers for breaking changes. `ETag` gives a 304 for unchanged responses
- `shouldRenderJsonWhen` makes API errors always JSON

---

<!-- _class: divider -->

# Part 4
## Authentication, Authorization, and Security

---

## Session Cookie vs Token

<div class="cols">
<div>

**Web pages (Meeting 7)**
- The browser stores the cookie automatically
- The session is matched through that cookie

</div>
<div>

**API clients (mobile, outside scripts)**
- No cookie jar like a browser
- The client stores the token and sends it explicitly on every request

</div>
</div>

<div class="tip-box">
Both prove "who is making this request". Only the way that proof is stored and sent differs.
</div>

---

## Sanctum: Flow and the Login Endpoint

<div class="flow">
  <div class="box">POST /api/login</div>
  <div class="arrow">&rarr;</div>
  <div class="box">createToken()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Token to client</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Authorization: Bearer</div>
</div>

```php
$user = User::where('email', $data['email'])->first();

if (! $user || ! Hash::check($data['password'], $user->password)) {
    return response()->json(['message' => 'Invalid credentials.'], 401);   // same message for wrong email or password
}

return response()->json(['token' => $user->createToken('mobile-client')->plainTextToken]);
```

- Only the **hash** of the token is stored in `personal_access_tokens`. `plainTextToken` is visible once, the client must keep it

---

## Sanctum: Setup and Ability Aliases

```bash
php artisan install:api      # installs Sanctum, routes/api.php, and the token table migration
php artisan migrate
```

```php
// app/Models/User.php
class User extends Authenticatable { use HasApiTokens, HasFactory, Notifiable; }   // use Laravel\Sanctum\HasApiTokens

// bootstrap/app.php: use Laravel\Sanctum\Http\Middleware\{CheckAbilities, CheckForAnyAbility};
$middleware->alias([
    'abilities' => CheckAbilities::class,        // all abilities are required
    'ability' => CheckForAnyAbility::class,      // any one ability is enough
]);
```

- Without `HasApiTokens`, `createToken()` doesn't exist. Without the aliases, `abilities:...` is an unknown middleware
- Check inside code: `$request->user()->tokenCan('articles:write')`

---

## Protecting Routes and Token Abilities

```php
Route::post('/login', [AuthController::class, 'login']);                  // public

Route::middleware('auth:sanctum')->group(function () {                    // token required
    Route::apiResource('articles', ArticleController::class)->only(['index', 'show']);
    Route::post('/articles', [ArticleController::class, 'store'])
        ->middleware('abilities:articles:write');                        // needs an ability
});
```

```php
$user->createToken('report-bot', ['articles:read']);                        // the smallest permission possible
$user->createToken('editor-app', ['articles:read', 'articles:write']);
```

- No valid token: **401** before reaching the controller. A token without enough ability: **403**
- Give the smallest ability possible: a report bot only needs `articles:read`

---

## Authorization: A Valid Token Doesn't Mean Allowed

**Authentication** (who are you?) failure: **401**. **Authorization** (allowed to do what? policy, role, ability) failure: **403**.

```php
// php artisan make:policy ArticlePolicy --model=Article   (discovered automatically from its name)
// app/Policies/ArticlePolicy.php
public function update(User $user, Article $article): bool
{
    return $user->id === $article->user_id;               // only the author
}

// controller: use Illuminate\Support\Facades\Gate;
Gate::authorize('update', $article);                      // failure: automatic 403
$article->update($request->validated());
```

- The policies and roles from Meeting 7 are reused in the API
- Scope the query to the user's own data (`$request->user()->articles()`), not `Article::find($id)` from client input (prevents IDOR)

---

## Token Lifecycle and Rate Limiting

| What | How |
|---|---|
| Logout (revoke this token) | `$request->user()->currentAccessToken()->delete()` |
| Revoke all tokens | `$user->tokens()->delete()` |
| Expiry | `'expiration' => 525600` in `config/sanctum.php` |
| Clean up stale tokens | `php artisan sanctum:prune-expired --hours=24` |

```php
RateLimiter::for('api', fn (Request $request) => Limit::perMinute(60)->by($request->user()?->id ?: $request->ip()));

Route::middleware(['auth:sanctum', 'throttle:api'])->group(/* ... */);
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');   // stricter for login
```

<div class="warn-box">
By default Sanctum tokens <b>never expire</b>. Going over the rate limit: <b>429</b> with a <code>Retry-After</code> header.
</div>

---

## API Security Checklist

<div class="cols">
<div>

**Must have**
- HTTPS in production
- Validate all input (`validate()`)
- `$fillable` on models, not `$guarded = []`
- Tokens hashed in the database, never logged
- Rate limiting, especially on `/login`
- `APP_DEBUG=false` in production

</div>
<div>

**Often forgotten**
- Check resource ownership (IDOR)
- Cap `per_page` and restrict sort columns
- Never return raw models (`password`, `remember_token`)
- CORS only for known origins (`config:publish cors`)
- Error messages that don't leak internals

</div>
</div>

<div class="ref-link">Laravel docs: <code>Sanctum</code>, <code>Routing &rarr; Rate Limiting</code>, and <code>Routing &rarr; CORS</code></div>

---

## Part 4 Summary

- The web uses session cookies, API clients use a Bearer token (Sanctum: `createToken()`, `auth:sanctum`)
- Failed authentication = 401, failed authorization = 403. Abilities (middleware aliases) limit a token, a `Policy` + `Gate::authorize` limits an action
- Check resource ownership through a user-scoped query or a policy (prevents IDOR)
- Set token expiry, provide revocation, and add `throttle` (stricter on login)
- HTTPS, `APP_DEBUG=false`, and never return raw models

---

<!-- _class: divider -->

# Part 5
## Documentation, Testing, and Consuming an API

---

## OpenAPI: A Contract, Not Notes That Go Stale

<div class="term-box">
<b>OpenAPI:</b> a structured specification (YAML or JSON) describing endpoints, input, output, and authentication. Tools can read it: interactive docs (Swagger UI), client generators, validators.
</div>

```yaml
paths:
  /api/v1/articles:
    post:
      security: [ { bearerAuth: [] } ]
      requestBody:
        content: { application/json: { schema: { $ref: '#/components/schemas/ArticleInput' } } }
      responses:
        '201': { description: Created }
        '401': { description: Invalid token }
        '422': { description: Validation failed }
components:
  securitySchemes: { bearerAuth: { type: http, scheme: bearer } }
  schemas:
    ArticleInput: { type: object, required: [title], properties: { title: { type: string } } }
```

- **Contract-first**: write the contract, agree on it, implement, test. Mobile and backend teams work in parallel, and the contract lives in the repository

---

## Testing an API in Laravel

```php
public function test_guest_cannot_create_article(): void
{
    $this->postJson('/api/v1/articles', ['title' => 'X'])->assertUnauthorized();          // 401
}

public function test_create_article_validates_title(): void
{
    Sanctum::actingAs(User::factory()->create(), ['articles:write']);

    $this->postJson('/api/v1/articles', [])
        ->assertUnprocessable()->assertJsonValidationErrors('title');                     // 422
}

public function test_create_article_returns_created(): void
{
    Sanctum::actingAs(User::factory()->create(), ['articles:write']);

    $this->postJson('/api/v1/articles', ['title' => 'Learning REST'])
        ->assertCreated()->assertJsonPath('data.title', 'Learning REST');                 // 201
}
```

---

## HTTP Client: Check the Status Before Reading the Body

```php
$login = Http::post("{$baseUrl}/api/login", ['email' => $email, 'password' => $password]);

if ($login->failed()) { /* handle the error, don't continue */ }   // not straight to ->json('token')

$token = $login->json('token');

match ($response->status()) {
    201 => /* saved, read $response->json('data') */,
    401 => /* invalid token, log in again */,
    422 => /* input rejected, fix the input */,
    429 => /* too frequent, wait per Retry-After */,
    default => /* other error, show it to the user */,
};
```

<div class="warn-box">
A client that reads <code>json('token')</code> without checking <code>failed()</code> fails silently: <code>$token</code> is <code>null</code>, and the error only blows up somewhere confusing.
</div>

---

## HTTP Client: Retry and Backoff

```php
$when = fn ($e) => $e instanceof ConnectionException
    || in_array($e->response->status(), [429, 502, 503, 504]);        // only errors worth retrying

// GET is safe to repeat: wait 1 second, 2 seconds, 3 seconds (backoff)
Http::withToken($token)->acceptJson()
    ->retry(3, fn (int $attempt) => $attempt * 1000, $when, throw: false)
    ->get("{$baseUrl}/api/v1/articles");

// POST may be retried ONLY with the same idempotency key
Http::withToken($token)->withHeaders(['Idempotency-Key' => $key])
    ->retry(3, fn (int $attempt) => $attempt * 1000, $when, throw: false)
    ->post("{$baseUrl}/api/v1/transactions", $payload);
```

| Kind | May it be retried automatically? |
|---|---|
| 4xx (except 429) | no, the request itself is wrong |
| 429, 503 | yes, after a pause (read `Retry-After`) |
| 5xx on `GET` | yes, with backoff. On `POST`: only with an idempotency key |

---

## AJAX: Your Own Page Calls a JSON Endpoint

<div class="flow">
  <div class="box">Click</div>
  <div class="arrow">&rarr;</div>
  <div class="box">fetch()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Route</div>
  <div class="arrow">&rarr;</div>
  <div class="box">JSON</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Alpine update</div>
</div>

| | AJAX from your own page | External API client (Sanctum) |
|---|---|---|
| **Route file** | `routes/web.php` | `routes/api.php` |
| **Proof of identity** | session cookie (web login) | `Authorization: Bearer` header |
| **CSRF** | required for POST/PUT/PATCH/DELETE | none |
| **Middleware** | `auth` | `auth:sanctum` |

<div class="warn-box">
AJAX from your own page to a route in <code>api.php</code> gets 401: there is no session there, only tokens.
</div>

---

## AJAX Backend: Route, Controller, and the `Accept` Header

```php
Route::middleware('auth')->post('/articles/{article}/comments', [CommentController::class, 'store']);   // web.php

public function store(Request $request, Article $article): JsonResponse
{
    $data = $request->validate(['body' => ['required', 'string', 'max:500']]);

    return response()->json($article->comments()->create($data + ['user_id' => $request->user()->id]), 201);
}
```

<div class="cols">
<div>

**Without `Accept: application/json`**
- `validate()` fails: **302 redirect**
- `fetch` receives HTML, `res.json()` throws

</div>
<div>

**With `Accept: application/json`**
- `validate()` fails: **422** + JSON
- `{"message": "...", "errors": {"body": [...]}}`

</div>
</div>

---

## AJAX Frontend: CSRF, `fetch`, and Alpine

```html
<meta name="csrf-token" content="{{ csrf_token() }}">   <!-- in the layout <head> -->
```

```js
Alpine.data('commentForm', (articleId) => ({
    body: '', errors: {}, comments: [], loading: false,

    async submit() {
        if (this.loading) return;
        this.loading = true; this.errors = {};
        const res = await fetch(`/articles/${articleId}/comments`, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content },
            body: JSON.stringify({ body: this.body }),
        });
        if (res.status === 201) { this.comments.push(await res.json()); this.body = ''; }
        else if (res.status === 422) { this.errors = (await res.json()).errors; }
        else if (res.status === 401 || res.status === 419) { location.reload(); }
        this.loading = false;
    },
}));
```

---

## Common AJAX Pitfalls

| Symptom | Cause |
|---|---|
| **419** Page Expired | the `X-CSRF-TOKEN` header was not sent (if the browser origin check `Sec-Fetch-Site` fails, the token decides) |
| **302**, or `res.json()` throws because the body is HTML | the `Accept: application/json` header was not sent |
| **401** although you are logged in in the browser | the route is in `api.php`, not `web.php` |
| **405** Method Not Allowed | `@method('PATCH')` only works in HTML forms, `fetch` must use the real method |
| Data saved twice | the button was not disabled (`:disabled="loading"`) while the request ran |

<div class="ref-link">Laravel docs: <code>CSRF Protection &rarr; X-CSRF-TOKEN</code> and <code>Validation &rarr; Validation Error Response Format</code></div>

---

## Part 5 Summary

- OpenAPI = a contract tools can read. Contract-first: write, agree, implement, test
- Test with `getJson`, `postJson`, `Sanctum::actingAs`: at least 401, 403, 422, and the success path
- A client checks the status before reading the body, and only retries errors that may be retried (`retry()` with backoff, POST with an idempotency key)
- AJAX from your own page uses `web.php` + session + CSRF, not `api.php` + token
- Send `Accept: application/json` and `X-CSRF-TOKEN`, check `res.status`, and disable the button while the request runs

---

## API Design Review Checklist

<div class="cols">
<div>

**Resource, URL, and response**
- Plural noun URLs, no verbs
- Methods match their meaning (safe, idempotent), nesting at most 2 levels
- Non-CRUD actions as a status or sub-resource
- Right status codes, consistent success and error shapes
- Collections paginated with a cap

</div>
<div>

**Security, evolution, docs**
- Authentication and authorization separate (401 vs 403)
- Resource ownership checked, rate limiting, HTTPS
- A version prefix exists
- The OpenAPI contract lives in the repository
- Tests for 401, 403, 422, and the success path

</div>
</div>

---

## Applying It to Simple POS

In the jobsheet, you apply these concepts to Simple POS:

1. Install Sanctum, the `POST /api/login` endpoint, and tokens with abilities and an expiry time
2. Product and transaction endpoints with API Resource, 401 and 422
3. Tidy the design: pagination, filters, a consistent error format, and rate limiting
4. An idempotency key on transactions, plus authorization with abilities and a Policy (403)
5. An HTTP client with retry, OpenAPI documentation, and feature tests
6. One small AJAX feature on a web page: a form that sends JSON through `fetch`

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos-ch09</code></div>

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Sanctum, Eloquent API Resources, Pagination, Routing, CSRF Protection, Validation), the OpenAPI specification, RFC 9457, and Fielding's dissertation on REST architectural principles

Full code: `github.com/se-polinema/simple-pos-ch09`

**Next meeting:** the start of the PBL (Project Based Learning) project, where you will plan the features and architecture of your own web project
