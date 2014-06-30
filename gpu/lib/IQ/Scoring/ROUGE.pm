package ROUGE;

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
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Metrics;

our ($ROUGEXT, $CFGEXT, $rROUGE, $TROUGE);

$ROUGE::ROUGEXT = "ROUGE";
$ROUGE::TROUGE = "rouge-1.5.5";    # version 1.5.5
$ROUGE::rROUGE = { "$ROUGE::ROUGEXT-1" => 1, "$ROUGE::ROUGEXT-2" => 1, "$ROUGE::ROUGEXT-3" => 1, "$ROUGE::ROUGEXT-4" => 1,
	           "$ROUGE::ROUGEXT-L" => 1, "$ROUGE::ROUGEXT-S*" => 1, "$ROUGE::ROUGEXT-SU*" => 1, "$ROUGE::ROUGEXT-W" => 1 };
$ROUGE::CFGEXT = "config";


sub metric_set {
    #description _ returns the set of available metrics
    #@return _ metric set structure (hash ref)

    return $ROUGE::rROUGE;
}

sub read_rouge {
   #description _ read ROUGE value from report file (for all segments)
   #param1  _ report filename
   #@return _ ROUGE score list

   my $report = shift;

   my %Hrouge;
   my @lrouge;

   open(AUX, "< $report") or die "couldn't open file: $report\n";
   while (my $aux = <AUX>) {
      if ($aux =~ /^X ROUGE-[SLW1-4][^ ]* Average_F.*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         $Hrouge{$laux[1]} = $laux[3];
      }
   }
   close(AUX);

   foreach my $s (sort keys %Hrouge) { push(@lrouge, $Hrouge{$s}); }

   return \@lrouge;
}

sub read_rouge_segments {
   #description _ read ROUGE value from report file (for all segments)
   #param1  _ report filename
   #@return _ ROUGE score list

   my $report = shift;

   my @lrouge1;
   my @lrouge2;
   my @lrouge3;
   my @lrouge4;
   my @lrougeL;
   my @lrougeS;
   my @lrougeSU;
   my @lrougeW;

   open(AUX, "< $report") or die "couldn't open file: $report\n";
   while (my $aux = <AUX>) {
      if ($aux =~ /^X ROUGE-[SLW1-4][^ ]* Eval.*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         my @ll = split(/\./, $laux[3]);
         my @llF = split(":", $laux[6]);
         if ($laux[1] eq "ROUGE-1") { push(@lrouge1, $llF[1]); }
         if ($laux[1] eq "ROUGE-2") { push(@lrouge2, $llF[1]); }
         if ($laux[1] eq "ROUGE-3") { push(@lrouge3, $llF[1]); }
         if ($laux[1] eq "ROUGE-4") { push(@lrouge4, $llF[1]); }
         if ($laux[1] eq "ROUGE-L") { push(@lrougeL, $llF[1]); }
         if ($laux[1] eq "ROUGE-S*") { push(@lrougeS, $llF[1]); }
         if ($laux[1] eq "ROUGE-SU*") { push(@lrougeSU, $llF[1]); }
         if ($laux[1] eq "ROUGE-W-1.2") { push(@lrougeW, $llF[1]); }
      }
   }
   close(AUX);

   my @lSEG = (\@lrouge1, \@lrouge2, \@lrouge3, \@lrouge4, \@lrougeL, \@lrougeS, \@lrougeSU, \@lrougeW);

   return \@lSEG;
}

