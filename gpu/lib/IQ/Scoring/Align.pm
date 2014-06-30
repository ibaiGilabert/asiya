package Align;

# ------------------------------------------------------------------------

#Copyright (C) Meritxell Gonzalez

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
use File::Basename;
use Unicode::String qw(utf8 latin1);
use Data::Dumper;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Metrics;

our ($ALIGNEXT, $BERKELEY);

$Align::ALIGNEXT = "align";
$Align::BERKELEYPATH = "berkeleyaligner";   # berkeley aligner run
$Align::BERKELEYSCRIPT = "berkeley_aligner_wrapper.sh";   # berkeley aligner run
$Align::BERKELEYMODELS = { "en2es" => "500K_en-es",
                           "en2de" => "500K_en-de",
                           "en2ru" => "500K_en-ru",
                           "en2fr" => "500K_en-fr",
                           "en2cz" => "500K_en-cs" };
$Align::BERKELEYCONFS = { "en2es" => "align_en_es.conf",
                          "en2de" => "align_en_de.conf",
                          "en2ru" => "align_en_ru.conf",
                          "en2fr" => "align_en_fr.conf",
			  "en2cz" => "align_en_cs.conf" };


$Align::AsEXT = "ALGNs"; #alignments between the cand and the Source
$Align::ArEXT = "ALGNr"; #alignments between the cand and the Reference (via the source)
$Align::ApEXT = "ALGNp"; #Proportion of shared alignments between cand/ref and source

$Align::rA = { "$Align::AsEXT" => 1, "$Align::ArEXT" => 1, "$Align::ApEXT" => 1 };

sub numerically    { $a <=> $b }
sub alphabetically { lc $a cmp lc $b }

#-----------------------------------------------------------------

sub metric_set {
    #description _ returns the set of available metrics
    #@return _ metric set structure (hash ref)

    my $srclang = shift;
    my $trglang = shift;

    my %metric_set;
    if ( ($srclang eq $Common::L_ENG) && ($trglang eq $Common::L_SPA) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_SPA) && ($trglang eq $Common::L_ENG) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_GER) && ($trglang eq $Common::L_ENG) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_ENG) && ($trglang eq $Common::L_GER) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_CZE) && ($trglang eq $Common::L_ENG) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_ENG) && ($trglang eq $Common::L_CZE) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_RUS) && ($trglang eq $Common::L_ENG) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_ENG) && ($trglang eq $Common::L_RUS) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_FRN) && ($trglang eq $Common::L_ENG) ) { %metric_set = %{$Align::rA}; }
    elsif ( ($srclang eq $Common::L_ENG) && ($trglang eq $Common::L_FRN) ) { %metric_set = %{$Align::rA}; }

    return \%metric_set;
}



sub compute_numof_alignments {
   #description _ computes number of aligned words between elems in the hash
   #param1 _ source sentence
   #param2 _ destination sentence
   #param3 _ alignments [hash reference]

    my $srcsent = shift;
    my $dstsent = shift;
    my $aligns = shift;

	 
    my %araligns = (defined($aligns))? %{$aligns} : {};

    chomp($srcsent);
    my @srctokens = split(" ", $srcsent);
    chomp($dstsent);
    my @dsttokens = split(" ", $dstsent);
    
    my @sorted_numbers = sort numerically keys %araligns; #words in the orig
    my $hits = scalar @sorted_numbers;
    my $total = scalar @srctokens;
     
#    my $hits = 0; 
#    my @sorted_numbers = sort numerically keys %araligns; #words in the orig
#    foreach my $wordid  ( @sorted_numbers ) {
#		my @l = @{$araligns{$wordid}};  #list of words in the dest
#    	if ( @l && (scalar @l > 0) ) { $hits++; }
#    }
    
#    my $total = scalar @sorted_numbers;
    
    return ($hits, $total);
}







#-----------------------------------------------------------------

