#!/opt/ActivePerl-5.16/bin/perl
  use strict;
  use DBI();
if (@ARGV!=3)
{
    die "please check the parameters <primer_id_file> <vector_Type_file> <outputfile>";
}

open(PRIMER_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS primer_id_file File\n";
open(VECTOR, "<", $ARGV[1]) or die "PLEASE CHECK IF THERE IS VECTOR FILE\n";
open(RESULT,">>",$ARGV[2]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";


  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $clone_type=<VECTOR>)
{
    print $clone_type;
    chomp($clone_type);
    while (my $primer_id=<PRIMER_ID>)
    {
      chomp($primer_id);
      my $sth = $dbh->prepare("select sn,primer_id,plasmid_place,plate_well,stock_place,vector from _cs_transfer_result where (vector like '%$clone_type%')and primer_id=\'$primer_id\'");
      $sth->execute();
      my $ref;
      my $numRows = $sth->rows;
      if($numRows>0)
      {
	      while ($ref = $sth->fetchrow_hashref())
		{   
		    print RESULT $ref->{'primer_id'},"\t",$ref->{'sn'},"\t",$ref->{'plasmid_place'},"\t",$ref->{'plate_well'},"\t",$ref->{'stock_place'},"\t",$ref->{'vector'},"\t",$clone_type,"\n";
		}
      }
       else
       {
	    
		    print RESULT $primer_id,"\t","-","\t","-","\t","-","\t","-","\t","-","\t",$clone_type,"\n";
	    
       }
	
      $sth->finish();
    }
    seek PRIMER_ID, 0, 0;
}
close PRIMER_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();