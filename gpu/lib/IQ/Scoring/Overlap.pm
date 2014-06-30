package Overlap;

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
use List::Util qw[min max];
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Metrics;

our ($rOl, $OlEXT, $PlEXT, $RlEXT, $FlEXT);

$Overlap::OlEXT = "Ol";
$Overlap::PlEXT = "Pl";
$Overlap::RlEXT = "Rl";
$Overlap::FlEXT = "Fl";
$Overlap::rOl = { "$Overlap::OlEXT" => 1, "$Overlap::PlEXT" => 1, "$Overlap::RlEXT" => 1, "$Overlap::FlEXT" => 1 };

sub metric_set {
    #description _ returns the set of available metrics
    #@return _ metric set structure (hash ref)

    return $Overlap::rOl;
}

sub compute_total {
   #description _ computes total in hash of features
   #param1 _ candidate hash of features

   my $h_candidate = shift;

   my $total=0;
   if (scalar(keys %{$h_candidate}) > 0) {
      foreach my $W (keys %{$h_candidate}) { $total += $h_candidate->{$W}; }
   }

   return $total;
}


sub extract_terms{
   #description _ extract the hash-counts of features
   #param1 _ candidate hash of features
   #param2 _ reference hash of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $h_candidate = shift;
   my $h_reference = shift;
   my $LC = shift;

   my %terms_candidate; my %terms_reference; my %termsTot;

   if (scalar(keys %{$h_candidate}) > 0) {
      foreach my $W (keys %{$h_candidate}) {
         my $t;
         if ($LC) { $t = lc($W); }
         else { $t = $W; }
         $terms_candidate{$t} += $h_candidate->{$W}; 
         $termsTot{$t} += $h_candidate->{$W};
      }
   }
   if (scalar(keys %{$h_reference}) > 0) {
      foreach my $W (keys %{$h_reference}) {
         my $t;
         if ($LC) { $t = lc($W); }
         else { $t = $W; }
         $terms_reference{$t} += $h_reference->{$W}; 
         $termsTot{$t} += $h_reference->{$W};
      }
   }
   return (\%terms_candidate,\%terms_reference,\%termsTot);
}

sub compute_overlap {
   #description _ computes overlap between elems in candidate and reference hash of features
   #param1 _ candidate hash of features
   #param2 _ reference hash of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $h_candidate = shift;
   my $h_reference = shift;
   my $LC = shift;

   my $hits = 0; my $total = 0;

   my ($terms_candidate, $terms_reference, $termsTot) = extract_terms ($h_candidate, $h_reference, $LC);
   my %terms_candidate = %$terms_candidate;
   my %terms_reference = %$terms_reference;
   my %termsTot = %$termsTot;

   if ((scalar(keys %{$h_candidate}) > 0) and (scalar(keys %{$h_reference}) > 0)) {
      foreach my $term (keys %termsTot){
         if ($terms_candidate{$term} && $terms_reference{$term}) {
            if ($terms_candidate{$term} > $terms_reference{$term}) {
               $hits += $terms_reference{$term};
               $total += $terms_candidate{$term};
            }
            else {
               $hits += $terms_candidate{$term};
               $total += $terms_reference{$term};
            }
         }
         else {
            if ($terms_candidate{$term}) { $total += $terms_candidate{$term}; }
            elsif ($terms_reference{$term}) { $total += $terms_reference{$term}; }
	 		}
      }
   }
   else { foreach my $term (keys %termsTot) { $total += $termsTot{$term}; } }

   return ($hits, $total);
}

sub compute_precision {
   #description _ computes precision (proportion of elems in the candidate also in the reference hash of features)
   #param1 _ candidate hash of features
   #param2 _ reference hash of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $h_candidate = shift;
   my $h_reference = shift;
   my $LC = shift;

   my $hits = 0; my $total = 0;

   my ($terms_candidate, $terms_reference, $termsTot) = extract_terms ($h_candidate, $h_reference, $LC);
   my %terms_candidate = %$terms_candidate;
   my %terms_reference = %$terms_reference;
   my %termsTot = %$termsTot;

   if ((scalar(keys %{$h_candidate}) > 0) and (scalar(keys %{$h_reference}) > 0)) {
      foreach my $term (keys %termsTot){
         if ($terms_candidate{$term} && $terms_reference{$term}) {
	    if ($terms_candidate{$term} > $terms_reference{$term}) {
               $hits += $terms_reference{$term};
               $total += $terms_candidate{$term};
            }
            else {
               $hits += $terms_candidate{$term};
               $total += $terms_candidate{$term};
            }
         }
         else {
            if ($terms_candidate{$term}) { $total += $terms_candidate{$term}; }
	 }
      }
   }
   return ($hits, $total);
}

