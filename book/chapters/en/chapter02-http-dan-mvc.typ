#import "/template.typ": *

= HTTP Protocol and the MVC Pattern <ch:http-dan-mvc>

#chapterhero("blue", [Map the HTTP request/response cycle onto the MVC pattern, then write Simple POS's first route and controller.], [#icon("route")#h(1em)the HTTP cycle], [#icon("sitemap")#h(1em)MVC vs MVVM], [#icon("code")#h(1em)routes & controllers])

A letter dropped off at a post office doesn't land on the right desk by
itself. It comes in through the intake counter, a clerk reads the address
and the type of mail (a regular letter, a parcel, express delivery), then
forwards it to the right department: accounting if the envelope says
"invoice", HR if it's a job application. The clerk never opens the
envelope or decides what the reply should say; the job is purely sorting
and forwarding. Every time Simple POS receives a request from a browser,
whether a cashier clicks "Save Transaction" or an admin opens the reports
page, that request goes through exactly the same process: one entry point,
sorted by address and type, forwarded to the right handler. Get that
sorting wrong, say a request to delete a product gets forwarded to a
handler that never checks whether the sender is actually an admin, and the
shop loses control over who can change what.

#strong[What You'll Learn]

+ explain the HTTP request/response cycle (method, status code, header) and map it onto Simple POS route code;
+ compare the MVC, MVVM, and Clean Architecture patterns, and explain how Laravel implements MVC in practice;
+ write a route and controller for the `/pos` and `/transactions` endpoints on Simple POS, including separating web routes from their middleware groups.

== The HTTP Request/Response Cycle <sec:http-dan-mvc-1>

#istilahpenting[
/ Request: What a browser sends to a server, carrying a method, an address (URL), headers, and sometimes data (a form, JSON).
/ Response: What a server sends back to a browser, carrying a status code, headers, and a body (HTML, JSON, a redirect).
/ Route: A rule mapping one combination of method and URL to the code that will handle it.
/ Controller: A class holding request-handling methods, invoked by whichever route matches.
/ Middleware: A layer that inspects or transforms a request before it reaches a controller, for example checking whether the user is logged in.
]

Every time a browser requests a page or submits a form, that request takes
the shape of an HTTP #term[request] that always carries a #emph[method]
stating its intent. Four methods show up constantly throughout this book:
`GET` (asking for data, without changing anything server-side),
`POST` (submitting new data, such as saving a cashier's transaction),
`PATCH` (updating part of existing data), and `DELETE` (removing
data). The server answers with a #term[response] that always carries a
#emph[status code], a three-digit number summarizing the outcome before a
single byte of the body gets read.

#figure(
  table(
    columns: (0.6fr, 1fr, 2fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Code], [Meaning], [Example on Simple POS],
    table.hline(stroke: 0.5pt),
    [200], [OK], [The `/transactions` page renders successfully],
    [302], [Redirect], [After `/pos` saves, the browser is sent to the detail page],
    [404], [Not Found], [Opening `/transactions/9999` for an ID that doesn't exist],
    [422], [Unprocessable Entity], [The transaction form is submitted with insufficient stock],
    [500], [Server Error], [An unhandled error on the server side],
    table.hline(stroke: 0.8pt),
  ),
  caption: [HTTP status codes that show up on Simple POS],
) <tab:status-code>

Code 302 deserves special attention because the pattern repeats across
nearly every write-heavy feature in Simple POS: once `POST /pos`
successfully saves a transaction, the server doesn't send back an HTML page
directly; it sends a 302 response carrying a `Location` header that
tells the browser to request a different address instead, in this case the
detail page for the transaction just created. That save-then-redirect
pattern stops a user from hitting refresh and accidentally submitting the
same transaction twice.

#notebox[
Request and response headers carry metadata outside the main body. The
`Content-Type` header states the body's format (`text/html`,
`application/json`); the `Authorization` header, covered in
Chapter~9, will carry a Sanctum token for requests coming from a mobile
cashier app.
]

== MVC, MVVM, and Clean Architecture <sec:http-dan-mvc-2>

Handling a request and sending a response isn't enough on its own to keep
code organized as an application grows. The #term[MVC pattern]
(Model-View-Controller) answers that by drawing a firm line between three
responsibilities: the Model owns data and business rules (say, how stock
gets recalculated after a transaction), the View owns what the user sees,
and the Controller sits in the middle, accepting a request, calling the
relevant Model, then picking which View to render as the answer. Back to
the post office analogy, the Controller is the sorting clerk, the Model is
the actual filed records, and the View is the reply form finally handed to
the sender.

#figure(
  table(
    columns: (0.9fr, 1.3fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Pattern], [Main Separation], [Typical Use],
    table.hline(stroke: 0.5pt),
    [MVC], [Model, View, Controller], [Laravel (built in)],
    [MVVM], [Model, View, ViewModel], [Applications with two-way binding between view and state],
    [Clean Architecture], [Use-case layer isolated from the framework], [Large systems with heavy business logic],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Comparing MVC, MVVM, and Clean Architecture],
) <tab:mvc-mvvm-clean>

