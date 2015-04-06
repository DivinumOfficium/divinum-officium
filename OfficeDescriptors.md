# Introduction #

Office descriptors are the data structures used internally to describe a single office (as opposed to the office of a day, which might consist of one office with a commemoration of others). The entries in [calendar files](CalendarFiles.md) can be thought of as dehydrated forms of office descriptors, which when parsed are arranged into the structure described here, with the inclusion of all sorts of derived data.

# The structure #

Each descriptor is a hash with (some of) the following values. Often the values will be specified by symbolic constants, and typically only a few representative possibilites will be listed here. For full lists, see `Calendar/Definitions.pm`.

## `category` ##

E.g. `FESTAL_OFFICE` or `SUNDAY_OFFICE`.

## `common_ref` ##

A cache of the common for the office, as loaded by `office_string`. Intended for use by `get_office_part_from_common`. See also `office_ref`.

## `office_ref` ##

A cache of the office file, as loaded by `office_string`. Intended for use by `get_office_part`.

## `rank` ##

## `rankord` ##

An integer representing the rank in some ordered fashion. Smaller is better.

## `standing` ##

`GREATER_PRIVILEGED_DAY`, `GREATER_DAY` or `LESSER_DAY`.

## `title` ##

## Lots more! ##