package DR;

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
#use Data::Dumper;
use IO::File;
use XML::Twig;
use Unicode::String qw(utf8 latin1);
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Overlap;
use IQ::Scoring::Metrics;

our ($DREXT, $DRDOCEXT, $rDReng, $rDRother, $ENGTOOL, $MAXSTM_LENGTH);

#my %FEATURES;
#$DR::rFEATURES = \%FEATURES;

$DR::DREXT = "DR";
$DR::DRDOCEXT = $DR::DREXT.$Common::DOCEXT;
$DR::ENGTOOL = "candc";

#$DR::rLANG = { $Common::L_ENG => 'en', $Common::L_ITA => 'it' };
$DR::rLANG = { $Common::L_ENG => 'en' };

$DR::MAXSTM_LENGTH = 9;

$DR::rDReng = { "$DR::DREXT-STM-1" => 1, "$DR::DREXT-STM-2" => 1, "$DR::DREXT-STM-3" => 1,
                "$DR::DREXT-STM-4" => 1, "$DR::DREXT-STM-5" => 1, "$DR::DREXT-STM-6" => 1,
                "$DR::DREXT-STM-7" => 1, "$DR::DREXT-STM-8" => 1, "$DR::DREXT-STM-9" => 1,
                "$DR::DREXT-STMi-2" => 1, "$DR::DREXT-STMi-3" => 1, "$DR::DREXT-STMi-4" => 1,
                "$DR::DREXT-STMi-5" => 1, "$DR::DREXT-STMi-6" => 1, "$DR::DREXT-STMi-7" => 1,
                "$DR::DREXT-STMi-8" => 1, "$DR::DREXT-STMi-9" => 1, "$DR::DREXT-Or-(dr)" => 1,
                "$DR::DREXT-Or(drs)" => 1, "$DR::DREXT-Or(alfa)" => 1, "$DR::DREXT-Or(merge)" => 1,
                "$DR::DREXT-Or(smerge)" => 1, "$DR::DREXT-Or(timex)" => 1, "$DR::DREXT-Or(named)" => 1,
                "$DR::DREXT-Or(pred)" => 1, "$DR::DREXT-Or(card)" => 1, "$DR::DREXT-Or(rel)" => 1,
                "$DR::DREXT-Or(eq)" => 1, "$DR::DREXT-Or(not)" => 1, "$DR::DREXT-Or(or)" => 1,
                "$DR::DREXT-Or(imp)" => 1, "$DR::DREXT-Or(whq)" => 1, "$DR::DREXT-Or(prop)" => 1,
                "$DR::DREXT-Orp(dr)" => 1, "$DR::DREXT-Orp(drs)" => 1, "$DR::DREXT-Orp(alfa)" => 1,
                "$DR::DREXT-Orp(merge)" => 1, "$DR::DREXT-Orp(smerge)" => 1, "$DR::DREXT-Orp(timex)" => 1,
                "$DR::DREXT-Orp(named)" => 1, "$DR::DREXT-Orp(pred)" => 1, "$DR::DREXT-Orp(card)" => 1,
                "$DR::DREXT-Orp(rel)" => 1, "$DR::DREXT-Orp(eq)" => 1, "$DR::DREXT-Orp(not)" => 1,
                "$DR::DREXT-Orp(or)" => 1, "$DR::DREXT-Orp(imp)" => 1, "$DR::DREXT-Orp(whq)" => 1,
                "$DR::DREXT-Orp(prop)" => 1, "$DR::DREXT-Or(*)" => 1, "$DR::DREXT-Orp(*)" => 1,
                "$DR::DREXT-Or(*)_b" => 1, "$DR::DREXT-Orp(*)_b" => 1, "$DR::DREXT-Or(*)_i" => 1,
                "$DR::DREXT-Orp(*)_i" => 1, "$DR::DREXT-Ol" => 1, 
                "$DR::DREXT-STM-4_b" => 1, "$DR::DREXT-STM-4_i" => 1,
	            
                "$DR::DREXT-Pr(*)" => 1, "$DR::DREXT-Rr(*)" => 1, "$DR::DREXT-Fr(*)" => 1,
                "$DR::DREXT-Prp(*)" => 1, "$DR::DREXT-Rrp(*)" => 1, "$DR::DREXT-Frp(*)" => 1
             };

