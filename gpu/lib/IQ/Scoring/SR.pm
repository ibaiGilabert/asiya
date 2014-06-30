package SR;

# ------------------------------------------------------------------------

#Copyright (C) Jesus Gimenez

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

use IO::File;
use Unicode::String;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Overlap;
use IQ::Scoring::Metrics;
use IQ::Scoring::NE;


# SR for Spanish/Catalan
use IQ::Scoring::SRXLike;

our ($SREXT, $rSReng);

#my %FEATURES;
#$SR::rFEATURES = \%FEATURES;

$SR::SREXT = "SR";
$SR::SWIRL = "swirl-1.1.0";

# B-TAGS -> B-A0 B-A1 B-A2 B-A3 B-A4 B-A5 B-AA B-AM-ADV B-AM-CAU B-AM-DIR B-AM-DIS B-AM-EXT B-AM-LOC B-AM-MNR B-AM-MOD B-AM-NEG B-AM-PNC B-AM-PRD B-AM-REC B-AM-TMP B-C-A0 B-C-A1 B-C-A2 B-C-A3 B-C-AM-MNR B-R-A0 B-R-A1 B-R-A2 B-R-A3 B-R-AM-CAU B-R-AM-LOC B-R-AM-MNR B-R-AM-PNC B-R-AM-TMP

# ROLES -> A0 A1 A2 A3 A4 A5 AA AM-ADV AM-CAU AM-DIR AM-DIS AM-EXT AM-LOC AM-MNR AM-MOD AM-NEG AM-PNC AM-PRD AM-REC AM-TMP

$SR::rSReng = { "$SR::SREXT-Nv" => 1, "$SR::SREXT-Ov" => 1, "$SR::SREXT-Or" => 1, "$SR::SREXT-Orv" => 1,
	            "$SR::SREXT-Mrv(*)" => 1, "$SR::SREXT-Mrv(A0)" => 1, "$SR::SREXT-Mrv(A1)" => 1,
	            "$SR::SREXT-Mrv(A2)" => 1, "$SR::SREXT-Mrv(A3)" => 1, "$SR::SREXT-Mrv(A4)" => 1,
	            "$SR::SREXT-Mrv(A5)" => 1, "$SR::SREXT-Mrv(AA)" => 1, "$SR::SREXT-Mrv(AM-ADV)" => 1,
	            "$SR::SREXT-Mrv(AM-CAU)" => 1, "$SR::SREXT-Mrv(AM-DIR)" => 1, "$SR::SREXT-Mrv(AM-DIS)" => 1,
	            "$SR::SREXT-Mrv(AM-EXT)" => 1, "$SR::SREXT-Mrv(AM-LOC)" => 1, "$SR::SREXT-Mrv(AM-MNR)" => 1,
	            "$SR::SREXT-Mrv(AM-MOD)" => 1, "$SR::SREXT-Mrv(AM-NEG)" => 1, "$SR::SREXT-Mrv(AM-PNC)" => 1,
	            "$SR::SREXT-Mrv(AM-PRD)" => 1, "$SR::SREXT-Mrv(AM-REC)" => 1, "$SR::SREXT-Mrv(AM-TMP)" => 1,
	            "$SR::SREXT-Orv(*)" => 1, "$SR::SREXT-Orv(A0)" => 1, "$SR::SREXT-Orv(A1)" => 1,
	            "$SR::SREXT-Orv(A2)" => 1, "$SR::SREXT-Orv(A3)" => 1, "$SR::SREXT-Orv(A4)" => 1,
	            "$SR::SREXT-Orv(A5)" => 1, "$SR::SREXT-Orv(AA)" => 1, "$SR::SREXT-Orv(AM-ADV)" => 1,
	            "$SR::SREXT-Orv(AM-CAU)" => 1, "$SR::SREXT-Orv(AM-DIR)" => 1, "$SR::SREXT-Orv(AM-DIS)" => 1,
	            "$SR::SREXT-Orv(AM-EXT)" => 1, "$SR::SREXT-Orv(AM-LOC)" => 1, "$SR::SREXT-Orv(AM-MNR)" => 1,
	            "$SR::SREXT-Orv(AM-MOD)" => 1, "$SR::SREXT-Orv(AM-NEG)" => 1, "$SR::SREXT-Orv(AM-PNC)" => 1,
	            "$SR::SREXT-Orv(AM-PRD)" => 1, "$SR::SREXT-Orv(AM-REC)" => 1, "$SR::SREXT-Orv(AM-TMP)" => 1,
	            "$SR::SREXT-Mr(*)" => 1, "$SR::SREXT-Mr(A0)" => 1, "$SR::SREXT-Mr(A1)" => 1,
	            "$SR::SREXT-Mr(A2)" => 1, "$SR::SREXT-Mr(A3)" => 1, "$SR::SREXT-Mr(A4)" => 1,
	            "$SR::SREXT-Mr(A5)" => 1, "$SR::SREXT-Mr(AA)" => 1, "$SR::SREXT-Mr(AM-ADV)" => 1,
	            "$SR::SREXT-Mr(AM-CAU)" => 1, "$SR::SREXT-Mr(AM-DIR)" => 1, "$SR::SREXT-Mr(AM-DIS)" => 1,
	            "$SR::SREXT-Mr(AM-EXT)" => 1, "$SR::SREXT-Mr(AM-LOC)" => 1, "$SR::SREXT-Mr(AM-MNR)" => 1,
	            "$SR::SREXT-Mr(AM-MOD)" => 1, "$SR::SREXT-Mr(AM-NEG)" => 1, "$SR::SREXT-Mr(AM-PNC)" => 1,
	            "$SR::SREXT-Mr(AM-PRD)" => 1, "$SR::SREXT-Mr(AM-REC)" => 1, "$SR::SREXT-Mr(AM-TMP)" => 1,
	            "$SR::SREXT-Or(*)" => 1, "$SR::SREXT-Or(A0)" => 1, "$SR::SREXT-Or(A1)" => 1,
	            "$SR::SREXT-Or(A2)" => 1, "$SR::SREXT-Or(A3)" => 1, "$SR::SREXT-Or(A4)" => 1,
	            "$SR::SREXT-Or(A5)" => 1, "$SR::SREXT-Or(AA)" => 1, "$SR::SREXT-Or(AM-ADV)" => 1,
	            "$SR::SREXT-Or(AM-CAU)" => 1, "$SR::SREXT-Or(AM-DIR)" => 1, "$SR::SREXT-Or(AM-DIS)" => 1,
	            "$SR::SREXT-Or(AM-EXT)" => 1, "$SR::SREXT-Or(AM-LOC)" => 1, "$SR::SREXT-Or(AM-MNR)" => 1,
	            "$SR::SREXT-Or(AM-MOD)" => 1, "$SR::SREXT-Or(AM-NEG)" => 1, "$SR::SREXT-Or(AM-PNC)" => 1,
	            "$SR::SREXT-Or(AM-PRD)" => 1, "$SR::SREXT-Or(AM-REC)" => 1, "$SR::SREXT-Or(AM-TMP)" => 1, 
                "$SR::SREXT-Ol" => 1, "$SR::SREXT-Or(*)_b" => 1, "$SR::SREXT-Or(*)_i" => 1,
                "$SR::SREXT-Mr(*)_b" => 1, "$SR::SREXT-Mr(*)_i" => 1, "$SR::SREXT-Orv(*)_b" => 1,
                "$SR::SREXT-Orv(*)_i" => 1, "$SR::SREXT-Mrv(*)_b" => 1, "$SR::SREXT-Mrv(*)_i" => 1,
                "$SR::SREXT-Or_b" => 1, "$SR::SREXT-Or_i" => 1, "$SR::SREXT-Orv_b" => 1,
                "$SR::SREXT-Orv_i" => 1,
                "$SR::SREXT-Pr(*)" => 1, "$SR::SREXT-Rr(*)" => 1, "$SR::SREXT-Fr(*)" => 1,
                "$SR::SREXT-MPr(*)" => 1, "$SR::SREXT-MRr(*)" => 1, "$SR::SREXT-MFr(*)" => 1,
                "$SR::SREXT-Ora" => 1, "$SR::SREXT-Mra(*)" => 1, "$SR::SREXT-Ora(*)" => 1                
};

      


sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;
    if ($language eq $Common::L_ENG) { %metric_set = %{$SR::rSReng}; }
    elsif  ($language eq $Common::L_SPA) { %metric_set = %{$SRXLike::rSRspacat}; }
    elsif  ($language eq $Common::L_CAT) { %metric_set = %{$SRXLike::rSRspacat}; }

    return \%metric_set;
}

sub SNT_extract_features {
   #description _ extracts features from a given SR-parsed sentence.
   #param1  _ sentence
   #@return _ sentence (+features)

   my $snt = shift;
	
   my %SNT;
   if (defined($snt)) {
      if (exists($snt->{R})) {
         my $i = 0;
         while ($i < scalar(@{$snt->{R}})) { #$i -> num of predicates
            my $verb = $snt->{V}->[$i]->[1]; #verb of the predicate
            foreach my $role (keys %{$snt->{R}->[$i]}) { #each role of the predicate $i
		my $cleanrole = $role;
		$cleanrole =~ s/^C-//g;    # C - continuation ARGUMENTS
		$cleanrole =~ s/^R-//g;    # R - reference ARGUMENTS
		my $j = 0;
		while ($j < scalar(@{$snt->{R}->[$i]->{$role}})) { 
		  my @Rwords;
                  my $k = $snt->{R}->[$i]->{$role}->[$j];
		  my $k_end = defined($snt->{R}->[$i]->{$role}->[$j+1]) ? $snt->{R}->[$i]->{$role}->[$j+1]:$k;
		  #print STDERR "\tk is $k, kend is $k_end, role is $role\n";
		  #print STDERR Dumper $snt->{R}->[$i];
                  while ( $k <= $k_end ) {
                     my $word = $snt->{S}->[$k]->[0];
						   if ( defined($word)){
							 #bags-of-words ---------------
							 $SNT{bow}->{$cleanrole}->{$word}++;
							 $SNT{Vbow}->{$cleanrole}->{$verb."##".$word}++;
							 $SNT{Abow}->{$cleanrole."##".$i}->{$word}++;
							 push(@Rwords, $word);
						   }
						   #bag-of-roles ---------------
						   $SNT{bor}->{$cleanrole}++;
						   $SNT{Vbor}->{$verb."##".$cleanrole}++;
						   $SNT{Abor}->{$cleanrole."##".$i}++;
						   $k++;
                  }
                  #exact role matches -----------------------
                  $SNT{exact}->{$cleanrole}->{join(" ", @Rwords)}++;
                  $SNT{Vexact}->{$cleanrole}->{$verb."##".join(" ", @Rwords)}++;
                  $SNT{Aexact}->{$cleanrole."##".$i}->{join(" ", @Rwords)}++;
                  $j += 2;
               }
            }
            $i++;
         }
      }
      $SNT{nVerbs} = 0;
      if (exists($snt->{V})) {
         $SNT{nVerbs} = scalar(@{$snt->{V}});
         foreach my $elem (@{$snt->{V}}) { $SNT{Verbs}->{$elem->[1]}++; }
      }
      if (exists($snt->{S})) { #only for lexical overlap (e.g., to backoff when parsing fails) 
      	 my $i = 0;
      	 while ($i < scalar(@{$snt->{S}})) {
				my $theword = $snt->{S}->[$i]->[0];
	     		if ( defined ( $theword )){
		 			$SNT{BOW}->{$theword} = ( defined ($SNT{BOW}->{$theword})) ? $SNT{BOW}->{$theword}+1 : 1; 
	     		}
	     		$i++;
      	 } 
      }
   }

   #print Dumper %SNT;
   return \%SNT;
}


