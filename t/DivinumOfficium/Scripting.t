use strict;
use warnings;

use lib 'web/cgi-bin';
use DivinumOfficium::Scripting qw(dispatch_script_function parse_script_arguments);
use Test2::V0;

# Not covered here (documented gap, no reasonable way to exercise these):
#   - The older-Perl deferred-registration fallback (register_deferred_functions
#     / the "if (register_deferred_functions())" retry in dispatch_script_function):
#     @deferred_functions is a true file-scoped lexical, not reachable from a
#     test without a source change, and the code path it exists for isn't
#     triggered on modern Perls (script_attr_handler gets a usable glob
#     immediately).
#   - The parenthesized name-override form of the attributes, e.g.
#     ':ScriptFunc(SomeName)' / ':ScriptShortFunc'. Neither form is used
#     anywhere in the real codebase (grep finds zero occurrences), and ad hoc
#     testing during development of this file could not get the override name
#     to register successfully under either the override or the sub's own
#     name. Flagged here rather than pursued further, since nothing in
#     production depends on it.

### parse_script_arguments
# "The syntax is very crude: only numeric literals and single-quoted strings
# (with no escaping functionality) are supported" (per the sub's own doc).

## Group A: happy path

is([parse_script_arguments(undef)], [], 'undef yields no arguments');
is([parse_script_arguments('')], [], 'An empty string yields no arguments');
is([parse_script_arguments('5')], ['5'], 'A bare positive number');
is([parse_script_arguments('-5')], ['-5'], 'A bare negative number');
is([parse_script_arguments("'hello'")], ['hello'], 'A single-quoted string has its quotes stripped');
is([parse_script_arguments("5,'hello',10")], ['5', 'hello', '10'], 'A mixed list of numbers and a quoted string',);

# The split regexp is quote-balance-aware: a comma *inside* a quoted string
# does not split the argument list.
is([parse_script_arguments("'a,b',5")], ['a,b', '5'], 'A comma inside quotes does not split the argument');

## Group B: two confirmed bugs, documented rather than fixed
# The final step is `map { /'(.*)'|(-?\d+)/; $1 || $2 }`. Because '||' tests
# truthiness rather than definedness, this silently discards a quoted
# capture ($1) whenever it happens to be a Perl-falsy string ('' or '0'),
# falling through to $2 (undef, since the numeric alternative never
# matched) instead of returning the real value. A fix would use '//'
# (defined-or) instead of '||', but that's out of scope here: these tests
# document the current (buggy) behavior as a regression marker.
# TODO: Check if this is intentional

is(
  [parse_script_arguments("''")],
  [undef], 'BUG: an empty quoted string argument becomes undef instead of the empty string',
);
is([parse_script_arguments("'0'")], [undef], 'BUG: a quoted literal "0" becomes undef instead of the string \'0\'',);

## Group C: other quirks worth pinning down

# split()'s default behaviour drops trailing empty fields but keeps leading
# ones - this asymmetry applies here too, since parse_script_arguments does
# no trimming of its own.
is([parse_script_arguments('5,')], ['5'], 'A trailing comma does not produce a trailing empty argument');
is([parse_script_arguments(',5')], [undef, '5'], 'A leading comma does produce a leading (undef) argument');

# Unquoted, non-numeric text matches neither alternative in the regexp, so
# it silently becomes undef - this is the "crude" syntax working as
# documented, not a bug.
is([parse_script_arguments('foo')], [undef],
  'Unquoted non-numeric text becomes undef, per the documented crude syntax');

### register_script_function / dispatch_script_function

# register_script_function() isn't exported (it's meant to be driven via the
# :ScriptFunc/:ScriptShortFunc attributes below), but it's still a plain sub
# in the package, so it can be called by its fully-qualified name.
DivinumOfficium::Scripting::register_script_function('TestDispatch', sub { return "got:@_" });

is(dispatch_script_function('TestDispatch', 'a', 'b'),
  'got:a b', 'Dispatch calls the registered function with its arguments');

like(
  dies { dispatch_script_function('NoSuchScriptFunction') },
  qr/Invalid script function NoSuchScriptFunction/,
  'Dispatching an unregistered function name is fatal',
);

# Registering only a "short" handler leaves the (only ever consulted) 'func'
# slot empty. This also demonstrates that the short-function mechanism is
# unreachable: dispatch_script_function() never looks at 'shortfunc'.
DivinumOfficium::Scripting::register_script_function('ShortOnly', sub { return 'x' }, short => 1);

like(
  dies { dispatch_script_function('ShortOnly') },
  qr/No handler registered for ShortOnly/,
  'A function registered only as a short-form handler has no dispatchable code',
);

### The real :ScriptFunc attribute mechanism
# Everything above drives register_script_function() directly; this checks
# the actual production path (Attribute::Handlers -> script_attr_handler ->
# register_script_function) that all ~50 real script functions go through.

sub RealAttributeFunc : ScriptFunc {
  return "attr:@_";
}

is(
    dispatch_script_function('RealAttributeFunc', 1, 2),
  'attr:1 2', 'A sub declared with the bare :ScriptFunc attribute registers under its own name',
);

done_testing;