$DR::rDRengDOC = { "$DR::DREXT$Common::DOCEXT-STM-1" => 1, "$DR::DREXT$Common::DOCEXT-STM-2" => 1,
                   "$DR::DREXT$Common::DOCEXT-STM-3" => 1, "$DR::DREXT$Common::DOCEXT-STM-4" => 1,
                   "$DR::DREXT$Common::DOCEXT-STM-5" => 1, "$DR::DREXT$Common::DOCEXT-STM-6" => 1,
                   "$DR::DREXT$Common::DOCEXT-STM-7" => 1, "$DR::DREXT$Common::DOCEXT-STM-8" => 1,
                   "$DR::DREXT$Common::DOCEXT-STM-9" => 1, "$DR::DREXT$Common::DOCEXT-STMi-2" => 1,
                   "$DR::DREXT$Common::DOCEXT-STMi-3" => 1, "$DR::DREXT$Common::DOCEXT-STMi-4" => 1,
                   "$DR::DREXT$Common::DOCEXT-STMi-5" => 1, "$DR::DREXT$Common::DOCEXT-STMi-6" => 1,
                   "$DR::DREXT$Common::DOCEXT-STMi-7" => 1, "$DR::DREXT$Common::DOCEXT-STMi-8" => 1,
                   "$DR::DREXT$Common::DOCEXT-STMi-9" => 1, "$DR::DREXT$Common::DOCEXT-Or(dr)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Or(drs)" => 1, "$DR::DREXT$Common::DOCEXT-Or(alfa)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Or(merge)" => 1, "$DR::DREXT$Common::DOCEXT-Or(smerge)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Or(timex)" => 1, "$DR::DREXT$Common::DOCEXT-Or(named)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Or(pred)" => 1, "$DR::DREXT$Common::DOCEXT-Or(card)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Or(rel)" => 1, "$DR::DREXT$Common::DOCEXT-Or(eq)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Or(not)" => 1, "$DR::DREXT$Common::DOCEXT-Or(or)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Or(imp)" => 1, "$DR::DREXT$Common::DOCEXT-Or(whq)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Or(prop)" => 1, "$DR::DREXT$Common::DOCEXT-Orp(dr)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(drs)" => 1, "$DR::DREXT$Common::DOCEXT-Orp(alfa)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(merge)" => 1, "$DR::DREXT$Common::DOCEXT-Orp(smerge)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(timex)" => 1, "$DR::DREXT$Common::DOCEXT-Orp(named)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(pred)" => 1, "$DR::DREXT$Common::DOCEXT-Orp(card)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(rel)" => 1, "$DR::DREXT$Common::DOCEXT-Orp(eq)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(not)" => 1, "$DR::DREXT$Common::DOCEXT-Orp(or)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(imp)" => 1, "$DR::DREXT$Common::DOCEXT-Orp(whq)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(prop)" => 1, "$DR::DREXT$Common::DOCEXT-Or(*)" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(*)" => 1, "$DR::DREXT$Common::DOCEXT-Or(*)_b" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(*)_b" => 1, "$DR::DREXT$Common::DOCEXT-Or(*)_i" => 1,
                   "$DR::DREXT$Common::DOCEXT-Orp(*)_i" => 1, "$DR::DREXT$Common::DOCEXT-Ol" => 1,

                   "$DR::DREXT$Common::DOCEXT-STM-4_b" => 1, "$DR::DREXT$Common::DOCEXT-STM-4_i" => 1
                  
                   #"$DR::DREXT$Common::DOCEXT-Pr(*)" => 1, "$DR::DREXT$Common::DOCEXT-Rr(*)" => 1, "$DR::DREXT$Common::DOCEXT-Fr(*)" => 1, 
                   #"$DR::DREXT$Common::DOCEXT-Prp(*)" => 1, "$DR::DREXT$Common::DOCEXT-Rrp(*)" => 1, "$DR::DREXT$Common::DOCEXT-Frp(*)" => 1
                 };

$DR::rOl = { "$DR::DREXT-Ol" => 1 };

$DR::rDRother = { };


#basic drs ------------ dr, drs
#complex drs ---------- alfa, merge, smerge
#basic conditions ----- timex, named, pred, card, rel, eq
#complex conditions --- not, or, imp, whq, prop

#--------------------------------------------------------------------------
#BOXER -- Fixed Symbols (http://svn.ask.it.usyd.edu.au/trac/candc/wiki/Semantics)
#
#There is a set of fixed symbols used in basic DRS conditions.
#
#One-place predicates:
#
#    * topic,a,n (elliptical noun phrases)
#    * thing,n,12 (used in NP quantifiers: 'something', etc.)
#    * person,n,1 (used in first-person pronouns, 'who'-questions)
#    * event,n,1 (introduced by main verbs)
#    * group,n,1 (used for plural descriptions)
#    * reason,n,2 (used in 'why'-questions)
#    * manner,n,2 (used in 'how'-questions)
#    * proposition,n,1 (arguments of propositional complement verbs)
#    * unit_of_time,n,1 (used in 'when'-questions)
#    * location,n,1 (used in 'there' insertion, 'where'-questions)
#    * quantity,n,1 (used in 'how many')
#    * amount,n,3 (used in 'how much')
#    * degree,n,1
#    * age,n,1
#    * neuter,a,0 (used in third-person pronouns: it, its)
#    * male,a,0 (used in third-person pronouns: he, his, him)
#    * female,a,0 (used in third-person pronouns: she, her)
#    * base,v,2
#    * bear,v,2 
#
#Two-place relations:
#
#    * rel,0 (general, underspecified type of relation)
#    * loc_rel,0 (locative relation)
#    * role,0 (underspecified role: agent,patient,theme)
#    * member,0 (used for plural descriptions)
#    * agent,0 (subject)
#    * theme,0 (indirect object)
#    * patient,0 (semantic object, subject of passive verbs)
#
#--------------------------------------------------------------------------


sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;
    if ($language eq $Common::L_ENG) {
       @metric_set{keys %{$DR::rDReng}} = values %{$DR::rDReng};
       @metric_set{keys %{$DR::rDRengDOC}} = values %{$DR::rDRengDOC};
    }

    return \%metric_set;
}