sub readAlignments{
   #description _ read alignments from the file (for all segments) 
   #param1  _ alignment filename
   #@return _ two arrays with the  direct and reverse aligments

   my $report = shift;

   if ( !(-e $report) && !(-e $report.".$Common::GZEXT") ) {
     print STDERR "unable to open alignments file $report for reading\n";
   }
   if ( (!(-e $report)) and (-e "$report.$Common::GZEXT")) { system("$Common::GUNZIP $report.$Common::GZEXT"); }
	
   open ALIGNFILE, "< $report" or die "unable to open alignments file $report for reading\n";
   my %a;
   my %b;
   my $segid = 1;
   while ( my $value=<ALIGNFILE> ){
      my ( $arr1, $arr2 ) = String2Align($value);
      $a{$segid} = $arr1;
      $b{$segid} = $arr2;
      $segid++;
   }
   close ALIGNFILE;
   system("$Common::GZIP $report");
   
   return (\%a,\%b);
}

#-----------------------------------------------------------------

sub String2Align { 
    #description _ converts the alignmenst string into an array 
    #param1 _ array
    #returns arrays in direct and reverse order

    my $strar = shift; 
   
    my %arr1;
    my %arr2;

    my @ar = split ( ' ', $strar ); #alignments string ex: 0-0 0-1 1-2 2-3 3-3
    foreach my $item ( @ar ){
      # form of the items: i-j

      my ($w1,$w2) = split ("-",$item);
      push ( @{$arr1{$w1}}, $w2 ); 
      push ( @{$arr2{$w2}}, $w1 ); 
    }


#    foreach my $k ( keys %arr1 ){
#        my @tmp = @{$arr1{$k}};
#        foreach my $j ( @tmp ){
#            print "$k , $j \n";
#        }
#    }
     return \%arr1, \%arr2;   
}

#-----------------------------------------------------------------


sub Align2String { 
    #description _ converts into a string the alignments array
    # param1 _ aligns

    my $ar = shift; # [hash reference ]

    my %araligns = %{$ar};

    my @values;
    my @sorted_numbers = sort numerically keys %araligns;
    foreach my $wordid  ( @sorted_numbers ) {
        my @l = @{$araligns{$wordid}};  #list of words in the origin
        foreach my $w (@l){ #list of words in the 
            push (@values, "$wordid"."-"."$w");
        }
    }
    
    my $str = join( ' ', @values);
    return $str; 
}

#-----------------------------------------------------------------


sub writeAlignDoc {
   #description _ writes alignments into the file
   #param1  _ output filename
   #param2  _ array of alignments [segment][word] = l_words

   my $filename = shift;
   my $ARRALIGNS = shift; # [hash reference]


   #open output the file
   #for each alignment
   #    add it on the output file, having the line with the name before the alignments
  
   open ALIGNFILE, "> $filename" or die "unable to open alignments file $filename for writing\n";

   my %raligns = %{$ARRALIGNS};
   my @sorted_numbers = sort numerically keys %raligns;
   foreach my $segid  ( @sorted_numbers ) {
        my $value = Align2String($raligns{$segid});
        print ALIGNFILE $value."\n";
   }
   close ALIGNFILE;
}


#-----------------------------------------------------------------