sub compute_recall {
   #description _ computes recall (proportion of elems in the reference also in the candidate hash of features)
   #param1 _ candidate hash of features
   #param2 _ reference hash of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $h_candidate = shift;
   my $h_reference = shift;
   my $LC = shift;

   my $hits = 0; my $total = 0;

   my ($terms_candidate, $terms_reference, $termsTot) = extract_terms ($h_candidate, $h_reference, $LC);
   my %terms_candidate = %$terms_candidate;
   my %terms_reference = %$terms_reference;
   my %termsTot = %$termsTot;

   if ((scalar(keys %{$h_candidate}) > 0) and (scalar(keys %{$h_reference}) > 0)) {
      foreach my $term (keys %termsTot){
         if ($terms_candidate{$term} && $terms_reference{$term}) {
	    if ($terms_reference{$term} < $terms_candidate{$term}) {
               $hits += $terms_reference{$term};
               $total += $terms_reference{$term};
            }
            else {
               $hits += $terms_candidate{$term};
               $total += $terms_reference{$term};
            }
         }
         else {
            if ($terms_reference{$term}) { $total += $terms_reference{$term}; }
         }
      }
   }

   return ($hits, $total);
}


sub compute_overlap_l {
   #description _ computes overlap between elems in candidate and reference list of features
   #param1 _ candidate list of features
   #param2 _ reference list of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $L1 = shift;
   my $L2 = shift;
   my $LC = shift;

   my %terms_candidate; my %terms_reference; my %termsTot; my $hits = 0; my $total = 0;
   foreach my $term (@{$L1}) {
      if ($term ne ""){
	     my $t;
         if ($LC) { $t = lc($term); }
         else { $t = $term; }
         $terms_candidate{$t}++; 
         $termsTot{$t}++;
      }
   }
   foreach my $term (@{$L2}) {
      if ($term ne ""){
         my $t; if ($LC) { $t = lc($term); } else { $t = $term; }
         $terms_reference{$t}++; $termsTot{$t}++;
      }
   }
   foreach my $term (keys %termsTot){
      if ($terms_candidate{$term} && $terms_reference{$term}) {
         if ($terms_candidate{$term} > $terms_reference{$term}) {
            $hits += $terms_reference{$term};
            $total += $terms_candidate{$term};
         }
         else {
            $hits += $terms_candidate{$term};
            $total += $terms_reference{$term};
         }
      }
      else {
         if ($terms_candidate{$term}) { $total += $terms_candidate{$term}; }
         elsif ($terms_reference{$term}) { $total += $terms_reference{$term}; }
      }
   }

   return ($hits, $total);
}

sub compute_precision_l {
   #description _ computes precision (proportion of elems in the candidate also in the reference list of features)
   #param1 _ candidate list of features
   #param2 _ reference list of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $L1 = shift;
   my $L2 = shift;
   my $LC = shift;

   my %terms_candidate; my %terms_reference; my %termsTot; my $hits=0; my $total=0;
   foreach my $term (@{$L1}) {
      if ($term ne ""){
	     my $t;
         if ($LC) { $t = lc($term); }
         else { $t = $term; }
         $terms_candidate{$t}++; $termsTot{$t}++;
      }
   }
   foreach my $term (@{$L2}) {
      if ($term ne ""){
         my $t; if ($LC) { $t = lc($term); } else { $t = $term; }
         $terms_reference{$t}++; $termsTot{$t}++;
      }
   }


   foreach my $term (keys %termsTot){
      if ($terms_candidate{$term} && $terms_reference{$term}) {
         if ($terms_candidate{$term} > $terms_reference{$term}) {
            $hits += $terms_reference{$term};
            $total += $terms_candidate{$term};
         }
         else {
            $hits += $terms_candidate{$term};
            $total += $terms_candidate{$term};
         }
      }
      else {
         if ($terms_candidate{$term}) { $total += $terms_candidate{$term}; }
      }
   }

   return ($hits, $total);
}

