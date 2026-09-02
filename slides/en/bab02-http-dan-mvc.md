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

Meeting 2: **HTTP Protocol and the MVC Pattern**

Request/Response Cycle & Web Application Architecture

---

## What You'll Learn

1. Explaining the HTTP **request/response** cycle (method, status code, header) and mapping it onto routing code

2. Comparing the **MVC**, **MVVM**, and **Clean Architecture** patterns, and explaining how Laravel implements MVC

3. Recognizing the roles of **route**, **controller**, and **middleware**, including modern routing patterns: **route parameters**, **named routes**, **route groups**, and **resource routing**

4. Explaining how to organize controllers: **resource controllers**, **single-action controllers**, and the *thin controller* principle

<div class="tip-box">
This slide covers concepts. The practical steps for writing routes, controllers, and middleware are covered separately outside this slide.
</div>

---

<!-- _class: divider -->

# Part 1
## The HTTP Request/Response Cycle

---

## The Post Office Analogy

<div class="cols">
<div>

**A letter**
- Comes in through the intake counter
- The clerk reads the address & type of mail
- Forwarded to the right department
- The clerk doesn't open the envelope or decide the reply's content

</div>
<div>

**A request to Simple POS**
- Comes in through one door
- Sorted by its address & type
- Forwarded to the right handler for processing
- The sorter doesn't decide the response's content

</div>
</div>

<div class="warn-box">
If the sorting goes wrong (e.g. a delete-product request gets forwarded without checking whether the sender is an admin), the application loses control over who's allowed to change what.
</div>

---

## Anatomy of a Request

<div class="term-box">
<b>Request:</b> what a browser sends to a server, carrying a method, an address (URL), headers, and sometimes data (a form, JSON).
</div>

<div class="term-box">
<b>Route:</b> a rule mapping one combination of method and URL to the code that will handle it.
</div>

- Every request always carries a **method** stating the request's intent
- It's this method that determines which route matches, not the URL alone

---

## HTTP Methods

| Method | Meaning | Example on Simple POS |
|---|---|---|
| `GET` | Requesting data, **without changing** anything server-side | Rendering the `/transactions` page |
| `POST` | Submitting new data | Saving a new cashier transaction |
| `PATCH` | Updating part of existing data | Updating product stock |
| `DELETE` | Removing data | Removing a product from the catalog |

Other methods worth knowing: **`PUT`** (replacing all of the data at once), **`HEAD`** (like `GET` but only asking for headers, no body), **`OPTIONS`** (asking which methods the server allows).

<div class="ref-link">Full list of methods: <code>developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Methods</code></div>

---

## Method Ground Rules: Safe & Idempotent

<div class="term-box">
<b>Safe:</b> methods that don't change anything server-side: <code>GET</code>, <code>HEAD</code>. <b>Idempotent:</b> methods that produce the same result no matter how many times they're sent: <code>GET</code>, <code>PUT</code>, <code>DELETE</code>; <code>POST</code> is not.
</div>

- Browsers & servers assume this rule is followed: refresh, the back button, and caching all depend on it
- `POST` isn't idempotent, which is why the save-then-redirect pattern on the next slide is needed

<div class="warn-box">
Strict rule: <code>GET</code> must never change data server-side. Breaking this rule makes application behavior unpredictable, e.g. refreshing a page accidentally deleting data.
</div>

---

## Anatomy of a Response

<div class="term-box">
<b>Response:</b> what a server sends back to a browser, carrying a status code, headers, and a body (HTML, JSON, a redirect).
</div>

<div class="flow">
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Server</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Response</div>
</div>

<div class="tip-box" style="margin-top:30px;">
A response always carries a <b>status code</b>, a three-digit number summarizing the outcome before a single byte of the body gets read.
</div>

---

## The Five Status Code Classes

Hundreds of status codes are grouped by their first digit: you only need to memorize the five classes, not every code.