sub computeBiAlign {
    #description _ computes the alignment between the reference and the candidate pivoting on the source alignment
    #param1 _ array1
    #param2 _ array2

    my $arr1 = shift;
    my $arr2 = shift;

    my %outarr;

    my %segarr1;
    my @sorted_refs = sort keys %{$arr1};
    foreach my $r (@sorted_refs) { if (exists($arr1->{$r})) { $segarr1{$r} = $arr1->{$r}; } }

    my %segarr2;
    @sorted_refs = sort keys %{$arr2};
    foreach my $r (@sorted_refs) { if (exists($arr2->{$r})) { $segarr2{$r} = $arr2->{$r}; } }

    #print "arr1\n";
    #print_align( \%segarr1 );
    #print "-----------\n";

    #print "arr2\n";
    #print_align ( \%segarr2 );
    #print "-----------\n";

    foreach my $seg_i ( sort keys %segarr1 ) { 
      my %wordarr1;
      %wordarr1 = %{$segarr1{$seg_i}};

      if ( defined $segarr2{$seg_i} ){

        	my %wordarr2;
        	%wordarr2 = %{$segarr2{$seg_i}};

        	foreach my $word_i ( sort keys %wordarr1 ) {
            my @l1 = @{$wordarr1{$word_i}}; #all alignments between arr1 and src
            foreach my $alitem1 ( @l1 ){
                if ( defined ( $wordarr2{$alitem1} )){
                    my @l2 = @{$wordarr2{$alitem1}}; # all alignments between src and arr2
                    foreach my $alitem2 ( @l2 ){
                        push ( @{$outarr{$seg_i}{$word_i}} , $alitem2 );  #add the alignment arr1->arr2
                    }
                }
            }
      	}
    	}# fi if defined
    	else{
    		print STDERR "$seg_i was not defined!!!\n";
    	}
    }

    #print "out\n";
    #print_align( \%outarr );
    #print "-----------\n";
    
    return (\%outarr);
}


sub print_align{
	
	my $hin = shift;
	
	my %hasha = %{$hin};
	
	my $str="";
	foreach my $numseg (sort keys %hasha){
		$str .= "$numseg => ";
		my %hashb = %{$hasha{$numseg}};
		foreach my $numword ( sort keys %hashb ){
			my @listwords = @{$hashb{$numword}};
			foreach my $destword (sort @listwords){
				$str .= $numword."-".$destword." ";
			}
		}
		$str .= "\n";
	}
	print "$str\n";
}


#-----------------------------------------------------------------




sub run_align {
   #description _ computes the alignments between the source and a translation
   #param1 _ source file
   #param2 _ source lang
   #param3 _ source name
   #param4 _ translation file
   #param5 _ translation lang
   #param6 _ translation name
   #param7 _ tools path
   #param8 _ verbose

   my $src = shift;
   my $srclang = shift;
   my $srcname = shift;
   my $trg = shift;
	my $trglang = shift;
	my $trgname = shift;
   my $tools = shift;
	my $verbose = shift;

	my $MODEL = "";
        my $CONF = "";
	my $toolAlign;
	my $alignfile="";
	my $reverse=0;
	
	#check if the alignment exist
	my $GO=0;
	$alignfile = "$src.$trgname.$ALIGNEXT"; #alignment with the source
	#print STDERR "looking for alignment at $alignfile\n";	
	if ( !(-e $alignfile) && !(-e $alignfile.".$Common::GZEXT") ){
		$alignfile = "$trg.$srcname.$ALIGNEXT"; #alignment with the source
		#print STDERR "looking for alignment at $alignfile\n";	
		if ( (-e $alignfile) || (-e $alignfile.".$Common::GZEXT") ){
			$reverse=1;
		}
		else{
			$GO = 1;
		}
	}

	#the alignment does not exist
	if ( $GO ){
		#print STDERR "running aligner \n";
		my $srclang2 = ($srclang eq "cz") ? "cs" : $srclang;
		my $trglang2 = ($trglang eq "cz") ? "cs" : $trglang;

		if ( $Align::BERKELEYCONFS->{$srclang."2".$trglang} ){
			$alignfile = "$src.$trgname.$ALIGNEXT"; #alignment with the source
			$CONF = "$tools/$Align::BERKELEYPATH/".$Align::BERKELEYCONFS->{$srclang."2".$trglang};
			$MODEL = $Align::BERKELEYMODELS->{$srclang."2".$trglang};
			$toolAlign = "$tools/$Align::BERKELEYPATH/$Align::BERKELEYSCRIPT $MODEL $srclang2 $trglang2 $CONF $src $trg $alignfile > $alignfile.out 2> $alignfile.err ";
		}
		elsif ( $Align::BERKELEYCONFS->{$trglang."2".$srclang} ){
			$alignfile = "$trg.$srcname.$ALIGNEXT"; #alignment with the source
			$CONF = "$tools/$Align::BERKELEYPATH/".$Align::BERKELEYCONFS->{$trglang."2".$srclang};
			$MODEL = $Align::BERKELEYMODELS->{$trglang."2".$srclang};
			$toolAlign = "$tools/$Align::BERKELEYPATH/$Align::BERKELEYSCRIPT $MODEL $trglang2 $srclang2 $CONF $trg $src $alignfile > $alignfile.out 2> $alignfile.err ";
			$reverse = 1;
		}
		else{ 
			if ($verbose) { print STDERR "ERROR running berkeley aligner. Missing models for language pais $srclang $trglang\n"; } 
		}


		if ( $CONF && (-e $CONF) ){
		    #print STDERR "calling berkeley aligner: $toolAlign\n";
  		    Common::execute_or_die("$toolAlign ", "[ERROR] problems running ALIGN...");
  		    system("$Common::GZIP $alignfile");
  		    system("rm -f $alignfile.out");
  		    system("rm -f $alignfile.err");
		}
		else{
			if ($verbose) { print STDERR "ERROR running berkeley aligner. The model file <$MODEL> cannot be found: $CONF\n"; }
		}
	}

	return ($reverse, $alignfile);
}

