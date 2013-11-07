#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <GC_ID> <basic_info>";
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
  
  my $sth = $dbh->prepare("select gb_acc,(cds_stop-cds_start+1)as orf_len,gene_symb,LocusID,name from gene where gene_id=\'$gc_id\' limit 1");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {
	        my $acc=$ref->{'gb_acc'};
	        my $orf_len=$ref->{'orf_len'};
	        my $gene_symbol=$ref->{'gene_symb'};
	        my $gene_id=$ref->{'LocusID'};
	        my $name=$ref->{'name'};
	        print RESULT $gc_id,"\t",$acc,"\t",$orf_len,"\t",$gene_symbol,"\t",$gene_id,"\t",$name,"\n";
	    }
  }
    else
    {
        
         print RESULT $gc_id,"\t","-","\t","-","\t","-","\t","-","\t","-","\n";
        
    }
    
    
  $sth->finish();
  


}

close GC_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();