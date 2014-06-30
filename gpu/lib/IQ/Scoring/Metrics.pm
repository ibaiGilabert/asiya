package Metrics;

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
use Benchmark;
use IQ::Common;
use IQ::InOut::IQXML;
use IQ::InOut::NISTXML;
use IQ::Scoring::METEOR;
use IQ::Scoring::WER;
use IQ::Scoring::PER;
use IQ::Scoring::TERp;
use IQ::Scoring::ROUGE;
use IQ::Scoring::GTM;
use IQ::Scoring::BLEU;
use IQ::Scoring::NIST;
use IQ::Scoring::BLEUNIST;
use IQ::Scoring::NGRAM;
use IQ::Scoring::ESA;
use IQ::Scoring::Overlap;
use IQ::Scoring::SP;
use IQ::Scoring::DP;
use IQ::Scoring::DPmalt;
use IQ::Scoring::NE;
use IQ::Scoring::SR;
use IQ::Scoring::CP;
use IQ::Scoring::DR;
use IQ::Scoring::CE;
use IQ::Scoring::LeM;
use IQ::Scoring::Align;
use IQ::MetaScoring::ULC;
use IQ::MetaScoring::QARLA;
use IQ::InOut::TeX;
use IQ::Learning::Learner;
use IQ::Analyzing::TSDatabase;

# PREDEFINED METRIC SETS ====================================
# (default metric sets)
$Metrics::METRICS_DEFAULT = "$BLEUNIST::BLEUEXT $GTM::GTMEXT-1 $GTM::GTMEXT-2 $GTM::GTMEXT-3 $BLEUNIST::NISTEXT $ROUGE::ROUGEXT-L $ROUGE::ROUGEXT-S* $ROUGE::ROUGEXT-SU* $ROUGE::ROUGEXT-W -$WER::WEREXT -$PER::PEREXT -$TERp::TEREXT -$TERp::TEREXT"."base -$TERp::TEREXT"."p -$TERp::TEREXT"."p-A $METEOR::MTREXT-ex $METEOR::MTREXT-st $METEOR::MTREXT-sy $METEOR::MTREXT-pa $Overlap::OlEXT $SP::SPEXT-Op(*) $SP::SPEXT-Oc(*) $SP::SPEXT-lNIST $SP::SPEXT-pNIST $SP::SPEXT-iobNIST $SP::SPEXT-cNIST $CP::CPEXT-Op(*) $CP::CPEXT-Oc(*) $CP::CPEXT-STM-4 $CP::CPEXT-STM-5 $CP::CPEXT-STM-6 $DP::DPEXT-Ol(*) $DP::DPEXT-Oc(*) $DP::DPEXT-Or(*) $DP::DPEXT-HWCM_w-4 $DP::DPEXT-HWCM_c-4 $DP::DPEXT-HWCM_r-4 $NE::NEEXT-Oe(*) $NE::NEEXT-Me(*) $SR::SREXT-Or(*) $SR::SREXT-Mr(*) $SR::SREXT-Or $SR::SREXT-Orv(*) $SR::SREXT-Mrv(*) $SR::SREXT-Orv $DR::DREXT-Or(*) $DR::DREXT-Orp(*) $DR::DREXT-STM-4 $DR::DREXT-STM-5 $DR::DREXT-STM-6";

#$Metrics::METRICS_DEFAULT_es = "$BLEUNIST::BLEUEXT $GTM::GTMEXT-1 $GTM::GTMEXT-2 $GTM::GTMEXT-3 $BLEUNIST::NISTEXT $ROUGE::ROUGEXT-L $ROUGE::ROUGEXT-S* $ROUGE::ROUGEXT-SU* $ROUGE::ROUGEXT-W -$WER::WEREXT -$PER::PEREXT -$TERp::TEREXT -$TERp::TEREXT"."base $METEOR::MTREXT-ex $METEOR::MTREXT-st $METEOR::MTREXT-pa $Overlap::OlEXT $SP::SPEXT-Op(*) $SP::SPEXT-Oc(*) $SP::SPEXT-lNIST $SP::SPEXT-pNIST $SP::SPEXT-iobNIST $SP::SPEXT-cNIST $CP::CPEXT-Op(*) $CP::CPEXT-Oc(*) $CP::CPEXT-STM-4 $CP::CPEXT-STM-5 $CP::CPEXT-STM-6";
$Metrics::METRICS_DEFAULT_es = "$BLEUNIST::BLEUEXT $GTM::GTMEXT-1 $GTM::GTMEXT-2 $GTM::GTMEXT-3 $BLEUNIST::NISTEXT $ROUGE::ROUGEXT-L $ROUGE::ROUGEXT-S* $ROUGE::ROUGEXT-SU* $ROUGE::ROUGEXT-W -$WER::WEREXT -$PER::PEREXT -$TERp::TEREXT -$TERp::TEREXT"."base $METEOR::MTREXT-ex $METEOR::MTREXT-st $METEOR::MTREXT-pa $Overlap::OlEXT $SP::SPEXT-Op(*) $SP::SPEXT-Oc(*) $SP::SPEXT-lNIST $SP::SPEXT-pNIST $SP::SPEXT-iobNIST $SP::SPEXT-cNIST";
#mgb removed the CP metrics due the lack of CP parser for spanish
$Metrics::METRICS_DEFAULT_other = "$BLEUNIST::BLEUEXT $GTM::GTMEXT-1 $GTM::GTMEXT-2 $GTM::GTMEXT-3 $BLEUNIST::NISTEXT $ROUGE::ROUGEXT-L $ROUGE::ROUGEXT-S* $ROUGE::ROUGEXT-SU* $ROUGE::ROUGEXT-W -$WER::WEREXT -$PER::PEREXT -$TERp::TEREXT -$TERp::TEREXT"."base $METEOR::MTREXT-ex $METEOR::MTREXT-st $Overlap::OlEXT";
$Metrics::rMETRICS_DEFAULT = {$Common::L_ENG => $Metrics::METRICS_DEFAULT, $Common::L_SPA => $Metrics::METRICS_DEFAULT_es, $Common::L_OTHER => $Metrics::METRICS_DEFAULT_other };

# (ULCh metric sets)
$Metrics::METRICS_ULCh = "$ROUGE::ROUGEXT-W $METEOR::MTREXT-sy $CP::CPEXT-STM-4 $DP::DPEXT-HWCM_c-4 $DP::DPEXT-HWCM_r-4 $DP::DPEXT-Or(*) $SR::SREXT-Or(*)_b $SR::SREXT-Mr(*)_b $SR::SREXT-Or_b $DR::DREXT-Or(*)_b $DR::DREXT-Orp(*)_b";
$Metrics::METRICS_ULCh_es = "$ROUGE::ROUGEXT-W $METEOR::MTREXT-st $SP::SPEXT-Op(*) $SP::SPEXT-Oc(*) $CP::CPEXT-STM-4";
$Metrics::METRICS_ULCh_other = "$GTM::GTMEXT-2 $ROUGE::ROUGEXT-W $METEOR::MTREXT-ex -$TERp::TEREXT";
$Metrics::rMETRICS_ULCh = {$Common::L_ENG => $Metrics::METRICS_ULCh, $Common::L_SPA => $Metrics::METRICS_ULCh_es, $Common::L_OTHER => $Metrics::METRICS_ULCh_other };

# (DR and DRdoc metric sets)
$Metrics::METRICS_DR= "$DR::DREXT-Or(*)_b $DR::DREXT-Orp(*)_b $DR::DREXT-STM-4_b";
$Metrics::METRICS_DRdoc= "$DR::DRDOCEXT-Or(*)_b $DR::DRDOCEXT-Orp(*)_b $DR::DRDOCEXT-STM-4_b";

#########################################################################################################################################################


