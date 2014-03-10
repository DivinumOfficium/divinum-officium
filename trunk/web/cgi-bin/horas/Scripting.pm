# Module for processing hour scripts.

package horas::Scripting;

use strict;
use warnings;

use Carp;
use Attribute::Handlers;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(
    dispatch_script_function
    parse_script_arguments);
}

use FindBin qw($Bin);
use lib "$Bin/..";



my %script_functions;

#*** sub register_script_function($function_name, $code_ref, %params)
# Registers a new script function (the sort invoked with & in the scripts).
# $function_name is the name to be used in scripts in order to invoke it, and
# $code_ref is a reference to the Perl sub that should handle it. By default
# the handler for the long form is set; if $params{short} is true, the short
# handler is set instead.
#
# This subroutine is intended to be called in response to the presence of an
# appropriate attribute on some other subroutine.
sub register_script_function
{
  my ($function_name, $code_ref, %params) = @_;

  $script_functions{$function_name}
    {$params{'short'} ? 'shortfunc' : 'func'} = $code_ref;
}


# Glue between Attribute::Handlers and our scripting mechanism. We define two
# attributes:
#
# - ScriptFunc(func_name): registers the sub as a handler for a scripting
#   function with name func_name.
# - ScriptShortFunc(func_name): registers the sub as a handler for the short
#   text of a scripting function.
#
# In both cases, omitting func_name causes the name of the sub to be used. This
# is probably more useful for ScriptFunc than for ScriptShortFunc.
#
# Defining two handlers of the same type (i.e. long or short) for the same
# scripting function results in undefined behaviour.

# TODO: Having these in UNIVERSAL is heavy-handed. Is there a way to declare
# these in the calling package? (Exporting subsequently is too late, as
# Attribute::Handlers has already run by then.) Maybe create these subs
# dynamically in &import?
sub UNIVERSAL::ScriptFunc      : ATTR(CODE,BEGIN) { &script_attr_handler }
sub UNIVERSAL::ScriptShortFunc : ATTR(CODE,BEGIN) { &script_attr_handler }

sub script_attr_handler
{
  my ($attr, $symbol_ref, $code_ref, $name_override) = @_[0,1,2,4];

  register_script_function(
    $name_override || ((ref($symbol_ref) eq 'GLOB') && *{$symbol_ref}{NAME}),
    $code_ref,
    'short' => ($attr eq 'ScriptShortFunc'));
}


#*** sub dispatch_script_function($function_name, @args)
# Calls the script function $function_name with arguments @args.
#
# Calling a function that hasn't been registered is a fatal error. The @args
# are passed exactly as they are; it's the caller's job to make sure that any
# extra implicit parameters are in here.
#
# Returns whatever the handling subroutine returns.
sub dispatch_script_function
{
  my ($function_name, @args) = @_;

  croak "Invalid script function $function_name."
    unless exists($script_functions{$function_name});

  my $code_ref = $script_functions{$function_name}{'func'};

  croak "No handler registered for $function_name."
    unless ref($code_ref) eq 'CODE';

  return $code_ref->(@args);
}

#*** sub parse_script_arguments($list_str)
# Returns a list of arguments represented by a string from a script function
# call. The syntax is very crude: only numeric literals and single-quoted
# strings (with no escaping functionality) are supported.
sub parse_script_arguments
{
  # Extract individual parameters from the argument string.
  return
    map {/'(.*)'|(-?\d+)/; $1 || $2}  # Match string or number.
    split /,(?=(?:[^']|'[^']*')*$)/,  # Comma followed by balanced quotes.
    shift;
}

1;