| Class | Meaning | The Gist |
|---|---|---|
| `1xx` | Informational | "Received, still processing", rarely seen directly |
| `2xx` | Success | The request was processed successfully |
| `3xx` | Redirection | The browser is told to go to another address |
| `4xx` | Client Error | A mistake on the sender's side (wrong address, invalid data) |
| `5xx` | Server Error | A mistake on the server's side |

<div class="ref-link">Full list: <code>developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status</code></div>

---

## Status Codes on Simple POS

| Code | Meaning | Example on Simple POS |
|---|---|---|
| 200 | OK | The `/transactions` page renders successfully |
| 302 | Redirect | After `/pos` saves, the browser is sent to the detail page |
| 404 | Not Found | Opening `/transactions/9999` for an ID that doesn't exist |
| 422 | Unprocessable Entity | The transaction form is submitted with insufficient stock |
| 500 | Server Error | An unhandled error on the server side |

- Notice the pattern: 2xx = success, 3xx = address change, 4xx = sender-side mistake, 5xx = server-side mistake

---

## The 302 Pattern: Save-then-Redirect

<div class="flow">
  <div class="box">POST /pos</div>
  <div class="arrow">&rarr;</div>
  <div class="box">302 + Location</div>
  <div class="arrow">&rarr;</div>
  <div class="box">GET /transactions/{id}</div>
</div>

<div class="tip-box" style="margin-top:30px;">
After <code>POST /pos</code> successfully saves a transaction, the server doesn't send HTML back right away: it sends a 302 response with a <code>Location</code> header telling the browser to request another address instead.
</div>

- This pattern repeats across almost every data-writing feature
- Stops a user from hitting **refresh** and accidentally submitting the same data twice

---

## Headers: Metadata Outside the Body

<div class="term-box">
<b>Header:</b> metadata that accompanies a request or response, outside its main body.
</div>

<div class="cols">
<div>

**Request headers** (browser &rarr; server)
- `Content-Type`: format of the data being sent
- `Accept`: the response format wanted
- `Authorization`: sender's identity token
- `Cookie`: session data sent back

</div>
<div>

**Response headers** (server &rarr; browser)
- `Content-Type`: format of the response body
- `Location`: the redirect target address
- `Set-Cookie`: the server hands off session data
- `Cache-Control`: whether the response may be cached

</div>
</div>

<div class="ref-link">Full list of headers: <code>developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers</code></div>

---

## Seeing HTTP Directly

- Modern browsers provide **DevTools &rarr; the Network tab** to see every request-response that happens
- Each row shows: method, address, status code, and response time
- The most direct way to prove that "behind every click is a real HTTP request"

<div class="tip-box">
You'll put this straight into practice: opening DevTools and watching real requests from routes you build yourself.
</div>

---

<!-- _class: divider -->

# Part 2
## MVC, MVVM, and Clean Architecture

---

## The Problem MVC Solves

- Just accepting requests and sending responses isn't enough to keep code clean as an application grows
- Without a firm separation of responsibilities, code that "sorts requests", "fetches data", and "builds the display" ends up mixed in one file
- The **MVC** (Model-View-Controller) pattern answers this by drawing a firm line between three responsibilities

---

## Model, View, and Controller

<div class="term-box">
<b>MVC:</b> the Model owns data, the View owns presentation, the Controller owns the request flow between them.
</div>

<div class="cols">
<div>

**Back to the post-office analogy**
- Controller = the sorting clerk
- Model = the filed records holding the actual data
- View = the reply form handed to the sender

</div>
<div>

**Practical rule for where code goes**
- Touches data &rarr; Model
- Handles request flow &rarr; Controller
- Renders output &rarr; View

</div>
</div>

<div class="warn-box">
The framework doesn't enforce this: a query inside a view still runs. This pattern is a discipline the code's author has to maintain.
</div>

---

## MVC in Laravel's Folder Structure