# ---------------------------------------------------------------------------------------------

sub find_alignedverb {
   #description _ find the number of aligned words for each role in the sentence
   #param1  _ start word in origin
	#param2 _ end word in origin
	#param3 _ array of roles and words in each role for the dest sentence   
	#param4 _ alignments hash reference

	my $verb_pos = shift;
	my $sentverbs = shift;
	my $alignments = shift;

	my $res = -1;
	if ( exists ( $alignments->{$verb_pos} )) {
		my @Ldest = @{$alignments->{$verb_pos}}; #list of aligned words in dest
		for my $pred_i (0 ..  scalar(@{$sentverbs})-1 ) { #$pred_i -> num of predicates
			my $pos = $sentverbs->[$pred_i]->[0]; #position of the current verb
			for my $i ( @Ldest ){
				if ( $i == $pos ){ $res = $pred_i; }
			}
		}
	}
	return $res;	
}

sub find_num_alignedwords {
   #description _ find the number of aligned words for each role in the sentence
   #param1  _ start word in origin
	#param2 _ end word in origin
	#param3 _ array of roles and words in each role for the dest sentence   
	#param4 _ alignments hash reference
	
	my $startw = shift;
	my $endw = shift;
	my $verbpos = shift;
	my $sentroles = shift;
	my $alignments = shift;	
	

	#print Dumper $sentroles;
	#print Dumper $alignments;
	
	my %TALIGN;
	
	for my $orig_i ( $startw .. $endw ){
		if ( exists ( $alignments->{$orig_i} )) {
			my @Ldest_i = @{$alignments->{$orig_i}}; #list of aligned words in dest
			for my $pred_i (0 ..  scalar(@{$sentroles})-1 ) { #$pred_i -> num of predicates in the first sentence
				#search only if it is the predicate than the aligned verb or in all the predicates if the verb was not aligned 
				if ( $verbpos < 0 || $verbpos == $pred_i ){
		         foreach my $dest_role (keys %{$sentroles->[$pred_i]}) { #each role of the predicate $i
	  	            my $cleanrole = $dest_role;
		            $cleanrole =~ s/^C-//g;    # C - continuation ARGUMENTS
			         $cleanrole =~ s/^R-//g;    # R - reference ARGUMENTS
		            
		            my $numaligned=0;
		            my $j = 0;
		            while ($j < scalar(@{$sentroles->[$pred_i]->{$dest_role}})) { # each argument for the role 
							my $dest_start = $sentroles->[$pred_i]->{$dest_role}->[$j];
							my $dest_end = $sentroles->[$pred_i]->{$dest_role}->[$j+1];
							for my $dest_i ( @Ldest_i ){
								if ( $dest_i >= $dest_start && $dest_i <= $dest_end ){
									$numaligned++;
								}
							}
		               #next segment
		               $j += 2;
		            }
		            if ( exists( $TALIGN{$cleanrole."##".$pred_i} )){ $TALIGN{$cleanrole."##".$pred_i} += $numaligned;	}
		           	else{ $TALIGN{$cleanrole."##".$pred_i} = $numaligned; }
		         }
		      }
	      }
		}
	}
	return \%TALIGN;
}
sub SNT_extract_aligned_arguments{
   #description _ extracts the alignments between the arguments of the two sentences
   #param1  _ alignments
	#param2 _ sentence 1
	#param3 _ sentence 2   
	
	
	my $alignments = shift;
	my $snt1 = shift;
	my $snt2 = shift;

	#print "alignments \n";
	#print Dumper $alignments;
	#print "----\n";
	#print Dumper $snt1;
	
	my %Taligned;

   if ( defined($snt1) && defined ($snt2) ) {
      if ( exists($snt1->{R}) && exists($snt2->{R} ) ){ #arguments
         for my $i (0 ..  scalar(@{$snt1->{R}})-1 ) { #$i -> num of predicates in the first sentence
            my $verb1_pos = $snt1->{V}->[$i]->[0]; #verb of the predicate of the first sentence
            my $verb2_pos = find_alignedverb ( $verb1_pos, $snt2->{V}, $alignments ) ; #
            
				if ( $verb2_pos >= 0 ) {
					my $verb1 = $snt1->{V}->[$i]->[1]; #verb of the predicate of the first sentence 
					my $verb2 = $snt2->{V}->[$verb2_pos]->[1]; #verb of the predicate of the first sentence	
					$Taligned{$verb1."##".$i} = [$verb2,1]; 
				}
					
            foreach my $role1 (keys %{$snt1->{R}->[$i]}) { #each role of the predicate $i
            	my %Awords;
               my $cleanrole = $role1;
               $cleanrole =~ s/^C-//g;    # C - continuation ARGUMENTS
   	         $cleanrole =~ s/^R-//g;    # R - reference ARGUMENTS
               my $j = 0;
               while ($j < scalar(@{$snt1->{R}->[$i]->{$role1}})) { # each argument for the role 
						my $start = $snt1->{R}->[$i]->{$role1}->[$j];
						my $end = $snt1->{R}->[$i]->{$role1}->[$j+1];
						#find the alignments in the sentence2
                  my $alignedwords = find_num_alignedwords ( $start, $end, $verb2_pos, $snt2->{R}, $alignments ) ; #
                  # %Awords = %Awords + %alignedwords
                  foreach my $arole ( keys %{$alignedwords} ){
                  	if ( exists($Awords{$arole} )){ $Awords{$arole} += $alignedwords->{$arole}; }
                  	else{ $Awords{$arole} = $alignedwords->{$arole}; }
                  }
                  #next segment
                  $j += 2;
               }
               #print "Table of aligned words for $cleanrole in predicate $i aligned with predicate $verb2_pos\n";
               #print Dumper %Awords;
                 
               #find the role having the maximum number of alignments
               my $role2="";
               my $num=0;
					foreach my $arole ( keys %Awords ){
						if ( $Awords{$arole} > $num ) {
							$role2 = $arole;
							$num = $Awords{$arole};
						}
					}
					if ( $num > 0 ) { $Taligned{$role1."##".$i} = [$role2,$num]; }               
            }
         }
		}
	}	

	#print "alignments table\n";
	#print Dumper %Taligned;
	return \%Taligned;
}


