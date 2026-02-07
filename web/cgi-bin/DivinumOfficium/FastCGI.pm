#!/usr/bin/perl
use utf8;

package DivinumOfficium::FastCGI;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(reset_request_state);

# Reset all global variables between FastCGI requests
# This ensures request isolation in the persistent interpreter
sub reset_request_state {
    # Reset error/debug state
    $main::error = '';
    $main::debug = '';

    # Reset CGI object
    undef $main::q;

    # Reset script identification (will be set per-request)
    $main::Ck = 0;
    $main::missa = 0;
    $main::NewMass = 0;
    $main::version = '';

    # Reset dayname arrays
    @main::dayname = ();
    @main::tomorrowname = ();

    # Reset winner/commemoratio scalars
    $main::winner = '';
    $main::commemoratio = '';
    $main::scriptura = '';
    $main::commune = '';
    $main::communetype = '';
    $main::rank = '';
    $main::laudes = '';
    $main::vespera = '';
    $main::cvespera = '';
    $main::commemorated = '';
    $main::comrank = 0;
    $main::litaniaflag = 0;
    $main::octavam = '';

    # Reset winner/commemoratio hashes
    %main::winner = ();
    %main::commemoratio = ();
    %main::scriptura = ();
    %main::commune = ();
    %main::winner2 = ();
    %main::commemoratio2 = ();
    %main::commune2 = ();

    # Reset rule variables
    $main::rule = '';
    $main::communerule = '';
    $main::duplex = 0;

    # Reset language/display globals
    $main::lang1 = '';
    $main::lang2 = '';
    $main::langfb = '';
    $main::langc = '';
    $main::expand = '';
    $main::votive = '';
    $main::column = 0;
    $main::local = '';
    %main::translate = ();
    $main::only = 0;

    # Reset request parameters
    $main::command = '';
    $main::browsertime = '';
    $main::buildscript = '';
    $main::searchvalue = '';
    $main::content = '';
    $main::caller = '';
    $main::expandind = 0;
    $main::setupsave = '';
    $main::hora = '';
    $main::expandnum = '';
    $main::plures = '';

    # Reset date variables
    $main::date1 = '';
    $main::dayofweek = 0;
    $main::month = 0;
    $main::day = 0;
    $main::year = 0;

    # Reset psalm counters
    $main::psalmnum1 = 0;
    $main::psalmnum2 = 0;

    # Reset missa-specific variables
    $main::first = '';
    $main::Propers = '';
    $main::missanumber = 1;
    $main::testmode = '';
    $main::rubession = '';
    $main::soession = '';

    # Reset version comparison variables
    $main::version1 = '';
    $main::version2 = '';

    # Reset display variables
    $main::background = '';
    $main::whitebground = 0;
    $main::completed = 0;

    # Reset priest/general settings (will be reloaded from cookies)
    $main::priest = '';
    $main::rubession = '';
    $main::psalmvar = 0;

    return 1;
}

1;
