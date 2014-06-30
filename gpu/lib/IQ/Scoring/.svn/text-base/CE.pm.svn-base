package CE;

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
use List::Util qw[min max];
use Scalar::Util qw(looks_like_number);
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Metrics;
use IQ::Scoring::Overlap;

our ($CEEXT, $rCE, $rBIDICT, $length_factor, $rPUNCT, $LM_path, $LM_name, $LM_ext, $raw, $pos, $chunk,
     $BIDICT_SEPARATOR, $BIDICT_MAX_NGRAM_LENGTH);

$CE::CEEXT = $Common::CE;

####  metric sets

$CE::rCE = { "$CE::CEEXT-srclen" => 1,
	         "$CE::CEEXT-srclogp" => 1, "$CE::CEEXT-srcippl" => 1, "$CE::CEEXT-srcoov" => 1, 
	         "$CE::CEEXT-logp" => 1, "$CE::CEEXT-ippl" => 1, "$CE::CEEXT-oov" => 1, 
	         "$CE::CEEXT-srclogpP" => 1, "$CE::CEEXT-srcipplP" => 1, "$CE::CEEXT-logpP" => 1, "$CE::CEEXT-ipplP" => 1, 
	         "$CE::CEEXT-srclogpC" => 1, "$CE::CEEXT-srcipplC" => 1, "$CE::CEEXT-logpC" => 1, "$CE::CEEXT-ipplC" => 1,
	         "$CE::CEEXT-length" => 1, "$CE::CEEXT-long" => 1, "$CE::CEEXT-short" => 1, "$CE::CEEXT-symbols" => 1,
	         "$CE::CEEXT-Op" => 1, "$CE::CEEXT-Oc" => 1, "$CE::CEEXT-Nc" => 1, "$CE::CEEXT-Oe" => 1, "$CE::CEEXT-Ne" => 1,
	         "$CE::CEEXT-BiDictA" => 1, "$CE::CEEXT-BiDictO" => 1
	       };

$CE::srcENG = { "$CE::CEEXT-srclen" => 1,
	         "$CE::CEEXT-srclogp" => 1, "$CE::CEEXT-srcippl" => 1, "$CE::CEEXT-srcoov" => 1, 
	         "$CE::CEEXT-srclogpP" => 1, "$CE::CEEXT-srcipplP" => 1, 
	         "$CE::CEEXT-srclogpC" => 1, "$CE::CEEXT-srcipplC" => 1, 
	         "$CE::CEEXT-BiDictA" => 1
	       };

$CE::trgENG = { "$CE::CEEXT-logp" => 1, "$CE::CEEXT-ippl" => 1, "$CE::CEEXT-oov" => 1, 
	         "$CE::CEEXT-logpP" => 1, "$CE::CEEXT-ipplP" => 1, 
	         "$CE::CEEXT-logpC" => 1, "$CE::CEEXT-ipplC" => 1
	       };

$CE::notENGSPA = {"$CE::CEEXT-length" => 1, "$CE::CEEXT-long" => 1, "$CE::CEEXT-short" => 1, "$CE::CEEXT-symbols" => 1,
                    "$CE::CEEXT-Op" => 1, "$CE::CEEXT-Oc" => 1, "$CE::CEEXT-Nc" => 1, "$CE::CEEXT-Oe" => 1, "$CE::CEEXT-Ne" => 1
	       };

$CE::anyLANG = {"$CE::CEEXT-length" => 1, "$CE::CEEXT-long" => 1, "$CE::CEEXT-short" => 1, "$CE::CEEXT-symbols" => 1 };

#######################

$CE::rBIDICT ={ $Common::L_ENG."-".$Common::L_SPA => "apertium-dicts/en-es.dict",
                $Common::L_SPA."-".$Common::L_ENG => "apertium-dicts/es-en.dict"	
              };

$CE::BIDICT_SEPARATOR = quotemeta("|");

$CE::BIDICT_MAX_NGRAM_LENGTH = 5;

#en -es = 244144301 / 272396865

# Compresson factor aimed at compensating for differences in length inherent to the language pair (as estimated according to large bilingual corpora)
$CE::length_factor = { $Common::L_ARA => { },
                       $Common::L_CAT => { $Common::L_SPA => 65748722 / 68494845 },
                       $Common::L_CHN => { },
                       $Common::L_CZE => { },
                       $Common::L_ENG => { $Common::L_SPA => 272396865 / 244144301 },
                       $Common::L_FRN => { },
                       $Common::L_GER => { },
                       $Common::L_ITA => { },
                       $Common::L_ROM => { },
                       $Common::L_SPA => { },
                       $Common::L_OTHER => { }
};

$CE::rPUNCT = { '.' => 1, ',' => 1, '!' => 1, '?' => 1, '\'' => 1, '\"' => 1, '(' => 1, ')' => 1,
                '[' => 1, ']' => 1, '{' => 1, '}' => 11, '$' => 1, '%' => 1, '&' => 1, '/' => 1,
                '\\' => 1, '=' => 1, '*' => 1, '-' => 1, '_' => 1, '|' => 1, '<' => 1, '>' => 1,
                '@' => 1, '€' => 1, '#' => 1,
                "\x{00A3}" => 1, #pound
                "\x{0060}" => 1, "\x{00B4}" => 1, "\x{2018}" => 1, "\x{2019}" => 1, "\x{02BC}", #apostrophe
                "\x{00AB}" => 1, "\x{00BB}" => 1, "\x{201C}" => 1, "\x{201D}" => 1, # quotation
                "\x{002D}" => 1, "\x{2010}" => 1, "\x{2011}" => 1, "\x{2012}" => 1,
                "\x{2013}" => 1, "\x{2014}" => 1, "\x{2015}" => 1, "\x{207B}" => 1, 
                "\x{208B}" => 1, "\x{2212}", # hyphen
                "\x{2026}" => 1  # three dots
               };

$CE::LM_path = "srilm";
$CE::LM_ext = "LM";
$CE::lm_ext = "lm";
$CE::raw = "raw";
$CE::pos = "pos";
$CE::chunk = "chunk";

#news-commentary10
#europarl-v5
#news.shuffled

$CE::LM_name = {
	             $Common::L_ENG => { $CE::raw => "europarl-v5",
	             	                 $CE::pos => "europarl-v5",
	             	                 $CE::chunk => "europarl-v5" },
	             $Common::L_SPA => { $CE::raw => "europarl-v5",
	             	                 $CE::pos => "europarl-v5",
	             	                 $CE::chunk => "europarl-v5" }
               };


sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ source language
    #param2  _ target language
    #@return _ metric set structure (hash ref)

    my $source_language = shift;
    my $target_language = shift;

    my %metric_set;
    
    if ((($source_language eq $Common::L_ENG) and ($target_language eq $Common::L_SPA)) or
        (($source_language eq $Common::L_SPA) and ($target_language eq $Common::L_ENG))) { 
    	%metric_set = %{$CE::rCE};
    }
    elsif ( $source_language eq $Common::L_ENG ) { 
    	%metric_set = (%{$CE::srcENG},%{$CE::anyLANG});
    }
    elsif ( $target_language eq $Common::L_ENG ) { 
    	%metric_set = (%{$CE::trgENG},%{$CE::anyLANG});
    }
    else{ 
    	%metric_set = %{$CE::anyLANG};
    }
    return \%metric_set;
}


sub computeCE_segment_length_ratio($$$$$) {
    #description _ compute segment length ratio (three variants: 'length', 'long', 'short')
    #param1  _ source sentence
    #param2  _ target sentence
    #param3  _ source language
    #param4  _ target language
    #param5  _ verbosity (0/1)

    my $source = shift;
    my $target = shift;
    my $srclang = shift;
    my $trglang = shift;
    my $verbose = shift;

    my @source_tokens = split(/\s/, $source);
    my @target_tokens = split(/\s/, $target);
    my $source_length = scalar(@source_tokens);
    my $target_length = scalar(@target_tokens);

    my $compression_factor = 1;   # aimed at compensating for difference in length inherent to the language pair
    if (exists($CE::length_factor->{$srclang}->{$trglang})) {
       $compression_factor = $CE::length_factor->{$srclang}->{$trglang};
    }
    elsif (exists($CE::length_factor->{$trglang}->{$srclang})) {
       $compression_factor = 1 / $CE::length_factor->{$trglang}->{$srclang};    	
    }  
    
    my $numerator_length = min($source_length * $compression_factor, $target_length);
    my $denominator_length = max($source_length * $compression_factor, $target_length);
    my $length_score =  Common::safe_division($numerator_length, $denominator_length);

    my $numerator_long = $source_length * $compression_factor;
    my $denominator_long = max($source_length * $compression_factor, $target_length);
    my $long_score =  Common::safe_division($numerator_long, $denominator_long);

    my $numerator_short = $target_length;
    my $denominator_short = max($source_length * $compression_factor, $target_length);
    my $short_score =  Common::safe_division($numerator_short, $denominator_short);

    if ($verbose) {
       say "source length = $source_length";
       say "target length = $target_length";
       say "length(source, target) = $numerator_length / $denominator_length = $length_score";
       say "long(source, target) = $numerator_long / $denominator_long = $long_score";
       say "short(source, target) = $numerator_short / $denominator_short = $short_score";
    }           

    return ($length_score, $long_score, $short_score);	
}

sub computeCE_length_ratio($$$$$) {
    #description _ computes length ratio scores (three variants: 'length', 'long', 'short')   (no references)
    #param1  _ source file
    #param2  _ candidate file
    #param3  _ source language
    #param4  _ target language
    #param5  _ verbosity (0/1)

    my $src = shift;
    my $out = shift;
    my $SRCLANG = shift;
    my $TRGLANG = shift;
    my $verbose = shift;

    my $SRC = new IO::File("< $src") or die "Couldn't open input file: $src\n";
    my $OUT = new IO::File("< $out") or die "Couldn't open input file: $out\n";

    my $STOP = 0;
    my @SEGlength;
    my @SEGlong;
    my @SEGshort;
    my $SUMlength = 0;
    my $SUMlong = 0;
    my $SUMshort = 0;
    while ((defined (my $s = $SRC->getline())) and (!$STOP)) {
       my $length = 0; my $long = 0; my $short = 0;
       if (defined(my $o = $OUT->getline())) {
          chomp($s); chomp($o);
          ($length, $long, $short) = computeCE_segment_length_ratio($s, $o, $SRCLANG, $TRGLANG, $verbose);
          $SUMlength += $length;
          $SUMlong += $long;
          $SUMshort += $short;
       }
       else { print STDERR "[ERROR] number of lines differs <$src> vs <$out>\n"; $STOP = 1; }
       push(@SEGlength, $length);
       push(@SEGlong, $long);
       push(@SEGshort, $short);
    }
    $OUT->close();
    $SRC->close();

    
    my %SYS;
    $SYS{"length"} = Common::safe_division($SUMlength, scalar(@SEGlength));
    $SYS{"long"} = Common::safe_division($SUMlong, scalar(@SEGlong));
    $SYS{"short"} = Common::safe_division($SUMshort, scalar(@SEGshort));
    my %SEGS;
    $SEGS{"length"} = \@SEGlength;
    $SEGS{"long"} = \@SEGlong;
    $SEGS{"short"} = \@SEGshort;

    return(\%SYS, \%SEGS);
}

sub computeCE_segment_length($$) {
    #description _ computes segment length scores   (no references)
    #param1  _ text file
    #param2  _ verbosity (0/1)

    my $file = shift;
    my $verbose = shift;

    my $FILE = new IO::File("< $file") or die "Couldn't open input file: $file\n";
    my @SEGS;
    my $SUM = 0;
    while (defined (my $segment = $FILE->getline())) {
       chomp($segment);
       my @tokens = split(/\s/, $segment);
       my $length = scalar(@tokens);
       my $SEGscore = Common::safe_division(1, $length);
       if ($verbose) { say "score = 1 / $length = $SEGscore"; }           
       $SUM += $SEGscore;
       push(@SEGS, $SEGscore);      
    }
    $FILE->close();

    my $SYS = Common::safe_division($SUM, scalar(@SEGS));

    return($SYS, \@SEGS);
}

sub extract_symbol_set($) {
    #description _ extract set of symbols in text
    #param1  _ input text
    #@return _ set of symbols (hash ref)
    
    my $text = shift;
    
    my @tokens = split(/\s/, $text);

    my %symbol_set;
    foreach my $token (@tokens){
       #if (exists($CE::rPUNCT->{$token})) { $symbol_set{$token}++; }
       if (exists($CE::rPUNCT->{$token}) or (looks_like_number($token))) { $symbol_set{$token}++; }
    }
    
    return \%symbol_set;
}

