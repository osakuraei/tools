#!/opt/ActivePerl-5.16/bin/perl

use strict;
use lib qw(/home/kokia/bioperl-live);
use Bio::SeqIO;
use Bio::Seq;
if(@ARGV!=2)
{
    die "please check your input list <Primer_input_file> <Product_out_put_file>\n";
}
open primer_file,"<",$ARGV[0];
open primer_product,">>",$ARGV[1];

my %hash_seq = ();
 

my @chorme=qw/chr1.fa chr2.fa chr3.fa chr4.fa chr5.fa chr6.fa chr7.fa chr8.fa chr9.fa chr10.fa chr11.fa chr12.fa chr13.fa chr14.fa chr15.fa chr16.fa chr17.fa chr18.fa chr19.fa chrX.fa chrY.fa/;
my @chorme_sign=qw/chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chrX chrY/;

while(my $chr=shift(@chorme))
{
    my $chorme_sign=shift(@chorme_sign);
    my $chr10  = Bio::SeqIO->new(-file => "<$chr" , '-format' => 'Fasta');
    while(my $seq = $chr10->next_seq)
    {
        $hash_seq{$chorme_sign}=$seq->seq();
    }
}
while(my $Line=<primer_file>)
{
    chomp($Line);
    my @fileds=split /	/,$Line;
    
    my $f=$fileds[0];
    my $r=$fileds[1];
    my $chr=$fileds[2];
    my $begin=$fileds[3];
    my $end=$fileds[4];
    
    my $begin_0=$begin-1;
    my $length=$end-$begin_0;

    my $seq=$hash_seq{$chr};
    my $product=substr $seq,$begin_0,$length;
    print primer_product $f,"\t",$product,"\t",$r,"\t",$chr,"\t",$begin,"\t",$end,"\n";
    
}

close primer_product;
close primer_file;

#I see, please read
#please read this file
#please add the file