sub SNT_compute_align_scores {
   #description _ computes distances between a candidate and a reference sentence (+features)
	#param1 _ table of aligned arguments [hash reference]
   #param2 _ candidate sentence (+features)
   #param3 _ reference sentence (+features)
   #param4 _ language
   #param5 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

	my $candrefaligns = shift;   
   my $Tout = shift;
   my $Tref = shift;
   my $LANG = shift;
   my $LC = shift;

   my %SCORES;

   if ((scalar(keys %{$Tref}) != 0) and (scalar(keys %{$Tout}) != 0)) {  # BOTH SEGMENTS AVAILABLE

      # BOTH SEGMENTS HAVE BEEN 'SUCCESSFULLY' SR-PARSED? (BOW for lexical overlap is always there)
      if ((scalar(keys %{$Tref}) > 1) and (scalar(keys %{$Tout}) > 1)) { $SCORES{OK} = 1; }
      else { $SCORES{OK} = 0; }
  
      #SR::SREXT-Ora ----------------------------------------------------------------------------------
		#rename  the arguments in the arrays
		my %Fout; my %Fref;
      foreach my $N (keys %{$Tout->{Abor}}) { $Fout{$N} = 1; }
      foreach my $M (keys %{$Tref->{Abor}}) { $Fref{$M} = 1; }
      my %newout;
		my %newref;
      foreach my $N (keys %Fout) {
      	if ( exists ($candrefaligns->{$N}) ){
      		my $M = $candrefaligns->{$N}->[0];
      		$newout{$M} = $Tout->{Abor}->{$N}; # save as M
      		$newref{$M} = $Tref->{Abor}->{$M}; # keep as M
      		delete($Fout{$N}); delete($Fref{$M});
      	}
		}
		#save the unaligned
      foreach my $N (keys %Fout){ $newout{"unaligned"} = $Tout->{Abor}->{$N}; }
      foreach my $M (keys %Fref){ $newref{"unaligned"} = $Tref->{Abor}->{$M}; }
      my ($hits, $total) = Overlap::compute_overlap(\%newout, \%newref, 0);
      $SCORES{"$SR::SREXT-Ora"} = Common::safe_division($hits, $total);
        

      #SR::SREXT-Mra(*) ----------------------------------------------------------------------------------
      my $HITS = 0;    my $TOTAL = 0;      my %F = ();
      foreach my $N (keys %{$Tout->{Aexact}}) { $Fout{$N} = 1; }
      foreach my $M (keys %{$Tref->{Aexact}}) { $Fref{$M} = 1; }
      foreach my $N (keys %Fout) {
      	if ( exists ($candrefaligns->{$N}) ){
      		my $M = $candrefaligns->{$N}->[0];
         	my ($hits, $total) = Overlap::compute_overlap($Tout->{Aexact}->{$N}, $Tref->{Aexact}->{$M}, $LC);
         	$HITS += $hits; $TOTAL += $total;
         	delete($Fout{$N}); delete($Fref{$M});
         }
      }
      #mgb what do we do with the other unaligned segments?

      $SCORES{"$SR::SREXT-Mra(*)"} = Common::safe_division($HITS, $TOTAL);

      #SR::SREXT-Ora(*) ----------------------------------------------------------------------------------
      $HITS = 0;    $TOTAL = 0;      %F = ();
      foreach my $N (keys %{$Tout->{Abow}}) { $F{$N} = 1; }
      foreach my $M (keys %{$Tref->{Abow}}) { $F{$M} = 1; }
      foreach my $N (keys %F) {
      	if ( exists ($candrefaligns->{$N}) ){
      		my $M = $candrefaligns->{$N}->[0];
	         my ($hits, $total) = Overlap::compute_overlap($Tout->{Abow}->{$N}, $Tref->{Abow}->{$M}, $LC);
   	      $HITS += $hits; $TOTAL += $total;
   	      delete($Fout{$N}); delete($Fref{$M});
   	   }
      }
      $SCORES{"$SR::SREXT-Ora(*)"} = Common::safe_division($HITS, $TOTAL);
   }

   return \%SCORES;
}

# -----------------------------------------------------------------------