sub compute_recall_l {
   #description _ computes recall (proportion of elems in the reference also in the candidate list of features)
   #param1 _ candidate list of features
   #param2 _ reference list of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $L1 = shift;
   my $L2 = shift;
   my $LC = shift;

   my %terms_candidate; my %terms_reference; my %termsTot; my $hits=0; my $total=0;
   foreach my $term (@{$L1}) {
      if ($term ne ""){
	     my $t;
         if ($LC) { $t = lc($term); }
         else { $t = $term; }
         $terms_candidate{$t}++; $termsTot{$t}++;
      }
   }
   foreach my $term (@{$L2}) {
      if ($term ne ""){
         my $t; if ($LC) { $t = lc($term); } else { $t = $term; }
         $terms_reference{$t}++; $termsTot{$t}++;
      }
   }

   foreach my $term (keys %termsTot){
      if ($terms_candidate{$term} && $terms_reference{$term}) {
         if ($terms_reference{$term} < $terms_candidate{$term}) {
            $hits += $terms_candidate{$term};
            $total += $terms_reference{$term};
         }
         else {
            $hits += $terms_reference{$term};
            $total += $terms_reference{$term};
         }
      }
      else {
         if ($terms_reference{$term}) { $total += $terms_reference{$term}; }
      }
   }

   return ($hits, $total);
}

sub get_segment_scores {
   #description _ retrieves scores at the segment level for the given feature
   #              as well as the average system score (dealing with void values
   #              according to the given 'mode' value)
   #param1  _ feature scores
   #param2  _ feature
   #param3  _ mode
   #@return _ (system score, segment scores)

   my $scores = shift;
   my $feature = shift;
   my $mode = shift;

   my @Fscores;
   my $SYSscore = 0; my $N = 0;
   foreach my $topic (@{$scores}) {
      my $n = 0; #feature exists? 0:no, 1:yes
      my $SEGscore = 0;
      if (exists($topic->{$feature})) {
         if (defined($topic->{$feature})) {
            if (exists($topic->{OK})) {
               if ($topic->{OK} == 1) { $SEGscore = $topic->{$feature}; $n = 1; }
            }
            else { $SEGscore = $topic->{$feature}; $n = 1; }
         }
      }

      $SYSscore += $SEGscore;
      $N+= $n;
      if ($n == 0) {
         if ($mode == 0) { undef($SEGscore); }
         elsif ($mode == 1) { $SEGscore = 1; }
         elsif ($mode == 2) { $SEGscore = 0; }
      }
      push(@Fscores, $SEGscore);
   }

   if ($N == 0) {
      if ($mode == 0) { $SYSscore = 0; }
      elsif ($mode == 1) { $SYSscore = 1; }
      elsif ($mode == 2) { $SYSscore = 0; }
   }
   else { $SYSscore /= $N; } 

   return ($SYSscore, \@Fscores);
}

sub compute_average_score {
   #description _ retrieves average metric score
   #param1 _ metric scores
   #param2 _ metric name 1

   my $scores = shift;
   my $metric = shift;

   my $SYSscore = 0; my $N = 0;
   foreach my $topic (@{$scores}) {
      my $n = 0; #feature exists? 0:no, 1:yes
      my $SEGscore = 0;
      if (exists($topic->{$metric})) {
         if (defined($topic->{$metric})) {
            if (exists($topic->{OK})) {
               if ($topic->{OK} == 1) { $SEGscore = $topic->{$metric}; $n = 1; }
            }
            else { $SEGscore = $topic->{$metric}; $n = 1; }
         }
      }
      $SYSscore += $SEGscore;
      $N+= $n;
   }

   my $SYS = Common::safe_division($SYSscore, $N);

   return ($SYS);
}

