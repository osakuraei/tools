#!/opt/ActivePerl-5.16/bin/perl

use lib qw(/home/kokia/bioperl-live);

use strict;

use Bio::SeqIO;
use Bio::Perl;
if (@ARGV!=3)
{
    die "please check <primer_tab_file> <template_fasta_file> <outputfile>\n";
}

my $primer_hash={};
my $template_id="";
my $template_seq="";
my $template_revcom="";
my $template_len="";
my $cut_len=15;
my $n_cut_len=-1*($cut_len);

open(PRIMER,"<", $ARGV[0]) or die "please check if there is a primer file \n";
open(OUTPUT,">", $ARGV[2]) or die "please check if there is an outputfile\n";

my $inseq = Bio::SeqIO->new(
                            -file   => "<$ARGV[1]",
                            -format => "FASTA",
                            );

while (my $line=<PRIMER>) {
    chomp($line);
    my @arr=split /	/,$line;
    if(@arr==3)
    {
	$primer_hash->{$arr[0]}={F=>uc($arr[1]),
			       R=>uc($arr[2])
			       };
    }
}

while (my $seq=$inseq->next_seq) {
    my $d_seq=$seq->seq();
    if($d_seq ne "")
    {
	$template_id= $seq->primary_id;
	$template_len=$seq->length();
	$template_seq= uc($d_seq);
	$template_revcom=reverse_complement_as_string($template_seq);
    }
    else
    {
    	print STDERR $seq->primary_id,"\t","EMPTY SEQUENCE","\n";
    }
}

for my $key(sort keys %$primer_hash)
{
    my $primer_f=$primer_hash->{$key}->{F};
    my $primer_r=$primer_hash->{$key}->{R};
    
    my $primer_f_PR=$primer_f;
    my $primer_r_PR=$primer_r;
    
    $primer_f=substr $primer_f_PR,$n_cut_len;
    $primer_r=substr $primer_r_PR,$n_cut_len;
    
    if (($template_seq=~/$primer_f/i)&&($template_revcom=~/$primer_r/i))
    {
	my $f_index=index($template_seq,$primer_f);
	my $primer_r_revcom=reverse_complement_as_string($primer_r);
	my $r_index_1=index($template_seq,$primer_r_revcom);
	my $product_len=abs($r_index_1-$f_index);
	my $product_p=substr $template_seq,$f_index,$product_len;
	my $product_p_tmp=$product_p;
	$product_p=substr $product_p_tmp,$cut_len;
	my $primer_r_PR_r=reverse_complement_as_string($primer_r_PR);
	print OUTPUT  "+","\t",$key,"\t",$primer_f_PR,"\t",$primer_f_PR.$product_p.$primer_r_PR_r,"\t",$primer_r_PR,"\n";
    }
    elsif(($template_revcom=~/$primer_f/i)&&($template_seq=~/$primer_r/i))
    {
	my $f_index=index($template_revcom,$primer_f);
	my $primer_r_revcom=reverse_complement_as_string($primer_r);
	my $r_index_1=index($template_revcom,$primer_r_revcom);
	my $product_len=abs($r_index_1-$f_index);
	my $product_p=substr $template_revcom,$f_index,$product_len;
	my $product_p_tmp=$product_p;
	$product_p=substr $product_p_tmp,$cut_len;
	my $primer_r_PR_r=reverse_complement_as_string($primer_r_PR);
	print OUTPUT  "-","\t",$key,"\t",$primer_f_PR,"\t",$primer_f_PR.$product_p.$primer_r_PR_r,"\t",$primer_r_PR,"\n";
    }
    else
    {
	print STDERR "PRIMER $key AND TEMPLATE $template_id MISMATCH\n";
    }
    
}

close PRIMER;
close OUTPUT;