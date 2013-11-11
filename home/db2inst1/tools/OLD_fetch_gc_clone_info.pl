#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use lib qw(/home/kokia/bioperl-live);
  use DBI();
if (@ARGV!=2)
{
    die "please check the parameters <gene_id_file> <outputfile>\n";
}

open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";

my $rHoHoH_A ={};
my $rHoHoH_B ={};
my $rHoHoH_C ={};
  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $gene_id=<GENE_ID>)
{
  chomp($gene_id);
  
  my $sth = $dbh->prepare("SELECT sn,clone_status FROM _mll_clone_status where gene_id=\'$gene_id\' order by mod_date desc limit 1");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {
		$rHoHoH_A->{$gene_id}={
				       SN=>$ref->{'sn'},
				       STATUS=>$ref->{'clone_status'},
				       SEQ=>"-",
				       ASSEMBLY=>"-",
				       AVI=>"-"
				     };
	    }
  }
   else
   {
	 		$rHoHoH_A->{$gene_id}={
				       SN=>"-",
				       STATUS=>"-",
				       SEQ=>"-",
				       ASSEMBLY=>"-",
				       AVI=>"-"
				     };
        
   }
    
  
  my $sth2 = $dbh->prepare("SELECT sn,status FROM _mll_cp_clone where new_gene_id=\'$gene_id\' order by mod_date desc limit 1");
  $sth2->execute();
  my $numRows = $sth2->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth2->fetchrow_hashref())
	    {
		$rHoHoH_B->{$gene_id}={
				        SN=>$ref->{'sn'},
				        STATUS=>$ref->{'status'},
					SEQ=>"-",
					ASSEMBLY=>"-",
					AVI=>"-"
				      };
	    
	    }
  }
   else
   {

	 		$rHoHoH_B->{$gene_id}={
						SN=>"-",
						STATUS=>"-",
						SEQ=>"-",
						ASSEMBLY=>"-",
						AVI=>"-"
					      };
        
   }
    
  $sth->finish();
  $sth2->finish();
}

for my $key ( sort keys %$rHoHoH_A)
{
    my $sn_a=$rHoHoH_A->{$key}->{SN};
    my $status_a=uc($rHoHoH_A->{$key}->{STATUS});
    my $sn_b=$rHoHoH_B->{$key}->{SN};
    my $status_b=uc($rHoHoH_B->{$key}->{STATUS});
    if (($status_a eq "AD") or ($status_a eq "AD&AI") or ($status_a eq "AP") or ($status_a eq "AI&AD") or ($status_a eq "AI") or ($status_a eq "AN") or ($status_a eq "CONSERVED") or ($status_a eq "PM_IN_DB") or ($status_a eq "Y"))
    {
			$rHoHoH_C->{$key}={
						SN=>$sn_a,
						STATUS=>$status_a,
						SEQ=>"-",
						ASSEMBLY=>"-",
						AVI=>"Y"
					    };
    }
    elsif ((($status_a ne "AD") && ($status_a ne "AD&AI") && ($status_a ne "AP") && ($status_a ne "AI&AD") && ($status_a ne "AI") && ($status_a ne "AN") && ($status_a ne "CONSERVED") && ($status_a ne "PM_IN_DB") && ($status_a ne "Y"))&&(($status_b eq "AD")or($status_b eq "AD&AI")or($status_b eq "AD&CF")or($status_b eq "ADAPTOR_WRONG|ORF:Y")or($status_b eq "AI")or ($status_b eq "AI&AD")or ($status_b eq "AP")or ($status_b eq "AP:ORF:Y")or ($status_b eq "CONSERVED")or ($status_b eq "CONSERVED&CF")or ($status_b eq "CONSERVED\@CF")or ($status_b eq "PM_IN_DB")or ($status_b eq "PM_IN_DB&CF")or($status_b eq "Y")  or ($status_b eq "Y\@CF")))
    {
				$rHoHoH_C->{$key}={
						    SN=>$sn_b,
						    STATUS=>$status_b,
						    SEQ=>"-",
						    ASSEMBLY=>"-",
						    AVI=>"Y"
						    };
    }
    else
    {
				$rHoHoH_C->{$key}={
						    SN=>$sn_a,
						    STATUS=>$status_a,
						    SEQ=>"-",
						    ASSEMBLY=>"-",
						    AVI=>"-"
						    };
    }
    
    
}

for my $key ( sort keys %$rHoHoH_C)
{
    my $sn_c=$rHoHoH_C->{$key}->{SN};
    if ($sn_c ne "-")
    {
	my $sth3 = $dbh->prepare("select assembly,forward_primer,reverse_primer,reverse_adapter,assembled from _ll_assembly where sn=\'$sn_c\' limit 1");
	$sth3->execute();
	my $numRows = $sth3->rows;
	if($numRows>0)
	{
		while (my $ref = $sth3->fetchrow_hashref())
		  {
		      my $assembly=$ref->{'assembly'};
		      my $forward_primer=$ref->{'forward_primer'};
		      my $reverse_primer=$ref->{'reverse_primer'};
		      my $reverse_adapter=$ref->{'reverse_adapter'};
		      my $assembled=$ref->{'assembled'};
		      my $sub_adp=substr $reverse_adapter,0,3;
		      my $seq_assembly="ATG".$forward_primer.$assembly.$reverse_primer.$sub_adp;
		      $rHoHoH_C->{$key}->{SEQ}=$seq_assembly;
		      $rHoHoH_C->{$key}->{ASSEMBLY}=$assembled;
		      
		  }
	}
	else
	{
	      
		      $rHoHoH_C->{$key}->{SEQ}="-";
		      $rHoHoH_C->{$key}->{ASSEMBLY}="-";
	      
	}
	$sth3->finish();
    }
    else
    {
		      $rHoHoH_C->{$key}->{SEQ}="-";
		      $rHoHoH_C->{$key}->{ASSEMBLY}="-";
    }

}

for my $key ( sort keys %$rHoHoH_C)
{
    my $sn_c=$rHoHoH_C->{$key}->{SN};
    my $status_c=$rHoHoH_C->{$key}->{STATUS};
    my $seq_c=$rHoHoH_C->{$key}->{SEQ};
    my $assembled=$rHoHoH_C->{$key}->{ASSEMBLY};
    my $avi=$rHoHoH_C->{$key}->{AVI};
    print RESULT $key,"\t",$sn_c,"\t",$status_c,"\t",$seq_c,"\t",$assembled,"\t",$avi,"\n";
}

close GENE_ID;
close RESULT;
  

  # Disconnect from the database.
  $dbh->disconnect();