sub computeCE_segment_symbol_overlap($$$) {
    #description _ compute segment symbol overlap between source and target
    #param1  _ source sentence
    #param2  _ target sentence
    #param3  _ verbosity (0/1)

    my $source = shift;
    my $target = shift;
    my $verbose = shift;

    my $source_symbols = extract_symbol_set($source);
    my $target_symbols = extract_symbol_set($target);
    
    my ($hits, $total) =  Overlap::compute_overlap($source_symbols, $target_symbols, 0);
    
    my $score = Common::safe_division($hits, $total);

    if ($verbose) {
       say "source = $source";
       print Dumper $source_symbols;
       say "target = $target";
       print Dumper $target_symbols;
       say "OVERLAP = $hits / $total = $score";
    }
    
    return $score;	
}

sub computeCE_symbol_overlap($$$) {
    #description _ computes symbol overlap scores   (no references)
    #              (pending: make it language dependent? because the use of punctuation symbols may vary between languages)
    #param1  _ source file
    #param2  _ target file
    #param3  _ verbosity (0/1)

    my $src = shift;
    my $out = shift;
    my $verbose = shift;

    my $SRC = new IO::File("< $src") or die "Couldn't open input file: $src\n";
    my $OUT = new IO::File("< $out") or die "Couldn't open input file: $out\n";

    my $STOP = 0;
    my @SEGS;
    my $SUM = 0;
    while ((defined (my $s = $SRC->getline())) and (!$STOP)) {
       my $SEGscore = 0;
       if (defined(my $o = $OUT->getline())) {
          chomp($s); chomp($o);
          $SEGscore = computeCE_segment_symbol_overlap($s, $o, $verbose);
          $SUM += $SEGscore;
       }
       else { print STDERR "[ERROR] number of lines differs <$src> vs <$out>\n"; $STOP = 1; }
       push(@SEGS, $SEGscore);      
    }
    $OUT->close();
    $SRC->close();

    my $SYS = 0;
    if (scalar(@SEGS) != 0) { $SYS = $SUM / scalar(@SEGS); } 

    return($SYS, \@SEGS);
}

sub compute_language_modeling_features($$$$$$) {
   	#description _ compute language modeling features (logp, inverse perplexity and oov proportion)
   	#              variants -> (raw, pos, chunk) according to the type of linguistic units
    #param1  _ input file
    #param2  _ language
    #param3  _ case
    #param4  _ tools
    #param5  _ variant ('raw' | 'pos' | 'chunk')
    #param6  _ verbosity (0/1)
   	
    my $file = shift;
    my $LANG = shift;
    my $CASE = shift;
    my $tools = shift;
    my $variant = shift;
    my $verbose = shift;
    
    srand;
    my $r = rand($Common::NRAND);
    my $tmp_out = $file.".$LM_ext.".$r;
    
    if (exists($CE::LM_name->{$LANG}->{$variant})) {
       if ($variant eq $CE::raw) {
          Common::execute_or_die("ngram -lm $tools/$LM_path/$LANG/$CASE/".$CE::LM_name->{$LANG}->{$variant}.".$CE::lm_ext -debug 1".
                                  (($CASE eq $Common::CASE_CI)? " -tolower" : "")." -ppl $file > $tmp_out 2> /dev/null",
                                 "[ERROR] SRILM - language modeling toolkit not available!!");
       }
       else {
          Common::execute_or_die("ngram -lm $tools/$LM_path/$LANG/".$CE::LM_name->{$LANG}->{$variant}.".$variant".
                                  ".$CE::lm_ext -debug 1"." -ppl $file > $tmp_out 2> /dev/null",
                                 "[ERROR] SRILM - language modeling toolkit not available!!");       	
       }
    }
    else { die "[ERROR] unavailable language model for language <$LANG> - variant <$variant>!!\n"; }
  
    my @SEGoov;
    my @SEGlogp;
    my @SEGippl;
    my $SUMoov = 0; my $SUMlogp = 0; my $SUMippl = 0;    
    my $FILE = new IO::File("< $file") or die "Couldn't open input file: $file\n";
    my $TMP_OUT = new IO::File("< $tmp_out") or die "Couldn't open input file: $tmp_out\n";
    while (defined (my $segment = $FILE->getline())) {
       chomp($segment);
       while ($segment =~ /^$/) {
          push(@SEGoov, 0);
          push(@SEGlogp, 0);
          push(@SEGippl, 0);
          $segment = $FILE->getline();
          chomp($segment);
       }
       my $source = $TMP_OUT->getline(); chomp($source);
       my $info = $TMP_OUT->getline(); chomp($info);
       my $scores = $TMP_OUT->getline(); chomp($scores);
       $TMP_OUT->getline(); # empty line
       #if ($segment ne $source) {
       #   print "------------------------------------\n";
       #   print $segment, "\n";
       #   print "--> $source\n";
       #   print "----> $info\n";
       #   print "------> $scores\n";
       #}
       my @l_info = split(/\s/, $info);
       my $num_words = $l_info[2];
       my $num_oov = $l_info[4];
       my $oov = 1 - Common::safe_division($num_oov, $num_words);
       my @l_scores = split(/\s/, $scores);
       my $logp = $l_scores[3];
       my $ppl = $l_scores[5];
       my $ippl = 1 / $ppl;
       if ($verbose) {
          say $source;
          #say $info;
          #say $scores;
          say "oov = 1 - $num_oov / $num_words = $oov";
          say "logp = $logp";
          say "ippl = 1 / $ppl = $ippl";
       }
       $SUMoov += $oov;
       $SUMlogp += $logp;
       $SUMippl += $ippl;
       push(@SEGoov, $oov);
       push(@SEGlogp, $logp);
       push(@SEGippl, $ippl);
    }
    $FILE->close();
    $TMP_OUT->close();
    
    system "rm -rf $tmp_out";

    my %SYS;
    $SYS{"oov"} = Common::safe_division($SUMoov, scalar(@SEGoov));
    $SYS{"logp"} = Common::safe_division($SUMlogp, scalar(@SEGlogp));
    $SYS{"ippl"} = Common::safe_division($SUMippl, scalar(@SEGippl));
    my %SEGS;
    $SEGS{"oov"} = \@SEGoov;
    $SEGS{"logp"} = \@SEGlogp;
    $SEGS{"ippl"} = \@SEGippl;

    return (\%SYS, \%SEGS);
}

