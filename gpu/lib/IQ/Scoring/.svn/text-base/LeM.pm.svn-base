package LeM;

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

our ($LeMEXT, $rLeM, $TLeM);

$LeM::LeMEXT = "LeM";
$LeM::TLeM = "lengthmodel/LengthModel.jar";
$LeM::rLeM = { "$LeM::LeMEXT" => 1 };


$LeM::rLANG = { $Common::L_ENG => {
                     $Common::L_SPA => 1,
                     $Common::L_GER => 1, 
                     $Common::L_FRN => 1, 
                     $Common::L_CZE => 1,
                     $Common::L_RUS => 1 },
                   $Common::L_SPA => { $Common::L_ENG => 1 }, 
                   $Common::L_GER => { $Common::L_ENG => 1 }, 
                   $Common::L_FRN => { $Common::L_ENG => 1 },
                   $Common::L_CZE => { $Common::L_ENG => 1 },
                   $Common::L_RUS => { $Common::L_ENG => 1 } };

sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ source language
    #param2  _ target language
    #@return _ metric set structure (hash ref)

    my $srclang = shift;
    my $trglang = shift;

    my %metric_set;
    if (exists($LeM::rLANG->{$srclang})) { 
      if (exists($LeM::rLANG->{$srclang}->{$trglang})) { $metric_set{"$LeM::LeMEXT"} = 1; }
    }
    
    return \%metric_set;
}
		          


sub LeM_f_create_doc {
    #description _ creation of a RAW evaluation document 
    #param1  _ input file
    #param2  _ output file
    #param3  _ granularity (SYS,DOC,SEG)
    #param4  _ index structure
    #param5  _ verbose (0/1)

    my $input = shift;
    my $output = shift;
    my $G = shift;
    my $idx = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING <$input> for LeM parsing...\n"; }

    if (-e $input) {
       if ($verbose > 1) { print STDERR "reading <$input>\n"; }

       my $IN = new IO::File("< $input") or
                die "Couldn't open input file: $input\n";

       my $OUT = new IO::File("> $output");

       my $i = 1; my $docid= $idx->[$i]->[0];
       while (defined (my $line = $IN->getline())) {
          chomp($line);
          $line =~ s/\r//;
          $line =~ s/ +$//;
          
          if ($G eq $Common::G_SEG) { # seg-level 
             print $OUT $line."\n"; 
          }
          elsif ($G eq $Common::G_DOC) { # doc-level
       	   if ($idx->[$i]->[0] ne $docid) { 
       	      print $OUT "\n".$line." "; 
       	      $docid = $idx->[$i]->[0];
       	   }
       	   else{ print $OUT $line." ";  }
       	 }
          else { # sys-level 
            print $OUT $line." ";
          }
          $i++;
       }
       
       if ($G ne $Common::G_SEG){ print $OUT "\n";}
       $IN->close();    
       $OUT->close();    
    }
    else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }
}

sub read_LeM {
    #description _ reads a given MetricsMaTr format scr file (of a given granularity)
    #param1  _ filename
    #@return _ score list ref

    my $file = shift;
    
    my $SYSscore;
    my $F = new IO::File("< $file.$Common::G_SYS") or die "[ERROR] unavailable file <$file.$Common::G_SYS>\n";
    while (defined(my $line = $F->getline())) {
       chomp($line); 
       $SYSscore = $line;
    }
    $F->close();

    my @DOCscores;
    $F = new IO::File("< $file.$Common::G_DOC") or die "[ERROR] unavailable file <$file.$Common::G_DOC>\n";
    while (defined(my $line = $F->getline())) {
       chomp($line); 
       push(@DOCscores, $line);
    }
    $F->close();

    my @SEGscores;
    $F = new IO::File("< $file.$Common::G_SEG") or die "[ERROR] unavailable file <$file.$Common::G_SEG>\n";
    while (defined(my $line = $F->getline())) {
       chomp($line); 
       push(@SEGscores, $line);
    }
    $F->close();
    
    return($SYSscore, \@DOCscores, \@SEGscores);
}