sub computeMultiROUGE {
   #description _ computes ROUGE scores -> n = 1..4, LCS, S*, SU*, W-1.2 (multiple references)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ remake reports? (1 - yes :: 0 - no)
   #param5 _ TARGET NAME (base filename)
   #param6 _ REF NAME (base filename)
   #param7 _ tools
   #param8 _ stemming? (0/1)
   #param9 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $remakeREPORTS = shift;
   my $TGT = shift;
   my $REFname = shift;
   my $tools = shift;
   my $stem = shift;
   my $verbose = shift;

   my $toolROUGE = "$tools/$ROUGE::TROUGE/ROUGE-1.5.5.pl -e $tools/$ROUGE::TROUGE/data -z SPL -2 -1 -U -r 1000 -n 4 -w 1.2 -c 95 -d".($stem? " -m":"");

   my $reportROUGE = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$ROUGEXT.$Common::REPORTEXT";
   my $configROUGE = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$ROUGEXT.$ROUGE::CFGEXT";

   open(OUT, "< $out") or die "couldn't open file: $out\n";
   open(CFG, "> $configROUGE") or die "couldn't open file: $configROUGE\n";
   if ($verbose > 1) { print STDERR "generating files for ROUGE"; }
   my %hRAND;
   foreach my $r (keys %{$Href}) {
      my $ref = $Href->{$r};
      open(REF, "< $ref") or die "couldn't open file: $ref\n";
      my $j = 1;
      my $random = rand($Common::NRAND);
      $hRAND{$r} = $random;
      while (my $auxREF = <REF>) {
         chomp($auxREF);
         my $ref_j = "$Common::DATA_PATH/$Common::TMP/$ROUGEXT.$random.$Common::REFEXT.$j";
         if (!(-e $ref_j) or $remakeREPORTS) {
            open(REFj, "> $ref_j") or die "couldn't open file: $ref_j\n";
            $auxREF =~ s/^ +//g; $auxREF =~ s/ +$//g;
            if (($auxREF eq "") or ($auxREF =~ /^[\?\!\.]$/)){ $auxREF = $Common::EMPTY_ITEM; }
            print REFj $auxREF, "\n";
            close(REFj);
         }
         $j++;
      }
      close(REF);
   }
   my $i = 1;
   my $random = rand($Common::NRAND);
   while (my $auxOUT = <OUT>) {
      chomp($auxOUT);
      my @cfgline;
      my $out_i = "$Common::DATA_PATH/$Common::TMP/$ROUGEXT.$random.$Common::SYSEXT.$i";
      foreach my $r (keys %{$Href}) {
         my $ref_i = "$Common::DATA_PATH/$Common::TMP/$ROUGEXT.".$hRAND{$r}.".$Common::REFEXT.$i";
         push(@cfgline, $ref_i);
      }
      if (!(-e $out_i) or $remakeREPORTS) {
         open(OUTi, "> $out_i") or die "couldn't open file: $out_i\n";
         $auxOUT =~ s/^ +//g; $auxOUT =~ s/ +$//g;
         if (($auxOUT eq "") or ($auxOUT =~ /^[\?\!\.]$/)) { $auxOUT = $Common::EMPTY_ITEM; }
         print OUTi $auxOUT, "\n";
         close(OUTi);
      }
      if ($verbose > 1) { 
         if ($i % 10 == 0) { print STDERR "."; }
         if ($i % 100 == 0) { print STDERR "$i"; }
      }
      $i++;
      print CFG "$out_i ", join(" ", @cfgline), "\n";
   }
   if ($verbose > 1) { print STDERR "..", $i-1, " segments [DONE]\n"; }
   close(CFG);
   close(OUT);

   if ($verbose > 1) { print STDERR "building $reportROUGE...\n"; }
   #print "$toolROUGE $configROUGE > $reportROUGE";
   Common::execute_or_die("$toolROUGE $configROUGE > $reportROUGE", "[ERROR] problems running ROUGE...");
   system("rm -f $configROUGE");
   my $j = 1;
   while ($j < $i) { if (-e "$Common::DATA_PATH/$Common::TMP/$ROUGEXT.$random.$Common::SYSEXT.$j") { system("rm -f $Common::DATA_PATH/$Common::TMP/$ROUGEXT.$random.$Common::SYSEXT.$j"); } $j++; }
   foreach my $r (keys %{$Href}) {
      my $ref = $Href->{$r};
      $j = 1;
      while ($j < $i) { if (-e "$Common::DATA_PATH/$Common::TMP/$ROUGEXT.".$hRAND{$r}.".$Common::REFEXT.$j") { system("rm -f $Common::DATA_PATH/$Common::TMP/$ROUGEXT.".$hRAND{$r}.".$Common::REFEXT.$j"); } $j++; }
   }
   my $SYS = read_rouge($reportROUGE);
   my $SEG = read_rouge_segments($reportROUGE);
   system("rm -f $reportROUGE");

   return ($SYS, $SEG);
}

