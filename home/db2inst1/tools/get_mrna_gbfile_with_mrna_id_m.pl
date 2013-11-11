 #!/opt/ActivePerl-5.16/bin/perl
 use strict;
 use threads;
 use threads::shared;
 use Thread::Semaphore;
 use lib qw(/home/kokia/bioperl-live);
 my $max_thread=3;
 my $semaphore = Thread::Semaphore->new($max_thread);
 my $mutex_1 = Thread::Semaphore->new(1);
 my $mutex_2 = Thread::Semaphore->new(1);
 
if (@ARGV!=4)
{
    die "please check the <mrna_ac_input> <unget_mrna__id_file> <genbankfile_output> <orf_fasta>\n";
}

open(NCBI_REF_AC,"<",$ARGV[0]) or die "please check the <mrna_ac_input> file \n";
open(UNGET_MRNA_ID,">>",$ARGV[1]) or die "please check the <unget_mrna__id_file> file \n";

my $GENE_ID_MRNA=$ARGV[2];


    while (my $ref_ac=<NCBI_REF_AC>)
    {
  	chomp($ref_ac);
  	  		
	$semaphore->down;
	print  STDERR "DOWN\t",${$semaphore},"\n";
  	my $p_thread=threads->create(\&p_get,$ref_ac);
  	$p_thread->detach();
    }
	
    &Wait2Quit();
    
    close NCBI_REF_AC;
    close UNGET_MRNA_ID;
    close $GENE_ID_MRNA;
    
    my @para=($ARGV[2],$ARGV[3]);
    my @args = ($^X,'/home/db2inst1/tools/fetch_NCBI_Seq_orf_s.pl',@para);
    system(@args) == 0 or die "system @args failed: $?";


sub p_get
{
    
    my $ref_ac=shift @_;
    my $url="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=$ref_ac&rettype=gb&retmode=text";
    
    
    eval
    {
	$mutex_1->down;
	open STDOUT,">>",$GENE_ID_MRNA;
	system('curl',  '-s', "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=$ref_ac&rettype=gb&retmode=text") == 0 or print STDERR "system failed: $?";
	$mutex_1->up;
    };
    if($@) 
    {
	$mutex_2->down;
	print UNGET_MRNA_ID $ref_ac,"\n";
	$mutex_2->up;
    }
    
    $semaphore->up;
    print STDERR "UP\t",${$semaphore},"\n";
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
			   print STDERR "FULL NCBI QUERY THREADS QUIT \n";
			   last;
		     }
		     sleep(2);
		     $counter++;
		     if($counter>1800)
		     {
			   my $diff=$max_thread-$sig;
			   print STDERR "$diff NCBI QUERY THREADS NOT QUIT \n";
			   last;
		     }
	    }	
      }