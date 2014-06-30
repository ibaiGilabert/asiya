package Common;

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
use Benchmark;
use Unicode::String;
use File::Basename;
use Encode;
use Data::Dumper;

our($SGMLEXT, $REPORTEXT, $SRCEXT, $REFEXT, $SYSEXT, $XMLEXT, $TXTEXT, $IDXEXT, $DOCEXT, $TOKEXT, $GZEXT, $GZIP, $GUNZIP, $TOOLS,
    $VERSION, $appVERSION, $appNAME, $appYEAR, $CASE_CS, $CASE_CI, $CASE_DEFAULT,
    $L_ENG, $L_SPA, $L_CAT, $L_ARA, $L_FRN, $L_ROM, $L_GER, $L_CZE, $L_ITA, $L_CHN, $L_DEFAULT, $L_OTHER, $rLANGS,
    $L_DAN, $L_FIN, $L_HUN,$L_DUT, $L_NOR, $L_POR, $L_RUS, $L_SWE, $L_TUR,
    $G_SYS, $G_DOC, $G_SEG, $G_ALL, $G_DEFAULT, $I_RAW, $I_NIST, $I_DEFAULT,
    $O_MMATRIX, $O_SMATRIX, $O_RLISTS, $O_NIST, $O_NONE, $O_DEFAULT, $SORT_NAME, $SORT_SCORE, $SORT_DEFAULT, $O_STORAGE,
    $DEFAULT_EVAL_CRITERION, $S_SINGLE, $S_ULC, $S_QUEEN, $S_MODEL, $eval_schemes,
    $DEFAULT_METAEVAL_CRITERION, $C_CONSISTENCY, $C_MRANKENDALL, $C_KING, $C_ORANGE, $C_PEARSON, $C_SPEARMAN, $C_KENDALL, $C_REGRESSION, $rCORRS, $rMRANKS,
    $CI_NONE, $CI_FISHER, $CI_BOOTSTRAP, $CI_EXHAUSTIVE_BOOTSTRAP, $CI_PAIRED_BOOTSTRAP, $CI_EXHAUSTIVE_PAIRED_BOOTSTRAP, $rCI,
    $CI_DEFAULT, $ALFA_DEFAULT, $N_RESAMPLINGS_DEFAULT, $metaeval_criteria,
    $progress0, $progress1, $progress2, $progress3, $EMPTY_ITEM, $DATA_PATH, $TMP, $REPORTS, $NRAND, $MINVALUE, $SOURCEID,
    $FLOAT_LENGTH_DEFAULT, $FLOAT_PRECISION_DEFAULT, $METRIC_NAME_LENGTH, $HLINE_LENGTH,
    $SET_NAME_LENGTH, $SYS_NAME_LENGTH, $DOC_NAME_LENGTH, $SEG_ID_LENGTH, $MIN_ID_LENGTH,
    $UNKNOWN_SET, $UNKNOWN_LANG, $UNKNOWN_GENRE, $UNKNOWN_DOC, $SENSIBLE_MAX_N,
    $FS_HUGE, $FS_LARGE, $FS_NORMAL, $FS_SMALL, $FS_TINY,
    $ID_SEPARATOR, $CE, $tokenize,
    $LEARN_PERCEPTRON, $MODELS, $MODEL_DEFAULT, $TRAINING_PROPORTION_DEFAULT, $N_EPOCHS_DEFAULT, $MIN_DIST_DEFAULT
   );

#FILE EXTENSIONS
$Common::SGMLEXT = "sgml";
$Common::REPORTEXT = "report";
$Common::SRCEXT = "src";
$Common::REFEXT = "ref";
$Common::SYSEXT = "out";
$Common::XMLEXT = "xml";
$Common::GZEXT = "gz";
$Common::TXTEXT = "txt";
$Common::IDXEXT = "idx";
$Common::DOCEXT = "doc";
$Common::TOKEXT = "tok";

#compression
$Common::GZIP = "gzip -f";
$Common::GUNZIP = "gunzip";

#tools directory
$Common::TOOLS = "tools";

