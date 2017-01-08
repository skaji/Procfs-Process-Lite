#!/usr/bin/env perl
use strict;
use warnings;
use lib "../lib", "lib";
use Procfs::Process::Lite;
use DDP;

my $pid = shift || $$;
my $p = Procfs::Process::Lite->new($pid);

p $p;
