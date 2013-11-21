use strict;
use lib qw(/home/kokia/bioperl-live);
if(@ARGV!=2)
{
	die "please check your <GENE_SYMOBOL_INPUTFILE> <GENE_ID_OUTPUTFILE>\n";
}

open(SYM_IN_FILE,"<",$ARGV[0]) or die "please check your input file\n";
open(CONFIG_IN_FILE,"<","/home/db2inst1/tools/symbol_gene_id_config") or die "please check your CONFIG file\n";
open(OUT_FILE,">",$ARGV[1]) or die "please check your output file\n";
my %hash=();
while(my $symbol=<SYM_IN_FILE>)
{
	chomp($symbol);
	my $temp_symbol=uc($symbol);
	my $flag=1;
	while (my $line=<CONFIG_IN_FILE>)
	{
		chomp($line);
		my @arr=split /	/,$line;
		my @new_arr=grep{$_ ne ""}@arr;
		foreach my $field (1..$#new_arr)
			{
					my $FIELD=uc($new_arr[$field]);
					if ($temp_symbol eq  $FIELD)
					{
						print OUT_FILE $temp_symbol,"\t",$new_arr[0],"\n";
						$flag=0;
					}					
			}
		
	}
	seek CONFIG_IN_FILE,0,0;
	if ($flag==1)
	{
		print OUT_FILE $temp_symbol,"\t","-","\n";
	}
	
}

close SYM_IN_FILE;
close CONFIG_IN_FILE;
close OUT_FILE;