#!/usr/bin/perl
use strict;
use warnings;

# Preload DivinumOfficium modules (caches will be shared)
use lib '/var/www/web/cgi-bin';
use DivinumOfficium::Directorium;
use DivinumOfficium::LanguageTextTools;
use DivinumOfficium::FileIO;
use DivinumOfficium::Date;
use DivinumOfficium::Main;
use DivinumOfficium::Scripting;
use DivinumOfficium::RunTimeOptions;

# Preload CGI and standard modules
use CGI ();
use CGI::Cookie ();
use POSIX ();
use Time::Local ();
use File::Basename ();
use FindBin ();

# Fix FindBin for mod_perl: set $Bin based on actual script location before each request
use DivinumOfficium::FindBinFix ();

# Preload script files that define ScriptFunc functions (required for mod_perl attribute handling)
{
    package main;
    require '/var/www/web/cgi-bin/horas/horasscripts.pl';
    require '/var/www/web/cgi-bin/horas/specmatins.pl';
    require '/var/www/web/cgi-bin/horas/altovadum.pl';
    require '/var/www/web/cgi-bin/missa/propers.pl';
}

1;
