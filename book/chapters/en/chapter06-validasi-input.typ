#import "/template.typ": *

= Validation and Input Security <ch:validasi-input>

#chapterhero("teal", [Reject malformed input before it ever touches the database, then recompute the transaction total server-side, never trust a number the client sends.], [#icon("shield-alt")#h(1em)FormRequests], [#icon("check-double")#h(1em)server-side totals], [#icon("exclamation-triangle")#h(1em)error messages])

The guard at a warehouse gate doesn't just wave through anyone who
claims to be a courier. He checks the delivery order, matches the
vehicle's plate number, and holds back anyone whose paperwork is
incomplete right there at the gate, before a single item gets anywhere
near the storage area. A cashier at the register has a quieter version
of that same habit: the moment a customer hands over cash and names an
amount, a good cashier doesn't just take that number at face value, she
recounts the total herself off the printed receipt. Simple POS runs
both habits at once. A FormRequest plays the gate guard, holding back
malformed data before it ever reaches the controller. Server-side total
computation plays the recounting cashier, never accepting a total sent
from a form or client-side JavaScript at face value.

#strong[What You'll Learn]

+ write `FormRequest` classes to validate Simple POS's product and transaction input, including custom validation rules;
+ explain why a transaction's total and a transaction detail's subtotal must be computed server-side rather than accepted directly from client input;
+ handle validation error messages and flash messages on Simple POS's Blade forms so users get clear feedback when input is rejected.

== FormRequests and Validation Rules <sec:validasi-input-1>

#istilahpenting[
/ FormRequest: A Laravel class wrapping one request's validation and authorization logic, separated from the controller, so the controller only ever handles data already declared valid.
/ Validation: The process of checking whether input data meets a set of rules (type, format, value bounds) before that data gets used any further.
/ Sanitization: The process of cleaning or normalizing input data, such as trimming extra whitespace or casting a type, usually run after validation passes.
/ Flash Message: A short message stored in the session for exactly one following request, used to show a success or failure notice after a redirect.
]

Putting validation rules directly inside a controller method works fine
for a very simple form, but once one form has more than a handful of
rules, the controller quickly fills up with checking code that isn't
really the controller's job at all. `FormRequest` moves that
responsibility into its own class: the `rules()` method
declares every field's rules, and Laravel runs that validation
automatically before the controller method ever gets to execute at all.

