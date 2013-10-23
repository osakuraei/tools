#!/opt/ActivePerl-5.16/bin/perl

use strict;
 my $rHoHoH = ();
 open(INPUT, "<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS INPUTFILE\n";
 open(OUTPUT, ">", $ARGV[1]) or die "PLEASE CHECK IF THERE IS OUTPUTFILE\n";

while(my $line=<INPUT>)
{
    chomp($line);
    my ($trans,$product,$pm_num)=split /	/,$line;
    if (not exists $rHoHoH->{$trans}) {

                $rHoHoH->{$trans}={   PRODUCT =>$product,
                                            PM=>$pm_num
                                            };
    }
    else
    {
        my $pm=$rHoHoH->{$trans}->{PM};
        if ($pm_num<$pm) {
            
            $rHoHoH->{$trans}={   PRODUCT =>$product,
                                            PM=>$pm_num
                                            };
            
        }
        
    }
   
}

 for my $k1 ( sort keys %$rHoHoH )
 {


            print OUTPUT $k1,"\t",$rHoHoH->{$k1}->{PRODUCT},"\t",$rHoHoH->{$k1}->{PM},"\t","Y","\n";
 }
 
 close INPUT;
 close OUTPUT;