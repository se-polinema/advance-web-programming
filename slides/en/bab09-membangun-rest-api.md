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

From use case to resource, consistent responses, token authentication, and documentation you can trust

---

## What You'll Learn

1. Explain the **REST** principles and follow the **API design process** from use case to contract
2. Model **resources and URLs**, and choose the right HTTP method (safe, idempotent)
3. Design **responses**: status codes, JSON shape, pagination, filtering, error format, and versioning
4. Secure an API with **Sanctum tokens**, abilities, authorization, and rate limiting
5. Document the contract with **OpenAPI**, test it, and consume an API correctly
6. Call a JSON endpoint from your own web page (**AJAX**) safely

<div class="tip-box">
This deck covers concepts. Applying them to Simple POS happens in the lab jobsheet.
</div>

---

## Meeting Map

<div class="flow">
  <div class="box">Use case</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Resource</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Response</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Security</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Docs</div>
</div>

<div class="tip-box">
An API is a restaurant menu: customers (clients) don't need to know what's in the kitchen, only what they can order and what the dish looks like. Designing an API means writing that menu well.
</div>

---

<!-- _class: divider -->

# Part 1
## REST Basics and the Design Process

---

## Key Terms

| Term | Meaning |
|---|---|
| **API** | an interface called by other programs, not by people |
| **REST** | an architectural style: resources accessed through URLs and standard HTTP methods |
| **Resource** | a thing the API manages (article, comment, author) |
| **Endpoint** | one combination of method and URL, for example `GET /api/v1/articles` |
| **Representation** | the form of a resource that is sent, usually JSON |
| **Stateless** | every request carries everything the server needs |
| **Contract** | a written agreement about endpoints, input, and output |

---

## Why Do We Need an API?

<div class="cols">
<div>

**Without an API**
- Each client has its own logic
- Business rules are written many times
- One change means fixing many places

</div>
<div>

**With an API**
- One backend, many clients: web, mobile, partners
- Business rules live in one place
- A new client only needs to read the contract

</div>
</div>

<div class="tip-box">
API clients are often written by other people, in other languages, and you can't fix them. That is why an API must be designed, not just "made to work".
</div>

---

## Five REST Principles

| Principle | Meaning |
|---|---|
| **Client-server** | the client handles display, the server handles data and rules |
| **Stateless** | the server doesn't remember earlier requests, the token is sent every time |
| **Uniform interface** | resources and HTTP methods are used the same way on every endpoint |
| **Cacheable** | a response may say whether the client can store it |
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
  <div class="box">1. Use cases</div>
  <div class="arrow">&rarr;</div>
  <div class="box">2. Resources</div>
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
  <div class="box">8. Documentation</div>
</div>

<div class="tip-box">
Design on paper first, then write code. Changing a URL or a JSON shape after clients use it costs far more than changing controller code.
</div>

---

<!-- _class: divider -->

# Part 2
## Designing Resources and URLs

---

## From Use Case to Resource

Example domain: a blog with **authors**, **articles**, and **comments**.

| Use case | Noun (resource) |
|---|---|
| A reader views the article list | article |
| A reader reads one article | article |
| A user writes a comment | comment |
| An author publishes an article | article (status changes) |
| View the articles of one author | author, article |

- Look for **nouns**, not verbs
- One resource = one concept that has an identity (an ID)

---

## URL Naming Rules

| Rule | Good | Bad |
|---|---|---|
| Nouns, not verbs | `/articles` | `/getArticles` |
| Plural | `/articles/7` | `/article/7` |
| Lowercase, hyphens | `/article-tags` | `/ArticleTags` |
| No extension or trailing slash | `/articles` | `/articles.json/` |
| ID in the path, filters in the query | `/articles/7`, `?status=draft` | `/articles/status/draft` |

<div class="tip-box">
The HTTP method is already the verb. <code>GET /articles</code> reads as "get articles", so there is no need for <code>getArticles</code>.
</div>

---

## CRUD Operations Become Method + URL

| Operation | Method + URL | Success |
|---|---|---|
| List articles | `GET /articles` | 200 |
| One article | `GET /articles/{id}` | 200 |
| Create an article | `POST /articles` | 201 |
| Replace entirely | `PUT /articles/{id}` | 200 |
| Change partially | `PATCH /articles/{id}` | 200 |
| Delete | `DELETE /articles/{id}` | 204 |

```php
Route::apiResource('articles', ArticleController::class);   // 5 routes: index, store, show, update, destroy
```

---

## Relationships and Nesting

