package BLEUNIST;

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
use IO::File;
use Data::Dumper;
use IQ::InOut::IQXML;
use IQ::InOut::NISTSCR;
use IQ::Common;

our ($BLEUEXT, $NISTEXT, $rBLEUNIST, $TBLEUNIST);

#$BLEUNIST::BLEUEXT = "BLEUs";
$BLEUNIST::BLEUEXT = "BLEU";
$BLEUNIST::NISTEXT = "NIST";
$BLEUNIST::TBLEUNIST = "mteval-kit";  # v13a
$BLEUNIST::rBLEUNIST = { "$BLEUNIST::BLEUEXT" => 1, "$BLEUNIST::NISTEXT" => 1};
$BLEUNIST::rBLEU = { "$BLEUNIST::BLEUEXT" => 1 };
$BLEUNIST::rNIST = { "$BLEUNIST::NISTEXT" => 1};


sub metric_set {
    #description _ returns the set of available metrics
    #@return _ metric set structure (hash ref)

    return $BLEUNIST::rBLEUNIST;
}

sub read_scores ($;$) {
   #description _ read system, document and segment scores (from the corresponding Metrics_MaTR-like format files)
   #param1  _ metric name
   #param2  _ optional. the idx structure for the related basename-system
   #@return _ (sys_score, doc_scores, seg_scores)

   my $basename = shift;
   my $bIDX = shift;

   my $sys_scores = read_scores_G($basename, $Common::G_SYS, $bIDX);
   my $doc_scores = read_scores_G($basename, $Common::G_DOC, $bIDX);
   my $seg_scores = read_scores_G($basename, $Common::G_SEG, $bIDX );

   return ($sys_scores->[0], $doc_scores, $seg_scores);
}

sub read_scores_G ($$;$) {
   #description _ reads MetricsMaTr format scr file for a given metric and a given granularity
   #param1  _ metric name
   #param2  _ granularity
   #param3  _ optional. the idx structure for the related basename-system
   #@return _ scores

   my $basename = shift;
   my $G = shift;
   my $bIDX = shift;
   
   my $file = "$basename-$G.scr";

   #read_scr_file
   my $hscores = NISTSCR::read_scr_file($file, $G, 0);

   #delete scr file
   system("rm -f $file");

   my $arscores = Common::reorder_scores( $hscores, $bIDX, $G );

   return $arscores;
}

sub computeMultiBLEUNIST {
   #description _ computes smoothed BLEU-4 score and NIST-5 score (by calling NIST mteval script) (multiple references)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ target name
   #param5 _ idx structure
   #param6 _ remake reports? (1 - yes :: 0 - no)
   #param7 _ target case? (cs/ci)
   #param8 _ tools
   #param9 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $TGT = shift;
   my $IDX = shift;
   my $remakeREPORTS = shift;
   my $case = shift;
   my $tools = shift;
   my $verbose = shift;

   my $toolBLEUNIST = "perl $tools/$BLEUNIST::TBLEUNIST/mteval-v13a.pl --metricsMATR -d 2 "; # version v13a
   if ( $case eq $Common::CASE_CS ) { $toolBLEUNIST .= "-c "; }

   my $R = rand($Common::NRAND);
   my $srcXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::SRCEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $srcXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_doc($src, $srcXML, $TGT, $IDX, 0, $Common::CASE_CS, $verbose); }
   my $outXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::SYSEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $outXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_doc($out, $outXML, $TGT, $IDX, 1, $Common::CASE_CS, $verbose); }
   my $refXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::REFEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $refXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_multidoc($Href, $refXML, $IDX, 2, $Common::CASE_CS, $verbose); }

   #print STDERR "cd $Common::DATA_PATH; $toolBLEUNIST -s $srcXML -t $outXML -r $refXML \n";
   Common::execute_or_die("cd $Common::DATA_PATH; $toolBLEUNIST -s $srcXML -t $outXML -r $refXML >/dev/null 2>/dev/null", "[ERROR] problems running BLEU_NIST...");   

   if (-e $refXML) { system "rm -f $refXML"; }
   if (-e $srcXML) { system "rm -f $srcXML"; }
   if (-e $outXML) { system "rm -f $outXML"; }

   my ($BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores) = read_scores($Common::DATA_PATH."/BLEU", $IDX->{$TGT});
   my ($NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores) = read_scores($Common::DATA_PATH."/NIST", $IDX->{$TGT});
   return($BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores, $NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores);
}

