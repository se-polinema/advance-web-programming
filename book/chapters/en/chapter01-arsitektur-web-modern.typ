#import "/template.typ": *
#import "/diagrams.typ": *

= Modern Web Architecture and the Laravel Ecosystem <ch:arsitektur-web-modern>

#chapterhero("blue", [Compare monolith, microservices, and serverless architectures, then set up a Laravel 13 project with SQLite as the foundation for Simple POS.], [#icon("server")#h(1em)monolith vs microservices], [#icon("code-branch")#h(1em)the Laravel ecosystem], [#icon("database")#h(1em)Simple POS])

A newly opened family restaurant usually handles everything itself: the
owner cooks, a son takes orders, a daughter counts cash at the same counter
the customers eat next to. Everybody knows everything, and when the kitchen
gets swamped on a Saturday night, the fix is adding another stove, not
opening a branch across town. Compare that to a food court in a mall, where
every stall runs its own kitchen, its own register, even its own secret
recipe, and the mall operator only provides shared tables and a power line.
If the noodle stall is packed while the ice cream stall sits empty, both
keep running as separate units, neither waiting on the other.

Those two models map exactly onto software architecture: a monolith is the
family restaurant (one codebase, one process, one team running everything),
and microservices is the food court (many independent services talking
over a network). Simple POS, the point-of-sale application built chapter by
chapter throughout this book, is deliberately a monolith, not out of
limitation but because the scale fits: a small shop with one or two
cashiers does not need ten separate services just to record the sale of a
cup of coffee. Picking the wrong architecture here, building a food court
for a business that one kitchen can serve just fine, means spending
development time wiring up inter-service networking nobody needs, instead
of shipping the feature a cashier actually uses every day.

#strong[What You'll Learn]

+ compare monolith, microservices, and serverless architectures to explain why Laravel was chosen as the monolithic framework for Simple POS;
+ set up a new Laravel 13 project with SQLite as a zero-setup database, including `migrate:fresh --seed` and `serve`;
+ get to know Laravel's project folder structure (`routes/`, `app/Http/Controllers/`, `database/migrations/`) as an embodiment of the MVC pattern, then initialize a Git repository with the first `increment 1` commit.

== Monolith, Microservices, and Why Laravel <sec:arsitektur-web-modern-1>

#istilahpenting[
/ Monolith: An application whose layers, interface, business logic, and data access, all run in a single codebase deployed as a single unit. Often mistaken for "messy code"; a well-structured monolith (e.g. following MVC) stays clean, its real opposite isn't "modular", it's "distributed".
/ Microservices: An architecture that splits an application into independent services, each deployed on its own, communicating over a network. Rule of thumb: only worth it once an organization has enough teams that each can own and operate its own service; a small team splitting its application just adds operational overhead.
]

A #term[monolith] keeps its entire codebase, from the interface a user sees
down to the query that touches the database, inside one project deployed as
one unit. Adding a feature means adding code to that same project;
deploying an update means swapping that one unit for a new version. A
#term[microservices] architecture splits those responsibilities into
separate services instead, say one service dedicated to a product catalog,
another dedicated to payments, talking to each other over network calls
(usually HTTP or a message queue). That split buys freedom: each service
can be written in a different language, deployed on a different schedule,
and scaled independently when its own traffic spikes.

That freedom has a price. A team that splits its application into eight
separate services now has to run eight deployment processes, manage eight
points of failure, and handle network communication between services that
used to be a plain function call inside the same process. For a large team
operating a system serving millions of users, that price is worth the
freedom it buys. For an application like Simple POS, serving one shop with
a daily transaction volume you could tally by hand, that price far
outweighs the benefit.

#figure(
  table(
    columns: (1fr, 1.2fr, 1fr, 1.4fr),
    align: (left, left, left, left),
    table.hline(stroke: 0.8pt),
    [Architecture], [Deployment], [Initial Complexity], [Best For],
    table.hline(stroke: 0.5pt),
    [Monolith], [Single unit], [Low], [Simple POS, MVPs, small teams],
    [Microservices], [Many independent units], [High], [Large-scale systems, large teams],
    [Serverless], [Function per event], [Medium], [Sporadic workloads],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Comparing monolith, microservices, and serverless architectures],
) <tab:arsitektur-perbandingan>

