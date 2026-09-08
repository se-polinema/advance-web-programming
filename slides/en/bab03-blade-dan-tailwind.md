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

Meeting 3: **Frontend & Templating (Blade, Tailwind, Alpine)**

The Frontend Landscape, Server-Side Templating, and Light Interactivity

---

## What You'll Learn

1. Compare the **MPA** and **SPA** patterns, and explain where Blade and Alpine.js sit as a hybrid approach

2. Understand the **template engine** concept and the **utility-first CSS** approach, and how the two work together to build a page's layout

3. Explain how **Alpine.js** adds client-side interactivity with no page reload, while the server stays the source of truth

<div class="tip-box">
This slide deck covers concepts. Building the layout, the cashier page, and the cart happens in the practicum jobsheet, this time as a group.
</div>

---

<!-- _class: divider -->

# Part 1
## The Frontend Landscape: MPA vs SPA

---

## A Glass Display Case vs. an Attentive Clerk

<div class="cols">
<div>

**Glass display case**
- Never changes until the owner walks over and rearranges it
- A customer who wants to know how much stock is left has to call over a clerk and wait

</div>
<div>

**Attentive clerk**
- The moment a customer lifts an item, the clerk already knows
- Recalculates the running total on the spot, ready to undo that pick without the customer starting over

</div>
</div>

<div class="warn-box">
A page built purely with Blade, with no JavaScript touching it, behaves like the glass display case: every time a user adds one item to a cart, the entire page reloads. An application with high interaction volume doesn't have time for dozens of reloads in a single session.
</div>

---

## MPA: Reload the Whole Page

<div class="term-box">
<b>Multi-page application (MPA):</b> every time a user follows a link or submits a form, the browser discards the old HTML, requests a new one, and renders it from scratch.
</div>

<div class="flow">
  <div class="box">Click</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Full HTML</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Re-render</div>
</div>

- Simple to reason about and easy to debug: every request gets back a complete HTML answer
- Feels sluggish for small, frequently repeated interactions, e.g. adding one product to a cart

---

## SPA: JavaScript Takes Over

<div class="term-box">
<b>Single-page application (SPA):</b> one HTML page loads once at the start, and every change after that is handled by JavaScript in the browser through hidden requests, updating only part of the DOM with no reload.
</div>

- React, Vue, and Angular are libraries built specifically around this pattern
- Fits very frequent interaction and complex state
- The cost: build complexity and state split across two places (client and server)

---

## A Spectrum, Not Two Poles

<div class="flow">
  <div class="box">Pure MPA</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Server-rendered + a little JavaScript</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Pure SPA</div>
</div>

- Most real applications sit in the middle, not at either end
- The ecosystem has names for this middle ground: **Livewire** (Laravel), **Hotwire** (Rails), **htmx**

<div class="tip-box">
In this approach, the server stays the source of truth; JavaScript's only job is speeding up the one part that would otherwise feel slow if it had to reload in full.
</div>

---

## Comparing Three Patterns

| Pattern | Render Source | Fits |
|---|---|---|
| Pure MPA | Server, full HTML per navigation | Pages with infrequent interaction, where SEO matters |
| Pure SPA | Client, JavaScript renders the DOM | Applications with very frequent interaction, complex state |
| Blade + Alpine.js | Server for structure, client for local interaction | Apps with mostly static pages, a small part needing reactivity |

---

## When Blade + Alpine.js Is Enough

- Pages that rarely change within a single work session (e.g. lists, reports): plain server rendering through Blade is already fast enough
- The part that needs repeated interactivity without a reload (e.g. a shopping cart): Alpine.js fills that gap
- No need to force the whole application into a different architecture just for this one small part

<div class="warn-box">
Moving the entire application to a full SPA just for one small component is an architectural cost that doesn't pay off.
</div>

---

<!-- _class: divider -->

# Part 2
## Blade, Tailwind, and Vite

Rendering a page from the server

---

## The Template Engine Concept: Template + Data &rarr; HTML

<div class="term-box">
<b>Template engine:</b> a tool that merges a template containing placeholders with real data, producing a final document ready to display.
</div>

<div class="flow">
  <div class="box">Template (placeholder)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">+ Data</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Template Engine</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Final HTML</div>
</div>

- A simple example: template `<h1>Hello, {{ $name }}</h1>` + data `$name = "Rani"` &rarr; result `<h1>Hello, Rani</h1>`
- The same concept appears across languages: Blade (Laravel/PHP), Jinja (Python), EJS (JavaScript), Twig (PHP)

<div class="tip-box">
Blade is one implementation of this concept in the Laravel ecosystem, not the concept itself.
</div>

---