sub computeMultiBLEU {
   #description _ computes smoothed BLEU-4 score (by calling NIST mteval script) (multiple references)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ target name
   #param5 _ idx structure
   #param6 _ remake reports? (1 - yes :: 0 - no)
   #param7 _ target case (cs/ci)
   #param8 _ tools
   #param9 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $TGT = shift;
   my $IDX = shift;
   my $remakeREPORTS = shift;
   my $case = shift;
   my $tools = shift;
   my $verbose = shift;

   my $toolBLEU = "perl $tools/$BLEUNIST::TBLEUNIST/mteval-v13a.pl -b --metricsMATR -d 2 ";
   if ( $case eq $Common::CASE_CS ) { $toolBLEU .= "-c "; }
   
   my $R = rand($Common::NRAND);
   my $srcXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::SRCEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $srcXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_doc($src, $srcXML, $TGT, $IDX, 0, $Common::CASE_CS, $verbose); }
   my $outXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::SYSEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $outXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_doc($out, $outXML, $TGT, $IDX, 1, $Common::CASE_CS, $verbose); }
   my $refXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::REFEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $refXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_multidoc($Href, $refXML, $IDX, 2, $Common::CASE_CS, $verbose); }

   Common::execute_or_die("$toolBLEU -s $srcXML -t $outXML -r $refXML >/dev/null 2>/dev/null", "[ERROR] problems running BLEU...");   

   if (-e $refXML) { system "rm -f $refXML"; }
   if (-e $srcXML) { system "rm -f $srcXML"; }
   if (-e $outXML) { system "rm -f $outXML"; }
   my ($BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores) = read_scores($Common::DATA_PATH."/BLEU", $IDX->{$TGT});

   return($BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores);
}

sub computeMultiNIST {
   #description _ computes NIST-5 score (by calling NIST mteval script) (multiple references)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ target name
   #param5 _ idx structure
   #param6 _ remake reports? (1 - yes :: 0 - no)
   #param7 _ target case (cs/ci)
   #param8 _ tools
   #param9 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $TGT = shift;
   my $IDX = shift;
   my $remakeREPORTS = shift;
   my $case = shift;
   my $tools = shift;
   my $verbose = shift;

   my $toolNIST = "perl $tools/$BLEUNIST::TBLEUNIST/mteval-v13a.pl -d 2 -n --metricsMATR ";
   if ( $case eq $Common::CASE_CS ) { $toolNIST .= "-c "; }
   
   my $R = rand($Common::NRAND);
   my $srcXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::SRCEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $srcXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_doc($src, $srcXML, $TGT, $IDX, 0, $Common::CASE_CS, $verbose); }
   my $outXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::SYSEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $outXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_doc($out, $outXML, $TGT, $IDX, 1, $Common::CASE_CS, $verbose); }
   my $refXML = "$Common::DATA_PATH/$Common::TMP/$R.$Common::REFEXT.$NISTEXT.$Common::XMLEXT";
   if ((!(-e $refXML)) or $remakeREPORTS) { NISTXML::f_create_mteval_multidoc($Href, $refXML, $IDX, 2, $Common::CASE_CS, $verbose); }

   #print "cd $Common::DATA_PATH; $toolNIST -s $srcXML -t $outXML -r $refXML \n";
   Common::execute_or_die("cd $Common::DATA_PATH; $toolNIST -s $srcXML -t $outXML -r $refXML >/dev/null 2>/dev/null", "[ERROR] problems running NIST...");   
   if (-e $refXML) { system "rm -f $refXML"; }
   if (-e $srcXML) { system "rm -f $srcXML"; }
   if (-e $outXML) { system "rm -f $outXML"; }

   my ($NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores) = read_scores($Common::DATA_PATH."/NIST", $IDX->{$TGT});

   return($NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores);
}

