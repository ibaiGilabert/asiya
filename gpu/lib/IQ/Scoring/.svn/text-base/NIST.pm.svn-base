package NIST;

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
# Notes on the nist calculation:

# http://www.itl.nist.gov/iad/mig//tests/mt/doc/ngram-study.pdf

# The NIST score is similar to BLEU but:
# - It calculates arithmetic mean instead of geometric mean
# - It weights every N-gram according to the frequency on the references. As a result, less frequen n-grams (more informative ones) are heavily weighted in front of more frequent ones
#
# ------------------------------------------------------------------------

use Modern::Perl;
use File::ReadBackwards;
#use Data::Dumper;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Metrics;

our ($NISTEXT, $NISTEXTi, $rNIST, $TNIST);

$NIST::NISTEXT = "NIST";
$NIST::NISTEXTi = "NISTi";
$NIST::TNIST = "mteval-kit";
$NIST::rNIST = { "$NIST::NISTEXT-1" => 1, "$NIST::NISTEXT-2" => 1, "$NIST::NISTEXT-3" => 1,
                 "$NIST::NISTEXT-4" => 1, "$NIST::NISTEXT-5" => 1, "$NIST::NISTEXTi-2" => 1,
                 "$NIST::NISTEXTi-3" => 1, "$NIST::NISTEXTi-4" => 1, "$NIST::NISTEXTi-5" => 1 };

sub metric_set {
    #description _ returns the set of available metrics
    #@return _ metric set structure (hash ref)

    return $NIST::rNIST;
}