#application details
$Common::VERSION = "3.0";
$Common::appVERSION = "3.0";
$Common::appNAME = "ASIYA";
$Common::appYEAR = "2014";
$Common::appAUTHOR = "Meritxell Gonzalez, Jesus Gimenez";

# languages
$Common::L_ARA = "ar"; #arabic
$Common::L_CAT = "ca"; #catalan
$Common::L_CHN = "ch"; #chinesse
$Common::L_CZE = "cz"; #czech
$Common::L_DAN = "da"; #danish
$Common::L_GER = "de"; #german
$Common::L_ENG = "en"; #english
$Common::L_SPA = "es"; #spanish
$Common::L_FIN = "fi"; #finnish
$Common::L_FRN = "fr"; #french
$Common::L_HUN = "hu"; #hungarian
$Common::L_ITA = "it"; #italian
$Common::L_DUT = "nl"; #dutch
$Common::L_NOR = "no"; #norwegian
$Common::L_POR = "pt"; #portuguese
$Common::L_ROM = "ro"; #romanian
$Common::L_RUS = "ru"; #russian
$Common::L_SWE = "sv"; #swedish
$Common::L_TUR = "tr"; #turkish
$Common::L_OTHER = "other";
$Common::L_DEFAULT = $Common::L_ENG;
$Common::rLANGS = { $Common::L_ENG => 1, $Common::L_SPA => 1, $Common::L_CAT => 1, $Common::L_GER => 1, $Common::L_FRN => 1, $Common::L_CZE => 1, $Common::L_ARA => 1, 
                    $Common::L_DAN => 1, $Common::L_FIN => 1, $Common::L_HUN => 1, $Common::L_ITA => 1, $Common::L_DUT => 1, $Common::L_NOR => 1, 
                    $Common::L_POR => 1, $Common::L_ROM => 1, $Common::L_RUS => 1, $Common::L_SWE => 1, $Common::L_TUR => 1, $Common::L_OTHER => 1 };

# granularity
$Common::G_SYS = "sys";
$Common::G_DOC = "doc";
$Common::G_SEG = "seg";
$Common::G_ALL = "all";
$Common::G_DEFAULT = $Common::G_SYS;

# output format
$Common::O_MMATRIX = "mmatrix";
$Common::O_SMATRIX = "smatrix";
$Common::O_RLISTS = "rlists";
$Common::O_NIST = "nist";
$Common::O_NONE = "none";
$Common::O_DEFAULT = $Common::O_MMATRIX;
$Common::SORT_NAME = "name";
$Common::SORT_SCORE = "score";
$Common::SORT_NONE = "none";
$Common::SORT_DEFAULT = $Common::SORT_NONE;
$Common::O_STORAGE = 1;

# evaluation
$Common::S_SINGLE = "single";
$Common::S_ULC = "ulc";
$Common::S_QUEEN = "queen";
$Common::S_MODEL = "model";
$Common::eval_schemes = { $Common::S_SINGLE => 1, $Common::S_ULC => 1,
	                      $Common::S_QUEEN => 1, $Common::S_MODEL => 1 };
$Common::DEFAULT_EVAL_CRITERION = $Common::S_SINGLE;

# learning
$Common::LEARN_PERCEPTRON = "perceptron";
$Common::TRAINING_PROPORTION_DEFAULT = 0.8;
$Common::N_EPOCHS_DEFAULT = 100;
$Common::MIN_DIST_DEFAULT = 0;
$Common::MODELS = "models";
$Common::MODEL_DEFAULT = "$Common::MODELS/$Common::LEARN_PERCEPTRON.mod";

# meta-evaluation
$Common::C_REGRESSION = "regression";
$Common::C_PEARSON = "pearson";
$Common::C_SPEARMAN = "spearman";
$Common::C_KENDALL = "kendall";
$Common::CI_NONE = "none";
$Common::CI_FISHER = "fisher";
$Common::CI_BOOTSTRAP = "bootstrap";
$Common::CI_EXHAUSTIVE_BOOTSTRAP = "xbootstrap";
$Common::CI_PAIRED_BOOTSTRAP = "paired_bootstrap";
$Common::CI_EXHAUSTIVE_PAIRED_BOOTSTRAP = "paired_xbootstrap";
$Common::CI_DEFAULT = $Common::CI_NONE;
$Common::rCI = { $Common::CI_FISHER => 1, $Common::CI_BOOTSTRAP => 1, $Common::CI_EXHAUSTIVE_BOOTSTRAP => 1,
	             $Common::CI_PAIRED_BOOTSTRAP => 1, $Common::CI_EXHAUSTIVE_PAIRED_BOOTSTRAP => 1,
	             $Common::CI_NONE => 1 };