#listing(file: "app/Http/Requests/StoreProductRequest.php", ```php
class StoreProductRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['required', 'exists:categories,id'],
            'price' => ['required', 'integer', 'min:0'],
            'stock' => ['required', 'integer', 'min:0'],
        ];
    }
}
```)

The `exists:categories,id` rule is an example of a built-in
Laravel rule that runs a database query as part of validation: it
rejects the request if the submitted `category_id` doesn't
match any `id` row in the `categories` table. Once
`StoreProductRequest` is used as a controller parameter's
type-hint, in place of a plain `Request`, Laravel automatically
runs `rules()` first; if anything fails, the request gets
redirected straight back to the originating form with error messages
attached, and the controller body never gets a chance to run at all.

== Why Totals Are Computed Server-Side <sec:validasi-input-2>

Chapter~3 already touched on this briefly: the Alpine.js cart on the
cashier page computes a subtotal directly in the browser, purely for
display. If the transaction form got submitted with a `total`
field carrying that Alpine-computed value, and the server trusted it
outright with no verification, anyone who alters the value on the
request itself (through browser DevTools, or an HTTP client like curl
that never runs any JavaScript at all) could submit whatever total they
wanted, including one far smaller than what the purchased products
actually cost.

#warningbox[
Any value originating on the client side, no matter how correct its
computation looks on screen, can be altered before it ever reaches the
server. A `total` field submitted through an HTML form is no
exception; it's just a string in the request body like any other field,
and nothing stops someone from changing it to a different value before
the request actually gets sent.
]

Simple POS sidesteps that risk by never reading `total` from
input at all. The controller only accepts a list of
`product_id` and `qty` pairs, then pulls each product's
real price from the database, multiplies it by the quantity for each
detail row, and sums up every one of those subtotals itself.

#listing(```php
$total = 0;
foreach ($validated['items'] as $item) {
    $product = Product::findOrFail($item['product_id']);
    $subtotal = $product->price * $item['qty'];
    $total += $subtotal;
    // save the TransactionDetail with $subtotal here
}
$transaction->update(['total' => $total]);
```)

With this pattern, whatever value someone tries to slip in through a
`total` field on the request, that value is never read at all;
the server always recomputes from a trusted source, the product price
actually stored in the database at that moment.

== Practice: Validating the Product and Transaction Forms <sec:validasi-input-3>

`StoreTransactionRequest` validates the structure of a shopping
item array, not just a single field. The steps below build it from
scratch and wire it onto the existing cashier transaction form.

+ Create the `FormRequest` class skeleton:

  #listing(```bash
  php artisan make:request StoreTransactionRequest
    
  ```)
+ Open the newly created file at
      `app/Http/Requests/StoreTransactionRequest.php`. Change
      `authorize()` to return `true` (any logged-in cashier
      may use this form), then fill in `rules()`:

  #listing(file: "app/Http/Requests/StoreTransactionRequest.php", ```php
  public function rules(): array
  {
      return [
          'items' => ['required', 'array', 'min:1'],
          'items.*.product_id' => ['required', 'exists:products,id'],
          'items.*.qty' => ['required', 'integer', 'min:1'],
      ];
  }
    
  ```)

  The `items.*.product_id` notation validates every element
      of the `items` array one by one, confirming every row's
      `product_id` genuinely exists in the `products`
      table and its `qty` is at least 1, without hand-writing a
      manual validation loop.
+ Open `app/Http/Controllers/TransactionController.php`,
      the `store()` method. Change its parameter's type-hint from a
      plain `Request` to `StoreTransactionRequest`:

  #listing(file: "app/Http/Controllers/TransactionController.php", ```php
  public function store(StoreTransactionRequest $request)
  {
      $validated = $request->validated();
      // ...total computed server-side, see the previous section
  }
    
  ```)

  Just by swapping that type-hint, Laravel automatically runs
      `rules()` before the first line of the `store()` method
      ever gets a chance to execute.
+ Open `resources/views/pos/create.blade.php` (the
      cashier form from Chapter~3). Add a success message block near the
      top of the page:

  #listing(file: "resources/views/pos/create.blade.php", ```php
  @if (session('success'))
      <div class="bg-green-50 text-green-700 p-3 rounded-md mb-4">
          {{ session('success') }}
      </div>
  @endif
    
  ```)
+ Near the cart element, add a general error block for the
      `items` field:

  #listing(file: "resources/views/pos/create.blade.php", ```php
  @error('items')
      <p class="text-sm text-red-600">{{ $message }}</p>
  @enderror
    
  ```)

  The `@error('items')` directive only renders that block
      when the `items` field specifically failed validation, so
      the error message shows up right next to the cart, not as a
      generic list at the top of the page.
+ In the controller, add a flash message once the transaction is
      saved: `->with('success', 'Transaction saved
      successfully.')` on its redirect.
+ Run `php artisan serve`, open `/pos`, then
      submit the cashier form with an empty cart (without adding a
      single product). #strong[What to expect]: the page returns to
      `/pos` (not some other page), and the error message from
      step 5 shows up right next to the cart.
+ Add one product to the cart, then resubmit the form.
      #strong[What to expect]: the transaction saves, the page redirects,
      and the success message from step 4 shows up once; reload that
      same page again and the message is already gone.
+ #strong[If `$errors` is always empty] even when the
      cart is submitted empty, check step 3: make sure the `store()`
      method's parameter is genuinely typed as
      `StoreTransactionRequest`, not a plain `Request`;
      validation only runs automatically through that type-hint.

#branchref("chapter-06")

== Summary <sec:validasi-input-rangkuman>

- `FormRequest` separates validation rules from the
      controller through the `rules()` method, run automatically
      by Laravel before the controller code ever executes, including
      built-in rules like `exists` that validate through a
      database query.
- A transaction's total and its detail subtotals must be
      recomputed server-side from the product price stored in the
      database, because any value sent from the client, including an
      Alpine.js computation, can be altered before it reaches the server
      and must never be trusted outright.
- Validation error messages are shown through `@error()`
      right next to the offending input, and a flash message through
      `session('success')` gives brief feedback after a redirect
      without persisting into the next request.

== Exercises

+ Add a new validation rule to `StoreProductRequest`
      that rejects a product name identical to another product's name
      within the same category (use the `unique` rule with an
      additional clause).
+ Submit a transaction request through curl with `qty` set
      to 0 and a `product_id` that doesn't exist, then observe
      what error message Laravel returns for each case.
+ Explain in your own words: if the `total` field still
      got validated (say, with a `numeric` rule), would that be
      enough to prevent total manipulation? Why or why not?
+ #strong[Self-check:] without reopening this chapter, try
      explaining in your own words: (a) what `FormRequest` does
      before the controller executes, (b) why a total must never be
      accepted directly from input, and (c) how a flash message differs
      from ordinary session data. Check your answers against this
      chapter.

#challengebox[
Add a sufficient-stock validation to `StoreTransactionRequest`
or the controller: reject a transaction if the `qty` requested
on any item row exceeds that product's currently stored `stock`,
with an error message naming the specific product that's short on
stock.
]

== References

This chapter draws on the official Laravel documentation
#cite(<laraveldocs>) for FormRequests and validation rules, and the OWASP
Top 10 #cite(<owasptop10>) for the principle of never trusting
client-side input.
