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
---

<!-- _class: lead -->

# Advanced Web Programming
## SIB245007 &nbsp;|&nbsp; D-IV Sistem Informasi Bisnis

Meeting 1: **Modern Web Architecture and the Laravel Ecosystem**

Semester Learning Plan (RPS) & Meeting 1 Materials

---

<!-- _class: divider -->

# Part 1
## Semester Learning Plan (RPS)

---

## Course Information

| | |
|---|---|
| **Study Program** | D-IV Sistem Informasi Bisnis |
| **Course Code** | SIB245007 |
| **Course Name** | Advanced Web Programming |

<div class="tip-box">
This course uses <b>Simple POS</b>, a real point-of-sale cashier app for small businesses that grows commit by commit, as a running case study across the whole semester.
</div>

---

## Semester Learning Plan

<div class="cols">
<div>

<table class="small">
<tr><th>Meeting</th><th>Topic</th></tr>
<tr><td>1</td><td>Modern Web Architecture</td></tr>
<tr><td>2</td><td>HTTP &amp; MVC Architecture</td></tr>
<tr><td>3</td><td>Frontend &amp; Templating</td></tr>
<tr><td>4</td><td>Database Design &amp; Migration</td></tr>
<tr><td>5</td><td>ORM &amp; Data Relations</td></tr>
<tr><td>6</td><td>Input Validation &amp; Security</td></tr>
<tr><td>7</td><td>Authentication &amp; Authorization</td></tr>
<tr><td>8</td><td><b>Midterm</b></td></tr>
<tr><td>9</td><td>Data Processing &amp; Export</td></tr>
</table>

</div>
<div>

<table class="small">
<tr><th>Meeting</th><th>Topic</th></tr>
<tr><td>10</td><td>API Architecture &amp; Design</td></tr>
<tr><td>11</td><td>PBL Project Planning</td></tr>
<tr><td>12</td><td>PBL Feature Development</td></tr>
<tr><td>13</td><td>PBL Integration &amp; Testing</td></tr>
<tr><td>14</td><td>PBL Optimization &amp; Deployment</td></tr>
<tr><td>15</td><td>PBL Project Finalization</td></tr>
<tr><td>16</td><td>PBL Final Exam Preparation</td></tr>
<tr><td>17</td><td><b>Final Exam</b></td></tr>
</table>

</div>
</div>

<div class="tip-box">
Meetings 1&ndash;10 build the technical foundation in Laravel; Meetings 11&ndash;17 shift it into an independent <i>Project Based Learning</i> (PBL) project.
</div>

---

## Evaluation Components

| Evaluation Basis | Weight |
|---|---:|
| Participatory Activity (Case Method) | 0% |
| Project Outcome (Project Based Learning) | 55% |
| Cognitive &ndash; Weekly assignment (increment) | 15% |
| Cognitive &ndash; Quiz | 0% |
| Cognitive &ndash; Midterm (project progress + presentation) | 5% |
| Cognitive &ndash; Final Exam (final project + presentation) | 25% |
| **Total** | **100%** |

<div class="term-box">
<b>Weekly assignment</b>: incremental (<i>increment</i>) implementation of the Simple POS application, submitted as evidence of code and documentation per the rubric.
</div>

---

<!-- _class: divider -->

# Part 2
## Meeting 1: Modern Web Architecture and the Laravel Ecosystem

---

## What You'll Learn

1. Comparing **monolith**, **microservices**, and **serverless** architectures to explain why Laravel was chosen as Simple POS's framework

2. Understanding why **Laravel 13** with **SQLite** as a zero-setup database was chosen for Simple POS

3. Recognizing the Laravel project folder structure (`routes/`, `app/Http/Controllers/`, `database/migrations/`) as an embodiment of the **MVC** pattern

<div class="tip-box">
This slide covers concepts. Installation steps, project setup, and full hands-on practice are covered separately outside this slide.
</div>

---

## What Is Web Architecture?

<div class="term-box">
<b>Web architecture:</b> how an application's layers (interface, business logic, data access) are organized and deployed: as a single unit, or as many separate units.
</div>

