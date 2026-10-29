#import "/template.typ": *

= Authentication, Authorization, and RBAC <ch:autentikasi-dan-otorisasi>

#chapterhero("purple", [Separate who is allowed in from what they're allowed to do, then build a custom role middleware that keeps admin pages closed to ordinary cashiers.], [#icon("lock")#h(1em)login & sessions], [#icon("user-shield")#h(1em)role middleware], [#icon("users-cog")#h(1em)RBAC])

A layered office building usually has two doors with different rules.
The access card reader at the lobby checks exactly one thing: is this
card registered as belonging to a building employee, yes or no. Once
past the lobby, that same person still stops at the server room door,
and the question there is different: no longer "are you an employee"
but "is your role actually authorized to enter this specific room". A
receptionist with a perfectly valid card still gets turned away at the
server room if her role isn't IT staff. Simple POS splits those two
questions the same way. Authentication answers the lobby question: who
are you, proven through an email and a password. Authorization answers
the server room question: given that identity, which pages are actually
allowed.

#strong[What You'll Learn]

+ implement login and logout in Simple POS using Laravel's built-in authentication system, including the demo admin and cashier accounts;
+ write a custom `role:admin` middleware to restrict access to the product, category, and report pages to the admin role only;
+ compare Simple POS's manual RBAC approach (a custom middleware) with packages such as Laravel Breeze and Spatie Permission, and when each fits better.

== Authentication: Login and User Sessions <sec:autentikasi-dan-otorisasi-1>

#istilahpenting[
/ Authentication: The process of proving a user's identity, usually through an email and password combination, answering the question "who are you".
/ Authorization: The process of deciding what a proven identity is allowed to do, answering the question "what are you allowed to do".
/ Middleware: A layer of code that inspects or modifies a request before it reaches the controller, attached to a specific route or route group.
/ RBAC: #emph[Role-Based Access Control], an authorization approach that ties access permissions to a user's role (admin, cashier) rather than to individual users one by one.
/ Session: Data for a logged-in user, stored server-side across requests, usually identified through a browser cookie, so a user doesn't have to log in again on every page.
]

Laravel ships a built-in authentication system through the
`Auth` facade, and Simple POS uses it directly with no
additional package. `LoginController` accepts an email and
password from a form, then hands the check off to
`Auth::attempt(['email' => ..., 'password' => ...])`.

