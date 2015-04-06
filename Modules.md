# Introduction #

To help keep the project maintainable, we should refactor a lot of the code into modules.

# Modules #

Everything should live in the `DivinumOfficium` namespace, the directory for which should live in `cgi-bin/`.

## Hierarchy ##

Incomplete!

  * `Calendar`
    * `Data`
  * `Mass`
  * `Office`
    * `LaudsAndVespers`
  * `Output`
    * `HTML`
  * `Scripting`

# Tests #

Each module should be provided with a set of unit tests. The should reside in the `t/` directory.