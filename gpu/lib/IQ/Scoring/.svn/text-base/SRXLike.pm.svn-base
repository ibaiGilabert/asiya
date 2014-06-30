package SRXLike;

# ------------------------------------------------------------------------

#Copyright (C) Meritxell Gonzàlez

#This library is free software; you can redistribute it and/or
#modify it under the terms of the GNU Lesser General Public
#License as published by the Free Software Foundation; either
#version 2.1 of the License, or (at your option) any later version.

#This library is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#Lesser General Public License for more details.

#You should have received a copy of the GNU Lesser General Public
#License along with this library; if not, write to the Free Software
#Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# ------------------------------------------------------------------------

use Modern::Perl;
use Data::Dumper;
use File::Basename;
use IO::File;
use Unicode::String;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Overlap;
use IQ::Scoring::Metrics;
use IQ::Scoring::NE;
use List::Util qw[min max];

our ($SREXT, $XLike, $rSRspacat);

$SRXLike::SREXT = "SR";
$SRXLike::XLike = "xlike/runxlikeparser.sh";

$SRXLike::rSRspacat = { "$SRXLike::SREXT-Nv" => 1, "$SRXLike::SREXT-Ov" => 1, "$SRXLike::SREXT-Or" => 1, "$SRXLike::SREXT-Orv" => 1,
	            "$SRXLike::SREXT-Mrv(*)" => 1, "$SRXLike::SREXT-Mrv(A0)" => 1, "$SRXLike::SREXT-Mrv(A1)" => 1,
	            "$SRXLike::SREXT-Mrv(A2)" => 1, "$SRXLike::SREXT-Mrv(A3)" => 1, "$SRXLike::SREXT-Mrv(A4)" => 1,
	            "$SRXLike::SREXT-Mrv(A5)" => 1, "$SRXLike::SREXT-Mrv(A6)" => 1, "$SRXLike::SREXT-Mrv(A7)" => 1, 
	            "$SRXLike::SREXT-Mrv(A8)" => 1, "$SRXLike::SREXT-Mrv(A9)" => 1, "$SRXLike::SREXT-Mrv(AM-LOC)" => 1, 
	            "$SRXLike::SREXT-Mrv(AM-TMP)" => 1, "$SRXLike::SREXT-Mrv(AM-MNR)" => 1, "$SRXLike::SREXT-Mrv(AM-ADV)" => 1, 
	            "$SRXLike::SREXT-Mrv(Attribute)" => 1, "$SRXLike::SREXT-Mrv(Beneficiary)" => 1, "$SRXLike::SREXT-Mrv(Cause)" => 1, 
	            "$SRXLike::SREXT-Mrv(Destination)" => 1, "$SRXLike::SREXT-Mrv(Final_State)" => 1, "$SRXLike::SREXT-Mrv(Initial_State)" => 1, 
	            "$SRXLike::SREXT-Mrv(Experiencer)" => 1, "$SRXLike::SREXT-Mrv(Extent)" => 1, "$SRXLike::SREXT-Mrv(Goal)" => 1, 
	            "$SRXLike::SREXT-Mrv(Instrument)" => 1, "$SRXLike::SREXT-Mrv(Location)" => 1, "$SRXLike::SREXT-Mrv(Initial_Location)" => 1, 
	            "$SRXLike::SREXT-Mrv(Patient)" => 1, "$SRXLike::SREXT-Mrv(Source)" => 1, "$SRXLike::SREXT-Mrv(Theme)" => 1, 

	            "$SRXLike::SREXT-Orv(*)" => 1, "$SRXLike::SREXT-Orv(A0)" => 1, "$SRXLike::SREXT-Orv(A1)" => 1,
	            "$SRXLike::SREXT-Orv(A2)" => 1, "$SRXLike::SREXT-Orv(A3)" => 1, "$SRXLike::SREXT-Orv(A4)" => 1,
	            "$SRXLike::SREXT-Orv(A5)" => 1, "$SRXLike::SREXT-Orv(A6)" => 1, "$SRXLike::SREXT-Orv(A7)" => 1, 
	            "$SRXLike::SREXT-Orv(A8)" => 1, "$SRXLike::SREXT-Orv(A9)" => 1, "$SRXLike::SREXT-Orv(AM-LOC)" => 1, 
	            "$SRXLike::SREXT-Orv(AM-TMP)" => 1, "$SRXLike::SREXT-Orv(AM-MNR)" => 1, "$SRXLike::SREXT-Orv(AM-ADV)" => 1, 
	            "$SRXLike::SREXT-Orv(Attribute)" => 1, "$SRXLike::SREXT-Orv(Beneficiary)" => 1, "$SRXLike::SREXT-Orv(Cause)" => 1, 
	            "$SRXLike::SREXT-Orv(Destination)" => 1, "$SRXLike::SREXT-Orv(Final_State)" => 1, "$SRXLike::SREXT-Orv(Initial_State)" => 1, 
	            "$SRXLike::SREXT-Orv(Experiencer)" => 1, "$SRXLike::SREXT-Orv(Extent)" => 1, "$SRXLike::SREXT-Orv(Goal)" => 1, 
	            "$SRXLike::SREXT-Orv(Instrument)" => 1, "$SRXLike::SREXT-Orv(Location)" => 1, "$SRXLike::SREXT-Orv(Initial_Location)" => 1, 
	            "$SRXLike::SREXT-Orv(Patient)" => 1, "$SRXLike::SREXT-Orv(Source)" => 1, "$SRXLike::SREXT-Orv(Theme)" => 1, 

	            "$SRXLike::SREXT-Mr(*)" => 1, "$SRXLike::SREXT-Mr(A0)" => 1, "$SRXLike::SREXT-Mr(A1)" => 1,
	            "$SRXLike::SREXT-Mr(A2)" => 1, "$SRXLike::SREXT-Mr(A3)" => 1, "$SRXLike::SREXT-Mr(A4)" => 1,
	            "$SRXLike::SREXT-Mr(A5)" => 1, "$SRXLike::SREXT-Mr(A6)" => 1, "$SRXLike::SREXT-Mr(A7)" => 1, 
	            "$SRXLike::SREXT-Mr(A8)" => 1, "$SRXLike::SREXT-Mr(A9)" => 1, "$SRXLike::SREXT-Mr(AM-LOC)" => 1, 
	            "$SRXLike::SREXT-Mr(AM-TMP)" => 1, "$SRXLike::SREXT-Mr(AM-MNR)" => 1, "$SRXLike::SREXT-Mr(AM-ADV)" => 1, 
	            "$SRXLike::SREXT-Mr(Attribute)" => 1, "$SRXLike::SREXT-Mr(Beneficiary)" => 1, "$SRXLike::SREXT-Mr(Cause)" => 1, 
	            "$SRXLike::SREXT-Mr(Destination)" => 1, "$SRXLike::SREXT-Mr(Final_State)" => 1, "$SRXLike::SREXT-Mr(Initial_State)" => 1, 
	            "$SRXLike::SREXT-Mr(Experiencer)" => 1, "$SRXLike::SREXT-Mr(Extent)" => 1, "$SRXLike::SREXT-Mr(Goal)" => 1, 
	            "$SRXLike::SREXT-Mr(Instrument)" => 1, "$SRXLike::SREXT-Mr(Location)" => 1, "$SRXLike::SREXT-Mr(Initial_Location)" => 1, 
	            "$SRXLike::SREXT-Mr(Patient)" => 1, "$SRXLike::SREXT-Mr(Source)" => 1, "$SRXLike::SREXT-Mr(Theme)" => 1, 

	            "$SRXLike::SREXT-Or(*)" => 1, "$SRXLike::SREXT-Or(A0)" => 1, "$SRXLike::SREXT-Or(A1)" => 1,
	            "$SRXLike::SREXT-Or(A2)" => 1, "$SRXLike::SREXT-Or(A3)" => 1, "$SRXLike::SREXT-Or(A4)" => 1,
	            "$SRXLike::SREXT-Or(A5)" => 1, "$SRXLike::SREXT-Or(A6)" => 1, "$SRXLike::SREXT-Or(A7)" => 1, 
	            "$SRXLike::SREXT-Or(A8)" => 1, "$SRXLike::SREXT-Or(A9)" => 1, "$SRXLike::SREXT-Or(AM-LOC)" => 1, 
	            "$SRXLike::SREXT-Or(AM-TMP)" => 1, "$SRXLike::SREXT-Or(AM-MNR)" => 1, "$SRXLike::SREXT-Or(AM-ADV)" => 1, 
	            "$SRXLike::SREXT-Or(Attribute)" => 1, "$SRXLike::SREXT-Or(Beneficiary)" => 1, "$SRXLike::SREXT-Or(Cause)" => 1, 
	            "$SRXLike::SREXT-Or(Destination)" => 1, "$SRXLike::SREXT-Or(Final_State)" => 1, "$SRXLike::SREXT-Or(Initial_State)" => 1, 
	            "$SRXLike::SREXT-Or(Experiencer)" => 1, "$SRXLike::SREXT-Or(Extent)" => 1, "$SRXLike::SREXT-Or(Goal)" => 1, 
	            "$SRXLike::SREXT-Or(Instrument)" => 1, "$SRXLike::SREXT-Or(Location)" => 1, "$SRXLike::SREXT-Or(Initial_Location)" => 1, 
	            "$SRXLike::SREXT-Or(Patient)" => 1, "$SRXLike::SREXT-Or(Source)" => 1, "$SRXLike::SREXT-Or(Theme)" => 1, 

                "$SRXLike::SREXT-Ol" => 1, "$SRXLike::SREXT-Or(*)_b" => 1, "$SRXLike::SREXT-Or(*)_i" => 1,
                "$SRXLike::SREXT-Mr(*)_b" => 1, "$SRXLike::SREXT-Mr(*)_i" => 1, "$SRXLike::SREXT-Orv(*)_b" => 1,
                "$SRXLike::SREXT-Orv(*)_i" => 1, "$SRXLike::SREXT-Mrv(*)_b" => 1, "$SRXLike::SREXT-Mrv(*)_i" => 1,
                "$SRXLike::SREXT-Or_b" => 1, "$SRXLike::SREXT-Or_i" => 1, "$SRXLike::SREXT-Orv_b" => 1,
                "$SRXLike::SREXT-Orv_i" => 1,
                "$SRXLike::SREXT-Pr(*)" => 1, "$SRXLike::SREXT-Rr(*)" => 1, "$SRXLike::SREXT-Fr(*)" => 1,
                "$SRXLike::SREXT-MPr(*)" => 1, "$SRXLike::SREXT-MRr(*)" => 1, "$SRXLike::SREXT-MFr(*)" => 1,
                "$SRXLike::SREXT-Ora" => 1, "$SRXLike::SREXT-Mra(*)" => 1, "$SRXLike::SREXT-Ora(*)" => 1                
};

      

