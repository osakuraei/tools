#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
  use lib qw(/home/kokia/bioperl-live);
  
if (@ARGV!=2)
{
    die "please check the parameters <GC_ID> <Primer_ID>";
}

open(GC_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GC_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";


  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $gc_id=<GC_ID>)
{
	  chomp($gc_id);
	  
	  my $sth = $dbh->prepare("select primerid  from _glz_design_primer  where gene_id=\'$gc_id\' limit 1");
	  $sth->execute();
	  my $numRows = $sth->rows;
	  if($numRows>0)
	  {
		  while (my $ref = $sth->fetchrow_hashref())
		    {
		        my $primerid=$ref->{'primerid'};
		        print RESULT $gc_id,"\t",$primerid,"\n";
		    }
	  }
	  else
	  {
	        
	         print RESULT $gc_id,"\t","-","\n";
	        
	  }
	    
	    
	  $sth->finish();

}

close GC_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();