$Common::ALFA_DEFAULT = 0.05;
$Common::N_RESAMPLINGS_DEFAULT = 1000;
$Common::rCORRS = { $Common::C_PEARSON => 1, $Common::C_SPEARMAN => 1, $Common::C_KENDALL => 1 };
$Common::C_KING = "king";
$Common::C_ORANGE = "orange";
$Common::C_CONSISTENCY = "consistency";
$Common::C_MRANKENDALL = "mrankskendall";
$Common::rMRANKS = { $Common::C_CONSISTENCY => 1, $Common::C_MRANKENDALL => 1 };
$Common::metaeval_criteria = { $Common::C_PEARSON => 1, $Common::C_SPEARMAN => 1, $Common::C_KENDALL => 1, $Common::C_KING => 1, $Common::C_ORANGE =>1, $Common::C_CONSISTENCY => 1, $Common::C_MRANKENDALL => 1 };
$Common::DEFAULT_METAEVAL_CRITERION = $Common::C_ORANGE;

#input file format
$Common::I_NIST = "nist";
$Common::I_RAW = "raw";
$Common::I_DEFAULT = $Common::I_NIST;
$Common::tokenize = 1;

#text case
$Common::CASE_CS = "cs";
$Common::CASE_CI = "ci";
$Common::CASE_DEFAULT = $Common::CASE_CS;

#progress values
$Common::progress0 = 10;
$Common::progress1 = 100;
$Common::progress2 = 1000;
$Common::progress3 = 10000;

#font sizes
$Common::FS_HUGE = "huge";
$Common::FS_LARGE = "large";
$Common::FS_NORMAL = "normal";
$Common::FS_SMALL = "small";
$Common::FS_TINY = "tiny";
$Common::FS_DEFAULT = $Common::FS_NORMAL;

#other constants
$Common::EMPTY_ITEM = "***EMPTY***";
$Common::DATA_PATH = ".";
$Common::ALIGN = "alignments";
$Common::TMP = "tmp";
$Common::REPORTS = "scores";
$Common::NRAND = 10000;
$Common::MINVALUE = -99999999;
$Common::SOURCEID = "source";
$Common::FLOAT_LENGTH_DEFAULT = 10;
$Common::FLOAT_PRECISION_DEFAULT = 8;
$Common::METRIC_NAME_LENGTH = 12;
$Common::SET_NAME_LENGTH = 40;
$Common::SYS_NAME_LENGTH = 30;
$Common::DOC_NAME_LENGTH = 30;
$Common::SEG_ID_LENGTH = 10;
$Common::MIN_ID_LENGTH = 3;
$Common::HLINE_LENGTH = 120;
$Common::UNKNOWN_SET = "UNKNOWN_SET";
$Common::UNKNOWN_LANG = "UNKNOWN_LANG";
$Common::UNKNOWN_GENRE = "UNKNOWN_GENRE";
$Common::UNKNOWN_DOC = "UNKNOWN_DOC";
$Common::SENSIBLE_MAX_N = 1000000;
$Common::ID_SEPARATOR = "@@";
$Common::CE = "CE";
$Common::LeM = "LeM";


sub replace_utf8_char($$$) {
    #description _ returns given string replacing evey occurrence of the given utf-8 character by the given replacement
    #param1  _ input string
    #param2  _ utf-8 code
    #param3  _ replacement
    #@return _ replaced string
    
    my $string = shift;
    my $char = shift;
    my $newchar = shift;
    
    my $utf8_str = encode('utf-8', $char);
    
    my $newstring = $string;
    $newstring =~ s/$utf8_str/$newchar/g;
    
    return $newstring;
}

