#import "/template.typ": *

= Interfaces with Blade, Tailwind, and Alpine <ch:blade-dan-tailwind>

#chapterhero("blue", [Build Simple POS's cashier interface with Blade and Tailwind, then bring its shopping cart to life with Alpine.js, no page reloads required.], [#icon("layer-group")#h(1em)MPA vs SPA], [#icon("palette")#h(1em)Blade & Tailwind], [#icon("bolt")#h(1em)Alpine.js])

A corner shop's display window, goods sitting behind glass, never changes
until the owner walks over and rearranges it. A customer who wants to know
how much stock is left, or wants to put back an item they'd already picked
up, has to call over a clerk and wait for an answer. An attentive clerk
works differently: the moment a customer lifts an item and drops it in
their basket, the clerk already knows, recalculates the running total on
the spot, and can undo that pick without the customer repeating themselves
from scratch. A cashier page built purely with Blade, with no JavaScript
touching it at all, behaves exactly like that glass display: every time a
cashier adds one product to the cart, the entire page has to reload from
the server. A shop with a high transaction volume doesn't have time for
dozens of reloads in a single shift; a cashier waiting on every click to
finish reloading serves customers more slowly, and the line at the counter
feels it too.

#strong[What You'll Learn]

+ compare the multi-page application (MPA) and single-page application (SPA) patterns, and explain where Blade and Alpine.js sit as a hybrid approach;
+ build a Blade layout and Simple POS's cashier page (`/pos`) with Tailwind CSS via Vite, using `npm run dev` for hot reload during development;
+ implement a dynamic shopping cart on the cashier page using Alpine.js, installed through npm and bundled with the rest of the assets by Vite, for client-side interactivity with no page reload.

== MPA vs SPA and Blade's Role <sec:blade-dan-tailwind-1>

#istilahpenting[
/ Blade: Laravel's built-in templating engine, rendering HTML on the server using directive syntax like `@if` and `@foreach` directly inside `.blade.php` files.
/ Directive: A Blade instruction starting with `@`, such as `@extends`, `@section`, and `@yield`, compiled by Laravel into plain PHP before it ever runs.
/ Component: A reusable piece of Blade shared across pages, such as a product card or a button, registered as its own file and invoked through an `<x-component-name>` tag.
/ Alpine.js: A lightweight JavaScript library adding state and interactivity directly through HTML attributes (`x-data`, `x-model`, `@click`), installed through npm like any other JavaScript dependency.
/ Vite: The frontend build tool Laravel ships with by default: runs a dev server with hot reload through `npm run dev` during development, and bundles/minifies every CSS & JavaScript file into production assets through `npm run build`.
]

A #term[multi-page application] (MPA) reloads the entire page from the
server every time a user follows a link or submits a form: the browser
discards the old HTML, requests a new one, and renders it from scratch.
That approach is simple to reason about and easy to debug, since every
request gets back a complete HTML answer, but it feels sluggish for small,
frequently repeated interactions, like adding one product to a shopping
cart. A #term[single-page application] (SPA) takes the opposite route: one
HTML page loads once at the start, and every change after that is handled
by JavaScript running in the browser, which fetches data through hidden
requests and updates only part of the DOM with no reload. React, Vue, and
Angular are libraries built specifically around the SPA pattern.

#figure(
  table(
    columns: (0.7fr, 1.3fr, 1.3fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [Pattern], [Render source], [Fits],
    table.hline(stroke: 0.5pt),
    [Pure MPA], [Server, full HTML per navigation], [Pages with infrequent interaction, where SEO matters],
    [Pure SPA], [Client, JavaScript renders the DOM], [Applications with very frequent interaction, complex state],
    [Blade + Alpine.js], [Server for structure, client for local interaction], [Apps like Simple POS: mostly static pages, a small part needing reactivity],
    table.hline(stroke: 0.8pt),
  ),
  caption: [MPA, SPA, and the Blade + Alpine.js hybrid approach],
) <tab:mpa-spa>