```text
GET  /articles/7/comments        comments of article 7
POST /articles/7/comments        add a comment to article 7
GET  /comments/31                one comment (the ID is already unique)
```

<div class="cols">
<div>

**Use nesting when**
- The child makes no sense without the parent
- You want the list of children of a parent

</div>
<div>

**Avoid**
- More than 2 levels: `/a/1/b/2/c/3/d`
- Copying every operation onto two paths

</div>
</div>

<div class="tip-box">
If the child already has a unique ID, single access is just <code>/comments/31</code>. Nesting is for lists and creation.
</div>

---

## Safe and Idempotent Methods

| Method | Safe (doesn't change data) | Idempotent (repeat = same effect) |
|---|---|---|
| `GET` | yes | yes |
| `PUT` | no | yes |
| `PATCH` | no | depends on the design |
| `DELETE` | no | yes |
| `POST` | no | **no** |

<div class="warn-box">
A <code>POST /transactions</code> repeated after a timeout can create two transactions. <code>GET</code>, <code>PUT</code>, and <code>DELETE</code> are safe for a client to repeat.
</div>

---

## PUT vs PATCH

<div class="cols">
<div>

**PUT**: replace the whole resource
```json
PUT /articles/7
{ "title": "New",
  "body": "New body",
  "status": "draft" }
```
Fields not sent are treated as empty.

</div>
<div>

**PATCH**: change part of it
```json
PATCH /articles/7
{ "title": "New" }
```
Only the fields sent change.

</div>
</div>

<div class="tip-box">
In Laravel, PATCH validation rules usually use <code>sometimes</code> so fields that aren't sent are not treated as required.
</div>

---

## Actions That Aren't CRUD

How do you model "publish an article" or "cancel a transaction"?

| Option | Example | When |
|---|---|---|
| Change the **status** with PATCH | `PATCH /articles/7` `{"status":"published"}` | status is an attribute of the resource (recommended) |
| The action as a **sub-resource** | `POST /articles/7/publication` | the action has side effects and a history |
| The action as a verb | `POST /articles/7/publish` | last resort when the other two don't fit |

<div class="warn-box">
Don't create <code>POST /publishArticle</code>. Look for a noun or a status that describes the outcome.
</div>

---

## Idempotency Key: Making POST Safe to Repeat

<div class="flow">
  <div class="box">Client makes key</div>
  <div class="arrow">&rarr;</div>
  <div class="box">POST + key</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Server stores</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Repeat: old result</div>
</div>

```http
POST /api/v1/transactions
Idempotency-Key: 8f14e45f-ceea-467f-a0e1-8b1c2e1d9f10
```

- The same key = the same request, the server doesn't create a second record
- Used for operations that must not duplicate: payments, transactions
- Laravel doesn't provide it out of the box: store the key in a table with a unique index

---

<!-- _class: divider -->

# Part 3
## Designing Responses

---

## Status Codes: Five Groups

| Group | Meaning | Examples |
|---|---|---|
| **2xx** | success | 200 OK, 201 Created, 204 No Content |
| **3xx** | redirected | 301 Moved Permanently, 304 Not Modified |
| **4xx** | the client's mistake | 401, 403, 404, 422, 429 |
| **5xx** | the server's mistake | 500, 503 |

<div class="tip-box">
The client decides its next action from the <b>status code</b> first, then reads the body. Don't reply <code>200</code> with a body of <code>{"error": ...}</code>.
</div>

---

## Commonly Used Status Codes

| Code | Use when |
|---|---|
| **200** OK | GET, PUT, PATCH succeeded |
| **201** Created | POST created a new resource, include a `Location` header |
| **204** No Content | DELETE succeeded, no body |
| **400** Bad Request | the request is broken (invalid JSON) |
| **401** Unauthorized | no identity, or the token is invalid |
| **403** Forbidden | valid identity, but not allowed to access |
| **404** Not Found | the resource doesn't exist |
| **409** Conflict | clashes with the current state (duplicate data, stale version) |
| **422** Unprocessable | the format is right, but the content fails validation |
| **429** Too Many Requests | hit the rate limit |

---

## 401 vs 403 vs 404

<div class="cols">
<div>

**401: who are you?**
- The token is missing, wrong, or expired
- Client: log in again

**403: you may not**
- The token is valid, but the role or ability isn't enough
- Client: show "no access"

</div>
<div>

**404: not found**
- The resource really doesn't exist
- Or it is deliberately hidden from those without access (someone else's draft article)

**422: wrong content**
- Validation failed, say which field is wrong

</div>
</div>

<div class="warn-box">
Treating all of them as "failed" leaves the client not knowing what to do: log in again, fix the input, or give up.
</div>

---

## Response Shape: One Resource and a Collection

```json
// GET /api/v1/articles/7
{
  "data": { "id": 7, "title": "Learning REST", "status": "published" }
}

// GET /api/v1/articles
{
  "data": [ { "id": 7, "title": "Learning REST" }, { "id": 8, "title": "Learning JSON" } ],
  "links": { "next": "/api/v1/articles?page=2" },
  "meta": { "current_page": 1, "per_page": 15, "total": 42 }
}
```

- Use the **same shape** on every endpoint: data in `data`, extra info in `meta` and `links`
- A collection is always an array, even when empty (`[]`), never `null`

---

## Data Conventions in JSON

| Topic | Rule | Example |
|---|---|---|
| Field names | one style only, `snake_case` | `published_at` |
| Dates | ISO 8601, clear time zone | `"2026-08-20T10:30:00Z"` |
| Money | integer in the smallest unit | `"price": 15000` |
| Boolean | `true` / `false`, not `"yes"` | `"is_active": true` |
| Empty | `null` for "no value", still present | `"image": null` |
| IDs | consistent, don't leak ordering if sensitive | `"id": 7` |

<div class="warn-box">
Don't use float decimals for money (<code>0.1 + 0.2</code> is not <code>0.3</code>). Store and send it as an integer.
</div>

---

## API Resource: Filtering What Goes Out

<div class="cols">
<div>

**Without a Resource**
```php
return Article::find($id);
```
Every column goes out, including internal ones (`user_id`, `deleted_at`) and columns added later.

</div>
<div>

**With a Resource**
```php
return new ArticleResource($article);
```
Only the fields you choose. The table may change, the contract stays.

</div>
</div>

```bash
php artisan make:resource ArticleResource
```

---

## API Resource: Code and Relations

```php
class ArticleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'status' => $this->status,
            'published_at' => $this->published_at,
            'author' => new AuthorResource($this->whenLoaded('author')),
            'comments_count' => $this->whenCounted('comments'),
        ];
    }
}
```

- `whenLoaded()` includes a relation **only if it was already loaded**, so it never triggers a silent N+1
- Collections: `ArticleResource::collection($articles)`. A paginator also produces `links` and `meta`

---

## Pagination: Don't Send Everything

| | Offset (`paginate`) | Cursor (`cursorPaginate`) |
|---|---|---|
| **Query** | `limit 15 offset 30` | `where id > 45 limit 15` |
| **Parameter** | `?page=3` | `?cursor=eyJpZCI6NDV9` |
| **Jump to page N** | possible | not possible |
| **Data changes while reading** | rows can be skipped or duplicated | stable |
| **Very large data** | slows down (offset scan) | stays fast (needs an index) |

```php
return ArticleResource::collection(
    Article::latest('id')->paginate(15)->withQueryString()
);
```

<div class="tip-box">
Also cap <code>per_page</code> at a maximum (for example 100), so a client can't ask for 100,000 rows at once.
</div>

---

## Filter, Sort, and Search with the Query String

```text
GET /api/v1/articles?status=published&author_id=3&sort=-published_at&q=rest&per_page=20
```

```php
$articles = Article::query()
    ->when($request->status, fn ($q, $v) => $q->where('status', $v))
    ->when($request->author_id, fn ($q, $v) => $q->where('author_id', $v))
    ->when($request->q, fn ($q, $v) => $q->where('title', 'like', "%{$v}%"))
    ->orderBy(ltrim($sort, '-'), str_starts_with($sort, '-') ? 'desc' : 'asc')
    ->paginate(min($request->integer('per_page', 15), 100));
```

<div class="warn-box">
Keep an allow list of columns that may be sorted (<code>in_array</code> against a list). Never pass client input straight into <code>orderBy()</code>.
</div>

---

## A Consistent Error Format

Every error, from any endpoint, uses the same shape.

```json
// 422: validation failed
{ "message": "The title field is required.",
  "errors": { "title": ["The title field is required."] } }

// 404: not found
{ "message": "Article not found." }
```

- `message`: a summary a person can read
- `errors`: per field, only for 422
- Don't leak stack traces or table names in production (`APP_DEBUG=false`)

<div class="ref-link">A stricter standard: RFC 9457 (Problem Details for HTTP APIs)</div>

---

## Shaping the 404 Error for APIs in Laravel

```php
// bootstrap/app.php
->withExceptions(function (Exceptions $exceptions): void {
    $exceptions->shouldRenderJsonWhen(
        fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
    );

    $exceptions->render(function (NotFoundHttpException $e, Request $request) {
        if ($request->is('api/*')) {
            return response()->json(['message' => 'Resource not found.'], 404);
        }
    });
})
```

- `shouldRenderJsonWhen`: errors under `api/*` are always JSON, never an HTML page
- A failed route model binding (`Article $article`) also becomes a 404 here

---

## Versioning: The API Changes, Old Clients Must Not Break

| Change | Breaks old clients? |
|---|---|
| Adding a field to the response | no |
| Adding a new endpoint | no |
| Removing or renaming a field | **yes** |
| Changing a data type (`"15000"` to `15000`) | **yes** |
| Adding a required field to the request | **yes** |

```php
Route::prefix('v1')->group(function () {          // /api/v1/articles
    Route::apiResource('articles', ArticleController::class);
});
```

- A breaking change = a new version (`/api/v2`). The old version stays alive until clients move
- Announce retirement with the `Deprecation` and `Sunset` headers

---

## Performance: Cheap Responses

| Technique | Effect |
|---|---|
| `with('author')` | avoids N+1 queries when a relation is sent |
| `paginate()` + a `per_page` cap | response size under control |
| index on filter and sort columns | the query doesn't scan the whole table |
| `Cache-Control` / `ETag` | the client may reuse the response (304 Not Modified) |
| compression (gzip) on the web server | smaller payload |

```php
return ArticleResource::collection(Article::with('author')->paginate(15));
```

<div class="tip-box">
Design the response from the client's needs: if a mobile client only needs the title, don't send the whole article body in the list.
</div>

---

<!-- _class: divider -->

# Part 4
## Authentication, Authorization, and Security

---

## Cookie Session vs Token: Different Clients, Different Mechanisms

<div class="cols">
<div>

**Web pages (Meeting 7)**
- The browser stores the cookie automatically
- The session is matched through that cookie
- Fits clients that have a cookie jar

</div>
<div>

**API clients (mobile, outside scripts)**
- No cookie jar like a browser
- The client stores the token itself
- Sent again explicitly on every request

</div>
</div>

<div class="tip-box">
Both prove "who is making this request". Only the way that proof is stored and sent differs.
</div>

---

## The Sanctum Authentication Flow

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
$token = $user->createToken('mobile-client')->plainTextToken;
```

- Only the **hash** of the token is stored in the `personal_access_tokens` table
- `plainTextToken` is visible **only once**, when it is created. The client must store it

---

## The Login Endpoint

```php
public function login(Request $request): JsonResponse
{
    $data = $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required'],
    ]);

    $user = User::where('email', $data['email'])->first();

    if (! $user || ! Hash::check($data['password'], $user->password)) {
        return response()->json(['message' => 'Invalid credentials.'], 401);
    }

    return response()->json([
        'token' => $user->createToken('mobile-client')->plainTextToken,
    ]);
}
```

<div class="tip-box">
The error message is deliberately the same for a wrong email and a wrong password, so an attacker can't learn which emails are registered.
</div>

---

## Protecting Routes with `auth:sanctum`

```php
Route::post('/login', [AuthController::class, 'login']);         // public

