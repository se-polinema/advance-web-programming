#import "/template.typ": *

= Optimization, Deployment, and Documentation <ch:optimasi-dan-deployment>

#chapterhero("orange", [Re-profile N+1 queries and indexes with real numbers, prepare Simple POS for deployment, then leave behind technical documentation for the next developer.], [#icon("tachometer-alt")#h(1em)N+1 & index profiling], [#icon("rocket")#h(1em)deployment prep], [#icon("file-alt")#h(1em)technical docs])

A courier moving an office from one building to another has two routes
to pick from: a shortcut already mapped out through the back alleys, or
a roundabout route down the main road, jammed because nobody checked
the alternative in time. An experienced courier doesn't guess; he
already timed both routes with a stopwatch before moving day, and knows
exactly which one is faster for a fully loaded truck. This chapter does
the same thing for Simple POS near the end of its journey: measure,
with real numbers, just how much the eager loading fix (Chapter~5) and
the foreign key index (Chapter~4) genuinely speed the application up,
then prepare that application for its real "moving day", deployment to
a production environment, and leave that route map behind as
documentation for whoever continues the journey.

#strong[What You'll Learn]

+ profile N+1 queries and unindexed queries in Simple POS using `EXPLAIN QUERY PLAN`, then measure the improvement after adding eager loading and indexes;
+ prepare Simple POS for deployment (production environment configuration, migrations, config and route caching);
+ write concise technical documentation explaining Simple POS's architectural decisions for another developer continuing the project.

== Profiling N+1 Queries and Indexes <sec:optimasi-dan-deployment-1>

#istilahpenting[
/ Profiling: Measuring directly, with numbers, which part of an application actually consumes the most time, rather than guessing off intuition.
/ Query Cache: A mechanism for storing an expensive query's result so it doesn't need to run again on an identical following request.
/ Route Cache: A compiled file holding every one of Laravel's route definitions, speeding up matching a URL to a route without reloading all the route files on every request.
/ Config Cache: A compiled file merging every Laravel configuration file into one, avoiding repeated reads of many small files on every request.
]

Chapter~4 and Chapter~5 each showed off one performance bug: the
missing foreign key index on SQLite, and the N+1 problem on the
transaction listing. This time both fixes get measured together, in a
scenario closer to production conditions: rendering the transaction
history page complete with details and products, over a database
already filled by the Chapter~4 seed.

