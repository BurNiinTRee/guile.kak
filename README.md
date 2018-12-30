# guile.kak
Simple guile integration for kakoune

This kakoune script allows you to start a guile session in the background and allows you to send your selection to it,
writing the output of the repl into a `guile` buffer.

Additionally, it provides a user mode called `guile`, allowing you to restart the guile process, load and execute your current buffer,
as well as your current selection.

## Installation
### With plug.kak
Simply add
```sh
plug "burniintree/guile.kak"
```
to your kakrc.
### Manually
Source the script from your kakrc via
```sh
source "path/to/guile.kak"
```
or clone this repo into your autoload directory.

## Contributions
Always welcome.

## Copying
This is licensed under the Gnu GPL v3. See the `LICENSE` file.