sub load_metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ source language
    #param2  _ target language
    #@return _ metric set structure (hash ref)

    my $source_language = shift;
    my $target_language = shift;

    my %metric_set;


    my $METEOR_set = METEOR::metric_set($target_language);
    @metric_set{keys %{$METEOR_set}} = values %{$METEOR_set};
    my $ROUGE_set = ROUGE::metric_set();
    @metric_set{keys %{$ROUGE_set}} = values %{$ROUGE_set};
    my $BLEU_set = BLEU::metric_set();
    @metric_set{keys %{$BLEU_set}} = values %{$BLEU_set};
    my $NIST_set = NIST::metric_set();
    @metric_set{keys %{$NIST_set}} = values %{$NIST_set};
    my $BLEUNIST_set = BLEUNIST::metric_set();
    @metric_set{keys %{$BLEUNIST_set}} = values %{$BLEUNIST_set};
    my $NGRAM_set = NGRAM::metric_set();
    @metric_set{keys %{$NGRAM_set}} = values %{$NGRAM_set};
    my $ESA_set = ESA::metric_set($target_language);
    @metric_set{keys %{$ESA_set}} = values %{$ESA_set};
    my $GTM_set = GTM::metric_set();
    @metric_set{keys %{$GTM_set}} = values %{$GTM_set};
    my $WER_set = WER::metric_set();
    @metric_set{keys %{$WER_set}} = values %{$WER_set};
    my $PER_set = PER::metric_set();
    @metric_set{keys %{$PER_set}} = values %{$PER_set};
    my $TER_set = TERp::metric_set();
    @metric_set{keys %{$TER_set}} = values %{$TER_set};
    my $OVERLAP_set = Overlap::metric_set();
    @metric_set{keys %{$OVERLAP_set}} = values %{$OVERLAP_set};
    my $ALIGN_set = Align::metric_set($source_language, $target_language);
    @metric_set{keys %{$ALIGN_set}} = values %{$ALIGN_set};
    my $SP_set = SP::metric_set($target_language);
    @metric_set{keys %{$SP_set}} = values %{$SP_set};
    my $DP_set = DP::metric_set($target_language);
    @metric_set{keys %{$DP_set}} = values %{$DP_set};
    my $DPm_set = DPmalt::metric_set($target_language);
    @metric_set{keys %{$DPm_set}} = values %{$DPm_set};
    my $NE_set = NE::metric_set($target_language);
    @metric_set{keys %{$NE_set}} = values %{$NE_set};
    my $SR_set = SR::metric_set($target_language);
    @metric_set{keys %{$SR_set}} = values %{$SR_set};
    my $CP_set = CP::metric_set($target_language);
    @metric_set{keys %{$CP_set}} = values %{$CP_set};
    my $DR_set = DR::metric_set($target_language);
    @metric_set{keys %{$DR_set}} = values %{$DR_set};
    my $CE_set = CE::metric_set($source_language, $target_language);
    @metric_set{keys %{$CE_set}} = values %{$CE_set};
    my $LeM_set = LeM::metric_set($source_language, $target_language);
    @metric_set{keys %{$LeM_set}} = values %{$LeM_set};

    return \%metric_set;
}



sub doMultiMetrics {
   #description _ launches automatic MT evaluation metrics (for multiple references)
   #                              * computes GTM (by calling Proteus java gtm) -> e = 1..3
   #                              * computes BLEU score (by calling NIST mteval script) -> n = 4
   #                              * computes NIST score (by calling NIST mteval script) -> n = 5
   #                              * computes METEOR
   #                              * computes ROUGE
   #                              * computes WER
   #                              * computes PER
   #                              * computes TER
   #                              * computes SP-based (Shallow Parsing)
   #                              * computes DP-based (Dependency Parsing)
   #                              * computes NE-based (Named Entity Recognition & Classification)
   #                              * computes CP-based (Full Parsing)
   #                              * computes SR-based (Semantic Role Labeling)
   #                              * computes DR-based (Discourse Representation - Semantics)
   #param1  _ configuration 
   #param2  _ candidate hypothesis (KEY)
   #param3  _ candidate filename (string)
   #param4  _ reference list (KEY LIST)
   #param5  _ reference filenames (hash ref)
   #param6  _ hash of scores
   
   my $config = shift;
   my $HYP = shift;
   my $HYP_file = shift;
   my $Lref = shift;
   my $Href = shift;
	my $hOQ = shift;


   my $verbose = $config->{verbose};            # verbosity (0/1)
   my $M = $config->{Hmetrics};                 # set of metrics

   my %HREF;
   my @sorted_refs = sort @{$Lref};
   foreach my $r (@sorted_refs) { if (exists($Href->{$r})) { $HREF{$r} = $Href->{$r}; } }
   my $REF = join("_", sort keys %HREF);

   if ($verbose > 1) { print STDERR "computing similarities [$HYP]...\n"; }
   elsif ($verbose == 1) { print STDERR "$HYP - $REF ["; }

	
   CE::doCE($config, $HYP, $HYP_file, $REF, $hOQ);
   LeM::doMultiLeM($config, $HYP, $HYP_file, $REF, $hOQ);

   if (scalar(@{$Lref}) > 0) {
      BLEU::doMultiBLEU($config, $HYP, $HYP_file, $REF, \%HREF, "", $hOQ);
      NIST::doMultiNIST($config, $HYP, $HYP_file, $REF, \%HREF, "", $hOQ);
      BLEUNIST::doMultiBLEUNIST($config, $HYP, $HYP_file, $REF, \%HREF, "", $hOQ);
      NGRAM::doMultiNGRAM($config, $HYP, $HYP_file, $REF, \%HREF, "", $hOQ);
      ESA::doMultiESA($config, $HYP, $HYP_file, $REF, \%HREF, "", $hOQ);
      WER::doMultiWER($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      PER::doMultiPER($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      TERp::doMultiTER($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      Overlap::doMultiOl($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      Align::doMultiAr($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      GTM::doMultiGTM($config, $HYP, $HYP_file, $REF, \%HREF, "", $hOQ);
      METEOR::doMultiMETEOR($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      ROUGE::doMultiROUGE($config, $HYP, $HYP_file, $REF, \%HREF, 1, "", $hOQ); # + stemming
      SP::doMultiSP($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      DP::doMultiDP($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      DPmalt::doMultiDP($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      NE::doMultiNE($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      CP::doMultiCP($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      SR::doMultiSR($config, $HYP, $HYP_file, $REF, \%HREF, $hOQ);
      DR::doMultiDR($config, $HYP, $HYP_file, $REF, \%HREF, 0, $hOQ);
      DR::doMultiDR($config, $HYP, $HYP_file, $REF, \%HREF, 1, $hOQ);
   }
   
   if ($verbose == 1) { print STDERR "]\n"; }
}

# *************************************************************************************
# ************************* METRIC REPORTS ********************************************
# *************************************************************************************

sub get_sorted_metrics {
	my $config = shift;

	my @sorted_metrics;
		
    if (exists($config->{eval_schemes}->{$Common::S_SINGLE})) { 
    	 my @metrics = @{$config->{metrics}}; 
		 if ($config->{SORT} eq $Common::SORT_NAME) { @sorted_metrics = sort @metrics; }
		 else { @sorted_metrics = @metrics; }
    }
    if (exists($config->{eval_schemes}->{$Common::S_ULC})) { push(@sorted_metrics, $ULC::ULC_NAME); }
    if (exists($config->{eval_schemes}->{$Common::S_QUEEN})) { push(@sorted_metrics, $QARLA::QUEEN); }
    
    return @sorted_metrics;
}


# *************************************************************************************

sub get_sorted_systems {
	 my $config = shift;

	 my @systems;
	 	
	 if ($config->{SORT} eq $Common::SORT_NAME) { @systems = sort @{$config->{systems}}; }
    else { @systems = @{$config->{systems}}; }
    
    return @systems;
}

# *************************************************************************************

sub compute_metrics_combination {
    #description _ computes the combination of metrics
    #              -> all systems (system, document, segment levels) into the corresponding output files
    #param1  _ configuration
    #param2  _ the reference name
    #param3  _ the list of systems
    #param4  _ the list of metrics
    #param5  _ hash of scores    
    
    my $config = shift;
    my $REF = shift;
    my $rsystems = shift;
    my $rsorted_metrics = shift;
    my $hOQ = shift;

 
	 #for each metric
    foreach my $metric (@{$rsorted_metrics}) {
       # for each system
       foreach my $system (@{$rsystems}) {
          my $REF = join("_", sort @{$config->{references}});
          if ($metric eq $ULC::ULC_NAME) { 
          	 ULC::compute_normalized_ULC($config, $hOQ, [$system], $config->{references}, $config->{metrics}, $config->{G}); 
          }
          elsif ($metric eq $QARLA::QUEEN_NAME) { 
          	 QARLA::QUEEN($config, $hOQ, [$system], $config->{references}, $config->{metrics}, $config->{G}); 
          }
          else { 
	          IQXML::read_report($system, $REF, $metric, $hOQ, $config->{segments}, $config->{G}, $config->{verbose}); 
			 }
       }

       # for each reference
       if (($config->{do_refs}) and (scalar(@{$config->{references}}) > 1)) {
          foreach my $ref1 (sort @{$config->{references}}) { # references
             my @all_other_refs;
             foreach my $ref2 (@{$config->{references}}) { if ($ref1 ne $ref2) { push(@all_other_refs, $ref2); } }
             if (scalar(@all_other_refs)) {
                my $other_refs = join("_", sort @all_other_refs);
                if ($metric eq $ULC::ULC_NAME) { 
                	ULC::compute_normalized_ULC($config, $hOQ, [$ref1], \@all_other_refs, $config->{metrics}, $config->{G}); 
                }
                if ($metric eq $QARLA::QUEEN_NAME) { 
                	QARLA::QUEEN($config, $hOQ, [$ref1], \@all_other_refs, $config->{metrics}, $config->{G}); 
                }
                else { 
                	IQXML::read_report($ref1, $other_refs, $metric, $hOQ, $config->{segments}, $config->{G}, $config->{verbose}); 
                }
             }
          }
       }       
    }
	 #print STDERR Dumper $hOQ;
}

# ***************************************************************************************************************

sub delete_system_scores_NIST {
    #description _ delete score files for a given system
    #param1  _ configuration
    #param2  _ system name

    my $config = shift;
    my $system = shift;

    my $sysid = $config->{IDX}->{$system}->[1]->[2];
    
    # SYSTEM SCORE
    my $Fsys = "$sysid-sys.scr";
    system "rm -f $Fsys";
    # DOCUMENT SCORES
    my $Fdoc = "$sysid-doc.scr";
    system "rm -f $Fdoc";
    # SEGMENT SCORES
    my $Fseg = "$sysid-seg.scr";
    system "rm -f $Fseg";
}



sub save_system_scores_NIST {
    #description _ save scores for a given system according to a given metric into the corresponding output files
    #param1  _ configuration
    #param2  _ hash of scores (outside QARLA)
    #param3  _ system name
    #param4  _ reference name
    #param5  _ metric name

    my $config = shift;
    my $hOQ = shift;
    my $system = shift;
    my $ref = shift;
    my $metric = shift;

    my $S0 = $config->{systems}->[0];
    my $setid = $config->{IDX}->{$S0}->[0]->[0];

    my $sysid = $config->{IDX}->{$system}->[1]->[2];

    if (($config->{G} eq $Common::G_SYS) or ($config->{G} eq $Common::G_ALL)) { # SYSTEM SCORE
       my $Fsys = "$sysid-sys.scr";
       open(FSYS, " >> $Fsys") or die "Couldn't open output file $Fsys\n";
       print FSYS "$setid\t$sysid\t", Common::trunk_number($hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref}, $config->{float_length}, $config->{float_precision}), "\t$metric\n";
       close(FSYS);
    }
    
    if (($config->{G} eq $Common::G_DOC) or ($config->{G} eq $Common::G_ALL)) { # DOCUMENT SCORES
       my $ldocids = NISTXML::get_docid_list($config->{IDX}->{$system});      
       my $Fdoc = "$sysid-doc.scr";
       open(FDOC, " >> $Fdoc") or die "Couldn't open output file $Fdoc\n";
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_DOC}}); $i++) {
          my $docid = $ldocids->[$i];
          print FDOC "$setid\t$sysid\t$docid\t", Common::trunk_number($hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref}, $config->{float_length}, $config->{float_precision}), "\t$metric\n";
       }
       close(FDOC);
    }
    
    if (($config->{G} eq $Common::G_SEG) or ($config->{G} eq $Common::G_ALL)) { # SEGMENT SCORES
       my $Fseg = "$sysid-seg.scr";
       open(FSEG, " >> $Fseg") or die "Couldn't open output file $Fseg\n";
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_SEG}}); $i++) {
          my $docid = $config->{IDX}->{$system}->[$i + 1]->[0];
          my $segid = $config->{IDX}->{$system}->[$i + 1]->[3];
          print FSEG "$setid\t$sysid\t$docid\t$segid\t", Common::trunk_number($hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref}, $config->{float_length}, $config->{float_precision}), "\t$metric\n";
       }
       close(FSEG);
    }
}