sub merge_metrics {
   #description _ merge metrics 1 and 2 according to the given mode
   #param1 _ metric scores
   #param2 _ metric name 1
   #param3 _ metric name 2
   #param4 _ merging mode  (0: back-off, 1:interpolation A, 2:interpolation B)

   my $scores = shift;
   my $metric1 = shift;
   my $metric2 = shift;
   my $mode = shift;

   my $avg1 = compute_average_score($scores, $metric1);
   #my $avg2 = compute_average_score($scores, $metric2);

   my @Fscores;
   my $SYSscore = 0; my $N = 0;
   my $i = 0;
   while ($i < scalar(@{$scores})) {
      my $topic = $scores->[$i];
      my $n1 = 0; my $n2 = 0; #feature exists? 0:no, 1:yes
      if (exists($topic->{$metric1})) {
         if (exists($topic->{OK})) { if ($topic->{OK} == 1) { $n1 = 1; } }
         else { $n1 = 1; }
      }
      if (exists($topic->{$metric2})) { $n2 = 1; }

      my $SEGscore = 0;
      if ($n1 and $n2) {
         if ($mode == 0) { $SEGscore = $topic->{$metric1}; }
         #elsif ($mode == 1) { $SEGscore = ($topic->{$metric1} + ($topic->{$metric2} * $avg1)) / 2; }
         elsif ($mode == 1) { $SEGscore = ($topic->{$metric1} + $topic->{$metric2}) / 2; }
      }
      elsif ($n1 and !$n2) {
         $SEGscore = $topic->{$metric1};
      }
      elsif (!$n1 and $n2) {
         if ($mode == 0) { $SEGscore = $topic->{$metric2} * $avg1; }
	     elsif ($mode == 1) { $SEGscore = ($topic->{$metric2} * $avg1) / 2; }         
         elsif ($mode == 1) { $SEGscore = $topic->{$metric2} / 2; }         
      }
      else { #!n1 and !n2
         $SEGscore = 0;
      }         

      #if ($n1 or $n2) { $N++; $SYSscore += $SEGscore; }
      #if ($n1) { $N++; $SYSscore += $SEGscore; }
      $N++; $SYSscore += $SEGscore;

      push(@Fscores, $SEGscore);
      #print "[$n1 $n2 $SEGscore $avg $mode]\n";
      #print Dumper $topic;

      $i++;
   }

   my $SYS = Common::safe_division($SYSscore, $N);

   #print Dumper \@Fscores;

   return ($SYS, \@Fscores);
}



sub get_segment_scores_M {
   #description _ retrieves scores at the segment level for the given feature
   #              as well as the average system score (dealing with void values
   #              according to the given 'mode' value) ---> (multiple reference setting)
   #param1  _ feature scores
   #param2  _ feature
   #param3  _ mode
   #param4  _ OK parsing structure
   #@return _ (system score, segment scores)

   my $scores = shift;
   my $feature = shift;
   my $mode = shift;
   my $OK = shift;

   my @Fscores;
   my $SYSscore = 0; my $N = 0;
   my $i = 0;
   while ($i < scalar(@{$scores})) {
      my $topic = $scores->[$i];
      my $n = 0; #feature exists? 0:no, 1:yes
      my $SEGscore = 0;
      if (exists($topic->{$feature})) {
         if (defined($topic->{$feature})) {
            if (exists($topic->{OK})) {
               if ($topic->{OK} == 1) { $SEGscore = $topic->{$feature}; $n = 1; }
            }
            else {
               if (exists($OK->{$feature})) {
                  if (defined($OK->{$feature}->[$i])) {
                     if ($OK->{$feature}->[$i] == 1) { $SEGscore = $topic->{$feature}; $n = 1; }
                  }
                  else { $SEGscore = $topic->{$feature}; $n = 1; } 
               }
               else { $SEGscore = $topic->{$feature}; $n = 1; } 
            }
         }
      }
      $SYSscore += $SEGscore;
      $N+= $n;
      if ($n == 0) {
         if ($mode == 0) { undef($SEGscore); }
         elsif ($mode == 1) { $SEGscore = 1; }
         elsif ($mode == 2) { $SEGscore = 0; }
      }
      push(@Fscores, $SEGscore);

      $i++;
   }

   if ($N == 0) {
      if ($mode == 0) { $SYSscore = 0; }
      elsif ($mode == 1) { $SYSscore = 1; }
      elsif ($mode == 2) { $SYSscore = 0; }
   }
   else { $SYSscore /= $N; } 

   return ($SYSscore, \@Fscores);
}

