requires 'Plack';
requires 'Starman';
requires 'Plack::App::CGIBin';
requires 'CGI::Compile';
requires 'CGI::Emulate::PSGI';
requires 'CGI::Session';
requires 'CGI';
requires 'Algorithm::Diff';
requires 'Date::Calc';
requires 'Date::Format';
requires 'URI';
requires 'URL::Encode';

on 'develop' => sub {
  requires 'Perl::Tidy';
};