sub SNT_compute_overlap_scores {
   #description _ computes distances between a candidate and a reference sentence (+features)
   #param1 _ candidate sentence (+features)
   #param2 _ reference sentence (+features)
   #param3 _ language
   #param4 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $Tout = shift;
   my $Tref = shift;
   my $LANG = shift;
   my $LC = shift;

   my %SCORES;

   if ((scalar(keys %{$Tref}) != 0) and (scalar(keys %{$Tout}) != 0)) {  # BOTH SEGMENTS AVAILABLE

      # BOTH SEGMENTS HAVE BEEN 'SUCCESSFULLY' SR-PARSED? (BOW for lexical overlap is always there)
      if ((scalar(keys %{$Tref}) > 1) and (scalar(keys %{$Tout}) > 1)) { $SCORES{OK} = 1; }
      else { $SCORES{OK} = 0; }

      #SR::SREXT-Nv ---------------------------------------------------------------------------------
      my $diff = abs($Tref->{nVerbs} - $Tout->{nVerbs});
      $SCORES{"$SR::SREXT-Nv"} = 1 / (($diff == 0)? 1 : $diff);

      #SR::SREXT-Ov --------------------------------------------------------------------------------
      my ($hits, $total) = Overlap::compute_overlap($Tout->{Verbs}, $Tref->{Verbs}, 0);
      $SCORES{"$SR::SREXT-Ov"} = Common::safe_division($hits, $total);  

      #SR::SREXT-Or --------------------------------------------------------------------------------
      ($hits, $total) = Overlap::compute_overlap($Tout->{bor}, $Tref->{bor}, 0);
      $SCORES{"$SR::SREXT-Or"} = Common::safe_division($hits, $total);

      #SR::SREXT-Orv ----------------------------------------------------------------------------------
      ($hits, $total) = Overlap::compute_overlap($Tout->{Vbor}, $Tref->{Vbor}, 0);
      $SCORES{"$SR::SREXT-Orv"} = Common::safe_division($hits, $total);  

      #SR::SREXT-Mr(*) ----------------------------------------------------------------------------------
      my $HITS = 0;    my $TOTAL = 0;
      my $PHITS = 0;   my $PTOTAL = 0;
      my $RHITS = 0;   my $RTOTAL = 0;
      my %F;
      foreach my $N (keys %{$Tout->{exact}}) { $F{$N} = 1; }
      foreach my $N (keys %{$Tref->{exact}}) { $F{$N} = 1; }
      foreach my $N (keys %F) {
         my ($hits, $total) = Overlap::compute_overlap($Tout->{exact}->{$N}, $Tref->{exact}->{$N}, $LC);
         $SCORES{"$SR::SREXT-Mr($N)"} = Common::safe_division($hits, $total);
         $HITS += $hits; $TOTAL += $total;
         my ($phits, $ptotal) = Overlap::compute_precision($Tout->{exact}->{$N}, $Tref->{exact}->{$N}, $LC);
         #my $p = Common::safe_division($phits, $ptotal);
         #$SCORES{"$SR::SREXT-MPr($N)"} = $p;
         $PHITS += $phits; $PTOTAL += $ptotal;
         my ($rhits, $rtotal) = Overlap::compute_recall($Tout->{exact}->{$N}, $Tref->{exact}->{$N}, $LC);
         #my $r = Common::safe_division($rhits, $rtotal);
         #$SCORES{"$SR::SREXT-MRr($N)"} = $r;
         $RHITS += $rhits; $RTOTAL += $rtotal;
         #$SCORES{"$SR::SREXT-MFr($N)"} = Common::f_measure($p, $r, 1);
      }
      $SCORES{"$SR::SREXT-Mr(*)"} = Common::safe_division($HITS, $TOTAL);
      my $P = Common::safe_division($PHITS, $PTOTAL);
      $SCORES{"$SR::SREXT-MPr(*)"} = $P;
      my $R = Common::safe_division($RHITS, $RTOTAL);
      $SCORES{"$SR::SREXT-MRr(*)"} = $R;
      $SCORES{"$SR::SREXT-MFr(*)"} = Common::f_measure($P, $R, 1);

      #SR::SREXT-Or(*) ----------------------------------------------------------------------------------
      $HITS = 0;    $TOTAL = 0;
      $PHITS = 0;   $PTOTAL = 0;
      $RHITS = 0;   $RTOTAL = 0;
      %F = ();
      foreach my $N (keys %{$Tout->{bow}}) { $F{$N} = 1; }
      foreach my $N (keys %{$Tref->{bow}}) { $F{$N} = 1; }
      foreach my $N (keys %F) {
         my ($hits, $total) = Overlap::compute_overlap($Tout->{bow}->{$N}, $Tref->{bow}->{$N}, $LC);
         $SCORES{"$SR::SREXT-Or($N)"} = Common::safe_division($hits, $total);
         $HITS += $hits; $TOTAL += $total;
         my ($phits, $ptotal) = Overlap::compute_precision($Tout->{bow}->{$N}, $Tref->{bow}->{$N}, $LC);
         #my $p = Common::safe_division($phits, $ptotal);
         #$SCORES{"$SR::SREXT-Pr($N)"} = $p;
         $PHITS += $phits; $PTOTAL += $ptotal;
         my ($rhits, $rtotal) = Overlap::compute_recall($Tout->{bow}->{$N}, $Tref->{bow}->{$N}, $LC);
         #my $r = Common::safe_division($rhits, $rtotal);
         #$SCORES{"$SR::SREXT-Rr($N)"} = $r;
         $RHITS += $rhits; $RTOTAL += $rtotal;
         #$SCORES{"$SR::SREXT-Fr($N)"} = Common::f_measure($p, $r, 1);
      }
      $SCORES{"$SR::SREXT-Or(*)"} = Common::safe_division($HITS, $TOTAL);
      $P = Common::safe_division($PHITS, $PTOTAL);
      $SCORES{"$SR::SREXT-Pr(*)"} = $P;
      $R = Common::safe_division($RHITS, $RTOTAL);
      $SCORES{"$SR::SREXT-Rr(*)"} = $R;
      $SCORES{"$SR::SREXT-Fr(*)"} = Common::f_measure($P, $R, 1);

      #SR::SREXT-Mrv(*) ----------------------------------------------------------------------------------
      $HITS = 0;    $TOTAL = 0;      %F = ();
      foreach my $N (keys %{$Tout->{Vexact}}) { $F{$N} = 1; }
      foreach my $N (keys %{$Tref->{Vexact}}) { $F{$N} = 1; }
      foreach my $N (keys %F) {
         my ($hits, $total) = Overlap::compute_overlap($Tout->{Vexact}->{$N}, $Tref->{Vexact}->{$N}, $LC);
         $SCORES{"$SR::SREXT-Mrv($N)"} = Common::safe_division($hits, $total);
         $HITS += $hits; $TOTAL += $total;
      }
      $SCORES{"$SR::SREXT-Mrv(*)"} = Common::safe_division($HITS, $TOTAL);

      #SR::SREXT-Orv(*) ----------------------------------------------------------------------------------
      $HITS = 0;    $TOTAL = 0;      %F = ();
      foreach my $N (keys %{$Tout->{Vbow}}) { $F{$N} = 1; }
      foreach my $N (keys %{$Tref->{Vbow}}) { $F{$N} = 1; }
      foreach my $N (keys %F) {
         my ($hits, $total) = Overlap::compute_overlap($Tout->{Vbow}->{$N}, $Tref->{Vbow}->{$N}, $LC);
         $SCORES{"$SR::SREXT-Orv($N)"} = Common::safe_division($hits, $total);
         $HITS += $hits; $TOTAL += $total;
      }
      $SCORES{"$SR::SREXT-Orv(*)"} = Common::safe_division($HITS, $TOTAL);

      #SR::SREXT-Ol ------------------------------------------------------------------------------------
      # lexical overlap alone
      ($HITS, $TOTAL) = Overlap::compute_overlap($Tout->{BOW}, $Tref->{BOW}, $LC);
      $SCORES{"$SR::SREXT-Ol"} = Common::safe_division($HITS, $TOTAL);
      
   }

   return \%SCORES;
}


