package NE;

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
use IO::File;
use Unicode::String;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::SP;
use IQ::Scoring::Overlap;
use IQ::Scoring::Metrics;

our ($NEEXT, $rNEeng, $rNEspacat, $BIOS);

$NE::NEEXT = "NE";
$NE::BIOS = "bios-1.1.0";

$NE::rLANG = { $Common::L_ENG => 'en', $Common::L_SPA => 'es' };

$NE::rNEeng = { "$NE::NEEXT-Oe(ANGLE_QUANTITY)" => 1, "$NE::NEEXT-Oe(DATE)" => 1,
	            "$NE::NEEXT-Oe(DISTANCE_QUANTITY)" => 1, "$NE::NEEXT-Oe(LANGUAGE)" => 1,
	            "$NE::NEEXT-Oe(LOC)" => 1, "$NE::NEEXT-Oe(METHOD)" => 1, "$NE::NEEXT-Oe(MISC)" => 1,
	            "$NE::NEEXT-Oe(MONEY)" => 1, "$NE::NEEXT-Oe(NUM)" => 1, "$NE::NEEXT-Oe(ORG)" => 1,
	            "$NE::NEEXT-Oe(PER)" => 1, "$NE::NEEXT-Oe(PERCENT)" => 1, "$NE::NEEXT-Oe(PROJECT)" => 1,
	            "$NE::NEEXT-Oe(SIZE_QUANTITY)" => 1, "$NE::NEEXT-Oe(SPEED_QUANTITY)" => 1,
	            "$NE::NEEXT-Oe(SYSTEM)" => 1, "$NE::NEEXT-Oe(TEMPERATURE_QUANTITY)" => 1,
	            "$NE::NEEXT-Oe(WEIGHT_QUANTITY)" => 1, "$NE::NEEXT-Oe(TIME)" => 1, "$NE::NEEXT-Oe(MEASURE)" => 1,
	            "$NE::NEEXT-Oe(O)" => 1, "$NE::NEEXT-Oe(*)" => 1, "$NE::NEEXT-Oe(**)" => 1,
	            "$NE::NEEXT-Me(ANGLE_QUANTITY)" => 1, "$NE::NEEXT-Me(DATE)" => 1,
	            "$NE::NEEXT-Me(DISTANCE_QUANTITY)" => 1, "$NE::NEEXT-Me(LANGUAGE)" => 1, "$NE::NEEXT-Me(LOC)" => 1,
	            "$NE::NEEXT-Me(METHOD)" => 1, "$NE::NEEXT-Me(MISC)" => 1, "$NE::NEEXT-Me(MONEY)" => 1,
	            "$NE::NEEXT-Me(NUM)" => 1, "$NE::NEEXT-Me(ORG)" => 1, "$NE::NEEXT-Me(PER)" => 1,
	            "$NE::NEEXT-Me(PERCENT)" => 1, "$NE::NEEXT-Me(PROJECT)" => 1, "$NE::NEEXT-Me(SIZE_QUANTITY)" => 1,
	            "$NE::NEEXT-Me(SPEED_QUANTITY)" => 1, "$NE::NEEXT-Me(SYSTEM)" => 1,
	            "$NE::NEEXT-Me(TEMPERATURE_QUANTITY)" => 1, "$NE::NEEXT-Me(WEIGHT_QUANTITY)" => 1,
	            "$NE::NEEXT-Me(TIME)" => 1, "$NE::NEEXT-Me(MEASURE)" => 1, "$NE::NEEXT-Me(*)" => 1 };

#PER LOC ORG MISC MONEY PERCENT DISTANCE_QUANTITY SPEED_QUANTITY TEMPERATURE_QUANTITY SIZE_QUANTITY WEIGHT_QUANTITY ANGLE_QUANTITY TIME MEASURE DATE

