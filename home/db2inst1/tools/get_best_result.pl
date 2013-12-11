use strict;
if (@ARGV!=3) {
    die "please check <inputfile> <out_got> <out_missing>\n"
}

open(INPUTFL,"<",$ARGV[0]) or die "please check if the inputfile exists \n";
open(OUTNORM,">",$ARGV[1]) or die "please check if the normal outputfile exists \n";
open(OUTMI,">",$ARGV[2]) or die "please check if the missing outputfile exists \n";
my $hash_ref={};
my %collector1=();
my %collector2=();
my $gc_ref={};
my %gc_st_N=();
my %gc_st_Y=();
my %pro_count_pm=();
while (my $line=<INPUTFL>)
{
    chomp($line);
    my($acc,$gc_id,$count_pm,$sn,$pro_pm,$template_st)=split /	/,$line;
    $collector1{$acc}="-";
    $hash_ref->{$acc}->{$gc_id}={
                                    GC=>$gc_id,
                                    COUNT_PM=>$count_pm,
                                    SN=>$sn,
                                    PRO_PM=>$pro_pm,
                                    TST=>$template_st
                                 };
    
}

foreach my $key1(sort keys %$hash_ref)
{
    my $acc=$key1;
    my $flag=0;
      for my $key2 ( sort keys %{$hash_ref->{$key1}} )
      {
        my $pro_pm=$hash_ref->{$key1}->{$key2}->{"PRO_PM"};
        if ($pro_pm ne "-")
        {
            $flag=1;
            $pro_count_pm{$key2}=$pro_pm;
        }
        
        my $count_pm=$hash_ref->{$key1}->{$key2}->{"COUNT_PM"};
        my $template_st=$hash_ref->{$key1}->{$key2}->{"TST"};
        $gc_ref->{$key2}={PM=>$count_pm,
                          ST=>$template_st};     
      }
      
      if ($flag==0)
      {
        
        foreach my $key(sort keys %$gc_ref)
        {
            my $pm=$gc_ref->{$key}->{"PM"};
            my $st=$gc_ref->{$key}->{"ST"};
            if ($st eq "N")
            {
                $gc_st_N{$key}=$pm;
            }
            elsif($st eq "Y")
            {
                $gc_st_Y{$key}=$pm;
            }
            else
            {
                
            } 
        }
        
        my $tmp_count;
        my $p_flag=0;
        my $gc_id="";
        my $exe_flag_Y=0;
        foreach my $key_st_Y(sort keys %gc_st_Y)
        {
            if($p_flag==0)
            {
                $tmp_count=$gc_st_Y{$key_st_Y};
                $gc_id=$key_st_Y;
                $p_flag=1;
                $exe_flag_Y=1;
            }
            else
            {
                my $s_count=$gc_st_Y{$key_st_Y};
                if ($tmp_count>$s_count)
                {
                    $tmp_count=$s_count;
                    $gc_id=$key_st_Y;
                    $exe_flag_Y=1;
                }
            }
        }
        if ($exe_flag_Y==1)
        {
            $collector2{$acc}="-";
             print OUTNORM $acc,"\t",$gc_id,"\t",$hash_ref->{$acc}->{$gc_id}->{"SN"},"\t",$hash_ref->{$acc}->{$gc_id}->{"PRO_PM"},"\t",$hash_ref->{$acc}->{$gc_id}->{"COUNT_PM"},"\n";
        }
        
       
        
       
        
        foreach my $key_st_N(sort keys %gc_st_N)
        {
            my $pm=$gc_st_N{$key_st_N};
            if ($pm==0)
            {
                $collector2{$acc}="-";
                print OUTNORM $acc,"\t",$key_st_N,"\t",$hash_ref->{$acc}->{$key_st_N}->{"SN"},"\t",$hash_ref->{$acc}->{$key_st_N}->{"PRO_PM"},"\t",$hash_ref->{$acc}->{$key_st_N}->{"COUNT_PM"},"\n";
              
                last;
            }
            
            
        }       
      }
      
      elsif($flag==1)
      {
        my $tmp_count;
        my $p_flag=0;
        my $gc_id="";
        foreach my $key(sort keys %pro_count_pm)
        {
            if ($p_flag==0)
            {
                $tmp_count=$pro_count_pm{$key};
                $gc_id=$key;
                $p_flag=1;
            }
            else
            {
                my $s_count=$pro_count_pm{$key};
                if ($tmp_count>$s_count)
                {
                    $tmp_count=$s_count;
                    $gc_id=$key;
                }
            }
        }
        $collector2{$acc}="-";
        print OUTNORM $acc,"\t",$gc_id,"\t",$hash_ref->{$acc}->{$gc_id}->{"SN"},"\t",$hash_ref->{$acc}->{$gc_id}->{"PRO_PM"},"\t",$hash_ref->{$acc}->{$gc_id}->{"COUNT_PM"},"\n";
      }
      
      else
      {
        
      }    

    $gc_ref={};
    %gc_st_N=();
    %gc_st_Y=();
    %pro_count_pm=();
}

foreach my $key1 (sort keys %collector1)
{
    if (not exists $collector2{$key1}) {
        print OUTMI $key1,"\n";
    }
    
}

close INPUTFL;
close OUTNORM;
close OUTMI;