sub load_bidict($$$) {
	#description _ load bilingual dictionary (according to the given language pair) if available
    #param1  _ TOOL directory
	#param2  _ source language
	#param3  _ target language
	#@return _ bilingual dictionary (hash ref)
	
    my $tools = shift;
    my $source_language = shift;
    my $target_language = shift;

    my %bidict; 
    
    if (exists($rBIDICT->{$source_language."-".$target_language})) {
       my $bidict_file = $tools."/".$rBIDICT->{$source_language."-".$target_language};
       my $BIDICT_FILE = new IO::File("< $bidict_file") or die "Couldn't open input file: $bidict_file\n";
       while (defined (my $entry = $BIDICT_FILE->getline())) {
          chomp($entry);
          my @elems = split(/$CE::BIDICT_SEPARATOR/, $entry);
          if (scalar(@elems) == 2) {
          	 my $source = lc($elems[0]);
          	 my $target = lc($elems[1]);
             if (($target ne "prpers") and ($target ne "pn000")) {
                $bidict{$source}->{$target}++;
             }
          }
       }
    }

    return \%bidict;       	
}

sub retrieve_mixed_ngrams($$$) {
    #description _ retrieve all mixed ngrams (in the two sequences) up to a given length
    #param1  _ sequence 1 (list ref)
    #param2  _ sequence 2 (list ref)
    #param3  _ ngram length
    #@return _ ngrams (hash ref)

    my $tokens = shift;
    my $lemmas = shift;
    my $length = shift;

    if ($length < 1) { $length = 1; }
    
    my %ngrams;
    my %window;
    my $i = 0;
    while ($i < scalar(@{$tokens})) {
       my $token = lc($tokens->[$i]);
       my $lemma = lc($lemmas->[$i]);
       if ($length == 1) {
          $ngrams{$token}++;
          if ($lemma ne $token) { $ngrams{$lemma}++; }
       }
       else {
          if ($i < $length) {
             if (scalar(keys %window) == 0) { #empty window
          	    $window{$token} = 1;
             	if ($lemma ne $token) { $window{$lemma} = 1; }
                if ($i == $length -1) {
                   $ngrams{$token}++;
                   if ($lemma ne $token) { $ngrams{$lemma}++; }
                }
             }
             else {
          	    foreach my $ngram (keys %window) {
          	 	   delete $window{$ngram};
                   $window{Common::trim_string($ngram." ".$token)} = 1;
          	 	   if ($lemma ne $token) { $window{Common::trim_string($ngram." ".$lemma)} = 1; }
          	 	   if ($i == $length -1) {
          	 	      $ngrams{Common::trim_string($ngram." ".$token)}++;
          	 	      if ($lemma ne $token) { $ngrams{Common::trim_string($ngram." ".$lemma)}++; }
          	 	   }
          	    }
             }
          }
          else {
             foreach my $ngram (keys %window) {
          	    delete $window{$ngram};
          	    my @lgram = split(" ", $ngram);
          	    shift(@lgram);
          	    my $new_ngram = "";
          	    if (scalar(@lgram) > 0) { $new_ngram = join(" ", @lgram); }
          	    $window{Common::trim_string($new_ngram." ".$token)} = 1;
          	    if ($lemma ne $token) { $window{Common::trim_string($new_ngram." ".$lemma)} = 1; }     	 
       	        $ngrams{Common::trim_string($new_ngram." ".$token)}++;
          	    if ($lemma ne $token) { $ngrams{Common::trim_string($new_ngram." ".$lemma)}++; }
             }    	  
          }
       	
       }
       $i++;
    }
    
    return \%ngrams;
}

sub merge_ngrams($$) {
    #description _ merge two ngram sets (adding counts) into the first
    #param1  _ set 1 (hash ref) input/output
    #param2  _ set 2 (hash ref)
    
    my $ngrams1 = shift;
    my $ngrams2 = shift;
    
    foreach my $ngram (keys %{$ngrams2}) {
       if (exists($ngrams1->{$ngram})) { $ngrams1->{$ngram} += $ngrams2->{$ngram}; }
       else { $ngrams1->{$ngram} = $ngrams2->{$ngram}; }
    }
}

sub retrieve_all_mixed_ngrams($$) {
    #description _ retrieve all mixed ngrams (in the two sequences) of any length
    #param1  _ sequence 1 (list ref)
    #param2  _ sequence 2 (list ref)
    #@return _ ngrams (hash ref)

    my $tokens = shift;
    my $lemmas = shift;

    my %ngrams;
    
    my $i = 1;
    while (($i <= scalar(@{$tokens})) and ($i <= $BIDICT_MAX_NGRAM_LENGTH)) {
       my $i_ngrams = retrieve_mixed_ngrams($tokens, $lemmas, $i);
       merge_ngrams(\%ngrams, $i_ngrams);
       $i++;
    }	

	return \%ngrams;
}

sub computeCE_bidict_segment_ambiguity($$$$) {
    #description _ computes segment ambiguity scores   (no references)
    #param1  _ segment
    #param2  _ lemma segment
    #param3  _ bidict (hash ref)
    #param4  _ verbosity (0/1)
    #@return _ segment ambiguity (n_translations, total_cases)

    my $segment = shift;
    my $lemma_segment = shift;
    my $bidict = shift;
    my $verbose = shift;

    my @tokens = split(/\s/, $segment);
    my @lemmas = split(/\s/, $lemma_segment);

    if (scalar(@tokens) != scalar(@lemmas)) {
       die "[ERROR] number of tokens and lemmas differ (".scalar(@tokens)." vs. ".scalar(@lemmas).")!!\n".
           "tokens = ".join(" ", @tokens)."\n"."lemmas = ".join(" ", @lemmas)."\n";
    }

    my $ngrams = retrieve_all_mixed_ngrams(\@tokens, \@lemmas);
    
    my $n = 0;
    my $total = 0;
    foreach my $ngram (keys %{$ngrams}) {
       if (exists($bidict->{$ngram})) {
       	  #print Dumper $ngrams->{$ngram};
       	  #print Dumper $bidict->{$ngram};
       	  my $n_occurrences = $ngrams->{$ngram};
       	  my $n_translations = scalar(keys %{$bidict->{$ngram}});
          $n += $n_translations * $n_occurrences;
          $total += $ngrams->{$ngram};
          if ($verbose) {
          	 print "$ngram --> $ngram :: #occurrences = $n_occurrences :: #translations = $n_translations\n";
          }
       }
    }
    
    return ($n, $total);
}