#-----------------------------------------------------------------

sub do_parse_alignments {
   #description _ create and read the alignments between the candidate and multiple references
   #param1 _ source name
   #param2 _ source file
   #param3 _ source lang
   #param4 _ candidate name
   #param5 _ candidate file
   #param6 _ candidate lang
   #param7 _ reference file(s) [hash reference]
   #param8 _ tools
   #param9 _ verbosity (0/1)
   #param10 _ remake reports (0/1)

   my $src = shift;
   my $srcfile = shift;
   my $srclang = shift;
   my $cand = shift;
   my $candfile = shift;
   my $candlang = shift;
   my $Href = shift; # [hash reference]
   my $tools = shift;
   my $verbose = shift;
   my $remakeREPORTS = shift;

   #if ((!(-e $reportALIGN) and !(-e $reportALIGN.".$Common::GZEXT")) or $remakeREPORTS) {
   
   # calculating candidate vs. reference(s) procedure:
   # first calculate source vs. references (if they do not exist!)
   # then calculate source vs. candidate
   # then combine both to create candidate vs. references 
   # and save as report


   #calculating reference vs. source
   my %LSrcRefAligns;
   my %LRefSrcAligns;
   foreach my $r (keys %{$Href}) {
       #check if already calculated
       my $reportALIGN;
       my $reffile = $Href->{$r};
       (my $reverse, $reportALIGN) = run_align ($srcfile, $srclang, $src, $reffile, $candlang, $r, $tools, $verbose);
       #read the alignments
       my ($a,$b) = readAlignments($reportALIGN);
       #mgb it seems that the alignments has the reverse form. Check the reasons of this behaviour!! 
       if ( $reverse ) { $LSrcRefAligns{$r} = $b;  $LRefSrcAligns{$r} = $a; }
       else{ $LSrcRefAligns{$r} = $a; $LRefSrcAligns{$r} = $b; }

   }

   #calculating candidate vs. source
   my ($reverse, $reportALIGN) = run_align ($srcfile, $srclang, $src, $candfile, $candlang, $cand, $tools, $verbose);
   my ($SrcCandAlign, $CandSrcAlign) = readAlignments($reportALIGN);
   #mgb it seems that the alignments has the reverse form. Check the reasons of this behaviour!!
   if ( $reverse ){
		my $tmp = $CandSrcAlign;
		$CandSrcAlign = $SrcCandAlign;
		$SrcCandAlign = $tmp;   
   }

   #calculating candidate vs. reference(s)
   my %LCandRefAligns;
   my %LRefCandAligns;
   foreach my $r (keys %{$Href}) {
        #format of alignments array[seg_num][word_num] = (list of aligns)
        #if ($verbose) { print "bialign between $r-$src and $src-$cand \n"; }
        $LRefCandAligns{$r}= computeBiAlign ($LRefSrcAligns{$r}, $SrcCandAlign);
		  #if ($verbose) { print "bialign between $cand-$src and $src-$r \n";}
        $LCandRefAligns{$r} = computeBiAlign ($CandSrcAlign, $LSrcRefAligns{$r});
        
   	  #save cand->ref aligns
        my $outAlign = "$candfile.$r.$ALIGNEXT";
        writeAlignDoc($outAlign, $LRefCandAligns{$r});
		  system("$Common::GZIP $outAlign");
        #if ($verbose > 1) { print STDERR "building $outAlign...\n"; }        
   }
   
   return(\%LSrcRefAligns, $SrcCandAlign, \%LCandRefAligns);
}

