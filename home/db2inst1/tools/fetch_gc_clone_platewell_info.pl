#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
  use lib qw(/home/kokia/bioperl-live);
  use Bio::Seq;
  use Bio::SeqIO;
  use Bio::Perl;
  
if (@ARGV!=3)
{
    die "please check the parameters <gc_id_orf_file> <platewell_outputfile> <QA_REPORT>\n";
}
my %hash_hold=();
my %hash_check=();
my $dna_checker={};
my %gc_id_holder=();
my $gc_clone_container={};

my %cf_id_holder=();
my $cf_clone_container={};

open(PLATE_WELL_ORF,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS platewell_orf_file File\n";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE\n";

open(QAREPORT,">>",$ARGV[2]) or die "PLEASE CHECK IF THERE IS A QAREPORT OUTPUTFILE\n";

  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
while (my $line=<PLATE_WELL_ORF>)
{
 
  chomp($line);
  my($platewell, $orf)=split /	/,$line;
  $hash_hold{$platewell}="-";
  my $sql="select sn,pattern, curated,assembly,forward_primer,reverse_primer,reverse_adapter,assembled from _ll_assembly where gene_id='$platewell'";
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {
		my $SN=$ref->{'sn'};
		my $pattern=$ref->{'pattern'};
		my $curated=$ref->{'curated'};
	        my $assembly=$ref->{'assembly'};
		$assembly=~s/-//g;
	        my $forward_primer=$ref->{'forward_primer'};
		$forward_primer=~s/-//g;
	        my $reverse_primer=$ref->{'reverse_primer'};
		$reverse_primer=~s/-//g;
	        my $reverse_adapter=$ref->{'reverse_adapter'};
		$reverse_adapter=~s/-//g;
	        my $assembled=$ref->{'assembled'};
	        my $sub_adp=uc(substr $reverse_adapter,0,3);
		my $seq_orf="ATG".$forward_primer.$assembly.$reverse_primer.$sub_adp;
		my @avi_check_pra=($assembled,$pattern,$seq_orf,$orf,$sub_adp,$curated,$platewell,$SN);
		
		
		my $check_result=&check_avi(\@avi_check_pra);
		my($clone_type,$avi)=@$check_result;
		if ((($clone_type eq "GC") or ($clone_type eq "CF")) and ($avi eq "Y"))
		{
		    print RESULT $platewell,"\t",$SN,"\t",$seq_orf,"\t",$clone_type,"\t",$avi,"\n";
		    if ($clone_type eq "GC")
		    {
			$gc_id_holder{$platewell}="-";
			$gc_clone_container->{$platewell}->{$SN}={SEQ=>$seq_orf,
							      TYPE=>$clone_type,
							      AVI=>$avi};
		    }
		    elsif($clone_type eq "CF")
		    {
			$cf_id_holder{$platewell}="-";
			$cf_clone_container->{$platewell}->{$SN}={SEQ=>$seq_orf,
							      TYPE=>$clone_type,
							      AVI=>$avi};
		    }
		    else
		    {
			
		    }
		    
		    
		    $hash_check{$platewell}="-";
		}

	    }
	   
  }
  else
  {
	$hash_check{$platewell}="-";
        print RESULT $platewell,"\t","-","\t","-","\t","-","\t","-","\n";     
  }
    
  $sth->finish();
}

foreach my $key(sort keys %hash_hold)
{
    if (not exists $hash_check{$key})
    {
	print RESULT $key,"\t","-","\t","-","\t","-","\t","-","\n";
    }	
}

foreach my $key1(sort keys %gc_id_holder)
{
    my $count_p=0;
    my $flag=0;
    my $tmp_count_p=0;
    my $tmp_platewell="";
    my $temp_sn="";
    foreach my $key2(sort keys %{$gc_clone_container->{$key1}} )
    {
	
	$count_p=$dna_checker->{$key1}->{$key2};
	if ($flag==0) {
	    $tmp_count_p=$count_p;
	    $tmp_platewell=$key1;
	    $temp_sn=$key2;
	}
	else
	{
	    if ($count_p<$tmp_count_p)
	    {
		$tmp_platewell=$key1;
		$temp_sn=$key2;
	    }
	    $tmp_count_p=$count_p;
	    
	}
	$flag=1;
	
    }
    print RESULT $tmp_platewell,"\t",$temp_sn,"\t",$gc_clone_container->{$tmp_platewell}->{$temp_sn}->{SEQ},"\t",$gc_clone_container->{$tmp_platewell}->{$temp_sn}->{TYPE},"\t",$gc_clone_container->{$tmp_platewell}->{$temp_sn}->{AVI},"\n";
}