# ---------------------------------------------------------------------------------------------



sub FILE_create_input {
   #description _ creates the input file in conll format
   #param1  _ input file
   #param2  _ output conll file
   #param3  _ verbosity (0/1)
   #@return  _ number of lines processed
   
   my $input = shift;
   my $auxconllfile = shift;
   my $verbose = shift;

   open(CONLLFILE, "> $auxconllfile") or die "couldn't open CONLLFILE file: $auxconllfile\n";
   open(FILE, " < $input") or die "couldn't open input file: $input\n";

   my $iter = 0;
   while (my $line = <FILE>) {
      chomp($line);
      my @toks = split(' ', $line);
      
      my $wcount = 1;
      foreach my $w (@toks) {
   	  print CONLLFILE "$wcount $w\n";
   	  $wcount++;
      }
      print CONLLFILE "\n";

      if ($verbose > 1) {
         if (($iter%10) == 0) { print STDERR "."; }
         if (($iter%100) == 0) { print STDERR $iter; }
      }
      $iter++;
   }
   close(FILE);
   close(CONLLFILE);

   return $iter;
}

sub find_role_boundaries {
	my $DPtree = shift;
	my $head = shift;

	my $start = $head;
	my $end = $head;
	
	if (defined $DPtree->[$head] ){
		my @nodes = @{$DPtree->[$head]};
		foreach my $node (@nodes){
			my ($tmpstart,$tmpend) = find_role_boundaries ($DPtree, $node);
			$start = min($tmpstart,$start);
			$end = max($tmpend,$end);
		}
	}
	return ($start,$end);
}

