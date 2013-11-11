#!/opt/ActivePerl-5.16/bin/perl
 
 use strict;
 use lib qw(/home/kokia/bioperl-live);
 use Bio::DB::GenBank;
 use Bio::Seq;
 use Bio::SeqIO;
 use threads;
 use threads::shared;
 use Thread::Semaphore;
 
 if (@ARGV!=2) {
    die "please check the argument <GenBank_Input_File> <parsed_genbank_output_file> \n";
 }
 

 
 my $thread;
 my $max_thread=20;
 my $semaphore = Thread::Semaphore->new($max_thread);
 
my $seqio_object = Bio::SeqIO->new(
                            -file   => "<$ARGV[0]",
                            -format => "genbank",
                            );
my $out = Bio::SeqIO->new(-file => ">>$ARGV[1]" ,
                           -format => 'Fasta');
while(my $seq_obj = $seqio_object->next_seq)
{
   $semaphore->down;
    print STDOUT "DOWN\t",${$semaphore},"\n";
    my $p_thread=threads->create(\&make_fasta_file,$seq_obj);
    $p_thread->detach();
} 

 &Wait2Quit();
 
 
sub make_fasta_file
{
   my $seq_obj=shift @_;
   my $ac=$seq_obj->accession_number;
   my $version=$seq_obj->version;
   my $seq=$seq_obj->seq;
   my $desc=$seq_obj->desc();
   my $id=$ac.".".$version;
   for my $feat_object ($seq_obj->get_SeqFeatures)
   {
      if ($feat_object->primary_tag eq "CDS")
      {
         my $cds=$feat_object->spliced_seq->seq;
         my $seqobj = Bio::Seq->new( -display_id =>$id,
                             -seq => $cds,
                             -desc=>$desc);
         $out->write_seq($seqobj);
         
      }
      
   }
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
				print STDOUT "FULL PARSE THREADS QUIT \n";
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