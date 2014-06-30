package BLEU;

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
use File::ReadBackwards;
#use Data::Dumper;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Metrics;

our($BLEUEXT, $BLEUEXTi, $rBLEU, $TBLEU);

$BLEU::BLEUEXT = "BLEU";
$BLEU::BLEUEXTi = "BLEUi";
$BLEU::TBLEU = "mteval-kit";
$BLEU::rBLEU = { "$BLEU::BLEUEXT-1" => 1, "$BLEU::BLEUEXT-2" => 1, "$BLEU::BLEUEXT-3" => 1,
	         "$BLEU::BLEUEXT-4" => 1, "$BLEU::BLEUEXTi-2" => 1, "$BLEU::BLEUEXTi-3" => 1,
	         "$BLEU::BLEUEXTi-4" => 1};


sub metric_set {
    #description _ returns the set of available metrics
    #@return _ metric set structure (hash ref)
    return $BLEU::rBLEU;
}

sub read_bleu {
   #description _ read BLEU value from report file
   #param1  _ report filename
   #@return _ BLEU score list (n = 1..9)

   my $report = shift;

   my $REPORT = File::ReadBackwards->new($report) or die "Couldn't open input file: $report\n";
   my $line = $REPORT->readline;
   while (!($line =~ /^ +BLEU:.*/)) { $line = $REPORT->readline; }
   chomp($line); $line =~ s/^ +BLEU: +//; $line =~ s/ +/ /g;
   my @lbleu = split(" ", $line); pop(@lbleu);
   while (!($line =~ /^ +BLEU:.*/)) { $line = $REPORT->readline; }
   chomp($line); $line =~ s/^ +BLEU: +//; $line =~ s/ +/ /g;
   my @lbleui = split(" ", $line); pop(@lbleui);

   $REPORT->close();
 
   my @l = ($lbleu[0], $lbleu[1], $lbleu[2], $lbleu[3], $lbleui[0], $lbleui[1], $lbleui[2], $lbleui[3]);

   return (\@l);
}

sub read_bleu_segments {
   #description _ read BLEU-4 value from report file (for all segments)
   #param1  _ report filename
   #@return _ bleu score list

   my $report = shift;

   my @lbleu1;   my @lbleu2;   my @lbleu3;   my @lbleu4;
   my @lbleu1i;  my @lbleu2i;  my @lbleu3i;  my @lbleu4i;

   open(AUX, "< $report") or die "couldn't open file: $report\n";

   while (my $aux = <AUX>) {
      if ($aux =~ /^ +BLEU score using.*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         my @lN;
         push(@lbleu1, $laux[6]);
         push(@lbleu2, $laux[7]);
         push(@lbleu3, $laux[8]);
         push(@lbleu4, $laux[9]);
      }
      elsif ($aux =~ /^ +cumulative-BLEU score using.*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         my @lN;
         push(@lbleu1, $laux[6]);
         push(@lbleu2, $laux[7]);
         push(@lbleu3, $laux[8]);
         push(@lbleu4, $laux[9]);
      }
      elsif ($aux =~ /^ +individual-BLEU score using.*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         my @lN;
         push(@lbleu1i, $laux[6]);
         push(@lbleu2i, $laux[7]);
         push(@lbleu3i, $laux[8]);
         push(@lbleu4i, $laux[9]);
      }
   }
   close(AUX);
   my @SEG = (\@lbleu1, \@lbleu2, \@lbleu3, \@lbleu4, \@lbleu1i, \@lbleu2i, \@lbleu3i, \@lbleu4i);

   return \@SEG;
}

