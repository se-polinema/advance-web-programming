#import "/template.typ": *

= Testing and Application Quality <ch:pengujian-aplikasi>

#chapterhero("orange", [Read the anatomy of Simple POS's existing feature tests, run them as a quality gate, then build a milestone checklist before moving to the next chapter.], [#icon("vial")#h(1em)13 feature tests], [#icon("check-circle")#h(1em)`php artisan test`], [#icon("bug")#h(1em)a milestone checklist])

A quality control inspector on a factory floor doesn't wait until a
product reaches a buyer's hands to find out something's defective. She
stands at the end of the production line, pulls a sample from every
batch, runs the exact same check every single time, and holds that
batch back at the plant the moment even one sample fails. That
inspection needs no instinct or guesswork; the checklist is already
fixed, and the result is always a clean answer: pass or fail. Simple
POS's feature tests play that same role. Every time code changes,
whether adding a new feature or fixing an old bug, running `php
artisan test` gives a clean answer within seconds: existing behavior
still works as it should, or something broke somewhere that might not
have been noticed at all.

#strong[What You'll Learn]

+ explain the coverage of Simple POS's 13 feature tests (login/logout, role-based authorization, POS transactions, the API token flow) and what each group validates;
+ run `php artisan test` and interpret the resulting 27 assertions to decide whether a code change broke existing behavior;
+ build a milestone checklist to verify that Simple POS's CRUD, authentication, and authorization work before moving on to the next chapter.

== Anatomy of the Simple POS Feature Tests <sec:pengujian-aplikasi-1>

#istilahpenting[
/ Feature Test: A test that exercises one complete application flow, from an incoming HTTP request to the outgoing response, distinct from a unit test that checks one isolated function.
/ Assertion: A single check statement inside a test, such as "the response status must be 200" or "product stock must drop by 3", declared failed when reality doesn't match.
/ RefreshDatabase: Laravel's built-in PHPUnit/Pest trait that resets the test database to a clean state before every test runs, preventing one test from affecting another's result through leftover data.
/ Regression: Old behavior that previously worked correctly but broke due to a new code change, usually unintentional and unnoticed until a test fails.
]

Simple POS's 13 feature tests split into four groups, each exercising
one slice of behavior already covered in earlier chapters:
authentication (successful login, failed login, logout), role-based
authorization (admin can reach the product page, cashier gets blocked),
POS transactions (stock drops by the right quantity, total is computed
correctly from product prices), and the API token flow (API login
returns a token, a bad token gets rejected).

#listing(file: "tests/Feature/ProductAuthorizationTest.php", ```php
public function test_kasir_cannot_access_admin_pages(): void
{
    $kasir = User::factory()->create(['role' => 'kasir']);

    $response = $this->actingAs($kasir)->get('/products');

    $response->assertForbidden();
}
```)

`actingAs($kasir)` simulates a request as though it were sent
by an already-logged-in `$kasir` user, without actually
filling out a login form; that's what lets a feature test exercise the
`role:admin` middleware from Chapter~7 directly.
`assertForbidden()` is a single assertion, checking that the
response really does carry a 403 status. `RefreshDatabase`
attached to the test class makes sure the `$kasir` created in
this test doesn't leak into any test running after it.

== Running and Interpreting Test Results <sec:pengujian-aplikasi-2>

#listing(```bash
php artisan test

   PASS  Tests\Feature\AuthenticationTest
  [x] user can login with valid credentials
  [x] user cannot login with invalid credentials

   PASS  Tests\Feature\TransactionTest
  [x] stock decrements after transaction

  Tests:    13 passed (27 assertions)
  Duration: 1.42s
