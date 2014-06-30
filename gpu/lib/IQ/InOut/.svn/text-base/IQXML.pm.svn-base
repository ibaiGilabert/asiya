package IQXML;

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
# !! watch memory leaks when using XML::Twig !!
# ------------------------------------------------------------------------

use Modern::Perl;
use Data::Dumper;
use IO::File;
use XML::Twig;
use Unicode::String qw(utf8 latin1);
use File::Basename;
use IQ::Common;

$IQXML::FLOAT_LENGTH = 10;
$IQXML::FLOAT_PRECISION = 8;
$IQXML::ROOT_ELEMENT = "REPORT";

sub write_report {
   #description _ writes evaluation scores onto a given XML report file
   #param1  _ TARGET
   #param2  _ REFERENCE
   #param3  _ METRIC name
   #param4  _ system-level score for the given metric
   #param5  _ document-level scores for the given metric (list)
   #param6  _ segment-level scores for the given metric (list)
   #param7  _ index structure
   #param8  _ verbosity (0/1)
 
   my $TGT = shift;
   my $REF = shift;
   my $METRIC = shift;
   my $T_SCORE = shift;
   my $D_SCORES = shift;
   my $S_SCORES = shift;
   my $idx = shift;
   my $verbose = shift;

   my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$METRIC.$Common::XMLEXT";

   if ($verbose > 1) { print STDERR "writing XML REPORT <$report_xml>\n"; }

   if (!(-e "$Common::DATA_PATH/$Common::REPORTS")) { system "mkdir $Common::DATA_PATH/$Common::REPORTS"; }
   if (!(-e "$Common::DATA_PATH/$Common::REPORTS/$TGT")) { system "mkdir $Common::DATA_PATH/$Common::REPORTS/$TGT"; }
   if (!(-e "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF")) { system "mkdir $Common::DATA_PATH/$Common::REPORTS/$TGT/$REF"; }
   my $OUT = new IO::File("> $report_xml") or die "Couldn't open output file: $report_xml\n";

   print $OUT "<?xml version=\"1.0\"?>\n";                  # print the XML declaration
   print $OUT "<!DOCTYPE ".$IQXML::ROOT_ELEMENT." SYSTEM \"".lc($Common::appNAME).".dtd\" []>";

   my $REPORT = new XML::Twig::Elt($IQXML::ROOT_ELEMENT);
   my $DOC = undef;

   my $i = 1;
   my $n_docs = 0;
   my $n_doc_segs = 0;
   my $document_id = "";
   
   while ($i < @$idx) {
      if ($idx->[$i]->[0] ne $document_id) { # NEW DOCUMENT
         if (defined($DOC)) {
            my $x = Common::trunk_and_trim_number($D_SCORES->[$n_docs - 1], $IQXML::FLOAT_LENGTH, $IQXML::FLOAT_PRECISION);
            my %attdoc = ('n' => $n_docs, 'id' => $document_id, 'n_segments' => $n_doc_segs, 'score' => $x);
            $DOC->set_atts(\%attdoc);
            $DOC->paste('last_child', $REPORT);
         }
         $DOC = new XML::Twig::Elt('DOC');
         $document_id = $idx->[$i]->[0]; 
         $n_docs++;  
         $n_doc_segs = 0;
      }   	  
   	  
      # CREATE A SEGMENT      
      my $SEG = new XML::Twig::Elt('S');
      my $x = Common::trunk_and_trim_number($S_SCORES->[$i - 1], $IQXML::FLOAT_LENGTH, $IQXML::FLOAT_PRECISION);
      $SEG->set_text($x);
      my %attseg = ('n' => $i);
      $SEG->set_atts(\%attseg);
      $SEG->paste('last_child', $DOC);
      $n_doc_segs++;
      $i++;
   }

   #PASTE LAST DOC (if any)
   if (defined($DOC)) {
      my $x = Common::trunk_and_trim_number($D_SCORES->[$n_docs - 1], $IQXML::FLOAT_LENGTH, $IQXML::FLOAT_PRECISION);
      my %attdoc = ('n' => $n_docs, 'id' => $document_id, 'n_segments' => $n_doc_segs, 'score' => $x);
      $DOC->set_atts(\%attdoc);
      $DOC->paste('last_child', $REPORT);
   }
   
   # -> STORE IQREPORT
   my $x = Common::trunk_and_trim_number($T_SCORE, $IQXML::FLOAT_LENGTH, $IQXML::FLOAT_PRECISION);
   my %attreport = ('metric' => $METRIC, 'hyp' => $TGT, 'ref' => $REF, 'score' => $x,
                    'n_docs' => $n_docs, 'n_segments' => $i-1);
   $REPORT->set_atts(\%attreport);
   $REPORT->set_pretty_print('record');
   $REPORT->print($OUT);

   #free memory
   my @DOCS = $REPORT->children;
   for (my $d = 0; $d < scalar(@DOCS); $d += 1) {
      my @SGMS = $DOCS[$d]->children;
      for (my $s = 0; $s < scalar(@SGMS); $s += 1) { $SGMS[$s]->cut_children(); }
   	  $DOCS[$d]->cut_children();
   }
   $REPORT->cut_children();

   $OUT->close();    

   $report_xml =~ s/\*/\\\*/g;
   $report_xml =~ s/\'/\\\'/g;
   $report_xml =~ s/\`/\\\`/g;
   $report_xml =~ s/\(/\\\(/g;
   $report_xml =~ s/\)/\\\)/g;
   $report_xml =~ s/;/\\;/g;
   $report_xml =~ s/\?/\\\?/g;

   system("$Common::GZIP ".$report_xml);
}

sub read_report {
   #description _ reads evaluation scores from a given XML report file onto memory.
   #param1  _ TARGET
   #param2  _ REFERENCE
   #param3  _ METRIC name
   #param4  _ metric scores (hash ref)
   #param5  _ set of segments (topics) (hash ref)
   #param6  _ level of granularity ('sys' for system; 'doc' for document; 'seg' for segment; 'all' for all)
   #param7  _ verbosity (0/1)

   my $TGT = shift;
   my $REF = shift;
   my $METRIC = shift;
   my $hOQ = shift;
   my $T = shift;
   my $G = shift;
   my $verbose = shift;


	#print STDERR "reading $G $METRIC $TGT $REF \n";
	#print STDERR Dumper $hOQ;

   # Do not reload already loaded scores
   if ($G eq $Common::G_SYS) {
      if (exists($hOQ->{$G}->{$METRIC}->{$TGT}->{$REF})) { return; }
   }
   elsif (($G eq $Common::G_SEG) or ($G eq $Common::G_DOC)) {
      if (exists($hOQ->{$G}->[0]->{$METRIC}->{$TGT}->{$REF})) { return; }
   }   
   elsif ($G eq $Common::G_ALL) {
      if (exists($hOQ->{$G}->{$METRIC}->{$TGT}->{$REF}) or 
          exists($hOQ->{$G}->{$METRIC}->{$TGT}->{$CE::CEEXT}) or 
          exists($hOQ->{$G}->{$METRIC}->{$TGT}->{$LeM::LeMEXT}) ) { return; }
   }
   else { die "[ERROR] unknown granularity <", $G, ">!\n"; }

   my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$METRIC.$Common::XMLEXT";
   if ($METRIC =~ /^$Common::CE.*/) {   	 
      $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$Common::CE/$METRIC.$Common::XMLEXT";
   }
   elsif ($METRIC =~ /^$Common::LeM.*/) {   	 
      $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$Common::LeM/$METRIC.$Common::XMLEXT";
   }
   else {
      # exit if REF is empty or undefined and not a CE measure
      if (!defined($REF) or ($REF eq '')) {
      	 print STDERR "[ERROR] no reference defined for a reference-based measure!!\n";
      	 return;
      }
   }

   my $doALL = (scalar(keys %{$T}) == 0);  # if no segments are specified, then read all

   srand(); my $randomXML = ""; my $randomXML2 = "";

   if ((-e $report_xml) or (-e "$report_xml.$Common::GZEXT")) {
      if ($verbose > 1) { print STDERR "reading XML REPORT <$report_xml>\n"; }

      if (!(-e $report_xml)) {
         my $report_xml2 = Common::replace_special_characters($report_xml);
         my $r = rand($Common::NRAND);
         $randomXML = "$Common::DATA_PATH/$Common::TMP/".basename("$report_xml.".$r);
         $randomXML2 = "$Common::DATA_PATH/$Common::TMP/".basename("$report_xml2.".$r);
         system "$Common::GUNZIP -c $report_xml2.$Common::GZEXT > $randomXML2";
      }

      my $twig = XML::Twig->new( keep_encoding => 1 );
      if (-e $report_xml) { $twig->parsefile($report_xml); }
      else { $twig->parsefile($randomXML); }
      my $REPORT = $twig->root;
      #my $metric = $REPORT->att('metric');
      #my $target = $REPORT->att('hyp');
      #my $ref = $REPORT->att('ref');

      if (($G eq $Common::G_SYS) or ($G eq $Common::G_ALL)) { #system_score
         $hOQ->{$Common::G_SYS}->{$METRIC}->{$TGT}->{$REF} = $REPORT->att('score');
      }
      if (($G eq $Common::G_DOC) or ($G eq $Common::G_SEG) or ($G eq $Common::G_ALL)) {
         my @DOCS = $REPORT->children;
         for (my $d = 0; $d < scalar(@DOCS); $d += 1) {  #doc scores
            $hOQ->{$Common::G_DOC}->[$d]->{$METRIC}->{$TGT}->{$REF} = $DOCS[$d]->att('score');
            if (($G eq $Common::G_SEG) or ($G eq $Common::G_ALL)) {
               my @SGMS = $DOCS[$d]->children;
               for (my $s = 0; $s < scalar(@SGMS); $s += 1) { #seg scores
                  my $x = $SGMS[$s]->text;
                  my $n = $SGMS[$s]->att('n');
                  if (exists($T->{$n}) or $doALL) { $hOQ->{$Common::G_SEG}->[$n - 1]->{$METRIC}->{$TGT}->{$REF} = $x; }
               }
            }
         }
      }

      $twig->dispose();

      if (-e $report_xml) {
         my $report_xml2 = Common::replace_special_characters($report_xml);
         system("$Common::GZIP ".$report_xml2);
      }
      else { system "rm -f $randomXML2"; }
   }
   else { print STDERR "\n[ERROR] UNAVAILABLE file read_report <$report_xml>!!!\n"; }
}


sub read_score_list {
   #description _ reads a list of segment MT scores for a given metric
   #              from a given XML report file onto memory. (single reference)
   #param1  _ TARGET
   #param2  _ REFERENCE
   #param3  _ METRIC name
   #param4  _ level of granularity ('sys' for system; 'doc' for document; 'seg' for segment)
   #param5  _ hash of scores
   #param6  _ verbosity (0/1)

   my $TGT = shift;
   my $REF = shift;
   my $METRIC = shift;
   my $G = shift;
   my $hOQ = shift;
   my $verbose = shift;

   my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$METRIC.$Common::XMLEXT";

   my @SCORES;

   # Look into the scores structure
   if ( ($G eq $Common::G_SYS) and (exists($hOQ->{$G}->{$METRIC}->{$TGT}->{$REF})) ) { 
		push(@SCORES, $hOQ->{$Common::G_SYS}->{$METRIC}->{$TGT}->{$REF} );
		return \@SCORES;
   }
   elsif ( ($G eq $Common::G_DOC) and (exists($hOQ->{$G}->[0]->{$METRIC}->{$TGT}->{$REF})) ){ 
         for (my $d = 0; $d < scalar(@{$hOQ->{$G}}); $d += 1) {  #doc scores
				push(@SCORES, $hOQ->{$G}->[$d]->{$METRIC}->{$TGT}->{$REF} );
         }   
		return \@SCORES;
	}   	
   elsif ( ($G eq $Common::G_SEG) and (exists($hOQ->{$G}->[0]->{$METRIC}->{$TGT}->{$REF})) ){ 
         for (my $d = 0; $d < scalar(@{$hOQ->{$G}}); $d += 1) {  #seg scores
				push(@SCORES, $hOQ->{$G}->[$d]->{$METRIC}->{$TGT}->{$REF} );
         }   	
		return \@SCORES;
   }   

	
	# now try in the report file
	
   if ((-e $report_xml) or (-e "$report_xml.$Common::GZEXT")) {
   	srand(); my $randomXML = ""; my $randomXML2 = "";
      if ($verbose > 1) { print STDERR "reading XML REPORT <$report_xml>\n"; }

      if (!(-e $report_xml)) {
         my $report_xml2 = Common::replace_special_characters($report_xml);
         my $r = rand($Common::NRAND);
         $randomXML = "$Common::DATA_PATH/$Common::TMP/".basename("$report_xml.".$r);
         $randomXML2 = "$Common::DATA_PATH/$Common::TMP/".basename("$report_xml2.".$r);
         system "$Common::GUNZIP -c $report_xml2.$Common::GZEXT > $randomXML2";
      }

      my $twig = XML::Twig->new( keep_encoding => 1 );
      if (-e $report_xml) { $twig->parsefile($report_xml); }
      else { $twig->parsefile($randomXML); }
      my $REPORT = $twig->root;

      if ($G eq $Common::G_SYS) { #system_score
         push(@SCORES, $REPORT->att('score'));
      }
      elsif (($G eq $Common::G_DOC) or ($G eq $Common::G_SEG)) {
         my @DOCS = $REPORT->children;
         for (my $d = 0; $d < scalar(@DOCS); $d += 1) {  #doc scores
            if ($G eq $Common::G_DOC) { #document_scores
               push(@SCORES, $DOCS[$d]->att('score'));
            }
            elsif ($G eq $Common::G_SEG) { #seg scores
               my @SGMS = $DOCS[$d]->children;
               for (my $s = 0; $s < scalar(@SGMS); $s += 1) {
                  my $x = $SGMS[$s]->text;
                  my $n = $SGMS[$s]->att('n');
                  push(@SCORES, $x);
               }
            }
         }
      }

      $twig->dispose();

      if (-e $report_xml) {
         my $report_xml2 = Common::replace_special_characters($report_xml);
         system("$Common::GZIP ".$report_xml2);
      }
      else { system "rm -f $randomXML2"; }
   }
   else { print STDERR "\n[ERROR] UNAVAILABLE file at read_score_list <$report_xml>!!!\n"; }

   return \@SCORES;
}

1;