sub merge_metrics_M {
   #description _ merge metrics 1 and 2 according to the given mode (multiple reference setting)
   #param1 _ metric scores
   #param2 _ metric name 1
   #param3 _ metric name 2
   #param4 _ merging mode  (0: back-off, 1:interpolation A, 2:normalized_interpolation)
   #param5 _ OK parsing structure

   my $scores = shift;
   my $metric1 = shift;
   my $metric2 = shift;
   my $mode = shift;
   my $OK = shift;

   my $avg1 = compute_average_score($scores, $metric1);
   #my $avg2 = compute_average_score($scores, $metric2);

   my @Fscores;
   my $SYSscore = 0; my $N = 0;
   my $i = 0;
   while ($i < scalar(@{$scores})) {
      my $topic = $scores->[$i];
      my $n1 = 0; my $n2 = 0; #feature exists? 0:no, 1:yes
      if (exists($topic->{$metric1})) {
         if (exists($topic->{OK})) { if ($topic->{OK} == 1) { $n1 = 1; } }
         else {
            if (exists($OK->{$metric1})) {
               if (defined($OK->{$metric1}->[$i])) {
                  if ($OK->{$metric1}->[$i]) { $n1 = 1; }
               }
               else { $n1 = 1; } 
            }
            else { $n1 = 1; } 
         }
      }
      if (exists($topic->{$metric2})) { $n2 = 1; }

      my $SEGscore = 0;
      my $x1 = 0;
      if (defined($topic->{$metric1})) { $x1 = $topic->{$metric1}; }
      my $x2 = 0;
      if (defined($topic->{$metric2})) { $x2 = $topic->{$metric2}; }
      if ($n1 and $n2) {
         if ($mode == 0) { $SEGscore = $x1; }
         #elsif ($mode == 1) { $SEGscore = ($x1 + $x2 * $avg1) / 2; }
         elsif ($mode == 1) { $SEGscore = ($x1 + $x2) / 2; }
      }
      elsif ($n1 and !$n2) { $SEGscore = $x1; }
      elsif (!$n1 and $n2) {
         if ($mode == 0) { $SEGscore = $x2 * $avg1; }
         #elsif ($mode == 1) { $SEGscore = ($x2 * $avg1) / 2; }
         elsif ($mode == 1) { $SEGscore = $x2 / 2; }
      }
      else { #!n1 and !n2
         $SEGscore = 0;
      }         

      #if ($n1 or $n2) { $N++; $SYSscore += $SEGscore; }
      if ($n1) { $N++; $SYSscore += $SEGscore; }

      push(@Fscores, $SEGscore);

      $i++;
   }

   my $SYS = Common::safe_division($SYSscore, $N);

   return ($SYS, \@Fscores);
}

sub computeOn($$$) {
   #description _ computes overlap ratio (single reference)
   #param1 _ candidate file
   #param2 _ reference file
   #param3 _ verbosity (0/1)

   my $out = shift;
   my $ref = shift;
   my $verbose = shift;

   my $OUT = new IO::File("< $out") or die "Couldn't open input file: $out\n";
   my $REF = new IO::File("< $ref") or die "Couldn't open input file: $ref\n";

   my $STOP = 0; my $N_numerator = 0; my $N_denominator = 0;
   my @SEG;
   while ((defined (my $o = $OUT->getline())) and (!$STOP)) {
      my $SEGscore = 0;
      if (defined(my $r = $REF->getline())) {
         chomp($o); chomp($r);
         my @lO = split(" ", $o);
         my @lR = split(" ", $r);
         my $n_out = scalar(@lO);
         my $n_ref = scalar(@lR);
         my $numerator = min($n_out, $n_ref);
         my $denominator = max($n_out, $n_ref);
         $SEGscore = Common::safe_division($numerator, $denominator);
         $N_numerator += $numerator;
         $N_denominator += $denominator;
      }
      else { print STDERR "[ERROR] number of lines differs <$out> vs <$ref>\n"; $STOP = 1; }
      push(@SEG, $SEGscore);      
   }
   $OUT->close();
   $REF->close();

   my $SYS = Common::safe_division($N_numerator, $N_denominator);

   return($SYS, \@SEG);
}