foreach my $key1(sort keys %cf_id_holder)
{
    my $count_p=0;
    my $flag=0;
    my $tmp_count_p=0;
    my $tmp_platewell="";
    my $temp_sn="";
    foreach my $key2(sort keys %{$cf_clone_container->{$key1}} )
    {
	
	$count_p=$dna_checker->{$key1}->{$key2};
	if ($flag==0) {
	    $tmp_count_p=$count_p;
	    $tmp_platewell=$key1;
	    $temp_sn=$key2;
	}
	else
	{
	    if ($count_p<$tmp_count_p)
	    {
		$tmp_platewell=$key1;
		$temp_sn=$key2;
	    }
	    $tmp_count_p=$count_p;
	    
	}
	$flag=1;
	
    }
    print RESULT $tmp_platewell,"\t",$temp_sn,"\t",$cf_clone_container->{$tmp_platewell}->{$temp_sn}->{SEQ},"\t",$cf_clone_container->{$tmp_platewell}->{$temp_sn}->{TYPE},"\t",$cf_clone_container->{$tmp_platewell}->{$temp_sn}->{AVI},"\n";
}


close PLATE_WELL_ORF;
close RESULT;
close QAREPORT;


  

  # Disconnect from the database.
  $dbh->disconnect();
  
  sub check_avi
  {
    
    my $arr=shift @_;
    my ($assembled,$pattern,$seq_orf_o,$orf_o,$sub_adp_hold,$curated,$platewell,$SN)=@$arr;
    my $orf=uc($orf_o);
    my $seq_orf=uc($seq_orf_o);
    my $sub_adp=substr $seq_orf,-3;
    my $platewell_prt="";
    my $std_prt="";

    my $clone_type="";
    my $avi="N";
    if ($sub_adp eq "TAG")
    {
	$clone_type="GC";
    }
    elsif($sub_adp eq "TAC")
    {
	$clone_type="CF";
    }
    else
    {
	$clone_type="TBI";
    }
    

    my $rear_3nts=substr $seq_orf,-3;
    
    if ($rear_3nts eq "TAG")
    {
	my $l=length($orf);
	my $tmp_len=$l-3;
	my $pr1_tmp=substr $orf,0,$tmp_len;
	$orf=$pr1_tmp."TAG";

    }
    elsif($rear_3nts eq "TAC")
    {
	my $l=length($orf);
	my $tmp_len=$l-3;
	my $pr1_tmp=substr $orf,0,$tmp_len;
	$orf=$pr1_tmp."TAC";	
    }
    else
    {
	
    }
    
    
    eval
    {
	$platewell_prt=uc(translate_as_string($seq_orf));
	$std_prt=uc(translate_as_string($orf));
    };if($@){print STDERR $@;};
    
    
    my @seq_prt=($std_prt,$platewell_prt,$platewell,$SN);
    my @seq=($orf,$seq_orf,$platewell,$SN);
    my @assembled_curated=($assembled,$curated,$platewell,$SN);
    my @pattern_platewell=($pattern,$platewell,$SN);
    
    my $protein_avi=&check_prt_seq(\@seq_prt);
    my $dna_avi=&check_dna_seq(\@seq);
    my $pattern_avi=&check_pattern(\@pattern_platewell);
    my $assembled_curated_avi=&check_assembled_curated(\@assembled_curated);
    
    if (($protein_avi eq "N") or ($dna_avi eq "N") or ($pattern_avi eq "N") or ($assembled_curated_avi eq "N")) {
	$avi="N";
	
    }
    else
    {
	$avi="Y";
    }
    my @result=($clone_type,$avi);
    return \@result;
   

  }
  
