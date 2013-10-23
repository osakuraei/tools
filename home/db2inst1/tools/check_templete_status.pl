#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <gene_id_file> <outputfile>";
}

open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";

  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=test;host=magic.fulengen.net",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $gene_id=<GENE_ID>)
{
  chomp($gene_id);
  my $sth = $dbh->prepare("SELECT gene_id,template,availability FROM _th_gene2template where gene_id=\'$gene_id\'");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
   {
		  while (my $ref = $sth->fetchrow_hashref())
		    {
		        print RESULT $ref->{'gene_id'},"\t",$ref->{'template'},"\t",$ref->{'availability'},"\n";
		    }
   }
   else
   {  
        		print RESULT $gene_id,"\t","-","\t","-","\n";  
   }
    
  $sth->finish();
}

close GENE_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();