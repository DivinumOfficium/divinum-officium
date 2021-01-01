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

## Docker

Build status badges:

[![](https://images.microbadger.com/badges/version/divinumofficiumweb/divinumofficium.svg)](https://hub.docker.com/r/divinumofficiumweb/divinumofficium "DockerHub Container")

[![](https://images.microbadger.com/badges/image/divinumofficiumweb/divinumofficium.svg)](https://hub.docker.com/r/divinumofficiumweb/divinumofficium "DockerHub Container")

### Production

To pull a pre-built container, pull see docker image `divinumofficiumweb/divinumofficium:latest`.

You can also use Docker Compose to load a copy of the container in one command:

```bash
docker-compose -f docker-compose-prod.yml up -d
```

This will download Divinum Officium, and run a local copy on your system, bound to
`localhost`, port 80.

When you are done, stop the container by running:

```bash
docker-compose -f docker-compose-prod.yml down
```

### Development

[Docker](https://docker.com/) contains complete development environment
necessary for running Divinum Officium website. To run this project you need to
have docker and [Docker Compose](https://docs.docker.com/compose/) installed on
your system. Run the following command in root directory of project:

```bash
docker-compose up
```

This starts the web server and you can visit the website on
`http://localhost:8080`. It will mount the current web directory into the container
so that you can change files and do live-changes without restarting the container.

#### MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

This permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.