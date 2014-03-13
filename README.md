# brew-rebuild - Rebuild installed formulae

## Why?

Because the various one liners I've used don't really do this well. So here's an [external
command](https://github.com/Homebrew/homebrew/wiki/External-Commands) for [Homebrew](https://github.com/Homebrew/homebrew).

## Usage

````
brew rebuild --installed
brew rebuild qt
brew rebuild --recursive gettext
````

Rebuilds all formulae with the given formula as a dependency. Unless `--recursive` is supplied, only the formulae with a direct dependency will be rebuilt.

* `--installed` - rebuild all installed formulae. Useful for OS and compoler upgrades.
* `--recursive` - rebuild all formulae with a recursive dependency

## Installation

    brew tap tduehr/homebrew-rebuild && brew install brew-rebuild

## Contributing

I'm always happy to review pull requests but I'm not sure there's anything to add or change.