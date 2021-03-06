#!/opt/ActivePerl-5.16/bin/perl
  use strict;
  use lib qw(/home/kokia/bioperl-live);
  use List::MoreUtils qw(uniq);
  use DBI();
if (@ARGV!=3)
{
    die "please check the parameters <primer_id_file/GC_ID_FILE> <Vector> <outputfile>";
}

open(PRIMER_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS primer_id_file File";
open(RESULT,">>",$ARGV[2]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";
my $clone_type=uc($ARGV[1]);

  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});

    while (my $primer_id=<PRIMER_ID>)
    {
      chomp($primer_id);
      my $sth ="";
      my $platewell_ary_ref;
      if ($primer_id=~/^GC-/i)
      {
	my $sql1="select b.gene_id,a.sn,a.primer_id,a.plasmid_place,a.plate_well,a.stock_place,a.vector from _cs_transfer_result a,_glz_design_primer b where (a.vector like '%$clone_type%')and a.primer_id=b.primerid and b.gene_id=\'$primer_id\'";
	$sth = $dbh->prepare( $sql1);
	 $platewell_ary_ref = $dbh->selectcol_arrayref($sql1,{ Columns=>[5]});
      }
      
      else
      {
	my $sql2="select b.gene_id,a.sn,a.primer_id,a.plasmid_place,a.plate_well,a.stock_place,a.vector from _cs_transfer_result a,_glz_design_primer b where (vector like '%$clone_type%')and a.primer_id=\'$primer_id\'and a.primer_id=b.primerid";
	$sth = $dbh->prepare($sql2);
	$platewell_ary_ref = $dbh->selectcol_arrayref($sql2,{ Columns=>[5]});
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


