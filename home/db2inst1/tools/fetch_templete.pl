#!/opt/ActivePerl-5.16/bin/perl

use strict;

if (@ARGV!=2) {
    die "please input <source_file> and <output>\n";
}

open(SOURCE,"<",$ARGV[0]) or die "please input source file";
open(OUTPUTFILE,">>",$ARGV[1]) or die "please input outputfile";

my $rHoHoH ={};
while (my $line=<SOURCE>)
{
    chomp($line);
    my @scour=split /	/,$line;
    my($gene_id,$tel_ac,$tel_id,$tel_wel)=($scour[0],$scour[1],$scour[2],$scour[3]);
    if (not exists $rHoHoH->{$gene_id})
    {
        if ($tel_id=~/MGC.*/)
        {
            $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
            $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
            $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
            $rHoHoH->{$gene_id}->{FLAG}=1;          
        }
        elsif ($tel_id=~/HOC.*/)
        {
            $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
            $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
            $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
            $rHoHoH->{$gene_id}->{FLAG}=2;
        }
        elsif ($tel_id=~/OG.*/)
        {
            $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
            $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
            $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
            $rHoHoH->{$gene_id}->{FLAG}=3;
        }
        else
        {
        	  $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
            $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
            $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
            $rHoHoH->{$gene_id}->{FLAG}=0;
        	
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
        		$flag=0;
        }
        my $pri_flag=$rHoHoH->{$gene_id}->{FLAG};
        if ($pri_flag<$flag) {
            
            $rHoHoH->{$gene_id}->{TEL_AC}=$tel_ac;
            $rHoHoH->{$gene_id}->{TEL_ID}=$tel_id;
            $rHoHoH->{$gene_id}->{TEL_WELL}=$tel_wel;
            $rHoHoH->{$gene_id}->{FLAG}=$flag;
        }
        
        
    } 
}

for my $key ( sort keys %$rHoHoH ) {
    
    print OUTPUTFILE $key,"\t",$rHoHoH->{$key}->{TEL_AC},"\t",$rHoHoH->{$key}->{TEL_ID},"\t",$rHoHoH->{$key}->{TEL_WELL},"\t",$rHoHoH->{$key}->{FLAG},"\n";
}

close SOURCE;
close OUTPUTFILE;



