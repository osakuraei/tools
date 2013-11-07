#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <primer_id_file> <platewell_outputfile>";
}

open(PRIMER_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS primer_id_file File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";
  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $primer_id=<PRIMER_ID>)
{
  chomp($primer_id);
  
  my $sth = $dbh->prepare("select stock_place,plasmid_place,primer_id,plate_well,vector from _cs_transfer_result where primer_id=\'$primer_id\' and  (vector like '%M13%')");
  $sth->execute();
  my $numRows = $sth->rows;
	  if($numRows>0)
	  {
		  while (my $ref = $sth->fetchrow_hashref())
		    {      
		        my $primer_id=$ref->{'primer_id'};
		        my $stock_place=$ref->{'stock_place'};
		        my $plasmid_place=$ref->{'plasmid_place'};
		        my $plate_well=$ref->{'plate_well'};
		        my $vector=$ref->{'vector'};
		        print RESULT $primer_id,"\t",$stock_place,"\t",$plasmid_place,"\t",$plate_well,"\t",$vector,"\n";
		    }
	  }
    else
    {
        
        	print RESULT $primer_id,"\t","-","\t","-","\t","-","\t","-","\n";
        
    }
       
  $sth->finish();
}

close PRIMER_ID;
close RESULT;

  

  # Disconnect from the database.
  $dbh->disconnect();