Route::middleware('auth:sanctum')->group(function () {           // token required
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::apiResource('articles', ArticleController::class);
});
```

- Without a valid `Authorization: Bearer <token>` header: **401** before reaching the controller
- Same pattern as `role:admin` in Meeting 7, only the proof is a token, not a session

---

## Token Abilities: Permissions per Token

One user can have several tokens with different permissions.

```php
$user->createToken('report-bot', ['articles:read'])->plainTextToken;
$user->createToken('editor-app', ['articles:read', 'articles:write'])->plainTextToken;
```

```php
// bootstrap/app.php: register the middleware aliases
$middleware->alias(['abilities' => CheckAbilities::class, 'ability' => CheckForAnyAbility::class]);

// routes/api.php
Route::post('/articles', [ArticleController::class, 'store'])
    ->middleware(['auth:sanctum', 'abilities:articles:write']);
```

<div class="tip-box">
A token without enough ability is rejected with <b>403</b>. Grant the smallest permission possible: a report bot doesn't need to write.
</div>

---

## Authorization: A Valid Token Doesn't Mean Allowed

<div class="cols">
<div>

**Authentication**: who are you?
- The token is valid, the user is found
- Failure: 401

</div>
<div>

**Authorization**: what may you do?
- Policy, role, or ability
- Failure: 403

</div>
</div>

```php
public function update(Request $request, Article $article): ArticleResource
{
    $this->authorize('update', $article);     // ArticlePolicy: only the author
    $article->update($request->validated());
    return new ArticleResource($article);
}
```

- The policies and roles from Meeting 7 are reused in the API, not rewritten
- Scope queries to the user: `$request->user()->articles()`, not `Article::find($id)` from client input

---

## Token Lifecycle

| Topic | How |
|---|---|
| Logout (revoke this token) | `$request->user()->currentAccessToken()->delete()` |
| Revoke all tokens | `$user->tokens()->delete()` |
| Expiry | `'expiration' => 525600` (minutes) in `config/sanctum.php`, or the 3rd argument of `createToken()` |
| Clean up stale tokens | `php artisan sanctum:prune-expired --hours=24` (scheduled daily) |

<div class="warn-box">
By default Sanctum tokens <b>never expire</b>. For a real application, set a lifetime and give users a way to revoke a lost token.
</div>

---

## Rate Limiting: Protection from Request Floods

```php
// AppServiceProvider::boot()
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});
```

```php
Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () { /* ... */ });
Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');   // 5 per minute
```

- Exceeded: **429 Too Many Requests** with a `Retry-After` header
- The key is per user (or per IP when not logged in), not one limit for everyone
- Login gets a stricter limit to slow down password guessing

---

## API Security Checklist

<div class="cols">
<div>

**Required**
- HTTPS in production
- Validate all input (`validate()`)
- `$fillable` on models, not `$guarded = []`
- Tokens hashed in the database, never logged
- Rate limits, especially on `/login`
- `APP_DEBUG=false` in production

</div>
<div>

**Often forgotten**
- Check ownership of the resource (IDOR)
- Cap `per_page` and the columns allowed for sorting
- Never return a raw model (`password`, `remember_token`)
- CORS only for known origins (`config/cors.php`)
- Error messages don't leak internal details

</div>
</div>

<div class="ref-link">Laravel docs: <code>Sanctum</code>, <code>Routing &rarr; Rate Limiting</code>, and <code>Routing &rarr; CORS</code></div>

---

<!-- _class: divider -->

# Part 5
## Documentation, Testing, and Consuming an API

---

## OpenAPI: A Contract, Not a Note That Goes Stale

<div class="term-box">
<b>OpenAPI:</b> a structured specification (YAML or JSON) that describes endpoints, input, output, and authentication. Tools can read it: interactive docs, client code generators, validators.
</div>

```yaml
openapi: 3.0.0
info: { title: Blog API, version: 1.0.0 }
paths:
  /api/v1/articles:
    get:
      summary: List articles
      responses:
        '200': { description: List of articles }