$NE::rNEengSmall = { "$NE::NEEXT-Oe(PER)" => 1, "$NE::NEEXT-Oe(LOC)" => 1, "$NE::NEEXT-Oe(ORG)" => 1,
	                 "$NE::NEEXT-Oe(MISC)" => 1, "$NE::NEEXT-Oe(NUM)" => 1, "$NE::NEEXT-Oe(DATE)" => 1,
	                 "$NE::NEEXT-Oe(O)" => 1, "$NE::NEEXT-Oe(*)" => 1, "$NE::NEEXT-Oe(**)" => 1,
	                 "$NE::NEEXT-Me(PER)" => 1, "$NE::NEEXT-Me(LOC)" => 1, "$NE::NEEXT-Me(ORG)" => 1,
	                 "$NE::NEEXT-Me(MISC)" => 1, "$NE::NEEXT-Me(NUM)" => 1, "$NE::NEEXT-Me(DATE)" => 1,
	                 "$NE::NEEXT-Me(*)" => 1 };

#$NE::rNEspacatSmall = { "$NE::NEEXT-Oe(PER)" => 1, "$NE::NEEXT-Oe(LOC)" => 1, "$NE::NEEXT-Oe(ORG)" => 1, "$NE::NEEXT-Oe(MISC)" => 1, "$NE::NEEXT-Oe(NUM)" => 1, "$NE::NEEXT-Oe(DATE)" => 1, "$NE::NEEXT-Oe(O)" => 1, "$NE::NEEXT-Oe(*)" => 1, "$NE::NEEXT-Oe(**)" => 1, "$NE::NEEXT-Me(PER)" => 1, "$NE::NEEXT-Me(LOC)" => 1, "$NE::NEEXT-Me(ORG)" => 1, "$NE::NEEXT-Me(MISC)" => 1, "$NE::NEEXT-Me(NUM)" => 1, "$NE::NEEXT-Me(DATE)" => 1, "$NE::NEEXT-Me(*)" => 1};

$NE::rNEspacat = { };

sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;
    if ($language eq $Common::L_ENG) { %metric_set = %{$NE::rNEeng}; }
    elsif  ($language eq $Common::L_SPA) { %metric_set = %{$NE::rNEspacat}; }
    elsif  ($language eq $Common::L_CAT) { %metric_set = %{$NE::rNEspacat}; }

    return \%metric_set;
}

sub SNT_extract_features {
   #description _ extracts features from a given NE-parsed sentence.
   #param1  _ sentence
   #@return _ sentence (+features)

   my $snt = shift;

   my %SNT;
   my $type = "";
   my @lne;
   foreach my $elem (@{$snt}) {
      my $word = $elem->[0];
      #my $pos = $elem->[1];
      #my $lemma = $elem->[2];    
      #my $chunk = $elem->[3];
      #my $ne = $elem->[4];
      my $ne = $elem->[scalar(@{$elem}) - 1];
      #bags-of-words ---------------
      my @NE = split("-", $ne);
      $SNT{bow}->{(scalar(@NE) == 1)? $NE[0] : $NE[1]}->{$word}++;
      #exact matches -----------------------
      if (($ne =~ /^B-.*/) or ($ne eq "O")) {
          if (scalar(@lne) and ($type ne "")) { $SNT{exact}->{$type}->{join(" ", @lne)}++; }
          $type = $NE[1];
          @lne = ();
          if ($ne =~ /^B-.*/) { push(@lne, $word); }
      }
      elsif ($ne =~ /^I-.*/) { push(@lne, $word); }
   }

   return \%SNT;
}

