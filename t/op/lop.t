#!./perl

#
# test the logical operators '&&', '||', '!', 'and', 'or', 'not'
#

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
}

print "1..9\n";

my $test = 0;
for my $i (undef, 0 .. 2, "", "0 but true") {
    my $true = 1;
    my $false = 0;
    for my $j (undef, 0 .. 2, "", "0 but true") {
	$true &&= !(
	    ((!$i || !$j) != !($i && $j))
	    or (!($i || $j) != (!$i && !$j))
	    or (!!($i || $j) != !(!$i && !$j))
	    or (!(!$i || !$j) != !!($i && $j))
	);
	$false ||= (
	    ((!$i || !$j) == !!($i && $j))
	    and (!!($i || $j) == (!$i && !$j))
	    and ((!$i || $j) == ($i && !$j))
	    and (($i || !$j) != (!$i && $j))
	);
    }
    if (not $true) {
	print "not ";
    } elsif ($false) {
	print "not ";
    }
    print "ok ", ++$test, "\n";
}

# $test == 6
my $i = 0;
(($i ||= 1) &&= 3) += 4;
print "not " unless $i == 7;
print "ok ", ++$test, "\n";

my ($x, $y) = (1, 8);
$i = !$x || $y;
print "not " unless $i == 8;
print "ok ", ++$test, "\n";

($x, $y) = (0, 9);
$i = !$x && $y;
print "not " unless $i == 9;
print "ok ", ++$test, "\n";
