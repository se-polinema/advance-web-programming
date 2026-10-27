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

Consistent endpoints, token authentication, and documentation you can trust

---

## What You'll Learn

1. Design REST API endpoints that consistently follow HTTP method semantics, and curate the response shape with an API Resource

2. Implement token-based authentication with Sanctum for clients that don't have a cookie jar, including how that client itself consumes a protected endpoint

3. Document an API contract using the OpenAPI specification, so other teams don't need to read controller code to know how to call it

4. Call a JSON endpoint from your own web page (AJAX) safely, including the CSRF token and validation error handling

<div class="tip-box">
This deck covers concepts. Applying REST endpoints, Sanctum, OpenAPI, and AJAX to Simple POS happens in the practicum jobsheet.
</div>

---

<!-- _class: divider -->

# Part 1
## Designing REST API Endpoints

---

## Key Terms (1/2)

<div class="term-box">
<b>REST (Representational State Transfer):</b> an API architectural style that maps operations to resources via standard HTTP methods (GET, POST, PUT, DELETE) and a URL that represents the resource itself.
</div>

<div class="term-box">
<b>Endpoint:</b> one combination of an HTTP method and a URL path that performs one specific operation, for example <code>POST /api/login</code>.
</div>

<div class="term-box">
<b>Token:</b> a random string representing a user's identity after a successful login, sent again with every subsequent request as proof that the user is already authenticated.
</div>

---

## Key Terms (2/2)

<div class="term-box">
<b>Sanctum:</b> Laravel's built-in authentication package for token-based APIs, designed for both SPA clients and pure mobile clients.
</div>

<div class="term-box">
<b>API Resource:</b> a Laravel transformation class that turns an Eloquent model into a consistent JSON structure, separating the API response shape from the raw table column structure.
</div>

<div class="tip-box">
REST isn't a strict formal protocol, it's a set of shared conventions that make an API's behavior predictable just from its method and URL, without reading a line of documentation first.
</div>

---

## HTTP Method Semantics Aren't Just Formality

<div class="cols">
<div>

**GET must be safe and idempotent**
- Never changes state on the server
- Calling it repeatedly = same effect as once
- Clients can safely retry without worry

</div>
<div>

**POST may change state**
- Can create a new row in the database
- Calling it twice can create two rows
- The client must handle that risk itself

</div>
</div>

<div class="warn-box">
<code>GET /api/products</code> called repeatedly because of a dropped connection never duplicates data. <code>POST /api/transactions</code> called twice because the first request timed out genuinely can create two transactions, not something safe to assume won't happen.
</div>

---

## API Resource: Curating the Response Shape

An Eloquent model returned directly as JSON can leak internal columns (`updated_at`, `password`) or relationships the client has no use for. An API Resource ensures every endpoint returns a curated, consistent JSON shape.

```php
class ArticleResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'author' => $this->author->name,
        ];
    }
}
```

Only three fields are chosen to appear in the JSON, so whatever column gets added to the `articles` table later doesn't automatically leak to the client.

---

<!-- _class: divider -->

# Part 2
## Token Authentication with Sanctum

---

## Cookie Sessions vs Tokens: Different Clients, Different Mechanisms

<div class="cols">
<div>

**Web pages (Meeting 7)**
- The browser stores cookies automatically
- Sessions are matched via that cookie
- Suits clients that have a cookie jar

</div>
<div>

**API clients (mobile, external scripts)**
- Have no cookie jar like a browser does
- The client stores the token itself
- Sends it explicitly with every request

</div>
</div>

<div class="tip-box">
Both prove "who is making this request", only the mechanism for storing and sending that proof differs, matching the kind of client using it.
</div>

---

## The Sanctum Authentication Flow

<div class="flow">
  <div class="box">POST /api/login</div>
  <div class="arrow">&rarr;</div>
  <div class="box">createToken()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Token sent to the client</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Authorization: Bearer header</div>
</div>

```php
$user = Auth::user();
$token = $user->createToken('mobile-client')->plainTextToken;
```

`createToken()` stores that token as a hash in the `personal_access_tokens` table, and `->plainTextToken` is the only chance that raw token is ever visible. After this login response, the server can never show that same token in readable form again.

---

## Protecting a Route with auth:sanctum

A route that needs protection just gets wrapped in the `auth:sanctum` middleware, similar to the `role:admin` pattern from Meeting 7, except what's checked this time is the presence and validity of a token via the `Authorization` header, not a cookie session.

```php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/articles', [ArticleController::class, 'index']);
    Route::post('/articles', [ArticleController::class, 'store']);
});
```

