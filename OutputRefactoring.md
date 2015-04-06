# Introduction #

The output produced for the hours and Mass could benefit from aesthetic improvements: alignment, spacing, etc. Also, from a technical standpoint, the HTML is not well-formed, and the logic for generating it is spread throughout the code. Each of successive point blocks progress of the former, and so we should attack the last first, by pulling all of the code that generates HTML into a single module. This page describes the work involved.

(In the first instance, we can focus on the HTML for the hours/Mass, rather than the control widgets at the top and bottom.)


# Architectural goals #

  * Move all formatting logic into a set of modules specifically for this purpose, only one of which should interact directly with the main scripts.
  * Create a clean interface between the outward-facing module and the scripts. The interface should prefer to specify high-level actions (e.g. "format this in the form of a psalm" rather than "make this text small").
  * Minimise the number of scripts that invoke formatting operations. `horas.pl` and `missa.pl` are the natural ones; formatting invocations elsewhere should be refactored into these scripts as far as possible.

These are all directed towards making the transition to a CSS-defined design as easy as possible.


# Short-term tasks #

  * Replace calls to `&setfont` in `horas.pl` with method invocations.
  * Start on the higher-level interface.
  * Replicate the existing work in the `missa` tree. Share as much code between the two trees as possible!


# Details #

Development should take place on the `output` branch. It should be possible to merge this back to `trunk` early and often.

The `DivinumOfficium::Output::HTMLFormatter` module provides an interface to the existing code for formatting text as HTML. It might be profitable to use `CGI.pm` as far as practical to generate the HTML, but we don't do that yet.

The `&setfont` subroutine has been moved into this module. `&setcell` should follow too at some point. Then new subroutines will need to be factored out from things that are inlined in the existing code. Since we're aiming for a unified codebase, where things are implemented in slightly different ways in the various `?officium.pl` and `?webdia.pl` scripts, this is a good time to synchronise them, parameterising things if need be.

We should write unit tests as we go.


# Patronage #

St Augustine, as patron of printers.