sub normalize_utf8_characters($) {
    #description _ normalize utf-8 characters (quotation, hyphen, three dots...)
    #param1  _ input string
    #@return _ utf-8 normalized string

    my $line = shift;
	
    my $newline = $line;
    #apostrophe
    $newline = replace_utf8_char($newline, "\x{0060}", "'");       
    $newline = replace_utf8_char($newline, "\x{00B4}", "'");       
    $newline = replace_utf8_char($newline, "\x{2018}", "'");       
    $newline = replace_utf8_char($newline, "\x{2019}", "'");       
    $newline = replace_utf8_char($newline, "\x{02BC}", "'");       
    #quotation
    $newline = replace_utf8_char($newline, "\x{00AB}", "\"");       
    $newline = replace_utf8_char($newline, "\x{00BB}", "\"");       
    $newline = replace_utf8_char($newline, "\x{201C}", "\"");       
    $newline = replace_utf8_char($newline, "\x{201D}", "\"");       
    #hyphen
    $newline = replace_utf8_char($newline, "\x{002D}", "-");       
    $newline = replace_utf8_char($newline, "\x{2010}", "-");       
    $newline = replace_utf8_char($newline, "\x{2011}", "-");       
    $newline = replace_utf8_char($newline, "\x{2012}", "-");       
    $newline = replace_utf8_char($newline, "\x{2013}", "-");
    $newline = replace_utf8_char($newline, "\x{2014}", "-");       
    $newline = replace_utf8_char($newline, "\x{2015}", "-");       
    $newline = replace_utf8_char($newline, "\x{207B}", "-");       
    $newline = replace_utf8_char($newline, "\x{208B}", "-");       
    $newline = replace_utf8_char($newline, "\x{2212}", "-");
    #three dots       
    $newline = replace_utf8_char($newline, "\x{2026}", "...");
    #currency symbols
    #$newline = replace_utf8_char($newline, "\x{00A3}", "£");
    #$newline = replace_utf8_char($newline, "\x{20AC}", "€");
    
    return $newline;
}

sub sort_list($$) {
    my $list = shift;
    my $criterion = shift;
    
    my @sorted_list;
    if ($criterion eq $Common::SORT_NAME) { @sorted_list = sort @{$list}; }
    else { @sorted_list = @{$list}; }
    	
	return \@sorted_list;
}

sub get_language_name_from_abbreviation {
    my $abbrev = shift;
    
    my $language = "unknown";
    if (exists($Common::rLANGS->{$abbrev})) { $language = $Common::rLANGS->{$abbrev}; }
	
	return $language;
}

sub get_case_expansion_from_abbreviation {
    my $abbrev = shift;
    
    my $case = "unknown";
    if ($abbrev eq $Common::CASE_CS) { $case = "case sensitive"; }
    elsif ($abbrev eq $Common::CASE_CI) { $case = "case insensitive"; }
	
	return $case;
}

#$Common::XmlEntities = {
#	'&amp;'  => '&',
#	'&lt;'   => '<',
#	'&gt;'   => '>',
#	'&apos;' => '\'',
#	'&quot;' => '"'
#};

#$Common::XmlEntities_REV = {
#	'&'  => '&amp;',
#	'<'  => '&lt;',
#	'>'  => '&gt;',
#	'\'' => '&apos;',
#	'"'  => '&quot;'
#};

sub replace_xml_entities {
    #description _ substitutes xml entities in a given string for its associated actual value.
    #param1  _ input string
    #@return _ output string (free of xml entities)

    my $string = shift;

    $string =~ s/\& *lt *;/</g;
    $string =~ s/\& *gt *;/>/g;
    $string =~ s/\& *apos *;/\'/g;
    $string =~ s/\& *quot *;/\"/g;
    $string =~ s/\& *amp *;/&/g;

    return $string;
}

