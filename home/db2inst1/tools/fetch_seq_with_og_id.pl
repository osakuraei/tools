#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <OG_ID> <OG_SEQ_FILE>";
}

open(OG_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS OG_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";


  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $og_id=<OG_ID>)
{
  chomp($og_id);
  my $sth = $dbh->prepare("SELECT ORF_seq from _glz_ORFeome_v81_seq where product_id_en=\'$og_id\' limit 1");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {
	        my $seq=$ref->{'ORF_seq'};
	        print RESULT $og_id,"\t",$seq,"\n";
	    }
  }
  else
  {     
         print RESULT $og_id,"\t","-","\n";     
  }
   
  $sth->finish();

}

close OG_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();