#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use threads;
  use threads::shared;
  use Thread::Semaphore;
  use DBI();
  my @ary :shared;
if (@ARGV!=2)
{
    die "please check the parameters:\n\t\t\t\t<GC_ID>\n\t\t\t\t<Template_OUTFILE>\n";
}

open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS <GC_ID> File\n";

open(my $RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS A <Template_OUTFILE> \n";

select $RESULT;
$|=1;

my $thread;
my $max_thread=70;
my $semaphore = Thread::Semaphore->new($max_thread);
my $mutex = Thread::Semaphore->new(1);
	             
	while (my $gene_id=<GENE_ID>)
  {
  	chomp($gene_id);
  	  		
		$semaphore->down;
		print STDOUT "DOWN\t",${$semaphore},"\n";

  	my $p_thread=threads->create(\&p_get,$gene_id);
  	$p_thread->detach();
	}
	
	&Wait2Quit();

	#&out_file(\@ary);
    
    close GENE_ID;
    close $RESULT;
    
  	# Disconnect from the database.
  	

sub p_get
	{
		my $dbh = DBI->connect("DBI:mysql:database=test;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
		my $gene_id=shift @_;

		my $sql="select gene_id,accession,template_id,platewell,'available' from _mll_template  where gene_id='$gene_id' and status='Y' ";
		my $sql2="select gene_id,accession,'-',platewell,'not_available' from _mll_template  where gene_id='$gene_id'  and status='N' limit 1 ";
		my $sql3="select gene_id,accession,'-',platewell,'syn_template' from _mll_syn_template  where gene_id='$gene_id' limit 1 ";

	  my $sth = $dbh->prepare("$sql");
	  $sth->execute();
	  my $numRows = $sth->rows;
	    if ($numRows>0)
	    {
	        goto FLAG;
	    }
	        else
	        {
	            $sth = $dbh->prepare("$sql2");
	            $sth->execute();
	            $numRows = $sth->rows;
	            if ($numRows>0)
	            {
	                goto FLAG;
	            }
	                else
	                {
		                $sth = $dbh->prepare("$sql3");
		                $sth->execute();
		                $numRows = $sth->rows;
		                if ($numRows>0)
		                {
		                    goto FLAG;
		                }
		                    else
		                    { 
		                    	$mutex->down;                	
		                     	print $RESULT $gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."no_template"."\t"."\n";
		                     	#push(@ary,$gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."no_template"."\t"."\n");
		                     	$mutex->up;
		                    }
	              }
	      
	        }
	
	   
	   
			FLAG:   do
			   {
			        while (my @row= $sth->fetchrow_array())
			        {
			        		my $item="";
			            foreach my $field (0..$#row)
			            {

			                $item=$item.$row[$field]."\t";	
               
			            }
			            $item=$item."\n";
			            $mutex->down;
					       	print $RESULT $item;
					       	#push(@ary,$item);
					        $mutex->up;
			        }
			   }until (!$sth->more_results);
			    
			    $sth->finish();
			    $dbh->disconnect();
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
	
sub out_file
{
	my $arr=shift @_;
	foreach my $item(@$arr)
	{
		print $RESULT $item;
	}
}
