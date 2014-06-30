package GTM;

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
use Unicode::String qw(utf8 latin1);
#use Data::Dumper;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Metrics;

our ($GTMEXT, $rGTM, $TGTM);

$GTM::GTMEXT = "GTM";
$GTM::TGTM = "gtm-1.4";   # version 1.4
$GTM::rGTM = { "$GTM::GTMEXT-1" => 1, "$GTM::GTMEXT-2" => 1, "$GTM::GTMEXT-3" => 1 };

# watch character encoding!
# (e.g., unicode characters in WMT07)
# java performs pattern matching according to the LANG environment variable
# --------->  export LANG=ru_RU.KOI8-R
#             setenv LANG ru_RU.KOI8-R
#             export LANG=zh_CN.EUC
#             setenv LANG zh_CN.EUC
#             export LANG=es_ES@euro
#             setenv LANG es_ES@euro
#             setenv LANG ar
#             export LANG=ar


sub metric_set {
    #description _ returns the set of available metrics
    #@return _ metric set structure (hash ref)

    return $GTM::rGTM;
}

sub read_gtm {
   #description _ read GTM value from report file
   #param1  _ report filename
   #@return _ GTM score

   my $report = shift;

   my $REPORT = File::ReadBackwards->new($report) or die "Couldn't open input file: $report\n";
   my $gtm = $REPORT->readline;
   $REPORT->close();
   chomp($gtm);
   #$gtm =~ s/^ +//;

   my @GTM = split(/ +/, $gtm);

   #return $gtm;
   return $GTM[1];
}

sub read_gtm_segments_old {
   #description _ read GTM value from report file (for all segments)
   #param1  _ report filename
   #@return _ gtm F1 score list

   my $report = shift;

   my @lgtm;

   open(AUX, "< $report") or die "couldn't open file: $report\n";
   while (my $aux = <AUX>) {
      if ($aux =~ /^ \".*/) {
         chomp($aux);
         my @laux = split(/ +/, $aux);
         push(@lgtm, $laux[2]);
      }
   }
   close(AUX);

   return \@lgtm;
}

sub read_gtm_segments {
   #description _ read GTM value from report file (for all segments)
   #param1  _ report filename
   #@return _ gtm F1 score list

   my $report = shift;

   my @lgtm;

   open(AUX, "< $report") or die "couldn't open file: $report\n";
   while (my $aux = <AUX>) {
      chomp($aux);
      my @laux = split(/ +/, $aux);
      if (scalar(@laux) == 3) {
         push(@lgtm, $laux[2]);
      }
   }
   close(AUX);

   return \@lgtm;
}

sub computeMultiGTM {
   #description _ computes GTM F1 (by calling Proteus java gtm) -> e = 1..3 (multiple references)
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ remake reports? (1 - yes :: 0 - no)
   #param5 _ tools
   #param6 _ e parameter
   #param7 _ case (0/1)
   #param8 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $remakeREPORTS = shift;
   my $tools = shift;
   my $e = shift;
   my $case = shift;
   my $verbose = shift;

   my $toolGTM = "java -Dfile.encoding=UTF-8 -jar $tools/$GTM::TGTM/gtm.jar +s +d";
#   my $toolGTM = "/usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java -Dfile.encoding=UTF-8 -jar $tools/$GTM::TGTM/gtm.jar +s +d";

   my @LrefGTMsgml;
   foreach my $r (keys %{$Href}) {
       my $ref = $Href->{$r};
       my $refGTMsgml = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$Common::REFEXT.$GTMEXT.$Common::SGMLEXT";
       if ((!(-e $refGTMsgml)) or $remakeREPORTS) { NISTXML::SGML_GTM_f_create_mteval_doc($ref, $refGTMsgml, $case, $verbose); }
       push(@LrefGTMsgml, $refGTMsgml);
   }
   my $outGTMsgml = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$Common::SYSEXT.$GTMEXT.$Common::SGMLEXT";
   if ((!(-e $outGTMsgml)) or $remakeREPORTS) { NISTXML::SGML_GTM_f_create_mteval_doc($out, $outGTMsgml, $case, $verbose); }
   my $reportGTM = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$GTMEXT-$e.$Common::REPORTEXT";
   if ($verbose > 1) { print STDERR "building $reportGTM...\n"; }

   Common::execute_or_die("$toolGTM -e $e $outGTMsgml ".join(" ", @LrefGTMsgml)." > $reportGTM", "[ERROR] problems running GTM...");

   my $SYS = read_gtm($reportGTM);
   my $SEG = read_gtm_segments($reportGTM);

   system("rm -f $reportGTM");
   foreach my $r (@LrefGTMsgml) { if (-e $r) { system("rm -f $r"); } }
   if (-e $outGTMsgml) { system "rm -f $outGTMsgml"; }

   return($SYS, $SEG);
}

sub doMultiGTM {
   #description _ computes GTM F1 (by calling Proteus java gtm) -> e = 1..3 (multiple references)
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
   my @mGTM = keys %{$GTM::rGTM};
   while (($i < scalar(@mGTM)) and (!$GO)) { if (exists($M->{$prefix.$mGTM[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$GTM::GTMEXT.."; }
      my $reportGTM1xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$GTMEXT-1.$Common::XMLEXT";
      my $reportGTM2xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$GTMEXT-2.$Common::XMLEXT";
      my $reportGTM3xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$GTMEXT-3.$Common::XMLEXT";
      if ((!(-e $reportGTM1xml) and !(-e $reportGTM1xml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($SYS, $SEGS) = GTM::computeMultiGTM($src, $out, $Href, $remakeREPORTS, $tools, 1, $config->{CASE}, $verbose);
         my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$GTMEXT-1", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$GTMEXT-1", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
      }
      if ((!(-e $reportGTM2xml) and !(-e $reportGTM2xml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($SYS, $SEGS) = GTM::computeMultiGTM($src, $out, $Href, $remakeREPORTS, $tools, 2, $config->{CASE}, $verbose);
         my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$GTMEXT-2", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$GTMEXT-2", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
      }
      if ((!(-e $reportGTM3xml) and !(-e $reportGTM3xml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($SYS, $SEGS) = GTM::computeMultiGTM($src, $out, $Href, $remakeREPORTS, $tools, 3, $config->{CASE}, $verbose);
         my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$prefix$GTMEXT-3", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
			Scores::save_hash_scores("$prefix$GTMEXT-3", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
      }
   }
}

1;