sub FILE_compute_overlap_metrics {
   #description _ computes CHUNK scores (single reference)
   #param1 _ candidate list of parsed sentences (+features)
   #param2 _ reference list of parsed sentences (+features)
   #param3 _ language
   #param4 _ do_lower_case evaluation ( 1:yes -> case_insensitive  ::  0:no -> case_sensitive )
   #param5 _ doalign
   #param6 _ cand->ref aligns
   
   my $POUT = shift;
   my $PREF = shift;
   my $LANG = shift;
   my $LC = shift;
	my $CandRefAligns = shift;
	
#   print Dumper($POUT);
#   print Dumper($PREF);


   my @SCORES;
   my @SCORES2;
   my $topic = 0;
   while ($topic < scalar(@{$PREF})) {
      #print STDERR "*********** ", $topic + 1, " / ", scalar(@{$PREF}), "**********\n";
      #print Dumper $POUT->[$topic];
      #print STDERR "processing the system\n";
      my $OUTSNT = SNT_extract_features($POUT->[$topic]);
      #print Dumper $OUTSNT;
      #print "---------------------------------------------------------\n";
      #print Dumper $FREF->[$topic];
      #print STDERR "processing the reference\n";
      my $REFSNT = SNT_extract_features($PREF->[$topic]);
      #print Dumper $REFSNT;
      #print "---------------------------------------------------------\n";
      $SCORES[$topic] = SNT_compute_overlap_scores($OUTSNT, $REFSNT, $LANG, $LC);
      #print "---------------------------------------------------------\n";
      #mgb my $alignments = SNT_extract_aligned_arguments($CandRefAligns->{$topic+1}, $POUT->[$topic], $PREF->[$topic] );
		#mgb $SCORES2[$topic] = SNT_compute_align_scores($alignments, $OUTSNT, $REFSNT, $LANG, $LC);
		#print Dumper $SCORES2[$topic];
		
      foreach my $f (keys %{$SCORES2[$topic]}) { $SCORES[$topic]->{$f} = $SCORES2[$topic]->{$f}; }
      $topic++;
   }

   return \@SCORES;
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

    # -------------- FILES -----------------------------------------------------

    my @FILE;

    my $wpnercfile = $input.".$NE::NEEXT.wpn";
    my $srlfile = $input.".$SR::SREXT";
    my $wpnsrlfile = $input.".$SR::SREXT.wpn";
    my $wplcnercfile = $input.".$NE::NEEXT.wplcn";

    my $NERC = NE::FILE_parse_and_read($input, $parser, $tools, $L, $C, $verbose);

    my @WPLCN;

    # -------------- WPLCN -----------------------------------------------------
    if (!(-e $wplcnercfile) and (-e $wplcnercfile.".$Common::GZEXT")) { system "$Common::GUNZIP $wplcnercfile.$Common::GZEXT"; }

    open(WPLCN, "< $wplcnercfile") or die "couldn't open file: $wplcnercfile\n";
    open(CAND, "< $input") or die "couldn't open file: $input\n";
    
    my $i = 0;
    my $EMPTY = 1;
    my $candline = <CAND>;
    while (my $line = <WPLCN>) {
       if ($line =~ /^$/) {
	  	 	if ($EMPTY) { #empty sentence
  	     		my @l = ($Common::EMPTY_ITEM, $Common::EMPTY_ITEM, $Common::EMPTY_ITEM, "O", "O");     # W P L C NE  (empty)
            push(@{$WPLCN[$i]}, \@l);
            $EMPTY = 0;
         }
		   else { #sentence separator
		      $EMPTY = 1;
		      $i++;
		      #read next line in CAND
		   	$candline = <CAND>; 
			   # if it contains only punctuation, add the asterisk at the beginning to prevent parser failure
	 		 	if ( $candline && $candline =~ m/^[\s[:punct:]]*$/ ){
	 		 		# add the asterisk
	  	     		my @l = ("*", "*", "*", "O", "O");     # W P L C NE  (empty)
				   push(@{$WPLCN[$i]}, \@l);
			 	}
		   }
       }
       else {
       	chomp($line);
         my @entry = split(" ", $line);
         push(@{$WPLCN[$i]}, \@entry);     # W P L C NE
         $EMPTY = 0;
       }
    }
    close(WPLCN);
    close(CAND);
    if (-e $wplcnercfile) { system "$Common::GZIP $wplcnercfile"; }

    # -------------------------------------------------------------------------

    if ((!(-e $srlfile)) and (!(-e "$srlfile.$Common::GZEXT"))) {
       #if (!(-e $wpnercfile) and (-e $wpnercfile.".$Common::GZEXT")) { system "$Common::GUNZIP $wpnercfile.$Common::GZEXT"; }

       open(AUX, "> $wpnsrlfile") or die "couldn't open file: $wpnsrlfile\n";
       $i = 0;
       foreach my $snt (@WPLCN) {
          my @line;
		  	 my $countw = 0;
          foreach my $elem (@{$snt}) {
             my $word = $elem->[0]; $word =~ s/\"/\\\"/g;
             my $pos = $elem->[1]; $pos =~ s/\"/\\\"/g;
             my $ne = $elem->[4]; $ne =~ s/\"/\\\"/g;
             push(@line, "$word $pos $ne");
				  $countw++;
				  if ($countw >= 400 ) { last; }
          }
          print AUX "1 ", join(" ", @line), "\n";
       }
       close(AUX);

       if ($L eq $Common::L_ENG) {
          if ((!(-e $srlfile)) and (!(-e "$srlfile.$Common::GZEXT"))) {
             Common::execute_or_die("cd $Common::DATA_PATH; $tools/$SR::SWIRL/src/bin/swirl_parse_classify".(($C eq $Common::CASE_CI)? " --case-insensitive" : "")." $tools/$SR::SWIRL/model_swirl $tools/$SR::SWIRL/model_charniak $wpnsrlfile > $srlfile ", "[ERROR] problems running SwiRL...");
          }
       }
       else { die "[SR] tool for <$L> unavailable!!!\n"; }

       if (-e $wpnsrlfile) { system "rm -f $wpnsrlfile"; }
       #if (-e $wpnercfile) { system("$Common::GZIP $wpnercfile"); }
    }

    if ((!(-e $srlfile)) and (-e "$srlfile.$Common::GZEXT")) { system("$Common::GUNZIP $srlfile.$Common::GZEXT"); }

    open(AUX, "< $srlfile") or die "couldn't open file: $srlfile\n";
    $i = 0;
    my $j = 0;
    my @TAG;
    while (my $line = <AUX>) {
       chomp($line);
       if ($line =~ /^$/) { $i++; $j = 0; if (defined($WPLCN[$i-1])) { $FILE[$i-1]->{S} = $WPLCN[$i-1]; } }
       else {
          my @entry = split(/[\t]+/, $line);
          if ($entry[0] ne "-") { my @l = ($j, $entry[0]); push(@{$FILE[$i]->{V}}, \@l); }
          my $k = 1;
          while ($k < scalar(@entry)) {
	     		if ($entry[$k] ne "*") {
                my @tag = split(/[\(\*]/, $entry[$k]);
                if ($entry[$k] =~ /\(.*\)/) {
		   			push(@{$FILE[$i]->{R}->[$k-1]->{$tag[1]}}, $j);
					 }
                else {
                   if ($tag[1] eq ")") { push(@{$FILE[$i]->{R}->[$k-1]->{$TAG[$k-1]}}, $j); }
  	  	   			 else { push(@{$FILE[$i]->{R}->[$k-1]->{$tag[1]}}, $j); $TAG[$k-1] = $tag[1]; }
	        		 }
	     		}
	     		$k++;
	  		}
         $j++;
       }
    }
    close(AUX);

    if (-e $srlfile) { system "$Common::GZIP $srlfile"; }

	 #print "srlfile: $srlfile\n";
    #print Dumper \@FILE;

    return \@FILE;
}

sub doMultiSR {
   #description _ computes SR scores (multiple references)
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param5  _ hash of scores

   my $config = shift;
   my $TGT = shift;
   my $out = shift;
   my $REF = shift;
   my $Href = shift;
	my $hOQ = shift;
	
   my $src = $config->{src};                    # source file 
   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $parser = $config->{parser};              # shallow parser (object)
   my $M = $config->{Hmetrics};                 # set of metrics
   my $L = $config->{LANG};                     # language
   my $C = $config->{CASE};                     # case
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $rF;
   if (($L eq $Common::L_SPA) or ($L eq $Common::L_CAT)) { $rF = $SRXLike::rSRspacat; }
   else { $rF = $SR::rSReng; }


   my $GO_ON = 0;
   foreach my $metric (keys %{$rF}) {
      if ($M->{$metric}) { $GO_ON = 1; }
   }

   if ($GO_ON) {
      if ($verbose == 1) { print STDERR "$SR::SREXT.."; }

      my $DO_METRICS = $remakeREPORTS;
      if (!$DO_METRICS) {
         foreach my $metric (keys %{$rF}) {
            my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
            if ($M->{$metric} and !(-e $report_xml) and !(-e $report_xml.".$Common::GZEXT")) { $DO_METRICS = 1; }
         }
      }

      if ($DO_METRICS) {
      	#parse
      	my $FDout;
		 	if ( ($L eq $Common::L_SPA) or ($L eq $Common::L_CAT)) {
			 	$FDout =  SRXLike::parse_SR($tools, $parser, $L, $C, $out, $verbose);
			}
		 	elsif ($L eq $Common::L_ENG) {
			 	$FDout = SR::parse_SR($tools, $parser, $L, $C, $out, $verbose);
		 	}
		 	else { die "[SR] tool for <$L> unavailable!!!\n"; }
      	
         
			#align
			my $LSrcRefAligns; my $SrcCandAlign; my $LCandRefAligns;
			#mgb my $doalign = 1; 
			#mgb if ( $doalign > 0 ) {
			#mgb	($LSrcRefAligns, $SrcCandAlign, $LCandRefAligns) = Align::doMultiAlign( $config, $TGT, $out, $Href );
			#mgb}

         my @maxscores;
         my %maxOK;
         foreach my $ref (keys %{$Href}) {
		   	my $FDref;
			 	if ( ($L eq $Common::L_SPA) or ($L eq $Common::L_CAT)) {
				 	$FDref =  SRXLike::parse_SR($tools, $parser, $L, $C, $Href->{$ref}, $verbose);
				}
			 	elsif ($L eq $Common::L_ENG) {
				 	$FDref = SR::parse_SR($tools, $parser, $L, $C, $Href->{$ref}, $verbose);
			 	}
			 	else { die "[SR] tool for <$L> unavailable!!!\n"; }
            
            my $candrefalign;
            #if (exists ($LCandRefAligns->{$ref})) { $candrefalign = $LCandRefAligns->{$ref}; }
            my $scores = SR::FILE_compute_overlap_metrics( $FDout, $FDref, $L, ($C ne $Common::CASE_CI), $candrefalign );
            foreach my $metric (keys %{$rF}) {
               if (($M->{$metric}) or ($M->{$metric."_b"}) or ($M->{$metric."_i"})) {
                  #my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 0);
                  my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores_M(\@maxscores, $metric, 0, \%maxOK);
                  my ($SYS, $SEGS) = Overlap::get_segment_scores($scores, $metric, 0);
                  my $i = 0;
                  while ($i < scalar(@{$SEGS})) { #update max scores
	               if (defined($SEGS->[$i])) {
                        if (defined($MAXSEGS->[$i])) {
                           if ($SEGS->[$i] > $MAXSEGS->[$i]) {
  	                       if (exists($scores->[$i]->{$metric})) {
                                 $maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
                                 $maxOK{$metric}->[$i] = $scores->[$i]->{OK}; ###
    	                      }
                           }
                        }
                        else { $maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
                               $maxOK{$metric}->[$i] = $scores->[$i]->{OK}; } ###
                     }
                     else { $maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
                            $maxOK{$metric}->[$i] = $scores->[$i]->{OK}; } ###
                     $i++;
                  }
               }
            }
         }


         foreach my $metric (keys %{$rF}) {
            if ($M->{$metric}) {
               my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
               if ((!(-e $report_xml) and (!(-e $report_xml.".$Common::GZEXT"))) or $remakeREPORTS) {
                  if (($metric =~ /.*\_b$/) or ($metric =~ /.*\_i$/)) {
                     $config->{verbose} = 0; $config->{Hmetrics} = $Overlap::rOl;
                     Overlap::doMultiOl($config, $TGT, $out, $REF, $Href, $hOQ);
                     $config->{verbose} = $verbose; $config->{Hmetrics} = $M;
                     Metrics::add_metrics(\@maxscores, $TGT, $REF, $hOQ, $Overlap::rOl, $Common::G_SEG, $verbose);
  	              }
                  my $SYS; my $SEGS;
                  if ($metric =~ /.*\_b$/) {
                     my $backm = $metric; $backm =~ s/\_b$//; 
                     #($SYS, $SEGS) = Overlap::merge_metrics_M(\@maxscores, $backm, "$SR::SREXT-Ol", 0, \%maxOK);
                     ($SYS, $SEGS) = Overlap::merge_metrics_M(\@maxscores, $backm, "$Overlap::OlEXT", 0, \%maxOK);
                  }
                  elsif ($metric =~ /.*\_i$/) {
                     my $backm = $metric; $backm =~ s/\_i$//; 
                     #($SYS, $SEGS) = Overlap::merge_metrics_M(\@maxscores, $backm, "$SR::SREXT-Ol", 1, \%maxOK);
                     ($SYS, $SEGS) = Overlap::merge_metrics_M(\@maxscores, $backm, "$Overlap::OlEXT", 1, \%maxOK);
                  }
                  else {
                     #($SYS, $SEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 1);
                     ($SYS, $SEGS) = Overlap::get_segment_scores_M(\@maxscores, $metric, 2, \%maxOK);
                  }
                  my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
                  if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, $metric, $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            		Scores::save_hash_scores($metric, $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
               }
            }
         }
      }
   }
}

1;