sub print_scores_NIST {
    #description _ print metric scores in NIST 'MetricsMATR' format (i.e., onto .scr files)
    #              -> all systems (system, document, segment levels) into the corresponding output files
    #param1  _ configuration
    #param2  _ hash of scores

    my $config = shift;
    my $hOQ = shift;


	 #list of metrics
    my @sorted_metrics = get_sorted_metrics($config);    
    
	 #list of systems and references 
	 my @systems = get_sorted_systems($config);
    my $REF = join("_", sort @{$config->{references}});

	 Metrics::compute_metrics_combination( $config, $REF, \@systems, \@sorted_metrics, $hOQ );

    foreach my $system (@systems) {
       delete_system_scores_NIST($config, $system);
       foreach my $metric (@sorted_metrics) {
          if (exists($config->{eval_schemes}->{$Common::S_SINGLE})) { Metrics::save_system_scores_NIST($config, $hOQ, $system, $REF, $metric); }
       }
       if (exists($config->{eval_schemes}->{$Common::S_ULC})) { Metrics::save_system_scores_NIST($config, $hOQ, $system, $REF, $ULC::ULC_NAME); }
       if (exists($config->{eval_schemes}->{$Common::S_QUEEN})) { Metrics::save_system_scores_NIST($config, $hOQ, $system, $REF, $QARLA::QUEEN_NAME); }
    }
    
    if ($config->{do_refs}) {
       foreach my $ref1 (@{$config->{references}}) { # references
          my @all_other_refs;
          foreach my $ref2 (@{$config->{references}}) { if ($ref1 ne $ref2) { push(@all_other_refs, $ref2); } }
          if (scalar(@all_other_refs)) {
             my $REF2 = join("_", sort @all_other_refs);
             foreach my $metric (@sorted_metrics ) {
                if (exists($config->{eval_schemes}->{$Common::S_SINGLE})) { Metrics::save_system_scores_NIST($config, $hOQ, $ref1, $REF2, $metric); }
             }
             if (exists($config->{eval_schemes}->{$Common::S_ULC})) { Metrics::save_system_scores_NIST($config, $hOQ, $ref1, $REF2, $ULC::ULC_NAME); }
             if (exists($config->{eval_schemes}->{$Common::S_QUEEN})) { Metrics::save_system_scores_NIST($config, $hOQ, $ref1, $REF2, $QARLA::QUEEN_NAME); }
          }
       }
    }
}



# ***************************************************************************************************************


sub print_SMATRIX_header {
    #description _ print matrix score header (on a system basis)
    #param1  _ configuration 

    my $config = shift;
    my $rsystems = shift;


    my $r;
    my @header;
    my @references;
    foreach my $system (@{$rsystems}) {
       if ($config->{TEX} or exists($config->{PDF})) { push(@header, '{\bf '.$system.'}'); $r .= 'r'; }
       else { push(@header, Common::trunk_string($system, $config->{sysid_length})); }
    }
    if (($config->{do_refs}) and (scalar(@{$config->{references}}) > 1)) {
       if ($config->{SORT} eq $Common::SORT_NAME) { @references = sort @{$config->{references}}; }
       else { @references = @{$config->{references}}; }
       foreach my $reference (@references) {
          if ($config->{TEX} or exists($config->{PDF})) { push(@header, '{\bf '.$reference.'}'); $r .= 'r'; }
       	  else { push(@header, Common::trunk_string($reference, $config->{sysid_length})); }
       }
    }


    if ($config->{TEX} or (exists($config->{PDF}))) {
       my $head; my $l;
       if ($config->{G} eq $Common::G_SYS) { $l = "l"; $head = sprintf("%-".($Common::METRIC_NAME_LENGTH * 2)."s", '{\bf metric}'); }
       elsif ($config->{G} eq $Common::G_DOC) { $l = "ll"; $head = sprintf("%-".($Common::METRIC_NAME_LENGTH * 2)."s & %-".$config->{docid_length}."s", '{\bf metric}', '{\bf doc}'); }
       elsif ($config->{G} eq $Common::G_SEG) { $l = "lll"; $head = sprintf("%-".($Common::METRIC_NAME_LENGTH * 2)."s & %-".$config->{docid_length}."s & %-".$config->{segid_length}."s", '{\bf metric}', '{\bf doc}', '{\bf seg}'); }
       elsif ($config->{G} eq $Common::G_ALL) { $l = "lll"; $head = sprintf("%-".($Common::METRIC_NAME_LENGTH * 2)."s & %-".$config->{docid_length}."s & %-".$config->{segid_length}."s", '{\bf metric}', '{\bf doc}', '{\bf seg}'); }
       else { die "[ERROR] unknown granularity <", $config->{G}, ">!\n"; }
       my $fs = TeX::get_font_size($config->{TEX_font_size});
       my $tex_line = "\\begin{table}[tbhp]\n".
                      "\\centering\n".
                      "{$fs\n".
                      "\\begin{tabular}{$l$r}\n".
                      $head." & ".join(" & ", @header)."\\\\\\hline\n";
       if ($config->{TEX}) { print $tex_line; }
       if ($config->{PDF}) { $config->{TEX_REPORT} .= $tex_line; }    	
    }
    else {
       my $head;
       if ($config->{G} eq $Common::G_SYS) { $head = sprintf("%-".$config->{setid_length}."s %-".$Common::METRIC_NAME_LENGTH."s", "SET", "METRIC"); }
       elsif ($config->{G} eq $Common::G_DOC) { $head = sprintf("%-".$config->{setid_length}."s %-".$config->{docid_length}."s %-".$Common::METRIC_NAME_LENGTH."s", "SET", "DOC", "METRIC"); }
       elsif ($config->{G} eq $Common::G_SEG) { $head = sprintf("%-".$config->{setid_length}."s %-".$config->{docid_length}."s %-".$config->{segid_length}."s %-".$Common::METRIC_NAME_LENGTH."s", "SET", "DOC", "SEG", "METRIC"); }
       elsif ($config->{G} eq $Common::G_ALL) { $head = sprintf("%-".$config->{setid_length}."s %-".$config->{docid_length}."s %-".$config->{segid_length}."s %-".$Common::METRIC_NAME_LENGTH."s", "SET", "DOC", "SEG", "METRIC"); }
       else { die "[ERROR] unknown granularity <", $config->{G}, ">!\n"; }
       print $head, " ", join(" ", @header), "\n";
       my $length = length($head);
       $length += ($config->{sysid_length} + 1) * (scalar(@{$rsystems}) + scalar(@references));
       Common::print_hline('=', $length);
    } 
}