#-----------------------------------------------------------------

sub doMultiAlign {
   #description _ computes the Alignments between the source and the candidate/references. 
   #              Then, it also infers the alignment between the candidate and the references
   #mgb				This function is called TWICE. From here and from Metrics when the $config->{alignments} flag is active
   #					Reconfigure it!!
   #param1  _ configuration
   #param2  _ candidate NAME
   #param3  _ candidate file
   #param4  _ reference file(s) [hash reference]

   my $config = shift;
   my $TGT = shift;
   my $tgtfile = shift;
   my $Href = shift;


   my %HREF;
   my @sorted_refs = sort keys %{$Href};
   foreach my $r (@sorted_refs) { if (exists($Href->{$r})) { $HREF{$r} = $Href->{$r}; } }

   my $srcfile = $config->{src};                # source file 
   my $src = Common::give_system_name($srcfile);# source name

   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $GO = 0; my $i = 0;

	my $LSrcRefsAligns;
	my $SrcCandAlign;
	my $LCandRefsAligns;

   #if ($verbose == 1) { print STDERR "$Align::ALIGNEXT.."; }
   ($LSrcRefsAligns, $SrcCandAlign, $LCandRefsAligns) = do_parse_alignments($src, $srcfile, $config->{SRCLANG}, $TGT, $tgtfile, $config->{LANG}, \%HREF, $tools, $verbose, $remakeREPORTS);  

   return ($LSrcRefsAligns, $SrcCandAlign, $LCandRefsAligns);
}


#-----------------------------------------------------------------



sub computeALGNp {
   #description _ computes overlap between the alignments with the reference and the alignments with the candidate
   #param1 _ source file
   #param2 _ candidate file
   #param3 _ reference file
   #param4 _ Alignments between source  and cand
   #param5 _ Alignments between sourc and reference

	my $src = shift;
	my $cand = shift;
	my $ref = shift;
   my $SrcCandAlign = shift;
   my $SrcRefAlign = shift;

   my %candaligns = %{$SrcCandAlign};
   my %refaligns = %{$SrcRefAlign};

   my @SEG; my $HITS = 0; my $TOTAL = 0;
   my @sorted_numbers = sort numerically keys %candaligns;

	my $HITScand; my $TOTALcand; my $HITSref; my $TOTALref;
   
	open(SRCF, "< $src") or die "couldn't open input file: $src\n";
   open(CAND, "< $cand") or die "couldn't open input file: $cand\n";
   open(REFF, "< $ref") or die "couldn't open input file: $ref\n";

	my $srcsent; my $candsent; my $refsent;   
   foreach my $segid  ( @sorted_numbers ) {

   	$srcsent = <SRCF>;
   	$candsent = <CAND>;
   	$refsent = <REFF>;
   	
      my $SEGscorecand = 0;
      my $SEGscoreref = 0;
		my ($hitscand, $totalcand) = compute_numof_alignments($srcsent, $candsent, $candaligns{$segid} );
		$SEGscorecand = Common::safe_division($hitscand, $totalcand);
		my ($hitsref, $totalref) = compute_numof_alignments($srcsent, $refsent, $refaligns{$segid} );
      $SEGscoreref = Common::safe_division($hitsref, $totalref);
      #proportion cand/ref
		my $SEGscore= Common::safe_division($SEGscorecand, $SEGscoreref);
      
	   $HITScand += $hitscand;
   	$TOTALcand += $totalcand;
      $HITSref += $hitsref;
      $TOTALref += $totalref;
      push(@SEG, $SEGscore);      
   }

	#SYSTEM
	my $SYSscorecand = Common::safe_division($HITScand, $TOTALcand);
   my $SYSscoreref = Common::safe_division($HITSref, $TOTALref);
   my $SYS = Common::safe_division($SYSscorecand, $SYSscoreref);

   return($SYS, \@SEG);
}