Simple POS doesn't need a full SPA. The category page, the transaction
list, and the sales report rarely change within a single work session, so
plain server rendering through Blade is already fast enough and far
simpler to maintain. The one piece that genuinely needs interactivity
without a reload is the shopping cart on the cashier page: a cashier adds
and removes items repeatedly within one transaction, and waiting on a
reload for every click would get in the way. Alpine.js fills exactly that
gap without forcing the whole application into an SPA architecture; it
only adds state and reactivity to the HTML elements that actually need it,
while the rest of the page keeps rendering through Blade as usual.

#notebox[
This approach is sometimes called hybrid or, within the Laravel ecosystem,
close to the pattern popularized by Livewire and Hotwire: the server stays
the source of truth, and JavaScript's only job is speeding up the one part
that would otherwise feel slow if it had to reload in full.
]

== A Layout and Cashier Page with Tailwind <sec:blade-dan-tailwind-2>

Nearly every Simple POS page shares the same skeleton: a browser tab
title, a navigation menu on the left, and a content area that changes
depending on which page is open. Blade avoids repeating that skeleton in
every file through the `@extends`, `@section`, and `@yield`
directives: one layout file defines the full skeleton with a named hole
where each page's content gets inserted, and every individual page just
fills that hole instead of rewriting `<html>`, `<head>`, or
the navigation menu from scratch.

#listing(file: "resources/views/layouts/app.blade.php", ```php
<!DOCTYPE html>
<html lang="en">
<head>
    <title>@yield('title', 'Simple POS')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <x-nav />
    <main>@yield('content')</main>
</body>
</html>
```)

The `@vite([...])` directive replaces manual `<script>`\/
`<link>` tags: it injects the right CSS and JavaScript tags
automatically, differently depending on the mode. Three files work
together behind it, and all three are already in place after `npm
install` back in Chapter~1:

+ `resources/css/app.css` loads Tailwind through one line,
      `@import 'tailwindcss';`, at the very top, rather than a
      separate `tailwind.config.js` file the way older Tailwind
      versions required.
+ `vite.config.js` registers two plugins: `laravel()`
      (wiring Vite to the `@vite` directive and detecting changed
      files) and `tailwindcss()` (turning utility classes into real
      CSS).
+ `package.json` lists both packages as
      `devDependencies`, already downloaded into
      `node_modules/` since `npm install` ran.

During development, Vite runs as a dev server separate from `php
artisan serve`, started in a second terminal:

#listing(```bash
npm run dev
```)

#strong[What to expect]: a line reading `VITE vX.X.X ready in N ms`
followed by a local address like `Local: http://localhost:5173/`.
While that command keeps running, the `@vite` directive on a page
opened through `php artisan serve` automatically loads assets from
that dev server, and editing `app.css` or a Blade file shows up
straight in the browser with no manual refresh (#emph[hot reload]),
something a CDN never offered. Tailwind itself still works through
utility classes attached directly to HTML elements, for instance
`class="bg-slate-900 text-white rounded-md px-4 py-2"` for a dark
button with rounded corners and padding, instead of writing separate CSS
rules in another file; only where Tailwind comes from changed, from a CDN
to Vite.

#warningbox[
`npm run dev` needs to keep running in its own terminal throughout
development. If it stops, the `@vite` directive on a page that
reloads will fail to find the dev server and throw a
`ViteManifestNotFoundException`, unless a production build
(`npm run build`, covered in full in Chapter~11) has already run at
some point before.
]

#tipbox[
Running and remembering two separate terminals gets old once the routine
is familiar. The `composer run dev` script, already defined in the
`scripts` section of the default Laravel project's
`composer.json`, starts `php artisan serve`, `npm run
dev`, the queue listener, and the application's log tail all at once in
a single terminal through one `php artisan dev` command under
the hood; a single `Ctrl+C` stops all of them together. This book
deliberately starts with two separate terminals so it stays clear which
process handles what, especially when one of them fails (say Vite throws
an error, and a dedicated terminal makes the source obvious right away);
once that pattern feels familiar, `composer run dev` becomes the more
convenient choice for everyday use.
]

#listing(file: "resources/views/pos/create.blade.php", ```php
@extends('layouts.app')

