#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <platewell_id_file> <platewell_outputfile>";
}

open(PLATE_WELL,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";
  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=magic.fulengen.net",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $platewell=<PLATE_WELL>)
{
  chomp($platewell);
  
  my $sth = $dbh->prepare("select assembly,forward_primer,reverse_primer,reverse_adapter,assembled from _ll_assembly,_ll_platewell where _ll_platewell.sn=_ll_assembly.sn and _ll_platewell.platewell=\'$platewell\' limit 1");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {
	        my $assembly=$ref->{'assembly'};
	        my $forward_primer=$ref->{'forward_primer'};
	        my $reverse_primer=$ref->{'reverse_primer'};
	        my $reverse_adapter=$ref->{'reverse_adapter'};
	        my $assembled=$ref->{'assembled'};
	        my $sub_adp=substr $reverse_adapter,0,3;
	        print RESULT $platewell,"\t","ATG",$forward_primer,$assembly,$reverse_primer,$sub_adp,"\t",$assembled,"\n";
	    }
  }
  else
  {
        
         print RESULT $platewell,"\t","-","\t","-","\n";
        
  }
    
  $sth->finish();
}

close PLATE_WELL;
close RESULT;

  

  # Disconnect from the database.
  $dbh->disconnect();