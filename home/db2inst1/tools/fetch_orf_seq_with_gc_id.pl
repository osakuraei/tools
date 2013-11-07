#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <gc_id_file> <orf_outputfile>";
}

open(GC_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";
  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $gc_id=<GC_ID>)
{
  chomp($gc_id);
  
  my $sth = $dbh->prepare("select gene_id,cds_start,cds_stop,seq from geneseq where gene_id=\'$gc_id\' limit 1");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
	{
	  while (my $ref = $sth->fetchrow_hashref())
	    {
	        my $cds_start=$ref->{'cds_start'};
	        my $cds_stop=$ref->{'cds_stop'};
	        my $seq=$ref->{'seq'};
	        my $orf_len=abs($cds_stop-$cds_start)+1;
	        my $orf_offset=$cds_start-1;
	        my $orf_seq=substr $seq,$orf_offset,$orf_len;
	        print RESULT $gc_id,"\t",$orf_seq,"\n";
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