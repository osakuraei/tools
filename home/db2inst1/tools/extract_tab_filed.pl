#!/opt/ActivePerl-5.16/bin/perl
use strict;
if(@ARGV!=2)
{
	die "please check your INPUTFILE OUTPUTFILE\n";
	}
open(IN_FILE,"<",$ARGV[0]) or die "please check your input file\n";
open(OUT_FILE,">>",$ARGV[1]) or die "please check your output file\n";
while(my $line=<IN_FILE>)
{
	chomp($line);
	my @fileds=split /	/,$line;
	if($fileds[0] eq "9")
	{
		print OUT_FILE $fileds[0],"\t",$fileds[1],"\t",$fileds[2],"\t",$fileds[3],"\t",$fileds[4],"\t",$fileds[15],"\n";
	}
}