sub SNT_extract_features {
   #description _ extracts features from a given DR-parsed sentence structure.
   #param1  _ sentence DRS structure
   #@return _ sentence (+features)

   my $DRS = shift;

   my @SUBTREES;
   my %TAGS;
   my %BOW;

   if (exists($DRS->{LABEL}->{"l0"})) {
      my $start = $DRS->{LABEL}->{"l0"};
      my $tag = $start->[0];
      my $type = $start->[0].(exists($start->[1]->{"type"})? ".".$start->[1]->{"type"} : "").(exists($start->[1]->{"symbol"})? ".".$start->[1]->{"symbol"} : "");
      $SUBTREES[1]->{$type} = 1;
      my %tags; $tags{$tag} = 1;
      update_TAGWORDS($DRS, $start, \%tags, \%TAGS);
      my $children = $start->[2];
      my $N = 1;
      foreach my $child (@{$children}) {
         my $tag = $start->[0];
         my $type = $start->[0].(exists($start->[1]->{"type"})? ".".$start->[1]->{"type"} : "").(exists($start->[1]->{"symbol"})? ".".$start->[1]->{"symbol"} : "");
         my @chain = ($type);
         my %tags; $tags{$tag} = 1;
         my $n = 0; if (($tag eq "or") or ($tag eq "imp") or ($tag eq "whq")) { $n = $N; }
         extract_features($DRS, $child, \@chain, \@SUBTREES, \%tags, $n, \%TAGS);
         $N++;
      }
   }

   if (defined($DRS->{DR})) {
       foreach my $name (keys %{$DRS->{DR}}) {
          foreach my $index (@{$DRS->{DR}->{$name}}) {
             $TAGS{C}->{"dr"}->{W}->{$DRS->{INDEX}->{$index}->{W}}++;
             $TAGS{C}->{"dr"}->{P}->{$DRS->{INDEX}->{$index}->{P}}++;
          }
       }
   }
   if (defined($DRS->{WORDS})) { #only for lexical overlap (e.g., to backoff when parsing fails) 
      my $i = 0;
      while ($i < scalar(@{$DRS->{WORDS}})) {
         $BOW{$DRS->{WORDS}->[$i]}++;
         $i++;
      } 
   }

   my %snt;
   $snt{subtrees} = \@SUBTREES;
   $snt{tags} = \%TAGS;				
   $snt{BOW} = \%BOW;

   return \%snt;
}

sub extract_features {
   #description _ adds subtrees and tag-word associations below the given node
   #              to the inherited collections of subtrees and tag-word occurrences.
   #              New subtrees are also linked to previous subtrees above the
   #              given node in the path bettwen the node and the tree root.
   #param1  _ sentence DRS structure
   #param2  _ current child
   #param3  _ chain of tags visited so far (inherited)
   #param4  _ collection of subtrees (inherited + synthesized)
   #param5  _ distinct tags seen so far (inherited)
   #param6  _ child number
   #param7  _ collection of tag-word occurrences (inherited + synthesized)

   my $DRS = shift;
   my $label = shift;
   my $chain = shift;
   my $SUBTREES = shift;
   my $tags = shift;
   my $N = shift;
   my $TAGS = shift;

   if (exists($DRS->{LABEL}->{$label})) {
      my $drs = $DRS->{LABEL}->{$label};
      my @l = @{$chain};
      my $j = 0;
      my $tag = $drs->[0];
      my $type = $drs->[0].(exists($drs->[1]->{"type"})? ".".$drs->[1]->{"type"} : "").(exists($drs->[1]->{"symbol"})? ".".$drs->[1]->{"symbol"} : "");
      if ($N != 0) { $tag .= "-$N"; $type .= "-$N"; }
      while ($j < scalar(@{$chain})) {
         $SUBTREES->[scalar(@l)+1]->{join($CP::CSEP, @l).$CP::CSEP.$type}++;
         shift(@l);
         $j++;
      }
      $SUBTREES->[1]->{$type}++;

      push(@{$chain}, $type);
      $tags->{$tag}++;
      update_TAGWORDS($DRS, $drs, $tags, $TAGS);
      my $children = $drs->[2];
      my $N = 1;
      foreach my $child (@{$children}) {
         my $tag = $drs->[0];
         my $type = $drs->[0].(exists($drs->[1]->{"type"})? ".".$drs->[1]->{"type"} : "").(exists($drs->[1]->{"symbol"})? ".".$drs->[1]->{"symbol"} : "");
         #if (($tag eq "or") or ($tag eq "imp") or ($tag eq "whq")) { $tag .= "-$N"; $type .= "-$N"; }
         my @chain = @{$chain};   #copy list of tags
         my %tags = %{$tags};     #copy hash of tags
         my $n = 0; if (($tag eq "or") or ($tag eq "imp") or ($tag eq "whq")) { $n = $N; }
         extract_features($DRS, $child, \@chain, $SUBTREES, \%tags, $n, $TAGS);
         $N++;
      }
   }
}

sub update_TAGWORDS {
   #description _ adds words directly hanging from the given node to TAGS,
   #              i.e., the structure containing the WORDTAG associations
   #              for all tags in the path from the root to the given node. 
   #param1  _ sentence DRS structure
   #param2  _ current DR node
   #param3  _ distinct tags seen so far (inherited)
   #param4  _ collection of tag-word occurrences (inherited + synthesized)

    my $DRS = shift;
    my $drs = shift;
    my $tags = shift;
    my $TAGS = shift;

    foreach my $tag (keys %{$tags}) {
       if (exists($drs->[1]->{"arg"})) {
          my $indices = $DRS->{DR}->{$drs->[1]->{"arg"}}; 
          foreach my $index (@{$indices}) {
             $TAGS->{C}->{$tag}->{W}->{$DRS->{INDEX}->{$index}->{W}.".a"}++;
             $TAGS->{C}->{$tag}->{P}->{$DRS->{INDEX}->{$index}->{P}.".a"}++;
          }
       }
       if (exists($drs->[1]->{"arg1"})) {
          my $indices = $DRS->{DR}->{$drs->[1]->{"arg1"}}; 
          foreach my $index (@{$indices}) {
             $TAGS->{C}->{$tag}->{W}->{$DRS->{INDEX}->{$index}->{W}.".a1"}++;
             $TAGS->{C}->{$tag}->{P}->{$DRS->{INDEX}->{$index}->{P}.".a1"}++;
          }
       }
       if (exists($drs->[1]->{"arg2"})) {
          my $indices = $DRS->{DR}->{$drs->[1]->{"arg2"}}; 
          foreach my $index (@{$indices}) {
             $TAGS->{C}->{$tag}->{W}->{$DRS->{INDEX}->{$index}->{W}.".a2"}++;
             $TAGS->{C}->{$tag}->{P}->{$DRS->{INDEX}->{$index}->{P}.".a2"}++;
          }
       }
       if (defined($drs->[3])) {
          my $indices = $drs->[3];
          foreach my $index (@{$indices}) {
             $TAGS->{C}->{$tag}->{W}->{$DRS->{INDEX}->{$index}->{W}}++;
             $TAGS->{C}->{$tag}->{P}->{$DRS->{INDEX}->{$index}->{P}}++;
	  }
       }
       if ($drs->[4] ne "") { $TAGS->{C}->{$tag}->{W}->{$drs->[4]}++; }
   }
}