#listing(file: "app/Http/Controllers/Auth/LoginController.php", ```php
public function store(Request $request)
{
    $credentials = $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required'],
    ]);

    if (Auth::attempt($credentials)) {
        $request->session()->regenerate();
        return redirect()->intended('/dashboard');
    }

    return back()->withErrors(['email' => 'Credentials do not match.']);
}
```)

`Auth::attempt()` matches the email against a row in the
`users` table, then verifies the password against its stored
hash; the plain password itself is never stored in any directly
readable form. On a match, Laravel stores that user's identity in the
session, and `$request->session()->regenerate()` issues a new
session ID after a successful login, preventing a #emph[session
fixation] attack where an attacker plants his own old session ID before
the victim logs in. Simple POS ships two demo accounts,
`admin@pos.test` with the admin role and `kasir@pos.test`
with the cashier role, both signing in through the same login form; the
only difference is the `role` column value on each account's
`users` row.

== RBAC with a Custom Middleware <sec:autentikasi-dan-otorisasi-2>

A successful login only proves identity; it doesn't yet decide which
pages that identity is allowed to reach. Laravel's built-in
`auth` middleware is already enough to block a user who isn't
logged in at all, but Simple POS needs one more layer: telling a
cashier apart from an admin once both have successfully logged in.

#listing(file: "app/Http/Middleware/EnsureUserHasRole.php", ```php
class EnsureUserHasRole
{
    public function handle(Request $request, Closure $next, string $role)
    {
        if ($request->user()?->role !== $role) {
            abort(403, 'Access denied for your role.');
        }

        return $next($request);
    }
}
```)

The third parameter, `$role`, isn't a fixed part of Laravel's
middleware signature; it's a custom parameter supplied when the
middleware is attached to a route, written as `role:admin` on a
route group. This middleware gets registered as an alias in
`bootstrap/app.php` so it can be called by the short name
`role` instead of its full class name.

#listing(file: "routes/web.php", ```php
Route::middleware(['auth', 'role:admin'])->group(function () {
    Route::resource('products', ProductController::class);
    Route::resource('categories', CategoryController::class);
    Route::get('/reports', [ReportController::class, 'index']);
});
```)

Those two middleware run in sequence: `auth` first confirms
the user is logged in at all, then `role:admin` checks the
specific role. A cashier trying to open `/products` passes the
`auth` middleware fine (she really is logged in) but gets
stopped at `role:admin`, receiving a 403 Forbidden response.

== Practice: Restricting Access to Admin Pages <sec:autentikasi-dan-otorisasi-3>

The steps below build the `EnsureUserHasRole` middleware from
scratch, register it, then prove the restriction genuinely works using
two demo accounts with different roles.

+ Create the middleware class skeleton:

  #listing(```bash
  php artisan make:middleware EnsureUserHasRole
    
  ```)
+ Open the newly created file at
      `app/Http/Middleware/EnsureUserHasRole.php`, then
      replace its `handle()` method body with the code already shown
      in the previous section (the `$role` parameter, the
      `$request->user()?->role` check, and
      `abort(403, ...)`).
+ Open `bootstrap/app.php`, register that middleware as
      the `role` alias inside the `->withMiddleware()` call:

  #listing(file: "bootstrap/app.php", ```php
  ->withMiddleware(function (Middleware $middleware) {
      $middleware->alias([
          'role' => \App\Http\Middleware\EnsureUserHasRole::class,
      ]);
  })
    
  ```)

  Without registering this alias, writing `role:admin` on a
      route fails with `Target class [role] does not exist`.
+ Open `routes/web.php`, wrap the product, category, and
      report routes in the `['auth', 'role:admin']` group as
      shown in the previous section's example.
+ Make sure the two demo accounts exist in the seeder. Open
      `database/seeders/DatabaseSeeder.php`, add (if not already
      there):

  #listing(file: "database/seeders/DatabaseSeeder.php", ```php
  User::factory()->create([
      'email' => 'admin@pos.test',
      'role' => 'admin',
  ]);
  User::factory()->create([
      'email' => 'kasir@pos.test',
      'role' => 'kasir',
  ]);
    
  ```)

  then run `php artisan migrate:fresh --seed` so both
      accounts exist in the database.
+ Run `php artisan serve`, log in as
      `admin@pos.test`, open `/products`. #strong[What to
      expect]: the product list page renders normally.
+ Log out, log in as `kasir@pos.test`, open
      `/products` again. #strong[What to expect]: what shows up is
      a 403 error page, not the product list.
+ #strong[If the cashier can still open `/products`],
      check the two most common causes: (a) the `/products` route
      turned out to be registered outside the `role:admin` group
      from step 4; (b) the routes got cached before the middleware was
      added (`php artisan route:cache` was run at some point), so
      Laravel is still using the old route list; run
      `php artisan route:clear` and try again.

#figure(
  table(
    columns: (1.1fr, 0.9fr, 1.6fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Approach], [Setup complexity], [Fits],
    table.hline(stroke: 0.5pt),
    [Custom middleware (Simple POS)], [Low], [Simple roles, 2--3 fixed roles],
    [Laravel Breeze], [Medium], [Ready-made auth plus UI scaffolding],
    [Spatie Permission], [Medium--high], [Granular roles and permissions, many combinations],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Custom middleware vs ready-made authorization packages],
) <tab:rbac-perbandingan>

A custom middleware like `EnsureUserHasRole` is enough for
Simple POS because the number of roles stays small and stable. Once the
need grows into granular per-action permissions, say "branch A's admin
may manage branch A's products only, not branch B's", a package like
Spatie Permission provides a far more flexible role-and-permission
model than a single `role` string column, at the cost of a more
elaborate setup and extra tables.

#warningbox[
A middleware only protects a route it's actually attached to. Adding a
new route inside a `Route::resource()` group that's already
protected by `role:admin` stays safe, but adding a new admin
route #emph[outside] that group, or forgetting to place it in the
right group, leaves that page reachable by anyone logged in at all,
regardless of role. This mistake won't show up in a development
environment if whoever's testing always logs in as admin.
]

#branchref("chapter-07")

== Summary <sec:autentikasi-dan-otorisasi-rangkuman>

- Login and logout in Simple POS use Laravel's built-in
      `Auth::attempt()`, with `session()->regenerate()`
      preventing session fixation, and two demo accounts
      (`admin@pos.test`, `kasir@pos.test`) told apart
      through the `role` column.
- The `EnsureUserHasRole` middleware, registered as the
      `role` alias and attached through `role:admin` on a
      route group, restricts access to the product, category, and report
      pages to admin-role users only, returning 403 for any other role.
- A custom middleware fits simple RBAC with a handful of fixed
      roles like Simple POS; a package like Laravel Breeze fits
      ready-made auth scaffolding better, and Spatie Permission fits
      granular per-action permissions with many role combinations better.

== Exercises

+ Log in as the cashier, try to reach `/reports` directly
      through the URL, and note what response comes back compared to
      logging in as admin.
+ Add a new role, say `manager`, allowed to view
      `/reports` but not manage `/products`. Sketch out how
      the middleware would need to change to support this.
+ Explain in your own words the difference between authentication
      and authorization, using a concrete Simple POS example other than
      the ones already covered in this chapter.
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) what `Auth::attempt()`
      does, (b) why the `auth` and `role:admin`
      middleware need to run in that order, and (c) when Spatie
      Permission makes more sense than a custom middleware. Check your
      answers against this chapter.

#challengebox[
Add a specific error message shown when a cashier tries to reach an
admin page, naming the page that was denied and the role required,
instead of Laravel's generic 403 message.
]

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for authentication, sessions, and middleware.