sub print_metric_scores_SMATRIX {
    #description _ print scores for a given system according to a given metric
    #param1  _ configuration
    #param2  _ hash of scores (outside QARLA)
    #param3  _ metric name
    #param4  _ system list
    #param4  _ reference name

    my $config = shift;
    my $hOQ = shift;
    my $metric = shift;
    my $rsystems = shift;

    my $texmetric;
    if ($config->{TEX} or exists($config->{PDF})) { $texmetric = TeX::tex_metric($metric);	}
    
    my @references;
    if (($config->{do_refs}) and (scalar(@{$config->{references}}) > 1)) {
       if ($config->{SORT} eq $Common::SORT_NAME) { @references = sort @{$config->{references}}; }
       else { @references = @{$config->{references}}; }
    }

    my $ref = join("_", @{$config->{references}});
    my $doALL = (scalar(keys %{$config->{segments}}) == 0);  # if no segments are specified, print all

    my $S0 = $config->{systems}->[0];
    my $setid = $config->{IDX}->{$S0}->[0]->[0];

    if (($config->{G} eq $Common::G_SYS) or ($config->{G} eq $Common::G_ALL)) { # SYSTEM SCORE
       my @scores;
       foreach my $system (@{$rsystems}) {
          push(@scores, Common::trunk_number($hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref}, $config->{sysid_length}, $config->{float_precision}));
       }
       foreach my $ref1 (@references) {
          my @all_other_refs;
          foreach my $ref2 (@{$config->{references}}) { if ($ref2 ne $ref1) { push(@all_other_refs, $ref2); } }
          my $other_refs = join("_", @all_other_refs);
          push(@scores, Common::trunk_number($hOQ->{$Common::G_SYS}->{$metric}->{$ref1}->{$other_refs}, $config->{sysid_length}, $config->{float_precision}));
       }
       if ($config->{TEX} or exists($config->{PDF})) {
       	  my $tex_line = sprintf("{\\bf\\boldmath %-".($Common::METRIC_NAME_LENGTH * 2)."s} & %s\\\\\n", $texmetric, join(" & ", @scores));
          if ($config->{TEX}) { printf $tex_line; }
          if (exists($config->{PDF})) { $config->{TEX_REPORT} .= $tex_line; }
       }
       else { printf "%-".$config->{setid_length}."s %-".$Common::METRIC_NAME_LENGTH."s %s\n", $setid, $metric, join(" ", @scores); }
    }

    if (($config->{G} eq $Common::G_DOC) or ($config->{G} eq $Common::G_ALL)) { # DOCUMENT SCORES
       my $ldocids = NISTXML::get_docid_list($config->{IDX}->{$S0});      
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_DOC}}); $i++) {
          my @scores;
          my $docid = $ldocids->[$i];
          foreach my $system (@{$rsystems}) {
             my $sysid = $config->{IDX}->{$system}->[1]->[2];
             push(@scores, Common::trunk_number($hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref}, $config->{sysid_length}, $config->{float_precision}));
          }
          foreach my $ref1 (@references) {
             my @all_other_refs;
             foreach my $ref2 (@{$config->{references}}) { if ($ref2 ne $ref1) { push(@all_other_refs, $ref2); } }
             my $other_refs = join("_", @all_other_refs);
             push(@scores, Common::trunk_number($hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$ref1}->{$other_refs}, $config->{sysid_length}, $config->{float_precision}));
          }
          if ($config->{TEX} or exists($config->{PDF})) {
             my $docidtex = TeX::escape_tex($docid);
             my $tex_line;
           	 if ($i == 0) { $tex_line = sprintf("{\\bf\\boldmath %-".($Common::METRIC_NAME_LENGTH * 2)."s} & %-".$config->{docid_length}."s & %s\\\\\n", $texmetric, $docidtex, join(" & ", @scores)); }
           	 else { $tex_line = sprintf("     %-".$Common::METRIC_NAME_LENGTH."s  & %-".$config->{docid_length}."s & %s\\\\\n", "", $docidtex, join(" & ", @scores)); }
             if ($config->{TEX}) { print $tex_line; }
             if (exists($config->{PDF})) { $config->{TEX_REPORT} .= $tex_line; }
          }
          else { printf "%-".$config->{setid_length}."s %-".$config->{docid_length}."s %-".$Common::METRIC_NAME_LENGTH."s %s\n", $setid, $docid, $metric, join(" ", @scores); }
       }
    }
    
    if (($config->{G} eq $Common::G_SEG) or ($config->{G} eq $Common::G_ALL)) { # SEGMENT SCORES
       my $prevdocid = "";
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_SEG}}); $i++) {
       	  if (exists($config->{segments}->{$i + 1}) or $doALL) {
             my $docid = $config->{IDX}->{$S0}->[$i + 1]->[0];
             my $segid = $config->{IDX}->{$S0}->[$i + 1]->[3];
             my @scores;
             foreach my $system (@{$rsystems}) {
                push(@scores, Common::trunk_number($hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref}, $config->{sysid_length}, $config->{float_precision}));
             }
             foreach my $ref1 (@references) {
                my @all_other_refs;
                foreach my $ref2 (@{$config->{references}}) { if ($ref2 ne $ref1) { push(@all_other_refs, $ref2); } }
                my $other_refs = join("_", @all_other_refs);
                push(@scores, Common::trunk_number($hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$ref1}->{$other_refs}, $config->{sysid_length}, $config->{float_precision}));
             }
             if ($config->{TEX} or exists($config->{PDF})) {
             	my $docidtex = TeX::escape_tex($docid);
             	my $tex_line;
             	if ($i == 0) { $tex_line = sprintf("{\\bf\\boldmath %-".($Common::METRIC_NAME_LENGTH * 2)."s} & %-".$config->{docid_length}."s & %-".$config->{segid_length}."s & %s\\\\\n", $texmetric, $docidtex, $segid, join(" & ", @scores)); }
             	else {
             	   if ($prevdocid eq $docid) { $tex_line = sprintf("     %-".$Common::METRIC_NAME_LENGTH."s  & %-".$config->{docid_length}."s & %-".$config->{segid_length}."s & %s\\\\\n", "", "", $segid, join(" & ", @scores)); }
             	   else { $tex_line = sprintf("     %-".$Common::METRIC_NAME_LENGTH."s  & %-".$config->{docid_length}."s & %-".$config->{segid_length}."s & %s\\\\\n", "", $docidtex, $segid, join(" & ", @scores)); }
             	}
                if ($config->{TEX}) { print $tex_line; }
                if (exists($config->{PDF})) { $config->{TEX_REPORT} .= $tex_line; }
             }
             else { printf "%-".$config->{setid_length}."s %-".$config->{docid_length}."s %-".$config->{segid_length}."s %-".$Common::METRIC_NAME_LENGTH."s %s\n", $setid, $docid, $segid, $metric, join(" ", @scores); }
             $prevdocid = $docid; 
       	  }
       }
    }    
}

sub print_scores_SMATRIX {
    #description _ print metric scores in SMATRIX format (on a system basis)
    #param1  _ configuration
    #param2  _ hash of scores

    my $config = shift;
    my $hOQ = shift;

	 #list of metrics
    my @sorted_metrics = get_sorted_metrics($config);    
    
	 #list of systems and references 
	 my @systems = get_sorted_systems($config);
    my $REF = join("_", sort @{$config->{references}});

    Metrics::print_SMATRIX_header($config);
    
	 Metrics::compute_metrics_combination( $config, $REF, \@systems, \@sorted_metrics, $hOQ );

    foreach my $metric (@sorted_metrics) {
       Metrics::print_metric_scores_SMATRIX($config, $hOQ, $metric, \@systems);  
    }

    if ($config->{TEX} or exists($config->{PDF})) { # close table
       my $tex_line = "\\end{tabular}\n".
                      "}\n".
                      "\\caption{".$Common::appNAME."-generated evaluation report (".$config->{G}."-level)}\n".
                      "\\label{t-".$Common::appNAME."_".$config->{TEX_table_count}."}\n".
                      "\\end{table}\n";
       $config->{TEX_table_count}++;
       if ($config->{TEX}) { print $tex_line; }
       if (exists($config->{PDF})) { $config->{TEX_REPORT} .= $tex_line; }
    }
}