sub extract_DP_subtrees
{
	#description: process the DPtrees to extract the beginning and end of the role chunks
        #the file structure contains only the head of the subtree, and it should contain the first and last word of the role chunk
	#the role range is defined as the complete subtree starting from the head
	#
	#param1 _ the DP tree
	#param2 _ the array of role heads for each role and verb

	my $DPtree = shift;
	my $rolestruct = shift;
	
	#for each verb
#	print STDERR "processing subtree\n";
#	print STDERR Dumper $rolestruct;

	for (my $vidx = 0; $vidx < scalar(@{$rolestruct}); $vidx++) {
	    if ( defined($rolestruct->[$vidx]) ){
		my %vhash = %{$rolestruct->[$vidx]};
		#for each role
		foreach my $rkey (keys %vhash) {
			my @rar = @{$vhash{$rkey}};
			#for each word
			my @updatedlist = ();
			for (my $widx=0; $widx < scalar(@rar); $widx++){
				my ($wstart,$wend) = find_role_boundaries($DPtree, ($rar[$widx]+1));
				push(@updatedlist,$wstart);
				push(@updatedlist,$wend);
			}
			$rolestruct->[$vidx]->{$rkey} = \@updatedlist;
		}
	    }
	    else{
		$rolestruct->[$vidx] =();
	    }
	}		
}

