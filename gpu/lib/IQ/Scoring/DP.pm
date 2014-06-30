package DP;

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
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Overlap;
use IQ::Scoring::Metrics;

our($DPEXT, $rDPeng, $rDPspacat, $TDPeng, $MAXHWC_LENGTH);

my $SEP = "_";
my $DMAX = 4;

$DP::TDPparser = "minipar/pdemo/pdemo";
$DP::DPEXT = "DP";

$DP::USE_LOWERCASE = 1;

$DP::MAXHWC_LENGTH = 9;

$DP::rDPeng = { "$DP::DPEXT-Oc(a)" => 1, "$DP::DPEXT-Oc(as)" => 1, "$DP::DPEXT-Oc(aux)" => 1,
                "$DP::DPEXT-Oc(be)" => 1, "$DP::DPEXT-Oc(c)" => 1, "$DP::DPEXT-Oc(comp)" => 1,
                "$DP::DPEXT-Oc(det)" => 1, "$DP::DPEXT-Oc(have)" => 1, "$DP::DPEXT-Oc(n)" => 1,
                "$DP::DPEXT-Oc(postdet)" => 1, "$DP::DPEXT-Oc(ppspec)" => 1, "$DP::DPEXT-Oc(predet)" => 1,
                "$DP::DPEXT-Oc(prep)" => 1, "$DP::DPEXT-Oc(saidx)" => 1, "$DP::DPEXT-Oc(sentadjunct)" => 1,
                "$DP::DPEXT-Oc(subj)" => 1, "$DP::DPEXT-Oc(that)" => 1, "$DP::DPEXT-Oc(u)" => 1,
                "$DP::DPEXT-Oc(v)" => 1, "$DP::DPEXT-Oc(vbe)" => 1, "$DP::DPEXT-Oc(xsaid)" => 1,
                "$DP::DPEXT-Ol(1)" => 1, "$DP::DPEXT-Ol(2)" => 1, "$DP::DPEXT-Ol(3)" => 1,
                "$DP::DPEXT-Ol(4)" => 1, "$DP::DPEXT-Ol(5)" => 1, "$DP::DPEXT-Ol(6)" => 1,
                "$DP::DPEXT-Ol(7)" => 1, "$DP::DPEXT-Ol(8)" => 1, "$DP::DPEXT-Ol(9)" => 1,
                "$DP::DPEXT-Or(amod)" => 1, "$DP::DPEXT-Or(amount-value)" => 1, "$DP::DPEXT-Or(appo)" => 1,
                "$DP::DPEXT-Or(appo-mod)" => 1, "$DP::DPEXT-Or(as-arg)" => 1, "$DP::DPEXT-Or(as1)" => 1,
                "$DP::DPEXT-Or(as2)" => 1, "$DP::DPEXT-Or(aux)" => 1, "$DP::DPEXT-Or(be)" => 1,
                "$DP::DPEXT-Or(being)" => 1, "$DP::DPEXT-Or(by-subj)" => 1, "$DP::DPEXT-Or(c)" => 1,
                "$DP::DPEXT-Or(cn)" => 1, "$DP::DPEXT-Or(comp1)" => 1, "$DP::DPEXT-Or(conj)" => 1,
                "$DP::DPEXT-Or(desc)" => 1, "$DP::DPEXT-Or(dest)" => 1, "$DP::DPEXT-Or(det)" => 1,
                "$DP::DPEXT-Or(else)" => 1, "$DP::DPEXT-Or(fc)" => 1, "$DP::DPEXT-Or(gen)" => 1,
                "$DP::DPEXT-Or(guest)" => 1, "$DP::DPEXT-Or(have)" => 1, "$DP::DPEXT-Or(head)" => 1,
                "$DP::DPEXT-Or(i)" => 1, "$DP::DPEXT-Or(inv-aux)" => 1, "$DP::DPEXT-Or(inv-have)" => 1,
                "$DP::DPEXT-Or(lex-dep)" => 1, "$DP::DPEXT-Or(lex-mod)" => 1, "$DP::DPEXT-Or(mod)" => 1,
                "$DP::DPEXT-Or(mod-before)" => 1, "$DP::DPEXT-Or(neg)" => 1, "$DP::DPEXT-Or(nn)" => 1,
                "$DP::DPEXT-Or(num)" => 1, "$DP::DPEXT-Or(num-mod)" => 1, "$DP::DPEXT-Or(obj)" => 1,
                "$DP::DPEXT-Or(obj1)" => 1, "$DP::DPEXT-Or(obj2)" => 1, "$DP::DPEXT-Or(p)" => 1,
                "$DP::DPEXT-Or(p-spec)" => 1, "$DP::DPEXT-Or(pcomp-c)" => 1, "$DP::DPEXT-Or(pcomp-n)" => 1,
                "$DP::DPEXT-Or(person)" => 1, "$DP::DPEXT-Or(pnmod)" => 1, "$DP::DPEXT-Or(poss)" => 1,
                "$DP::DPEXT-Or(post)" => 1, "$DP::DPEXT-Or(pre)" => 1, "$DP::DPEXT-Or(pred)" => 1,
                "$DP::DPEXT-Or(punc)" => 1, "$DP::DPEXT-Or(rel)" => 1, "$DP::DPEXT-Or(s)" => 1,
                "$DP::DPEXT-Or(sc)" => 1, "$DP::DPEXT-Or(subcat)" => 1, "$DP::DPEXT-Or(subclass)" => 1,
                "$DP::DPEXT-Or(subj)" => 1, "$DP::DPEXT-Or(title)" => 1, "$DP::DPEXT-Or(vrel)" => 1,
                "$DP::DPEXT-Or(wha)" => 1, "$DP::DPEXT-Or(whn)" => 1, "$DP::DPEXT-Or(whp)" => 1,
                "$DP::DPEXT-Oc(*)" => 1, "$DP::DPEXT-Ol(*)" => 1, "$DP::DPEXT-Or(*)" => 1,
                "$DP::DPEXT-HWCM_w-1" => 1, "$DP::DPEXT-HWCM_w-2" => 1, "$DP::DPEXT-HWCM_w-3" => 1,
                "$DP::DPEXT-HWCM_w-4" => 1, "$DP::DPEXT-HWCM_c-1" => 1, "$DP::DPEXT-HWCM_c-2" => 1,
                "$DP::DPEXT-HWCM_c-3" => 1, "$DP::DPEXT-HWCM_c-4" => 1, "$DP::DPEXT-HWCM_r-1" => 1,
                "$DP::DPEXT-HWCM_r-2" => 1, "$DP::DPEXT-HWCM_r-3" => 1, "$DP::DPEXT-HWCM_r-4" => 1,
                "$DP::DPEXT-HWCMi_w-2" => 1, "$DP::DPEXT-HWCMi_w-3" => 1, "$DP::DPEXT-HWCMi_w-4" => 1,
                "$DP::DPEXT-HWCMi_c-2" => 1, "$DP::DPEXT-HWCMi_c-3" => 1, "$DP::DPEXT-HWCMi_c-4" => 1,
                "$DP::DPEXT-HWCMi_r-2" => 1, "$DP::DPEXT-HWCMi_r-3" => 1, "$DP::DPEXT-HWCMi_r-4" => 1

                #, "$DP::DPEXT-Pl(*)" => 1, "$DP::DPEXT-Rl(*)" => 1, "$DP::DPEXT-Fl(*)" => 1,
                #"$DP::DPEXT-Pc(*)" => 1, "$DP::DPEXT-Rc(*)" => 1, "$DP::DPEXT-Fc(*)" => 1,
                #"$DP::DPEXT-Pr(*)" => 1, "$DP::DPEXT-Rr(*)" => 1, "$DP::DPEXT-Ff(*)" => 1
};