```)

The line `Tests: 13 passed (27 assertions)` is the summary worth
reading first: 13 is the number of test functions run, 27 is the number
of individual check statements across all of them combined (a single
test function can hold more than one assertion, as
`test_kasir_cannot_access_admin_pages` above would if an
error-message check got added on top). Every green checkmark means the
behavior under test still runs exactly as expected.

#warningbox[
A test that fails after a code change isn't noise to shrug off; it's
exactly the signal worth looking for: a regression. If
`test_stock_decrements_after_transaction` suddenly fails
after the transaction controller gets edited, that means the edit broke
stock-decrement behavior that previously worked correctly, regardless
of whether that edit was aimed at some entirely different feature.
]

== Practice: a Milestone Checklist Before Moving On <sec:pengujian-aplikasi-3>

These 13 feature tests cover the core features through Chapter~9, but
not every piece of Simple POS's behavior has an automated test. A
manual checklist fills that gap, especially for things easier to check
through a browser than to write as an assertion. The steps below run
the existing test suite, deliberately break one test to see it fail,
then work through the manual checklist.

+ Check where the existing tests live:
      `tests/Feature/AuthenticationTest.php`,
      `tests/Feature/TransactionTest.php`, and similar
      files under `tests/Feature/`. Each file tests one group of
      behavior, matching the anatomy from the previous section.
+ Run the whole suite to confirm the baseline is still green:

  #listing(```bash
  php artisan test
    
  ```)

  #strong[What to expect]: output like the previous section's,
      `13 passed (27 assertions)`.
+ Open `app/Http/Controllers/TransactionController.php`,
      deliberately change the stock-decrement line (for example, swap
      `$product->decrement('stock', $qty)` for
      `$product->increment('stock', $qty)`, the opposite).
+ Run `php artisan test` again. #strong[What to expect]:
      the `Tests: 13 passed` line now includes at least
      `1 failed`, with
      `test_stock_decrements_after_transaction` flagged as
      failing, along with a message comparing the expected stock value
      against what was actually returned.
+ Revert the line changed in step 3 back to its original
      (`decrement`), run `php artisan test` once more, and
      confirm it's back to `13 passed`.
+ Work through the following manual checklist one item at a
      time, directly in the browser:

  + Create, edit, then delete one product through
            `/products`. #strong[What to expect]: all three actions
            succeed with no errors.
  + Log in as admin, log out, log in as cashier, log out
            again. #strong[What to expect]: after logging out, opening a
            page that requires login (e.g. `/dashboard`) redirects
            straight back to the login form.
  + Log in as cashier, open `/products`. #strong[What to
            expect]: a 403 page, per Chapter~7.
  + Record one transaction through `/pos`, compare
            product stock before and after on `/products`.
            #strong[What to expect]: stock drops by exactly the quantity
            purchased.
+ #strong[If the test in step 4 shows no failure at all] after
      the deliberate change in step 3, check whether the line changed is
      genuinely the one executed when a transaction gets saved (not a
      line in a similar-looking method, e.g. a transaction-void method).

#tipbox[
Run `php artisan test` before starting a significant change, not
only after. An "all green" baseline before the change makes any failure
afterward unambiguous; if the same test was already failing before any
change even started, that failure isn't caused by the change that was
just written.
]

#branchref("chapter-10")

== Summary <sec:pengujian-aplikasi-rangkuman>

- Simple POS's 13 feature tests split across four groups
      (authentication, role authorization, POS transactions, the API
      token flow), each using `actingAs()` to simulate a logged-in
      user and `RefreshDatabase` to keep tests isolated from
      each other.
- `php artisan test` reports 13 tests and 27 assertions; a
      test that fails after a code change is a regression signal, not
      noise to ignore.
- A manual milestone checklist, such as verifying product CRUD and
      stock decrement directly through the browser, fills in around
      automated test coverage before moving to the next chapter.

== Exercises

+ Run `php artisan test` and read the result line by line,
      noting which test group exercises the behavior from Chapter~7.
+ Deliberately break one line of the transaction-total
      calculation logic (Chapter~6), run the tests again, and observe
      which test fails and what error message it shows.
+ Write your own milestone checklist for a feature in Simple POS
      that doesn't have an automated test yet, at least three items.
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) the difference between a feature
      test and a unit test, (b) why `RefreshDatabase` is needed,
      and (c) why a test that fails after a code change counts as a
      regression signal. Check your answers against this chapter.

#challengebox[
Write one new feature test for the sales report endpoint from
Chapter~8, verifying that the date-range filter genuinely excludes
transactions outside that range.
]

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for feature testing and `RefreshDatabase`.