#figure(
  diagram-monolith(),
  caption: [Monolith structure (one codebase, three layers fused together) vs
microservices (independent services calling each other over the network)],
) <fig:monolith-microservices>

#istilahpenting[
/ Serverless: A model of code execution as small functions that only run when triggered by an event, with no server process staying up continuously; a cloud provider manages the infrastructure. The name is misleading: the server still exists, it just isn't your responsibility. Because the process doesn't stay alive continuously, there's a #emph[cold start] delay when a function hasn't been called recently, and billing is per execution, not per hour a server stays on.
]

#term[Serverless] takes a third path: code is written as small functions
that only run when triggered by an event (an HTTP request, a cron
schedule, a new message on a queue), and a cloud provider manages the
servers behind the scenes. It suits workloads that spike sharply, such as
image processing triggered only when a user uploads a photo, but it fits
poorly for an application like Simple POS that needs a steady database
connection throughout a shop's business hours.

#istilahpenting[
/ MVC: The #emph[Model-View-Controller] pattern: the Model owns data, the View owns presentation, and the Controller owns the request flow between them. Practical rule for where code goes: touches data, goes in the Model; handles request flow, goes in the Controller; renders output, goes in the View. The framework doesn't enforce this (a query inside a view still runs), it's a discipline the code's author has to maintain.
]

Laravel was chosen as this book's framework because it maps directly onto
what a monolith needs: a single PHP project that already ships routing,
authentication, an ORM, and a templating system, with no need to assemble
pieces from separate libraries. Compared to writing plain PHP from scratch,
Laravel gives a consistent #term[MVC] structure from the first line of code;
compared to a more elaborate microservices-first framework, Laravel stays
productive for a team of one or two people racing a deadline.

#figure(
  diagram-lifecycle(),
  caption: [One Laravel request's flow: an incoming HTTP request passes
through the router, gets handled by a controller, reads/writes data
through a model, until a response comes back through a view],
) <fig:laravel-lifecycle>

The flow in #xref(<fig:laravel-lifecycle>) is a pattern that repeats in
nearly every chapter of this book: `/pos` in Chapter~3 follows this
exact flow, and so does every API endpoint in Chapter~9.

#notebox[
Laravel is not the only PHP framework, and PHP is not the only language for
building monolithic web applications. Django (Python) and Ruby on Rails
share a similar "convention over configuration" philosophy with Laravel.
Laravel's standout strength is its package ecosystem
(Sanctum for APIs, Excel for import/export, Cashier for payments), which
plugs in with minimal configuration, something felt directly starting in
Chapter~9.
]

== Setting Up a Laravel Project with SQLite <sec:arsitektur-web-modern-2>

Every Laravel project needs a database to run, and this book picks SQLite
over MySQL or PostgreSQL for one practical reason: SQLite stores an entire
database as a single ordinary file, with no separate server process to
start, configure, and grant credentials to before the first line of code
runs. A reader who just installed PHP can run migrations within the first
minute, instead of spending half an hour setting up a MySQL account. Simple
POS itself runs on SQLite even for in-class demonstrations, not just for
this book's exercises.

#tipbox[
Before continuing, confirm the following four tools are installed by
running each command in a terminal: `php -v` (version 8.2 or
higher), `composer -V`, `node -v`, and `git --version`. If
any is missing or too old, install it first before moving to the next
step; Appendix~E walks through installing all four per operating system
(Windows, macOS, Linux).
]

#istilahpenting[
/ Artisan: Laravel's built-in command-line interface for everyday development tasks: migrations, seeding, and boilerplate file generation. The full command list can be viewed anytime by running `php artisan list`; Artisan is strictly a development tool, it never runs while the application serves real users.
/ Migration: A PHP file that defines a database schema change in code, so the schema can be rebuilt consistently on any machine. Treat it like version control for the schema: a new change means a new migration file, never editing an old migration that has already run on another machine.
]