- Choosing an architecture isn't just a technical decision: it determines how many deploy processes, failure points, and network calls the team has to manage
- A "fancier" architecture isn't automatically better: building a food court for a business that only needs one kitchen just burns effort on connecting plumbing instead of features
- Three styles we'll compare: **monolith**, **microservices**, **serverless**

---

## Monolith

<div class="term-box">
<b>Monolith:</b> An application whose layers (interface, business logic, data access) all run in a single codebase and a single deploy process.
</div>

- Adding a feature = adding code to the same project
- Deploying an update = replacing one unit with a new version
- Often mistaken for "messy code"
- A well-structured monolith (e.g. with MVC) stays clean
- Its opposite isn't "modular", it's **"distributed"**

---

## Microservices

<div class="term-box">
<b>Microservices:</b> An architecture that splits an application into independent services, each running and deployed on its own, communicating over a network.
</div>

- Each service: different language, different deploy schedule, scales independently
- **The price:** 8 services = 8 deploy processes + 8 failure points + network calls between services
- Worth it for **large teams** running systems at millions-of-users scale
- For Simple POS: the cost far outweighs the benefit

---

## Analogy: Family Restaurant vs. Food Court

The two architectures we just defined, in an everyday analogy:

<div class="cols">
<div>

**Family restaurant (monolith)**
- One kitchen, one register, one team
- Everybody knows everything
- Busy? Add a stove, not a new branch

</div>
<div>

**Food court (microservices)**
- Each stall: its own kitchen, register, recipe
- Independent units
- One empty stall doesn't affect the others

</div>
</div>

<div class="tip-box">
Simple POS is built as a <b>monolith</b> (the family restaurant) not out of limitation, but because the scale fits: a shop with one or two cashiers doesn't need ten separate services.
</div>

---

## Serverless

<div class="term-box">
<b>Serverless:</b> Code runs as small functions that only execute when triggered by an event, with no server process staying up continuously.
</div>

- The name is misleading: the server still exists, it's just not your responsibility
- There's a **cold start** delay when a function hasn't been called in a while
- Billing is per execution, not per hour a server stays on
- Good fit: spiky workloads (e.g. image processing on upload)
- Poor fit: Simple POS, which needs a consistent database connection

---

## Comparing the Three Architectures

| Architecture | Deployment | Initial Complexity | Best For |
|---|---|---|---|
| **Monolith** | Single unit | Low | Simple POS, MVPs, small teams |
| **Microservices** | Many independent units | High | Large-scale systems, large teams |
| **Serverless** | Function per event | Medium | Sporadic workloads |

<div class="cols" style="margin-top: 30px;">
<div class="stack">
<div class="box">Interface (UI)</div>
<div class="box">Business Logic</div>
<div class="box">Data Access</div>
<p style="text-align:center; font-weight:bold;">Monolith</p>
</div>
<div class="stack">
<div class="box">Product Service</div>
<div class="box">Payment Service</div>
<div class="box">User Service</div>
<p style="text-align:center; font-weight:bold;">Microservices</p>
</div>
</div>

---

## Why Laravel?

<div class="term-box">
<b>MVC (Model-View-Controller):</b> the Model owns data, the View owns presentation, the Controller owns the request flow between them.
</div>

- One PHP project: routing, authentication, ORM, templating, ready to use
- Compared to plain PHP: consistent MVC structure from the first line of code
- Compared to microservices-first frameworks: stays productive for a team of 1&ndash;2 people
- Strong package ecosystem: **Sanctum** (API), **Excel** (import/export), **Cashier** (payments)
- Similar philosophy to Django (Python) & Ruby on Rails: *convention over configuration*

---

## One Entry Point: `public/index.php`

<div class="cols">
<div>

**Plain PHP**
- URL maps directly to a file
- `/product.php` &rarr; runs `product.php`
- Every file is potentially accessible directly via URL

</div>
<div>

**Laravel**
- Every request enters through one file: `public/index.php`
- URLs are registered in `routes/web.php`
- Other files (Controller, Model) can't be accessed directly via URL

</div>
</div>