sub SNT_compute_overlap_scores {
   #description _ computes distances between a candidate and a reference sentence (+features)
   #param1  _ candidate sentence (+features)
   #param2  _ reference sentence (+features)
   #param3  _ language
   #param4  _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)
   #param5  _ do document-level scores

   my $Tout = shift;
   my $Tref = shift;
   my $LANG = shift;
   my $LC = shift;
   my $DO_doc = shift;

   my %SCORES;
   my $EXT = $DR::DREXT.($DO_doc? "$Common::DOCEXT" : "");

   # DR-STM   -----------------------------------------------------------------------------
   # ~(STM) subtree metrics (Liu and Gildea, 2005), applied to semantic DRS'
   if ((scalar(@{$Tref->{subtrees}}) > 1) and (scalar(@{$Tout->{subtrees}}) > 1)) {  # BOTH SEGMENTS CORRECTLY FULLY-PARSED
      $SCORES{OK} = 1;
      my $HITS = 0;   my $TOTAL = 0;
      my $i = 1;
      while ($i <= $DR::MAXSTM_LENGTH){
         if ((defined($Tref->{subtrees}->[$i])) and (defined($Tout->{subtrees}->[$i]))) { # BOTH CONTAIN i-subtrees
            my ($hits, $total) = Overlap::compute_overlap($Tout->{subtrees}->[$i], $Tref->{subtrees}->[$i], $LC);
            $SCORES{"$EXT-STMi-".$i} =  Common::safe_division($hits, $total);
            $HITS += $hits; $TOTAL += $total;
            $SCORES{"$EXT-STM-".$i} =  Common::safe_division($HITS, $TOTAL);
         }
         else {
         	$SCORES{"$EXT-STMi-".$i} = 0;
         	$TOTAL += (defined($Tref->{subtrees}->[$i])? Overlap::compute_total($Tref->{subtrees}->[$i]) : 0) +
         	          (defined($Tout->{subtrees}->[$i])? Overlap::compute_total($Tout->{subtrees}->[$i]) : 0);
      	    $SCORES{"$EXT-STM-".$i} = Common::safe_division($HITS, $TOTAL);
         }
         #print "STM-$i HITS = $HITS :: TOTAL = $TOTAL\n";
         $i++;
      }
      #$SCORES{"$EXT-STM-*"} =  Common::safe_division($HITS, $TOTAL);
   }
   else { $SCORES{OK} = 0; }

   #Overlap (Gimenez and Marquez, 2007)
   # DR-Or(*)  -----------------------------------------------------------------------------
   my $HITS = 0;   my $TOTAL = 0; 
   my $PHITS = 0;  my $PTOTAL = 0;
   my $RHITS = 0;  my $RTOTAL = 0;
   my %F;
   foreach my $C (keys %{$Tout->{tags}->{C}}) { $F{$C} = 1; }
   foreach my $C (keys %{$Tref->{tags}->{C}}) { $F{$C} = 1; }
   foreach my $C (keys %F) {
      #print "C = $C\n";
      my ($hits, $total) = Overlap::compute_overlap($Tout->{tags}->{C}->{$C}->{W}, $Tref->{tags}->{C}->{$C}->{W}, $LC);
      #print "hits = $hits :: total = $total\n";
      $SCORES{"$EXT-Or($C)"} = Common::safe_division($hits, $total);
      $HITS += $hits; $TOTAL += $total;
      my ($phits, $ptotal) = Overlap::compute_precision($Tout->{tags}->{C}->{$C}->{W}, $Tref->{tags}->{C}->{$C}->{W}, $LC);
      #my $p = Common::safe_division($phits, $ptotal);
      #$SCORES{"$EXT-Pr-".$C} = $p;
      $PHITS += $phits; $PTOTAL += $ptotal;
      my ($rhits, $rtotal) = Overlap::compute_recall($Tout->{tags}->{C}->{$C}->{W}, $Tref->{tags}->{C}->{$C}->{W}, $LC);
      #my $r = Common::safe_division($rhits, $rtotal);
      #$SCORES{"$EXT-Rr-".$C} = $r;
      $RHITS += $rhits; $RTOTAL += $rtotal;
   }
   $SCORES{"$EXT-Or(*)"} = Common::safe_division($HITS, $TOTAL);
   #print "HITS = $HITS :: TOTAL = $TOTAL\n";
   my $P = Common::safe_division($PHITS, $PTOTAL);
   $SCORES{"$EXT-Pr(*)"} = $P;
   my $R = Common::safe_division($RHITS, $RTOTAL);
   $SCORES{"$EXT-Rr(*)"} = $R;
   $SCORES{"$EXT-Fr(*)"} = Common::f_measure($P, $R, 1);

   # DR-Orp(*)  -----------------------------------------------------------------------------
   $HITS = 0;   $TOTAL = 0;
   $PHITS = 0;  $PTOTAL = 0;
   $RHITS = 0;  $RTOTAL = 0;
   %F = ();
   foreach my $C (keys %{$Tout->{tags}->{C}}) { $F{$C} = 1; }
   foreach my $C (keys %{$Tref->{tags}->{C}}) { $F{$C} = 1; }
   foreach my $C (keys %F) {
      my ($hits, $total) = Overlap::compute_overlap($Tout->{tags}->{C}->{$C}->{P}, $Tref->{tags}->{C}->{$C}->{P}, $LC);
      $SCORES{"$EXT-Orp($C)"} = Common::safe_division($hits, $total);
      $HITS += $hits; $TOTAL += $total;
      my ($phits, $ptotal) = Overlap::compute_precision($Tout->{tags}->{C}->{$C}->{P}, $Tref->{tags}->{C}->{$C}->{P}, $LC);
      #my $p = Common::safe_division($phits, $ptotal);
      #$SCORES{"$EXT-Prp($C)"} = $p;
      $PHITS += $phits; $PTOTAL += $ptotal;
      my ($rhits, $rtotal) = Overlap::compute_recall($Tout->{tags}->{C}->{$C}->{P}, $Tref->{tags}->{C}->{$C}->{P}, $LC);
      #my $r = Common::safe_division($rhits, $rtotal);
      #$SCORES{"$EXT-Rrp($C)"} = $r;
      $RHITS += $rhits; $RTOTAL += $rtotal;
   }
   $SCORES{"$EXT-Orp(*)"} = Common::safe_division($HITS, $TOTAL);
   $P = Common::safe_division($PHITS, $PTOTAL);
   $SCORES{"$EXT-Prp(*)"} = $P;
   $R = Common::safe_division($RHITS, $RTOTAL);
   $SCORES{"$EXT-Rrp(*)"} = $R;
   $SCORES{"$EXT-Frp(*)"} = Common::f_measure($P, $R, 1);

   # DR-Ol ----------------------------------------------------------------------------------
   # lexical overlap alone
   ($HITS, $TOTAL) = Overlap::compute_overlap($Tout->{BOW}, $Tref->{BOW}, $LC);
   $SCORES{"$EXT-Ol"} = Common::safe_division($HITS, $TOTAL);

   return \%SCORES;
}

