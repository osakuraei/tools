#!/opt/ActivePerl-5.16/bin/perl

use lib qw(/home/kokia/bioperl-live);
use strict;
use Bio::SeqIO;
my $rHoHoH ={};

if (@ARGV!=3) {
    die "please check input files: <fasta_file> <adatper_config_file> <SEQ_TAB_FILE>\n";
}

open(CONFIG,"<", $ARGV[1]) or die "Please check your <adatper_config_file>\n";
open(OUTPUTFILE,">", $ARGV[2]) or die "Please check your <SEQ_TAB_FILE>\n";
while (my $line=<CONFIG>)
{
    chomp($line);
    my @ada=split /	/,$line;
    $rHoHoH->{$ada[0]}={
                        AL=>$ada[1],
                        AL_L=>$ada[2],
                        AR=>$ada[3],
                        AR_L=>$ada[4]
                     };
    
}

my $inseq = Bio::SeqIO->new(
                            -file   => "$ARGV[0]",
                            -format => "FASTA",
                            );

while (my $seq=$inseq->next_seq) {
    my $sequence=lc($seq->seq());
    my $id=$seq->primary_id;
    for my $key ( sort keys %$rHoHoH )
    {
        my $seq_len=length($sequence);
        my $al=$rHoHoH->{$key}->{AL};
        my $al_l=$rHoHoH->{$key}->{AL_L};
        my $ar=$rHoHoH->{$key}->{AR};
        my $ar_l=-1*($rHoHoH->{$key}->{AR_L});
        my $seq_pl=substr $sequence, 0,$al_l;    
        my $seq_pr=substr $sequence, $ar_l;
        if (($al eq $seq_pl) &&($ar eq $seq_pr) )
        {
            $sequence=~s/$al//i;
            $sequence=~s/$ar//i;
            print OUTPUTFILE $id,"\t",$sequence,"\n";  
            goto AKT;          
        }
    }
    print STDERR "I didn't find correct adapter in \t$id\t sequence, please help me to recheck this sequence.\n";
    AKT:
}

close OUTPUTFILE;
close CONFIG;