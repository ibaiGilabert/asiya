package PER;

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
use Data::Dumper;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Metrics;

our ($PEREXT, $rPER, $TPER);

$PER::PEREXT = "PER";
#$PER::TPER = "PER/PER.pl";
$PER::TPER = "per/PER.pl";
#$PER::rPER = { "-$PER::PEREXT" => 1, "$PER::PEREXT" => 1 };
$PER::rPER = { "-$PER::PEREXT" => 1};

sub metric_set {
    #description _ returns the set of available metrics
    #@return _ metric set structure (hash ref)

    return $PER::rPER;
}



sub PER_f_create_doc {
    #description _ creation of a RAW evaluation document 
    #param1  _ input file
    #param2  _ output file
    #param3  _ case (cs/ci)
    #param4  _ verbose (0/1)

    my $input = shift;
    my $output = shift;
    my $case = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING <$input> for PER parsing...\n"; }

    if (-e $input) {
       if ($verbose > 1) { print STDERR "reading <$input>\n"; }

       my $IN = new IO::File("< $input") or
                die "Couldn't open input file: $input\n";

       my $OUT = new IO::File("> $output");

       while (defined (my $line = $IN->getline())) {
          chomp($line);
          $line =~ s/\r//;
          $line =~ s/ +$//;
          if ($case eq $Common::CASE_CI) { my $line2 = lc $line; $line=$line2; }
          print $OUT $line."\n";
       }

       $IN->close();    
       $OUT->close();    

    }
    else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }
}


sub read_PER {
   #description _ read PER (system and segment scores) from report file
   #param1  _ report filename
   #param2  _ do_neg
   #@return _ PER

   my $report = shift;
   my $do_neg = shift;

   my $PER = 0;
   my @lPER;

   open(AUX, "< $report") or die "couldn't open file: $report\n";
   while (my $aux = <AUX>) {
      chomp($aux);
      my @laux = split(/\s+/, $aux);
      if ($do_neg){
          if (scalar(@laux) == 3) { push(@lPER, -$laux[2]); }
          elsif (scalar(@laux) == 1) { $PER = -$aux; }
      }
      else{
          if (scalar(@laux) == 3) { push(@lPER, $laux[2]); }
          elsif (scalar(@laux) == 1) { $PER = $aux; }
      }
   }
   close(AUX);

   return ($PER, \@lPER);
}

sub computeMultiPER($$$$$$$) {
   #description _ computes -PER score (multiple references)
   #param1 _ candidate file
   #param2 _ reference file(s) [hash reference]
   #param3 _ do_neg
   #param4 _ remake reports? (1 - yes :: 0 - no)
   #param5 _ tools
   #param6 _ case (cs/ci)
   #param7 _ verbosity (0/1)

   my $out = shift;
   my $Href = shift;
   my $do_neg = shift;
   my $remakeREPORTS = shift;
   my $tools = shift;
   my $case = shift;
   my $verbose = shift;

   my $toolPER = "perl $tools/$PER::TPER";

   my $reportPER = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$PEREXT.$Common::REPORTEXT";
   if ($verbose > 1) { print STDERR "building $reportPER...\n"; }

   my $outRND = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$PEREXT.$Common::SYSEXT";
   PER_f_create_doc ($out,$outRND,$case,$verbose);

   my @maxSEGscores;
   my $maxSYS = undef;
   foreach my $r (keys %{$Href}) {
      my $ref = $Href->{$r};
      my $refRND = "$Common::DATA_PATH/$Common::TMP/".rand($Common::NRAND).".$PEREXT.$Common::REFEXT";

      PER_f_create_doc ($ref,$refRND,$case,$verbose);

      Common::execute_or_die("$toolPER -s -t $outRND -r $refRND > $reportPER", "[ERROR] problems running PER...");
      my ($SYS, $SEGS) = read_PER($reportPER, $do_neg);
      if (defined($maxSYS)) {
         if ($SYS > $maxSYS) { $maxSYS = $SYS; }
      }
      else { $maxSYS = $SYS; }
      my $i = 0;
      while ($i < scalar(@{$SEGS})) {
      	 if (defined($maxSEGscores[$i])) {
            if ($SEGS->[$i] > $maxSEGscores[$i]) { $maxSEGscores[$i] = $SEGS->[$i] }
      	 }
      	 else { $maxSEGscores[$i] = $SEGS->[$i]; }
         $i++;      	
      }
      
      system("rm -f $reportPER");
      system("rm -f $refRND");
   }
   system("rm -f $outRND");

   return($maxSYS, \@maxSEGscores);


}

sub doMultiPER {
   #description _ computes -PER score (multiple references)
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
	
   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $M = $config->{Hmetrics};                 # set of metrics
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $GO = 0; my $i = 0;
   my @mPER = keys %{$PER::rPER};
   while (($i < scalar(@mPER)) and (!$GO)) { if (exists($M->{$mPER[$i]})) { $GO = 1; } $i++; }

   if ($GO) {
      if ($verbose == 1) { print STDERR "$PER::PEREXT.."; }
      my $reportPERxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/-$PEREXT.$Common::XMLEXT";
      if (((!(-e $reportPERxml) and !(-e $reportPERxml.".$Common::GZEXT")) or $remakeREPORTS) and $M->{"-".$PEREXT} ) {
         my ($SYS, $SEGS) = PER::computeMultiPER($out, $Href, 1, $remakeREPORTS, $tools, $config->{CASE}, $verbose);
         my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "-PER", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            Scores::save_hash_scores("-PER", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
      }
      $reportPERxml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$PEREXT.$Common::XMLEXT";
      if (((!(-e $reportPERxml) and !(-e $reportPERxml.".$Common::GZEXT")) or $remakeREPORTS) and $M->{$PEREXT} ) {
         my ($SYS, $SEGS) = PER::computeMultiPER($out, $Href, 0, $remakeREPORTS, $tools, $config->{CASE}, $verbose);
         my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
         if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, "PER", $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
         Scores::save_hash_scores("PER", $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
      }
   }
}

1;
