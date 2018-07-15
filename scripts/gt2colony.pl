#!/usr/bin/env perl
# written by E Meyer, eli.meyer@science.oregonstate.edu
# distributed without any guarantees or restrictions

# -- check arguments and print usage statement
$scriptname=$0; $scriptname =~ s/.+\///g;
$usage = <<USAGE;
Converts a genotype matrix (loci x samples) into the appropriate input format for COLONY.
Usage: $scriptname -i input -o output
Required arguments:
	-i input	tab-delimited genotype matrix, with rows=loci and columns=samples.
                	First two columns indicate tag and position respectively.
                	This format is the output from CallGenotypes.pl.
	-o output	a name for the output file. COLONY input format.
USAGE

# -- module and executable dependencies
$mod1="Getopt::Std";
unless(eval("require $mod1")) {print "$mod1 not found. Exiting\n"; exit;}
use Getopt::Std;

# get variables from input
getopts('i:o:h');	# in this example a is required, b is optional, h is help
if (!$opt_i || !$opt_o || $opt_h) {print "\n", "-"x60, "\n", $scriptname, "\n", $usage, "-"x60, "\n\n"; exit;}

open(IN, $opt_i);
while(<IN>)
	{
	chomp;
	$rowcount++;
	if ($rowcount==1)
		{
		@noma = split("\t", $_);
		$nom = @noma;
		@noma = @noma[2..$nom];
		next;
		}
	@cols = split("\t", $_);
	$nom = @cols;
	$locname = $cols[0]."-".$cols[1];
	$loch{$rowcount-1} = $locname;
	for ($a=2; $a<$nom; $a++)
		{
		$gh{$noma[$a-2]}{$rowcount-1} = $cols[$a];
		}
	}

open(OUT, ">$outfile");
print OUT "SampleID\t";
foreach $s (sort{$a<=>$b}(keys(%loch))) {print OUT $loch{$s}, "-1\t", $loch{$s}, "-2\t";}
print OUT "\n";

foreach $s (sort(keys(%gh)))
	{
	%sh = %{$gh{$s}};
	print OUT $s,"\t";
	for ($b=1; $b<$rowcount; $b++)
		{
		$gi = $sh{$b};
		if ($gi eq 0)				# missing data
			{
			print OUT "0\t0\t";
			next;
			}
		elsif ($gi !~ /\s/)			#homozygous
			{
			print OUT $gi, "\t", $gi, "\t";
			next;
			}				
		elsif ($gi =~ /\s/)			#heterozygous
			{
			@alla = split(" ", $gi);
			print OUT $alla[0], "\t", $alla[1], "\t";
			next;
			}
		}
	print OUT "\n";
	}