sub FILE_compute_overlap_metrics {
   #description _ computes CHUNK scores (single reference)
   #param1  _ candidate list of parsed sentences (+features)
   #param2  _ reference list of parsed sentences (+features)
   #param3  _ language
   #param4  _ do_lower_case evaluation ( 1:yes -> case_insensitive  ::  0:no -> case_sensitive )
   #param5  _ do document-level scores
   #@return _ metric scores

   my $FOUT = shift;
   my $FREF = shift;
   my $LANG = shift;
   my $LC = shift;
   my $DO_doc = shift;

   #print Dumper($FOUT);
   #print Dumper($FREF);

   my @SCORES;
   my $topic = 0;
   while ($topic < scalar(@{$FREF})) {
      #print "*********** ", $topic + 1, " / ", scalar(@{$FREF}), "**********\n";
      #print Dumper $FOUT->[$topic];
      my $OUTSNT = SNT_extract_features($FOUT->[$topic]);
      #print Dumper $OUTSNT;
      #print "---------------------------------------------------------\n";
      #print Dumper $FREF->[$topic];
      my $REFSNT = SNT_extract_features($FREF->[$topic]);
      #print Dumper $REFSNT;
      #print "---------------------------------------------------------\n";
      $SCORES[$topic] = SNT_compute_overlap_scores($OUTSNT, $REFSNT, $LANG, $LC, $DO_doc);
      #print Dumper $SCORES[$topic];
      #foreach my $f (keys %{$SCORES[$topic]}) { $FEATURES{$f} = 1; }
      $topic++;
   }

   return \@SCORES;
}