```

<div class="tip-box">
A text note in a README goes stale the moment one field is renamed. A structured format can be checked by automated tools.
</div>

---

## OpenAPI: Schemas and Security

```yaml
paths:
  /api/v1/articles:
    post:
      security: [ { bearerAuth: [] } ]
      requestBody:
        required: true
        content:
          application/json:
            schema: { $ref: '#/components/schemas/ArticleInput' }
      responses:
        '201': { description: Created }
        '401': { description: Invalid token }
        '422': { description: Validation failed }
components:
  securitySchemes:
    bearerAuth: { type: http, scheme: bearer }
  schemas:
    ArticleInput:
      type: object
      required: [title]
      properties:
        title: { type: string }
```

---

## The Contract-First Workflow

<div class="flow">
  <div class="box">Write contract</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Agree</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Implement</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Test</div>
</div>

- The mobile team and the backend work in parallel from the same contract
- A contract change becomes a conversation, not a surprise
- The contract lives in the repository and is reviewed like code

<div class="tip-box">
Tools like Swagger UI let you try the contract straight from the browser, without writing a client first.
</div>

---

## Testing an API in Laravel

```php
public function test_guest_cannot_create_article(): void
{
    $this->postJson('/api/v1/articles', ['title' => 'X'])
        ->assertUnauthorized();                                  // 401
}

