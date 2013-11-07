#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
if (@ARGV!=3)
{
    die "please check the parameters <gene_id_file> <OC_outputfile1> <OG_outputfile2>";
}

open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";
open(RESULT1,">>",$ARGV[2]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";

  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $gene_id=<GENE_ID>)
{
  chomp($gene_id);
  
  my $sth = $dbh->prepare("SELECT ORFeome_product_id from _glz_ORFeome_gene where gene_id=\'$gene_id\' limit 1");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {
	        my $ORFeome_product_id=$ref->{'ORFeome_product_id'};
		my $checker=&status_checker($ORFeome_product_id);
	        my $sth1 = $dbh->prepare("SELECT ORF_seq  from _glz_ORFeome_seq  where ORFeome_product_id=\'$ORFeome_product_id\' limit 1");
	        $sth1->execute();
	        while (my $ref1 = $sth1->fetchrow_hashref())
	        {
	            my $seq=$ref1->{'ORF_seq'};
	            print RESULT $gene_id,"\t",$ORFeome_product_id,"\t",$seq,"\t","$checker","\n";
	        }
	        $sth1->finish();
	    }
  }
  else
  {
     print RESULT $gene_id,"\t","-","\t","-","\t","N","\n";
  }
    

  my $sth2 = $dbh->prepare("SELECT  product_id_en FROM  _glz_ORFeome_v81_gene where gene_ID=\'$gene_id\' limit 1");
  $sth2->execute();
  my $numRows_og = $sth2->rows;
  if($numRows_og>0)
  {
  	while (my $ref2 = $sth2->fetchrow_hashref())
    {
        my $product_id_en=$ref2->{'product_id_en'};
	my $checker=&status_checker($product_id_en);
        my $sth3 = $dbh->prepare("SELECT ORF_seq from _glz_ORFeome_v81_seq where product_id_en=\'$product_id_en\' limit 1");
        $sth3->execute();
        while (my $ref3 = $sth3->fetchrow_hashref())
        {
            my $seq=$ref3->{'ORF_seq'};
            print RESULT1 $gene_id,"\t",$product_id_en,"\t",$seq,"\t","$checker","\n";
        }
        
        $sth3->finish();
    }
  }
   else
   {
        
       print RESULT1 $gene_id,"\t","-","\t","-","\t","N","\n";
        
   }
    
  $sth->finish();
  
  $sth2->finish();

}

close GENE_ID;
close RESULT;
close RESULT1;
  

  # Disconnect from the database.
  $dbh->disconnect();
  
  
  
sub status_checker
{
    my $template_id=shift @_;
    my $check_stat_sql="SELECT template_id,status,mgc_status,placeno FROM _glz_mgc2gene WHERE template_id='$template_id' limit 1";
    my $check_stat_sth = $dbh->prepare("$check_stat_sql");
    $check_stat_sth->execute();
    my $check_stat_numRows = $check_stat_sth->rows;
    my $checker_stat="TBI";
    if ($check_stat_numRows>0)
    {
        my $s_status="";
        my $c_status="";
        while (my $ref = $check_stat_sth->fetchrow_hashref())
        {                              
            my $status= $ref->{'status'};
            my $mgc_status= $ref->{'mgc_status'};
            
            if ($status eq '1')
            {
            $s_status='available(Old MGC)';
            }
            elsif($status eq '2')
            {
                    $s_status='available(RZPD)';
            }
            elsif($status eq '3')
            {
                    $s_status='available in USA';
            }
            elsif($status eq '4')
            {
                    $s_status='available(Openbiosystem)';
            }
            elsif($status eq '5')
            {
                    $s_status='available(ORFeome)';
            }
            else
            {
                    $s_status='not available';
            }
                                                            
            
            if($mgc_status eq '0')
            {
                    $c_status='NA';
            }
            elsif($mgc_status eq '1')
            {
                    $c_status='OK';
            }
            elsif($mgc_status eq '2')
            {
                    $c_status='PCR negative';
            }
            elsif($mgc_status eq '3')
            {
                    $c_status='SCR negative';
            }
            elsif($mgc_status eq '4')
            {
                    $c_status='QC wrong';
            }
            elsif($mgc_status eq '5')
            {
                    $c_status='Seq wrong';
            }
            elsif($mgc_status eq '6')
            {
                    $c_status='Other gene';
            }
            else
            {
                    $c_status='Problematic';
            }
            
            
            if(($s_status ne "not available")&&(($c_status eq "NA")or($c_status eq "OK")))
            {
                $checker_stat="Y";
            }
            else
            {
               $checker_stat="N";
            }            
        }
    }
    
    $check_stat_sth->finish();
    
    return $checker_stat;
    
}