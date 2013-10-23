#!/opt/ActivePerl-5.16/bin/perl

use lib qw(/home/kokia/bioperl-live);
use strict;
use Bio::SeqIO;
if (@ARGV!=2) {
    die "please check <fasta file> <tab file>\n";
}
open(OUTPUTFILE,">", $ARGV[1]) or die "Please check your outputfile\n";
my $inseq = Bio::SeqIO->new(
                            -file   => "$ARGV[0]",
                            -format => "FASTA",
                            );

while (my $seq=$inseq->next_seq)
{
    my $d_seq=$seq->seq();
    if ($d_seq ne "")
    {
        print OUTPUTFILE $seq->primary_id,"\t",$d_seq,"\n";
    }
    else
    {
        print STDOUT $seq->primary_id,"\t","EMPTY SEQUENCE","\n";
    }
    
}

close OUTPUTFILE;