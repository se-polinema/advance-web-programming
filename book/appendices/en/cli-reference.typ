#import "/template.typ": *

= Artisan and Composer Command Reference <app:cli>

This appendix summarizes the command-line interface (CLI) commands used most
often throughout the book. All commands are run from the Simple POS project
directory unless noted otherwise.

== Setting Up a Project

#table(
    columns: (1fr, 1.6fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Command]], [#strong[Purpose]],
    table.hline(stroke: 0.5pt),
    [`composer install`], [Install PHP dependencies from `composer.json`],
    [`php artisan key:generate`], [Generate the application's encryption key],
    [`php artisan migrate:fresh --seed`], [Re-run every migration, then seed the database],
    [`php artisan serve`], [Run the local development server],
    [`composer run dev`], [Run the dev server, Vite, queue listener, and log tail together in one terminal],
    table.hline(stroke: 0.8pt),
  )

== Migrations and the Database

#table(
    columns: (1fr, 1.6fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Command]], [#strong[Purpose]],
    table.hline(stroke: 0.5pt),
    [`php artisan make:migration create_products_table`], [Create a new migration file],
    [`php artisan migrate`], [Run migrations that have not yet executed],
    [`php artisan migrate:rollback`], [Roll back the last migration batch],
    [`php artisan db:seed`], [Run seeders without re-running migrations],
    table.hline(stroke: 0.8pt),
  )

== Generating Boilerplate Files

#table(
    columns: (1fr, 1.6fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Command]], [#strong[Purpose]],
    table.hline(stroke: 0.5pt),
    [`php artisan make:model Product -mfs`], [Create a model along with its migration, factory, and seeder],
    [`php artisan make:controller ProductController`], [Create a new controller],
    [`php artisan make:request StoreProductRequest`], [Create a FormRequest class],
    [`php artisan make:middleware EnsureUserHasRole`], [Create a custom middleware],
    table.hline(stroke: 0.8pt),
  )

== Testing and Maintenance

#table(
    columns: (1fr, 1.6fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Command]], [#strong[Purpose]],
    table.hline(stroke: 0.5pt),
    [`php artisan test`], [Run every feature and unit test],
    [`php artisan route:list`], [List every registered route],
    [`php artisan config:cache`], [Cache configuration for production],
    [`php artisan route:cache`], [Cache routes for production],
    table.hline(stroke: 0.8pt),
  )
