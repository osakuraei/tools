#!/opt/ActivePerl-5.16/bin/perl
  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <primer_id_file> <outputfile>";
}

open(PRIMER_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS primer_id_file File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";

  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=magic.fulengen.net",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $primer_id=<PRIMER_ID>)
{
  chomp($primer_id);
  my $sth = $dbh->prepare("select sn,primer_id,plasmid_place,plate_well,stock_place,vector from _cs_transfer_result where (vector like '%M02%')and primer_id=\'$primer_id\' limit 1");
  $sth->execute();
  my $ref;
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while ($ref = $sth->fetchrow_hashref())
	    {   
	        print RESULT $ref->{'primer_id'},"\t",$ref->{'sn'},"\t",$ref->{'plasmid_place'},"\t",$ref->{'plate_well'},"\t",$ref->{'stock_place'},"\t",$ref->{'vector'},"\n";
	    }
  }
   else
   {
        
        	print RESULT $primer_id,"\t","-","\t","-","\t","-","\t","-","\t","-","\n";
        
   }
    
  $sth->finish();
}

close PRIMER_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();