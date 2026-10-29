#import "/template.typ": *

= Development Environment Installation Guide <app:instalasi>

Chapter~1 assumes four command-line tools are already installed: PHP,
Composer, Node.js, and Git (see the tip box right before
`composer create-project` in that chapter). This appendix walks
through installing all four from scratch, split by operating system, then
closes with a verification step common to all three.

#figure(
  table(
    columns: (0.8fr, 0.9fr, 1.6fr),
    align: (left, left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Tool]], [#strong[Minimum Version]], [#strong[Purpose]],
    table.hline(stroke: 0.5pt),
    [PHP], [8.2], [Runs Laravel 13 and the Artisan command line],
    [Composer], [2.x], [Installs PHP dependencies from `composer.json`],
    [Node.js], [18 LTS], [Runs `npm` for the Vite + Tailwind toolchain (Chapter~3)],
    [Git], [2.x], [Tracks code versions and follows the `chapter-NN` branches],
    table.hline(stroke: 0.8pt),
  ),
  caption: [Tools required before starting Chapter~1],
) <tab:instalasi-kebutuhan>

== Windows

The quickest path on Windows 10/11 is #pkg[winget], the package manager
already bundled with most modern installations. Open PowerShell and run
the following four commands one at a time:

#listing(```bash
winget install PHP.PHP.8.3
winget install Composer.Composer
winget install OpenJS.NodeJS.LTS
winget install Git.Git
```)

#warningbox[
The default `php.ini` shipped with the #pkg[PHP.PHP.8.3] package
disables several extensions, including `pdo_sqlite`, which Simple
POS requires. Run `php --ini` to find the active `php.ini`
path, open it, and remove the leading `;` from the
`extension=pdo_sqlite` and `extension=fileinfo` lines. See
#xref(<sec:instalasi-ekstensi>) for the full list of required extensions.
]

#tipbox[
Close and reopen the terminal window after #pkg[winget] finishes
installing. A newly added PATH entry is only picked up by terminals
opened after the change, not the one still running.
]

Another option is #pkg[Scoop], a package manager that installs every tool
into the user's own directory (`~ scoop`)
without requiring administrator rights or a UAC confirmation prompt. This
is useful on campus lab or office computers whose accounts are not granted
administrator access. Open PowerShell and run:

#listing(```bash
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex
scoop install php composer nodejs-lts git
```)

#notebox[
The first two lines install Scoop itself (allowing locally signed
PowerShell scripts to run, then downloading and running Scoop's
installer); the third line installs all four tools at once from Scoop's
default `main` bucket. Scoop's #pkg[php] package uses the same
default Windows `php.ini` as the #pkg[winget] package, so the
`pdo_sqlite` extension warning above applies here exactly the
same way. Pick one package manager only, #pkg[winget] or #pkg[Scoop], not
both; two competing PHP installations on PATH are the most common cause
of `php -v` showing an unexpected version (see the warning box in the
Verification section).
]

== macOS

#pkg[Homebrew] is the most common third-party package manager on macOS.
If it is not installed yet, follow the instructions at
#link("https://brew.sh") first, then run:

#listing(```bash
brew install php composer node git
```)

#notebox[
The Homebrew #pkg[php] formula already ships every extension listed in
#xref(<sec:instalasi-ekstensi>) enabled by default, including
`pdo_sqlite`, so the `php.ini` edit described for Windows is
not needed on macOS.
]

#warningbox[
macOS ships a system PHP at `/usr/bin/php`, usually an old version
Laravel 13 does not support. After `brew install php`, confirm
`which php` points to `/opt/homebrew/bin/php` (Apple Silicon) or
`/usr/local/bin/php` (Intel), not `/usr/bin/php`. If it still
points to the system version, add
`export PATH="/opt/homebrew/bin:$PATH"` to
`~/.zshrc`, then open a new terminal window.
]

== Linux (Debian/Ubuntu)

#listing(```bash
sudo apt update
sudo apt install php php-cli php-sqlite3 php-mbstring php-xml php-curl unzip
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo apt install nodejs npm git
```)

#notebox[
Ubuntu LTS's default package repository sometimes lags a few PHP versions
behind the latest release. If `php -v` reports a version below 8.2
after `apt install`, add the #pkg[ondrej/php] PPA
(`sudo add-apt-repository ppa:ondrej/php`) before re-running
`apt update && apt install php8.3`. Fedora and Arch Linux users can
use the equivalent package names with `dnf install php composer
nodejs npm git` or `pacman -S php composer nodejs npm git`.
]

== Verification

Once one of the paths above is done, run the following four commands in
the terminal to confirm everything is installed and reachable through
PATH:

#listing(```bash
php -v
composer -V
node -v
git --version
```)

#figure(
  image("/images/verifikasi-instalasi.png", width: 85%),
  caption: [Sample terminal output after running the four verification
commands in sequence; the exact version numbers on your screen will
differ depending on when each tool was installed, what matters is the
absence of any `command not found` message],
) <fig:verifikasi-instalasi>

#warningbox[
If `php -v` shows an old version even though a newer one was just
installed, another PHP installation is likely found first on PATH
(common on macOS with the system PHP, or on Windows with a leftover
XAMPP install). Run `which php` (macOS/Linux) or `where.exe php`
(Windows) to see the order of locations checked, then adjust PATH so the
correct installation appears first.
]

== PHP Extensions Laravel Requires <sec:instalasi-ekstensi>

Laravel 13 checks for nine PHP extensions when `composer
create-project` and `php artisan serve` run. Most are already
enabled by default on modern PHP installations, but minimal builds
(especially manual builds from source, or a bare `php:cli` Docker
image) often miss some of them.

#figure(
  table(
    columns: (1fr, 1.8fr),
    align: (left, left),
    table.hline(stroke: 0.8pt),
    [#strong[Extension]], [#strong[Purpose]],
    table.hline(stroke: 0.5pt),
    [OpenSSL], [Encrypts sessions, cookies, and the application key],
    [PDO & `pdo_sqlite`], [Eloquent's connection to the `database.sqlite` file],
    [Mbstring], [UTF-8-safe string handling (product names, transaction labels)],
    [Tokenizer], [Composer's and Blade's internal parser],
    [XML], [Parses Composer package configuration],
    [Ctype & JSON], [Input validation and API responses (Chapter~9)],
    [BCMath], [High-precision decimal math for transaction totals],
    [Fileinfo], [File-type detection during CSV import (Chapter~8)],
    table.hline(stroke: 0.8pt),
  ),
  caption: [PHP extensions required for Laravel 13 and Simple POS],
) <tab:instalasi-ekstensi>

#tipbox[
The `php -m` command prints every extension active on the current
PHP installation. Pair it with `grep` to check one at a time, for
example `php -m | grep -i sqlite` to confirm `pdo_sqlite` is
active before running `php artisan migrate:fresh --seed` for the
first time.
]
