[![Build Status](https://travis-ci.org/tfoertsch/perl-Try-Tiny-Except.svg?branch=master)](https://travis-ci.org/tfoertsch/perl-Try-Tiny-Except)
[![Coverage Status](https://coveralls.io/repos/tfoertsch/perl-Try-Tiny-Except/badge.png?branch=master)](https://coveralls.io/r/tfoertsch/perl-Try-Tiny-Except?branch=master)

# NAME

Try::Tiny::Except - a thin wrapper around Try::Tiny

# SYNOPSIS

As early as possible (startup code):

    use Try::Tiny::Except ();

In normal code:

    use Try::Tiny;

Then set (or localize)

    $Try::Tiny::Except::always_propagate=sub {
      /ALARM/;                     # or whatever
    };

to have exceptions that contain `ALARM` propgate through every `catch`
block. `finally` blocks are still called though.

# DESCRIPTION

[Try::Tiny](https://metacpan.org/pod/Try::Tiny) works great in most situations. However, in sometimes you
might want a certain exception being propagated always without the possibility
to catch it in a `catch` block or to ignore it. For instance [CGI::Compile](https://metacpan.org/pod/CGI::Compile)
or mod\_perl's [ModPerl::Registry](https://metacpan.org/pod/ModPerl::Registry) try to execute perl scripts in a persistent
interpreter. Hence, they have to prevent `exit` being called by the
script. The usual way to achieve that is to turn it into a special exception.
But then you have to inspect all the `eval`s in the code to make them aware
of that special exception. Provided your code does not use plain `eval` but
[Try::Tiny](https://metacpan.org/pod/Try::Tiny) instead, this is where `Try::Tiny::Except` comes to rescue.

`Try::Tiny::Except` can be used in 2 slightly different modes. First, you can
simply replace all `use Try::Tiny` by `use Try::Tiny::Except`. In that case
the `try`, `catch` and `finally` functions provided by
`Try::Tiny::Except` will be used. This is totally fine. To make sure
both modules behave exactly the same, I have copied the test suite from
[Try::Tiny](https://metacpan.org/pod/Try::Tiny) and replaced all occurrences of `use Try::Tiny` by
`use Try::Tiny::Except`. The advantage of this usage is that it is obvious
to the reader which module is used. But it requires code changes.

The other usage mode is to load `Try::Tiny::Except` as early as possible when
the interpreter is started. It loads then [Try::Tiny](https://metacpan.org/pod/Try::Tiny) and overwrites the
`try` function. Later in the code you can either `use Try::Tiny` or
`use Try::Tiny::Except`. Anyway, you'll get the `try` function provided
by `use Try::Tiny::Except`.

## How to make an exception always propagate?

Let's use a real-life example, [CGI::Compile](https://metacpan.org/pod/CGI::Compile). This module overwrites
`exit` with something like this:

    *CORE::GLOBAL::exit=sub {
      die ["EXIT\n", $_[0] || 0];
    };

So, a script performing `exit` is actually throwing an exception
and `$@` becomes an array with 2 elements where the first element is
the string `"EXIT\n"`.

To prevent this exception from ever being catched by a `catch` block or
ignored by a bare `try` block, set `$Try::Tiny::Except::always_propagate`
like this:

    $Try::Tiny::Except::always_propagate=sub {
        ref eq 'ARRAY' and
        @$_==2 and
        $_->[0] eq "EXIT\n";
    };

Now compile and run a script:

    my $code=CGI::Compile->new(return_exit_val=>1)->compile('/path/to/script.pl');
    my $rc=$code->();

If `script.pl` looks like this:

    use Try::Tiny;
    try {exit 19};
    12;

`$rc` will become `19` instead of `12`.

## EXPORT

`try`, `catch` and `finally` are exported by default and on demand.

# SEE ALSO

[Try::Tiny](https://metacpan.org/pod/Try::Tiny)

# AUTHOR

Torsten Förtsch <torsten.foertsch@gmx.net>

# COPYRIGHT AND LICENSE

Copyright (C) 2014 by Torsten Förtsch

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.