#listing(```bash
composer create-project laravel/laravel simple-pos
cd simple-pos
cp .env.example .env
php artisan key:generate
```)

#strong[What to expect]: `composer create-project` prints a list of
packages being downloaded one by one, ending with a line like
`Application ready in simple-pos. You can now start using
Composer!`; `key:generate` prints
`INFO Application key set successfully.` Those last three commands
prepare the `.env` configuration file
(where credentials and environment settings live, kept separate from
source code so they never get committed to Git) and generate the
application's encryption key, which Laravel uses to secure sessions and
cookies.

#tipbox[
#strong[If `composer create-project` fails] with a message
mentioning the PHP version (e.g. `requires php ^8.2`),
run
`php -v` to confirm the installed PHP version is 8.2 or higher;
Laravel 13 cannot be installed on an older PHP version.
]

Alongside the PHP dependencies `composer` just installed, a fresh
Laravel project also ships with `package.json`: a list of JavaScript
dependencies for the frontend toolchain (Vite and Tailwind CSS) that
Chapter~3 starts using. `npm install` is the JavaScript-world
equivalent of `composer install`, reading `package.json` and
downloading every listed package into a `node_modules/` folder:

#listing(```bash
npm install
```)

#strong[What to expect]: `npm install` prints the number of packages
installed, ending with a line like `added N packages in Ns`, with
no `npm error` lines in between. This step isn't required to run Simple POS today; Laravel's default
welcome page still renders with a fallback style even without
`node_modules/`. Running it now avoids a sudden install pause once
Chapter~3 starts using Tailwind and Alpine.js through Vite. The next step
points the database connection at a SQLite file:

#listing(```bash
touch database/database.sqlite
php artisan migrate:fresh --seed
```)

#strong[What to expect]: the list of migrations prints one by one, each
ending with `DONE`, with no error lines in between, followed by a
message that the seeder finished running. `migrate:fresh` runs every migration file from scratch (dropping
any existing tables first, then rebuilding them from the latest schema
definitions), while the `--seed` flag immediately populates the newly
created tables with sample data through a seeder file. For Simple POS, that
seeder fills in hundreds of products and thousands of transactions at once,
a choice examined more closely in Chapter~4, once the payoff of seeding at
realistic scale, not just a handful of rows, becomes visible.

#warningbox[
The `.env` file holds sensitive information (the application key,
production database credentials if any exist) and must never be committed
to Git. A project created with `composer create-project` already ships
a `.gitignore` that excludes `.env` by default; never remove that
line.
]

Once migrations finish, Laravel's built-in development server runs
immediately, no separate web server like Apache or Nginx required:

#listing(```bash
php artisan serve
```)

#strong[What to expect]: a line reading `INFO Server running on
[http://127.0.0.1:8000]`, then the terminal stays open waiting for
requests (press `Ctrl+C` to stop it). Open that address in a
browser; Laravel's welcome page, not an error message, is the sign every
step in this section succeeded. That command serves the application at `http://127.0.0.1:8000` using
PHP's built-in server, plenty for every local development session in this
book. A real production server (covered in Chapter~11) uses a different
setup, but the application structure learned here stays exactly the same.

== Hands-On: Initializing Simple POS and the Git Workflow <sec:arsitektur-web-modern-3>

#heading(level: 3, numbering: none, outlined: false)[Exercise 1.1: Getting to Know the Project Structure]

Before writing the first line of feature code, it's worth knowing which
parts of Laravel's folder structure will get touched constantly throughout
this book, and which ones can be safely ignored for now.

+ Open the `routes/` folder, specifically `routes/web.php`:
      every URL a user can reach in the application gets registered here.
+ Open `app/Http/Controllers/`: the folder where classes that
      process each request (accepting input, calling a model, choosing a
      view) grow one by one starting in Chapter~2.
+ Open `database/migrations/`: where database schema changes get
      defined as code, instead of clicked together in a separate database
      tool.
+ Compare that to the `vendor/` folder: holds every third-party
      Composer package, never edited by hand, and never committed to Git.

This structure is no accident. It embodies the MVC pattern flagged in the
key-terms box earlier: `routes/` and `app/Http/Controllers/`
handle the Controller side, the Eloquent models introduced in Chapter~5
handle the Model side, and the Blade files in `resources/views/`
(covered starting Chapter~3) handle the View side.

#heading(level: 3, numbering: none, outlined: false)[Exercise 1.2: The Increment Commit Convention on Simple POS]

The Simple POS repository this book draws on was not built as one single
project all at once; it grew commit by commit, each one labeled
`increment N`. Increment 1 holds nothing but an empty project skeleton
from `composer create-project`, exactly like the result of Exercise
1.1; each following increment adds one concrete capability, product routing
and controllers, then Blade views, then the database schema, following the
same order as this book's chapters. Reading through Simple POS's commit
history in order is the same experience as reading this book chapter by
chapter, just in the form of real running code instead of prose. The
following steps create your own `increment 1` commit, so this
convention feels real, not just something you read about.

+ `composer create-project` doesn't automatically set up a Git
      repository (unlike the `laravel new` installer, which does this
      automatically), so this step is done manually on purpose from inside
      the `simple-pos/` folder:

  #listing(```bash
  git init
    
  ```)

  #strong[What to expect]: a message reading `Initialized empty
      Git repository in .../simple-pos/.git/`.
+ Add every project file to the staging area, then make the first
      commit with a message following the `increment N` convention:

  #listing(```bash
  git add .
  git commit -m "increment 1: empty Laravel project"
    
  ```)

  #strong[What to expect]: a summary of how many files were committed,
      ending with a line like `N files changed, M insertions(+)`.
      Notice that `vendor/`, `node_modules/`, and `.env`
      aren't mentioned at all; Laravel's default `.gitignore` already
      excludes all three, exactly as the warning in the previous section
      said.
+ Verify the commit actually got saved:

  #listing(```bash
  git log --oneline
    
  ```)

  #strong[What to expect]: one line with a short hash followed by the
      message `increment 1: empty Laravel project`, exactly as just
      written.
+ #strong[If `git commit` fails] with a message asking for
      `user.name`/`user.email`, this is a machine that has
      never used Git before; set it once with
      `git config --global user.name "Your Name"` and
      `git config --global user.email "email@you.com"`, then repeat
      step 2.

#tipbox[
Full code for every chapter comes in two forms. The
`\repobase` repository holds the whole history in one place, with
one branch per chapter (`chapter-01` through `chapter-12`),
each branch building on the previous chapter's; good for reading straight
through like a real commit history. The end of every Exercise section in
this book, like the box below, instead points to a standalone template
repository for that one chapter (e.g. `\repoowner/simple-pos-ch04`
for Chapter~4): click GitHub's #strong[Use this template] button to start
directly from that chapter's state, no need to know how to
`git checkout` a specific branch. This book shows the code snippets
most essential to understand; the full runnable code always lives in
both repositories.
]

#branchref("chapter-01")

== Summary <sec:arsitektur-web-modern-rangkuman>

- A monolith keeps every application layer in one codebase and one
      deployment process, fitting Simple POS's scale; microservices split
      that into independent services whose operational cost only pays off at
      large scale; serverless suits sporadic workloads, not an application
      that needs a steady database connection.
- A Laravel 13 project is set up with `composer create-project`,
      wired to SQLite as a zero-setup database, then started with
      `migrate:fresh --seed` and `serve`.
- Laravel's folder structure (`routes/`, `app/Http/Controllers/`,
      `database/migrations/`) embodies the MVC pattern; the first
      `increment N` commit marks the Git repository as initialized,
      with the same convention mapping the application's growth chapter by
      chapter and the full code for each chapter available as its own
      GitHub branch.

== Exercises

+ Run every setup command from Section 2 (`composer
      create-project` through `serve`) on your own machine, then
      confirm `php artisan serve` shows Laravel's welcome page at
      `http://127.0.0.1:8000`; follow up with the three Git commands
      from Exercise 1.2 and confirm `git log --oneline` shows your own
      `increment 1` commit.
+ Open `database/migrations/` in the freshly created project,
      then identify how many migration files already exist out of the box
      (without writing any code) and which tables they create.
+ Explain in your own words: why does a shop with a single cashier
      fit a monolithic architecture better than microservices, while a
      national e-commerce platform with millions of users often reaches for
      microservices instead.
+ #strong[Self-check:] without reopening this chapter, try explaining
      in your own words: (a) the difference between a monolith and
      microservices, (b) why this book picks SQLite, and (c) what the
      `--seed` flag does on `migrate:fresh`. Check your answers
      against this chapter, and note anything you'd need to revisit.

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for project structure and Artisan commands, and the PHP
Manual #cite(<phpmanual>) as a reference for the language underlying the
Laravel framework.
