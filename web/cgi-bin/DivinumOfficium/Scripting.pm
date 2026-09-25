# Module for processing hour scripts.
package DivinumOfficium::Scripting;

use strict;
use warnings;
use Carp;
use Attribute::Handlers;
use Exporter qw(import);

our $VERSION = 1.00;
our @EXPORT_OK = qw(
  dispatch_script_function
  parse_script_arguments
);

use FindBin qw($Bin);
use lib "$Bin/..";
my %script_functions;

#*** sub register_script_function($function_name, $code_ref)
# Registers a new script function (the sort invoked with & in the scripts).
# $function_name is the name to be used in scripts in order to invoke it, and
# $code_ref is a reference to the Perl sub that should handle it.
#
# This subroutine is intended to be called in response to the presence of an
# appropriate attribute on some other subroutine.
sub register_script_function {
  my ($function_name, $code_ref) = @_;
  $script_functions{$function_name} = $code_ref;
}

# Glue between Attribute::Handlers and our scripting mechanism.
#
# ScriptFunc(func_name): registers the sub as a handler for a scripting
#   function with name func_name.
#
# TODO: Having these in UNIVERSAL is heavy-handed. Is there a way to declare
# these in the calling package? (Exporting subsequently is too late, as
# Attribute::Handlers has already run by then.)
sub UNIVERSAL::ScriptFunc : ATTR(CODE,BEGIN) {&script_attr_handler}

sub script_attr_handler {

  #   $pkg,  $symbol_ref, $code_ref, $attr, $name_override
  my (undef, $symbol_ref, $code_ref, undef, $name_override) = @_;

  if ($name_override || ref($symbol_ref) eq 'GLOB') {
    register_script_function($name_override || *{$symbol_ref}{NAME}, $code_ref);
  } else {
    croak "Unexpected script attribute handler state without symbol table entry.";
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
    croak "Invalid script function $function_name.";
  }
  my $code_ref = $script_functions{$function_name};
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