#-----------------------------------------------------------------

sub computeALGNs {
   #description _ computes number of alignments between the origin and dest (e.g., source and candidate)
   #param1 _ origin sentence
   #param2 _ destination sentence
   #param3 _ Alignments between origin and dest

	my $origfile = shift;
	my $destfile = shift;
   my $OrigDestAlign = shift;
   
	#print "orig file $origfile\n";
	#print "des file $destfile\n";
	#print Dumper $OrigDestAlign;
   my @SEG; my $HITS = 0; my $TOTAL = 0;
   my %raligns = %{$OrigDestAlign};
   my @sorted_numbers = sort numerically keys %raligns;
   
	open(ORIG, "< $origfile") or die "couldn't open input file: $origfile\n";
   open(DEST, "< $destfile") or die "couldn't open input file: $destfile\n";

	my $origsentence;
	my $destsentence;
   foreach my $segid  ( @sorted_numbers ) {
   	$origsentence = <ORIG>;
	   $destsentence = <DEST>;
      my $SEGscore = 0;
		my ($hits, $total) = compute_numof_alignments( $origsentence, $destsentence, $raligns{$segid} );
      $SEGscore = Common::safe_division($hits, $total);
      $HITS += $hits;
      $TOTAL += $total;
      push(@SEG, $SEGscore);      
   }

   my $SYS = Common::safe_division($HITS, $TOTAL);
   
	close (ORIG);
	close (DEST);
	
   return($SYS, \@SEG);
}



sub computeMultiALGNr {
   #description _ computes number of alignments between the candidate and multiple references
   #param1 _ Candidate file
   #param2 _ List of references files
   #param3 _ List of alignments between candidate and references

	my $cand = shift;
	my $Href = shift; # [hash reference]   
   my $LCandRefAligns = shift; # [list reference]

   my %raligns = %{$LCandRefAligns};

	#update maxscores
   my @MAXSEGS;
   foreach my $ref (keys %{$LCandRefAligns}) {
   	#obtain scores for the current reference
      my ($SYS, $SEGS) = Align::computeALGNs( $cand, $Href->{$ref}, $raligns{$ref} );
		#update max scores
      my $i = 0;
      while ($i < scalar(@{$SEGS})) { 
         if (defined($MAXSEGS[$i])) {
            if ($SEGS->[$i] > $MAXSEGS[$i]) { $MAXSEGS[$i] = $SEGS->[$i]; }
         }
         else { $MAXSEGS[$i] = $SEGS->[$i]; }
         $i++;
      }
   }

   my $MAXSYS = 0; my $N = 0;
   foreach my $seg (@MAXSEGS) {
      $MAXSYS += $seg;
      $N++;
   }

   $MAXSYS = Common::safe_division($MAXSYS, $N);

   return($MAXSYS, \@MAXSEGS);
}


