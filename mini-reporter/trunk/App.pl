#!/usr/bin/perl -w

use lib '.';

use strict;

use Shlomif::MiniReporter;

my $webapp = Shlomif::MiniReporter->new();
$webapp->run();