## Blade: Laravel's Templating Engine

<div class="term-box">
<b>Blade:</b> Laravel's built-in templating engine, rendering HTML on the server using directive syntax like <code>@if</code> and <code>@foreach</code> directly inside <code>.blade.php</code> files.
</div>

<div class="term-box">
<b>Directive:</b> a Blade instruction starting with <code>@</code>, such as <code>@extends</code>, <code>@section</code>, and <code>@yield</code>, compiled by Laravel into plain PHP before it runs.
</div>

- Blade isn't a new language, just a concise way to write PHP inside a template

---

## Layout: Write the Skeleton Once

Nearly every page in a web application shares the same skeleton: a tab title, a navigation menu, and a content area that changes. A Blade layout avoids repeating that skeleton in every file.

```php
<!-- resources/views/layouts/app.blade.php -->
<!DOCTYPE html>
<html lang="en">
<head>
    <title>@yield('title', 'App Name')</title>
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body>
    <x-nav />
    <main>@yield('content')</main>
</body>
</html>
```

---

## A Page Fills the Layout's Hole

```php
<!-- resources/views/articles/index.blade.php -->
@extends('layouts.app')

@section('title', 'Article List')

@section('content')
    <h1 class="text-lg font-semibold mb-4">Article List</h1>
    <div class="grid grid-cols-3 gap-4">
        @foreach ($articles as $article)
            <div class="border rounded-md p-3">
                <p class="font-medium">{{ $article->title }}</p>
            </div>
        @endforeach
    </div>
@endsection
```

- The page never rewrites `<html>`, `<head>`, or the navigation menu

<div class="ref-link">Full list of Blade directives: <code>laravel.com/docs/blade</code></div>

---

## `{{ }}` and `{!! !!}`: Printing Data into HTML

<div class="term-box">
<b>{{ }}:</b> Blade's syntax for printing a variable or PHP expression's value into HTML, automatically escaping HTML characters.
</div>

<div class="term-box">
<b>{!! !!}:</b> Blade's syntax for printing a variable's value with no escaping at all; its content is printed as-is, as raw HTML.
</div>

- Example: `{{ $article->title }}` prints the article's title, automatically safe from a character like `<` that could otherwise be abused to inject foreign markup

<div class="warn-box">
Data coming from user input, including an article title typed into a form, must always be printed through <code>{{ }}</code>, never <code>{!! !!}</code>. The second syntax skips escaping entirely and opens a cross-site scripting hole the moment its content ever came from untrusted input.
</div>

- The full security discussion arrives in the validation & security meeting

---

## Component: A Piece You Reuse

<div class="term-box">
<b>Component:</b> a reusable piece of Blade shared across pages, such as a product card or a button, registered as its own file and invoked through an <code>&lt;x-component-name&gt;</code> tag.
</div>

- `<x-nav />` in the layout above is a component
- An article card or a button are natural next candidates

---

## Vite: The Frontend Build Tool

<div class="term-box">
<b>Vite:</b> the frontend build tool Laravel ships with by default, running a dev server with hot reload through <code>npm run dev</code> during development, and bundling/minifying every CSS & JavaScript file into production assets through <code>npm run build</code>.
</div>

<div class="flow">
  <div class="box">app.css / app.js</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Vite</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Tags via @vite</div>
</div>

- `@vite([...])` replaces manual `<script>`/`<link>` tags

---

## Three Files Behind `@vite`

1. `resources/css/app.css`: the first line is `@import 'tailwindcss';`, no separate `tailwind.config.js` file
2. `vite.config.js`: registers the `laravel()` and `tailwindcss()` plugins
3. `package.json`: lists both packages as `devDependencies`

<div class="tip-box">
All three have been in your project since Meeting 1. This meeting you start actually using them.
</div>

---

## Two Terminals: `artisan serve` + `npm run dev`

- Vite runs as a dev server separate from `php artisan serve`, in a second terminal
- What to expect: `VITE vX.X.X ready` followed by a local address
- Editing `app.css` or a Blade file shows up instantly, with no manual refresh (hot reload)

<div class="warn-box">
If <code>npm run dev</code> stops, the <code>@vite</code> directive on a page that reloads will fail to find the dev server and throw a <code>ViteManifestNotFoundException</code>.
</div>

<div class="tip-box">
<code>composer run dev</code> runs artisan serve, npm run dev, and other processes together in one terminal. Start with two separate terminals first, so it's clear which process fails.
</div>

---

## Tailwind: Utility-First CSS

- Utility classes attach directly to elements, instead of separate CSS rules in another file
- Example: `class="bg-slate-900 text-white rounded-md px-4 py-2"` for a dark, rounded button with padding
- One class equals one small styling decision, easy to guess and easy to remove