sub computeMultiLeM {
   #description _ computes LeM score (multiple references)
   #param1 _ candidate file
   #param2 _ source file 
   #param3 _ remake reports? (1 - yes :: 0 - no)
   #param4 _ tools
   #param5 _ src-trg pair 
   #param6 _ idx
   #param7 _ verbosity (0/1)

   my $out = shift;
   my $src = shift;
   my $remakeREPORTS = shift;
   my $tools = shift;
   my $langpair = shift;
   my $idx = shift;
   my $verbose = shift;

   my $mem_options = " -Xms1024M -Xmx3072M "; 
   my $toolLeM = "java -Dfile.encoding=UTF-8 $mem_options -jar $tools/$LeM::TLeM";

   my $reportLeM = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$LeMEXT.$Common::REPORTEXT";
   if ($verbose > 1) { print STDERR "building $reportLeM...\n"; }

   #SEG LEVEL
   my $outRND = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$LeMEXT.$Common::SYSEXT";
   my $srcRND = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$LeMEXT.$Common::SRCEXT";
   LeM_f_create_doc ($out,$outRND,$Common::G_SEG,$idx,$verbose);
   LeM_f_create_doc ($src,$srcRND,$Common::G_SEG,$idx,$verbose);
   #print STDERR           "$toolLeM -s $srcRND -t $outRND -p $langpair > $reportLeM.$Common::G_SEG \n";
   Common::execute_or_die("$toolLeM -s $srcRND -t $outRND -p $langpair > $reportLeM.$Common::G_SEG 2> /dev/null", "[ERROR] problems running LeM...");

   #DOC LEVEL
   LeM_f_create_doc ($out,$outRND,$Common::G_DOC,$idx,$verbose);
   LeM_f_create_doc ($src,$srcRND,$Common::G_DOC,$idx,$verbose);
   #print STDERR           "$toolLeM -s $srcRND -t $outRND -p $langpair > $reportLeM.$Common::G_DOC \n";
   Common::execute_or_die("$toolLeM -s $srcRND -t $outRND -p $langpair > $reportLeM.$Common::G_DOC 2> /dev/null", "[ERROR] problems running LeM...");

   #SYS LEVEL
   LeM_f_create_doc ($out,$outRND,$Common::G_SYS,$idx,$verbose);
   LeM_f_create_doc ($src,$srcRND,$Common::G_SYS,$idx,$verbose);
   #print STDERR           "$toolLeM -s $srcRND -t $outRND -p $langpair > $reportLeM.$Common::G_SYS \n";
   Common::execute_or_die("$toolLeM -s $srcRND -t $outRND -p $langpair > $reportLeM.$Common::G_SYS 2> /dev/null", "[ERROR] problems running LeM...");
   
   my ($SYSscore, $DOCscores, $SEGscores) = read_LeM($reportLeM);

   system("rm -f $reportLeM.$Common::G_SEG");
   system("rm -f $reportLeM.$Common::G_DOC");
   system("rm -f $reportLeM.$Common::G_SYS");
   system("rm -f $srcRND");
   system("rm -f $outRND");

   return($SYSscore, $DOCscores, $SEGscores);
}

sub doMultiLeM {
   #description _ computes LeM score (multiple references)
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
   my $M = $config->{Hmetrics};                 # set of metrics
   my $IDX = $config->{IDX};                    # sys-doc-seg index structure
   my $srcL = $config->{SRCLANG};                     # language
   my $trgL = $config->{LANG};                     # case
   my $verbose = $config->{verbose};            # verbosity (0/1)
   
   my $GO = 0; my $i = 0;
   my @mLeM = keys %{$LeM::rLeM};
   while (($i < scalar(@mLeM)) and (!$GO)) { if (exists($M->{$mLeM[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$LeM::LeMEXT.."; }
      my $reportLeMxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$LeMEXT/$LeMEXT.$Common::XMLEXT";
      if ((!(-e $reportLeMxml) and !(-e $reportLeMxml.".$Common::GZEXT")) or $remakeREPORTS) {
         my ($SYS, $DOC, $SEG) = LeM::computeMultiLeM($out, $src, $remakeREPORTS, $tools, "$srcL-$trgL", $IDX->{$TGT}, $verbose);
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $LeM::LeMEXT, $LeM::LeMEXT, $SYS, $DOC, $SEG, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores($LeM::LeMEXT, $TGT, $REF, $SYS, $DOC, $SEG,$hOQ);
      }
   }
}

1;