# ***************************************************************************************************************


sub print_MMATRIX_header {
    #description _ print matrix score header (on a metric basis)
    #param1  _ configuration 
    #param1  _ metrics header

    my $config = shift;
    my $rsorted_metrics = shift;
    
    my @sorted_metrics = @{$rsorted_metrics};

    my $head;
    if ($config->{G} eq $Common::G_SYS) { $head = sprintf("%-".$config->{setid_length}."s %-".$config->{sysid_length}."s", "SET", "SYS"); }
    elsif ($config->{G} eq $Common::G_DOC) { $head = sprintf("%-".$config->{setid_length}."s %-".$config->{sysid_length}."s %-".$config->{docid_length}."s", "SET", "SYS", "DOC"); }
    elsif ($config->{G} eq $Common::G_SEG) { $head = sprintf("%-".$config->{setid_length}."s %-".$config->{sysid_length}."s %-".$config->{docid_length}."s %-".$config->{segid_length}."s", "SET", "SYS", "DOC", "SEG"); }
    elsif ($config->{G} eq $Common::G_ALL) { $head = sprintf("%-".$config->{setid_length}."s %-".$config->{sysid_length}."s %-".$config->{docid_length}."s %-".$config->{segid_length}."s", "SET", "SYS", "DOC", "SEG"); }
    else { die "[ERROR] unknown granularity <", $config->{G}, ">!\n"; }
    my @header;
    foreach my $metric (@sorted_metrics) { push(@header, Common::trunk_string($metric, $Common::METRIC_NAME_LENGTH)); }
    print $head, " ", join(" ", @header), "\n";

    my $length = length($head);

    $length += ($Common::METRIC_NAME_LENGTH + 1) * scalar(@{$rsorted_metrics});

    Common::print_hline('=', $length);
}


sub print_system_scores_MMATRIX {
    #description _ print scores for a given system according to a given metric
    #param1  _ configuration
    #param2  _ hash of scores (outside QARLA)
    #param3  _ system name
    #param4  _ list of metrics
    #param5  _ reference name

    my $config = shift;
    my $hOQ = shift;
    my $system = shift;
    my $rsorted_metrics = shift;
    my $ref = shift;
	 
    my $doALL = (scalar(keys %{$config->{segments}}) == 0);  # if no segments are specified, print all

    my $S0 = $config->{systems}->[0];
    my $setid = $config->{IDX}->{$S0}->[0]->[0];

    my $sysid = $config->{IDX}->{$system}->[1]->[2];

    if (($config->{G} eq $Common::G_SYS) or ($config->{G} eq $Common::G_ALL)) { # SYSTEM SCORE
       my @scores;
       foreach my $metric (@{$rsorted_metrics}) {
          push(@scores, Common::trunk_number($hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref}, $Common::METRIC_NAME_LENGTH, $config->{float_precision}));
       }
       printf "%-".$config->{setid_length}."s %-".$config->{sysid_length}."s %s\n", $setid, $sysid, join(" ", @scores);
    }

    if (($config->{G} eq $Common::G_DOC) or ($config->{G} eq $Common::G_ALL)) { # DOCUMENT SCORES
       my $ldocids = NISTXML::get_docid_list($config->{IDX}->{$system});      
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_DOC}}); $i++) {
          my @scores;
          my $docid = $ldocids->[$i];
          foreach my $metric (@{$rsorted_metrics}) {
             push(@scores, Common::trunk_number($hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref}, $Common::METRIC_NAME_LENGTH, $config->{float_precision}));
          }
          printf "%-".$config->{setid_length}."s %-".$config->{sysid_length}."s %-".$config->{docid_length}."s %s\n", $setid, $sysid, $docid, join(" ", @scores);
       }
    }
    
    if (($config->{G} eq $Common::G_SEG) or ($config->{G} eq $Common::G_ALL)) { # SEGMENT SCORES
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_SEG}}); $i++) {
       	  if (exists($config->{segments}->{$i + 1}) or $doALL) {
             my $docid = $config->{IDX}->{$system}->[$i + 1]->[0];
             my $segid = $config->{IDX}->{$system}->[$i + 1]->[3];
             my @scores;
             foreach my $metric (@{$rsorted_metrics}) {
                push(@scores, Common::trunk_number($hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref}, $Common::METRIC_NAME_LENGTH, $config->{float_precision}));
             }
             printf "%-".$config->{setid_length}."s %-".$config->{sysid_length}."s %-".$config->{docid_length}."s %-".$config->{segid_length}."s %s\n", $setid, $sysid, $docid, $segid, join(" ", @scores);
       	  }
       }
    }
}



sub print_scores_MMATRIX {
    #description _ print metric scores in MMATRIX format (on a metric basis)
    #param1  _ configuration
    #param2  _ hash of scores

    my $config = shift;
    my $hOQ = shift;

	 #list of metrics
    my @sorted_metrics = get_sorted_metrics($config);    
    
	 #list of systems and references 
	 my @systems = get_sorted_systems($config);
    my $REF = join("_", sort @{$config->{references}});

    Metrics::print_MMATRIX_header($config, \@sorted_metrics);
    
	 Metrics::compute_metrics_combination( $config, $REF, \@systems, \@sorted_metrics, $hOQ );
    
    foreach my $system (@systems) { # systems
       Metrics::print_system_scores_MMATRIX($config, $hOQ, $system, \@sorted_metrics, $REF);
    }
    if ($config->{do_refs}) {
       foreach my $ref1 (sort @{$config->{references}}) { # references
          my @all_other_refs;
          foreach my $ref2 (@{$config->{references}}) { if ($ref1 ne $ref2) { push(@all_other_refs, $ref2); } }
          if (scalar(@all_other_refs)) {
             $REF = join("_", sort @all_other_refs);
             Metrics::print_system_scores_MMATRIX($config, $hOQ, $ref1, \@sorted_metrics, $REF);
          }
       }
    }
}

# *************************************************************************************
# *************************************************************************************

sub get_seg_doc_sys_scores {
    #description _ returns segment, document and system scores, given an index structure which
    #              contains information on the number of segments per document 
    #              if scores are segment-level:
    #                 * doc scores are averaged over documents
    #                 * sys score is averaged over documents
    #param1  _ segment/doc scores
    #param2  _ document-level (1) or segment-level (2) scores
    #param3  _ index structure
	
    my $scores = shift;
    my $DO_doc = shift;
    my $idx = shift;

    my @D_scores;
    my @S_scores;
    
    my $doc_score = 0;
    my $sum = undef;
    my $n = 0;
    my $n_doc = 0;
    my $docid = "";

    my $sys_score = 0;
    my $i = 1;
    while ($i < scalar@$idx) {
       if ($DO_doc) { # doc-level scores
       	  if ($idx->[$i]->[0] ne $docid) { # NEW DOCUMENT
       	     push(@D_scores, $scores->[$n_doc]);
             $sys_score += $scores->[$n_doc];
             $docid = $idx->[$i]->[0];
       	     $n_doc++;
       	  }
       	  push(@S_scores, $scores->[$n_doc - 1]);
       }
       else { # segment-level scores
       	  if ($idx->[$i]->[0] ne $docid) { # NEW DOCUMENT
             if (defined($sum)) {
                push(@D_scores, $sum / $n);
                $sys_score += $sum / $n;
             }
             $docid = $idx->[$i]->[0];
       	     $n_doc++;
             $sum = 0;
             $n = 0;
          }
          my $x = 0;
          if (defined($scores->[$i - 1])) { $x = $scores->[$i - 1]; }
          push(@S_scores, $x);
          $sum += $x;
          $n++;
       }
       $i++;
    }
	
    #last document (only if segment-level scores)
    if (!$DO_doc) {
       if (defined($sum)) { push(@D_scores, $sum / $n); $sys_score += $sum / $n; }
    }

    $sys_score /= $n_doc;

    return ($sys_score, \@D_scores, \@S_scores);	
}
		          
