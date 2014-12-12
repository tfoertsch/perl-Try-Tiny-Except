requires 'perl', '5.010';
requires 'Try::Tiny', '0.22';

on test => sub {
    requires 'CGI::Compile', '0.17';
    requires 'Sub::Name', '0';
    requires 'Capture::Tiny', '0.12';
};
