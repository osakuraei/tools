use strict;
use lib qw(E:\bioperl-live);
use Bio::Seq;
use Bio::SeqIO;
use Bio::Perl;

if (@ARGV!=2)
{
    die "please check your inputfile outptufile \n";
}

my $count=0;
open(INPUTFILE,"<", $ARGV[0]) or die "please check your inputfile\n";
open(OUTPUTFILE,">", $ARGV[1]) or die "please check your outputfile\n";

while (my $line=<INPUTFILE>)
{
    chomp($line);
    my @arr=split /	/,$line;
    my $flag=0;
    if($arr[1] =~ /[^atcg]/i)
    {
        print $arr[0],"\t","dose contain not atgc  1\n";
        $flag=1;
    }
    if($arr[3]=~/[^atcg]/i)
    {
        print $arr[3],"\t","dose contain not atgc 2 \n";
        $flag=1;
    }
    my $pr1=translate_as_string($arr[1]);
    my $pr2=translate_as_string($arr[3]);
    my @sub_arr=(uc($pr1),uc($pr2));
    if (length($pr1)==length($pr2))
    {
        my $arr_p=&compare_seq(\@sub_arr);
        my ($count_p,$star1,$star2,$p_rate)=@$arr_p;
        if (($star1==1) && ($star2==1)&&($flag==0))
        {
            print OUTPUTFILE $arr[0],"\t",$arr[2],"\t",$pr1,"\t",$pr2,"\t",length($pr1),"\t",$star1,"\t",$star2,"\t",$count_p,"\t",$p_rate,"\t","GOOD","\n";
        }
        
        else
        {
             print OUTPUTFILE $arr[0],"\t",$arr[2],"\t",$pr1,"\t",$pr2,"\t",length($pr1),"\t",$star1,"\t",$star2,"\t",$count_p,"\t",$p_rate,"\t","BAD","\n";
        }
    }
    else
    {
        print OUTPUTFILE $arr[0],"\t",$arr[2],"\t",$pr1,"\t",$pr2,"\t",length($pr1),"\t","-","\t","-","\n";
    }
    
    
}

close INPUTFILE;
close OUTPUTFILE;

sub compare_seq
{
    my $arr=shift @_;
    my($pr1,$pr2)=@$arr;
    my $pr_len=length($pr1);
    my $i=0;
    my $count_p=0;
    my $p_rate=0;
    my $star1=0;
    my $star2=0;
    while( $pr1 =~/\*/g )
    {
        $star1++;
    }
    while( $pr2 =~/\*/g )
    {
        $star2++;
    }
    for($i=0;$i<$pr_len;$i++)
    {
        my $chr1=substr $pr1,$i,1;
        my $chr2=substr $pr2,$i,1;
        if ($chr1 ne $chr2)
        {
            $count_p++;
        }
    }
    $p_rate=$count_p/$pr_len;
    my @result=($count_p,$star1,$star2,$p_rate);
    return (\@result);
}