public function test_create_article_validates_title(): void
{
    Sanctum::actingAs(User::factory()->create(), ['articles:write']);

    $this->postJson('/api/v1/articles', [])
        ->assertUnprocessable()                                  // 422
        ->assertJsonValidationErrors('title');
}

public function test_create_article_returns_created(): void
{
    Sanctum::actingAs(User::factory()->create(), ['articles:write']);

    $this->postJson('/api/v1/articles', ['title' => 'Learning REST'])
        ->assertCreated()                                        // 201
        ->assertJsonPath('data.title', 'Learning REST');
}
```

---

## A Client Must Check the Status Before Reading the Body

```php
$login = Http::post("{$baseUrl}/api/login", [
    'email' => $email,
    'password' => $password,
]);

if ($login->failed()) {
    // handle the error here, don't go on to the next step
}

$token = $login->json('token');
```

<div class="warn-box">
A client that reads <code>$login->json('token')</code> without checking <code>failed()</code> fails silently: <code>$token</code> is <code>null</code>, and the error only blows up somewhere confusing.
</div>

---

## Telling Errors Apart and Retrying Correctly

```php
match ($response->status()) {
    201 => /* saved, read $response->json('data') */,
    401 => /* invalid token, log in again */,
    422 => /* input rejected, fix the input */,
    429 => /* too frequent, wait per the Retry-After header */,
    default => /* other error, show it to the user */,
};
```

| Kind | May it be retried automatically? |
|---|---|
| 4xx (except 429) | no, the request itself is wrong |
| 429, 503 | yes, after a delay (`Retry-After`) |
| 5xx on `GET` | yes, with a growing delay (backoff) |
| 5xx on `POST` | only when using an idempotency key |

---

<!-- _class: divider -->

# Part 6
## Case Study: Designing a Blog API from Scratch

---

## Steps 1-2: Use Cases and Resources

**Requirement:** a blog mobile app. Readers view articles and comments. Authors write and publish articles. Logged-in readers may comment.

| Use case | Who | Resource |
|---|---|---|
| View the article list and details | anyone | `articles` |
| Write, edit, delete an article | author (owner) | `articles` |
| Publish an article | author (owner) | status on `articles` |
| View and write comments | view: anyone, write: logged-in user | `comments` (child of `articles`) |
| Log in and out | user | `login`, `logout` |

---

## Step 3: The Endpoint List

| Method + URL | Auth | Success | Errors |
|---|---|---|---|
| `POST /api/v1/login` | public | 200 | 401, 422, 429 |
| `GET /api/v1/articles` | public | 200 | 429 |
| `GET /api/v1/articles/{id}` | public | 200 | 404 |
| `POST /api/v1/articles` | token | 201 | 401, 403, 422 |
| `PATCH /api/v1/articles/{id}` | owner | 200 | 401, 403, 404, 422 |
| `DELETE /api/v1/articles/{id}` | owner | 204 | 401, 403, 404 |
| `GET /api/v1/articles/{id}/comments` | public | 200 | 404 |
| `POST /api/v1/articles/{id}/comments` | token | 201 | 401, 404, 422 |

---

## Step 4: The Representation Shape

<div class="cols">
<div>

**Article (detail)**
```json
{
  "data": {
    "id": 7,
    "title": "Learning REST",
    "body": "Article body...",
    "status": "published",
    "published_at": "2026-08-20T10:30:00Z",
    "author": { "id": 3, "name": "Sari" },
    "comments_count": 12
  }
}
```

</div>
<div>

**Comment**
```json
{
  "data": {
    "id": 31,
    "body": "Nice writing",
    "created_at": "2026-08-21T08:00:00Z",
    "user": { "id": 9, "name": "Budi" }
  }
}
```

- The article list has no `body` (saves payload)
- No `password`, `email`, or raw `user_id`

</div>
</div>

---

## Step 5: List Parameters

```text
GET /api/v1/articles?status=published&author_id=3&q=rest&sort=-published_at&per_page=20&page=2
```

| Parameter | Meaning | Rule |
|---|---|---|
| `status` | filter by status | `draft` is only visible to its author |
| `author_id` | filter by author | an existing integer |
| `q` | search in the title | at least 2 letters |
| `sort` | order | allow list: `published_at`, `title`; prefix `-` = descending |
| `per_page` | page size | default 15, maximum 100 |

---

## Step 6: Errors and Security

| Situation | Status | Body |
|---|---|---|
| POST article body without `title` | 422 | `message` + `errors.title` |
| Article 999 doesn't exist | 404 | `message` |
| No token sent | 401 | `message` |
| Editing another author's article | 403 | `message` |
| Viewing someone else's draft | 404 | hidden, not 403 |
| More than 60 requests per minute | 429 | `Retry-After` |

- Rate limit `throttle:api`, stricter on login
- Tokens carry the `articles:write` ability for write operations
- Every POST/PATCH uses `validate()` or a Form Request

---

## Step 7: Contract and Version

```yaml
paths:
  /api/v1/articles/{id}/comments:
    post:
      summary: Add a comment
      security: [ { bearerAuth: [] } ]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [body]
              properties:
                body: { type: string, maxLength: 500 }
      responses:
        '201': { description: Comment created }
        '401': { description: Invalid token }
        '404': { description: Article not found }
        '422': { description: Validation failed }