sub read_nist {
   #description _ read NIST value from report file
   #param1  _ report filename
   #@return _ NIST score list (n = 1..9)

   my $report = shift;

   my $REPORT = File::ReadBackwards->new($report) or die "Couldn't open input file: $report\n";

   my $line = $REPORT->readline;
   while (!$REPORT->eof && !($line =~ /^ +NIST:.*/)) { $line = $REPORT->readline; }
   defined( $line ) or die "readline failed reading $report: $!";
   chomp($line);   
   if ( $line =~ m/^ +NIST: +/ ){ $line =~ s/^ +NIST: +//; $line =~ s/ +/ /g; }
   else{ die "NIST results unavailable in file $report!"; }
   my @lnist = split(" ", $line);   pop(@lnist);

   while (!$REPORT->eof && !($line =~ /^ +NIST:.*/)) { $line = $REPORT->readline; }
   defined( $line ) or die "readline failed reading $report: $!";
   chomp($line);   
   if ( $line =~ m/^ +NIST: +/ ) { $line =~ s/^ +NIST: +//; $line =~ s/ +/ /g; }
   else{ die "NIST results unavailable in file $report!"; }
   my @lnisti = split(" ", $line);   pop(@lnisti);

   $REPORT->close();

   my @l = ($lnist[0], $lnist[1], $lnist[2], $lnist[3], $lnist[4], $lnisti[0], $lnisti[1], $lnisti[2], $lnisti[3], $lnisti[4]);

   return (\@l);
}

sub read_nist_segments {
   #description _ read NIST-5 value from report file (for all segments)
   #param1  _ report filename
   #@return _ NIST score list

   my $report = shift;

   my @lnist1;   my @lnist2;   my @lnist3;   my @lnist4;   my @lnist5;
   my @lnist1i;  my @lnist2i;  my @lnist3i;  my @lnist4i;  my @lnist5i;

   open(AUX, "< $report") or die "couldn't open file: $report\n";
   while (my $aux = <AUX>) {
      if ($aux =~ /^ +NIST score using.*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         push(@lnist1, $laux[6]);
         push(@lnist2, $laux[7]);
         push(@lnist3, $laux[8]);
         push(@lnist4, $laux[9]);
         push(@lnist5, $laux[10]);
      }
      elsif ($aux =~ /^ +cumulative-NIST score using.*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         push(@lnist1, $laux[6]);
         push(@lnist2, $laux[7]);
         push(@lnist3, $laux[8]);
         push(@lnist4, $laux[9]);
         push(@lnist5, $laux[10]);
      }
      elsif ($aux =~ /^ +individual-NIST score using.*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         push(@lnist1i, $laux[6]);
         push(@lnist2i, $laux[7]);
         push(@lnist3i, $laux[8]);
         push(@lnist4i, $laux[9]);
         push(@lnist5i, $laux[10]);
      }
   }
   close(AUX);
   my @SEG = (\@lnist1, \@lnist2, \@lnist3, \@lnist4, \@lnist5, \@lnist1i, \@lnist2i, \@lnist3i, \@lnist4i, \@lnist5i);

   return \@SEG;
}

sub computeMultiNIST {
   #description _ computes NIST score (by calling NIST mteval script) -> n = 1..4 (multiple references)
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

   my $toolNIST = "perl $tools/$NIST::TNIST/mteval-v13a.pl -n -d 2 "; # version v13a
   if ( $case eq $Common::CASE_CS ) { $toolNIST .= "-c "; }

   my $refNISTxml = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$Common::REFEXT.$NISTEXT.$Common::SGMLEXT";
   if ((!(-e $refNISTxml)) or $remakeREPORTS) { NISTXML::SGML_f_create_mteval_multidoc($Href, $refNISTxml, 2, $verbose); }
   my $srcNISTxml = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$Common::SRCEXT.$NISTEXT.$Common::SGMLEXT";
   if ((!(-e $srcNISTxml)) or $remakeREPORTS) { NISTXML::SGML_f_create_mteval_doc($src, $srcNISTxml, 0, $verbose); }
   my $outNISTxml = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$Common::SYSEXT.$NISTEXT.$Common::SGMLEXT";
   if ((!(-e $outNISTxml)) or $remakeREPORTS) { NISTXML::SGML_f_create_mteval_doc($out, $outNISTxml, 1, $verbose); }
   my $reportNIST = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$NISTEXT.$Common::REPORTEXT";
   if ($verbose > 1) { print STDERR "building $reportNIST...\n"; }
   
   #print STDERR "$toolNIST -s $srcNISTxml -t $outNISTxml -r $refNISTxml > $reportNIST\n";
   Common::execute_or_die("$toolNIST -s $srcNISTxml -t $outNISTxml -r $refNISTxml > $reportNIST", "[ERROR] problems running NIST...");
   
   if (-e $srcNISTxml) { system "rm -f $srcNISTxml"; }
   if (-e $refNISTxml) { system "rm -f $refNISTxml"; }
   if (-e $outNISTxml) { system "rm -f $outNISTxml"; }
   
   my $SYS = read_nist($reportNIST);
   my $SEG = read_nist_segments($reportNIST);
   system("rm -f $reportNIST");

   return($SYS, $SEG);
}

sub doMultiNIST {
   #description _ computes NIST score (by calling NIST mteval script) -> n = 1..4 (multiple references)
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
   my @mNIST = keys %{$NIST::rNIST};   
   while (($i < scalar(@mNIST)) and (!$GO)) { if (exists($M->{$prefix.$mNIST[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$NIST::NISTEXT.."; }
      my $reportNIST1xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXT-1.$Common::XMLEXT";
      my $reportNIST2xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXT-2.$Common::XMLEXT";
      my $reportNIST3xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXT-3.$Common::XMLEXT";
      my $reportNIST4xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXT-4.$Common::XMLEXT";
      my $reportNIST5xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXT-5.$Common::XMLEXT";
      my $reportNIST2ixml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXTi-2.$Common::XMLEXT";
      my $reportNIST3ixml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXTi-3.$Common::XMLEXT";
      my $reportNIST4ixml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXTi-4.$Common::XMLEXT";
      my $reportNIST5ixml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NISTEXTi-5.$Common::XMLEXT";

      if ( (!(-e $reportNIST1xml) and !(-e $reportNIST1xml.".$Common::GZEXT")) or 
           (!(-e $reportNIST2xml) and !(-e $reportNIST2xml.".$Common::GZEXT")) or 
           (!(-e $reportNIST3xml) and !(-e $reportNIST3xml.".$Common::GZEXT")) or 
           (!(-e $reportNIST4xml) and !(-e $reportNIST4xml.".$Common::GZEXT")) or 
           (!(-e $reportNIST5xml) and !(-e $reportNIST5xml.".$Common::GZEXT")) or 
           (!(-e $reportNIST2ixml) and !(-e $reportNIST2ixml.".$Common::GZEXT")) or 
           (!(-e $reportNIST3ixml) and !(-e $reportNIST3ixml.".$Common::GZEXT")) or 
           (!(-e $reportNIST4ixml) and !(-e $reportNIST4ixml.".$Common::GZEXT")) or 
           (!(-e $reportNIST5ixml) and !(-e $reportNIST5ixml.".$Common::GZEXT")) or 
           $remakeREPORTS) {
           
         my ($SYS, $SEGS) = NIST::computeMultiNIST($src, $out, $Href, $remakeREPORTS, $config->{CASE}, $tools, $verbose, $hOQ );
         my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[0], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXT-1", $SYS->[0], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXT-1", $TGT, $REF, $SYS->[0], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[1], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXT-2", $SYS->[1], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXT-2", $TGT, $REF, $SYS->[1], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[2], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXT-3", $SYS->[2], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXT-3", $TGT, $REF, $SYS->[2], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[3], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXT-4", $SYS->[3], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXT-4", $TGT, $REF, $SYS->[3], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[4], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXT-5", $SYS->[4], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXT-5", $TGT, $REF, $SYS->[4], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[6], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXTi-2", $SYS->[6], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXTi-2", $TGT, $REF, $SYS->[6], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[7], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXTi-3", $SYS->[7], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXTi-3", $TGT, $REF, $SYS->[7], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[8], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXTi-4", $SYS->[8], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXTi-4", $TGT, $REF, $SYS->[8], $doc_scores, $seg_scores,$hOQ);
         
         ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->[9], 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$NISTEXTi-5", $SYS->[9], $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$NISTEXTi-5", $TGT, $REF, $SYS->[9], $doc_scores, $seg_scores,$hOQ);
      }
   }
}

1;
