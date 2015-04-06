# Introduction #

More wide-ranging but rather out-of-date documentation is available at http://divinumofficium.com/www/horas/Help/brevitechnical.html.

# Syntax #

## Cross-references ##

```
@[filename][:section][:regex]
```

Includes a section from another (or the same) file.

  * `filename` is the name of the desired file relative to the language directory. If omitted, the current file is used.
  * `section` is the desired section in the specified file. If omitted, the current section name is used. May not be omitted if `filename` is omitted.
  * `regex` is a list of whitespaced-separated regular-expression substituions mimicking the syntax of Perl's `s///` operator. Only the `g`, `i`, `s` and `m` options are supported. May not be used if `section` is omitted.

**NB:** A different syntax applies in `Commemoratio` sections. (TODO: Document it.)

Examples:

```
[Ant Vespera]
@:Ant Laudes

[Graduale]
@Sancti/11-30

[Oratio]
@Commune/C2:Oratio1:s/N\./Eusébii/
```