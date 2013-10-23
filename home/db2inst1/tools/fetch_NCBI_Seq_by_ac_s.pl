#!/opt/ActivePerl-5.16/bin/perl

 use lib qw(/home/kokia/bioperl-live);
 
 use strict;
 if (@ARGV!=3) {
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
    &p_get_genbank($ac);
    sleep(1);
 }

 close AC_FILE;
 close LEFT_FILE;
 
sub p_get_genbank
         {
         	my $ac;
         	 eval
	          {
	           $ac=shift @_;
	           my $outfile = Bio::SeqIO->new(-file => ">>$ARGV[1]" ,
	                                -format => 'Genbank');
	           my $seq_obj = $gb->get_Seq_by_acc($ac);
	           $outfile->write_seq($seq_obj);
	         };
	         if($@)
	         {
	         	print LEFT_FILE $ac,"\n";
	         }
         }
