#!/opt/ActivePerl-5.16/bin/perl

  use strict;
  use lib qw(/home/kokia/bioperl-live);
  use threads;
  use threads::shared;
  use Thread::Semaphore;
  use DBI();
  my @ary :shared;
  my $rHoHoH ={};
  my $dbh_fl_info = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
if (@ARGV!=2)
{
    die "please check the parameters:\t<gc_id>\t<mgc_template_outputfile>\n";
}

open(GENE_ID,"<", $ARGV[0]) or die "PLEASE CHECK IF THERE IS GENE_ID File\n";

open(RESULT,">>",$ARGV[1]) or die "PLEASE CHECK IF THERE IS an mgc_template_outputfile \n";
select RESULT;
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

	&out_file(\@ary);

    close GENE_ID;
    close RESULT;
    
  	

sub p_get
	{
		my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
		my $gene_id=shift @_;

	  my $sql="SELECT gene_id, template_id,COLLECTION_NAME,PLATE,ROW_POS,COL_POS,accession,mod_date,comment,sn,status,check_status,checker,check_date,mgc_status,placeno FROM _glz_mgc2gene WHERE gene_id = \'$gene_id\' OR template_id='$gene_id' OR accession = '$gene_id'";
	  my $sth = $dbh->prepare("$sql");
	  $sth->execute();
	  my $numRows = $sth->rows;
	    if ($numRows>0)
	    {
			     while (my $ref = $sth->fetchrow_hashref())
			     {
								my $template_id= $ref->{'template_id'};
								my $COLLECTION_NAME= $ref->{'COLLECTION_NAME'};
								my $PLATE= $ref->{'PLATE'};
								my $ROW_POS= $ref->{'ROW_POS'};
								my $COL_POS= $ref->{'COL_POS'};
								my $accession= $ref->{'accession'};
								my $mod_date= $ref->{'mod_date'};
								my $comment= $ref->{'comment'};
								my $sn= $ref->{'sn'};
								my $status= $ref->{'status'};
								my $check_status= $ref->{'check_status'};
								my $checker= $ref->{'checker'};
								my $check_date= $ref->{'check_date'};
								my $mgc_status= $ref->{'mgc_status'};
								my $placeno= $ref->{'placeno'};
								my $platewell=$COLLECTION_NAME."-".$PLATE."-".$ROW_POS."-".$COL_POS;
								my $vector="-";
								my $antibiotic="-";
								my $s_status="-";
								my $c_status="-";

								if(($COLLECTION_NAME ne "")&&($PLATE ne "")) 
								{
									  my $sql_vector="select a.vector,b.antibiotic from _wyn_MGC_384_info as a left join _wyn_vector_info as b on a.vector=b.name where collection=\'$COLLECTION_NAME\' and plate=\'$PLATE\' and row=\'$ROW_POS\' and col=\'$COL_POS\'";
										my $sth_va = $dbh->prepare("$sql_vector");
										$sth_va->execute();
	  								my $numRows_va = $sth_va->rows;
	  								if($numRows_va>0)
	  								{
	  									while (my $ref_va = $sth_va->fetchrow_hashref())
	  									{
	  										$vector=$ref_va->{'vector'};
	  										$antibiotic=$ref_va->{'antibiotic'};
	  									}
	  									
	  								}
	  								$sth_va->finish();
							  }
							  
							  if ($status eq '1')
							  {
							  	$s_status='available(Old MGC)';
							  }
								elsif($status eq '2')
								{
									$s_status='available(RZPD)';
								}
								elsif($status eq '3')
								{
									$s_status='available in USA';
								}
								elsif($status eq '4')
								{
									$s_status='available(Openbiosystem)';
								}
								elsif($status eq '5')
								{
									$s_status='available(ORFeome)';
								}
								else
								{
									$s_status='not available';
								}
						
								
								if($mgc_status eq '0')
								{
									$c_status='NA';
								}
								elsif($mgc_status eq '1')
								{
									$c_status='OK';
								}
								elsif($mgc_status eq '2')
								{
									$c_status='PCR negative';
								}
								elsif($mgc_status eq '3')
								{
									$c_status='SCR negative';
								}
								elsif($mgc_status eq '4')
								{
									$c_status='QC wrong';
								}
								elsif($mgc_status eq '5')
								{
									$c_status='Seq wrong';
								}
								elsif($mgc_status eq '6')
								{
									$c_status='Other gene';
								}
								else
								{
									$c_status='Problematic';
								}		
								if(($s_status ne "not available")&&(($c_status eq "NA")or($c_status eq "OK")))
								{
									$mutex->down;
							  			push (@ary,$gene_id."\t".$accession."\t".$template_id."\t".$platewell."\t"."Y"."\n");
							  			#print RESULT $gene_id."\t".$accession."\t".$template_id."\t",$platewell."\t",$vector."\t",$antibiotic."\t",$s_status."\t",$comment."\t".$c_status."\n";			  	
									$mutex->up;
								}
								else
								{
								    $mutex->down;
									    push (@ary,$gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."N"."\n");
									    #print RESULT $gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\n";
								    $mutex->up;
								}
					}
			}
						    
		else
		{
				$mutex->down;
	      			push (@ary,$gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."N"."\n");
	      			#print RESULT $gene_id."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\t"."-"."\n";
				$mutex->up;
		}
    
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
	    chomp($item);
	    
	    my @scour=split /	/, $item;
	    #my($gene_id,$tel_ac,$tel_id,$tel_wel,$av)=($scour[0],$scour[1],$scour[2],$scour[3],$scour[4]);
	    my($gene_id,$tel_ac,$tel_id,$tel_wel,$av)=@scour;
	    if (not exists $rHoHoH->{$gene_id})
	    {
		if ($tel_id=~/MGC.*/)
		{
		    $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
		    $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
		    $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
		    $rHoHoH->{$gene_id}->{AV}=$av;
		    $rHoHoH->{$gene_id}->{FLAG}=1;          
		}
		elsif ($tel_id=~/HOC.*/)
		{
		    $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
		    $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
		    $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
		    $rHoHoH->{$gene_id}->{AV}=$av;
		    $rHoHoH->{$gene_id}->{FLAG}=2;
		}
		elsif ($tel_id=~/OG.*/)
		{
		    $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
		    $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
		    $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
		    $rHoHoH->{$gene_id}->{AV}=$av;
		    $rHoHoH->{$gene_id}->{FLAG}=3;
		}
		else
		{
		    $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
		    $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
		    $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
		    $rHoHoH->{$gene_id}->{AV}=$av;
		    $rHoHoH->{$gene_id}->{FLAG}=4;
			
		}
		
	    }
	    else
	    {
					my $flag;
					if ($tel_id=~/MGC.*/)
					{
					    $flag=1;
					}
					elsif ($tel_id=~/HOC.*/)
					{
					    $flag=2;
					}
					elsif ($tel_id=~/OG.*/)
					{
					    $flag=3;
					}
					else
					{
					    $flag=4;
					}
					my $pri_flag=$rHoHoH->{$gene_id}->{FLAG};
					if ($pri_flag>$flag) {
					    
					    $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
					    $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
					    $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
					    $rHoHoH->{$gene_id}->{AV}=$av;
					    $rHoHoH->{$gene_id}->{FLAG}=$flag;
					}
		
		
	    } 
	
	}
	
    for my $key ( sort keys %$rHoHoH )
    {
	my $tel_id=$rHoHoH->{$key}->{TEL_ID};
	
	if ($tel_id=~/MGC.*/)
	    {
		my $tel_ac=$rHoHoH->{$key}->{TEL_AC};
		my $sql="select a.fl_id as FL_ID,a.fl_acc as ACC,b.cds_start as START,b.cds_stop as STOP,b.seq as SEQ from fl_info as a, fl_seq as b where a.fl_id=b.fl_id and a.fl_acc='$tel_ac'";
		my $sth = $dbh_fl_info->prepare("$sql");
		$sth->execute();
		my $numRows = $sth->rows;
		my $fl_id="-";
		my $template_seq="-";
		if ($numRows>0)
		{
		     while (my $ref = $sth->fetchrow_hashref())
		     {
			$fl_id=$ref->{'FL_ID'};
			my $start=$ref->{'START'};
			my $stop=$ref->{'STOP'};
			my $seq=$ref->{'SEQ'};
			my $offset_seq=$start-1;
			my $len_seq=abs($stop-$start+1);
			$template_seq=substr $seq,$offset_seq,$len_seq;
			
		     }
		    
		}
		
		
		print RESULT $key,"\t",$fl_id,"\t",$rHoHoH->{$key}->{TEL_AC},"\t",$rHoHoH->{$key}->{TEL_ID},"\t",$rHoHoH->{$key}->{TEL_WELL},"\t",$template_seq,"\t",$rHoHoH->{$key}->{AV},"\t",$rHoHoH->{$key}->{FLAG},"\n";
	    }
	else
	{
		print RESULT $key,"\t","-","\t","-","\t","-","\t","-","\t","-","\n";
	}
	
    }

}
