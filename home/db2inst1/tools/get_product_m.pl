#!/opt/ActivePerl-5.16/bin/perl

use strict;
use lib qw(/home/kokia/bioperl-live);
use Bio::SeqIO;
use Bio::Seq;

use threads;
use threads::shared;
use Thread::Semaphore;

my $thread;
my $max_thread=20;
my $semaphore = Thread::Semaphore->new($max_thread);


if(@ARGV!=2)
{
    die "please check your input list <Primer_input_file> <Product_out_put_file>\n";
}

open(PRIMER_FILE,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS primer  File\n";

open(PRIMER_PRODUCT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS A primer product \n";
select PRIMER_PRODUCT;
$|=1;




my %hash_seq= ();
share(%hash_seq);
 

my @chorme=qw/chr1.fa chr2.fa chr3.fa chr4.fa chr5.fa chr6.fa chr7.fa chr8.fa chr9.fa chr10.fa chr11.fa chr12.fa chr13.fa chr14.fa chr15.fa chr16.fa chr17.fa chr18.fa chr19.fa chrX.fa chrY.fa/;
my @chorme_sign=qw/chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chrX chrY/;

while(my $chr=shift(@chorme))
{
    my $chorme_sign=shift(@chorme_sign);
    my $chr1o  = Bio::SeqIO->new(-file => "<$chr" , '-format' => 'Fasta');
    while(my $seq = $chr1o->next_seq)
    {
        $hash_seq{$chorme_sign}=$seq->seq();
    }
}

while(my $record=<PRIMER_FILE>)
{
		chomp($record);
		$semaphore->down;
		print STDOUT "DOWN\t",${$semaphore},"\n";
  	my $p_thread=threads->create(\&get_p,$record);
  	$p_thread->detach();   
}
&Wait2Quit();

close PRIMER_PRODUCT;
close PRIMER_FILE;

sub get_p
{
		my $Line=shift @_;
	  my @fileds=split /	/,$Line;

    my $chr=$fileds[2];
    my $begin=$fileds[3];
    my $end=$fileds[4];
    
    my $begin_0=$begin-1;
    my $length=$end-$begin_0;

    my $seq=$hash_seq{$chr};
    my $product=substr $seq,$begin_0,$length;
    print PRIMER_PRODUCT $product,"\t",join("	", @fileds),"\n";
    $semaphore->up;
		print STDOUT "UP\t",${$semaphore},"\n";
}

sub Wait2Quit
	{
		my $counter=0;
		my $sig;
	
		while(1)
		{
			$sig=${$semaphore};
			if($sig==$max_thread)
			{
				print STDOUT "FULL QUERY THREADS QUIT \n";
				last;
			}
			sleep(2);
			$counter++;
			if($counter>1800)
			{
				my $diff=$max_thread-$sig;
				print STDOUT "$diff THREADS NOT QUIT \n";
				last;
			}
		}	
	}