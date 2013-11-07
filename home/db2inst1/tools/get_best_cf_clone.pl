#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use threads;
  use threads::shared;
  use Thread::Semaphore;
  use DBI();
  my @ary :shared;
if (@ARGV!=3)
{
    die "please check the parameters:\n\t\t\t\t<gene_id>\n\t\t\t\t<Best_CF_OUTFILE>\n\t\t\t\t<F includes OG/OC, P not>";
}
if (($ARGV[2] ne "F") and ($ARGV[2] ne "P"))
{
   die "please check if the third parameter is P or F \n";
}
my $choose=$ARGV[2];
open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File\n";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS A Best_CF_OUTFILE \n";
select RESULT;
$|=1;

my $thread;
my $max_thread=20;
my $semaphore = Thread::Semaphore->new($max_thread);
my $mutex = Thread::Semaphore->new(1);

if( $choose eq "P")
{ 
	             
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
}
elsif($choose eq "F")
{
	while (my $gene_id=<GENE_ID>)
	{
		chomp($gene_id);
		
		$semaphore->down;
		print STDOUT "DOWN\t",${$semaphore},"\n";
		my $p_thread=threads->create(\&f_get,$gene_id);
  	$p_thread->detach();
	}
	
	&Wait2Quit();
	#&out_file(\@ary);
}
else
{
		die "please check if the third parameter is P or F \n";
}
    close GENE_ID;
    close RESULT;
    
  	
  	

sub p_get
	{
		my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
		my $gene_id=shift @_;

	  my $sql="select gene_id, sn,clone_status,comments from _mll_clone_status  where gene_id=\'$gene_id\' and status_NO='15' order by sn desc limit 1 ";
	  my $sql2="select b.gene_id,a.sn,'unfullseq','CF' from  _ll_platewell as a,_ll_assembly  as b,rpwgp as c where b.gene_id=\'$gene_id\' and a.sn=b.sn and concat(c.plate,'_',c.well)=a.platewell and c.cycle like '%CF%' and (b.curated='0' or (b.curated='1' and (b.assembled='0' or b.assembled='8'))) ";
	  my $sql3="select b.gene_id,a.sn,'unfullseq','CF' from  _ll_platewell as a,_ll_assembly  as b,pwgp as c where b.gene_id=\'$gene_id\' and a.sn=b.sn and concat(c.plate,'_',c.well)=a.platewell and c.cycle like  '%CF%' and (b.curated='0' or (b.curated='1' and (b.assembled='0' or b.assembled='8'))) ";
	  my $sqlunfull="select gene_id,sn,status,comments from _mll_unfullseq where gene_id=\'$gene_id\' and status like '%CF%' order by sn desc limit 1 ";
	  my $sqlwrong="select gene_id,sn,clone_status,comments from _mll_clone_status  where gene_id=\'$gene_id\' and status_NO>15 and status_NO<20 order by status_NO,sn desc limit 1 ";
	  
	  my $sth = $dbh->prepare("$sql");
	  $sth->execute();
	  my $numRows = $sth->rows;
	    if ($numRows>0)
	    {
	        goto FLAG;
	    }
	        else
	        {
	            $sth = $dbh->prepare("$sqlunfull");
	            $sth->execute();
	            $numRows = $sth->rows;
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
	                               $sth = $dbh->prepare("$sqlwrong");
	                               $sth->execute();
	                               $numRows = $sth->rows;
	                               if ($numRows>0)
	                               {
	                                   goto FLAG;
	                               }
	                                   else
	                                   {
	                                   	$mutex->down;
	                                   		#push  (@ary,$gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."\n");
	                                   		print RESULT $gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."\n";
	                                   	$mutex->up;
	                                   }
	                           }
	                
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
					        #push  (@ary,$item);
					        print RESULT $item;
					        $mutex->up;
			        }
			   }until (!$sth->more_results);
			    
			    $sth->finish();
			    $dbh->disconnect();
			    $semaphore->up;
			    print STDOUT "UP\t",${$semaphore},"\n";
	}

sub f_get
	{
					my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
					my $gene_id=shift @_;
		
				  my $sql="select gene_id,sn,clone_status,comments from _mll_clone_status  where gene_id=\'$gene_id\' and status_NO='15' order by sn desc limit 1 ";
					my $sqlOC="select gene_id,template_id,status,concat\(\'without_SC\|\',accession) from test._mll_OC_without_SC where gene_id=\'$gene_id\' order by PM_status  limit 1";
					my $sqlOG="select a.gene_ID,a.product_id_en,seqstatus,concat\(\'without_SC\|\',parent_acc) from _glz_ORFeome_v81_gene as a,_glz_ORFeome_v81_clone_product as b where a.product_id_en=b.product_id_en and a.gene_ID=\'$gene_id\' and status1=\'1\' "; 
				  my $sql2="select b.gene_id,a.sn,'unfullseq','CF' from  _ll_platewell as a,_ll_assembly  as b,rpwgp as c where b.gene_id=\'$gene_id\' and a.sn=b.sn and concat(c.plate,'_',c.well)=a.platewell and c.cycle like '%CF%' and (b.curated='0' or (b.curated='1' and (b.assembled='0' or b.assembled='8'))) ";
				  my $sql3="select b.gene_id,a.sn,'unfullseq','CF' from  _ll_platewell as a,_ll_assembly  as b,pwgp as c where b.gene_id=\'$gene_id\' and a.sn=b.sn and concat(c.plate,'_',c.well)=a.platewell and c.cycle like  '%CF%' and (b.curated='0' or (b.curated='1' and (b.assembled='0' or b.assembled='8'))) ";
				  my $sqlunfull="select gene_id,sn,status,comments from _mll_unfullseq where gene_id=\'$gene_id\' and status like '%CF%' order by sn desc limit 1 ";
				  my $sqlwrong="select gene_id,sn,clone_status,comments from _mll_clone_status  where gene_id=\'$gene_id\' and status_NO>15 and status_NO<20 order by status_NO,sn desc limit 1 ";
				  
				  my $sth = $dbh->prepare("$sql");
				  $sth->execute();
				  my $numRows = $sth->rows;
				    if ($numRows>0)
				    {
				        goto FLAG;
				    }
				        else
				        {
				            $sth = $dbh->prepare("$sqlunfull");
				            $sth->execute();
				            $numRows = $sth->rows;
				            if ($numRows>0)
				            {
				                goto FLAG;
				            }
				                else
				                {

				                  $sth = $dbh->prepare("$sqlOC");
							            $sth->execute();
							            $numRows = $sth->rows;
							            if ($numRows>0)
								            {
							                goto FLAG;
							            	}
					                else
					                {
					                	$sth = $dbh->prepare("$sqlOG");
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
									                               $sth = $dbh->prepare("$sqlwrong");
									                               $sth->execute();
									                               $numRows = $sth->rows;
									                               if ($numRows>0)
									                               {
									                                   goto FLAG;
									                               }
									                                   else
									                                   {
									                                   	$mutex->down;
									                                       #push  (@ary,$gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."\n");
									                                       print RESULT $gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."\n";
									                                     $mutex->up;
									                                   }
									                           }
									                
									                    }

									            }
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
					        	#push  (@ary,$item);
					        	print RESULT $item;
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
		print RESULT $item;
	}
}