<div class="warn-box">
Without a valid <code>Authorization: Bearer &lt;token&gt;</code> header, this middleware rejects the request before it ever reaches the controller, exactly like <code>role:admin</code> rejects a non-admin user before reaching the protected action.
</div>

---

<!-- _class: divider -->

# Part 3
## Consuming and Documenting the API

---

## A Client Must Check Status Before Reading Content

An API client (a mobile app, a PHP script, or any language) must never assume every request succeeds.

```php
$login = Http::post("{$baseUrl}/api/login", [
    'email' => $email,
    'password' => $password,
]);

if ($login->failed()) {
    // handle the error here, don't proceed to the next step
}

$token = $login->json('token');
```

<div class="warn-box">
A client that reads <code>$login->json('token')</code> directly without checking <code>failed()</code> first fails silently: wrong credentials make <code>$token</code> end up <code>null</code> with no clear reason why, and the error only explodes a few steps later somewhere confusing.
</div>

---

## Distinguishing Error Types

Not every error is handled the same way. The HTTP status code tells the client what the right next move is.

```php
match ($response->status()) {
    201 => /* saved, read $response->json('data') */,
    401 => /* invalid token, the client must log in again */,
    422 => /* input rejected, fix the input, not re-login */,
    default => /* some other error, show it to the user */,
};
```

<div class="tip-box">
401 means the problem is the client's identity (an expired or revoked token), while 422 means the problem is the data that was sent. Treating both as "just log in again" makes the client retry login pointlessly when the real problem is the input.
</div>

---

## OpenAPI: A Contract, Not a Note That Goes Stale

<div class="term-box">
<b>OpenAPI:</b> a structured specification (YAML or JSON) that describes an API's endpoints, readable by other tools such as interactive documentation generators or client code generators.
</div>

```yaml
paths:
  /api/articles:
    get:
      summary: Get the list of articles
      responses:
        '200':
          description: List of articles
```

<div class="tip-box">
Plain text notes in a README go stale fast, because nothing forces anyone to update them when a response field gets renamed. A structured format like OpenAPI can be checked by automated tooling, so stale documentation gets caught by a failing test, not by another team's complaint later.
</div>

---

<!-- _class: divider -->

# Part 4
## AJAX: Your Own Page Calls a JSON Endpoint

---

## What Is AJAX?

<div class="flow">
  <div class="box">Click a button</div>
  <div class="arrow">&rarr;</div>
  <div class="box">fetch()</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Route + controller</div>
  <div class="arrow">&rarr;</div>
  <div class="box">JSON response</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Alpine updates the page</div>
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

You'll design and build `POST /api/login`, `GET /api/products`, and `POST /api/transactions` for Simple POS in the practicum jobsheet: protected by a Sanctum token, consumed by a real HTTP client, and documented with OpenAPI. You also add one small AJAX feature to a web page: a form that sends JSON through `fetch` and shows validation errors without a reload.

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos-ch09</code></div>

---

## Summary (1/3)

- REST endpoints consistently follow HTTP method semantics: `GET` is safe and idempotent, `POST` may change state and risks duplication if retried
- An API Resource curates the JSON shape returned, separating the API response from the raw table column structure
- Sanctum issues a token via `createToken()`, sent by the client through the `Authorization: Bearer` header, checked by the `auth:sanctum` middleware on protected routes

---

## Summary (2/3)

- An API client must check `failed()` before reading a response's content, and distinguish handling 401 (log in again) from 422 (fix the input), instead of treating every error the same way
- An OpenAPI specification documents each endpoint's `paths`, `requestBody`, and `responses` in a structured format that automated tooling can check, not just a passive note that goes stale

---

## Summary (3/3): AJAX

- AJAX from your own page uses a route in `web.php` with the session cookie, not `api.php` with a token
- Every POST/PUT/PATCH/DELETE should carry the CSRF token in the `X-CSRF-TOKEN` header (from `<meta name="csrf-token">`), because without it you can get a 419
- The `Accept: application/json` header makes `validate()` reply 422 JSON instead of a 302 redirect
- The client checks `res.status`: 201 success, 422 show per-field errors, 401/419 session expired
- Disable the button while the request runs so data is not saved twice

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Sanctum, CSRF Protection, Validation), the OpenAPI specification, and Fielding's paper on REST architectural principles

Full code: `github.com/se-polinema/simple-pos-ch09`

**Next meeting:** the start of the PBL (Project Based Learning) project, you'll plan the features and architecture of your own web project
