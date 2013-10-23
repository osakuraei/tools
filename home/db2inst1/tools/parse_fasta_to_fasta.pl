#!/opt/ActivePerl-5.16/bin/perl

use lib qw(/home/kokia/bioperl-live);

use strict;

use Bio::SeqIO;
if (@ARGV!=2) {
    die "please check <fasta file> <tab file>\n";
}
my $inseq = Bio::SeqIO->new(
                            -file   => "$ARGV[0]",
                            -format => "FASTA",
                            );
my $outseq = Bio::SeqIO->new(
                            -file   => ">>$ARGV[1]",
                            -format => "FASTA",
                            );


while (my $seq=$inseq->next_seq) {
    my $d_seq=$seq->seq();
    if($d_seq ne "")
    {
    	$outseq->write_seq($seq);
    }
    else
    {
    	print STDOUT $seq->primary_id,"\t","EMPTY SEQUENCE","\n";
    }
}
