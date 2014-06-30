package METEOR;

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
use IQ::InOut::NISTSCR;

our ($MTREXT, $rMETEOR, $rMETEOReng, $rMETEORnoeng, $TMETEOR);

$METEOR::MTREXT = "METEOR";
$METEOR::TMETEOR = "meteor-1.4";                # version 1.4
$METEOR::METEORSCRIPT = "meteor-1.4.jar";



#------------------------------------
#METEOR language <--> modules
#------------------------------------
#English    (en)    (all)
#Arabic     (ar)    (exact, paraphrase) 
#Czech      (cz)    (exact, paraphrase)
#French     (fr)    (exact, paraphrase, porter_stem)
#German     (de)    (exact, paraphrase, porter_stem)
#Spanish    (es)    (exact, paraphrase, porter_stem)
#Danish     (da)    (exact, porter_stem)
#Dutch      (nl)    (exact, porter_stem)
#Finnish    (fi)    (exact, porter_stem)
#Hungarian  (hu)    (exact, porter_stem)
#Italian    (it)    (exact, porter_stem)
#Norwegian  (no)    (exact, porter_stem)
#Portuguese (pt)    (exact, porter_stem)
#Romanian   (ro)    (exact, porter_stem)
#Russian    (ru)    (exact, porter_stem)
#Swedish    (sv)    (exact, porter_stem)
#Turkish    (tr)    (exact, porter_stem)
#------------------------------------

$METEOR::rMETEOR = { "$METEOR::MTREXT-ex" => 1, "$METEOR::MTREXT-st" => 1, "$METEOR::MTREXT-sy" => 1, "$METEOR::MTREXT-pa" => 1 };

$METEOR::rLANG = { $Common::L_ENG => 'en', $Common::L_SPA => 'es', $Common::L_GER => 'de', $Common::L_FRN => 'fr', $Common::L_CZE => 'cz',
                   $Common::L_ARA => 'ar', $Common::L_DAN => 'da', $Common::L_DUT => 'nl', $Common::L_FIN => 'fi', $Common::L_HUN => 'hu',
                   $Common::L_ITA => 'it', $Common::L_NOR => 'no', $Common::L_POR => 'pt', $Common::L_ROM => 'ro', $Common::L_RUS => 'ru', 
                   $Common::L_SWE => 'sv', $Common::L_TUR => 'tr'};

$METEOR::rLANG_STM = { $Common::L_ENG => 1, $Common::L_SPA => 1, $Common::L_GER => 1, $Common::L_FRN => 1, $Common::L_DAN => 1, $Common::L_DUT => 1, $Common::L_FIN => 1,
                       $Common::L_HUN => 1, $Common::L_ITA => 1, $Common::L_NOR => 1, $Common::L_POR => 1, $Common::L_ROM => 1, $Common::L_RUS => 1, $Common::L_SWE => 1, $Common::L_TUR => 1 };
                       
$METEOR::rLANG_PARA = { $Common::L_ENG => 1, $Common::L_SPA => 1, $Common::L_GER => 1, $Common::L_FRN => 1, $Common::L_CZE => 1, $Common::L_ARA => 1 };

$METEOR::rLANG_SYN = { $Common::L_ENG => 1 };

sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;
    $metric_set{"$METEOR::MTREXT-ex"} = 1;
    if (exists($METEOR::rLANG_STM->{$language})) { $metric_set{"$METEOR::MTREXT-st"} = 1; }
    if (exists($METEOR::rLANG_SYN->{$language})) { $metric_set{"$METEOR::MTREXT-sy"} = 1; }
    if (exists($METEOR::rLANG_PARA->{$language})) { $metric_set{"$METEOR::MTREXT-pa"} = 1; }

    return \%metric_set;
}

