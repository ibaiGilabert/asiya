package ESA;

# ------------------------------------------------------------------------

#Copyright (C) Meritxell Gonzàlez

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
use IQ::Scoring::Metrics;

our ($ESAEXT, $rESA, $TESA, $TESAdir, $TESAindex, $rLANG, $rLANG_ESA);

$NGRAM::EMPTY_ITEM = "0";

$ESA::ESAEXT    = "ESA";
$ESA::TESAdir   = "esa";

$ESA::TESA      = { 	"$ESA::ESAEXT-en" => "esa/SimilarityESAqe2.jar -l en", 
							"$ESA::ESAEXT-es" => "esa/SimilarityESAqe2.jar -l es", 
							"$ESA::ESAEXT-de" => "esa/SimilarityESAqe3.jar -l de", 
							"$ESA::ESAEXT-fr" => "esa/SimilarityESAqe59.jar -l fr" };

$ESA::TESA_java = { 	"$ESA::ESAEXT-en" => "java ", 
							"$ESA::ESAEXT-es" => "java ", 
							"$ESA::ESAEXT-de" => "java ", 
							"$ESA::ESAEXT-fr" => "/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java " };

$ESA::TESA_mem  = { 	"$ESA::ESAEXT-en" => " -Xms1024M -Xmx3072M ", 
							"$ESA::ESAEXT-es" => " -Xms1G -Xmx3G", 
							"$ESA::ESAEXT-de" => " -Xmx1G -Xmx3G", 
							"$ESA::ESAEXT-fr" => " -Xmx1G -Xmx3G" };

$ESA::TESAindex = { 	"$ESA::ESAEXT-en" => "esa/esaindex", 
							"$ESA::ESAEXT-es" => "esa/es.index2", 
							"$ESA::ESAEXT-de" => "esa/de.index", 
							"$ESA::ESAEXT-fr" => "esa/fr.index" };


$ESA::rESA = { "$ESA::ESAEXT-en" => 1, "$ESA::ESAEXT-es" => 1, "$ESA::ESAEXT-de" => 1, "$ESA::ESAEXT-fr" => 1 };

$ESA::rLANG = { $Common::L_ENG => {
                     "$ESA::ESAEXT-en" => 1},
                $Common::L_SPA => { 
                     "$ESA::ESAEXT-en" => 1,
                     "$ESA::ESAEXT-es" => 1},
                $Common::L_CAT => { 
                     "$ESA::ESAEXT-en" => 1,
                     "$ESA::ESAEXT-es" => 1},
                $Common::L_GER => { 
                     "$ESA::ESAEXT-en" => 1,
                     "$ESA::ESAEXT-de" => 1},
                $Common::L_FRN => { 
                     "$ESA::ESAEXT-en" => 1,
		     				"$ESA::ESAEXT-fr" => 1},
                $Common::L_CZE => { 
                     "$ESA::ESAEXT-en" => 1}};


sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1 _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;

    if (exists($ESA::rLANG->{$language})) { 

      my %tmp = %{$ESA::rLANG}; 
      %metric_set = %{$tmp{$language}};
   }
    return \%metric_set;
}
		          
	

sub ESA_f_create_doc {
    #description _ creation of a RAW evaluation document 
    #param1  _ input file
    #param2  _ output file
    #param3  _ case
    #param4  _ verbose (0/1)

    my $input = shift;
    my $output = shift;
    my $case = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING <$input> for ESA parsing...\n"; }

    if (-e $input) {
       if ($verbose > 1) { print STDERR "reading <$input>\n"; }

       my $IN = new IO::File("< $input") or
                die "Couldn't open input file: $input\n";

       my $OUT = new IO::File("> $output");

       while (defined (my $line = $IN->getline())) {
          chomp($line);
          $line =~ s/\r//;
          $line =~ s/ +$//;
          
          if ($line =~ /^$/) { $line = $NGRAM::EMPTY_ITEM; }
          elsif ($line =~ /^[!?.]+$/) { $line = $NGRAM::EMPTY_ITEM; }

          if ($case eq $Common::CASE_CI) {
            $line = lc($line);
          }
          print $OUT lc($line)."\n"; 
       }
       
       $IN->close();    
       $OUT->close();    
    }
    else { print STDERR "\n[ERROR] UNAVAILABLEfile <$input>!!!\n"; }
}


sub read_ESA_segments {
   #description _ read ESA value from report file (for all segments)
   #param1  _ report filename
   #@return _ gtm F1 score list

   my $report = shift;

   my @aESA;

   open(AUX, "< $report") or die "couldn't open file: $report\n";

   my $aux = <AUX>; # remove the header

   while ($aux = <AUX>) {
      chomp($aux);
      push(@aESA, $aux);
   }
   close(AUX);

   return \@aESA;
}