sub get_seg_doc_sys_scores_DOC {
    #description _ returns segment, document and system scores, given an index structure which
    #              contains information on the number of segments per document 
    #              if scores are segment-level:
    #                 * doc scores are averaged over documents
    #                 * sys score is averaged over documents
    #param1  _ segment/doc scores
    #param2  _ document-level (1) or segment-level (2) scores
    #param3  _ index structure
	
    my $scores = shift;
    my $DO_doc = shift;
    my $idx = shift;

    my @D_scores;
    my @S_scores;
    
    my $doc_score = 0;
    my $sum = undef;
    my $n = 0;
    my $n_doc = 0;
    my $docid = "";

    my $sys_score = 0;
    my $i = 1;
    my $doc_start_offset = 0;
    while ($i < scalar@$idx) {
       if ($DO_doc) { # doc-level scores
       	  if ($idx->[$i]->[0] ne $docid) { # NEW DOCUMENT
       	     push(@D_scores, $scores->[$n_doc]);
             $sys_score += $scores->[$n_doc];
             $docid = $idx->[$i]->[0];
       	     $n_doc++;
       	  }
       	  push(@S_scores, $scores->[$n_doc - 1]);
       }
       else { # segment-level scores
       	  if ($idx->[$i]->[0] ne $docid) { # NEW DOCUMENT
             if (defined($sum)) {
                push(@D_scores, $sum / $n);
                $sys_score += $sum / $n;
                for (my $j = $doc_start_offset; $j < $i; $j++) { $S_scores[$j] = $sum / $n; }
             }
             $doc_start_offset = $i;
             $docid = $idx->[$i]->[0];
       	     $n_doc++;
             $sum = 0;
             $n = 0;
          }
          my $x = 0;
          if (defined($scores->[$i - 1])) { $x = $scores->[$i - 1]; }
          #push(@S_scores, $x);
          $sum += $x;
          $n++;
       }
       $i++;
    }
	
    #last document (only if segment-level scores)
    if (!$DO_doc) {
       if (defined($sum)) {
       	  push(@D_scores, $sum / $n);
       	  $sys_score += $sum / $n;
          for (my $j = $doc_start_offset; $j < $i; $j++) { $S_scores[$j] = $sum / $n; }
       }
    }

    $sys_score /= $n_doc;

    return ($sys_score, \@D_scores, \@S_scores);	
}
		          
sub get_seg_doc_scores {
    #description _ returns segment and document scores, given an index structure which
    #              contains information on the number of segments per document 
    #param1  _ segment/doc scores
    #param2  _ document-level (1) or segment-level (2) scores
    #param3  _ index structure
	
    my $scores = shift;
    my $DO_doc = shift;
    my $idx = shift;

    my @D_scores;
    my @S_scores;
    
    my $doc_score = 0;
    my $sum = undef;
    my $n = 0;
    my $n_doc = 0;
    my $docid = "";

    my $i = 1;
    while ($i < scalar@$idx) {
       if ($DO_doc) { # doc-level scores
       	  if ($idx->[$i]->[0] ne $docid) { # NEW DOCUMENT
       	     push(@D_scores, $scores->[$n_doc]);
             $docid = $idx->[$i]->[0];
       	     $n_doc++;
       	  }
       	  push(@S_scores, $scores->[$n_doc - 1]);
       }
       else { # segment-level scores
       	  if ($idx->[$i]->[0] ne $docid) { # NEW DOCUMENT
             if (defined($sum)) { push(@D_scores, $sum / $n); }
             $docid = $idx->[$i]->[0];
             $sum = 0;
             $n = 0;
          }
          my $x = 0;
          if (defined($scores->[$i - 1])) { $x = $scores->[$i - 1]; }
          push(@S_scores, $x);
          $sum += $x;
          $n++;
       }
       $i++;
    }
	
    #last document (only if segment-level scores)
    if (!$DO_doc) { if (defined($sum)) { push(@D_scores, $sum / $n); } }
    
    return (\@D_scores, \@S_scores);	
}


sub find_max_metric_scores($$$$) {
    #description _ finds maximum score for each metric, so normalized scores for a given metric "i"
    #              can be later computed as are Xnorm(i) = X(i) / MAX(i)
    #              (max metric scores are stored onto the configuration object)
    #param1  _ configuration
    #param2  _ system set
    #param3  _ reference set
    #param4  _ hash of scores

    my $config = shift;
    my $systems = shift;
    my $references = shift;
	 my $hOQ = shift;
	 
    my $ref = join("_", sort @{$references});

    foreach my $metric (sort @{$config->{metrics}}) {
    	 my $ref_tmp = $ref;
    	 #if ( Common::isSourceFamily($metric) ){ $ref_tmp = Common::metricFamily($metric); }
       #maximums
       if (!exists($config->{max_score}->{$Common::G_SYS}->{$metric})) { $config->{max_score}->{$Common::G_SYS}->{$metric} = 0; }
       if (!exists($config->{max_score}->{$Common::G_DOC}->{$metric})) { $config->{max_score}->{$Common::G_DOC}->{$metric} = 0; }
       if (!exists($config->{max_score}->{$Common::G_SEG}->{$metric})) { $config->{max_score}->{$Common::G_SEG}->{$metric} = 0; }
       #absolute maximums
       if (!exists($config->{min_score}->{$Common::G_SYS}->{$metric})) { $config->{min_score}->{$Common::G_SYS}->{$metric} = 0; }
       if (!exists($config->{min_score}->{$Common::G_DOC}->{$metric})) { $config->{min_score}->{$Common::G_DOC}->{$metric} = 0; }
       if (!exists($config->{min_score}->{$Common::G_SEG}->{$metric})) { $config->{min_score}->{$Common::G_SEG}->{$metric} = 0; }
       foreach my $system (sort @{$systems}) {
          IQXML::read_report($system, $ref_tmp, $metric, $hOQ, $config->{segments}, $config->{G}, $config->{verbose});
          if (($config->{G} eq $Common::G_SYS) or ($config->{G} eq $Common::G_ALL)) {
             if ($hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref_tmp} < $config->{min_score}->{$Common::G_SYS}->{$metric}) {
                $config->{min_score}->{$Common::G_SYS}->{$metric} = $hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref_tmp};
             }
             if ($hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref_tmp} > $config->{max_score}->{$Common::G_SYS}->{$metric}) {
                $config->{max_score}->{$Common::G_SYS}->{$metric} = $hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref_tmp};
             }
          }
          if (($config->{G} eq $Common::G_DOC) or ($config->{G} eq $Common::G_ALL)) {
             for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_DOC}}); $i++) {
                if ($hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref_tmp} < $config->{min_score}->{$Common::G_DOC}->{$metric}) {
                   $config->{min_score}->{$Common::G_DOC}->{$metric} = $hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref_tmp};
                }
                if ($hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref_tmp} > $config->{max_score}->{$Common::G_DOC}->{$metric}) {
                   $config->{max_score}->{$Common::G_DOC}->{$metric} = $hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref_tmp};
                }
             }
          }
          if (($config->{G} eq $Common::G_SEG) or ($config->{G} eq $Common::G_ALL)) {
             for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_SEG}}); $i++) {
                if ($hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref_tmp} < $config->{min_score}->{$Common::G_SEG}->{$metric}) {
                   $config->{min_score}->{$Common::G_SEG}->{$metric} = $hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref_tmp};
                }
                if ($hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref_tmp} > $config->{max_score}->{$Common::G_SEG}->{$metric}) {
                   $config->{max_score}->{$Common::G_SEG}->{$metric} = $hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref_tmp};
                }
             }
          }
       }
    }
}

sub find_max_scores($$) {
    #description _ finds maximum score for each metric (), considering system translations by default.
    #              If "do_refs" reference ranslations are considered as well.
    #param1  _ configuration
    #param2  _ hash of scores

    my $config = shift;
	 my $hOQ = shift;
	
    find_max_metric_scores($config, $config->{systems}, $config->{references}, $hOQ);
    
    if ($config->{do_refs} and (scalar(@{$config->{references}}) > 1)) {
       foreach my $ref1 (sort @{$config->{references}}) { # references vs. all other references          
          my @all_other_refs;
          foreach my $ref2 (@{$config->{references}}) { if ($ref1 ne $ref2) { push(@all_other_refs, $ref2); } }
          find_max_metric_scores($config, [$ref1], \@all_other_refs, $hOQ);             	
       }
    }
}