$DP::rDPspacat = { };

#GRAMMATICAL CATEGORIES
# 
#The meanings of grammatical categories are explained as follows:
#
#  Det: Determiners
#  PreDet: Pre-determiners (search for PreDet in data/wndict.lsp for instances)
#  PostDet: Post-determiners (search for PostDet in data/wndict.lsp for instances)
#  NUM: numbers
#  C: Clauses
#  I: Inflectional Phrases
#  V: Verb and Verb Phrases
#  N: Noun and Noun Phrases
#  NN: noun-noun modifiers
#  P: Preposition and Preposition Phrases
#  PpSpec: Specifiers of Preposition Phrases (search for PpSpec
#          in data/wndict.lsp for instances)
#  A: Adjective/Adverbs
#  Have: have
#  Aux:  Auxilary verbs, e.g. should, will, does, ...
#  Be:   Different forms of be: is, am, were, be, ...
#  COMP:  Complementizer
#  VBE: be used as a linking verb. E.g., I am hungry
#  V_N   verbs with one argument (the subject), i.e., intransitive verbs
#  V_N_N verbs with two arguments, i.e., transitive verbs
#  V_N_I verbs taking small clause as complement

# GRAMMATICAL RELATIONSHIPS
# 
#The following is a list of all the grammatical relationships in Minipar. Search for (dep-type relation) in data/minipar.lsp for the meaning of relation.
#
#  appo    "ACME president, --appo-> P.W. Buckman"
#  aux     "should <-aux-- resign"
#  be      "is <-be-- sleeping"
#  c       "that <-c-- John loves Mary"
#  comp1   first complement
#  det     "the <-det `-- hat"
#  gen     "Jane's <-gen-- uncle"
#  have    "have <-have-- disappeared"
#  i       the relationship between a C clause and its I clause
#  inv-aux inverted auxiliary: "Will <-inv-aux-- you stop it?
#  inv-be  inverted be: "Is <-inv-be-- she sleeping"
#  inv-have inverted have: "Have <-inv-have-- you slept"
#  mod     the relationship between a word and its adjunct modifier
#  pnmod   post nominal modifier
#  p-spec  specifier of prepositional phrases
#  pcomp-c clausal complement of prepositions
#  pcomp-n nominal complement of prepositions
#  post    post determiner
#  pre     pre determiner
#  pred    predicate of a clause
#  rel     relative clause
#  vrel    passive verb modifier of nouns
#  wha, whn, whp: wh-elements at C-spec positions
#  obj     object of verbs
#  obj2    second object of ditransitive verbs
#  subj    subject of verbs
#  s       surface subject

