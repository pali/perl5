#!./perl -- -*- mode: cperl; cperl-indent-level: 4 -*-

BEGIN {
    chdir 't' if -d 't';
    @INC = qw(. ../lib);
    require Config; import Config;
    if ($^O eq 'VMS') {
	print "1..0 # skip on $^O, no piped open\n";
        exit 0;
    }
    $ENV{PERL5LIB} = '../lib';    # so children will see it too
    require 'test.pl';
}

use strict;

$| = 1;

my @prgs;

{
    local $/;
    @prgs = split "########\n", <DATA>;
    close DATA;
}

plan tests => scalar @prgs;

require "dumpvar.pl";

END { 1 while unlink "de0.out" }

$ENV{PERLDB_OPTS} = "TTY=0";
my ($ornament1, $ornament2);
my $Perl = which_perl();
for (@prgs){
    my($prog, $expected) = split(/\nEXPECT\n?/, $_);
    open my $debug, qq{| $Perl "-de0" 2>de0.out} or die;
    print $debug $prog, "\n";
    close $debug;
    my $got = do { local $/; open my $fh, "de0.out" or die; <$fh> };
    SKIP: {
	skip("failed to read debugger", 1) unless defined $got && length $got;
	$got =~ s/^\s*Loading.*\r?\n?Editor.*\r?\n?\r?\n?Enter.*\r?\n?\r?\n?main::\(-e:1\):\s+0\r?\n?//;
	unless (defined $ornament1) {
	    $got =~ s/^\s*Loading.*\r?\n?Editor.*\r?\n?\r?\n?Enter.*\r?\n?\r?\n?main::\(-e:1\):\s+0\r?\n?//;
	    ($ornament1,$ornament2) = $got =~
		/(.*?)0\s+'reserved example for calibrating the ornaments'\r?\n?(.*)/
	    }
	$got =~ s/^\Q$ornament1\E//;
	$got =~ s/\Q$ornament2\E\z//;
	like($got, qr:$expected:i, $prog);
    }
}

__END__
x "reserved example for calibrating the ornaments"
EXPECT
0  'reserved example for calibrating the ornaments'
########
x "foo"
EXPECT
0  'foo'
########
x "\x{100}"
EXPECT
0  '\\x\{0100\}'
########
x *a
EXPECT
0  \*main::a
########
x 1..3
EXPECT
0  1
1  2
2  3
########
x +{1..4}
EXPECT
0\s+HASH\(0x[0-9a-f]+\)
\s+1 => 2
\s+3 => 4
########