sub computeOl($$$) {
   #description _ computes lexical overlap (single reference)
   #param1 _ candidate file
   #param2 _ reference file
   #param3 _ verbosity (0/1)

   my $out = shift;
   my $ref = shift;
   my $verbose = shift;

   my $OUT = new IO::File("< $out") or die "Couldn't open input file: $out\n";
   my $REF = new IO::File("< $ref") or die "Couldn't open input file: $ref\n";

   my $STOP = 0; my $HITS = 0; my $TOTAL = 0;
   my @SEG;
   while ((defined (my $o = $OUT->getline())) and (!$STOP)) {
      my $SEGscore = 0;
      if (defined(my $r = $REF->getline())) {
         chomp($o); chomp($r);
         my @lO = split(" ", $o);
         my %hO; foreach my $w (@lO) { $hO{$w}++; }
         my @lR = split(" ", $r);
         my %hR; foreach my $w (@lR) { $hR{$w}++; }
         my ($hits, $total) = compute_overlap(\%hO, \%hR, 1);
         $SEGscore = Common::safe_division($hits, $total);
         $HITS += $hits;
         $TOTAL += $total;
      }
      else { print STDERR "[ERROR] number of lines differs <$out> vs <$ref>\n"; $STOP = 1; }
      push(@SEG, $SEGscore);      
   }
   $OUT->close();
   $REF->close();

   my $SYS = Common::safe_division($HITS, $TOTAL);

   return($SYS, \@SEG);
}

sub computePl($$$) {
   #description _ computes lexical precision (single reference)
   #param1 _ candidate file
   #param2 _ reference file
   #param3 _ verbosity (0/1)

   my $out = shift;
   my $ref = shift;
   my $verbose = shift;

   my $OUT = new IO::File("< $out") or die "Couldn't open input file: $out\n";
   my $REF = new IO::File("< $ref") or die "Couldn't open input file: $ref\n";

   my $STOP = 0; my $HITS = 0; my $TOTAL = 0;
   my @SEG;
   while ((defined (my $o = $OUT->getline())) and (!$STOP)) {
      my $SEGscore = 0;
      if (defined(my $r = $REF->getline())) {
         chomp($o); chomp($r);
         my @lO = split(" ", $o);
         my %hO; foreach my $w (@lO) { $hO{$w}++; }
         my @lR = split(" ", $r);
         my %hR; foreach my $w (@lR) { $hR{$w}++; }
         my ($hits, $total) = compute_precision(\%hO, \%hR, 1);
         $SEGscore = Common::safe_division($hits, $total);
         $HITS += $hits;
         $TOTAL += $total;
      }
      else { print STDERR "[ERROR] number of lines differs <$out> vs <$ref>\n"; $STOP = 1; }
      push(@SEG, $SEGscore);      
   }
   $OUT->close();
   $REF->close();

   my $SYS = Common::safe_division($HITS, $TOTAL);

   return($SYS, \@SEG);
}

sub computeRl($$$) {
   #description _ computes lexical recall (single reference)
   #param1 _ candidate file
   #param2 _ reference file
   #param3 _ verbosity (0/1)

   my $out = shift;
   my $ref = shift;
   my $verbose = shift;

   my $OUT = new IO::File("< $out") or die "Couldn't open input file: $out\n";
   my $REF = new IO::File("< $ref") or die "Couldn't open input file: $ref\n";

   my $STOP = 0; my $HITS = 0; my $TOTAL = 0;
   my @SEG;
   while ((defined (my $o = $OUT->getline())) and (!$STOP)) {
      my $SEGscore = 0;
      if (defined(my $r = $REF->getline())) {
         chomp($o); chomp($r);
         my @lO = split(" ", $o);
         my %hO; foreach my $w (@lO) { $hO{$w}++; }
         my @lR = split(" ", $r);
         my %hR; foreach my $w (@lR) { $hR{$w}++; }
         my ($hits, $total) = compute_recall(\%hO, \%hR, 1);
         $SEGscore = Common::safe_division($hits, $total);
         $HITS += $hits;
         $TOTAL += $total;
      }
      else { print STDERR "[ERROR] number of lines differs <$out> vs <$ref>\n"; $STOP = 1; }
      push(@SEG, $SEGscore);      
   }
   $OUT->close();
   $REF->close();

   my $SYS = Common::safe_division($HITS, $TOTAL);

   return($SYS, \@SEG);
}