| Folder | MVC Role |
|---|---|
| `routes/web.php` | Controller: URL registration |
| `app/Http/Controllers/` | Controller: request-handling classes |
| `app/Models/` | Model: data representation & business rules |
| `resources/views/` | View: what the user sees |

<div class="tip-box">
This folder structure isn't an accident: it embodies the same MVC pattern as the diagram earlier.
</div>

---

## MVVM

<div class="term-box">
<b>MVVM (Model-View-ViewModel):</b> inserts a ViewModel between Model and View; the ViewModel holds view state and keeps it automatically synced to the View through two-way binding.
</div>

- Popular in **reactive** interface applications: the display keeps changing without a page reload
- More relevant to frontend frameworks (e.g. Vue) than to server-rendered applications like Simple POS today

---

## Clean Architecture

<div class="term-box">
<b>Clean Architecture:</b> isolates core business rules (use cases) entirely from whatever framework is in use, so they can be tested, and even moved to a different framework, without being touched.
</div>

- Benefit: business rules can be tested and moved without depending on the framework
- Cost: an extra abstraction layer that needs maintaining

<div class="warn-box">
For an application at Simple POS's scale, isolation this strict adds abstraction that isn't yet worth its cost. Laravel's built-in MVC is already clean enough.
</div>

---

## Comparing the Three Patterns

| Pattern | Main Separation | Typical Use |
|---|---|---|
| **MVC** | Model, View, Controller | Laravel (built-in) |
| **MVVM** | Model, View, ViewModel | Applications with two-way binding between view and state |
| **Clean Architecture** | Use-case layer isolated from the framework | Large systems with heavy business logic |

---

<!-- _class: divider -->

# Part 3
## Modern Routing and Controller Organization

From URLs to clean controllers

---

## Route, Controller, and Middleware

<div class="term-box">
<b>Controller:</b> a class holding request-handling methods, invoked by whichever route matches.
</div>

<div class="term-box">
<b>Middleware:</b> a layer that inspects or transforms a request before it reaches a controller, for example checking whether the user is logged in.
</div>

<div class="flow">
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Route</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Middleware</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Controller</div>
</div>

- The hands-on practicum will write all three for Simple POS endpoints

---

## Route Parameters: Dynamic Addresses

<div class="term-box">
<b>Route parameter:</b> a part of the address written in curly braces, e.g. <code>{id}</code>, whose value gets filled in from the real URL and passed to the controller.
</div>

```php
Route::get('/transactions/{id}', [TransactionController::class, 'show']);
```

- `/transactions/1`, `/transactions/2`, `/transactions/9999`: one route serves them all
- The `{id}` value is received by the `show` method as an argument
- A missing ID &rarr; **404** (see the status code table back in Part 1)

---

## Named Routes: Addresses Can Change, Names Don't

<div class="term-box">
<b>Named route:</b> a unique label attached to a route via <code>-&gt;name()</code>, so the rest of the application refers to that name instead of the raw address.
</div>

```php
Route::get('/pos', [TransactionController::class, 'create'])
    ->name('pos.create');
Route::post('/pos', [TransactionController::class, 'store'])
    ->name('transactions.store');
```

- `GET /pos` and `POST /pos` are **two different routes** even though the address is the same, distinguished by their method
- Links/redirects are written as `route('pos.create')`. Address changes from `/pos` to `/checkout`? No caller needs editing
- Naming convention: `source.action`, e.g. `transactions.index`, `transactions.store`, etc.

---

## Route Groups: Shared Rules

<div class="term-box">
<b>Route group:</b> wraps several routes so they share the same middleware, address prefix, or name prefix, written once, applied to all of them.
</div>

```php
Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])
        ->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])
        ->name('transactions.store');
});
```

<div class="warn-box">
A new route that forgets to be wrapped in the right middleware group is an easy-to-miss security hole: a delete-category route meant only for admins becomes accessible to anyone who knows the address. Always check a new route's position before considering it done.
</div>

---

## Resource Controllers: Seven Conventional Actions

