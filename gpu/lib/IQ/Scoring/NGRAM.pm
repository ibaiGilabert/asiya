package NGRAM;

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
use File::Basename;
use File::Copy;

use utf8;
use open qw(:std :utf8);
use warnings;
use warnings qw(FATAL utf8);

our ($NGRAMEXT, $TNGRAM, $TNGRAMdir, $rNGRAM, $EMPTY_ITEM);

$NGRAM::EMPTY_ITEM = "*";

$NGRAM::NGRAMSRC = "src";
$NGRAM::NGRAMREF = "ref";

$NGRAM::NGRAMEXT = "NGRAM";
$NGRAM::CENGRAMEXT = "CENGRAM";
$NGRAM::TNGRAM = "ComputeSimilaritiesQE.jar";
$NGRAM::TNGRAMdir = "lengthmodel";
$NGRAM::TRANSLITERATOR = "transliterator/Transliterator.jar";

# las de tokens son para reference-target
# las de caracteres son para source-target
# las de pseudo-cognados son para source-target

$NGRAM::rNGRAM = {  "$NGRAM::NGRAMEXT-cosTok2ngrams" => 1 ,  "$NGRAM::NGRAMEXT-cosTok3ngrams" => 1 ,
                    "$NGRAM::NGRAMEXT-cosTok4ngrams" => 1 ,  "$NGRAM::NGRAMEXT-cosTok5ngrams" => 1 ,
                    "$NGRAM::NGRAMEXT-jacTok2ngrams" => 1 ,
                    "$NGRAM::NGRAMEXT-jacTok3ngrams" => 1 ,  "$NGRAM::NGRAMEXT-jacTok4ngrams" => 1 ,
                    "$NGRAM::NGRAMEXT-jacTok5ngrams" => 1 
};

$NGRAM::rCENGRAM = {"$NGRAM::NGRAMEXT-cosChar2ngrams" => 1 , "$NGRAM::NGRAMEXT-cosChar3ngrams" => 1 ,
                    "$NGRAM::NGRAMEXT-cosChar4ngrams" => 1 , "$NGRAM::NGRAMEXT-cosChar5ngrams" => 1 ,
                    "$NGRAM::NGRAMEXT-jacChar2ngrams" => 1 , "$NGRAM::NGRAMEXT-jacChar3ngrams" => 1 ,
                    "$NGRAM::NGRAMEXT-jacChar4ngrams" => 1 , "$NGRAM::NGRAMEXT-jacChar5ngrams" => 1 ,
                    "$NGRAM::NGRAMEXT-jacCognates" => 1 ,  "$NGRAM::NGRAMEXT-lenratio" => 1 
};


sub metric_set {
    #description _ returns the set of available metrics for the given language
    #@return _ metric set structure (hash ref)
    
    my %newHash = (%{$NGRAM::rNGRAM}, %{$NGRAM::rCENGRAM}); 
    return \%newHash;
}
		          

sub NGRAM_f_create_doc {
    #description _ creation of a RAW evaluation document 
    #param1  _ input file
    #param2  _ output file
    #param3  _ case
    #param4  _ verbose (0/1)

    my $input = shift;
    my $output = shift;
    my $case = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING <$input> for NGRAM parsing...\n"; }

    if (-e $input) {
       if ($verbose > 1) { print STDERR "reading <$input>\n"; }

       open(my $IN, "<:encoding(UTF-8)", "$input") || die "Couldn't open input file: $input\n";

       open(my $OUT, ">:encoding(UTF-8)", "$output") || die "Couldn't open output file: $output\n";

       while (defined (my $line = $IN->getline())) {
          chomp($line);
          $line =~ s/\r//;
          $line =~ s/ +$//;
          
          if ($line =~ /^$/) { $line = $NGRAM::EMPTY_ITEM." "."."; }
          elsif ($line =~ /^[!?.]$/) { $line = $NGRAM::EMPTY_ITEM." ".$line; }
          
          if ($case eq $Common::CASE_CI) {
            $line = lc($line);
          }
          print $OUT lc($line)."\n"; 
       }
       
       $IN->close();    
       $OUT->close();    
    }
    else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }
}