# -------------------------------------------------

sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;
    if ($language eq $Common::L_ENG) { %metric_set = %{$DP::rDPeng}; }
    #elsif  ($language eq $Common::L_SPA) { %metric_set = %{$DP::rDPspacat}; }
    #elsif  ($language eq $Common::L_CAT) { %metric_set = %{$DP::rDPspacat}; }

    return \%metric_set;
}

sub FOREST_parse {
   #description _ runs MINIPAR on a given file (1 sentence per line)
   #              and returns the resulting constituency / dependency forest
   #param1  _ input file
   #param2  _ kind of trees (0 - constituency trees :: 1 - dependency trees)
   #param3  _ tools
   #param4  _ verbosity (0/1)
   #@return _ forest (list of dependency trees)

   my $file = shift;
   my $kind = shift;
   my $tools = shift;
   my $verbose = shift;

   my @FOREST;

   my $forest = $file.".$DP::DPEXT.".($kind?"d":"c")."-forest";

   if (!(-e $forest)) {
      if (-e "$forest.$Common::GZEXT") { system("gunzip $forest.$Common::GZEXT"); }
      else {
         if ($verbose > 1) { print STDERR "running minipar parser [$file -> $forest]\n"; }
         my $toolDPparser = "$tools/$DP::TDPparser";
         Common::execute_or_die("$toolDPparser ".($kind?"":"-c ")." < $file > $forest 2> /dev/null", "[ERROR] problems running dependency parser...");
	 #print STDERR "execute $toolDPparser ".($kind?"":"-c ")." < $file > $forest ";
	 
      }
   }

   open(AUX, "< $forest") or die "couldn't open file: $forest\n";

   while (my $line = <AUX>) {
      chomp($line);
      if ($line=~/\> \(/) {
         my @tree;
         my $STOP = 0;
         while (!$STOP) {
            my $l = <AUX>;
            chomp($l);
            if ($l =~ /^\)$/) { $STOP = 1; }
            else {
               $l =~ s/\(//g;
               $l =~ s/\)//g;
               $l =~ s/\~ //g;
               my @entry = split(/\t/,$l);
               #print Dumper(\@entry);
               #my $idNode = $entry[0]; #my $word = $entry[1]; #my $nodeF = $entry[3];
               my $cat = $entry[2];
               my $catNode = "";
               if (scalar(@entry) > 4) { $catNode = $entry[4]; }
               if ($catNode ne ""){ $cat=~/(\S*)$/; $cat=$1; $entry[2] = $cat; push(@tree, \@entry); }
               #ENTRY = idNode word cat nodeF catNode [gov] [antecedent]
	        }
         }

         #print "*****************************\n";
         #print Dumper \@tree;
         #print "*****************************\n";

         push(@FOREST, \@tree);
      }
   }

   close(AUX);

   #print "*****************************\n";
   #print Dumper \@FOREST;
   #print "*****************************\n";

   #print "### TOPICS = ", scalar(@FOREST), "\n";

   system("$Common::GZIP $forest");

   return \@FOREST;
}

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