sub do_greedy_optimization($$$$) {
    #description _ finds optimal metric combinations according to the given combination scheme and meta-evaluation criterion
    #param1  _ configuration
    #param2  _ combination scheme (so far it works only over 'single' and 'ulc')
    #param3  _ meta-evaluation criterion (so far it works only over correlation coefficients)
    #param4  _ granularity ("sys", "doc", "level")

    my $config = shift;
    my $scheme = shift;
    my $criterion = shift;
    my $G = shift;
    
    if ($config->{verbose}) {
       Common::print_hline_stderr('_', $Common::HLINE_LENGTH);
       print STDERR "Finding sub-optimal metric set [scheme = $scheme : criterion = $criterion]...\n";
       print STDERR "(1) computing individual metric $criterion\n";
    }

    my $schemes = {$scheme => 1};

    #(1) compute correlation coefficient for each individual metric
    my $hR = MetaMetrics::metaeval($config, $criterion, $G, {$Common::S_SINGLE => 1}, $Common::CI_NONE, $config->{verbose});

    #(2) sort metrics according to their correlation
    if ($config->{verbose}) {
       print STDERR "(2) Sorting metrics according to their $criterion\n";
    }
    MetaMetrics::metaprint($config, $criterion, $schemes, $hR, $Common::CI_NONE, $Common::SORT_SCORE);
    
    #if ($scheme eq $Common::S_ULC) { delete $hR->{$ULC::ULC_NAME}; }
    #if ($scheme eq $Common::S_QUEEN) { delete $hR->{$QARLA::QUEEN_NAME}; }
    my @R_sorted = sort { $hR->{$b}->[0] <=> $hR->{$a}->[0] } keys %{$hR};

    my @SET;
    my $max_single = shift(@R_sorted);
    my $max_R = $hR->{$max_single}->[0];
    push(@SET, $max_single);
    if ($config->{verbose}) {
       print STDERR sprintf("iter %6d ", 0), "[$max_single] ";
       print STDERR "set = {$max_single}\n";
       print STDERR"---> $criterion = ", Common::trunk_number($max_R, $config->{float_length}, $config->{float_precision}), "\n";
    }
    
    #(3) process metrics in correlation order
    if (($scheme ne $Common::S_SINGLE) and ($max_R <1)) {
       if ($config->{verbose}) {
          print STDERR "(3) Processing metrics in order combining under $scheme\n";
       }
       my $i = 0;
       my $X = 0;
       #my $delta = 1;
       #while (($i < scalar(@R_sorted)) and ($delta >= $X)) {
       while ($i < scalar(@R_sorted)) {
          my $metric = $R_sorted[$i];
          if ($config->{verbose}) { print STDERR sprintf("iter %6d ", $i + 1), "[$metric] "; }
          push(@SET, $metric);
          if ($config->{verbose}) { print STDERR "set = {", join(", ", @SET), "}\n"; }
          my $combo = $config->{COMBO};
          $config->{COMBO} = \@SET;
          $hR = MetaMetrics::metaeval($config, $criterion, $G, $schemes, $Common::CI_NONE, 0);
          $config->{COMBO} = $combo;
          my $combo_metric;
          if ($scheme eq $Common::S_ULC) { $combo_metric = $ULC::ULC_NAME; }
          elsif ($scheme eq $Common::S_QUEEN) { $combo_metric = $QARLA::QUEEN_NAME; }
          my $R = $hR->{$combo_metric}->[0];
          if ($config->{verbose}) { print STDERR "---> $criterion = ", Common::trunk_number($R, $config->{float_length}, $config->{float_precision}),
                                                 " :: MAX_$criterion = ", Common::trunk_number($max_R, $config->{float_length}, $config->{float_precision}); }
          if ($R > $max_R) {
             #$delta = $R - $max_R;
             $max_R = $R;
             if ($config->{verbose}) { print STDERR "\t\t\t\t\t***** [ADDED] *****"; }
          }
          else { pop(@SET); }
          if ($config->{verbose}) { print STDERR "\n"; }
          $i++;
       }
    }

    return (\@SET, $max_R);   
}

# *************************************************************************************
# ******************************* PUBLIC METHODS **************************************
# *************************************************************************************

sub add_metrics {
    #description _ adds a given metric scores (reading from the associated XML report) into the given score structure
    #param1  _ metric scores (hash ref)
    #param2  _ target
    #param3  _ reference
    #param4  _ hash of metrics (input parameter)
    #param5  _ list of metrics (output parameter)
    #param6  _ level of granularity ('sys' for system; 'doc' for document; 'seg' for segment)
    #param7  _ verbosity (0/1)

    my $scores = shift;
    my $TGT = shift;
    my $REF = shift;
    my $hOQ = shift;
    my $M = shift;
    my $G = shift;
    my $verbose = shift;

    foreach my $m (sort keys %{$M}) {
       my $MSCORES = IQXML::read_score_list($TGT, $REF, $m, $G, $hOQ, $verbose);
       my $t = 0;
       while ($t < scalar(@{$MSCORES})) {
          $scores->[$t]->{$m} = $MSCORES->[$t];
	      $t++;
       }
    }
}

sub print_ULC_scores {
    #description _ print ULC scores in the given format
    #param1  _ configuration
    my $config = shift;

    $config->{G} = $Common::G_SEG;;
    $config->{O} = $Common::O_NIST;
    $config->{eval_schemes}->{$Common::S_ULC} = 1;
    do_eval($config);
}

sub do_scores {
    #description _ launches metric computation for all given systems
    #param1  _ configuration
    #param2  _ hash of scores
    #@return _ overall benchmark time (in secs)
	
    my $config = shift;
    my $hOQ = shift;

    $config->{parser} = undef;
    $config->{SRCparser} = undef;

    # --- create the tsearch if requested
    my $tsearch;
    if ($config->{tsearch} == 1 ){
        $tsearch = new TSDatabase($config->{testbedid}, $config->{IQ_config}, $Common::DATA_PATH, $config->{tools} );
    }
    # --- end creation of tsearch

    my $TIME = 0;   

    if (exists($config->{eval_schemes}->{$Common::S_SINGLE}) or
    exists($config->{metaeval_schemes}->{$Common::S_SINGLE}) or
    exists($config->{optimize_schemes}->{$Common::S_SINGLE}) or
    exists($config->{eval_schemes}->{$Common::S_ULC}) or
    exists($config->{metaeval_schemes}->{$Common::S_ULC}) or
    exists($config->{optimize_schemes}->{$Common::S_ULC})) {
       if ($config->{verbose}) { print STDERR "[METRICS] computing 'system vs. reference' scores (one vs. all)...\n"; }
       foreach my $sys (sort @{$config->{systems}}) { # systems vs. references
          my $time1 = new Benchmark;
          doMultiMetrics($config, $sys, $config->{Hsystems}->{$sys}, $config->{references}, $config->{Hrefs}, $hOQ);
          if (exists($config->{eval_schemes}->{$Common::S_QUEEN}) or
              exists($config->{metaeval_schemes}->{$Common::S_QUEEN}) or
              exists($config->{optimize_schemes}->{$Common::S_QUEEN})) {
             foreach my $ref (sort @{$config->{references}}) {
                doMultiMetrics($config, $sys, $config->{Hsystems}->{$sys}, [$ref], $config->{Hrefs}, $hOQ);
             }
          }
	  # --- tsearch insertion
	  if ($config->{tsearch} == 1 ){
	      my $REF = join("_", sort @{$config->{references}});
	      my $report_xml_path = "$Common::DATA_PATH/$Common::REPORTS/$sys/$REF/";
	      $tsearch->do_insert($sys, $report_xml_path);
	  }
	  # --- end tsearch insertion
          my $time2 = new Benchmark;
          my $time = Common::get_raw_benchmark($time1, $time2);
          $TIME += $time;
          if ($config->{do_time}) { print STDERR "t($sys) = $time\n"; }
       }
    }

    if (exists($config->{eval_schemes}->{$Common::S_QUEEN}) or
    exists($config->{metaeval_schemes}->{$Common::S_QUEEN}) or
    exists($config->{optimize_schemes}->{$Common::S_QUEEN})) {
       if ($config->{verbose}) { print STDERR "[METRICS] computing 'reference vs. reference' scores (pairwise)...\n"; }
       foreach my $ref1 (sort @{$config->{references}}) { # references vs. references
          my $time1 = new Benchmark;
          foreach my $ref2 (sort @{$config->{references}}) {
            if ($ref1 ne $ref2) { doMultiMetrics($config, $ref1, $config->{Hrefs}->{$ref1}, [$ref2], $config->{Hrefs}, $hOQ); }
          }
          my $time2 = new Benchmark;
          my $time = Common::get_raw_benchmark($time1, $time2);
          $TIME += $time;
          if ($config->{do_time}) { print STDERR "t($ref1) = $time\n"; }
       }
    }

    if ((scalar(@{$config->{references}}) > 1) and $config->{do_refs} or
       exists($config->{metaeval_criteria}->{$Common::C_KING}) or
       exists($config->{optimize_criteria}->{$Common::C_KING}) or
       exists($config->{metaeval_criteria}->{$Common::C_ORANGE}) or
       exists($config->{optimize_criteria}->{$Common::C_ORANGE})) {
       if ($config->{verbose}) { print STDERR "[METRICS] computing 'reference vs. reference' scores (one vs. all)...\n"; }
       foreach my $ref1 (sort @{$config->{references}}) { # references vs. all other references
          my $time1 = new Benchmark;
          my @all_other_refs;
          foreach my $ref2 (@{$config->{references}}) { if ($ref1 ne $ref2) { push(@all_other_refs, $ref2); } }
          if (scalar(@all_other_refs)) {
          	doMultiMetrics($config, $ref1, $config->{Hrefs}->{$ref1}, \@all_other_refs, $config->{Hrefs}, $hOQ);
          	if (exists($config->{metaeval_criteria}->{$Common::C_KING}) or
                exists($config->{optimize_criteria}->{$Common::C_KING}) or
                exists($config->{metaeval_criteria}->{$Common::C_ORANGE}) or
                exists($config->{optimize_criteria}->{$Common::C_ORANGE})) {
                foreach my $sys (sort @{$config->{systems}}) { # systems vs. all other references
                   doMultiMetrics($config, $sys, $config->{Hsystems}->{$sys}, \@all_other_refs, $config->{Hrefs}, $hOQ);
                }                	
             }
          }
          else { $config->{do_refs} = 0; } 
          
          # --- tsearch insertion
          if ($config->{tsearch} == 1 ){
            my $REF = join("_", sort @{@all_other_refs});
            my $report_xml_path = "$Common::DATA_PATH/$Common::REPORTS/$ref1/$REF/";
            $tsearch->do_insert($ref1, $report_xml_path);
          }
          # --- end tsearch insertion
          
          my $time2 = new Benchmark;
          my $time = Common::get_raw_benchmark($time1, $time2);
          $TIME += $time;
          if ($config->{do_time}) { print STDERR "t($ref1) = $time\n"; }
       }
    }       
	
    # --- finalize the tsearch
    if ($config->{tsearch} == 1 ){
        $tsearch->do_finalize();
    }
    # --- end finalize of tsearch

    if ($config->{do_time}) { print STDERR "TOTAL TIME = $TIME\n"; }

    # required for normalized ULC computation (it can be very slow!)
    if (exists($config->{eval_schemes}->{$Common::S_ULC}) or
        exists($config->{metaeval_schemes}->{$Common::S_ULC}) or
        exists($config->{optimize_schemes}->{$Common::S_ULC})) {
       if ($config->{verbose}) { print STDERR "[METRICS] finding max metric scores (for normalization)...\n"; }
       find_max_scores($config, $hOQ);
    }

    return $TIME;	
}

