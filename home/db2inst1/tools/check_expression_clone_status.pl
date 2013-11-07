#!/opt/ActivePerl-5.16/bin/perl
  use strict;
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

sub check_avi
{
    
    my $platewell=shift @_;
    chomp($platewell);
    my $avi_hash={};
  my $sth = $dbh->prepare("select assembly,forward_primer,reverse_primer,reverse_adapter,assembled from _ll_assembly,_ll_platewell where _ll_platewell.sn=_ll_assembly.sn and _ll_platewell.platewell=\'$platewell\' limit 1");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {
	        my $assembly=$ref->{'assembly'};
	        my $forward_primer=$ref->{'forward_primer'};
	        my $reverse_primer=$ref->{'reverse_primer'};
	        my $reverse_adapter=$ref->{'reverse_adapter'};
	        my $assembled=$ref->{'assembled'};
	        my $sub_adp=substr $reverse_adapter,0,3;
		my $avi="Y";
		if (($assembled eq "0") or($assembled eq "8")) {
		    $avi="N";
		}
		my $seq_orf="ATG".$forward_primer.$assembly.$reverse_primer.$sub_adp;
	        print RESULT $platewell,"\t",$seq_orf,"\t",$avi,"\t",$assembled,"\n";
		$avi_hash->{$platewell}={ORF=>$seq_orf,
					 AVI=>$avi,
					 ASE=>$assembled};
		
	    }
  }
  else
  {     
  }
    
  $sth->finish();
}