```

- Every route lives under `/api/v1`. A breaking change = `/api/v2`

---

## API Design Review Checklist (1/2)

**Resources, URLs, and responses**

- URLs are plural nouns, no verbs
- Methods match their meaning (safe, idempotent)
- Nesting at most 2 levels
- Non-CRUD actions modeled as a status or a sub-resource
- The right status code, not always 200
- Success and error shapes are consistent
- Collections are paginated with a cap

---

## API Design Review Checklist (2/2)

<div class="cols">
<div>

**Security**
- Authentication and authorization are separate (401 vs 403)
- Resource ownership is checked
- Rate limit and HTTPS

</div>
<div>

**Evolution and documentation**
- A version prefix exists
- The OpenAPI contract lives in the repository
- Tests cover 401, 403, 422, and the success path

</div>
</div>

---

<!-- _class: divider -->

# Part 7
## AJAX: Your Own Page Calls a JSON Endpoint

---

## What Is AJAX?

<div class="flow">
  <div class="box">Click</div>
  <div class="arrow">&rarr;</div>
  <div class="box">fetch()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Route</div>
  <div class="arrow">&rarr;</div>
  <div class="box">JSON</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Alpine updates</div>
</div>

- The page calls the server in the background, with no reload
- The server replies with JSON, not HTML
- JavaScript updates only the part of the page that changed

<div class="tip-box">
Example: adding a comment to an article without reloading the article page.
</div>

---

## Two Clients, One JSON Format

| | AJAX from your own page | External API client (Sanctum) |
|---|---|---|
| **Route file** | `routes/web.php` | `routes/api.php` |
| **Proof of identity** | session cookie (web login) | `Authorization: Bearer` header |
| **CSRF** | required for POST/PUT/PATCH/DELETE | none |
| **Middleware** | `auth` | `auth:sanctum` |
| **Response** | JSON + status code | JSON + status code |

<div class="warn-box">
AJAX from your own page whose route lives in <code>api.php</code> gets a 401: there is no session there, only tokens.
</div>

---

## Backend: Route and Controller

```php
// routes/web.php
Route::middleware('auth')->group(function () {
    Route::post('/articles/{article}/comments', [CommentController::class, 'store']);
});
```

```php
public function store(Request $request, Article $article): JsonResponse
{
    $data = $request->validate(['body' => ['required', 'string', 'max:500']]);

    $comment = $article->comments()->create($data + ['user_id' => $request->user()->id]);

    return response()->json($comment, 201);   // 201 Created, not 200
}
```

- Validation is still `validate()` or a Form Request (Meeting 6), no new code
- The status code follows the outcome: 201 created, 404 not found, 422 input rejected

---

## The `Accept` Header Decides the Error Shape

<div class="cols">
<div>

**Without `Accept: application/json`**
- `validate()` fails
- Laravel replies with a **302 redirect** to the previous page
- `fetch` follows the redirect and receives **HTML**
- `res.json()` throws

</div>
<div>

**With `Accept: application/json`**
- `validate()` fails
- Laravel replies **422** with JSON:

```json
{
  "message": "The body field is required.",
  "errors": {
    "body": ["The body field is required."]
  }
}
```

</div>
</div>

<div class="tip-box">
Same as 401 and 403: a request that asks for JSON gets JSON, not a redirect to <code>/login</code>.
</div>

---

## Frontend (1/3): CSRF Token and `fetch`

```html
<!-- layout, inside <head> -->
<meta name="csrf-token" content="{{ csrf_token() }}">
```

```js
const res = await fetch(`/articles/${articleId}/comments`, {
    method: 'POST',
    headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
    },
    body: JSON.stringify({ body: this.body }),
});
```

<div class="warn-box">
Laravel 13 checks the browser's <code>Sec-Fetch-Site</code> header first. If that does not pass (old browser, proxy, insecure connection), the token decides, and without <code>X-CSRF-TOKEN</code> the result is <b>419 Page Expired</b>. Always send the token.
</div>

---

## Frontend (2/3): The Alpine Component

```js
Alpine.data('commentForm', (articleId) => ({
    body: '', errors: {}, comments: [], loading: false,

    async submit() {
        if (this.loading) return;
        this.loading = true;
        this.errors = {};
        try {
            const res = await fetch(`/articles/${articleId}/comments`, { /* as on the previous slide */ });

            if (res.status === 201) {                       // success
                this.comments.push(await res.json());
                this.body = '';
            } else if (res.status === 422) {                // input rejected
                this.errors = (await res.json()).errors;
            } else if (res.status === 401 || res.status === 419) {
                location.reload();                          // session expired
            } else {
                this.errors = { body: ['Something went wrong, try again.'] };
            }
        } catch (e) {
            this.errors = { body: ['Could not reach the server.'] };
        } finally {
            this.loading = false;
        }
    },
}));
```

---

## Frontend (3/3): The Form in Blade

```html
<form x-data="commentForm({{ $article->id }})" @submit.prevent="submit()">
    <textarea x-model="body" rows="3"></textarea>
    <p x-text="errors.body?.[0]" class="text-red-600"></p>

    <button type="submit" :disabled="loading">
        <span x-show="!loading">Send</span>
        <span x-show="loading">Sending...</span>
    </button>

    <template x-for="c in comments" :key="c.id">
        <p x-text="c.body"></p>
    </template>
