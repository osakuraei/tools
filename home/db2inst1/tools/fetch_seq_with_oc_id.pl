#!/opt/ActivePerl-5.16/bin/perl


  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <OC_ID> <OC_SEQ_FILE>";
}

open(OC_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS OG_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";


  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $oc_id=<OC_ID>)
{
	  chomp($oc_id);
	  
	  my $sth = $dbh->prepare("SELECT ORF_seq from _glz_ORFeome_seq where ORFeome_product_id=\'$oc_id\' limit 1");
	  $sth->execute();
	  my $numRows = $sth->rows;
	  if($numRows>0)
	  {
		  while (my $ref = $sth->fetchrow_hashref())
		    {
		        my $seq=$ref->{'ORF_seq'};
		        print RESULT $oc_id,"\t",$seq,"\n";
		    }
	  }
	  else
	  {
	        
	         print RESULT $oc_id,"\t","-","\n";
	        
	  }
	 
	  $sth->finish();

}

close OC_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();