sub read_NGRAM_segments {
   #description _ read NGRAM value from report file (for all segments)
   #param1  _ report filename
   #param2  _ opt ref / src
   #@return _ gtm F1 score list

   my $report = shift;
	my $opt = shift;
	
   my %hngram;

   open(AUX, "< $report") or die "couldn't open file: $report\n";
	#SRC: 1_cosChar2ngrams,2_cosChar3ngrams,3_cosChar4ngrams,4_cosChar5ngrams,*,*,*,*,9_jacChar2ngrams,10_jacChar3ngrams,11_jacChar4ngrams,12_jacChar5ngrams,13_jacCognates,*,*,*,*,*,18_lenratio
	#REF: *,*,*,*,5_cosTok2ngrams,6_cosTok3ngrams,7_cosTok4ngrams,8_cosTok5ngrams,*,*,*,*,*,14_jacTok2ngrams,15_jacTok3ngrams,16_jacTok4ngrams,17_jacTok5ngrams,*
	
   my $aux = <AUX>;
   chomp($aux);

   my @lheaders = split( /,/ , $aux);
   while ($aux = <AUX>) {
      chomp($aux);
      my @laux = split(/,/, $aux);
      for(my $count = 0; $count < scalar(@laux); $count++) {
        my $header = $lheaders[$count];
	my $value = ($laux[$count] ne "NaN") ? $laux[$count] : 0;
        if ( ($opt eq $NGRAM::NGRAMREF) && ($header =~ m/Tok/)) {
	        push(@{$hngram{$header}}, $value);
	     }
        elsif ( $opt eq $NGRAM::NGRAMSRC && ($header =~ m/Char/ || $header =~ m/Cognates/ || $header =~ m/lenratio/) ){
	        push(@{$hngram{$header}}, $value);
	     }
      }
   }
   close(AUX);

   return \%hngram;
}


sub computeNGRAM($$$$$$$$$) {
   #description _ 
   #param1 _ src / ref
   #param2 _ candidate file
   #param3 _ reference file
   #param4 _ tool
   #param5 _ case
   #param6 _ srclang
   #param7 _ trglang
   #param8 _ verbosity (0/1)
   #param9 _ issrcbased (0/1)

   my $opt = shift;
   my $out = shift;
   my $ref = shift;
   my $tools = shift;
   my $case = shift;
   my $srclang = shift;
   my $trglang = shift;
   my $verbose = shift;
   my $issrcbased = shift;

   my $outRND = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$NGRAMEXT.$Common::SYSEXT";
   my $refRND = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$NGRAMEXT.$Common::REFEXT";

   NGRAM_f_create_doc ($out,$outRND,$case,$verbose);
   NGRAM_f_create_doc ($ref,$refRND,$case,$verbose);

   my $reportNGRAM = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$NGRAMEXT.$Common::REPORTEXT";

   if ($verbose > 1) { print STDERR "building $reportNGRAM...\n"; }

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
   if ( $reportNGRAM =~ m/\.\// ) {
      $reportNGRAM =~ s/\.\///;
      $reportNGRAM = "$pwd/$reportNGRAM";
   }

   #if language is russian, first transliterate
   if ( $trglang eq $Common::L_RUS ){
       my $transliterator = "/usr/local/jdk1.7.0/bin/java -Xms1024M -Xmx1024M -Dfile.encoding=UTF-8 -jar $tools/$NGRAM::TRANSLITERATOR -l ru -i $outRND";
       Common::execute_or_die("$transliterator > /dev/null 2> /dev/null", "[ERROR] problems running TRANSLITERATOR...");
       my $transname = dirname($outRND)."/trans.".basename($outRND);
       move($transname,$outRND);
   }


   if ( ($trglang eq $Common::L_RUS and $issrcbased == 0) ||
        ($srclang eq $Common::L_RUS and $issrcbased == 1) ){
       my $transliterator = "/usr/local/jdk1.7.0/bin/java -Xms1024M -Xmx1024M -Dfile.encoding=UTF-8 -jar $tools/$NGRAM::TRANSLITERATOR -l ru -i $refRND";
       Common::execute_or_die("$transliterator > /dev/null 2> /dev/null", "[ERROR] problems running TRANSLITERATOR..."); 
       my $transname = dirname($refRND)."/trans.".basename($refRND);
       move($transname,$refRND);
   }

   my $mem_options = " -Xms1024M -Xmx3072M ";
   my $toolNGRAM = "java -Dfile.encoding=UTF-8 $mem_options -jar $tools/$NGRAM::TNGRAMdir/$NGRAM::TNGRAM";
   #print STDERR         "\ncd $tools/$NGRAM::TNGRAMdir; $toolNGRAM -i $outRND -j $refRND -o $reportNGRAM; cd $pwd\n";
   Common::execute_or_die("cd $tools/$NGRAM::TNGRAMdir; $toolNGRAM -i $outRND -j $refRND -o $reportNGRAM > /dev/null 2> /dev/null ; cd $pwd;", "[ERROR] problems running NGRAM...");

   my $SEG = read_NGRAM_segments($reportNGRAM,$opt);

   system("rm -f $refRND");
   system("rm -f $outRND");
   system("rm -f $reportNGRAM");

   return $SEG;

}




