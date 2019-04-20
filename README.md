# divinum-officium
Data files and source code for the
[Divinum Officium](http://www.divinumofficium.com/) project.

This document is intended for people wishing to contribute to the project. To
pray the office, please [visit the website](http://www.divinumofficium.com/).

## Contributing to the project

Contributions are very welcome. To propose a change, please create a GitHub
account if necessary, and then open a **pull request**.

For small changes -- for example, for typographical corrections -- the simplest
way to do so is to navigate to the relevant file in GitHub's repository browser
and use its built-in editor. Any changes made in this way will automatically be
converted to a pull request.

For more substantial changes, please **fork** this repository using the link on
the repository's page on GitHub. This will create a copy of the repository
under your own account to which you may commit freely. When you are ready to
submit your change, GitHub's web interface can be used to create a
corresponding pull request. There are various ways to do this, and the
process is [described in the GitHub
documentation](https://help.github.com/articles/using-pull-requests/).

### Data files

The data files for the office and Mass are contained in the `web/www/horas/`
and `web/www/missa/` directories. Within these directories there is a directory
for each language. The files are UTF-8-encoded text files (Windows-1252
encoding is also supported, but is deprecated). The files are arranged into
sections, with each section beginning with its name enclosed in square
brackets. Please browse the files in the aforementioned directories for
examples.