<div class="tip-box">
A single entry point means every request can be processed uniformly before reaching the application code: the foundation of routing, middleware, and centralized authentication.
</div>

---

## One Laravel Request, Start to Finish

<div class="flow">
  <div class="box">Request</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Router</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Controller</div>
  <div class="arrow">&rarr;</div>
  <div class="box">Model</div>
  <div class="arrow">&rarr;</div>
  <div class="box">View / Response</div>
</div>

<div class="tip-box" style="margin-top:40px;">
This flow pattern repeats across every Simple POS feature, from the simple POS page to REST API endpoints, all following the same path.
</div>

---

## Setting Up the Project: Why SQLite?

- The database is stored in **a single plain file**
- No separate server process to start and configure
- Migrations can run right in the first minute
- Simple POS runs on SQLite even for classroom demos

<div class="warn-box">
Before continuing, make sure these four tools are installed: <code>php -v</code> (8.2+), <code>composer -V</code>, <code>node -v</code>, and <code>git --version</code>.
</div>

---

## Composer & npm: Dependency Managers

<div class="term-box">
<b>Composer:</b> PHP's dependency manager, reads <code>composer.json</code>, downloads packages into <code>vendor/</code>, then generates <code>vendor/autoload.php</code>.
</div>

- Thanks to <code>autoload.php</code>, every class is usable right away, no manual <code>require</code>/<code>include</code> like in plain PHP
- **npm** is its counterpart in the JavaScript world: `package.json` lists packages, `node_modules/` stores them, used by Laravel for Vite & Tailwind
- Both folders (`vendor/`, `node_modules/`) are downloaded output, never committed to Git

---

## `.env` & the Configuration Layer

<div class="term-box">
<b>.env:</b> a configuration file that separates credentials and environment settings from source code.
</div>

- Configuration read path: `.env` &rarr; the `env()` helper &rarr; `config/*.php` &rarr; the `config()` helper used by application code
- The app key inside it is used to encrypt sessions and cookies
- This separation allows different configuration per environment (local, staging, production) without changing code

<div class="warn-box">
The <code>.env</code> file stores sensitive data and must never be committed. Laravel's default <code>.gitignore</code> already excludes it.
</div>

---

## Artisan & Migrations

<div class="term-box">
<b>Artisan:</b> Laravel's built-in CLI for everyday development tasks (migrations, seeding, generating boilerplate): a dev tool, not part of the application served to users.
</div>

<div class="term-box">
<b>Migration:</b> a PHP file that defines a database schema change in code, so the schema can be rebuilt consistently on any machine.
</div>

- Treat migrations like version control for the schema: a new change means a new migration file, never edit an old migration that's already run elsewhere
- The `--seed` option fills tables with realistic sample data for practice and demos

---

## Laravel's Folder Structure = MVC in Practice

| Folder | MVC Role | Contents |
|---|---|---|
| `routes/web.php` | Controller | URL registration |
| `app/Http/Controllers/` | Controller | Request-handling classes |
| `database/migrations/` | Model | Database schema definitions |
| `resources/views/` | View | Blade files (Meeting 3) |
| `vendor/` | - | Composer packages, not committed |

<div class="tip-box">
This structure isn't an accident: it embodies the same MVC pattern as the request-flow diagram earlier.
</div>

---

## Summary

- **Monolith** unifies every layer in one codebase and one deploy, a fit for Simple POS's scale; **microservices** splits it apart at a cost that's only worth it for large systems; **serverless** suits sporadic workloads

- Laravel is Simple POS's framework because its structure stays consistent from the start (MVC) and it's productive for small teams; **SQLite** is the database because it's zero-setup: one file, no separate server

- **Composer**/npm manage dependencies; **.env** separates configuration from code; **Artisan** & **migrations** build the database schema programmatically

- Laravel's folder structure embodies the **MVC** pattern, consistently separating the responsibilities of routing, business logic, and presentation

---

<!-- _class: lead -->

# References & Discussion

Official Laravel documentation &middot; PHP Manual

Full code: `github.com/se-polinema/simple-pos`

**Next meeting:** HTTP & MVC Architecture