+ First measure the state #emph[without] eager loading:

  #listing(```bash
  php artisan tinker
  >>> DB::enableQueryLog();
  >>> Transaction::latest()->take(15)->get()->each(fn($t) => $t->details);
  >>> count(DB::getQueryLog());
    
  ```)

  `DB::enableQueryLog()` turns on logging for every query
      Eloquent runs during that tinker session. #strong[What to expect]:
      a printed number around 16 (1 query for the transaction list, plus
      15 detail queries, one per transaction, because
      `$t->details` gets accessed lazily inside `each()`).
+ Exit tinker (`exit`), then repeat with
      `with('details.product')` attached at the start of the
      query:

  #listing(```bash
  php artisan tinker
  >>> DB::enableQueryLog();
  >>> Transaction::with('details.product')->latest()->take(15)->get();
  >>> count(DB::getQueryLog());
    
  ```)

  #strong[What to expect]: the printed number drops to 3, matching
      Chapter~5's explanation, not just a theoretical claim.
+ Verify the index with the same command as Chapter~4, run here
      on the Chapter~8 sales report query:

  #listing(```bash
  sqlite3 database/database.sqlite \
    "EXPLAIN QUERY PLAN SELECT * FROM transactions WHERE created_at BETWEEN ? AND ?;"
    
  ```)

  #strong[What to expect]: the result row includes
      `SEARCH ... USING INDEX`, not `SCAN`, proving the
      `transactions.created_at` index added in Chapter~4 is
      genuinely being used, not just present in the schema while never
      touched by the query that actually runs.

== Preparing for Deployment <sec:optimasi-dan-deployment-2>

A local development environment and a production environment have
opposite priorities on one important thing: error information.
Locally, seeing an exception's full detail, including the query
content and the code line that triggered it, speeds up debugging. In
production, that same information, if shown to a regular user, leaks
the application's internal structure (table names, server file paths,
even a fragment of source code) to whoever happens to trigger an error.

#warningbox[
`APP_DEBUG=true` in a production environment is one of the most
common and most dangerous configuration mistakes: the moment even one
request triggers an unhandled exception, Laravel shows the full debug
page to that user, including the contents of other environment
variables that might hold database credentials. A production
`.env` file must use `APP_DEBUG=false` and
`APP_ENV=production`.
]

Once environment configuration is correct, four commands prepare
Simple POS to run faster in production:

+ Build production frontend assets. A production server never runs
      `npm run dev`, the dev server that needs Node kept alive in the
      background; instead, `npm run build` bundles and minifies every
      CSS & JavaScript file once into `public/build/`, and the same
      `@vite` directive from Chapter~3 automatically reads that build
      output instead of a dev server:

  #listing(```bash
  npm ci
  npm run build
    
  ```)

  #strong[What to expect]: output ending in a checkmarked
      `built in N ms` line, alongside a list of the generated
      `public/build/` files. `npm ci` is used instead of
      `npm install` in a production environment because it installs
      exactly the versions locked in `package-lock.json`, with no
      chance of accidentally upgrading a package's version.
+ Run migrations without the interactive confirmation Laravel
      normally prompts for in a production environment (by default
      Laravel refuses to run migrations outright under
      `APP_ENV=production` without this flag, as an extra
      safeguard):

  #listing(```bash
  php artisan migrate --force
    
  ```)
+ Merge every configuration file into one compiled file:

  #listing(```bash
  php artisan config:cache
    
  ```)

  #strong[What to expect]: output reading
      `INFO Configuration cached successfully.`
+ Merge every route definition into one compiled file:

  #listing(```bash
  php artisan route:cache
    
  ```)

  #strong[What to expect]: output reading `INFO Routes cached
      successfully.` Both caches speed up every request since Laravel no
      longer needs to reload dozens of small files each time it runs.
+ #strong[If the application suddenly errors out after
      `config:cache`] (e.g. a `.env` change has no effect, or
      a new route isn't found), that's a sign the old cache is still in
      use. Clear it with `php artisan config:clear` and
      `php artisan route:clear`, make the needed change, then
      run `config:cache`/`route:cache` again.

== Practice: Simple POS Technical Documentation <sec:optimasi-dan-deployment-3>

Code that runs correctly doesn't always explain itself to the next
developer. Good technical documentation doesn't repeat what's already
readable from the code (column names, method names), it answers the
question the code itself can't: why a particular decision got made.

+ Create a `docs/architecture.md` file at the root of the
      Simple POS project (not something that ships by default; this is a
      new documentation file).
+ Fill it in with a `## Architecture Decisions` heading,
      then one subsection per decision made throughout this book, at
      least the two examples below:

  #listing(file: "docs/architecture.md", ```
  ## Architecture Decisions

  ### Why SQLite, not MySQL/PostgreSQL?
  Simple POS uses SQLite for development because it needs no separate
  database server process, a good fit for demos and classroom use. The
  schema stays portable to MySQL/PostgreSQL through Laravel's standard
  migrations, with one caveat: a foreign key index still needs to be
  created explicitly (see Chapter 4), because MySQL creates it
  automatically while SQLite does not.

  ### Why a custom middleware, not Spatie Permission?
  Simple POS only has two fixed roles (admin, cashier), so the custom
  `role:admin` middleware stays simpler and adds no dependency. See
  Chapter 7 for the full comparison.
    
  ```)

  Those two sections above don't just describe what exists
      (descriptive), they explain why that choice got made over other
      reasonable alternatives (justification), something a new developer
      can't infer just from reading the `EnsureUserHasRole` code
      itself.
+ Add a third subsection for one more decision not yet recorded,
      for example why the transaction total gets recomputed server-side
      (Chapter~6) or why CSV import moved to a queue (Chapter~8).
+ #strong[Verify]: ask a colleague (or reread it yourself the
      next day) to answer "why does Simple POS use SQLite" purely from
      reading `docs/architecture.md`, without opening any code at
      all. If the answer is off, or they still have to guess, add the
      missing sentence to that file.

#branchref("chapter-11")

== Summary <sec:optimasi-dan-deployment-rangkuman>

- Re-profiling through `DB::enableQueryLog()` and
      `EXPLAIN QUERY PLAN` proves with real numbers that the eager
      loading fix (Chapter~5) and the foreign key index (Chapter~4) are
      genuinely used in a near-production scenario, not just a
      theoretical claim.
- Deployment preparation includes `APP_DEBUG=false` to
      prevent sensitive information leaks, plus `npm run build` to
      bundle production frontend assets, `migrate --force`,
      `config:cache`, and `route:cache` to run
      migrations and speed up requests in production.
- Useful technical documentation explains why an architectural
      decision was made over other alternatives, rather than just
      re-describing what's already readable directly from the code.

== Exercises

+ Profile one other query in Simple POS not yet checked in this
      chapter (for example, product listing by category), and note
      whether it's already using an existing index.
+ Prepare your own deployment checklist, at least five items,
      covering environment configuration and cache commands.
+ Write one page of architecture documentation for a part of
      Simple POS not yet covered in this chapter (for example, the CSV
      import flow from Chapter~8).
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) why `APP_DEBUG=true` is
      dangerous in production, (b) what `route:cache` does, and
      (c) the difference between descriptive documentation and
      documentation that explains the justification for a decision.
      Check your answers against this chapter.

#challengebox[
Measure the performance improvement on the Chapter~8 sales report
endpoint before and after the `transactions.created_at` index
gets added, through `EXPLAIN QUERY PLAN`, and write up the result
as one comparison table.
]

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for deployment configuration and caching commands.