sub doMultiROUGE {
   #description _ computes ROUGE scores -> n = 1..4, LCS, S*, SU*, W-1.2 (multiple references)
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param6  _ do stemming? (1: enabled  0: disabled)
   #param7  _ optional prefix
   #param8  _ hash of scores

   my $config = shift;
   my $TGT = shift;
   my $out = shift;
   my $REF = shift;
   my $Href = shift;
   my $stemming = shift;
   my $prefix = shift;
	my $hOQ = shift;
	
   my $src = $config->{src};                    # source file 
   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $M = $config->{Hmetrics};                 # set of metrics
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $GO = 0; my $i = 0;
   my @mROUGE = keys %{$ROUGE::rROUGE};
   while (($i < scalar(@mROUGE)) and (!$GO)) { if (exists($M->{$prefix.$mROUGE[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "ROUGE.."; }
      my $reportROUGE1xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$ROUGEXT-1.$Common::XMLEXT";
      my $reportROUGE2xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$ROUGEXT-2.$Common::XMLEXT";
      my $reportROUGE3xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$ROUGEXT-3.$Common::XMLEXT";
      my $reportROUGE4xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$ROUGEXT-4.$Common::XMLEXT";
      my $reportROUGELxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$ROUGEXT-L.$Common::XMLEXT";
      my $reportROUGESxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$ROUGEXT-S*.$Common::XMLEXT";
      my $reportROUGESUxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$ROUGEXT-SU*.$Common::XMLEXT";
      my $reportROUGEWxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$ROUGEXT-W.$Common::XMLEXT";

      if ((!(-e $reportROUGE1xml) and !(-e $reportROUGE1xml.".$Common::GZEXT")) or (!(-e $reportROUGE2xml) and !(-e $reportROUGE2xml.".$Common::GZEXT")) or (!(-e $reportROUGE3xml) and !(-e $reportROUGE3xml.".$Common::GZEXT")) or (!(-e $reportROUGE4xml) and !(-e $reportROUGE4xml.".$Common::GZEXT")) or (!(-e $reportROUGELxml) and !(-e $reportROUGELxml.".$Common::GZEXT")) or (!(-e $reportROUGESxml) and !(-e $reportROUGESxml.".$Common::GZEXT")) or (!(-e $reportROUGESUxml) and !(-e $reportROUGESUxml.".$Common::GZEXT")) or (!(-e $reportROUGEWxml) and !(-e $reportROUGEWxml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($SYS, $SEGS) = ROUGE::computeMultiROUGE($src, $out, $Href, $remakeREPORTS, $TGT, $REF, $tools, $stemming, $verbose);
         my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[0], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$ROUGEXT-1", $SYS->[0], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$ROUGEXT-1", $TGT, $REF, $SYS->[0], $doc_scores, $seg_scores,$hOQ);

         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[1], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$ROUGEXT-2", $SYS->[1], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$ROUGEXT-2", $TGT, $REF, $SYS->[1], $doc_scores, $seg_scores,$hOQ);

         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[2], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$ROUGEXT-3", $SYS->[2], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$ROUGEXT-3", $TGT, $REF, $SYS->[2], $doc_scores, $seg_scores,$hOQ);

         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[3], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$ROUGEXT-4", $SYS->[3], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$ROUGEXT-4", $TGT, $REF, $SYS->[3], $doc_scores, $seg_scores,$hOQ);

         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[4], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$ROUGEXT-L", $SYS->[4], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$ROUGEXT-L", $TGT, $REF, $SYS->[4], $doc_scores, $seg_scores,$hOQ);

         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[5], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$ROUGEXT-S*", $SYS->[5], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$ROUGEXT-S*", $TGT, $REF, $SYS->[5], $doc_scores, $seg_scores,$hOQ);

         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[6], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$ROUGEXT-SU*", $SYS->[6], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$ROUGEXT-SU*", $TGT, $REF, $SYS->[6], $doc_scores, $seg_scores,$hOQ);

         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[7], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$ROUGEXT-W", $SYS->[7], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$ROUGEXT-W", $TGT, $REF, $SYS->[7], $doc_scores, $seg_scores,$hOQ);
      }
   }
}

1;
