#import "/template.typ": *

= REST API Reference <app:rest-api>

This appendix summarizes the Simple POS REST API endpoints used by a mobile
cashier client, as discussed in #xref(<ch:membangun-rest-api>). Every endpoint
sits behind Sanctum as the token-based authentication layer.

== Authentication

#table(
    columns: (0.4fr, 1.4fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Method]], [#strong[Endpoint]], [#strong[Description]],
    table.hline(stroke: 0.5pt),
    [POST], [`/api/login`], [Send an email and password, returns a Sanctum token],
    [POST], [`/api/logout`], [Revoke the token currently in use (requires the `Authorization` header)],
    table.hline(stroke: 0.8pt),
  )

#notebox[
Every request to a protected endpoint must include an
`Authorization: Bearer <token>` header, where `<token>` is the
value returned by `POST /api/login`.
]

== Products

#table(
    columns: (0.4fr, 1.4fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Method]], [#strong[Endpoint]], [#strong[Description]],
    table.hline(stroke: 0.5pt),
    [GET], [`/api/products`], [Fetch the product list along with stock and price],
    table.hline(stroke: 0.8pt),
  )

== Transactions

#table(
    columns: (0.4fr, 1.4fr, 1.4fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Method]], [#strong[Endpoint]], [#strong[Description]],
    table.hline(stroke: 0.5pt),
    [POST], [`/api/transactions`], [Create a new transaction; the total is computed server-side],
    [GET], [`/api/transactions`], [Fetch the transaction list for the currently logged-in user],
    [GET], [`/api/transactions/{id}`], [Fetch a single transaction's detail],
    table.hline(stroke: 0.8pt),
  )

#warningbox[
Just like the web version, `POST /api/transactions` never accepts a
total value from the client. The total is always recomputed server-side from
product prices and quantities, following the same principle covered in
#xref(<ch:validasi-input>).
]