sub parse_FULL
{
    #description _ responsible for Semantic Parsing --> DRS (Discourse Representation Structures)
    #              (by calling Johan Bos' Boxer available inside the C&C software).
    #param1  _ IQMT TOOL directory pathname
    #param2  _ parsing LANGUAGE 1
    #param3  _ case 1
    #param4  _ input file
    #param5  _ shallow parser (object)
    #param6  _ enabled doc-level parsing FLAG
    #param7  _ idx structure
    #param8  _ verbosity (0/1)
    #@return _ parsed forest (list -> one item per tree)

    my $IQMT = shift;
    my $L = shift;
    my $C = shift;
    my $input = shift;
    my $parser = shift;
    my $DO_doc = shift;
    my $idx = shift;
    my $verbose = shift;

    #output format options
    my $opt_box = 'true';
    my $opt_flat = 'true';
    my $opt_format = 'xml';
    my $opt_instantiate = 'false';
    my $opt_semantics = 'drs';
    my $opt_doc = 'false';

    # options
    my $opt_copula = 'true';
    #my $opt_elimeq = 'true';
    my $opt_elimeq = 'false';
    my $opt_modal = 'false';
    my $opt_resolve = 'true';
    #my $opt_vpe = 'true';
    my $opt_vpe = 'false';
    my $opt_robust = 'true';
    my $opt_roles = 'proto';
    my $opt_tense = 'true';
    
    if ($DO_doc) { # annotate docs in the input file
       $input = annotate_docs($idx, $input);
    }

    # -------------------------------------------------------------------------

    my $DRfile = $input.".$DR::DREXT.xml";
    my $FILE;
    
    my $r = rand($Common::NRAND);

    if (exists($DR::rLANG->{$L})) {
       if ((!(-e $DRfile)) and (!(-e "$DRfile.$Common::GZEXT"))) { 
          my $CCGinput = $input.".$DR::DREXT.CCG";
          if ((!(-e $CCGinput)) and (!(-e "$CCGinput.$Common::GZEXT"))) { 
             my $tmp = "$input.$r";
             fill_empty_lines($input, $tmp);  #empty lines are skipped by the CCG parser!!

             Common::execute_or_die("$IQMT/$DR::ENGTOOL/bin/candc --log /dev/null --models $IQMT/$DR::ENGTOOL/models --candc-printer boxer < $tmp > $CCGinput", "[ERROR] problems running CCG parser...");
             system "rm -f $tmp";
     	  }
          if (-e "$CCGinput.$Common::GZEXT") { system("$Common::GUNZIP $CCGinput.$Common::GZEXT"); }
          my $CCGtmp = "$CCGinput.$r";
          my $DRfiletmp = "$DRfile.$r";
          Common::rerelatinize_file($CCGinput, $CCGtmp);

          Common::execute_or_die("$IQMT/$DR::ENGTOOL/bin/boxer --language ".$DR::rLANG->{$L}." --input $CCGtmp --output $DRfiletmp".
                                 " --box $opt_box --flat $opt_flat --format $opt_format --instantiate $opt_instantiate --semantics $opt_semantics".
                                 " --copula $opt_copula --elimeq $opt_elimeq --modal $opt_modal --resolve $opt_resolve --vpe $opt_vpe".
                                 " --robust $opt_robust --roles $opt_roles --tense $opt_tense --doc $opt_doc 2> /dev/null",
                                 "[ERROR] problems running semantic parser...");
          system "$Common::GZIP $CCGinput";
          system "rm -f $CCGtmp";
          repair_xml($DRfiletmp, $DRfile);
          system "rm -f $DRfiletmp";
       }
       $FILE = read_BOXER_parsing($DRfile, $DO_doc, $idx);
       add_lexical_items($FILE, $input);
    }
    else { die "[DR] tool for <$L> unavailable!!!\n"; }

    #print Dumper $FILE;

    system("$Common::GZIP $DRfile");

    return $FILE;
}

sub add_lexical_items {
   #description _ add lexical items to DR structure
   #param1 _ structure
   #param2 _ input file

   my $drs = shift;
   my $input = shift;

   my $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n";
   my $i = 0;
   my $d = 0;
   my $DO_doc = 0;
   while (defined(my $line = <$IN>)) {
   	  if (($i == 0) && ($line =~ /^<META>.*/)) { $DO_doc = 1; }
   	  else { 
         chomp($line);
         if (($line ne "") and ($line !~ /^<META>.*/)) {
    	    my @l = split(" ", $line);
	        if (exists($drs->[$d]->{WORDS})) {
	     	   my @ll = (@{$drs->[$d]->{WORDS}}, @l);
    	       $drs->[$d]->{WORDS} = \@ll;
	      	}
	        else { $drs->[$d]->{WORDS} = \@l; }
	     }
	     if ($DO_doc) { if ($line =~ /^<META>.*/) { $d++; } }
         else { $d++; }
   	  }
   	  $i++;
   }
   close($IN);
}

sub fill_empty_lines {
   #description _ writes the contents of input file into output file, filling empty lines, if any.
   #param1 _ input file
   #param2 _ output file

   my $input = shift;
   my $output = shift;

   my $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n";
   my $OUT = new IO::File("> $output");

   my $i = 0;
   while (defined(my $line = <$IN>)) {
      chomp($line);
      if ($line eq "") { print $OUT $Common::EMPTY_ITEM, "\n"; }
      else { print $OUT $line, "\n"; }
      $i++;
   }
   close($IN);
   close($OUT);
}

sub repair_xml {
   #description _ repair a possibly ill-formed XML file
   #              * look for forbidden characters
   #                { '&' => '&amp;', '<' => '&lt;', '>' => '&gt;', '\'' => '&apos;', '"' => '&quot;'};

   my $input = shift;
   my $output = shift;

   my $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n";
   my $OUT = new IO::File("> $output");

   while (defined(my $line = <$IN>)) {
      if (($line =~ /<named /) or ($line =~ /<pred /) or ($line =~ /<rel /)) {
         #<named label="l4" arg="_G29120" symbol="bharat_said:_"we" type="org">
         chomp($line);
         my @entry = split(" ", $line);
         my @new;
         foreach my $elem (@entry) {
	    if ($elem =~ /symbol=\".*\"/) {
   	       my @l = split("=", $elem);
               my $s = $l[1]; $s =~ s/^\"//; $s =~ s/\"$//;
  	       my $ss = utf8($s);
               $elem = "symbol=\"".Common::replace_xml_entities_REV($ss->utf8)."\"";
            }
            push(@new, $elem);         
         }
         print $OUT join(" ", @new), "\n";
      }
      elsif (($line =~ /<word /) or ($line =~ /<postag /)) {
         #<word xml:id="i3003">"We</word>
         chomp($line);
         my @entry = split(">", $line);
         my @l = split("<", $entry[1]);
     	 my $s = utf8($l[0]);
         print $OUT $entry[0].">".Common::replace_xml_entities_REV($s->utf8)."<".$l[1].">\n";
      }
      else { print $OUT $line; }
   }

   close($IN);
   close($OUT);
}