sub computeCE_bidict_ambiguity($$$$) {
    #description _ computes segment ambiguity scores   (no references)
    #param1  _ text file
    #param2  _ text lemma file
    #param3  _ bidict (hash ref)
    #param4  _ verbosity (0/1)
    #@return _ system, segment scores

    my $file = shift;
    my $lemma_file = shift;
    my $bidict = shift;
    my $verbose = shift;

    my $FILE = new IO::File("< $file") or die "Couldn't open input file: $file\n";
    my $LEMMA_FILE = new IO::File("< $lemma_file") or die "Couldn't open input file: $lemma_file\n";
    my @SEGS;
    my $SUM = 0;
    while (defined(my $segment = $FILE->getline())) {
       if (defined(my $lemma_segment = $LEMMA_FILE->getline())) {
          chomp($segment);
          chomp($lemma_segment);
          if ($verbose) {
             print "tokens = $segment\nlemmas = $lemma_segment\n";
          } 
          my ($n, $total) = computeCE_bidict_segment_ambiguity($segment, $lemma_segment, $bidict, $verbose);
          my $ambiguity = Common::safe_division($n, $total);
          my $SEGscore = Common::safe_division(1, $ambiguity);
          if ($verbose) { print "score = 1 / $ambiguity = $SEGscore\n"; }           
          $SUM += $SEGscore;
          push(@SEGS, $SEGscore);
       }
    }
    $FILE->close();
    $LEMMA_FILE->close();

    my $SYS = Common::safe_division($SUM, scalar(@SEGS));

    return($SYS, \@SEGS);
}

sub computeCE_bidict_segment_matching($$$$$$) {
    #description _ computes segment matching scores   (no references)
    #param1  _ source segment
    #param2  _ source lemma segment
    #param3  _ target segment
    #param4  _ target lemma segment
    #param5  _ bidict (hash ref)
    #param6  _ verbosity (0/1)
    #@return _ segment matching (hits, total)

    my $src_segment = shift;
    my $src_lemma_segment = shift;
    my $trg_segment = shift;
    my $trg_lemma_segment = shift;
    my $bidict = shift;
    my $verbose = shift;

    my @src_tokens = split(/\s/, $src_segment);
    my @src_lemmas = split(/\s/, $src_lemma_segment);
    my @trg_tokens = split(/\s/, $trg_segment);
    my @trg_lemmas = split(/\s/, $trg_lemma_segment);

    if ((scalar(@src_tokens) != scalar(@src_lemmas)) or (scalar(@trg_tokens) != scalar(@trg_lemmas))) {
       die "[ERROR] number of tokens and lemmas differ (source -> ".scalar(@src_tokens)." vs. ".scalar(@src_lemmas).
                                                     ", target -> ".scalar(@trg_tokens)." vs. ".scalar(@trg_lemmas).")!!\n".
           "source tokens = ".join(" ", @src_tokens)."\n"."source lemmas = ".join(" ", @src_lemmas)."\n";
           "target tokens = ".join(" ", @trg_tokens)."\n"."target lemmas = ".join(" ", @trg_lemmas)."\n";
    }

    my $src_ngrams = retrieve_all_mixed_ngrams(\@src_tokens, \@src_lemmas);
    my $trg_ngrams = retrieve_all_mixed_ngrams(\@trg_tokens, \@trg_lemmas);
    
    my $hits = 0;
    my $total = 0;
    foreach my $src_ngram (keys %{$src_ngrams}) {
       if (exists($bidict->{$src_ngram})) {
       	  my $n_source = $src_ngrams->{$src_ngram};
       	  my $n_target = 0;
          foreach my $trg_ngram (keys %{$bidict->{$src_ngram}}) {
             if (exists($trg_ngrams->{$trg_ngram})) { $n_target += $trg_ngrams->{$trg_ngram}; }
          }
          $hits += min($n_source, $n_target);
          $total += max($n_source, $n_target);
          if ($verbose) {
          	 print "ngram --> $src_ngram :: #source = $n_source :: #target = $n_target  [$hits/$total]\n";
          }
       }
    }
    
    return ($hits, $total);
}

sub computeCE_bidict_matching($$$$$$) {
    #description _ computes segment matching scores   (no references)
    #param1  _ source text file
    #param2  _ source text lemma file
    #param3  _ target text file
    #param4  _ target text lemma file
    #param5  _ bidict (hash ref)
    #param6  _ verbosity (0/1)
    #@return _ system, segment scores

    my $src_file = shift;
    my $src_lemma_file = shift;
    my $trg_file = shift;
    my $trg_lemma_file = shift;
    my $bidict = shift;
    my $verbose = shift;

    my $SRC_FILE = new IO::File("< $src_file") or die "Couldn't open input file: $src_file\n";
    my $SRC_LEMMA_FILE = new IO::File("< $src_lemma_file") or die "Couldn't open input file: $src_lemma_file\n";
    my $TRG_FILE = new IO::File("< $trg_file") or die "Couldn't open input file: $trg_file\n";
    my $TRG_LEMMA_FILE = new IO::File("< $trg_lemma_file") or die "Couldn't open input file: $trg_lemma_file\n";
    my @SEGS;
    my $SUM = 0;
    while (defined(my $src_segment = $SRC_FILE->getline())) {
       if (defined(my $src_lemma_segment = $SRC_LEMMA_FILE->getline()) and
           defined(my $trg_segment = $TRG_FILE->getline()) and
           defined(my $trg_lemma_segment = $TRG_LEMMA_FILE->getline())) {
          chomp($src_segment);
          chomp($src_lemma_segment);
          chomp($trg_segment);
          chomp($trg_lemma_segment);
          if ($verbose) {
             print "source tokens = $src_segment\nsource lemmas = $src_lemma_segment\n";
             print "target tokens = $trg_segment\ntarget lemmas = $trg_lemma_segment\n";
          } 
          my ($hits, $total) = computeCE_bidict_segment_matching($src_segment, $src_lemma_segment, $trg_segment, $trg_lemma_segment, $bidict, $verbose);
          my $SEGscore = Common::safe_division($hits, $total);
          if ($verbose) { print "score = $hits / $total = $SEGscore\n"; }           
          $SUM += $SEGscore;
          push(@SEGS, $SEGscore);
       }
    }
    $SRC_FILE->close();
    $SRC_LEMMA_FILE->close();
    $TRG_FILE->close();
    $TRG_LEMMA_FILE->close();

    my $SYS = Common::safe_division($SUM, scalar(@SEGS));

    return($SYS, \@SEGS);
}