<div class="ref-link">Full utility-class reference: <code>tailwindcss.com/docs</code> (don't memorize it, look it up when you need it)</div>

---

<!-- _class: divider -->

# Part 3
## Light Interactivity with Alpine.js

A shopping cart with no page reload

---

## Alpine.js: State Inside the Markup

<div class="term-box">
<b>Alpine.js:</b> a lightweight JavaScript library adding state and interactivity directly through HTML attributes (<code>x-data</code>, <code>x-model</code>, <code>@click</code>), installed through npm like any other JavaScript dependency.
</div>

- Not a mini SPA framework, but a complement to a page Blade already renders
- Any element inside an `x-data`, including its children, can read and change that state through other Alpine attributes

---

## The Core Mechanism: `x-data`

```html
<div x-data="{ cart: [] }">
  <button @click="cart.push({ id: 1, price: 15000 })">
    Add
  </button>
  <span x-text="cart.length"></span> items in cart
</div>
```

- `cart` starts as an empty array, the Add button pushes one new object on every click
- `x-text="cart.length"` updates the number automatically, with no line of code explicitly telling the DOM to refresh
- Alpine watches `cart` for changes and keeps the display in sync on its own

---

## Alpine Attributes You'll Use

| Attribute | Purpose |
|---|---|
| `x-data` | Declares local state |
| `@click` | Runs code when an element is clicked |
| `x-text` | Displays a reactive value |
| `x-for` | Repeats an element for each item |
| `x-model` | Binds an input to state |

<div class="ref-link">Full attribute list: <code>alpinejs.dev</code></div>

---

## Installed via npm, Not a CDN

```bash
npm install alpinejs
```

```js
// resources/js/app.js
import Alpine from 'alpinejs';

window.Alpine = Alpine;
Alpine.start();
```

- `app.js` is already loaded by `@vite` in the layout, no new `<script>` tag needed
- The bundler's load order automatically sidesteps the problem the `defer` attribute used to solve on a CDN tag

---

## Interactivity Pattern: Click to Update State

<div class="flow">
  <div class="box">Click item</div>
  <div class="arrow">&rarr;</div>
  <div class="box">addToCart(id, name, price)</div>
  <div class="arrow">&rarr;</div>
  <div class="box">cart changes</div>
  <div class="arrow">&rarr;</div>
  <div class="box">x-for + x-text update</div>
</div>

- `x-data` wraps the relevant list of items, defining `cart`, `addToCart`, and `subtotal()`
- `subtotal()` uses `reduce` to sum up the prices

<div class="tip-box" style="margin-top:30px;">
Proof there's no reload: the address bar and tab favicon never flicker.
</div>

---

## The Golden Rule: The Server Recalculates

<div class="warn-box">
The subtotal Alpine computes client-side exists purely for display. Every time the form gets submitted, the server recalculates the total from the data in the database, not from whatever number Alpine displayed in the browser. Anything coming from the browser can still be tampered with before it reaches the server.
</div>

<div class="tip-box">
A useful rule of thumb: cosmetic logic (showing a subtotal, highlighting a just-added item) is safe to keep in Alpine. Business decisions (the final total, data validity) must be recalculated on the server.
</div>

---

## The Grown-Up Version: `Alpine.data`

- An inline `x-data` object is enough to learn the mechanism
- In the Simple POS case study you build in the jobsheet, the cart registers itself through `Alpine.data('posCart', ...)` in `app.js`, complete with SKU scanning, discounts, and `sessionStorage`
- Same concept, different scale

<div class="ref-link">Full code: <code>github.com/se-polinema/simple-pos</code>, branch <code>chapter-03</code></div>

---

## Summary

- An MPA reloads the whole page on every navigation, an SPA renders everything client-side, and Blade + Alpine.js take a middle path: the server still renders the structure, Alpine only adds reactivity where it's needed

- A Blade layout through `@extends`/`@section`/`@yield` avoids repeating HTML skeleton code; `@vite` loads Tailwind CSS and JavaScript through Vite, with `npm run dev` giving hot reload

- Tailwind works through utility classes attached to elements; `{{ }}` escapes automatically, `{!! !!}` does not and opens an XSS hole

- Alpine.js is installed through npm; `x-data` declares state right in the markup, `@click` and `x-text` read and change it reactively, and a client-computed subtotal must still be re-verified on the server

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation (Blade, Vite) &middot; Tailwind CSS (tailwindcss.com) &middot; Alpine.js (alpinejs.dev)

Full code: `github.com/se-polinema/simple-pos`

**Next meeting:** Database Design & Migration (schema, migrations, seeding)
