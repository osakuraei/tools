 #!/opt/ActivePerl-5.16/bin/perl
 use strict;
 use threads;
 use threads::shared;
 use Thread::Semaphore;
 my $max_thread=3;
 my $semaphore = Thread::Semaphore->new($max_thread);
 my $mutex_1 = Thread::Semaphore->new(1);
 my $mutex_2 = Thread::Semaphore->new(1);
 use LWP;
 use LWP::UserAgent;
 use lib qw(/home/kokia/bioperl-live);
 
if (@ARGV!=4)
{
    die "please check the parameters:\n\t\t\t\t\t<ncbi_gene_id>\n\t\t\t\t\t<BAD_OUTPUTFILE>\n\t\t\t\t\t<gene_id_mrna_outfile>\n\t\t\t\t\t<gene_id_mrna_parsed_out>\n";
}
open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File\n";
open(BAD_FILE,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS A BAD OUTPUTFILE\n";
my $GENE_ID_MRNA=$ARGV[2];
open(PARSED_OUTFILE,">",$ARGV[3]) or die "Please check your gene_id_mrna_parsed_out file\n";

    while (my $gene_id=<GENE_ID>)
    {
  	chomp($gene_id);
  	  		
	$semaphore->down;
	print  STDERR "DOWN\t",${$semaphore},"\n";
  	my $p_thread=threads->create(\&p_get,$gene_id);
  	$p_thread->detach();
    }
	
    &Wait2Quit();
    close $GENE_ID_MRNA;
    &parse_out($GENE_ID_MRNA);   
    close GENE_ID;
    close BAD_FILE;
    close PARSED_OUTFILE;


sub p_get
{
    my $gene_id=shift @_;
    eval
    {
        $mutex_1->down;
        open STDOUT,">>",$GENE_ID_MRNA;
        system('xsltproc',  '--novalid',  '/home/db2inst1/tools/ncbi_parser.xsl',"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=gene&id=$gene_id&retmode=xml") == 0 or print STDERR "system failed: $?";
        $mutex_1->up;
    };
    if($@) 
    {
         $mutex_2->down;
         print BAD_FILE $gene_id,"\t check gene_id again\n";
         $mutex_2->up;
    }
    $semaphore->up;
    print STDERR "UP\t",${$semaphore},"\n";
}

sub parse_out
{
    my $INFILE=shift @_;
    open(GENE_ID_RNA, "<",$INFILE) or die "Please check your input file\n";
    my $gene_id="";
    my $gene_symbol="";
    my $acn="";
    while (my $line=<GENE_ID_RNA>)
    {
        chomp($line);
        my($par1,$par2)=split /	/,$line;
        if ($par1 eq "id")
        {
            $gene_id=$par2;
        }
        if ($par1 eq "locus")
        {
            $gene_symbol=$par2;
        }
        
        if ($par1 eq "acn")
        {
            $acn=$par2;
            print PARSED_OUTFILE $gene_id,"\t",$gene_symbol,"\t",$acn,"\n";
        }
        if (($par1 eq "]")&&($acn eq ""))
        {
            print PARSED_OUTFILE $gene_id,"\t",$gene_symbol,"\t","-","\n";
        }
        if ($par1 eq "]")
        {
            $gene_id="";
            $gene_symbol="";
            $acn="";
        }
        
        
    }
    close GENE_ID_RNA;
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