sub computeFl($$$) {
   #description _ computes lexical f-measure 2 * P * R / (P + R) (single reference)
   #param1 _ candidate file
   #param2 _ reference file
   #param3 _ verbosity (0/1)

   my $out = shift;
   my $ref = shift;
   my $verbose = shift;

   my $OUT = new IO::File("< $out") or die "Couldn't open input file: $out\n";
   my $REF = new IO::File("< $ref") or die "Couldn't open input file: $ref\n";

   my $STOP = 0;
   my $PHITS = 0; my $PTOTAL = 0;
   my $RHITS = 0; my $RTOTAL = 0;
   my @SEG;
   while ((defined (my $o = $OUT->getline())) and (!$STOP)) {
      my $SEGscore = 0;
      if (defined(my $r = $REF->getline())) {
         chomp($o); chomp($r);
         my @lO = split(" ", $o);
         my %hO; foreach my $w (@lO) { $hO{$w}++; }
         my @lR = split(" ", $r);
         my %hR; foreach my $w (@lR) { $hR{$w}++; }
         my ($Phits, $Ptotal) = compute_precision(\%hO, \%hR, 1);
         my ($Rhits, $Rtotal) = compute_recall(\%hO, \%hR, 1);
         my $P = Common::safe_division($Phits, $Ptotal);
         my $R = Common::safe_division($Rhits, $Rtotal);
         $SEGscore = Common::f_measure($P, $R, 1);
         $PHITS += $Phits; $PTOTAL += $Ptotal;
         $RHITS += $Rhits; $RTOTAL += $Rtotal;
      }
      else { print STDERR "[ERROR] number of lines differs <$out> vs <$ref>\n"; $STOP = 1; }
      push(@SEG, $SEGscore);      
   }
   $OUT->close();
   $REF->close();

   my $P = Common::safe_division($PHITS, $PTOTAL);
   my $R = Common::safe_division($RHITS, $RTOTAL);
   my $SYS = Common::f_measure($P, $R, 1);

   return($SYS, \@SEG);
}

sub computeMultiOl {
   #description _ computes lexical overlap (multiple reference)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ remake reports? (1 - yes :: 0 - no)
   #param5 _ tools
   #param6 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $remakeREPORTS = shift;
   my $tools = shift;
   my $verbose = shift;


   my @MAXSEGS;
   foreach my $ref (keys %{$Href}) {
      #my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 0);
      my ($SYS, $SEGS) = Overlap::computeOl($out, $Href->{$ref}, $verbose);
      my $i = 0;
      while ($i < scalar(@{$SEGS})) { #update max scores
         if (defined($MAXSEGS[$i])) {
            if ($SEGS->[$i] > $MAXSEGS[$i]) { $MAXSEGS[$i] = $SEGS->[$i]; }
         }
         else { $MAXSEGS[$i] = $SEGS->[$i]; }
         $i++;
      }
   }

   my $MAXSYS = 0; my $N = 0;
   foreach my $seg (@MAXSEGS) {
      $MAXSYS += $seg;
      $N++;
   }

   $MAXSYS = Common::safe_division($MAXSYS, $N);

   return($MAXSYS, \@MAXSEGS);
}

sub computeMultiPl {
   #description _ computes lexical precision (multiple reference)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ remake reports? (1 - yes :: 0 - no)
   #param5 _ tools
   #param6 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $remakeREPORTS = shift;
   my $tools = shift;
   my $verbose = shift;


   my @MAXSEGS;
   foreach my $ref (keys %{$Href}) {
      #my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 0);
      my ($SYS, $SEGS) = Overlap::computePl($out, $Href->{$ref}, $verbose);
      my $i = 0;
      while ($i < scalar(@{$SEGS})) { #update max scores
         if (defined($MAXSEGS[$i])) {
            if ($SEGS->[$i] > $MAXSEGS[$i]) { $MAXSEGS[$i] = $SEGS->[$i]; }
         }
         else { $MAXSEGS[$i] = $SEGS->[$i]; }
         $i++;
      }
   }

   my $MAXSYS = 0; my $N = 0;
   foreach my $seg (@MAXSEGS) {
      $MAXSYS += $seg;
      $N++;
   }

   $MAXSYS = Common::safe_division($MAXSYS, $N);

   return($MAXSYS, \@MAXSEGS);
}

sub computeMultiRl {
   #description _ computes lexical recall (multiple reference)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ remake reports? (1 - yes :: 0 - no)
   #param5 _ tools
   #param6 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $remakeREPORTS = shift;
   my $tools = shift;
   my $verbose = shift;


   my @MAXSEGS;
   foreach my $ref (keys %{$Href}) {
      #my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 0);
      my ($SYS, $SEGS) = Overlap::computeRl($out, $Href->{$ref}, $verbose);
      my $i = 0;
      while ($i < scalar(@{$SEGS})) { #update max scores
         if (defined($MAXSEGS[$i])) {
            if ($SEGS->[$i] > $MAXSEGS[$i]) { $MAXSEGS[$i] = $SEGS->[$i]; }
         }
         else { $MAXSEGS[$i] = $SEGS->[$i]; }
         $i++;
      }
   }

   my $MAXSYS = 0; my $N = 0;
   foreach my $seg (@MAXSEGS) {
      $MAXSYS += $seg;
      $N++;
   }

   $MAXSYS = Common::safe_division($MAXSYS, $N);

   return($MAXSYS, \@MAXSEGS);
}

