#!/opt/ActivePerl-5.16/bin/perl

 use lib qw(/home/kokia/bioperl-live);
 
 use strict;
 use Bio::DB::GenBank;
 use Bio::Seq;
 use Bio::SeqIO;

 
 if (@ARGV!=2) {
    die "please check the argument <GenBank_Input_File> <parsed_genbank_output_file> \n";
 }
 


 
my $seqio_object = Bio::SeqIO->new(
                            -file   => "<$ARGV[0]",
                            -format => "genbank",
                            );
my $out = Bio::SeqIO->new(-file => ">>$ARGV[1]" ,
                           -format => 'Fasta');
while(my $seq_obj = $seqio_object->next_seq)
{
	&make_fasta_file($seq_obj);
} 


 
 
sub make_fasta_file
{ my $ac;
	eval
	{
   my $seq_obj=shift @_;
   		$ac=$seq_obj->accession_number;
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
 	};
 	if($@)
 	{
 		print STDERR $ac,"\n";
 	}

}