#term[MVVM] (Model-View-ViewModel), popular in reactive interface
frameworks, inserts a ViewModel between Model and View: the ViewModel holds
view state and keeps it automatically synced to the View through two-way
binding, a pattern that suits interfaces that keep changing without a full
page reload. #term[Clean Architecture] goes further still, isolating core
business rules (#emph[use cases]) entirely from whatever framework is in
use, so those rules can be tested, and even moved to a different framework,
without touching them. For an application at Simple POS's scale, that
level of isolation adds an abstraction layer the benefit doesn't yet
justify; Laravel's built-in MVC already separates responsibilities cleanly
without piling on complexity nobody needs.

Mapping MVC onto Laravel's folder structure was already touched on in
Chapter~1: `routes/web.php` registers which address is handled by
which controller, `app/Http/Controllers/` holds the Controller
classes, the Eloquent models in `app/Models/` (covered fully starting
Chapter~5) play the Model role, and the Blade files in
`resources/views/` (covered starting Chapter~3) play the View role.

== Hands-On: Routing and Controllers on Simple POS <sec:http-dan-mvc-3>

#heading(level: 3, numbering: none, outlined: false)[Exercise 2.1: Creating the Transaction Controller]

#listing(```bash
php artisan make:controller TransactionController
```)

This command generates an empty `TransactionController` file in
`app/Http/Controllers/`, ready to fill with request-handling methods.
On Simple POS, this controller ends up with four methods:
`create` renders the cashier page for picking products,
`store` saves a new transaction, `index` lists past
transactions, and `show` renders one transaction's detail.

#listing(file: "routes/web.php", ```php
Route::middleware('auth')->group(function () {
    Route::get('/pos', [TransactionController::class, 'create'])
        ->name('pos.create');
    Route::post('/pos', [TransactionController::class, 'store'])
        ->name('transactions.store');
    Route::get('/transactions', [TransactionController::class, 'index'])
        ->name('transactions.index');
});
```)

Notice that `GET /pos` and `POST /pos` are two separate routes
despite sharing the exact same address: they're distinguished by their
HTTP method, one renders the cashier form, the other processes it. All
three routes also sit inside `Route::middleware('auth')->group(...)`,
meaning every request into them must pass through the `auth` middleware
first, a layer that confirms the sender is logged in before the request
ever reaches `TransactionController`.

#warningbox[
Registering a new route without wrapping it in the right #emph[middleware
group] is an easy mistake to miss, with serious consequences: a route that
should only be reachable by an admin, say deleting a product category, will
be reachable by anyone who knows its address if it's left out of
`Route::middleware('role:admin')->group(...)`. Always check that a new
route sits inside the correct middleware group before considering it done.
]

To inspect every route already registered, including its method and
middleware, Artisan ships a command that prints a compact table without
opening a single route file by hand:

#listing(```bash
php artisan route:list
```)

#challengebox[
Add a new route, `GET /pos/history`, to `routes/web.php`
pointing at a `history` method on `TransactionController`,
wrapped in the same `auth` middleware as the other `/pos` routes.
The method can return plain text for now, say `return "Cashier
history";`. Run `route:list` afterward and confirm your new route
shows up with the correct method and middleware.
]

#branchref("chapter-02")

== Summary <sec:http-dan-mvc-rangkuman>

- Every HTTP request carries a method (`GET`, `POST`,
      `PATCH`, `DELETE`) and every response carries a three-digit
      status code (200, 302, 404, 422, 500) that summarizes the outcome
      before its body gets read.
- MVC separates the Model (data and business rules), the View
      (presentation), and the Controller (request sorter); MVVM suits
      reactive interfaces, Clean Architecture suits large systems with
      complex business rules, and Laravel maps MVC directly onto
      `routes/`, `app/Http/Controllers/`, `app/Models/`, and
      `resources/views/`.
- The `/pos` and `/transactions` routes on Simple POS
      are registered in `routes/web.php`, handled by
      `TransactionController`, and wrapped in `auth` middleware
      so only logged-in users can reach them.

== Exercises

+ Run `route:list` on the Simple POS project from Chapter~1,
      then identify which HTTP methods are used for the `/pos` route.
+ Add a new route, `GET /pos/print-receipt`, that for now just
      returns the text `"Receipt"`, then confirm through
      `route:list` that it shows up with the correct address.
+ Explain in your own words: why are `GET /pos` and
      `POST /pos` treated as two different routes despite sharing the
      exact same URL.
+ #strong[Self-check:] without reopening this chapter, try explaining
      in your own words: (a) the difference in responsibility between the
      Model, View, and Controller, (b) when status code 422 shows up on
      Simple POS, and (c) what the `auth` middleware does on a route.
      Check your answers against this chapter.

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for routing and controller conventions, and Fielding's
dissertation #cite(<fielding2000rest>) for the semantics of HTTP methods and
status codes that later ground the REST architecture in Chapter~9.