sub do_eval {
    #description _ compute and print metric scores in the given format
    #param1  _ configuration
    #param2  _ hash of scores

    my $config = shift;
    my $hOQ = shift;

    if (exists($config->{eval_schemes}->{$Common::S_SINGLE}) or
        exists($config->{eval_schemes}->{$Common::S_ULC}) or
        exists($config->{eval_schemes}->{$Common::S_QUEEN})) {

       my $format = $Common::O_DEFAULT;
       if (exists($config->{O})) { $format = $config->{O}; }

       if ($config->{O} ne $Common::O_NONE) {
          if ($config->{verbose}) { print STDERR "Printing evaluation report...\n"; }
          # NIST/WMT file format 
          if ($format eq $Common::O_NIST) { print_scores_NIST($config, $hOQ); }
          # score matrix on a metric basis (metric comparison)
          elsif ($format eq $Common::O_MMATRIX) { print_scores_MMATRIX($config, $hOQ); }
          # score matrix on a system basis (system comparison)
          elsif ($format eq $Common::O_SMATRIX) { print_scores_SMATRIX($config, $hOQ); }
          else { die "[ERROR] unknown output format <$format>!\n"; }
       }
    }   
}

sub do_metric_optimization($$$$) {
    #description _ finds optimal metric combinations according to the given combination scheme, meta-evaluation criterion and granularity
    #param1  _ configuration
    #param2  _ combination scheme (so far it works only over 'single' and 'ulc')
    #param3  _ meta-evaluation criterion (so far it works only over correlation coefficients)
    #param4  _ granularity ("sys", "doc", "level")

    my $config = shift;
    my $scheme = shift;
    my $criterion = shift;
    my $G = shift;

    my ($optimal_set, $max) = do_greedy_optimization($config, $scheme, $criterion, $G);
    print "MAX_$criterion = ", Common::trunk_number($max, $config->{float_length}, $config->{float_precision}), "\n";
    print "OPTIMAL_METRIC_SET_".$scheme."_".$criterion." = {", join(", ", @{$optimal_set}), "}\n";

}

sub do_optimization {
    #description _ finds optimal metric combinations according to the given parameters
    #param1  _ configuration
    #param2  _ optimization parameters --> [scheme, criterion]
 
    my $config = shift;
    my $opt_params = shift;

    for my $scheme (@{$config->{optimize_schemes_list}}) {
       for my $criterion (@{$config->{optimize_criteria_list}}) {
          if ($config->{G} eq $Common::G_ALL) {
             do_metric_optimization($config, $scheme, $criterion, $Common::G_SYS);
             do_metric_optimization($config, $scheme, $criterion, $Common::G_DOC);
             do_metric_optimization($config, $scheme, $criterion, $Common::G_SEG);
          }
          else {
             do_metric_optimization($config, $scheme, $criterion, $config->{G});
          }
       }
    }
}




sub do_alignments{
    #description _ launches alignments computation for all given systems
    #param1  _ configuration
    #@return _ overall benchmark time (in secs)
	
    my $config = shift;

    $config->{parser} = undef;
    $config->{SRCparser} = undef;
	 my $TIME = 0;
	 
	 if ( $config->{alignments} > 0 ) {
    	   
    	foreach my $sys (sort @{$config->{systems}}) { # systems
        my $time1 = new Benchmark;
        Align::doMultiAlign($config, $sys, $config->{Hsystems}->{$sys}, $config->{Hrefs});
        my $time2 = new Benchmark;
        my $time = Common::get_raw_benchmark($time1, $time2);
        $TIME += $time;
        if ($config->{do_time}) { print STDERR "t($sys) = $time\n"; }
     	}
     }
     return $TIME;	
}



sub do_metric_names {
    #description _ print metric names
    #param1  _ configuration

    my $config = shift;

    if ($config->{do_metric_names}) {
	Metrics::print_metric_names($config->{SRCLANG}, $config->{LANG});
    }
}



sub print_metric_names {
    #description _ print metric names
    #param1  _ source lang
    #param2  _ target lang
    
 
    my $srclang = shift;
    my $trglang = shift;

       Common::print_hline('-', $Common::HLINE_LENGTH);
       print "METRIC NAMES\n";
       Common::print_hline('-', $Common::HLINE_LENGTH);
       my @metrics = sort keys %{Metrics::load_metric_set($srclang, $trglang)};
       print scalar(@metrics), " metrics are available for language '", $trglang, "'\n\n";
       print "METRICS = { ", join(", ", @metrics), " }\n\n";
       my %metric_families;
       foreach my $m (@metrics) {
       	  my $family = $m;
       	  $family =~ s/^([^-]+)\-.*$/$1/g;
       	  $family =~ s/\-//g;
       	  $family =~ s/[a-z].*//g;
       	  $metric_families{$family}->{$m} = 1;
       }
       foreach my $family (sort keys %metric_families) {
       	   print "metrics_$family = { ", join(", ", sort keys %{$metric_families{$family}}), " }\n\n";
       }
}


sub do_system_names {
    #description _ print system names
    #param1  _ configuration
 
    my $config = shift;

    if ($config->{do_system_names}) {
       Common::print_hline('-', $Common::HLINE_LENGTH);
       print "SYSTEM NAMES\n";
       Common::print_hline('-', $Common::HLINE_LENGTH);
       print "system_set = { ", join(", ", sort keys %{$config->{Hsystems}}), " }\n";
    }
}

sub do_reference_names {
    #description _ print reference names
    #param1  _ configuration
 
    my $config = shift;

    if ($config->{do_reference_names}) {
       Common::print_hline('-', $Common::HLINE_LENGTH);
       print "REFERENCE NAMES\n";
       Common::print_hline('-', $Common::HLINE_LENGTH);
       print "reference_set = { ", join(", ", sort keys %{$config->{Hrefs}}), " }\n";
    }
}

# *************************************************************************************
# LEARNING
# *************************************************************************************


sub do_learning {
    #description _ learning of measure combination	
    #param1  _ configuration
 
    my $config = shift;

    if ($config->{learn_scheme} eq $Common::LEARN_PERCEPTRON) {
       if ($config->{verbose}) { printf STDERR "learning '%s'\n", $config->{learn_scheme}; }

       my $learner = new Learner($config);
       $learner->go($config->{min_dist}, $config->{n_epochs}, $config->{model}, $config->{verbose}); 
    }    
}

1;