sub read_BOXER_parsing
{
    #description _ responsible for reading Boxer parser output into memory
    #param1  _ input parsed file
    #param2  _ enabled doc-level parsing FLAG
    #param3  _ idx structure
    #@return _ parsed forest (list -> one item per tree)

    my $DRfile = shift;
    my $DO_doc = shift;
    my $idx = shift;

    my $ldocids = [];;
    if ($DO_doc) { $ldocids = NISTXML::get_docid_list($idx); }    
  
    if ((!(-e $DRfile)) and (-e "$DRfile.$Common::GZEXT")) { system("$Common::GUNZIP $DRfile.$Common::GZEXT"); }

    my $r = rand($Common::NRAND);
    my $DRfiletmp = "$DRfile.$r";

    Common::XML_remove_comments($DRfile, $DRfiletmp);
    #$DRfile = "/tmp/test.boxer.flat.xml";

    my @FILE;

    my $twig = XML::Twig->new( comments => 'drop', keep_encoding => 1 );
    $twig->parsefile($DRfiletmp);
    my $root = $twig->root;
    my @XFDRS = $root->children;
    my $Ti = 1;
    for (my $x = 0; $x < scalar(@XFDRS); $x += 1) {
       my %INDEX; my %LABEL; my %DR;
       my $xfdrs = $XFDRS[$x];
       #push empty semantic trees
       my $Tid = $xfdrs->att("xml:id"); $Tid =~ s/^d//;
       if ($DO_doc) {
          while ($Tid ne $ldocids->[$Ti-1]) { push(@FILE, undef); $Ti++; }       	  
       }
       else {
          while ($Tid > $Ti) { push(@FILE, undef); $Ti++; }
       }
       my @ELEMS = $xfdrs->children;
       for (my $e = 0; $e < scalar(@ELEMS); $e += 1) {
          my $elem = $ELEMS[$e];
          if ($elem->gi eq "words") {
             my @WORDS = $elem->children;
             for (my $w = 0; $w < scalar(@WORDS); $w += 1) {
                $INDEX{$WORDS[$w]->att("xml:id")}->{W} = $WORDS[$w]->text;
	         }
          }
          elsif ($elem->gi eq "postags") {
             my @POSTAGS = $elem->children;
             for (my $p = 0; $p < scalar(@POSTAGS); $p += 1) {
                $INDEX{$POSTAGS[$p]->att("index")}->{P} = $POSTAGS[$p]->text;
	         }
          }
          elsif ($elem->gi eq "netags") {
             my @NETAGS = $elem->children;
             for (my $n = 0; $n < scalar(@NETAGS); $n += 1) {
                $INDEX{$NETAGS[$n]->att("index")}->{N} = $NETAGS[$n]->text;
	         }
          }
          elsif ($elem->gi eq "cons") {
             my @CONS = $elem->children;
             for (my $c = 0; $c < scalar(@CONS); $c += 1) {
        	 my $cons = $CONS[$c];
                 push(@{$LABEL{$cons->att("label")}}, $cons->gi);
                 push(@{$LABEL{$cons->att("label")}}, $cons->atts);
                 my @LABELS = $cons->children;
                 my @labels; my @indices; my $date = "";
                 for (my $l = 0; $l < scalar(@LABELS); $l += 1) {
                     if ($LABELS[$l]->gi eq "dr") {
                        my @index; my @idx = $LABELS[$l]->children;
                        for (my $i = 0; $i < scalar(@idx); $i += 1) {
                            push(@index, $idx[$i]->text);
                        }
                        $DR{$LABELS[$l]->att("name")} = \@index;
                     }
                     elsif (($LABELS[$l]->gi eq "date") or ($LABELS[$l]->gi eq "time")) { $date = $LABELS[$l]->text; }
                     else { #label / index
                        if ($LABELS[$l]->gi eq "label") { push(@labels, $LABELS[$l]->text); }
                        elsif ($LABELS[$l]->gi eq "index") { push(@indices, $LABELS[$l]->text); }
                     }
                 }
                 push(@{$LABEL{$cons->att("label")}}, \@labels);
                 push(@{$LABEL{$cons->att("label")}}, \@indices);
                 push(@{$LABEL{$cons->att("label")}}, $date);
	         }
	      }
       }
       my %DRS;
       $DRS{LABEL} = \%LABEL;
       $DRS{INDEX} = \%INDEX;
       $DRS{DR} = \%DR;
       #print Dumper(\%DRS);
       push(@FILE, \%DRS);
       $Ti++;
    }

    $twig->dispose();

    system "rm -rf $DRfiletmp";

    return \@FILE;
}

sub annotate_docs_in_file {
	#description _ annotates a file with document META tags (e.g., <META>'Doc n_doc'),
	#              according to a given DOC index structure             
	#param1  _ candidate index file 
	#param2  _ candidate filename (input)
	#param3  _ document-annotated candidate filename (output)

    my $idx = shift;
    my $out = shift;
    my $out_doc = shift;

    my $OUT = new IO::File("< $out") or die "Couldn't open input file: $out\n";
    my $OUT_DOC = new IO::File("> $out_doc") or die "Couldn't open output file: $out_doc\n";

	my $i = 1;
	my $document_id = "";
    while (defined(my $line = <$OUT>)) {
       if ($idx->[$i]->[0] ne $document_id) { # NEW DOCUMENT
          print $OUT_DOC "<META>'".$idx->[$i]->[0]."'\n";
          $document_id = $idx->[$i]->[0]; 
       }      
  	   print $OUT_DOC $line;
	   $i++;
	}
	$OUT->close();
	$OUT_DOC->close();
}  	

