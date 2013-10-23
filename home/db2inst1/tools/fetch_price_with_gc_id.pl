#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use DBI();
  my $hash_ref={};
if (@ARGV!=4)
{
    die "please check the parameters <gc_id_file> <Clone_Type> <Vector> <Outputfile>";
}

open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File";
my $clone_type=uc($ARGV[1]);
my $vector=uc($ARGV[2]);
open(RESULT,">>",$ARGV[3]) or die "PLEASE CHECK IF THERE IS AN OUTPUTFILE";

  # Connect to the database.

my $dbh = DBI->connect("DBI:mysql:database=lims;host=magic.fulengen.net",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});

while (my $gene_id=<GENE_ID>)
{
  chomp($gene_id);
  my $sth = $dbh->prepare("SELECT cloned FROM gene where gene_id=\'$gene_id\' limit 1");
  $sth->execute();
  my $numRows = $sth->rows;
  if($numRows>0)
  {
	  while (my $ref = $sth->fetchrow_hashref())
	    {

	       my $cloned= $ref->{'cloned'};
	       $hash_ref->{$gene_id}->{CLONE}=$cloned;
	    
	    }
  }
   else
   {
        
     	       $hash_ref->{$gene_id}->{CLONE}="-";
    
   }
    
  $sth->finish();
}


for my $key( sort keys %$hash_ref)
{
    $key=~/^GC-(.*)$/i;
    my $part=$1;
    my $id=$clone_type."-".$part."-".$vector;
    if ($clone_type eq "GC")
    {
	$id=$key;
    }

    my $cloned=$hash_ref->{$key}->{CLONE};

    if (($cloned ne "-")&&($cloned>=1&&$cloned<=5))
    {
	    
	my $price=`/home/shenc/bin/usaprice.sh $id`;
	chomp($price);
	my ($my_id,$cat_price,$dis_price)=split / /,$price;
	$hash_ref->{$key}->{CAT_PRICE}=$cat_price;
	$hash_ref->{$key}->{DIS_PRICE}=$dis_price;
	$hash_ref->{$key}->{ID}=$id;
    }
    else
    {
	$hash_ref->{$key}->{CAT_PRICE}="Inquiry";
	$hash_ref->{$key}->{DIS_PRICE}="Inquiry";
	$hash_ref->{$key}->{ID}=$id;
    }
}

for my $key( sort keys %$hash_ref)
{
    print RESULT $key,"\t",$hash_ref->{$key}->{CAT_PRICE},"\t",$hash_ref->{$key}->{DIS_PRICE},"\t",$hash_ref->{$key}->{ID},"\t",$hash_ref->{$key}->{CLONE},"\n";
}

close GENE_ID;
close RESULT;
  

  # Disconnect from the database.
  #final version
  $dbh->disconnect();