sub read_scores ($;$) {
   #description _ read system, document and segment scores (from the corresponding Metrics_MaTR-like format files)
   #param1  _ prefix basename for .scr files
   #param2  _ optional. the idx structure for the related basename-system
   #@return _ (sys_score, doc_scores, seg_scores)

   my $basename = shift;
   my $bIDX = shift;
   
   my $sys_scores = read_scores_G($basename, $Common::G_SYS, $bIDX);
   my $doc_scores = read_scores_G($basename, $Common::G_DOC, $bIDX);
   my $seg_scores = read_scores_G($basename, $Common::G_SEG, $bIDX);

   return ($sys_scores->[0], $doc_scores, $seg_scores);
}

sub read_scores_G ($$;$){
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

   my $scores = Common::reorder_scores( $hscores, $bIDX, $G );
      
   return $scores;
}

sub computeMultiMETEOR {
   #description _ computes METEOR scores (exact + stem + syn + para) (multiple references)
   #param1  _ source file
   #param2  _ candidate file
   #param3  _ reference file(s) [hash reference]
   #param4  _ candidate name
   #param5  _ sys-doc-seg index structure [hash reference]
   #param6  _ remake reports? (1 - yes :: 0 - no)
   #param7  _ tools
   #param8  _ language
   #param9  _ variant (exact | stem | syn | para)
   #param10 _ case (cs/ci)
   #param11 _ verbosity (0/1)

   my $src = shift;
   my $out = shift;
   my $Href = shift;
   my $TGT = shift;
   my $IDX = shift;
   my $remakeREPORTS = shift;
   my $tools = shift;
   my $L = shift;
   my $variant = shift;
   my $case = shift;
   my $verbose = shift;

   my $mem_options = " -Xms1024M -Xmx1024M "; #-XX:+UseCompressedOops"; #http://publib.boulder.ibm.com/infocenter/javasdk/v6r0/index.jsp?topic=%2Fcom.ibm.java.doc.user.aix64.60%2Fdiag%2Fappendixes%2Fcmdline%2Fcommands_jvm_xx.html


   my $lang = "";
   if ( exists $METEOR::rLANG->{$L} ){
	$lang = "-l $METEOR::rLANG->{$L}";
   }

   my $R = rand($Common::NRAND);
   my $sysid = $IDX->{$TGT}->[1]->[2];

   my $outMTRsgml = "$Common::DATA_PATH/$Common::TMP/$R.$Common::SYSEXT.$MTREXT.$Common::XMLEXT";
   if ((!(-e $outMTRsgml)) or $remakeREPORTS) { NISTXML::f_create_mteval_doc($out, $outMTRsgml, $TGT, $IDX, 1, $case, $verbose); }
   my $refMTRsgml = "$Common::DATA_PATH/$Common::TMP/$R.$Common::REFEXT.$MTREXT.$Common::XMLEXT";
   if ((!(-e $refMTRsgml)) or $remakeREPORTS) { NISTXML::f_create_mteval_multidoc($Href, $refMTRsgml, $IDX, 2, $case, $verbose); }

   my $modules;
   if ($variant eq "exact") { $modules = "exact"; }
   elsif ($variant eq "stem") { $modules = "exact stem"; }
   elsif ($variant eq "syn") { $modules = "exact stem synonym"; } 
   elsif ($variant eq "para" && $lang ne "-l cz" ) { $modules = "exact stem paraphrase"; } 
   elsif ($variant eq "para" && $lang eq "-l cz" ) { $modules = "exact paraphrase"; } 
   else { die "[ERROR] unknown METEOR variant <$variant>!!\n"; }

   my $toolMETEOR = "java -Dfile.encoding=UTF-8 $mem_options -jar $tools/$METEOR::TMETEOR/$METEOR::METEORSCRIPT";
   
   Common::execute_or_die("$toolMETEOR $outMTRsgml $refMTRsgml -sgml -f $Common::DATA_PATH/$Common::TMP/$sysid $lang -m \"$modules\" > /dev/null 2> /dev/null",
                          "[ERROR] problems running METEOR..."); # version 1.4 

   my ($sys_score, $doc_scores, $seg_scores) = read_scores("$Common::DATA_PATH/$Common::TMP/$sysid", $IDX->{$TGT});

   if (-e $refMTRsgml) { system "rm -f $refMTRsgml"; }
   if (-e $outMTRsgml) { system "rm -f $outMTRsgml"; }

   return ($sys_score, $doc_scores, $seg_scores);
}