sub replace_xml_entities_REV {
    #description _ substitutes conflicting characters in a given string for its associated xml entities.
    #param1  _ input string
    #@return _ output string (free of xml entities)

    my $string = shift;

    my $output = replace_xml_entities($string);

    $output =~ s/&/\&amp;/g;
    $output =~ s/</\&lt;/g;
    $output =~ s/>/\&gt;/g;
    $output =~ s/\'/\&apos;/g;
    $output =~ s/\´/\&apos;/g;
    $output =~ s/\"/\&quot;/g;

    return $output;
}

sub remove_carriage_return {
    #description _ removes trailing "\r" character, if present
    #param1  _ input string
    #@return _ output string (free of "\r" character)

    my $string = shift;
    
    $string =~ s/\r$//;

    return $string;
}

sub f_measure {
    #description _ computes F measure
    #param1  _ Precision
    #param1  _ Recall
    #param1  _ Beta
    #@return _ F measure

    my $p = shift;
    my $r = shift;
    my $beta = shift;

    return safe_division((1 + $beta**2) * $p * $r, $beta**2 * $p + $r);
}

sub safe_division {
    #description _ if denominator is different from 0 returns regular division; otherwise returns default value (0 if not specified)
    #param1  _ numerator
    #param2  _ denominator
    #param3  _ default value
    #@return _ safe division

    my $numerator = shift;
    my $denominator = shift;
    my $default = shift;
    
    if (!defined($default)) { $default = 0; }
  
    if (!defined($denominator)) { $denominator = 0; }
    
    if ($denominator == 0) { return $default; }
    
    return $numerator / $denominator;
}


sub sign {
    #description _ sign of the number  
    #param1  _ number
    #@return _ {-1,0,1}
    my $x = shift;
    return 0 if $x == 0;
    return $x > 0 ? 1 : -1;
}

sub display_application_title {
    #description _ display application name, version, year, and authory

    Common::print_hline_stderr('-', $Common::HLINE_LENGTH);
    print STDERR "$Common::appNAME v$Common::appVERSION\n";
    print STDERR "(C) $Common::appYEAR. TALP, Technical University of Catalonia (written by $Common::appAUTHOR)\n";
    Common::print_hline_stderr('-', $Common::HLINE_LENGTH);
}

sub show_progress {
    #description _ prints progress bar onto standard error output
    #param1 _ iteration number
    #param2 _ print "." after N p1 iterations
    #param3 _ print "#iter" after N p2 iterations

    my $iter = shift;
    my $p1 = shift;
    my $p2 = shift;

    if (($iter % $p1) == 0) { print STDERR "."; }
    if (($iter % $p2) == 0) { print STDERR "$iter"; }
}

sub print_hline {
    #description _ print horizontal line
    #param1 _ character
    #param1 _ length

    my $c = shift;
    my $l = shift;

    my $line = "";
    for (my $i = 0; $i < $l; $i++) { $line .= $c; } 
    print "$line\n";
}

sub print_hline_stderr {
    #description _ print horizontal line
    #param1 _ character
    #param1 _ length

    my $c = shift;
    my $l = shift;

    my $line = "";
    for (my $i = 0; $i < $l; $i++) { $line .= $c; } 
    print STDERR "$line\n";
}

sub sprint_hline {
    #description _ print horizontal line
    #param1 _ character
    #param1 _ length

    my $c = shift;
    my $l = shift;

    my $line = "";
    for (my $i = 0; $i < $l; $i++) { $line .= $c; } 
    return $line;
}
sub get_raw_benchmark
{
    #description _ returns the benchmark time
    #param1  _ first benchmark
    #param2  _ second benchmark
    #@return _ time difference

    my $time1 = shift;
    my $time2 = shift;

    #print Benchmark::timestr(Benchmark::timediff($time2, $time1));
    
    my $T = Benchmark::timediff($time2, $time1);
    return $T->[1] + $T->[2] + $T->[3] + $T->[4];
}

sub get_benchmark
{
    #description _ returns the benchmark time
    #param1  _ first benchmark
    #param2  _ second benchmark
    #@return _ time difference

    my $time1 = shift;
    my $time2 = shift;

    #print Benchmark::timestr(Benchmark::timediff($time2, $time1));
    
    return (Benchmark::timediff($time2, $time1))->[1];
}