sub getRoleName 
{
	#description _ responsible to convert the tagger notation into Asiya notation
	#
	#param1 _ the role id
	#param2 _ the language
	#return _ the new role id
	
	my $roleid = shift;
	my $L = shift;
	
	if ( $L eq $Common::L_SPA ){
		if ( $roleid =~ m/arg0/ ){ return "A0"; }
		if ( $roleid =~ m/arg1/ ){ return "A1"; }
		if ( $roleid =~ m/arg2/ ){ return "A2"; }
		if ( $roleid =~ m/arg3/ ){ return "A3"; }
		if ( $roleid =~ m/arg4/ ){ return "A4"; }
		if ( $roleid =~ m/arg5/ ){ return "A5"; }
		if ( $roleid =~ m/arg6/ ){ return "A6"; }
		if ( $roleid =~ m/arg7/ ){ return "A7"; }
		if ( $roleid =~ m/arg8/ ){ return "A8"; }
		if ( $roleid =~ m/arg9/ ){ return "A9"; }
		if ( $roleid =~ m/argM-loc/ ){ return "AM-LOC"; }
		if ( $roleid =~ m/argM-tmp/ ){ return "AM-TMP"; }
		if ( $roleid =~ m/argM-mnr/ ){ return "AM-MNR"; }
		if ( $roleid =~ m/argM-adv/ ){ return "AM-ADV"; }
	}
	
	return uc($roleid);
}


sub parse_SR
{
    #description _ responsible for SR
    #              (WORD + PoS)  ->  (WORD + SR)
    #param1  _ tools directory pathname
    #param2  _ parser object
    #param3  _ parsing LANGUAGE 1
    #param4  _ case 1
    #param5  _ input file
    #param6  _ verbosity (0/1)

    my $tools = shift;
    my $parser = shift;
    my $L = shift;
    my $C = shift;
    my $input = shift;
    my $verbose = shift;

    my @FILE;

    my $srlfile = $input.".$SR::SREXT";
    
    if (($L eq $Common::L_SPA) or ($L eq $Common::L_CAT) ){
    	if ((!(-e $srlfile)) and (!(-e "$srlfile.$Common::GZEXT"))) {
	    
	    srand();
	    my $r = rand($Common::NRAND);
	    my $auxconllfile = "$Common::DATA_PATH/$Common::TMP/".basename("$input.$r"); 
	    my $numlines =  FILE_create_input($input, $auxconllfile, $verbose);
	    
	    Common::execute_or_die("cd $Common::DATA_PATH; $tools/$SRXLike::XLike $auxconllfile > $srlfile ", "[ERROR] problems running XLike Parser...");
#			system "rm -f $auxconllfile";
	    
	}
    }
    else { die "[SR] tool for <$L> unavailable!!!\n"; }
    
    if ((!(-e $srlfile)) and (-e "$srlfile.$Common::GZEXT")) { system("$Common::GUNZIP $srlfile.$Common::GZEXT"); }
    
    open(AUX, "< $srlfile") or die "couldn't open file: $srlfile\n";   
    
    my $numsent = 0;
    my $numword = 0;
    my @TAG;
    my @DPforest; 
    
    my $numline=0;
    while (my $line = <AUX>) {
	$numline++;
#	print STDERR "processing line $numline\n";
	chomp($line);
	if ($line =~ /^$/) { #end of sentence
#	    print STDERR "processing subtree number $numsent\n";
	    extract_DP_subtrees ( $DPforest[$numsent], \@{$FILE[$numsent]->{R}});
	    $numsent++; 
	    $numword = 0; 
	} 
	else {
	    my @entry = split(/[ ]+/, $line); #0:7 1:deja 2:dejar 3:VMIP3S0 4:cpos=V|postype=main|mood=indicative|tense=present|person=3|num=s 5:_ 6:3 7:cd 8:dejar.01 9:arg1-pat 10:arg1-pat
	    #save the DP tree
	    push(@{$DPforest[$numsent][$entry[6]]},$entry[0]);
	    # save word
	    my @l = ($entry[1], $entry[3], $entry[2]); 
	    push(@{$FILE[$numsent]->{S}}, \@l);
	    # save verb
	    if ($entry[8] ne "_") { my @l = ($numword, $entry[2]); push(@{$FILE[$numsent]->{V}}, \@l); }
	    #start processing items
	    my $roleidx = 9; #position of roles
	    my $verbidx = 0; #index of verbs
	    while ($roleidx < scalar(@entry)) {
		if ($entry[$roleidx] ne "_") {
		    # save role 
		    my $tag = getRoleName($entry[$roleidx], $L);
		    push(@{$FILE[$numsent]->{R}->[$verbidx]->{$tag}}, $numword);
		}
		$roleidx++; #next role
		$verbidx++; #belongs to next verb
	    }
	    $numword++;
	}
    }
    close(AUX);
    
    if (-e $srlfile) { system "$Common::GZIP $srlfile"; }
    
    return \@FILE;
}


1;