sub computeMultiFl {
   #description _ computes lexical f-measure 2 * P * R / (P + R) (multiple reference)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ remake reports? (1 - yes :: 0 - no)
   #param5 _ tools
   #param6 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $remakeREPORTS = shift;
   my $tools = shift;
   my $verbose = shift;


   my @MAXSEGS;
   foreach my $ref (keys %{$Href}) {
      #my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 0);
      my ($SYS, $SEGS) = Overlap::computeFl($out, $Href->{$ref}, $verbose);
      my $i = 0;
      while ($i < scalar(@{$SEGS})) { #update max scores
         if (defined($MAXSEGS[$i])) {
            if ($SEGS->[$i] > $MAXSEGS[$i]) { $MAXSEGS[$i] = $SEGS->[$i]; }
         }
         else { $MAXSEGS[$i] = $SEGS->[$i]; }
         $i++;
      }
   }

   my $MAXSYS = 0; my $N = 0;
   foreach my $seg (@MAXSEGS) {
      $MAXSYS += $seg;
      $N++;
   }

   $MAXSYS = Common::safe_division($MAXSYS, $N);

   return($MAXSYS, \@MAXSEGS);
}

sub doMultiOl {
   #description _ computes lexical overlap (multiple references)
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
   my $M = $config->{Hmetrics};                 # set of metrics
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $GO = 0; my $i = 0;
   my @mOl = keys %{$Overlap::rOl};
   while (($i < scalar(@mOl)) and (!$GO)) { if (exists($M->{$mOl[$i]})) { $GO = 1; } $i++; }
	
   if ($GO) {
      if (exists($M->{$Overlap::OlEXT})) {
         if ($verbose == 1) { print STDERR "$Overlap::OlEXT.."; }
         my $reportxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$Overlap::OlEXT.$Common::XMLEXT";
         if ((!(-e $reportxml) and !(-e $reportxml.".$Common::GZEXT")) or $remakeREPORTS) {
            my ($SYS, $SEGS) = Overlap::computeMultiOl($src, $out, $Href, $remakeREPORTS, $tools, $verbose);
            my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$Overlap::OlEXT", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores("$Overlap::OlEXT", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
         }
      }
      if (exists($M->{$Overlap::PlEXT})) {
         if ($verbose == 1) { print STDERR "$Overlap::PlEXT.."; }
         my $reportxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$Overlap::PlEXT.$Common::XMLEXT";
         if ((!(-e $reportxml) and !(-e $reportxml.".$Common::GZEXT")) or $remakeREPORTS) {
            my ($SYS, $SEGS) = Overlap::computeMultiPl($src, $out, $Href, $remakeREPORTS, $tools, $verbose);
            my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$Overlap::PlEXT", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores("$Overlap::PlEXT", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
         }
      }
      if (exists($M->{$Overlap::RlEXT})) {
         if ($verbose == 1) { print STDERR "$Overlap::RlEXT.."; }
         my $reportxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$Overlap::RlEXT.$Common::XMLEXT";
         if ((!(-e $reportxml) and !(-e $reportxml.".$Common::GZEXT")) or $remakeREPORTS) {
            my ($SYS, $SEGS) = Overlap::computeMultiRl($src, $out, $Href, $remakeREPORTS, $tools, $verbose);
            my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$Overlap::RlEXT", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores("$Overlap::RlEXT", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
         }
      }
      if (exists($M->{$Overlap::FlEXT})) {
         if ($verbose == 1) { print STDERR "$Overlap::FlEXT.."; }
         my $reportxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$Overlap::FlEXT.$Common::XMLEXT";
         if ((!(-e $reportxml) and !(-e $reportxml.".$Common::GZEXT")) or $remakeREPORTS) {
            my ($SYS, $SEGS) = Overlap::computeMultiFl($src, $out, $Href, $remakeREPORTS, $tools, $verbose);
            my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$Overlap::FlEXT", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores("$Overlap::FlEXT", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
         }
      }
   }
}

1;