sub give_system_name {
    #description _ get system name from filename
    #param1  _ filename
    #@return _ system name
    
    my $fullname = shift;

    my @suffixlist = (); #(".txt", ".sgm", ".sgml");
    
    my ($basename,$path,$suffix) = fileparse($fullname, @suffixlist);
    
    return $basename;
}

sub trim_string {
   #description _ trim string (remove blank characters in start/end)
   #param1  _ input string
   #@return _ trimmed string

    my $string = shift;

    my $output = $string;
    $output =~ s/^ +//;
    $output =~ s/ +$//;

    return $output;
}

sub latinize_iofile {
   #description _ latinize a text file (i.e., convert to iso-latin 1)
   #param1 _ input file
   #param2 _ output file

   my $input = shift;
   my $output = shift;

   my $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n";
   my $OUT = new IO::File("> $output") or die "Couldn't open output file: $output\n";

   while (defined(my $line = $IN->getline())) {
      print $OUT Unicode::String::utf8($line)->latin1();
   }

   $IN->close();
   $OUT->close();
}

sub latinize_file {
   #description _ latinizes a text file (i.e., convert to iso-latin 1)
   #param1 _ input file
   #param2 _ output file

   my $input = shift;
   my $output = shift;

   open IN, ("< $input") or die "Couldn't open input file: $input\n";
   open OUT, ("> $output") or die "Couldn't open output file: $output\n";

   while (my $line = <IN>) {
      print OUT Unicode::String::utf8($line)->latin1();
   }

   close(IN);
   close(OUT);
}

sub relatinize_file {
   #description _ relatinizes a text file (i.e., convert to iso-latin 1)
   #param1 _ input file
   #param2 _ output file

   my $input = shift;
   my $output = shift;

   open IN, ("< $input") or die "Couldn't open input file: $input\n";
   open OUT, ("> $output") or die "Couldn't open output file: $output\n";

   while (my $line = <IN>) {
      print OUT Unicode::String::utf8(
                  Unicode::String::utf8($line)->latin1())->latin1();
   }

   close(IN);
   close(OUT);
}

sub rerelatinize_file {
   #description _ rerelatinizes a text file (i.e., convert to iso-latin 1)
   #param1 _ input file
   #param2 _ output file

   my $input = shift;
   my $output = shift;

   open IN, ("< $input") or die "Couldn't open input file: $input\n";
   open OUT, ("> $output") or die "Couldn't open output file: $output\n";

   while (my $line = <IN>) {
      print OUT Unicode::String::utf8(
                  Unicode::String::utf8(
                    Unicode::String::utf8($line)->latin1())->latin1())->latin1();
   }

   close(IN);
   close(OUT);
}

sub latinize {
    #description _ sprints a twig (latin1 encoding)                                                                                                          
    #param1 _ string                                                                                                                                         
    #@returns _ string representing the twig                                                                                                                 
    my $string = shift;

    my $out = Unicode::String::utf8($string)->latin1();

    #print "[$string] [$out]\n";
    #if (($out eq "") or ($out =~ / +/)) { $out = $Common::EMPTY_ITEM; }

    return($out);
}

#sub get_basename {
#   #description _ returns the basename of a given 'absolute path' filename
#   #param1  _ input string
#   #@return _ output string
#
#   my $input = shift;
#
#   my $output = $input;
#   $output =~ s/^.*\///;
#
#   return $output;
#}

sub remove_extension {
    #description _ removes the extension of a given 'absolute path' filename
    #param1  _ input string
    #@return _ output string

    my $input = shift;

    my $output = $input;
    $output =~ s/\.[^\/\.]*$//;

    return $output;
}

