[![Build Status](https://travis-ci.org/skaji/Procfs-Process-Lite.svg?branch=master)](https://travis-ci.org/skaji/Procfs-Process-Lite)

# NAME

Procfs::Process::Lite - read /proc/PID

# SYNOPSIS

    use Procfs::Process::Lite;

    my $proc = Procfs::Process::Lite->new($$);

# SEE ALSO

[proc(5)](http://man7.org/linux/man-pages/man5/proc.5.html)

http://d.hatena.ne.jp/naoya/20080727/1217119867

http://d.hatena.ne.jp/naoya/20080212/1202830671

# AUTHOR

Shoichi Kaji <skaji@cpan.org>

# COPYRIGHT AND LICENSE

Copyright 2017 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