sub TREE_extract_base_features {
   #description _ extracts base features from a given tree.
   #param1  _ tree
   #@return _ tree (+features)

   my $tree = shift;

   my %TREE;
   my %nP;
   my %nT;
   foreach my $elem (@{$tree}) {
      my ($node,$term,$cat,$dad,$role)=@{$elem};
      #print "NODE = $node :: TERM = $term :: CAT = $cat :: FATHER = $dad :: ROLE = $role\n";
      $nP{$node}=$dad;
      $nT{$node}=1;
      $nT{$dad}=1;
      $TREE{nodeRol}->{$node} = $role;
      $TREE{nodeCat}->{$node} = $cat;
      push(@{$TREE{children}->{$dad}}, $node); #########
      $TREE{nodeTerm}->{$node} = $term;
      if ($term ne ""){
         push(@{$TREE{featureTerms}->{"$DP::DPEXT-Oc(".lc($cat).")"}}, $term); ########
         #push(@{$TREE{featureTerms}->{"$DP::DPEXT-Oc(".$cat.")"}}, $term); ########
      }
   }
   foreach my $n (keys %nT){
      if (!exists($nP{$n})) { push(@{$TREE{children}->{"0"}}, $n); }
      else {
         if (!($nP{$n}=~/\S/)){ push(@{$TREE{children}->{"0"}}, $n); }
      }
   }

   #print Dumper \%TREE;

   return \%TREE;
}

