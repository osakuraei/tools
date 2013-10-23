use strict;
if(@ARGV!=2)
{
	die "please check your <GENE_SYMOBOL_INPUTFILE> <GENE_ID_OUTPUTFILE>\n";
}

open(SYM_IN_FILE,"<",$ARGV[0]) or die "please check your input file\n";
open(CONFIG_IN_FILE,"<","/home/db2inst1/tools/symbol_gene_id_config") or die "please check your CONFIG file\n";
open(OUT_FILE,">",$ARGV[1]) or die "please check your output file\n";
my %hash=();
while (my $line=<CONFIG_IN_FILE>) {
	chomp($line);
	my @arr=split /	/,$line;
	my @new_arr=grep{$_ ne ""}@arr;
	foreach my $field (1..$#new_arr)
		{
				my $FIELD=uc($new_arr[$field]);
				$hash{$FIELD}=$new_arr[0];
		}
	
}


while(my $line=<SYM_IN_FILE>)
{
	chomp($line);
	my $LINE=uc($line);
	if(exists $hash{$LINE})
	{
		my $gene_id=$hash{$LINE};
		print OUT_FILE $line,"\t",$gene_id,"\n";
	}
	else
	{
		print OUT_FILE $line,"\t","-","\n";
	}
}

close SYM_IN_FILE;
close CONFIG_IN_FILE;
close OUT_FILE;