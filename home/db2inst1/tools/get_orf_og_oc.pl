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

my $dbh = DBI->connect("DBI:mysql:database=lims;host=magic.fulengen.net",
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
	        my $sth1 = $dbh->prepare("SELECT ORF_seq  from _glz_ORFeome_seq  where ORFeome_product_id=\'$ORFeome_product_id\' limit 1");
	        $sth1->execute();
	        while (my $ref1 = $sth1->fetchrow_hashref())
	        {
	            my $seq=$ref1->{'ORF_seq'};
	            print RESULT $gene_id,"\t",$ORFeome_product_id,"\t",$seq,"\t","#","\n";
	        }
	        $sth1->finish();
	    }
  }
  else
  {
     print RESULT $gene_id,"\t","-","\t","-","\t","-","\n";
  }
    

  my $sth2 = $dbh->prepare("SELECT  product_id_en FROM  _glz_ORFeome_v81_gene where gene_ID=\'$gene_id\' limit 1");
  $sth2->execute();
  my $numRows = $sth2->rows;
  if($numRows>0)
  {
  	while (my $ref2 = $sth2->fetchrow_hashref())
    {
        my $product_id_en=$ref2->{'product_id_en'};
        my $sth3 = $dbh->prepare("SELECT ORF_seq from _glz_ORFeome_v81_seq where product_id_en=\'$product_id_en\' limit 1");
        $sth3->execute();
        while (my $ref3 = $sth3->fetchrow_hashref())
        {
            my $seq=$ref3->{'ORF_seq'};
            print RESULT1 $gene_id,"\t",$product_id_en,"\t",$seq,"\t","#","\n";
        }
        
        $sth3->finish();
    }
  }
   else
   {
        
       print RESULT1 $gene_id,"\t","-","\t","-","\t","-","\n";
        
   }
    
  $sth->finish();
  
  $sth2->finish();

}

close GENE_ID;
close RESULT;
close RESULT1;
  

  # Disconnect from the database.
  $dbh->disconnect();