sub TREE_extract_recursive_features {
   #description _ recursively extracts features from a given tree.
   #param1  _ tree (+ only base features)
   #param2  _ current node
   #param3  _ current level
   #@return _ set of visited terms (synthesized)

   my $tree=shift;
   my $node=shift;
   my $level=shift;

#   print "NODE = $node :: LEVEL = $level\n";

   my @terms;
   if (exists($tree->{nodeTerm}->{$node})) {
      if (($tree->{nodeTerm}->{$node} ne "")) { $level++; }
      foreach my $n ($tree->{nodeTerm}->{$node}) { if ((defined($n)) and ($n ne "")) { push(@terms, $n); } }
   }

   my $hwcW;
   my $hwcC;
   my $hwcR;

   if (exists($tree->{children}->{$node})) { # NON-TERMINAL NODE
      foreach my $child (@{$tree->{children}->{$node}}) {
         if ($child ne ""){
            my ($aux, $rW, $rC, $rR) = TREE_extract_recursive_features($tree, $child, $level);
            foreach my $a (@{$aux}) { if ((defined($a)) and ($a ne "")) { push(@terms, $a); } }
            if (defined($rW)) {
               my $i = 0;
               if (!defined($hwcW)) { my @hwc; $hwcW = \@hwc; }
               while ($i < scalar(@{$rW})) {
                  if (!defined($hwcW->[$i])) { my @hwci; $hwcW->[$i] = \@hwci; }
                  foreach my $chain (@{$rW->[$i]}) {
                     push(@{$hwcW->[$i]}, $chain);
                  }
  	              $i++;
	           }
	        }
            if (defined($rC)) {
               my $i = 0;
               if (!defined($hwcC)) { my @hwc; $hwcC = \@hwc; }
               while ($i < scalar(@{$rC})) {
                  if (!defined($hwcC->[$i])) { my @hwci; $hwcC->[$i] = \@hwci; }
                  foreach my $chain (@{$rC->[$i]}) {
                     push(@{$hwcC->[$i]}, $chain);
                  }
                  $i++;
               }
            }
            if (defined($rR)) {
               my $i = 0;
               if (!defined($hwcR)) { my @hwc; $hwcR = \@hwc; }
               while ($i < scalar(@{$rR})) {
                  if (!defined($hwcR->[$i])) { my @hwci; $hwcR->[$i] = \@hwci; }
                  foreach my $chain (@{$rR->[$i]}) {
                     push(@{$hwcR->[$i]}, $chain);
                  }
                  $i++;
               }
            }
         }
      }
      # ~(HWCM) head-word chain matching (Liu and Gildea, 2005) --------------------------------------------------
      if (exists($tree->{nodeTerm}->{$node})) {
         if ($tree->{nodeTerm}->{$node} ne "") {
            if (!defined($hwcW)) { my @hwc; $hwcW = \@hwc; }
            my $i = scalar(@{$hwcW});
            if ($i > $DMAX - 1) { $i = $DMAX - 1; }
            while ($i > 0 ) {
               foreach my $chain (@{$hwcW->[$i-1]}) {
                  my @newchain = @{$chain};
                  unshift(@newchain, $tree->{nodeTerm}->{$node});
                  push(@{$hwcW->[$i]}, \@newchain);
   	           }
	           $i--;
            }
            my @chain = ($tree->{nodeTerm}->{$node});
            push(@{$hwcW->[0]}, \@chain);
         }
      }
      if (exists($tree->{nodeCat}->{$node})) {
         if ($tree->{nodeCat}->{$node} ne "") {
            if (!defined($hwcC)) { my @hwc; $hwcC = \@hwc; }
            my $i = scalar(@{$hwcC});
            if ($i > $DMAX - 1) { $i = $DMAX - 1; }
            while ($i > 0 ) {
               foreach my $chain (@{$hwcC->[$i-1]}) {
                  my @newchain = @{$chain};
                  unshift(@newchain, $tree->{nodeCat}->{$node});
                  push(@{$hwcC->[$i]}, \@newchain);
               }
               $i--;
            }
            my @chain = ($tree->{nodeCat}->{$node});
            push(@{$hwcC->[0]}, \@chain);
         }
      }
      if (exists($tree->{nodeRol}->{$node})) {
         if ($tree->{nodeRol}->{$node} ne "") {
            if (!defined($hwcR)) { my @hwc; $hwcR = \@hwc; }
            my $i = scalar(@{$hwcR});
            if ($i > $DMAX - 1) { $i = $DMAX - 1; }
            while ($i > 0 ) {
               foreach my $chain (@{$hwcR->[$i-1]}) {
                  my @newchain = @{$chain};
                  unshift(@newchain, $tree->{nodeRol}->{$node});
                  push(@{$hwcR->[$i]}, \@newchain);
   	           }
               $i--;
            }
            my @chain = ($tree->{nodeRol}->{$node});
            push(@{$hwcR->[0]}, \@chain);
         }
      }
   }
   else { # TERMINAL NODE (LEAVE)
      if (exists($tree->{nodeTerm}->{$node})) {
         if ($tree->{nodeTerm}->{$node} ne "") {
            if (!defined($hwcW)) { my @hwc; $hwcW = \@hwc; }
            my @chain = ($tree->{nodeTerm}->{$node});
            push(@{$hwcW->[0]}, \@chain);
         }
      }
      if (exists($tree->{nodeCat}->{$node})) {
         if ($tree->{nodeCat}->{$node} ne "") {
            if (!defined($hwcC)) { my @hwc; $hwcC = \@hwc; }
            my @chain = ($tree->{nodeCat}->{$node});
            push(@{$hwcC->[0]}, \@chain);
         }
      }
      if (exists($tree->{nodeRol}->{$node})) {
         if ($tree->{nodeRol}->{$node} ne "") {
            if (!defined($hwcR)) { my @hwc; $hwcR = \@hwc; }
            my @chain = ($tree->{nodeRol}->{$node});
            push(@{$hwcR->[0]}, \@chain);
         }
      }
   }
   # ------------------------------------------------------------------------------------------

   if (scalar(@terms)) {
      if (exists($tree->{nodeRol}->{$node})) {
         my $featureTree="$DP::DPEXT-Or(".lc($tree->{nodeRol}->{$node}).")";
         #my $featureTree="$DP::DPEXT-Or(".$tree->{nodeRol}->{$node}.")";
         foreach my $elem (@terms) { push(@{$tree->{featureTerms}->{$featureTree}}, $elem); }
      }
      if ($level > 0) {
         foreach my $elem (@terms) { push(@{$tree->{featureTerms}->{"$DP::DPEXT-Ol(".$level.")"}}, $elem); }
      }
   } 

   return (\@terms, $hwcW, $hwcC, $hwcR);
}

sub compute_hwcm {
   #description _ computes HWCM between elems in candidate and reference list of features
   #param1 _ candidate list of features
   #param2 _ reference list of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $L1 = shift;
   my $L2 = shift;
   my $LC = shift;

   my %H1; my %H2; my %H12;   my $hits=0;   my $total=0;
   foreach my $l (@{$L1}) { $H1{$LC? lc(join($SEP, @{$l})) : join($SEP, @{$l})}++;
                            $H12{$LC? lc(join($SEP, @{$l})) : join($SEP, @{$l})}++; }
   foreach my $l (@{$L2}) { $H2{$LC? lc(join($SEP, @{$l})) : join($SEP, @{$l})}++;
                            $H12{$LC? lc(join($SEP, @{$l})) : join($SEP, @{$l})}++; }
   foreach my $elem (keys %H12){
      if ($H1{$elem} and $H2{$elem}) {
	 if ($H1{$elem} > $H2{$elem}) { $hits += $H2{$elem}; $total += $H1{$elem}; }
         else { $hits += $H1{$elem}; $total += $H2{$elem}; }
      }
      elsif ($H1{$elem}) { $total += $H1{$elem}; }
      elsif ($H2{$elem}) { $total += $H2{$elem}; }
   }

   return ($hits, $total);
}

