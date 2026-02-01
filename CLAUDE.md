# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Divinum Officium is a traditional Roman liturgy generator written in Perl/CGI. It generates texts for the Divine Office (Liturgy of the Hours) and Mass based on liturgical calendars, supporting 22+ languages and multiple liturgical traditions (1960, Divino Afflatu, 1570).

## Common Commands

```bash
# Run unit tests (working directory matters)
prove -r -I web/cgi-bin/ t

# Build system
perl Build.pl
perl Build test

# Code formatting (checked by CI)
perltidy <file.pl>
./perltidy.sh                    # Format all .pl/.pm files

# Docker development (runs on http://localhost:8080)
docker-compose up

# Docker production
docker-compose -f docker-compose-prod.yml up -d
```

## Architecture

### Core Directories

- **`web/cgi-bin/DivinumOfficium/`** - Main Perl modules (Date.pm, FileIO.pm, Main.pm, Cache.pm, etc.)
- **`web/cgi-bin/horas/`** - Divine Office generation scripts (main entry: officium.pl)
- **`web/cgi-bin/missa/`** - Mass generation scripts (main entry: missa.pl)
- **`web/www/horas/`** - Liturgical data files organized by language (Latin/, English/, etc.)
- **`web/www/missa/`** - Mass data files organized by language

### Data File Format

Liturgical data files are UTF-8 plain text with section-based format:
```
[SectionName]
Content here...

[AnotherSection]
More content...
```

Each language directory contains: `Commune/`, `Sancti/`, `Tempora/`, `Psalterium/`, `Martyrologium/`

### Testing

- **`t/`** - Unit tests using Test::Simple
- **`regress/`** - Regression tests comparing office output between commits

## Code Style

Perl code must pass perltidy with `.perltidyrc` settings:
- 2-space indentation
- 120 character line limit
- Cuddled braces
- No space inside parentheses/brackets

CI runs perltidy check on all PRs affecting .pl/.pm files.

## Caching System

The application supports caching of computed liturgical data via the `DivinumOfficium::Cache` module.

### Environment Variables

- **`CACHE_DIR`** - Directory path for storing cached content. Must be set to enable caching.
- **`SERVE_FROM_CACHE`** - Set to `true` or `1` to serve cached content when available.

### How It Works

1. Cache keys are generated from all parameters that affect output (date, version, language, hour, etc.)
2. Keys use SHA256 hashing for consistent, collision-resistant identifiers
3. Cached files are stored in a hierarchical directory structure: `{CACHE_DIR}/{type}/{hash[0:2]}/{hash[2:4]}/{hash}.html`
4. Two cache types: `horas` (Divine Office) and `missa` (Mass)

### Configuration Example

```bash
export CACHE_DIR=/var/cache/divinumofficium
export SERVE_FROM_CACHE=true
```

### Cache API

A REST-like API is available at `/cgi-bin/DivinumOfficium/cache_api.pl`:

| Endpoint | Description |
|----------|-------------|
| `?action=status` | Get cache statistics (file counts, sizes) |
| `?action=keys&type=horas` | List cached keys (optional type filter) |
| `?action=get&key=<hash>` | Get cached content by key |
| `?action=get&key=<hash>&format=html` | Get raw HTML content |
| `?action=clear&key=<hash>` | Delete specific cache entry |
| `?action=clear_all&confirm=yes` | Clear entire cache |

### Cache Invalidation

To clear the cache via API:
```bash
curl "http://localhost:8080/cgi-bin/DivinumOfficium/cache_api.pl?action=clear_all&confirm=yes"
```

Or manually delete the contents of `CACHE_DIR`:
```bash
rm -rf $CACHE_DIR/*
```

## Technology Stack

- Perl 5 (5.10.1 minimum, 5.42 in Docker)
- Apache2 with mod_cgi
- Docker/Docker Compose for development
- GitHub Actions for CI (lint.yml, build.yml)