sub doCE {
    #description _ computes CE scores   (no references)
    #param1  _ configuration
    #param2  _ target NAME
    #param3  _ candidate file
    #param4  _ reference file
    #param5  _ hash of scores
 
    my $config = shift;
    my $TGT = shift;
    my $out = shift;
    my $REF = shift;
	 my $hOQ = shift;
	 
    my $src = $config->{src};                    # source file 
    my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
    my $tools = $config->{tools};                # TOOL directory
    my $SRCLANG = $config->{SRCLANG};            # source language
    my $TRGLANG = $config->{LANG};               # target language
    my $SRCCASE = $config->{SRCCASE};            # source case
    my $TRGCASE = $config->{CASE};               # target case
    my $M = $config->{Hmetrics};                 # set of metrics
    my $verbose = $config->{verbose};            # verbosity (0/1)
    my $debug = $config->{debug};                # verbosity (0/1)
    my $IDX = $config->{IDX};                    # sys-doc-seg index structure
    my $SRCparser = $config->{SRCparser};        # source-language shallow parser (object)
    my $TRGparser = $config->{parser};           # target-language shallow parser (object)

    my $GO = 0; my $i = 0;
    my @mCE = keys %{$CE::rCE};
    while (($i < scalar(@mCE)) and (!$GO)) { if (exists($M->{$mCE[$i]})) { $GO = 1; } $i++; }

    if ($GO) {
       if ($verbose == 1) { print STDERR "$CE::CEEXT.."; }
       ### TRANSLATION DIFFICULTY ###
       # LENGTH
       my $reportCEsrclenXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-srclen.$Common::XMLEXT";
       if (((!(-e $reportCEsrclenXML) and !(-e $reportCEsrclenXML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-srclen"}) { #source length ratio
          my ($sys_score, $SEGS) = CE::computeCE_segment_length($src, $debug);
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-srclen", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-srclen", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }
       # LANGUAGE MODELING
       my $reportCEsrclogpXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-srclogp.$Common::XMLEXT";
       my $reportCEsrcipplXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-srcippl.$Common::XMLEXT";
       my $reportCEsrcoovXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-srcoov.$Common::XMLEXT";
       if (((!(-e $reportCEsrclogpXML) and !(-e $reportCEsrclogpXML.".$Common::GZEXT")) or
            (!(-e $reportCEsrcipplXML) and !(-e $reportCEsrcipplXML.".$Common::GZEXT")) or
            (!(-e $reportCEsrcoovXML) and !(-e $reportCEsrcoovXML.".$Common::GZEXT")) or $remakeREPORTS)
           and ($M->{"$CEEXT-srclogp"} or $M->{"$CEEXT-srcippl"} or $M->{"$CEEXT-srcoov"})) { #source language modeling
          my ($SYS, $SEGS) = CE::compute_language_modeling_features($src, $SRCLANG, $SRCCASE, $tools, $CE::raw, $debug);
          #log probabilities
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"logp"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-srclogp", $SYS->{"logp"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-srclogp", $TGT, $REF, $SYS->{"logp"}, $doc_scores, $seg_scores,$hOQ);
          #inverse perplexities
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"ippl"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-srcippl", $SYS->{"ippl"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-srcippl", $TGT, $REF, $SYS->{"ippl"}, $doc_scores, $seg_scores,$hOQ);
          #proportion of Out-of-vocabulary (OOV) tokens
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"oov"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-srcoov", $SYS->{"oov"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-srcoov", $TGT, $REF, $SYS->{"oov"}, $doc_scores, $seg_scores,$hOQ);
       }
       my $reportCEsrclogp_pos_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-srclogpP.$Common::XMLEXT";
       my $reportCEsrcippl_pos_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-srcipplP.$Common::XMLEXT";
       if (((!(-e $reportCEsrclogp_pos_XML) and !(-e $reportCEsrclogp_pos_XML.".$Common::GZEXT")) or
            (!(-e $reportCEsrcippl_pos_XML) and !(-e $reportCEsrcippl_pos_XML.".$Common::GZEXT")) or $remakeREPORTS)
           and ($M->{"$CEEXT-srclogpP"} or $M->{"$CEEXT-srcipplP"})) { #source PoS language modeling
          my $src_posfile = SP::create_PoS_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my ($SYS, $SEGS) = CE::compute_language_modeling_features($src_posfile, $SRCLANG, $SRCCASE, $tools, $CE::pos, $debug);
          system("$Common::GZIP $src_posfile");
          #log probabilities
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"logp"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-srclogpP", $SYS->{"logp"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-srclogpP", $TGT, $REF, $SYS->{"logp"}, $doc_scores, $seg_scores,$hOQ);
          #inverse perplexities
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"ippl"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-srcipplP", $SYS->{"ippl"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-srcipplP", $TGT, $REF, $SYS->{"ippl"}, $doc_scores, $seg_scores,$hOQ);
       }   
       my $reportCEsrclogp_chunk_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-srclogpC.$Common::XMLEXT";
       my $reportCEsrcippl_chunk_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-srcipplC.$Common::XMLEXT";
       if (((!(-e $reportCEsrclogp_chunk_XML) and !(-e $reportCEsrclogp_chunk_XML.".$Common::GZEXT")) or
            (!(-e $reportCEsrcippl_chunk_XML) and !(-e $reportCEsrcippl_chunk_XML.".$Common::GZEXT")) or $remakeREPORTS)
           and ($M->{"$CEEXT-srclogpC"} or $M->{"$CEEXT-srcipplC"})) { #source Chunk language modeling
          my $src_chunkfile = SP::create_chunk_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my ($SYS, $SEGS) = CE::compute_language_modeling_features($src_chunkfile, $SRCLANG, $SRCCASE, $tools, $CE::chunk, $debug);
          system("$Common::GZIP $src_chunkfile");
          #log probabilities
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"logp"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-srclogpC", $SYS->{"logp"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-srclogpC", $TGT, $REF, $SYS->{"logp"}, $doc_scores, $seg_scores,$hOQ);
          #inverse perplexities
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"ippl"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-srcipplC", $SYS->{"ippl"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-srcipplC", $TGT, $REF, $SYS->{"ippl"}, $doc_scores, $seg_scores,$hOQ);
       }

       ### FLUENCY ###
       # LANGUAGE MODELING
       my $reportCElogpXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-logp.$Common::XMLEXT";
       my $reportCEipplXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-ippl.$Common::XMLEXT";
       my $reportCEoovXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-oov.$Common::XMLEXT";
       if (((!(-e $reportCElogpXML) and !(-e $reportCElogpXML.".$Common::GZEXT")) or
            (!(-e $reportCEipplXML) and !(-e $reportCEipplXML.".$Common::GZEXT")) or
            (!(-e $reportCEoovXML) and !(-e $reportCEoovXML.".$Common::GZEXT")) or $remakeREPORTS)
           and ($M->{"$CEEXT-logp"} or $M->{"$CEEXT-ippl"} or $M->{"$CEEXT-oov"})) { #target language modeling
          my ($SYS, $SEGS) = CE::compute_language_modeling_features($out, $TRGLANG, $TRGCASE, $tools, $CE::raw, $debug);
          #log probabilities
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"logp"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-logp", $SYS->{"logp"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-logp", $TGT, $REF, $SYS->{"logp"}, $doc_scores, $seg_scores,$hOQ);
          #inverse perplexities
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"ippl"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-ippl", $SYS->{"ippl"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-ippl", $TGT, $REF, $SYS->{"ippl"}, $doc_scores, $seg_scores,$hOQ);
          #proportion of Out-of-vocabulary (OOV) tokens
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"oov"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-oov", $SYS->{"oov"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-oov", $TGT, $REF, $SYS->{"oov"}, $doc_scores, $seg_scores,$hOQ);
       }
       my $reportCElogp_pos_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-logpP.$Common::XMLEXT";
       my $reportCEippl_pos_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-ipplP.$Common::XMLEXT";
       if (((!(-e $reportCElogp_pos_XML) and !(-e $reportCElogp_pos_XML.".$Common::GZEXT")) or
            (!(-e $reportCEippl_pos_XML) and !(-e $reportCEippl_pos_XML.".$Common::GZEXT")) or $remakeREPORTS)
           and ($M->{"$CEEXT-logpP"} or $M->{"$CEEXT-ipplP"})) { #target PoS language modeling
          my $out_posfile = SP::create_PoS_file($out, $TRGparser, $tools, $TRGLANG, $TRGCASE, $verbose);
          my ($SYS, $SEGS) = CE::compute_language_modeling_features($out_posfile, $TRGLANG, $TRGCASE, $tools, $CE::pos, $debug);
          system("$Common::GZIP $out_posfile");
          #log probabilities
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"logp"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-logpP", $SYS->{"logp"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-logpP", $TGT, $REF, $SYS->{"logp"}, $doc_scores, $seg_scores,$hOQ);
          #inverse perplexities
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"ippl"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-ipplP", $SYS->{"ippl"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-ipplP", $TGT, $REF, $SYS->{"ippl"}, $doc_scores, $seg_scores,$hOQ);
       }
       my $reportCElogp_chunk_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-logpC.$Common::XMLEXT";
       my $reportCEippl_chunk_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-ipplC.$Common::XMLEXT";
       if (((!(-e $reportCElogp_chunk_XML) and !(-e $reportCElogp_chunk_XML.".$Common::GZEXT")) or
            (!(-e $reportCEippl_chunk_XML) and !(-e $reportCEippl_chunk_XML.".$Common::GZEXT")) or $remakeREPORTS)
           and ($M->{"$CEEXT-logpC"} or $M->{"$CEEXT-ipplC"})) { #target Chunk language modeling
          my $out_chunkfile = SP::create_chunk_file($out, $TRGparser, $tools, $TRGLANG, $TRGCASE, $verbose);
          my ($SYS, $SEGS) = CE::compute_language_modeling_features($out_chunkfile, $TRGLANG, $TRGCASE, $tools, $CE::chunk, $debug);
          system("$Common::GZIP $out_chunkfile");
          #log probabilities
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"logp"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-logpC", $SYS->{"logp"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-logpC", $TGT, $REF, $SYS->{"logp"}, $doc_scores, $seg_scores,$hOQ);
          #inverse perplexities
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"ippl"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-ipplC", $SYS->{"ippl"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-ipplC", $TGT, $REF, $SYS->{"ippl"}, $doc_scores, $seg_scores,$hOQ);
       }
       
       ### ADEQUACY ####
       # LENGTH RATIOS
       my $reportCElengthXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-length.$Common::XMLEXT";
       my $reportCElongXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-long.$Common::XMLEXT";
       my $reportCEshortXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-short.$Common::XMLEXT";
       if (((!(-e $reportCElengthXML) and !(-e $reportCElengthXML.".$Common::GZEXT")) or
            (!(-e $reportCElongXML) and !(-e $reportCElongXML.".$Common::GZEXT")) or
            (!(-e $reportCEshortXML) and !(-e $reportCEshortXML.".$Common::GZEXT")) or $remakeREPORTS)
           and ($M->{"$CEEXT-length"} or $M->{"$CEEXT-long"} or $M->{"$CEEXT-short"})) { #source / target length ratio
          my ($SYS, $SEGS) = CE::computeCE_length_ratio($src, $out, $SRCLANG, $TRGLANG, $debug);
          #length ratio
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"length"}, 0, $config->{IDX}->{$TGT});
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-length", $SYS->{"length"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-length", $TGT, $REF, $SYS->{"length"}, $doc_scores, $seg_scores,$hOQ);
          #lenghtiness ratio
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"long"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-long", $SYS->{"long"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-long", $TGT, $REF, $SYS->{"long"}, $doc_scores, $seg_scores,$hOQ);
          #shortness ratio
          ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS->{"short"}, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-short", $SYS->{"short"}, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-short", $TGT, $REF, $SYS->{"short"}, $doc_scores, $seg_scores,$hOQ);
       }
       # SYMBOL OVERLAP (punctuation, numbers, ...)
       my $reportCEsymbolXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-symbols.$Common::XMLEXT";
       if (((!(-e $reportCEsymbolXML) and !(-e $reportCEsymbolXML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-symbols"}) { #source / target punctuation and numerical symbols overlap
          my ($sys_score, $SEGS) = CE::computeCE_symbol_overlap($src, $out, $debug);
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-symbols", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-symbols", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }
       # Op --- PoS overlap
       my $reportCE_Op_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-Op.$Common::XMLEXT";
       if (((!(-e $reportCE_Op_XML) and !(-e $reportCE_Op_XML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-Op"}) { #PoS overlap
          my $out_posfile = SP::create_PoS_file($out, $TRGparser, $tools, $TRGLANG, $TRGCASE, $verbose);
          my $src_posfile = SP::create_PoS_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my ($sys_score, $SEGS) = Overlap::computeOl($out_posfile, $src_posfile, $debug);
          system("$Common::GZIP $out_posfile");
          system("$Common::GZIP $src_posfile");
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-Op", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-Op", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }
       # Oc --- chunk overlap
       my $reportCE_Oc_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-Oc.$Common::XMLEXT";
       if (((!(-e $reportCE_Oc_XML) and !(-e $reportCE_Oc_XML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-Oc"}) { #Chunk overlap
          my $out_chunkfile = SP::create_chunk_file($out, $TRGparser, $tools, $TRGLANG, $TRGCASE, $verbose);
          my $src_chunkfile = SP::create_chunk_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my ($sys_score, $SEGS) = Overlap::computeOl($out_chunkfile, $src_chunkfile, $debug);
          system("$Common::GZIP $out_chunkfile");
          system("$Common::GZIP $src_chunkfile");
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-Oc", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-Oc", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }    
       # Nc --- chunk N ratio   
       my $reportCE_Nc_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-Nc.$Common::XMLEXT";
       if (((!(-e $reportCE_Nc_XML) and !(-e $reportCE_Nc_XML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-Nc"}) { #Chunk overlap
          my $out_chunkfile = SP::create_chunk_file($out, $TRGparser, $tools, $TRGLANG, $TRGCASE, $verbose);
          my $src_chunkfile = SP::create_chunk_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my ($sys_score, $SEGS) = Overlap::computeOn($out_chunkfile, $src_chunkfile, $debug);
          system("$Common::GZIP $out_chunkfile");
          system("$Common::GZIP $src_chunkfile");
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-Nc", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-Nc", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }    

       # Oe --- NE overlap
       my $reportCE_Oe_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-Oe.$Common::XMLEXT";
       if (((!(-e $reportCE_Oe_XML) and !(-e $reportCE_Oe_XML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-Oe"}) { #NE overlap
          my $out_NEfile = NE::create_NE_file($out, $TRGparser, $tools, $TRGLANG, $TRGCASE, $verbose);
          my $src_NEfile = NE::create_NE_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my ($sys_score, $SEGS) = Overlap::computeOl($out_NEfile, $src_NEfile, $debug);
          system("$Common::GZIP $out_NEfile");
          system("$Common::GZIP $src_NEfile");
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-Oe", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-Oe", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }    
       # Ne --- NE N ratio
       my $reportCE_Ne_XML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-Ne.$Common::XMLEXT";
       if (((!(-e $reportCE_Ne_XML) and !(-e $reportCE_Ne_XML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-Ne"}) { #NE overlap
          my $out_NEfile = NE::create_NE_file($out, $TRGparser, $tools, $TRGLANG, $TRGCASE, $verbose);
          my $src_NEfile = NE::create_NE_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my ($sys_score, $SEGS) = Overlap::computeOn($out_NEfile, $src_NEfile, $debug);
          system("$Common::GZIP $out_NEfile");
          system("$Common::GZIP $src_NEfile");
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-Ne", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-Ne", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }    

       ### MARIANO Felice duties!!
       
       ### falta entrenar para SPA --> NE, DP... SR?

       ########## Od --- DP overlap   use MALT!!
       # Nd --- DP N ratio
       
       ########## Or --- SR overlap
       # Nr --- SR N ratio
       #create SR file
              
       #bilingual dictionary based measures (translation difficulty and adequacy) ---
       #  - we can use WordNet for English (translation difficulty based on number of senses)
       #    but not for other languages... because MCR is not free
       #  - we can build bilingual dicts out from MCR es-en es-ca en-ca, etc... (based on variants)
       #  - we can use bilingual dicts from Apertium project

       # --------------------------------
       # BiDictA (ambiguity)
       my $bidict = undef;
       my $reportCEBiDictAXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-BiDictA.$Common::XMLEXT";
       if (((!(-e $reportCEBiDictAXML) and !(-e $reportCEBiDictAXML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-BiDictA"}) { #source ambiguity according to a bilingual dictionary
          if (!defined($bidict)) { $bidict = load_bidict($tools, $SRCLANG, $TRGLANG); }
          my $src_lemmafile = SP::create_lemma_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my ($sys_score, $SEGS) = CE::computeCE_bidict_ambiguity($src, $src_lemmafile, $bidict, $debug);
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-BiDictA", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-BiDictA", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }
       # BiDictO (overlap)
       my $reportCEBiDictOXML = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$CEEXT/$CEEXT-BiDictO.$Common::XMLEXT";
       if (((!(-e $reportCEBiDictOXML) and !(-e $reportCEBiDictOXML.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"$CEEXT-BiDictO"}) { #source ambiguity according to a bilingual dictionary
          if (!defined($bidict)) { $bidict = load_bidict($tools, $SRCLANG, $TRGLANG); }
          my $src_lemmafile = SP::create_lemma_file($src, $SRCparser, $tools, $SRCLANG, $SRCCASE, $verbose);
          my $trg_lemmafile = SP::create_lemma_file($out, $TRGparser, $tools, $TRGLANG, $TRGCASE, $verbose);
          my ($sys_score, $SEGS) = CE::computeCE_bidict_matching($src, $src_lemmafile, $out, $trg_lemmafile, $bidict, $debug);
          my ($doc_scores, $seg_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
          if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $CE::CEEXT, "$CEEXT-BiDictO", $sys_score, $doc_scores, $seg_scores, $IDX->{$TGT}, $verbose); }
          Scores::save_hash_scores("$CEEXT-BiDictO", $TGT, $REF, $sys_score, $doc_scores, $seg_scores,$hOQ);
       }
    }
}

1;
