homebrew-rebuild
================

Usage:

````
brew rebuild --installed
brew rebuild qt
brew rebuild --recursive gettext
````

Rebuilds all formulae with the given formula as a dependency. Unless `--recursive` is supplied, only the formulae with a direct dependency will be rebuilt.

* `--installed` - rebuild all installed formulae. Useful for OS and compoler upgrades.
* `--recursive` - rebuild all formulae with a recursive dependency