sub computeMultiALGNp {
   #description _ computes overlap between the alignments with the references and  the alignments with the candidate
   #param1 _ source file
	#param2 _ candidate file
	#param3 _ list of references file [hash reference] 
	#param4 _ Alignments between source and candidate
   #param5 _ List of Alignments between source and references

	my $src = shift;
	my $cand = shift;
	my $Href = shift; # [hash reference]
   my $SrcCandAlign = shift; # [list reference]
   my $LSrcRefAligns = shift; # [hash reference]

   my %raligns = %{$LSrcRefAligns};

	#update maxscores
   my @MAXSEGS;
   foreach my $ref (keys %{$LSrcRefAligns}) {
   	#obtain scores for the current reference
      my ($SYS, $SEGS) = Align::computeALGNp( $src, $cand, $Href->{$ref}, $SrcCandAlign, $raligns{$ref} );
		#update max scores
      my $i = 0;
      while ($i < scalar(@{$SEGS})) { 
         if (defined($MAXSEGS[$i])) {
            if ($SEGS->[$i] > $MAXSEGS[$i]) { $MAXSEGS[$i] = $SEGS->[$i]; }
         }
         else { $MAXSEGS[$i] = $SEGS->[$i]; }
         $i++;
      }
   }

   my $MAXSYS = 0; my $N = 0;
   foreach my $seg (@MAXSEGS) {
      $MAXSYS += $seg;
      $N++;
   }

   $MAXSYS = Common::safe_division($MAXSYS, $N);

   return($MAXSYS, \@MAXSEGS);

}






sub doMultiAr {
   #description _ computes number of alignments (multiple references)
   #param1  _ configuration
   #param2  _ candidate NAME
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
   my $M = $config->{Hmetrics};                 # set of metrics
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $GO = 0; my $i = 0;
   my @mA = keys %{$Align::rA};

   while (($i < scalar(@mA)) and (!$GO)) { if (exists($M->{$mA[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
   	#compute the alignments
   	my ($LSrcRefAligns, $SrcCandAlign, $LCandRefAligns) = doMultiAlign( $config, $TGT, $out, $Href );
   	#compute the metrics related to the alignments
      if (exists($M->{$Align::AsEXT})) {
         my $reportxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$Align::AsEXT.$Common::XMLEXT";
         if ($verbose == 1) { print STDERR "$Align::AsEXT.."; }
         if ((!(-e $reportxml) and !(-e $reportxml.".$Common::GZEXT")) or $remakeREPORTS) {
            my ($SYS, $SEGS) = Align::computeALGNs($src, $out, $SrcCandAlign);
            my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$Align::AsEXT", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores("$Align::AsEXT", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
         }
      }
      if (exists($M->{$Align::ArEXT})) {
         if ($verbose == 1) { print STDERR "$Align::ArEXT.."; }
         my $reportxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$Align::ArEXT.$Common::XMLEXT";
         if ((!(-e $reportxml) and !(-e $reportxml.".$Common::GZEXT")) or $remakeREPORTS) {
            my ($SYS, $SEGS) = Align::computeMultiALGNr($out, $Href, $LCandRefAligns);
            my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$Align::ArEXT", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores("$Align::ArEXT", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
         }
      }
      if (exists($M->{$Align::ApEXT})) {
         if ($verbose == 1) { print STDERR "$Align::ApEXT.."; }
         my $reportxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$Align::ApEXT.$Common::XMLEXT";
         if ((!(-e $reportxml) and !(-e $reportxml.".$Common::GZEXT")) or $remakeREPORTS) {
            my ($SYS, $SEGS) = Align::computeMultiALGNp($src, $out, $Href, $SrcCandAlign, $LSrcRefAligns);
            my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
            if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "$Align::ApEXT", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores("$Align::ApEXT", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
         }
      }
   }
}


1;