sub TREE_compute_score {
   #description _ computes distances between a candidate and a reference tree (+features)
   #param1 _ candidate tree (+features)
   #param2 _ reference tree (+features)
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $Tout = shift;
   my $Tref = shift;
   my $LC = shift;

	#print "features in dependency parsing\n";
	#print Dumper $Tref;

   my %F;
   foreach my $f (keys %{$Tout->{featureTerms}}) { $F{$f} = 1; }
   foreach my $f (keys %{$Tref->{featureTerms}}) { $F{$f} = 1; }

   my %SCORES;
   foreach my $feature (keys %F) {
      if ((exists($Tout->{featureTerms}->{$feature})) and (exists($Tref->{featureTerms}->{$feature}))) {
         my ($hits, $total) = Overlap::compute_overlap_l($Tout->{featureTerms}->{$feature}, $Tref->{featureTerms}->{$feature}, $LC);
         $SCORES{$feature} = Common::safe_division($hits, $total);
      }
      else { $SCORES{$feature} = 0; }
   }

   # HWCM_word -----------------------------------------------------------------------------
   if (defined($Tout->{hwcW}) and defined($Tref->{hwcW})) {
      my $L1; my $L2;
      if (scalar(@{$Tout->{hwcW}}) > scalar(@{$Tref->{hwcW}})) { $L1 = $Tout->{hwcW}; $L2 = $Tref->{hwcW}; }
      else { $L1 = $Tref->{hwcW}; $L2 = $Tout->{hwcW}; } 
      my $i = 0;
      my $HITS = 0;   my $TOTAL = 0;
      while ($i < $DP::MAXHWC_LENGTH) {
         if (defined($L1->[$i]) and defined($L2->[$i])) {
            my ($hits, $total) = compute_hwcm($L1->[$i], $L2->[$i], $LC);
            $SCORES{$DP::DPEXT."-HWCMi_w-".($i+1)} = Common::safe_division($hits, $total);
            $HITS += $hits; $TOTAL += $total;
            $SCORES{$DP::DPEXT."-HWCM_w-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         else {
            $SCORES{$DP::DPEXT."-HWCMi_w-".($i+1)} = 0;
            $TOTAL += (defined($L1->[$i])? scalar(@{$L1->[$i]}) : 0) + (defined($L2->[$i])? scalar(@{$L2->[$i]}) : 0);
      	    $SCORES{$DP::DPEXT."-HWCM_w-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         $i++;
      }
   }
   # HWCM_cat ------------------------------------------------------------------------------
   if (defined($Tout->{hwcC}) and defined($Tref->{hwcC})) {
      my $L1; my $L2;
      if (scalar(@{$Tout->{hwcC}}) > scalar(@{$Tref->{hwcC}})) { $L1 = $Tout->{hwcC}; $L2 = $Tref->{hwcC}; }
      else { $L1 = $Tref->{hwcC}; $L2 = $Tout->{hwcC}; } 
      my $i = 0;
      my $HITS = 0;   my $TOTAL = 0;
      while ($i < $DP::MAXHWC_LENGTH) {
         if (defined($L1->[$i]) and defined($L2->[$i])) {
            my ($hits, $total) = compute_hwcm($L1->[$i], $L2->[$i], $LC);
            $SCORES{$DP::DPEXT."-HWCMi_c-".($i+1)} = Common::safe_division($hits, $total);
            $HITS += $hits; $TOTAL += $total;
            $SCORES{$DP::DPEXT."-HWCM_c-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         else {
            $SCORES{$DP::DPEXT."-HWCMi_c-".($i+1)} = 0;
            $TOTAL += (defined($L1->[$i])? scalar(@{$L1->[$i]}) : 0) + (defined($L2->[$i])? scalar(@{$L2->[$i]}) : 0);
      	    $SCORES{$DP::DPEXT."-HWCM_c-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         $i++;
      }
   }
   # HWCM_r ------------------------------------------------------------------------------
   if (defined($Tout->{hwcR}) and defined($Tref->{hwcR})) {
      my $L1; my $L2;
      if (scalar(@{$Tout->{hwcR}}) > scalar(@{$Tref->{hwcR}})) { $L1 = $Tout->{hwcR}; $L2 = $Tref->{hwcR}; }
      else { $L1 = $Tref->{hwcR}; $L2 = $Tout->{hwcR}; } 
      my $i = 0;
      my $HITS = 0;   my $TOTAL = 0;
      while ($i < $DP::MAXHWC_LENGTH) {
         if (defined($L1->[$i]) and defined($L2->[$i])) {
            my ($hits, $total) = compute_hwcm($L1->[$i], $L2->[$i], $LC);
            $SCORES{$DP::DPEXT."-HWCMi_r-".($i+1)} = Common::safe_division($hits, $total);
            $HITS += $hits; $TOTAL += $total;
            $SCORES{$DP::DPEXT."-HWCM_r-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         else {
            $SCORES{$DP::DPEXT."-HWCMi_r-".($i+1)} = 0;
            $TOTAL += (defined($L1->[$i])? scalar(@{$L1->[$i]}) : 0) + (defined($L2->[$i])? scalar(@{$L2->[$i]}) : 0);
      	    $SCORES{$DP::DPEXT."-HWCM_r-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         $i++;
      }
   }

   return \%SCORES;
}

sub TREE_print_features {
   #description _ prints features in a given tree
   #param1 _ tree (+features)

   my $T = shift;

   foreach my $feature (keys %{$T->{featureTerms}}) {
      print "$feature = ", join(" ", @{$T->{featureTerms}->{$feature}}), "\n";
   }
}

sub FOREST_compute_metrics {
   #description _ computes MINIPAR scores (single reference)
   #param1  _ candidate forest (+features)
   #param2  _ reference forest (+features)
   #param3  _ do_lower_case evaluation (1:yes->case_insensitive :: 0:no->case_sensitive)
   #@return _ scores (list -> one item per tree)

   my $FOUT = shift;
   my $FREF = shift;
   my $LC = shift;

   #print Dumper($FOUT);
   #print Dumper($FREF);

   my @SCORES;
   ### TREE/LEVEL --------------------------------------------------------
   my $topic = 0;
   while ($topic < scalar(@{$FREF})) {
      #print "*********** ", $topic + 1, " / ", scalar(@{$FREF}), "**********\n";
      #print Dumper $FOUT->[$topic];
      my $OUTTREE = TREE_extract_base_features($FOUT->[$topic]);
      #print Dumper $OUTTREE;
      my ($OUTdummy, $OUThwcW, $OUThwcC, $OUThwcR) = TREE_extract_recursive_features($OUTTREE,"0",0);
      $OUTTREE->{hwcW} = $OUThwcW; $OUTTREE->{hwcC} = $OUThwcC; $OUTTREE->{hwcR} = $OUThwcR;
      #print Dumper $OUTTREE;
      #TREE_print_features($OUTTREE);
      #print "---------------------------------------------------------\n";
      #print Dumper $FREF->[$topic];
      my $REFTREE = TREE_extract_base_features($FREF->[$topic]);
      #print Dumper $REFTREE;
      my ($REFdummy, $REFhwcW, $REFhwcC, $REFhwcR) = TREE_extract_recursive_features($REFTREE,"0",0);
      $REFTREE->{hwcW} = $REFhwcW; $REFTREE->{hwcC} = $REFhwcC; $REFTREE->{hwcR} = $REFhwcR;
      #print Dumper $REFTREE;
      #TREE_print_features($REFTREE);
      #print "---------------------------------------------------------\n";
      $SCORES[$topic] = TREE_compute_score($OUTTREE, $REFTREE, $LC);
      #print Dumper $SCORES[$topic];
      $topic++;
   }

   return \@SCORES;
}

sub get_segment_scores {
   #description _ retrieves scores at the segment level for the given feature
   #              as well as the average system score (dealing with void values
   #              according to the given 'mode' value)
   #param1  _ MINIPAR feature scores
   #param2  _ feature
   #param3  _ mode
   #@return _ (system score, segment scores)

   my $scores = shift;
   my $feature = shift;
   my $mode = shift;

   my @Fscores;
   
   my $SYSscore = 0; my $N = 0;
   foreach my $topic (@{$scores}) {
      my $n = 0;
      my $SEGscore = 0;
      if ($feature eq "$DP::DPEXT-Oc(*)") { # average feature Oc(*=
         foreach my $f (keys %{$topic}) {
            if ($f =~ /^DP-Oc\(.*/) {
	       if (defined($topic->{$f})) { $SEGscore += $topic->{$f}; $n++; }
            }
         }
      }
      elsif ($feature eq "$DP::DPEXT-Ol(*)") { # average feature Ol(*)
         foreach my $f (keys %{$topic}) {
            if ($f =~ /^DP-Ol\(.*/) {
	       if (defined($topic->{$f})) { $SEGscore += $topic->{$f}; $n++; }
            }
         }
      }
      elsif ($feature eq "$DP::DPEXT-Or(*)") { # average feature Or(*)
         foreach my $f (keys %{$topic}) {
            if ($f =~ /^DP-Or\(.*/) {
	       if (defined($topic->{$f})) { $SEGscore += $topic->{$f}; $n++; }
            }
         }
      }
      else { # individual feature (Oc(*) / Or(*) /Ol(*)
         if (exists($topic->{$feature})) {
            if (defined($topic->{$feature})) {
               $SEGscore = $topic->{$feature};
               $n = 1;
	    }
         }
      }
      $SYSscore += $SEGscore;
      $N += $n;


      if ($mode == 0) {
	 if ($n == 0) { push(@Fscores, undef); }
         else { push(@Fscores, $SEGscore / $n); }
      }
      elsif ($mode == 1) {
         if ($n == 0) { $SEGscore = 1; $n = 1; } ##### !!!
         push(@Fscores, $SEGscore / $n);
      }
      elsif ($mode == 2) {
         if ($n == 0) { $SEGscore = 0; $n = 1; } ##### !!!
         push(@Fscores, $SEGscore / $n);
      }
   }

   if ($N == 0) { $SYSscore = (($mode == 0) or ($mode == 2))? 0 : 1; } ##### !!!
   else { $SYSscore /= $N; } 

   return ($SYSscore, \@Fscores);
}

sub doMultiDP {
   #description _ computes DP metric scores (multiple references)
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param6  _ hash of scores

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

   my $GO_ON = 0;
   foreach my $metric (keys %{$DP::rDPeng}) {
      if ($M->{$metric}) { $GO_ON = 1; }
   }

   if ($GO_ON) {
      if ($verbose == 1) { print STDERR "$DP::DPEXT.."; }

      my $DO_METRICS = $remakeREPORTS;
      if (!$DO_METRICS) {
         foreach my $metric (keys %{$DP::rDPeng}) {
            my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
            if ($M->{$metric} and !(-e $report_xml) and !(-e $report_xml.".$Common::GZEXT")) { $DO_METRICS = 1; }
         }
      }

      if ($DO_METRICS) {
         my $FDout = DP::FOREST_parse($out, 1, $tools, $verbose);
         my @maxscores;
         foreach my $ref (keys %{$Href}) {
            my $FDref = DP::FOREST_parse($Href->{$ref}, 1, $tools, $verbose);
            my $scores = DP::FOREST_compute_metrics($FDout, $FDref, $DP::USE_LOWERCASE);
            foreach my $metric (keys %{$DP::rDPeng}) {
 	        if (($M->{$metric}) or (($M->{"$DP::DPEXT-Oc(*)"}) and ($metric =~ /^DP-Oc\(.*/)) or (($M->{"$DP::DPEXT-Ol(*)"}) and ($metric =~ /^DP-Ol\(.*/)) or (($M->{"$DP::DPEXT-Or(*)"}) and ($metric =~ /^DP-Or\(.*/))) {
               my ($MAXSYS, $MAXSEGS) = DP::get_segment_scores(\@maxscores, $metric, 0);
               my ($SYS, $SEGS) = DP::get_segment_scores($scores, $metric, 0); 
               my $i = 0;
               while ($i < scalar(@{$SEGS})) { #update max scores
                  if (defined($SEGS->[$i])) {
                     if (defined($MAXSEGS->[$i])) {
                        if ($SEGS->[$i] > $MAXSEGS->[$i]) {
                           if (exists($scores->[$i]->{$metric})) {
                              $maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
                           }
                        }
                     }
                     else { $maxscores[$i]->{$metric} = $scores->[$i]->{$metric}; }
	              }
                  else { $maxscores[$i]->{$metric} = $scores->[$i]->{$metric}; }
                  $i++;
               }
             }
          }
      }

      foreach my $metric (keys %{$DP::rDPeng}) {
         if ($M->{$metric}) {
            my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
            my $report_xmlgz = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT.$Common::GZEXT";
               if ((!(-e $report_xml) and (!(-e $report_xmlgz))) or $remakeREPORTS) {
                  #my ($SYS, $SEGS) = DP::get_segment_scores(\@maxscores, $metric, 1);
                  my ($SYS, $SEGS) = DP::get_segment_scores(\@maxscores, $metric, 2);
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