sub annotate_docs {
	#description _ creates an annotated file (with DOC tags) out from a given file,
	#              according to a given DOC index structure
	#param1  _ candidate index file 
	#param2  _ candidate filename (input)
    #@returns_ document-annotated candidate filename (output)
    
	my $idx = shift;
	my $file = shift;
	
    my $basename = $file;
    $basename =~ s/\.[^\.]*$//;
    
    my $file_doc = $basename.".".$Common::DOCEXT;
    
    if (!(-e $file_doc)) { annotate_docs_in_file($idx, $file, $file_doc); }
    
    return $file_doc;
}

sub doMultiDR {
   #description _ computes DR scores (multiple references)
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param6  _ FLAG that enables doc-level metric computation
   #param7  _ hash of scores

   my $config = shift;
   my $TGT = shift;
   my $out = shift;
   my $REF = shift;
   my $Href = shift;
   my $DO_doc = shift;
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
   if ($DO_doc) {
      if ($L eq $Common::L_ENG) { $rF = $DR::rDRengDOC; } # ENGLISH (doc level)
      else { $rF = $DR::rDRother; }              # OTHER (empty set)
   }
   else {
      if ($L eq $Common::L_ENG) { $rF = $DR::rDReng; }    # ENGLISH
      else { $rF = $DR::rDRother; }              # OTHER (empty set)
   }

   my $GO_ON = 0;
   foreach my $metric (keys %{$rF}) {
      if ($M->{$metric}) { $GO_ON = 1; }
   }

   if ($GO_ON) {
      if ($verbose == 1) { print STDERR "$DR::DREXT".($DO_doc? "$Common::DOCEXT" : "").".."; }

      my $DO_METRICS = $remakeREPORTS;
      if (!$DO_METRICS) {
         foreach my $metric (keys %{$rF}) {
            my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
            if ($M->{$metric} and !(-e $report_xml) and !(-e $report_xml.".$Common::GZEXT")) { $DO_METRICS = 1; }
         }
      }

      if ($DO_METRICS) {
         my $Fout = DR::parse_FULL($tools, $L, $C, $out, $parser, $DO_doc, $config->{IDX}->{$TGT}, $verbose);
         my @maxscores;
         my %maxOK;
         foreach my $ref (keys %{$Href}) {
            my $Fref = DR::parse_FULL($tools, $L, $C, $Href->{$ref}, $parser, $DO_doc, $config->{IDX}->{$ref}, $verbose);
            my $scores = DR::FILE_compute_overlap_metrics($Fout, $Fref, $L, ($C ne $Common::CASE_CI), $DO_doc);
            #delete_FOREST($Fref); 
            foreach my $metric (keys %{$rF}) {
               #if ($M->{$metric}) {
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
                        else {
                           $maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
                           $maxOK{$metric}->[$i] = $scores->[$i]->{OK};
                        }
                     }
                     else {
                        $maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
                        $maxOK{$metric}->[$i] = $scores->[$i]->{OK};
                     }
                     $i++;
                  }
               }
            }
         }
         #delete_FOREST($Fout);
         #print Dumper \@maxscores;

         foreach my $metric (keys %{$rF}) {
            if ($M->{$metric}) {
               my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
               if ((!(-e $report_xml) and (!(-e $report_xml.".$Common::GZEXT"))) or $remakeREPORTS) {
                  #my ($SYS, $SEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 1);
                  #my ($SYS, $SEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 2);
                  if (($metric =~ /.*\_b$/) or ($metric =~ /.*\_i$/)) {
                     $config->{verbose} = 0; $config->{Hmetrics} = $Overlap::rOl;
                     Overlap::doMultiOl($config, $TGT, $out, $REF, $Href,$hOQ);
                     $config->{verbose} = $verbose; $config->{Hmetrics} = $M;
                     Metrics::add_metrics(\@maxscores, $TGT, $REF, $hOQ, $Overlap::rOl, ($DO_doc? $Common::G_DOC : $Common::G_SEG), $verbose);
                  }
                  my $SYS; my $SEGS;
                  if ($metric =~ /.*\_b$/) {
                     my $backm = $metric; $backm =~ s/\_b$//; 
                     #($SYS, $SEGS) = Overlap::merge_metrics_M(\@maxscores, $backm, "$DR::DREXT-Ol", 0, \%maxOK);
                     ($SYS, $SEGS) = Overlap::merge_metrics_M(\@maxscores, $backm, "$Overlap::OlEXT", 0, \%maxOK);
                  }
                  elsif ($metric =~ /.*\_i$/) {
                     my $backm = $metric; $backm =~ s/\_i$//; 
                     #($SYS, $SEGS) = Overlap::merge_metrics_M(\@maxscores, $backm, "$DR::DREXT-Ol", 1, \%maxOK);
                     ($SYS, $SEGS) = Overlap::merge_metrics_M(\@maxscores, $backm, "$Overlap::OlEXT", 1, \%maxOK);
                  }
                  else {
                     #($SYS, $SEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 1);
                     ($SYS, $SEGS) = Overlap::get_segment_scores_M(\@maxscores, $metric, 2, \%maxOK);
	              }
	              my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, $DO_doc, $config->{IDX}->{$TGT});
	              if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, $metric, $SYS, $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
            	  Scores::save_hash_scores($metric, $TGT, $REF, $SYS, $doc_scores, $seg_scores,$hOQ);
               }
            }
         }
      }
   }
}

1;