sub computeESA($$$$$$$) {
   #description _ 
   #param1 _ candidate file
   #param2 _ candidate file
   #param3 _ reference file
   #param4 _ tool
   #param5 _ case
   #param6 _ verbosity (0/1)

   my $metric = shift;
   my $out = shift;
   my $ref = shift;
   my $tools = shift;
   my $case = shift;
   my $lang = shift;
   my $verbose = shift;


#   my $outRND = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$ESAEXT.$Common::SYSEXT";
#   my $refRND = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$ESAEXT.$Common::REFEXT";

   my $outRND = $out.".".$ESAEXT.".".$case;
   my $refRND = $ref.".".$ESAEXT.".".$case;


	ESA_f_create_doc ($out,$outRND,$case,$verbose);
	ESA_f_create_doc ($ref,$refRND,$case,$verbose);
	
   if ( -e "$outRND.esarep.obj.gz" ){ system("gunzip $outRND.esarep.obj.gz");   }
   if ( -e "$refRND.esarep.obj.gz" ){ system("gunzip $refRND.esarep.obj.gz");   }
	
   my $reportESA = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$ESAEXT.$Common::REPORTEXT";

   if ($verbose > 1) { print STDERR "building $reportESA...\n"; }

   my $pwd = readpipe("pwd");
   chomp($pwd);
   if ( $outRND =~ m/\.\// ) {
      $outRND =~ s/\.\///;
      $outRND = "$pwd/$outRND";
   }
   if ( $refRND =~ m/\.\// ) {
      $refRND =~ s/\.\///;
      $refRND = "$pwd/$refRND";
   }
   if ( $reportESA =~ m/\.\// ) {
      $reportESA =~ s/\.\///;
      $reportESA = "$pwd/$reportESA";
   }


   my $mem_options = "$ESA::TESA_mem->{$metric}";  # " -Xms8G -Xmx16G ";
   my $toolESA = $ESA::TESA_java->{$metric} ." -Dfile.encoding=UTF-8 $mem_options -jar $tools/$ESA::TESA->{$metric}";
   #print STDERR "          cd $tools/$ESA::TESAdir; $toolESA  -w $tools/$ESA::TESAindex->{$metric} -i $outRND -j $refRND -o $reportESA 2>$reportESA.err; cd $pwd;";
   Common::execute_or_die("cd $tools/$ESA::TESAdir; $toolESA  -w $tools/$ESA::TESAindex->{$metric} -i $outRND -j $refRND -o $reportESA 2>$reportESA.err; cd $pwd;", "[ERROR] problems running ESA...");
   
   my $SEG = read_ESA_segments($reportESA);

   system("rm -f $refRND");
   system("gzip $refRND.esarep.obj");
   system("rm -f $outRND");
   system("gzip $outRND.esarep.obj");
   system("rm -f $reportESA");
   system("rm -f $reportESA.err");

   return $SEG;

}



sub computeMultiESA {
   #description _ computes ESA score (multiple references)
   #param1 _ candidate file
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ target case (cs/ci)
   #param5 _ tools
   #param6 _ verbosity (0/1)

   my $metric = shift;
   my $out = shift;
   my $Href = shift;
   my $case = shift;
   my $tools = shift;
   my $lang = shift;
   my $verbose = shift;

   my @MAXSEGS;
   foreach my $ref (keys %{$Href}) {
      my $hSEGS = ESA::computeESA($metric,$out, $Href->{$ref}, $tools, $case, $lang, $verbose);

       my $i = 0;
       while ($i < scalar(@$hSEGS)) { #update max scores
          if (defined($MAXSEGS[$i])) {
             if ($hSEGS->[$i] > $MAXSEGS[$i]) { $MAXSEGS[$i] = $hSEGS->[$i]; }
          }
          else { $MAXSEGS[$i] = $hSEGS->[$i]; }
          $i++;
       }
   }

    my $maxsys = 0; my $N = 0;
    foreach my $seg (@MAXSEGS) {
       $maxsys += $seg;
       $N++;
    }
    $maxsys = Common::safe_division($maxsys, $N);

   return($maxsys, \@MAXSEGS);
}

sub doMultiESA {
   #description _ computes ESA score (multiple references)
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
   my $IDX = $config->{IDX};                    # sys-doc-seg index structure
   my $srcL = $config->{SRCLANG};                     # language
   my $trgL = $config->{LANG};                     # case
   my $verbose = $config->{verbose};            # verbosity (0/1)
   
   my $GO = 0; my $i = 0;
   my @mESA = keys %{ESA::metric_set($trgL)};

   while (($i < scalar(@mESA)) and (!$GO)) { if (exists($M->{$mESA[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$ESA::ESAEXT.."; }
      foreach my $metric ( @mESA) {
         my $reportESAxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$metric.$Common::XMLEXT";
         if ( (!(-e $reportESAxml) and !(-e $reportESAxml.".$Common::GZEXT")) or $remakeREPORTS) {
            my ($SYS,$SEGS) = ESA::computeMultiESA($metric,$out, $Href, $config->{CASE}, $tools, $trgL, $verbose);
            my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, $prefix.$metric, $SYS, $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores($prefix.$metric, $TGT, $REF, $SYS, $doc_scores, $seg_scores, $hOQ);
         }
      }
   }
}

1;
