package Procfs::Process::Lite;
use strict;
use warnings;

our $VERSION = '0.001';
use POSIX ();

use constant CLK_TCK  => POSIX::sysconf(POSIX::_SC_CLK_TCK());
use constant PAGESIZE => POSIX::sysconf(POSIX::_SC_PAGESIZE());

sub new {
    my ($class, $pid) = @_;
    my $self = bless { pid => $pid }, $class;
    $self->_init;
}

# ps -p $$ -o lstart=
# perl -MHTTP::Date -e 'my $str = `ps -p $$ -o lstart=`; chomp $str; print str2time($str)'
sub starttime {
    my $self = shift;
    my $starttime = sprintf "%d", $self->{stat}{starttime} / CLK_TCK;
    my $btime = $self->{_stat}{btime}[0];
    $btime + $starttime;
}

sub rss {
    my $self = shift;
    $self->{stat}{rss} * PAGESIZE;
}

# ps xao pid,ppid,pgid,sid,stat,comm
sub is_session_leader {
    my $self = shift;
    $self->{stat}{pid} == $self->{stat}{session};
}

my @field = qw(
    cmdline
    cwd
    exe
    fd
    limits
    root
    stat
    status
    _stat
);

sub _init {
    my $self = shift;
    local $!;
    for my $field (@field) {
        my $method = "_init_$field";
        $self->{$field} = $self->$method;
    }
    $self;
}

sub _init__stat {
    my $self = shift;
    open my $fh, "<", "/proc/stat" or return;
    my @line = <$fh>;
    close $fh;
    undef $fh;
    my %_stat;
    for my $line (@line) {
        chomp $line;
        my ($field, @value) = split /\s+/, $line;
        $_stat{$field} = \@value;
    }
    \%_stat;
}

sub _init_cmdline {
    my $self = shift;
    open my $fh, "<", "/proc/$self->{pid}/cmdline" or return;
    my $line = do { local $/; <$fh> };
    close $fh;
    undef $fh;
    [ split /\0/, $line ];
}

sub _init_fd {
    my $self = shift;
    my $pid = $self->{pid};
    opendir my $dh, "/proc/$pid/fd" or return;
    my @fd = grep { !/^\.{1,2}$/ } readdir $dh;
    closedir $dh;
    my %fd = map {
        my $fd = $_;
        my $link = readlink "/proc/$pid/fd/$fd";
        defined $link ? ($fd, $link) : ();
    } @fd;
    \%fd;
}

for my $field (qw(root cwd exe)) {
    my $method = "_init_$field";
    no strict 'refs';
    *$method = sub {
        my $self = shift;
        readlink "/proc/$self->{pid}/$field";
    };
}

sub _init_status {
    my $self = shift;
    open my $fh, "<", "/proc/$self->{pid}/status" or return;
    my @line = <$fh>;
    close $fh;
    undef $fh;
    my %status;
    for my $line (@line) {
        chomp $line;
        my ($field, $value) = split /\s+/, $line, 2;
        $field =~ s/:$//;
        $status{$field} = $value;
    }
    \%status;
}

sub _init_stat {
    my $self = shift;
    open my $fh, "<", "/proc/$self->{pid}/stat" or return;
    my $line = do { local $/; <$fh> };
    chomp $line;
    close $fh;
    undef $fh;
    my @part = split / /, $line;
    my @found = grep { $part[$_] =~ /\)$/ } 0..$#part;
    if ($found[-1] != 1) {
        splice @part, 1, $found[-1], join(' ', @part[1 .. $found[-1]]);
    }
    $part[1] =~ s/^\(//; $part[1] =~ s/\)$//;

    my @field = qw(
        pid
        comm
        state
        ppid
        pgrp
        session
        tty_nr
        tpgid
        flags
        minflt
        cminflt
        majflt
        cmajflt
        utime
        stime
        cutime
        cstime
        priority
        nice
        num_threads
        itrealvalue
        starttime
        vsize
        rss
        rsslim
        startcode
        endcode
        startstack
        kstkesp
        kstkeip
        signal
        blocked
        sigignore
        sigcatch
        wchan
        nswap
        cnswap
        exit_signal
        processor
        rt_priority
        policy
        delayacct_blkio_ticks
        guest_time
        cguest_time
        start_data
        end_data
        start_brk
        arg_start
        arg_end
        env_start
        env_end
        exit_code
    );
    +{ map {; ($field[$_], $part[$_]) } 0..$#part };
}

sub _init_limits {
    my $self = shift;
    my $pid = $self->{pid};
    open my $fh, "<", "/proc/$pid/limits" or return;
    my @line = <$fh>;
    close $fh;
    undef $fh;
    my $normal = sub { local $_ = shift; chomp; s/ /_/g; lc $_ };
    my @head = map { $normal->($_) } split /\s{2,}/, shift @line;
    my %limit;
    for my $line (@line) {
        my @value = map { $normal->($_) } split /\s{2,}/, $line;
        $limit{$value[0]} = +{ map {; ($head[$_], $value[$_]) } 1..$#value };
    }
    \%limit;
}

1;
__END__

=encoding utf-8

=head1 NAME

Procfs::Process::Lite - read /proc/PID

=head1 SYNOPSIS

  use Procfs::Process::Lite;

  my $proc = Procfs::Process::Lite->new($$);

=head1 SEE ALSO

L<proc(5)|http://man7.org/linux/man-pages/man5/proc.5.html>

http://d.hatena.ne.jp/naoya/20080727/1217119867

http://d.hatena.ne.jp/naoya/20080212/1202830671

=head1 AUTHOR

Shoichi Kaji <skaji@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2017 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