Any CRUD feature always needs the same seven actions. Laravel standardizes them into a naming convention for controller methods.

<table class="small">
<tr><th>Action</th><th>Method</th><th>URL</th><th>Task</th></tr>
<tr><td><code>index</code></td><td>GET</td><td><code>/products</code></td><td>List all products</td></tr>
<tr><td><code>create</code></td><td>GET</td><td><code>/products/create</code></td><td>Add-product form</td></tr>
<tr><td><code>store</code></td><td>POST</td><td><code>/products</code></td><td>Save a new product</td></tr>
<tr><td><code>show</code></td><td>GET</td><td><code>/products/{id}</code></td><td>A single product's detail</td></tr>
<tr><td><code>edit</code></td><td>GET</td><td><code>/products/{id}/edit</code></td><td>Edit-product form</td></tr>
<tr><td><code>update</code></td><td>PATCH</td><td><code>/products/{id}</code></td><td>Save changes</td></tr>
<tr><td><code>destroy</code></td><td>DELETE</td><td><code>/products/{id}</code></td><td>Delete a product</td></tr>
</table>

---

## `Route::resource`: Seven Routes, One Line

```php
Route::resource('products', ProductController::class);
```

- This one line registers all 7 routes from the previous slide at once, complete with named routes (`products.index`, `products.show`, etc.)
- Only need some of them? `->only(['index', 'show'])`
- The same convention across every feature means anyone on the team instantly knows where an action lives

<div class="tip-box">
The <code>php artisan route:list</code> command shows a table of every registered route (method, URL, name, and middleware) without opening route files one by one.
</div>

---

## Single-Action Controller

<div class="term-box">
<b>Single-action controller:</b> a controller with one <code>__invoke()</code> method for one single task, used when an action doesn't make sense folded into the seven resource actions.
</div>

```php
Route::get('/transactions/{id}/receipt', PrintReceiptController::class);
```

- Printing a transaction receipt isn't `show`, isn't `update`: it's a standalone action
- Its route points straight at the class, with no method name
- A sign you need one: an action keeps getting "forced" into a resource method that doesn't fit

---

## The Thin Controller Principle

<div class="term-box">
<b>Thin controller:</b> a controller only handles flow: accepting a request, calling the right party, choosing a response. Business rules live in the Model (or a service layer), not the controller.
</div>

<div class="cols">
<div>

**Fat controller (avoid)**
- Calculate totals, deduct stock, validate, format output: all in one method
- Hard to test, hard to reuse

</div>
<div>

**Thin controller (the goal)**
- `store` only validates input, hands the calculation off to the Model, then redirects
- The stock logic can be reused from anywhere

</div>
</div>

<div class="warn-box">
Remember the rule from Part 2: touches data &rarr; Model, handles flow &rarr; Controller. A fat controller is a slow-motion violation of MVC: each line feels small, until one day your <code>store</code> method is 200 lines long.
</div>

---

## Summary

- A request carries a **method** (`GET`/`POST`/`PATCH`/`DELETE` + `PUT`/`HEAD`/`OPTIONS`); a response carries a **status code** split into five classes (`1xx`&ndash;`5xx`); **headers** carry metadata in both directions

- **MVC** separates Model (data), View (presentation), Controller (flow); **MVVM** suits reactive interfaces; **Clean Architecture** suits large systems. Laravel maps MVC directly onto its folder structure

- Modern routing: **route parameters** (`{id}`), **named routes** (`->name()`), **route groups** (shared middleware/prefix), and **`Route::resource`** which registers seven actions at once

- Controller organization: **resource controllers** for CRUD, **single-action controllers** for standalone actions, and the **thin controller** principle: flow in the controller, business rules in the Model

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation &middot; MDN Web Docs (developer.mozilla.org) &middot; Fielding's (2000) dissertation on REST

Full code: `github.com/se-polinema/simple-pos`

**Next meeting:** Frontend & Templating (Blade, Tailwind, Alpine)