sub computeMultiNGRAM {
   #description _ computes NGRAM score (multiple references)
   #param1 _ "ref"/"src" options
   #param2 _ candidate file
   #param3 _ reference file(s) [hash reference]
   #param4 _ source file
   #param5 _ target case (cs/ci)
   #param6 _ src lang
   #param7 _ trg lang
   #param8 _ tools
   #param9 _ verbosity (0/1)
   #param10 _ is_vs_source (0/1)

   my $opt = shift;
   my $out = shift;
   my $Href = shift;
   my $src = shift;
   my $case = shift;
   my $srclang = shift;
   my $trglang = shift;
   my $tools = shift;
   my $verbose = shift;
   my $issrcbased = shift;


	my %MAXSEGS; my %MAXSYS;
	
	if ( $opt eq $NGRAM::NGRAMREF ){
		foreach my $ref (keys %{$Href}) {
		   my $hSEGS = NGRAM::computeNGRAM($NGRAM::NGRAMREF, $out, $Href->{$ref}, $tools, $case, $srclang, $trglang, $verbose, $issrcbased);
		   my %SEGS = %{$hSEGS};

		   foreach my $key (keys %SEGS){
		       my $i = 0;
		       while ($i < scalar(@{$SEGS{$key}})) { #update max scores
		          if (defined($MAXSEGS{$key}[$i])) {
		             if ($SEGS{$key}->[$i] > $MAXSEGS{$key}[$i]) { $MAXSEGS{$key}[$i] = $SEGS{$key}->[$i]; }
		          }
		          else { $MAXSEGS{$key}[$i] = $SEGS{$key}->[$i]; }
		          $i++;
		       }
		   }
		}
		
		foreach my $key (keys %MAXSEGS){
		    my $maxsys = 0; my $N = 0;
		    foreach my $seg (@{$MAXSEGS{$key}}) {
		       $maxsys += $seg;
		       $N++;
		    }
		    $maxsys = Common::safe_division($maxsys, $N);
		    $MAXSYS{$key} = $maxsys;
		}
	}
	elsif ( $opt eq $NGRAM::NGRAMSRC ){
	   my $hSEGS = NGRAM::computeNGRAM($NGRAM::NGRAMSRC, $out, $src, $tools, $case, $srclang, $trglang, $verbose, $issrcbased);
	   my %SEGS = %{$hSEGS};

	   foreach my $key (keys %SEGS){
	       my $i = 0;
	       while ($i < scalar(@{$SEGS{$key}})) { #update max scores
	          if (defined($MAXSEGS{$key}[$i])) {
	             if ($SEGS{$key}->[$i] > $MAXSEGS{$key}[$i]) { $MAXSEGS{$key}[$i] = $SEGS{$key}->[$i]; }
	          }
	          else { $MAXSEGS{$key}[$i] = $SEGS{$key}->[$i]; }
	          $i++;
	       }
	   }

		foreach my $key (keys %MAXSEGS){
		    my $maxsys = 0; my $N = 0;
		    foreach my $seg (@{$MAXSEGS{$key}}) {
		       $maxsys += $seg;
		       $N++;
		    }
		    $maxsys = Common::safe_division($maxsys, $N);
		    $MAXSYS{$key} = $maxsys;
		}
	}
	
	return(\%MAXSYS, \%MAXSEGS);
}