</form>
```

- `@submit.prevent` stops the form from submitting and the page from reloading
- `:disabled="loading"` stops a double click from saving the comment twice

---

## Common AJAX Pitfalls

| Symptom | Cause |
|---|---|
| **419** Page Expired | the `X-CSRF-TOKEN` header was not sent, and origin verification did not pass |
| **302**, or `res.json()` throws because the body is HTML | the `Accept: application/json` header was not sent |
| **401** although you are logged in in the browser | the route is in `api.php`, not `web.php` |
| **405** Method Not Allowed | wrong method; `@method('PATCH')` only works in HTML forms, `fetch` must use the real method |
| Data saved twice | the button was not disabled while the request ran |

<div class="ref-link">Laravel docs: <code>CSRF Protection &rarr; X-CSRF-TOKEN</code> and <code>Validation &rarr; Validation Error Response Format</code></div>

---

## Applying This to Simple POS

In the jobsheet you apply these concepts to Simple POS:

1. Installing Sanctum, the `POST /api/login` endpoint, and tokens
2. Product and transaction endpoints with an API Resource, 401 and 422
3. Tidying the design: a version prefix, pagination, filtering, and a consistent error format
4. A real HTTP client and OpenAPI documentation
5. One small AJAX feature on a web page: a form that sends JSON through `fetch`

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos-ch09</code></div>

---

## Summary (1/4): Design Process, Resources, and URLs

- Design from use cases: find the nouns, map them to operations, then write code
- URLs are plural nouns, HTTP methods are the verbs, nesting at most 2 levels
- `GET`, `PUT`, `DELETE` are safe to repeat. `POST` is not, unless it uses an idempotency key
- Non-CRUD actions are modeled as a status change or a sub-resource

---

## Summary (2/4): Designing Responses

- Status codes tell the client its next move: 201, 204, 401, 403, 404, 422, 429
- A consistent JSON shape: `data`, `meta`, `links`. Errors are always `message` and `errors`
- An API Resource filters fields. `paginate` or `cursorPaginate` with a `per_page` cap
- Filter and sort through the query string with an allow list. A version prefix for breaking changes

---

## Summary (3/4): Security, Documentation, and Testing

- Sanctum: `createToken()`, the `Authorization: Bearer` header, the `auth:sanctum` middleware
- Abilities limit a token, policies limit an action, `throttle` limits frequency
- Set a token lifetime and provide revocation
- OpenAPI as the contract, tested with `getJson`, `postJson`, and `Sanctum::actingAs`
- A client checks the status before reading the body, and only retries errors that may be retried

---

## Summary (4/4): AJAX

- AJAX from your own page uses a route in `web.php` with the session cookie, not `api.php` with a token
- Every POST/PUT/PATCH/DELETE should carry the CSRF token in the `X-CSRF-TOKEN` header (from `<meta name="csrf-token">`), because without it you can get a 419
- The `Accept: application/json` header makes `validate()` reply 422 JSON instead of a 302 redirect
- The client checks `res.status`: 201 success, 422 show per-field errors, 401/419 session expired
- Disable the button while the request runs so data is not saved twice

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Sanctum, Eloquent API Resources, Pagination, Routing, CSRF Protection, Validation), the OpenAPI specification, RFC 9457, and Fielding's paper on REST architectural principles

Full code: `github.com/se-polinema/simple-pos-ch09`

**Next meeting:** the start of the PBL (Project Based Learning) project, you'll plan the features and architecture of your own web project
