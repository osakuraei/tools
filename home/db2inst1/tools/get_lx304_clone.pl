#!/opt/ActivePerl-5.16/bin/perl
    use strict;
    use DBI();
    use lib qw(/home/kokia/bioperl-live);
    my $hash_ref={};
    my $gc_id="";
    my $product_id_lv="";
    if (@ARGV!=2)
    {
        die "please check the <gc_id_inputfile> <LX304_Clone_outputfile> \n";
    }
    open(GC_ID,"<",$ARGV[0]) or die "please check the <GC_ID_input_file> \n";
    open(LX304,">", $ARGV[1]) or die "Please check the <LX304_CLone_outputfile> \n";
    
    my $dbh = DBI->connect("DBI:mysql:database=lims;host=192.168.8.10",
                         "selectonly", "fulengen",
                         {'RaiseError' => 1});
    
   while ($gc_id=<GC_ID>)
   {
    chomp($gc_id);
    my $sth = $dbh->prepare("select distinct product_id_lv from _glz_ORFeome_v81_gene where gene_id='$gc_id'");
    $sth->execute();
    my $numRows = $sth->rows;
     if($numRows>0)
     {
        while (my $ref = $sth->fetchrow_hashref())
        {
            my $product_id_lv=$ref->{'product_id_lv'};
            $hash_ref->{$gc_id}->{$product_id_lv}={};
        }
     }
     else
     {
        print LX304 $gc_id,"\t","-","\t","-","\t","-","\t","-","\t","-","\t","-","\n";
     }
     $sth->finish();
   }
   
   for my $key1 (sort keys %$hash_ref)
   {
    for my $key2 ( sort keys %{$hash_ref->{ $key1}} )
    {
        my $sth = $dbh->prepare("select orf_seq from _glz_ORFeome_v81_seq where product_id_lv='$key2' limit 1");
        $sth->execute();
        my $numRows = $sth->rows;
        if($numRows>0)
        {
           while (my $ref = $sth->fetchrow_hashref())
           {
               my $orf_seq=$ref->{'orf_seq'};
               $hash_ref->{$key1}->{$key2}->{SEQ}=$orf_seq;
           }
        }
        else
        {
               $hash_ref->{$key1}->{$key2}->{SEQ}="-";
        }
        $sth->finish();
        
        $sth = $dbh->prepare("select plate2,row2,col2,vector2,status2 from  _glz_ORFeome_v81_clone_product  where product_id_lv='$key2' limit 1");
        $sth->execute();
        $numRows = $sth->rows;
        if($numRows>0)
        {
           while (my $ref = $sth->fetchrow_hashref())
           {
               my $platewell=$ref->{'plate2'}."-".$ref->{'row2'}."-".$ref->{'col2'};
               my $status=$ref->{'status2'};
               my $vector=$ref->{'vector2'};
               $hash_ref->{$key1}->{$key2}->{PLATEWELL}=$platewell;
               $hash_ref->{$key1}->{$key2}->{STATUS}=$status;
               $hash_ref->{$key1}->{$key2}->{VECTOR}=$vector;
               if ($status eq "1")
               {
                $hash_ref->{$key1}->{$key2}->{AVI}="Y";
               }
               else
               {
                $hash_ref->{$key1}->{$key2}->{AVI}="TBI";
               }
               
           }
        }
        else
        {
                $hash_ref->{$key1}->{$key2}->{PLATEWELL}="-";
                $hash_ref->{$key1}->{$key2}->{STATUS}="-";
                $hash_ref->{$key1}->{$key2}->{VECTOR}="-";
                $hash_ref->{$key1}->{$key2}->{AVI}="-";
        }
        $sth->finish();
    }
   }
   
    for my $key1 (sort keys %$hash_ref)
    {
        for my $key2 ( sort keys %{$hash_ref->{ $key1}} )
        {
            print LX304 $key1,"\t",$key2,"\t",$hash_ref->{$key1}->{$key2}->{SEQ},"\t",$hash_ref->{$key1}->{$key2}->{PLATEWELL},"\t",$hash_ref->{$key1}->{$key2}->{STATUS},"\t",$hash_ref->{$key1}->{$key2}->{VECTOR},"\t",$hash_ref->{$key1}->{$key2}->{AVI},"\n";
        }
    }
    
    close GC_ID;
    close LX304;