sub doMultiNGRAM {
   #description _ computes NGRAM score (multiple references)
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

	# reference-based measures   
   my $GO = 0; my $i = 0;
   my @mNGRAM = keys %{$NGRAM::rNGRAM};
   while (($i < scalar(@mNGRAM)) and (!$GO)) { if (exists($M->{$mNGRAM[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$NGRAM::NGRAMEXT.."; }

      my $reportNGRAMcosTok2xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-cosTok2ngrams.$Common::XMLEXT";
      my $reportNGRAMcosTok3xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-cosTok3ngrams.$Common::XMLEXT";
      my $reportNGRAMcosTok4xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-cosTok4ngrams.$Common::XMLEXT";
      my $reportNGRAMcosTok5xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-cosTok5ngrams.$Common::XMLEXT";
      my $reportNGRAMjacTok2xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacTok2ngrams.$Common::XMLEXT";
      my $reportNGRAMjacTok3xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacTok3ngrams.$Common::XMLEXT";
      my $reportNGRAMjacTok4xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacTok4ngrams.$Common::XMLEXT";
      my $reportNGRAMjacTok5xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacTok5ngrams.$Common::XMLEXT";

      if ((!(-e $reportNGRAMcosTok2xml) and !(-e $reportNGRAMcosTok2xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMcosTok3xml) and !(-e $reportNGRAMcosTok3xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMcosTok4xml) and !(-e $reportNGRAMcosTok4xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMcosTok5xml) and !(-e $reportNGRAMcosTok5xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacTok2xml) and !(-e $reportNGRAMjacTok2xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacTok3xml) and !(-e $reportNGRAMjacTok3xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacTok4xml) and !(-e $reportNGRAMjacTok4xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacTok5xml) and !(-e $reportNGRAMjacTok5xml.".$Common::GZEXT"))
          or $remakeREPORTS) {

         my ($SYS,$SEGS) = NGRAM::computeMultiNGRAM($NGRAM::NGRAMREF, $out, $Href, $src, $config->{CASE}, $srcL, $trgL, $tools, $verbose, 0);

         foreach my $key (keys %$SYS){
             my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{$key}, 0, $config->{IDX}->{$TGT});
             if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, $prefix.$NGRAMEXT."-".$key, $SYS->{$key}, $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose); }
				 Scores::save_hash_scores($prefix.$NGRAMEXT."-".$key, $TGT, $REF, $SYS->{$key}, $doc_scores, $seg_scores,$hOQ);
        }
      }
   }



   # source-based measures (CE)
   $GO = 0; $i = 0;
   @mNGRAM = keys %{$NGRAM::rCENGRAM};
   while (($i < scalar(@mNGRAM)) and (!$GO)) { if (exists($M->{$mNGRAM[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$NGRAM::CENGRAMEXT.."; }

      my $reportNGRAMcosChar2xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-cosChar2ngrams.$Common::XMLEXT";
      my $reportNGRAMcosChar3xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-cosChar3ngrams.$Common::XMLEXT";
      my $reportNGRAMcosChar4xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-cosChar4ngrams.$Common::XMLEXT";
      my $reportNGRAMcosChar5xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-cosChar5ngrams.$Common::XMLEXT";
      my $reportNGRAMjacChar2xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacChar2ngrams.$Common::XMLEXT";
      my $reportNGRAMjacChar3xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacChar3ngrams.$Common::XMLEXT";
      my $reportNGRAMjacChar4xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacChar4ngrams.$Common::XMLEXT";
      my $reportNGRAMjacChar5xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacChar5ngrams.$Common::XMLEXT";
      my $reportNGRAMjacCognatesxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-jacCognates.$Common::XMLEXT";
      my $reportNGRAMlenratioxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$prefix$NGRAMEXT-lenratio.$Common::XMLEXT";

      if ((!(-e $reportNGRAMcosChar2xml) and !(-e $reportNGRAMcosChar2xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMcosChar3xml) and !(-e $reportNGRAMcosChar3xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMcosChar4xml) and !(-e $reportNGRAMcosChar4xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMcosChar5xml) and !(-e $reportNGRAMcosChar5xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacCognatesxml) and !(-e $reportNGRAMjacCognatesxml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacChar2xml) and !(-e $reportNGRAMjacChar2xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacChar3xml) and !(-e $reportNGRAMjacChar3xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacChar4xml) and !(-e $reportNGRAMjacChar4xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMjacChar5xml) and !(-e $reportNGRAMjacChar5xml.".$Common::GZEXT")) or
          (!(-e $reportNGRAMlenratioxml) and !(-e $reportNGRAMlenratioxml.".$Common::GZEXT"))
          or $remakeREPORTS) {

         my ($SYS,$SEGS) = NGRAM::computeMultiNGRAM($NGRAM::NGRAMSRC, $out, $Href, $src, $config->{CASE}, $srcL, $trgL, $tools, $verbose, 1 );

         foreach my $key (keys %$SYS){
             my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{$key}, 0, $config->{IDX}->{$TGT});
             IQXML::write_report($TGT, $REF, $prefix.$NGRAMEXT."-".$key, $SYS->{$key}, $doc_scores, $seg_scores, $config->{IDX}->{$TGT}, $verbose);
        }
      }
	}
}

1;