sub doMultiBLEUNIST {
   #description _ computes smoothed BLEU-4 score and NIST-5 score (multiple references)
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
   my @mBLEUNIST = keys %{$BLEUNIST::rBLEUNIST};
   while (($i < scalar(@mBLEUNIST)) and (!$GO)) { if (exists($M->{$prefix.$mBLEUNIST[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$BLEUNIST::BLEUEXT..$BLEUNIST::NISTEXT.."; }
      my $reportBLEUxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXT.$Common::XMLEXT";
      my $reportNISTxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXT.$Common::XMLEXT";
      if ((!(-e $reportBLEUxml) and !(-e $reportBLEUxml.".$Common::GZEXT")) or (!(-e $reportNISTxml) and !(-e $reportNISTxml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores, $NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores) = 
            BLEUNIST::computeMultiBLEUNIST( $src, $out, $Href, $TGT, $config->{IDX}, $remakeREPORTS, $config->{CASE}, $tools, $verbose);
            
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$BLEUEXT", $BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$BLEUEXT", $TGT, $REF, $BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores,$hOQ);
         
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXT", $NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("$prefix$NISTEXT", $TGT, $REF, $NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores,$hOQ);
      }
   }

}

sub doMultiBLEU {
   #description _ computes smoothed BLEU-4 score (multiple references)
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param6  _ optional prefix

   my $config = shift;
   my $TGT = shift;
   my $out = shift;
   my $REF = shift;
   my $Href = shift;
   my $prefix = shift;

   my $src = $config->{src};                    # source file 
   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $M = $config->{Hmetrics};                 # set of metrics
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $GO = 0; my $i = 0;
   my @mBLEU = keys %{$BLEUNIST::rBLEU};
   while (($i < scalar(@mBLEU)) and (!$GO)) { if (exists($M->{$prefix.$mBLEU[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$BLEUNIST::BLEUEXT.."; }
      my $reportBLEUxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$BLEUEXT.$Common::XMLEXT";
      if ((!(-e $reportBLEUxml) and !(-e $reportBLEUxml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores) = 
            BLEUNIST::computeMultiBLEU($src, $out, $Href, $TGT, $config->{IDX}, $remakeREPORTS, $config->{CASE}, $tools, $verbose);
         IQXML::write_report($TGT, $REF, "$prefix$BLEUEXT", $BLEU_sys_score, $BLEU_doc_scores, $BLEU_seg_scores, $config->{IDX}->{$TGT}, $verbose);
      }
   }
}

sub doMultiNIST {
   #description _ computes NIST-5 score (multiple references)
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param6  _ optional prefix

   my $config = shift;
   my $TGT = shift;
   my $out = shift;
   my $REF = shift;
   my $Href = shift;
   my $prefix = shift;

   my $src = $config->{src};                    # source file 
   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $M = $config->{Hmetrics};                 # set of metrics
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $GO = 0; my $i = 0;
   my @mNIST = keys %{$BLEUNIST::rNIST};

   while (($i < scalar(@mNIST)) and (!$GO)) { if (exists($M->{$prefix.$mNIST[$i]})) { $GO = 1; } $i++; }

   if ($GO) {   	
      if ($verbose == 1) { print STDERR "$BLEUNIST::NISTEXT.."; }
      my $reportNISTxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXT.$Common::XMLEXT";
      if ((!(-e $reportNISTxml) and !(-e $reportNISTxml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores) = 
            BLEUNIST::computeMultiNIST($src, $out, $Href, $TGT, $config->{IDX}, $remakeREPORTS, $config->{CASE}, $tools, $verbose);
            IQXML::write_report($TGT, $REF, "$prefix$NISTEXT", $NIST_sys_score, $NIST_doc_scores, $NIST_seg_scores, $config->{IDX}->{$TGT}, $verbose);
      }
   }
}

1;