sub SNT_compute_overlap_scores {
   #description _ computes distances between a candidate and a reference sentence (+features)
   #param1 _ candidate sentence (+features)
   #param2 _ reference sentence (+features)
   #param3 _ language
   #param4 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $Tout = shift;
   my $Tref = shift;
   my $LANG = shift;
   my $LC = shift;

   my %SCORES;

   #NE::NEEXT-Me(*) ----------------------------------------------------------------------------------
   my $HITS = 0;    my $TOTAL = 0;
   my %F;
   foreach my $N (keys %{$Tout->{exact}}) { $F{$N} = 1; }
   foreach my $N (keys %{$Tref->{exact}}) { $F{$N} = 1; }
   foreach my $N (keys %F) {
      my ($hits, $total) = Overlap::compute_overlap($Tout->{exact}->{$N}, $Tref->{exact}->{$N}, $LC);
      $SCORES{"$NE::NEEXT-Me($N)"} = ($total == 0)? 0 : ($hits / $total);
      $HITS += $hits; $TOTAL += $total;
   }
   $SCORES{"$NE::NEEXT-Me(*)"} = ($TOTAL == 0)? 0 : ($HITS / $TOTAL);


   #NE::NEEXT-Oe(*) ----------------------------------------------------------------------------------
   $HITS = 0;       $TOTAL = 0;
   my $HITSb = 0;   my $TOTALb = 0;
   %F = ();
   foreach my $N (keys %{$Tout->{bow}}) { $F{$N} = 1; }
   foreach my $N (keys %{$Tref->{bow}}) { $F{$N} = 1; }
   foreach my $N (keys %F) {
      my ($hits, $total) = Overlap::compute_overlap($Tout->{bow}->{$N}, $Tref->{bow}->{$N}, $LC);
      $SCORES{"$NE::NEEXT-Oe($N)"} = ($total == 0)? 0 : ($hits / $total);
      $HITS += $hits; $TOTAL += $total;
      if ($N ne "O") { $HITSb += $hits; $TOTALb += $total; }
   }
   $SCORES{"$NE::NEEXT-Oe(*)"} = ($TOTALb == 0)? 0 : ($HITSb / $TOTALb);
   $SCORES{"$NE::NEEXT-Oe(**)"} = ($TOTAL == 0)? 0 : ($HITS / $TOTAL);

   return \%SCORES;
}

sub FILE_compute_overlap_metrics {
   #description _ computes NE scores (single reference)
   #param1 _ candidate list of parsed sentences (+features)
   #param2 _ reference list of parsed sentences (+features)
   #param3 _ language
   #param4 _ do_lower_case evaluation ( 1:yes -> case_insensitive  ::  0:no -> case_sensitive )

   my $FOUT = shift;
   my $FREF = shift;
   my $LANG = shift;
   my $LC = shift;

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
      $SCORES[$topic] = SNT_compute_overlap_scores($OUTSNT, $REFSNT, $LANG, $LC);
      #print Dumper $SCORES[$topic];
      $topic++;
   }

   return \@SCORES;
}