sub check_prt_seq
{
    my $arr=shift @_;
    my($pr1,$pr2,$platewell,$SN)=@$arr;
    my $pr1_len=length($pr1);
    my $pr2_len=length($pr2);
    
    my $avi="N";
    my $i=0;
    my $count_p=0;
    my $p_rate=0;
    my $star1=0;
    my $star2=0;
    my $check_len="Y";

    if (($pr1_len !=$pr2_len) or($pr1_len==0)or($pr2_len==0)) {
	$avi="N";
	$count_p="#";
	$star1="#";
	$star2="#";
	$p_rate="#";
	$check_len="N";
	goto CONK;
    }
    

    while( $pr1 =~/\*/g )
    {
        $star1++;
    }
    while( $pr2 =~/\*/g )
    {
        $star2++;
    }
    
    if ($star2>1)
    {
	$avi="N";
    }
    else
    {
	$avi="Y";
    }
    
    for($i=0;$i<$pr1_len;$i++)
    {
        my $chr1=substr $pr1,$i,1;
        my $chr2=substr $pr2,$i,1;
        if ($chr1 ne $chr2)
        {
            $count_p++;
        }
    }
    $p_rate=$count_p/$pr1_len;
    
   CONK: my $result=$avi;
    print QAREPORT $platewell,"\t",$SN,"\t","PROTEIN","\t",$pr1_len,"\t",$count_p,"\t",$p_rate,"\t",$star2,"\t",$avi,"\t|\t";
    return $result;
}






sub check_dna_seq
{
    my $arr=shift @_;
    my($pr1,$pr2,$platewell,$SN)=@$arr;
    
    my $pr1_len=length($pr1);
    my $pr2_len=length($pr2);
    
    my $avi="N";
    my $i=0;
    my $count_p=0;
    my $p_rate=0;
    my $check_len="Y";
    my $not_atcg="N";


     if (($pr1_len !=$pr2_len) or($pr1_len==0)or($pr2_len==0)) {
	$avi="N";
	$count_p="#";
	$p_rate="#";
	$check_len="N";
	goto CONK;
    }
     
    if($pr2=~ /[^atcg]/i)
    {
	 $avi="N";
	 $not_atcg="Y";
    }
    else
    {
	$avi="Y";
	$not_atcg="N";
    }
    

    
    for($i=0;$i<$pr1_len;$i++)
    {
        my $chr1=substr $pr1,$i,1;
        my $chr2=substr $pr2,$i,1;
        if ($chr1 ne $chr2)
        {
            $count_p++;
        }
    }
    $p_rate=$count_p/$pr1_len;
    CONK:my $result=$avi;
    print QAREPORT $platewell,"\t",$SN,"\t","DNA","\t",$pr1_len,"\t",$count_p,"\t",$p_rate,"\t",$not_atcg,"\t",$avi,"\n";
  
    if ($count_p=~/[0-9]+/)
    {
      $dna_checker->{$platewell}->{$SN}=$count_p;
    }
    
    return $result;
}

sub check_pattern
{
     my $arr=shift @_;
     my ($line,$platewell,$SN)=@$arr;
    

    
    
    my $avi="N";
    
    my $D=0;
    my $P=0;
    my $I=0;
    my $pD=0;
    my $pP=0;
    my $pI=0;
    my $aD=0;
    my $aI=0;
    my $aP=0;
    
    if ($line eq "")
    {
	$avi="Y";
	goto CONK;
    }

    while ($line=~/[0-9]+P\(([0-9]+)\|/g) {
        $P+=$1;
        
    }
    
    while ($line=~/[0-9]+D\(([0-9]+)\|/g) {
         $D+=$1;
        
    }
    while ($line=~/[0-9]+I\(([0-9]+)\|/g) {
         $I+=$1;
    }
    
    while ($line=~/[0-9]+aI\(([0-9]+)\|/g) {
         $aI+=$1;
    }
    
    while ($line=~/[0-9]+aD\(([0-9]+)\|/g) {
         $aD+=$1;
    }
    
    while ($line=~/[0-9]+aP\(([0-9]+)\|/g) {
         $aP+=$1;
    }
    
    while ($line=~/[0-9]+pP\(([0-9]+)\|/g) {
         $pP+=$1;
    }
    
    while ($line=~/[0-9]+pD\(([0-9]+)\|/g) {
         $pD+=$1;
    }
    
    
    while ($line=~/[0-9]+pI\(([0-9]+)\|/g) {
         $pI+=$1;
    }
    
    if (($D>0)or($I>0)or($pD>0)or($pI>0)) {
	$avi="N";
    }
    else
    {
	$avi="Y";
    }
    CONK:
    my $check=$avi;
    return $check;
    
}

sub check_assembled_curated
{
    my $arr=shift @_;
    my($assembled,$curated,$platewell,$SN)=@$arr;
    
    my $avi="N";
    if (($assembled eq "0") or ($assembled eq "8"))
    {
	$avi="N";
    }
    elsif(($curated eq "1") and(($assembled eq "1") or ($assembled eq "2")or ($assembled eq "7") or ($assembled eq "9")))
    {
	$avi="Y";
    }
    else
    {
	$avi="N";
    }
    return $avi;
    
}