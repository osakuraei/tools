#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <NCBI_gene_id_file> <outputfile>";
}

open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS NCBI_GENE_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";

  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $gene_id=<GENE_ID>)
{
  chomp($gene_id);
  my $sth = $dbh->prepare("SELECT distinct geneid,RNA from _glz_gene2accession where geneid=\"$gene_id\" and RNA like \"NM%\"");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {  
	        print RESULT $gene_id,"\t",$ref->{'RNA'},"\n";
	    }
  }
  else
  {
          print RESULT $gene_id,"\t","-","\n";   
  }
    
  $sth->finish();
}

close GENE_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();