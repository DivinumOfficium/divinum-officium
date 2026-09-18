requires 'Cpanel::JSON::XS', '== 4.51'; # Cpanel::JSON::XS pinned to 4.51 and installed FIRST: the 4.52 upload on CPAN is
                                        # corrupted/truncated (see https://github.com/rurban/Cpanel-JSON-XS/issues/257)
requires 'Plack', '== 1.0050'; # pin Plack to 1.0050 which reverts the breaking return_405 change
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

