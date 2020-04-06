# Module for processing hour scripts.
package horas::Scripting;
use strict;
use warnings;
use Carp;
use Attribute::Handlers;

BEGIN {
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
my @deferred_functions;

#*** sub register_script_function($function_name, $code_ref, %params)
# Registers a new script function (the sort invoked with & in the scripts).
# $function_name is the name to be used in scripts in order to invoke it, and
# $code_ref is a reference to the Perl sub that should handle it. By default
# the handler for the long form is set; if $params{short} is true, the short
# handler is set instead.
#
# This subroutine is intended to be called in response to the presence of an
# appropriate attribute on some other subroutine.
sub register_script_function {
  my ($function_name, $code_ref, %params) = @_;
  $script_functions{$function_name}{$params{'short'} ? 'shortfunc' : 'func'} = $code_ref;
}

#*** sub register_deferred_functions
# Attempts to register any remaining deferred functions. This only happens on
# older perls; see script_attr_handler for the details. Returns the count of
# new functions registered.
sub register_deferred_functions {
  my @still_deferred;

  foreach my $deferred_ref (@deferred_functions) {

    # Register the function if we can find its glob now.
    if (my $glob = Attribute::Handlers::findsym(@{$deferred_ref}{'package', 'code'}, 'CODE')) {
      register_script_function(*{$glob}{NAME}, $deferred_ref->{code}, %{$deferred_ref->{params}});
    } else {
      push @still_deferred, $deferred_ref;
    }
  }
  my $count = @deferred_functions - @still_deferred;
  @deferred_functions = @still_deferred;
  return $count;
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
# Attribute::Handlers has already run by then.)
sub UNIVERSAL::ScriptFunc : ATTR(CODE,BEGIN) {&script_attr_handler}
sub UNIVERSAL::ScriptShortFunc : ATTR(CODE,BEGIN) {&script_attr_handler}

sub script_attr_handler {
  my ($pkg, $symbol_ref, $code_ref, $attr, $name_override) = @_;
  my %params = ('short' => ($attr eq 'ScriptShortFunc'));

  if ($name_override || ref($symbol_ref) eq 'GLOB') {
    register_script_function($name_override || *{$symbol_ref}{NAME}, $code_ref, %params);
  } else {

    # Older perls fire the attribute handler before the sub is placed in the
    # symbol table, with the effect that we can't get the sub's name yet. Defer
    # the actual registration till later.
    push @deferred_functions, {
      'package' => $pkg,
      'code' => $code_ref,
      'params' => \%params
      };
  }
}

#*** sub dispatch_script_function($function_name, @args)
# Calls the script function $function_name with arguments @args.
#
# Calling a function that hasn't been registered is a fatal error. The @args
# are passed exactly as they are; it's the caller's job to make sure that any
# extra implicit parameters are in here.
#
# Returns whatever the handling subroutine returns.
sub dispatch_script_function {
  my ($function_name, @args) = @_;

  if (!exists($script_functions{$function_name})) {

    # No handler found. If there are any deferred functions still to be
    # registered, do so and then try again.
    if (register_deferred_functions()) {
      return &dispatch_script_function;
    }
    croak "Invalid script function $function_name.";
  }
  my $code_ref = $script_functions{$function_name}{'func'};
  croak "No handler registered for $function_name."
    unless ref($code_ref) eq 'CODE';
  return $code_ref->(@args);
}

#*** sub parse_script_arguments($list_str)
# Returns a list of arguments represented by a string from a script function
# call. The syntax is very crude: only numeric literals and single-quoted
# strings (with no escaping functionality) are supported.
sub parse_script_arguments {
  my $list_str = shift;
  return () unless defined($list_str);

  # Extract individual parameters from the argument string.
  return map { /'(.*)'|(-?\d+)/; $1 || $2 }    # Match string or number.
    split /,(?=(?:[^']|'[^']*')*$)/,           # Comma followed by balanced quotes.
    $list_str;
}
1;