sub computeMultiBLEU {
   #description _ computes BLEU score (by calling NIST mteval script) -> n = 1..4 (multiple references)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ remake reports? (1 - yes :: 0 - no)
   #param5 _ target case (cs/ci)
   #param6 _ tools
   #param7 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $remakeREPORTS = shift;
   my $case = shift;
   my $tools = shift;
   my $verbose = shift;

   my $toolBLEU = "perl $tools/$BLEU::TBLEU/mteval-v13a.pl -b -d 2 "; 
   if ( $case eq $Common::CASE_CS ) { $toolBLEU .= "-c "; }

   my $refBLEUsgml = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$Common::REFEXT.$BLEUEXT.$Common::SGMLEXT";
   if ((!(-e $refBLEUsgml)) or $remakeREPORTS) { NISTXML::SGML_f_create_mteval_multidoc($Href, $refBLEUsgml, 2, $verbose); }
   my $srcBLEUsgml = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$Common::SRCEXT.$BLEUEXT.$Common::SGMLEXT";
   if ((!(-e $srcBLEUsgml)) or $remakeREPORTS) { NISTXML::SGML_f_create_mteval_doc($src, $srcBLEUsgml, 0, $verbose); }
   my $outBLEUsgml = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$Common::SYSEXT.$BLEUEXT.$Common::SGMLEXT";
   if ((!(-e $outBLEUsgml)) or $remakeREPORTS) { NISTXML::SGML_f_create_mteval_doc($out, $outBLEUsgml, 1, $verbose); }
   my $reportBLEU = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$BLEUEXT.$Common::REPORTEXT";
   if ($verbose > 1) { print STDERR "building $reportBLEU...\n"; }

   Common::execute_or_die("$toolBLEU -s $srcBLEUsgml -t $outBLEUsgml -r $refBLEUsgml > $reportBLEU", "[ERROR] problems running BLEU...");
   if (-e $srcBLEUsgml) { system "rm -f $srcBLEUsgml"; }
   if (-e $refBLEUsgml) { system "rm -f $refBLEUsgml"; }
   if (-e $outBLEUsgml) { system "rm -f $outBLEUsgml"; }
   my $SYS = read_bleu($reportBLEU);
   my $SEG = read_bleu_segments($reportBLEU);
   system("rm -f $reportBLEU");

   return($SYS, $SEG);
}

sub doMultiBLEU {
   #description _ computes BLEU score (by calling NIST mteval script) -> n = 1..4 (multiple references)
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param6  _ optional prefix
   #param7  _ hash of scores

   my $config = shift;
   my $TGT = shift;
   my $out = shift;
   my $REF = shift;
   my $Href = shift;
   my $prefix = shift;
	my $hOQ = shift;
	
   my $src = $config->{src};                    # source file 
   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $M = $config->{Hmetrics};                 # set of metrics
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $GO = 0; my $i = 0;
   my @mBLEU = keys %{$BLEU::rBLEU};
   while (($i < scalar(@mBLEU)) and (!$GO)) { if (exists($M->{$prefix.$mBLEU[$i]})) { $GO = 1; } $i++; }
   if ($GO) {
      if ($verbose == 1) { print STDERR "$BLEU::BLEUEXT.."; }
	
      my $reportBLEU1xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXT-1.$Common::XMLEXT";
      my $reportBLEU2xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXT-2.$Common::XMLEXT";
      my $reportBLEU3xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXT-3.$Common::XMLEXT";
      my $reportBLEU4xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXT-4.$Common::XMLEXT";
      my $reportBLEU2ixml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXTi-2.$Common::XMLEXT";
      my $reportBLEU3ixml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXTi-3.$Common::XMLEXT";
      my $reportBLEU4ixml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXTi-4.$Common::XMLEXT";

      if ((!(-e $reportBLEU1xml) and !(-e $reportBLEU1xml.".$Common::GZEXT")) or
          (!(-e $reportBLEU2xml) and !(-e $reportBLEU2xml.".$Common::GZEXT")) or
          (!(-e $reportBLEU3xml) and !(-e $reportBLEU3xml.".$Common::GZEXT")) or
          (!(-e $reportBLEU4xml) and !(-e $reportBLEU4xml.".$Common::GZEXT")) or
          (!(-e $reportBLEU2ixml) and !(-e $reportBLEU2ixml.".$Common::GZEXT")) or
          (!(-e $reportBLEU3ixml) and !(-e $reportBLEU3ixml.".$Common::GZEXT")) or
          (!(-e $reportBLEU4ixml) and !(-e $reportBLEU4ixml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($SYS, $SEGS) = BLEU::computeMultiBLEU($src, $out, $Href, $remakeREPORTS, $config->{CASE}, $tools, $verbose);
         my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[0], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$BLEUEXT-1", $SYS->[0], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$BLEUEXT-1", $TGT, $REF, $SYS->[0], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[1], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$BLEUEXT-2", $SYS->[1], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$BLEUEXT-2", $TGT, $REF, $SYS->[1], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[2], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$BLEUEXT-3", $SYS->[2], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$BLEUEXT-3", $TGT, $REF, $SYS->[2], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[3], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$BLEUEXT-4", $SYS->[3], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$BLEUEXT-4", $TGT, $REF, $SYS->[3], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[5], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$BLEUEXTi-2", $SYS->[5], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$BLEUEXTi-2", $TGT, $REF, $SYS->[5], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[6], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$BLEUEXTi-3", $SYS->[6], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$BLEUEXTi-3", $TGT, $REF, $SYS->[6], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[7], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$BLEUEXTi-4", $SYS->[7], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$BLEUEXTi-4", $TGT, $REF, $SYS->[7], $doc_scores, $seg_scores,$hOQ);
      }
   }
}

1;
