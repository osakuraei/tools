#!/opt/ActivePerl-5.16/bin/perl
  use strict;
  use DBI();
if (@ARGV!=3)
{
    die "please check the parameters <primer_id_file/GC_ID_FILE> <Vector> <outputfile>";
}

open(PRIMER_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS primer_id_file File";
open(RESULT,">>",$ARGV[2]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";
my $clone_type=uc($ARGV[1]);

  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=magic.fulengen.net",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});

    while (my $primer_id=<PRIMER_ID>)
    {
      chomp($primer_id);
      my $sth ="";
      if ($primer_id=~/^GC-/i)
      {
	$sth = $dbh->prepare("select b.gene_id,a.sn,a.primer_id,a.plasmid_place,a.plate_well,a.stock_place,a.vector from _cs_transfer_result a,_glz_design_primer b where (a.vector like '%$clone_type%')and a.primer_id=b.primerid and b.gene_id=\'$primer_id\' limit 1");
      }
      
      else
      {
	$sth = $dbh->prepare("select b.gene_id,a.sn,a.primer_id,a.plasmid_place,a.plate_well,a.stock_place,a.vector from _cs_transfer_result a,_glz_design_primer b where (vector like '%$clone_type%')and a.primer_id=\'$primer_id\'and a.primer_id=b.primerid limit 1");
      }
      $sth->execute();
      my $ref;
      my $numRows = $sth->rows;
      if($numRows>0)
      {
	      while ($ref = $sth->fetchrow_hashref())
		{   
		    print RESULT $ref->{'gene_id'},"\t",$ref->{'primer_id'},"\t",$ref->{'sn'},"\t",$ref->{'plasmid_place'},"\t",$ref->{'plate_well'},"\t",$ref->{'stock_place'},"\t",$ref->{'vector'},"\n";
		}
      }
       else
       {
	    
		    print RESULT $primer_id,"\t","-","\t","-","\t","-","\t","-","\t","-","\t","-","\n";
	    
       }
	
      $sth->finish();
    }




close PRIMER_ID;
close RESULT;

$dbh->disconnect();