sub FILE_parse($$$$$$)
{
    #description _ responsible for NERC
    #              (WORD + PoS)  ->  (WORD + NE)
    #param1  _ input file
    #param2  _ parser object
    #param3  _ tools directory pathname
    #param4  _ parsing LANGUAGE 1
    #param5  _ case 1
    #param6  _ verbosity (0/1)

    my $input = shift;
    my $parser = shift;
    my $tools = shift;
    my $L = shift;
    my $C = shift;
    my $verbose = shift;

    my $wpfile = $input.".$SP::SPEXT.wp";
    my $wcfile = $input.".$SP::SPEXT.wc";
    my $wplfile = $input.".$SP::SPEXT.wpl";
    my $wpcfile = $input.".$SP::SPEXT.wpc";
    my $wplcfile = $input.".$SP::SPEXT.wplc";

    my $nercfile = $input.".$NE::NEEXT";
    #my $wpnercfile = $input.".$NE::NEEXT.wpn";
    my $wplcnercfile = $input.".$NE::NEEXT.wplcn";

    if (exists($NE::rLANG->{$L})) {
       if ((!(-e $wplcnercfile)) and (!(-e "$wplcnercfile.$Common::GZEXT"))) {
          #SP (shallow parsing)
          SP::FILE_parse($input, $parser, $tools, $L, $C, (($verbose > 0)? $verbose - 1 : 0));
          #NERC (named entitity recognition and classification)
          if (!(-e $nercfile)) {
             if (!(-e "$nercfile.$Common::GZEXT")) {
                if ((!(-e $wpcfile)) and (-e "$wpcfile.$Common::GZEXT")) { system("$Common::GUNZIP $wpcfile.$Common::GZEXT"); }
   	           Common::execute_or_die("cat $wpcfile | java -Dfile.encoding=UTF-8 -Xmx1024m -cp $tools/$BIOS/output/classes/:$tools/mill/output/classes:$tools/$BIOS/jars/maxent-2.3.0.jar:$tools/$BIOS/jars/trove.jar:$tools/$BIOS/jars/antlr-2.7.5.jar:$tools/$BIOS/jars/log4j.jar bios.nerc.Nerc --predict --namex=$tools/$BIOS/data/nerc/".$NE::rLANG->{$L}."/namex --numex=$tools/$BIOS/data/nerc/".$NE::rLANG->{$L}."/numex --model=conll.paum.".(($C eq $Common::CASE_CI)? "ci" : "cs").".model --type=paum --case-sensitive=".(($C eq $Common::CASE_CI)? "false" : "true")." --log4j=log4j.properties > $nercfile 2> /dev/null", "[ERROR] problems running BIOS...");

                system("$Common::GZIP $wpcfile");
             }
             else { system("$Common::GUNZIP $nercfile.$Common::GZEXT"); }
 	      }

          #merging tagging + chunking + nerc
          if ((!(-e $wplcfile)) and (-e "$wplcfile.$Common::GZEXT")) { system("$Common::GUNZIP $wplcfile.$Common::GZEXT"); }
          SP::FILE_merge_BIOS($wplcfile, $nercfile, $wplcnercfile);
          ##merging tagging + nerc
          #if ((!(-e $wpfile)) and (-e "$wpfile.$Common::GZEXT")) { system("$Common::GUNZIP $wpfile.$Common::GZEXT"); }
          #SP::FILE_merge_BIOS($wpfile, $nercfile, $wpnercfile);
          #system("$Common::GZIP $wpfile");
          system("$Common::GZIP $wplcfile");
          #system("$Common::GZIP $wpnercfile");
          #system("$Common::GZIP $nercfile");
          system("rm -f $nercfile");
       }
    }
    else { die "[NE] tool for <$L> unavailable!!!\n"; }
}

sub FILE_parse_and_read($$$$$$)
{
    #description _ responsible for NERC
    #              (WORD + PoS)  ->  (WORD + NE)
    #param1  _ input file
    #param2  _ parser object
    #param3  _ tools directory pathname
    #param4  _ language
    #param5  _ case
    #param6  _ verbosity (0/1)
    #@return _ list of (NE-)parsed sentences

    my $input = shift;
    my $parser = shift;
    my $tools = shift;
    my $L = shift;
    my $C = shift;
    my $verbose = shift;

    my $wplcnercfile = $input.".$NE::NEEXT.wplcn";

    FILE_parse($input, $parser, $tools, $L, $C, $verbose);

    my @FILE;
    if ((!(-e $wplcnercfile)) and (-e "$wplcnercfile.$Common::GZEXT")) { system("$Common::GUNZIP $wplcnercfile.$Common::GZEXT"); }

    open(AUX, "< $wplcnercfile") or die "couldn't open file: $wplcnercfile\n";
    #my $header = <AUX>;
    my $i = 0;
    while (my $line = <AUX>) {
       chomp($line);
       if ($line =~ /^$/) { $i++; }
       else {
  	      my @snt = split(" ", $line);
          push(@{$FILE[$i]}, \@snt);
       }
    }
    close(AUX);

    system("$Common::GZIP $wplcnercfile");

    return \@FILE;
}

