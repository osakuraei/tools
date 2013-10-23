#!/opt/ActivePerl-5.16/bin/perl
use lib qw(/home/kokia/bioperl-live);
 
 use strict;
 use threads;
 use threads::shared;
 use Thread::Semaphore;
 my $max_thread=3;
 my $semaphore = Thread::Semaphore->new($max_thread);
 my $mutex = Thread::Semaphore->new(1);
 my $mutex_write = Thread::Semaphore->new(1);
 
 if (@ARGV!=3)
 {
    die "please check the argument <NCBI_Accession_Number> <output_file_name_genbank_format> <LEFT_ID_FILE> \n";
 }
 
 use Bio::DB::GenBank;
 use Bio::Seq;
 use Bio::SeqIO;

 
 open (AC_FILE,"<",$ARGV[0]) or die "please check if it is an accession number file \n";
 open (LEFT_FILE,">>",$ARGV[2]) or die "please check if it is an LEFT_ID_FILE \n";
 my $gb = Bio::DB::GenBank->new();
 while(my $ac=<AC_FILE>)
 {
      chomp($ac);
      $semaphore->down;
      print STDERR "DOWN\t",${$semaphore},"\n";
      my $p_thread=threads->create(\&p_get_genbank,$ac);
      $p_thread->detach();
 }
   &Wait2Quit();
   close AC_FILE;
   close LEFT_FILE;
 
sub p_get_genbank
         {
         	my $ac;
         	 eval
	          {
	           $ac=shift @_;
                   my $seq_obj = $gb->get_Seq_by_acc($ac);
                   $mutex_write->down;
	           my $outfile = Bio::SeqIO->new(-file => ">>$ARGV[1]" ,
	                                -format => 'Genbank');
	           $outfile->write_seq($seq_obj);
                   $mutex_write->up;
	         };
	         if($@)
	         {
                     $mutex->down;
	             print LEFT_FILE $ac,"\n";
                     $mutex->up;
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
			   print STDERR "FULL QUERY THREADS QUIT \n";
			   last;
		     }
		     sleep(2);
		     $counter++;
		     if($counter>1800)
		     {
			   my $diff=$max_thread-$sig;
			   print STDERR "$diff THREADS NOT QUIT \n";
			   last;
		     }
	    }	
      }