@section('title', 'Cashier')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Cashier Transaction</h1>
    <div class="grid grid-cols-3 gap-4">
        @foreach ($products as $product)
            <div class="border rounded-md p-3">
                <p class="font-medium">{{ $product->name }}</p>
                <p class="text-sm text-slate-500">Rp {{ number_format($product->price) }}</p>
            </div>
        @endforeach
    </div>
@endsection
```)

The `/pos` page calls `@extends('layouts.app')` to inherit the
layout skeleton, then fills the `@section('content')` hole with a
product grid. Notice `{{ $product->name }}`: that double-curly
syntax is Blade's output syntax, automatically escaping HTML so a product
name containing a character like `<` can't be abused to inject
foreign markup into the page.

#warningbox[
Data coming from user input, including a product name an admin typed into
a form, must always be printed through `{{ }}`, never
`{!! !!}`. The second syntax skips escaping entirely and opens a
#emph[cross-site scripting] hole the moment its content ever came from
untrusted input.
]

== Hands-On: A Dynamic Shopping Cart with Alpine.js <sec:blade-dan-tailwind-3>

Wiring Alpine.js onto an element starts with the `x-data` attribute,
which declares local state as a plain JavaScript object right inside the
HTML markup. Any element inside that `x-data`, including its children,
can read and change that state through other Alpine attributes, such as
`@click` for events and `x-text` to display a reactive value.

#listing(```html
<div x-data="{ cart: [] }">
  <button @click="cart.push({ id: 1, price: 15000 })">
    Add
  </button>
  <span x-text="cart.length"></span> items in cart
</div>
```)

That snippet is enough to show the mechanism at work: `cart` starts as
an empty array, the #emph[Add] button pushes one new object into it on
every click, and `x-text="cart.length"` updates the displayed number
automatically, with not one line of code explicitly telling the DOM to
refresh. Alpine watches `cart` for changes and keeps the display in
sync on its own. The steps below wire up the same pattern, at real
scale, onto the `/pos` product grid already built in the previous
section.

+ Install Alpine.js as an npm dependency, not through a CDN:

  #listing(```bash
  npm install alpinejs
    
  ```)

  Open `resources/js/app.js`, then import and start Alpine
      there:

  #listing(file: "resources/js/app.js", ```
  import Alpine from 'alpinejs';

  window.Alpine = Alpine;
  Alpine.start();
  ```)

  Since `app.js` is already loaded through the `@vite`
      directive in `layouts/app.blade.php` (previous section), no
      new `<script>` tag is needed; Vite bundles Alpine together
      with the rest of the application code. This bundler-driven load
      order automatically sidesteps the problem the `defer`
      attribute used to solve on a CDN tag: `Alpine.start()` only
      gets called once every module has finished loading.
+ Open `resources/views/pos/create.blade.php` (the file
      already built in the previous section). Wrap the whole product grid
      in one `x-data` defining `cart` as an empty array plus two
      methods, `addToCart` and `subtotal`:

  #listing(file: "resources/views/pos/create.blade.php", ```html
  <div x-data="{
      cart: [],
      addToCart(id, name, price) {
          this.cart.push({ id, name, price });
      },
      subtotal() {
          return this.cart.reduce((sum, item) => sum + item.price, 0);
      }
  }">
    
  ```)
+ On each product card inside the `@foreach`, add an
      `@click` that calls `addToCart` with that row's product
      data:

  #listing(file: "resources/views/pos/create.blade.php", ```html
  <div class="border rounded-md p-3 cursor-pointer"
       @click="addToCart({{ $product->id }}, '{{ $product->name }}', {{ $product->price }})">
      <p class="font-medium">{{ $product->name }}</p>
      <p class="text-sm text-slate-500">Rp {{ number_format($product->price) }}</p>
  </div>
    
  ```)
+ Add a cart summary area below the grid, using `x-for` to
      list each item and `x-text` for the running subtotal:

  #listing(file: "resources/views/pos/create.blade.php", ```html
  <div class="mt-4 border-t pt-3">
      <template x-for="item in cart" :key="item.id">
          <p x-text="item.name + ' - Rp ' + item.price"></p>
      </template>
      <p class="font-semibold mt-2">Subtotal: Rp <span x-text="subtotal()"></span></p>
  </div>
    
  ```)
+ Make sure both servers are running side by side, in two separate
      terminals: `php artisan serve` and `npm run dev`. Then
      open `http://127.0.0.1:8000/pos` in a browser.