sub create_NE_file($$$$$$) {
   #description _ creates a one-sentence per line PoS file, and returns its name
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)
   #@return _ NE file name

   my $input = shift;
   my $parser = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   my $wplcnercfile = $input.".$NE::NEEXT.wplcn";
   my $nefile = $input.".$NE::NEEXT.ne";
   
   if (!(-e $nefile)) {
   	  if (-e "$nefile.$Common::GZEXT") { system("$Common::GUNZIP $nefile.$Common::GZEXT"); }
   	  else {
         FILE_parse($input, $parser, $tools, $L, $C, $verbose);

         if ((!(-e $wplcnercfile)) and (-e "$wplcnercfile.$Common::GZEXT")) { system("$Common::GUNZIP $wplcnercfile.$Common::GZEXT"); }

         open(NE, "> $nefile") or die "couldn't open file: $nefile\n";
         open(WLPCNERC, "< $wplcnercfile") or die "couldn't open file: $wplcnercfile\n";
         my $i = 0;
         my @sentence;
         my $EMPTY = 1;
         while (my $line = <WLPCNERC>) {
            if ($line =~ /^$/) { # sentence separator
               if ($EMPTY) { # empty sentence
	              $EMPTY = 0;
               }
               else {
               	  print NE join(" ", @sentence), "\n";
                  @sentence = ();
                  $EMPTY = 1;
               }
            }
            else {
               chomp($line);
               my @l = split(" ", $line);
               if ($l[4] =~ /B-.*/) { my @NE = split("-", $l[4]); push(@sentence, $NE[1]); }
   	           $EMPTY = 0;
            }
         }
         close(WLPCNERC);
         close(NE);
         system("$Common::GZIP $wplcnercfile");
   	  }	
   }

   return $nefile;
}

sub doMultiNE {
   #description _ computes NE scores (multiple references)
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

   my $rF;
   if (($L eq $Common::L_SPA) or ($L eq $Common::L_CAT)) { $rF = $NE::rNEspacat; }
   else { $rF = $NE::rNEeng; }

   my $GO_ON = 0;
   foreach my $metric (keys %{$rF}) {
      if ($M->{$metric}) { $GO_ON = 1; }
   }

   if ($GO_ON) {
      if ($verbose == 1) { print STDERR "$NE::NEEXT.."; }

      my $DO_METRICS = $remakeREPORTS;
      if (!$DO_METRICS) {
         foreach my $metric (keys %{$rF}) {
            my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
            if ($M->{$metric} and !(-e $report_xml) and !(-e $report_xml.".$Common::GZEXT")) { $DO_METRICS = 1; }
         }
      }

      if ($DO_METRICS) {
         my $FDout = FILE_parse_and_read($out, $parser, $tools, $L, $C, $verbose);      	
         my @maxscores;

         foreach my $ref (keys %{$Href}) {
            my $FDref = FILE_parse_and_read($Href->{$ref}, $parser, $tools, $L, $C, $verbose);
            my $scores = FILE_compute_overlap_metrics($FDout, $FDref, $L, ($C ne $Common::CASE_CI));
            foreach my $metric (keys %{$rF}) {
               if ($M->{$metric}) {
                  my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 0);
                  my ($SYS, $SEGS) = Overlap::get_segment_scores($scores, $metric, 0); 
                  my $i = 0;
                  while ($i < scalar(@{$SEGS})) { #update max scores
                    if (defined($MAXSEGS->[$i])) {
                        if ($SEGS->[$i] > $MAXSEGS->[$i]) {
                            if (exists($scores->[$i]->{$metric})) {
                                $maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
  	  	            }
                        }
                     }
                     else { $maxscores[$i]->{$metric} = $scores->[$i]->{$metric}; }
                     $i++;
                  }
  	           }
	        }
	     }

         foreach my $metric (keys %{$rF}) {
            if ($M->{$metric}) {
               my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
               if ((!(-e $report_xml) and (!(-e $report_xml.".$Common::GZEXT"))) or $remakeREPORTS) {
                  #my ($SYS, $SEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 1);
                  my ($SYS, $SEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 2);
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