sub replace_special_characters {
   #description _ replaces conflictive characters inside a given string (~filename)
   #param1  _ input string
   #@return _ output string

   my $input = shift;

   my $output = $input;
   $output =~ s/\*/\\\*/g;
   $output =~ s/\'/\\\'/g;
   $output =~ s/\`/\\\`/g;
   $output =~ s/\(/\\\(/g;
   $output =~ s/\)/\\\)/g;
   $output =~ s/;/\\;/g;
   $output =~ s/\?/\\\?/g;

   return $output;
}

sub trunk_string {
    #description _ trunks the given string to the given length
    #param1  _ string
    #param2  _ length
    #@return _ trunked string
	
    my $s = shift;
    my $l = shift;
	  
	if (!defined($s)) { $s = ''; } 

    my $x = sprintf("%".$l."s", $s);

    return $x;	
}


sub trunk_number {
    #description _ trunks the given number into a float (given length and precision)
    #param1  _ number
    #param2  _ length
    #param3  _ precision
    #@return _ trunked number
	
    my $n = shift;
    my $l = shift;
    my $p = shift;
	 
	if (!defined($n)) { $n = 0; } 

    my $x = sprintf("%".$l.".".$p."f", $n);
	
    return $x;	
}

sub trunk_and_trim_number {
    #description _ trunks the given number into a float (given length and precision) and trims trailing white spaces.
    #param1  _ number
    #param2  _ length
    #param3  _ precision
    #@return _ trunked number
	
    my $n = shift;
    my $l = shift;
    my $p = shift;

    if (!defined($n)) { $n = 0; }
	  
    my $x = sprintf("%".$l.".".$p."f", $n);
    $x =~ s/^ +//g;
	
    return $x;	
}

sub XML_remove_comments {
    #description _ copies all contents of a given XML file to a new one, except comments.
    #param1  _ input file
    #param2  _ output file
	
    my $input = shift;
    my $output = shift;

    my $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n";
    my $OUT = new IO::File("> $output") or die "Couldn't open output file: $output\n";

    my $print = 1;
    while (defined(my $line = $IN->getline())) {
       if ($line =~ /\s*<!--\s*/) { $print = 0; }
       if ($print) { print $OUT $line; }
       if ($line =~ /\s*-->\s*/) { $print = 1; }
    }

    $IN->close();
    $OUT->close();
}

sub execute_or_die {
    #description _ runs a command through a "system" call; dies if the command fails
    #param1  _ command to run
    #param2  _ error message

    my $command = shift;
    my $message = shift;

    $command =~ s/\R/ /g;
    #print "$command \n";
    #system($command);
    ( system($command) == 0 ) or die "$message\n$command\n"; #disabled for security reason under web based system
}

sub reorder_scores {
    #description _ converts a hash of scores into an ordered array according to the IDX file
    #param1  _ scores hash
    #param2  _ IDX
    #@return _ an array of values (scores)

    my $hscores = shift;
    my $IDX = shift;
    my $G = shift;

    my @orderkeys = ();
    if ( defined $IDX ){
       if ( $G eq $Common::G_SEG ){
          for (my $count = 1; $count < scalar(@{$IDX}); $count++) {
            my $idx = $IDX->[$count];
            my $k = "sys::".$idx->[2]."::doc::".$idx->[0]."::seg::".$idx->[3];
            push (@orderkeys,$k);
          }
       }
       elsif ( $G eq $Common::G_DOC ){
          for (my $count = 1; $count < scalar(@{$IDX}); $count++) {
            my $idx = $IDX->[$count];
            my $k = "sys::".$idx->[2]."::doc::".$idx->[0];
            push (@orderkeys,$k) if !($k ~~ @orderkeys );
          }
       }
       elsif ( $G eq $Common::G_SYS ){
          for (my $count = 1; $count < scalar(@{$IDX}); $count++) {
            my $idx = $IDX->[$count];
            my $k = "sys::".$idx->[2];
            push (@orderkeys,$k) if !($k ~~ @orderkeys );
          }
       }
    }
    else{
      @orderkeys = sort keys %{$hscores};
    }

    my @scores;
    foreach my $k (@orderkeys){
      push(@scores, $hscores->{$k});
    }

    return \@scores;
}



sub isSourceFamily {
	my $metric_name = shift;
	
	my $metric_family = metricFamily($metric_name);
	
	if ( ($metric_family eq $Common::CE) or ($metric_family eq $Common::LeM ) ){
		return 1;
	}
	else{
		return 0;
	}
	
}


sub metricFamily{
	my $metric_name = shift;

	my @values = split('-', $metric_name);
	return $values[0];
	
}

1;