+ Click one of the product cards. #strong[What to expect]: that
      product's name and price show up immediately in the summary area
      below the grid, and the subtotal figure grows, with the page never
      reloading (watch the address bar and tab favicon; neither flickers
      the way they would on a reload).
+ #strong[If clicking does nothing at all], check the three most
      common causes: (a) open the browser console (F12); an
      `Alpine is not defined` error means `npm run dev` isn't
      running, or step 1's change to `app.js` was never saved;
      (b) a `ViteManifestNotFoundException` on the page itself means
      `npm run dev` was never started at all; (c) make sure the entire
      product grid, including the summary area from step 4, genuinely sits
      #emph[inside] the element carrying `x-data` from step 2, rather
      than as a sibling element outside it.

The inline `x-data` object above is enough to understand the
mechanism, but Simple POS's real cart registers itself as one named
Alpine component through `Alpine.data('posCart', ...)` inside
`app.js`, complete with SKU scanning, discounts, and a
`sessionStorage` backup so the cart survives page navigation.
That's the grown-up version of the `x-data` object just built here,
not a different concept; the repository link at the end of this chapter
shows the full code.

The subtotal Alpine computes client-side exists purely for display; a
cashier needs to see a running number before the transaction gets saved.
That number is not a source of truth. Every time the cashier form actually
gets submitted, Simple POS recalculates the total from the product data
and quantities stored in the database, not from whatever number Alpine
happened to display in the browser. Chapter~6 explains why in more detail:
anything originating in the browser, including a JavaScript calculation
that looks perfectly correct, can still be tampered with before it reaches
the server, and must never be trusted outright for a figure involving
money.

#tipbox[
A useful rule of thumb: logic that's purely cosmetic, like showing a
running subtotal or highlighting a just-added item, is safe to keep in
Alpine.js. Logic that decides a business outcome, like the final figure
saved as a transaction's total or whether stock is sufficient to fulfill
an order, must be recalculated on the server, no matter how convincing the
client-side number already looks.
]

#challengebox[
Add a #emph[Remove] button to each cart row, calling a new Alpine method
that removes that item from the `cart` array by its `id`. Once the
button works, explain in your own words: why is removing an item through
Alpine alone, without sending anything to the server, already safe enough
at this point, given the numbers will still get recalculated when the form
is submitted?
]

#branchref("chapter-03")

== Summary <sec:blade-dan-tailwind-rangkuman>

- An MPA reloads the whole page from the server on every navigation,
      an SPA renders everything client-side through JavaScript, and Blade
      paired with Alpine.js takes a middle path: the server still renders
      the page's structure, and Alpine only adds reactivity to the part that
      actually needs it, such as the cashier's shopping cart.
- A Blade layout through `@extends`/`@section`/`@yield`
      avoids repeating HTML skeleton code, and the `@vite` directive
      loads Tailwind CSS and JavaScript through Vite, with `npm run dev`
      giving hot reload during development.
- Alpine.js is installed through `npm install alpinejs` and
      bundled by Vite together with the rest of the application code; the
      `x-data` attribute declares Alpine state right in the markup,
      `@click` and `x-text` read and change it reactively, and a
      subtotal computed client-side must still be re-verified on the server
      before it can be trusted as a final figure.

== Exercises

+ Create a new Blade layout file with `@extends` and
      `@yield('content')`, then prove a page can inherit it without
      rewriting the `<html>` or `<head>` tags.
+ On the `/pos` product grid, add a small badge showing the
      text "Low Stock" using the Tailwind classes `bg-amber-100
      text-amber-700`, appearing only when a product's stock drops below 10.
+ Explain in your own words: why is `{{ }}` safer for
      displaying a product name than `{!! !!}`.
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) the difference between MPA and SPA,
      (b) why Simple POS chose Blade + Alpine.js over a full SPA, and (c)
      why a cart subtotal computed by Alpine.js can't be trusted outright on
      the server. Check your answers against this chapter.

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for Blade conventions, and the Tailwind CSS
documentation #cite(<tailwinddocs>) for the utility-class system used
throughout Simple POS.