sub doMultiMETEOR {
   #description _ computes METEOR scores (exact + stem + syn + para) (multiple references)
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
   my $L = $config->{LANG};                     # language
   my $M = $config->{Hmetrics};                 # set of metrics
   my $verbose = $config->{verbose};            # verbosity (0/1)
   my $IDX = $config->{IDX};                    # sys-doc-seg index structure

   my $GO = 0; my $i = 0;
   my @mMETEOR = keys %{$METEOR::rMETEOR};
   while (($i < scalar(@mMETEOR)) and (!$GO)) { if (exists($M->{$mMETEOR[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "METEOR.."; }
      my $reportMTRexactXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$MTREXT-ex.$Common::XMLEXT";
      my $reportMTRstemXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$MTREXT-st.$Common::XMLEXT";
      my $reportMTRsynXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$MTREXT-sy.$Common::XMLEXT";
      my $reportMTRparaXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$MTREXT-pa.$Common::XMLEXT";
      if (((!(-e $reportMTRexactXML) and !(-e $reportMTRexactXML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$MTREXT-ex"}) { #exact
         my ($sys_score, $doc_scores, $seg_scores) = METEOR::computeMultiMETEOR($src, $out, $Href, $TGT, $IDX, $remakeREPORTS, $tools, $L, "exact", $config->{CASE}, $verbose);
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$MTREXT-ex", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
         Scores::save_hash_scores("$MTREXT-ex", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
      }
      if (((!(-e $reportMTRstemXML) and !(-e $reportMTRstemXML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$MTREXT-st"}) { #exact + porter_stem
         if (exists($METEOR::rLANG_STM->{$L})) {
            my ($sys_score, $doc_scores, $seg_scores) = METEOR::computeMultiMETEOR($src, $out, $Href, $TGT, $IDX, $remakeREPORTS, $tools, $L, "stem", $config->{CASE}, $verbose);
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$MTREXT-st", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
         	Scores::save_hash_scores("$MTREXT-st", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
         }
         else { die "[ERROR] $MTREXT-st metric not available for language '$L'!\n"; }
      }
      if (((!(-e $reportMTRsynXML) and !(-e $reportMTRsynXML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$MTREXT-sy"}) { #exact + porter_stem + wn_stem + wn_syn
         if (exists($METEOR::rLANG_SYN->{$L})) {
            my ($sys_score, $doc_scores, $seg_scores) = METEOR::computeMultiMETEOR($src, $out, $Href, $TGT, $IDX, $remakeREPORTS, $tools, $L, "syn", $config->{CASE}, $verbose);
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$MTREXT-sy", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
         	Scores::save_hash_scores("$MTREXT-sy", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
         }
         else { die "[ERROR] $MTREXT-sy metric not available for language '$L'!\n"; }
      }
      if (((!(-e $reportMTRparaXML) and !(-e $reportMTRparaXML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$MTREXT-pa"}) { #exact + porter_stem + wn_stem + wn_syn + para
         if (exists($METEOR::rLANG_PARA->{$L})) {
            my ($sys_score, $doc_scores, $seg_scores) = METEOR::computeMultiMETEOR($src, $out, $Href, $TGT, $IDX, $remakeREPORTS, $tools, $L, "para", $config->{CASE}, $verbose);
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$MTREXT-pa", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
         	Scores::save_hash_scores("$MTREXT-pa", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
         }
         else { die "[ERROR] $MTREXT-pa metric not available for language '$L'!\n"; }
      }
   }
}

1;
