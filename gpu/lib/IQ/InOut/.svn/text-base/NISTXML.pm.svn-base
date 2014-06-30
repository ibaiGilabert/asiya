package NISTXML;

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

our ($rLANG, $DTD);

$NISTXML::rLANG = {'Arabic' => $Common::L_ARA, 'Chinese' => $Common::L_CHN, 'Czech' => $Common::L_CZE, 'English' => $Common::L_ENG,
                   'French' => $Common::L_FRN, 'German' => $Common::L_GER, 'Spanish' => $Common::L_SPA};
                   #Farsi, Urdu...

$NISTXML::DTD = 1.5;

sub repair_file {
   #description _ repair possibly bad formed XML file
   #param1 _ input file
   #param2 _ output file

   my $input = shift;
   my $output = shift;

   my $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n";
   my $OUT = new IO::File("> $output") or die "Couldn't open output file: $output\n";
   
   my $in_segment = 0;
   while (defined(my $line = <$IN>)) {  	
      chomp($line);
      $line =~ s/\r$//;  # remove carriage return  	  
      my $rline;
      if (lc($line) =~ /<seg[^>]*>.*<\/seg>$/) {
         chomp($line);
         my $tline = Common::trim_string($line);
         my @l = split(">", $tline);
         #print Dumper \@l;
         my $i = 0; my @rl;
         while ($i < scalar(@l)) {
            if ($i == 0) { #FIRST
               push(@rl, $l[$i].">");
            }
            elsif ($i == (scalar(@l) - 1)) { #LAST
               my @ll = split ("<", $l[$i]);
               #print Dumper \@ll;
               my $j = 0; my @rll;
               while ($j < scalar(@ll)) {
                  if ($j == 0) { #LAST --> FIRST
                     push(@rll, Common::replace_xml_entities_REV(Common::replace_xml_entities($ll[$j])));
                  }
                  elsif ($j == (scalar(@ll) - 1)) { #LAST --> LAST
                     push(@rll, "<".$ll[$j].">");
	          }
                  else {
                     push(@rll, Common::replace_xml_entities_REV(Common::replace_xml_entities("<".$ll[$j])));
	          }
                  $j++;
                }
                push(@rl, join("", @rll));
            }
            else { push(@rl, Common::replace_xml_entities_REV(Common::replace_xml_entities($l[$i]."<"))); }
            $i++;
         }       
         $rline = join("", @rl);
      }
      elsif (lc($line) =~ /<seg[^>]*>$/) { $rline = $line; $in_segment = 1; }      
      elsif (lc($line) =~ /<\/seg>$/) { $rline = $line; $in_segment = 0; }      
      else {
      	 if ($in_segment) { $rline = Common::replace_xml_entities_REV(Common::replace_xml_entities($line)); }
      	 else {
            $line =~ s/<DOC/<doc/;
            $line =~ s/<\/DOC>/<\/doc>/;
            $rline = $line;
      	 }
      }
      #print $OUT Unicode::String::utf8($rline)->latin1();
      print $OUT $rline, "\n";
   }

   close($IN);
   close($OUT);
}

sub get_attribute_value {
    #description _ retrieve attribute value or empty item if undefined
    #param1  _ tree node
    #param2  _ attribute name
    #@return _ attribute value

    my $node = shift;
    my $attribute = shift;

    my $value = $Common::EMPTY_ITEM;
    if (defined($node->att($attribute))) { $value = $node->att($attribute); }

    return $value;
}

sub read_file {
    #description _ reads a NIST XML file and writes an equivalent RAW file and the correspondence between them (IDX)
    #              (conforming ftp://jaguar.ncsl.nist.gov/mt/resources/mteval-xml-v1.5.dtd)
    #param1  _ INPUT FILE
    #param2  _ tools directory
    #param3  _ verbosity (0/1)
    #param4  _ remake (0/1) to remake the idx files
    #@return _ OUTPUT STRUCTURE (hash ref)

    my $XML = shift;
    my $tools = shift;
    my $verbose = shift;
    my $tokenize = shift;
    my $remake = shift;

    my $dir = dirname($XML);
    my %contents;

    if ($verbose > 1) { print STDERR "reading NIST XML <$XML>\n"; }

    if ((-e $XML) or (-e "$XML.$Common::GZEXT")) {
       if (!(-e $XML) and (-e "$XML.$Common::GZEXT")) { system "$Common::GUNZIP $XML.$Common::GZEXT"; }
       #my $twig = XML::Twig->new( keep_encoding => 1, twig_roots => { 'refset' => 1, 'tstset' => 1, 'srcset' => 1 } );
       my $twig = XML::Twig->new( keep_encoding => 1 );
       srand();
       if (-e $XML) { 
          my $XMLrepaired = $XML.".repaired.".rand($Common::NRAND);
          repair_file($XML, $XMLrepaired);
          $twig->parsefile($XMLrepaired);
          system "rm -f $XMLrepaired";
       }

       my $ROOT = $twig->root;
       my $doc_type = $ROOT->gi();

       if ($doc_type eq "mteval") {
          my @SETS = $ROOT->children;
          for (my $s = 0; $s < scalar(@SETS); $s += 1) {
             process_set($SETS[$s], \%contents, $tools, $dir, $verbose, $tokenize, $remake);
          }
       } 
       elsif (($doc_type eq "srcset") or ($doc_type eq "refset") or ($doc_type eq "tstset")) {
          process_set($ROOT, \%contents, $tools, $dir, $verbose, $tokenize, $remake);
       }
       else { die "[ERROR] unknown XML document type <$doc_type>\n"; }
      
       $twig->dispose();
    }
    else { die "[ERROR] unavailable file <$XML>!\n"; }
          
    return \%contents;
}

sub get_sys_id_from_first_doc($) {
    #description _ retrieves the `sysid' from the 1st child documenet of the given SET, if available
    #param1  _ set element 
    
	my $SET = shift;
	
	my $DOC1 = $SET->first_child('doc'); 	
	my $id = get_attribute_value($DOC1, 'sysid');
	if ($id eq $Common::EMPTY_ITEM) { $id = get_attribute_value($DOC1, 'refid'); }
	
	return $id;
}

sub process_set {
    #description _ process a translation set (srcset|refset|tstset)
    #param1  _ set element 
    #param2  _ input/output structure -- hash ref (name, index structure)
    #param3  _ tools directory
    #param4  _ target directory
    #param5  _ verbosity (0/1)
    #param6  _ tokenize (0/1)
    #param7  _ remake (0/1) - to remake the idx
    
    my $SET = shift;
    my $contents = shift;
    my $tools = shift;
    my $dir = shift;    
    my $verbose = shift;
    my $tokenize = shift;
    my $remake = shift;

    my @lIDX;

    my $setid = get_attribute_value($SET, 'setid');
    my $srclang = get_attribute_value($SET, 'srclang');
    my $trglang = get_attribute_value($SET, 'trglang');

    my $lang;
    my $set_type = $SET->gi();
    my $id = $Common::EMPTY_ITEM;   ## from DTD v1.5 --> "sysid" attribute goes to "tstset"
    if ($set_type eq "srcset") {
       $id = $Common::SOURCEID;
       $lang = $srclang;
    } 
    elsif ($set_type eq "refset") {
       $id = get_attribute_value($SET, 'refid');
       if ($id eq $Common::EMPTY_ITEM) { $id = get_sys_id_from_first_doc($SET); }
       $lang = $trglang;
    } 
    elsif ($set_type eq "tstset") {
       $id = get_attribute_value($SET, 'sysid');
       if ($id eq $Common::EMPTY_ITEM) { $id = get_sys_id_from_first_doc($SET); }
       $lang = $trglang;
    }
    else { die "[ERROR] unknown XML set type <$set_type>\n"; }

    my $TXT;
    my $IDX;
       
    if ($id ne $Common::EMPTY_ITEM) {
       $TXT = $dir."/".$id.".$Common::TXTEXT";
       $IDX = $dir."/".$id.".$Common::IDXEXT";
#       if ((-e $TXT) and (-e $IDX) and !($remake)) {
#       	  $contents->{$id}->{txt} = $TXT;
#       	  $contents->{$id}->{idx} = read_idx_file($IDX, $verbose);
#       	  return;
#       }
       open(TXT, "> $TXT") or die "couldn't open output TXT file: $TXT\n";
       open(IDX, "> $IDX") or die "couldn't open output IDX file: $IDX\n";
       my @l = ($setid, $srclang, $trglang);
       print IDX join(" ", @l)."\n";
       push(@lIDX, \@l);  #IDX[i=0] <-- set information :: IDX[i>0] <-- segment information
    }
     
    my @DOCS = $SET->children;
    for (my $d = 0; $d < scalar(@DOCS); $d += 1) {
       my $docid = get_attribute_value($DOCS[$d], 'docid');
       my $genre = get_attribute_value($DOCS[$d], 'genre');
       if ($id eq $Common::EMPTY_ITEM) {
          my $sysid = get_attribute_value($DOCS[$d], 'sysid');
          if ($sysid eq $Common::EMPTY_ITEM) { die "[ERROR] unknown XML sys/ref id <$setid>\n"; }
          else {
             $id = $sysid;
             $TXT = $dir."/".$id.".$Common::TXTEXT";
             $IDX = $dir."/".$id.".$Common::IDXEXT";
#             if ((-e $TXT) and (-e $IDX) and !($remake)) {
#                $contents->{$id}->{txt} = $TXT;
#                $contents->{$id}->{idx} = read_idx_file($IDX, $verbose);
#                return;
#             }
             open(TXT, "> $TXT") or die "couldn't open output TXT file: $TXT\n";
             open(IDX, "> $IDX") or die "couldn't open output IDX file: $IDX\n";
             my @l = ($setid, $srclang, $trglang);
             push(@lIDX, \@l);  #IDX[i=0] <-- set information :: IDX[i>0] <-- segment information
             print IDX join(" ", @l)."\n";
          }
       }
       my @SEGS = $DOCS[$d]->children;
       for (my $i = 0; $i < scalar(@SEGS); $i += 1) {
          ### "doc" elements may contain 4 kinds of children --> (hl|p|poster|seg) ###
          if ($SEGS[$i]->gi eq "seg") { # 'seg' child
             my $text = Common::replace_xml_entities($SEGS[$i]->trimmed_text);
             my $segid = get_attribute_value($SEGS[$i], 'id');
             #print "---> $setid $docid $genre $sysid :: $segid :: $text\n";
             my @l = ($docid, $genre, $id, $segid);
             push(@lIDX, \@l);
             print IDX join(" ", @l)."\n";
             print TXT $text, "\n";
          }
          else { # (hl|p|poster) child  --> may contain "seg" children  ###
             my @SUBSEGS = $SEGS[$i]->children;
             for (my $j = 0; $j < scalar(@SUBSEGS); $j += 1) {
                my $text = Common::replace_xml_entities($SUBSEGS[$j]->trimmed_text);
                my $segid = get_attribute_value($SUBSEGS[$j], 'id');
                #print "---> $setid $docid $genre $sysid :: $segid :: $text\n";
                my @l = ($docid, $genre, $id, $segid);
                push(@lIDX, \@l);
                print IDX join(" ", @l)."\n";
                print TXT $text, "\n";
             }
          }
       }
    }

    close(TXT);
    close(IDX);

    if ( $tokenize ){
       my $l = $lang;
       if (exists($SP::rLANGTOK->{$lang})) { $l = $SP::rLANGTOK->{$lang}; }
       SP::tokenize_file($tools, $TXT, $l);
    }
    
    $contents->{$id}->{txt} = $TXT;
    $contents->{$id}->{idx} = \@lIDX;
 	 $contents->{$id}->{wc} = scalar(@lIDX)-1;
    
}

sub read_idx_file {
    #description _ reads an IDX file into memory
    #              (conforming ftp://jaguar.ncsl.nist.gov/mt/resources/mteval-xml-v1.0.dtd)
    #param1  _ INPUT IDX FILE
    #param2  _ verbosity (0/1)
    #@return _ OUTPUT IDX STRUCTURE

    my $IDX = shift;
    my $verbose = shift;

    my @lIDX;

    if ($verbose > 1) { print STDERR "reading IDX file <$IDX>\n"; }

    open(IDX, " < $IDX") or die "couldn't open input file: $IDX\n";
    while (defined(my $line = <IDX>)) {
       chomp $line;
       my @l = split(" ", $line);
       push(@lIDX, \@l);
    }
    close(IDX);

    return \@lIDX;
}

sub write_fake_idx_file {
    #description _ writes a fake idx file, given a raw input file, and loads IDX structure into memory
    #param1  _ input file
    #param2  _ OUTPUT IDX FILE
    #param3  _ verbosity (0/1)
    #@return _ OUTPUT IDX STRUCTURE

    my $file = shift;
    my $IDX = shift;
    my $verbose = shift;

    my @lIDX;

    if ($verbose > 1) { print STDERR "reading raw file <$file>\n"; }

    my $system_name = Common::give_system_name($file);
    
    open(IDX, "> $IDX") or die "couldn't open output IDX file: $IDX\n";
    my $fake_header = "$Common::UNKNOWN_SET $Common::UNKNOWN_LANG $Common::UNKNOWN_LANG";
    print IDX $fake_header, "\n";
    my @l_header = split(" ", $fake_header);
    push(@lIDX, \@l_header);

    open(RAW, " < $file") or die "couldn't open input file: $file\n";
    my $i = 1;
    while (defined(my $line = <RAW>)) {
       my $fake_line = "$Common::UNKNOWN_DOC $Common::UNKNOWN_GENRE $system_name $i";
       my @l = split(" ", $fake_line);
       push(@lIDX, \@l);
       print IDX $fake_line, "\n";
       $i++;
    }
    close(RAW);
    close(IDX);

    return \@lIDX;
}

sub get_docid_list {
    #description _ returns the list of document ids in the idx, in order of appearance
    #param1  _ idx structure
    #@return _ docid list ref
    
    my $idx = shift;
    
    my @ldocids;
    my $docid = "";
    my $i = 1;
    while ($i < scalar(@{$idx})) {
       if ($idx->[$i]->[0] ne $docid) {
       	  $docid = $idx->[$i]->[0];
       	  push(@ldocids, $docid);
       }
       $i++;
    }
    
    return \@ldocids;	
}

sub get_number_of_segments {
    #description _ returns the number of segments in the given idx
    #param1  _ idx structure
    #@return _ docid list ref
    
    my $idx = shift;

    return scalar(@{$idx}) - 1;
}

sub get_number_of_documents {
    #description _ returns the number of documents in the given idx
    #param1  _ idx structure
    #@return _ docid list ref
    
    my $idx = shift;

    return scalar(@{get_docid_list($idx)});
}

sub get_setid_length($) {
	#description _ returns the length of the set id of the given idx
    #param1  _ idx structure
    #@return _ docid list ref
    
    my $idx = shift;

    return length($idx->[0]->[0]);
}

sub get_max_docid_length {
    #description _ returns the length of the longest document id in the given idx
    #param1  _ idx structure
    #@return _ docid list ref
    
    my $idx = shift;
    
    my $max = 0;
    my $i = 1;
    while ($i < scalar(@{$idx})) {
       if (length($idx->[$i]->[0]) > $max) { $max = length($idx->[$i]->[0]); }
       $i++;
    }
    
    return $max;	
}

sub get_max_segid_length {
    #description _ returns the length of the longest segment id in the given idx
    #param1  _ idx structure
    #@return _ docid list ref
    
    my $idx = shift;
    
    my $max = 0;
    my $i = 1;
    while ($i < scalar(@{$idx})) {
       if (length($idx->[$i]->[3]) > $max) { $max = length($idx->[$i]->[3]); }
       $i++;
    }
    
    return $max;	
}

sub SGML_GTM_f_create_mteval_doc ($$$$) {
    #description _ creation of a NIST SGML evaluation document from a "sentence-per-line" format corpus
    #              specific for GTM metric
    #param1  _ input file
    #param2  _ output file
    #param3  _ case (cs/ci)
    #param4  _ verbose (0/1)

    my $input = shift;
    my $output = shift;
    my $case = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING <$input> for GTM xml-parsing...\n"; }

    srand(); my $randomINPUT = ""; my $randomINPUT2 = "";

    if ((-e $input) or (-e "$input.$Common::GZEXT")) {
       if ($verbose > 1) { print STDERR "reading <$input>\n"; }

       if (!(-e $input)) {
          #open FH, ">:encoding(UTF-8)"
          my $input2 = Common::replace_special_characters($input);
          my $r = rand($Common::NRAND);
          $randomINPUT = "$Common::DATA_PATH/$Common::TMP/".basename("$input.".$r);
          $randomINPUT2 = "$Common::DATA_PATH/$Common::TMP/".basename("$input2.".$r);
          system "$Common::GUNZIP -c $input2.$Common::GZEXT > $randomINPUT2";
       }

       my $IN;
       if (-e $input) { $IN = new IO::File("< $input") or
                            die "Couldn't open input file: $input\n"; }
       else { $IN = new IO::File("< $randomINPUT") or
                            die "Couldn't open input file: $randomINPUT\n"; }
       my $OUT = new IO::File("> $output");

       my $nSEGMENTS = 1;

       my $DOC = new XML::Twig::Elt('doc');
       ## -- DOCUMENTS*
       while (defined (my $line = $IN->getline())) {
          chomp($line);
          $line =~ s/\r//;
          $line =~ s/ +$//;
          if ($case eq $Common::CASE_CI) { my $line2 = lc $line; $line=$line2; }
          if ($line eq "") { $line = $Common::EMPTY_ITEM; }
          my $SEG = new XML::Twig::Elt('seg');
          $SEG->set_id($nSEGMENTS);
          my $s = utf8($line);
          $SEG->set_text($s->utf8);
          #$SEG->set_text($line);
          $SEG->paste('last_child', $DOC);
          $nSEGMENTS++;
       }

       # -> STORE DOCUMENT
       my %att = ('docid'=>"dummydoc", 'sysid'=>"dummysys");
       $DOC->set_atts(\%att);
       $DOC->set_pretty_print('record');
       $DOC->print($OUT);

       $IN->close();    
       $OUT->close();    

       my @SGMS = $DOC->children;
       for (my $s = 0; $s < scalar(@SGMS); $s += 1) { $SGMS[$s]->cut_children(); }
       $DOC->cut_children();

       if (-e $input) {
       #   my $input2 = Common::replace_special_characters($input);
       #   system("$Common::GZIP ".$input2);
       }
       else { system "rm -f $randomINPUT2"; }
    }
    else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }
}

sub METEOR_f_create_mteval_doc {
    #description _ creation of a NIST SGML evaluation document from a "sentence-per-line" format corpus
    #              specific for METEOR metric
    #param1  _ input file
    #param2  _ output file
    #param3  _ system id
    #param4  _ candidate index structure
    #param5  _ type (0:srcset :: 1:tstset :: 2:refset)
    #param6  _ verbose (0/1)

    my $input = shift;
    my $output = shift;
    my $sysid = shift;
    my $idx = shift;
    my $type = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING <$input> for NIST xml-parsing [type = ", ($type == 0)? "SRC" : ($type == 1)? "TST" : "REF", "]...\n"; }

    srand(); my $randomINPUT = ""; my $randomINPUT2 = "";

    if ((-e $input) or (-e "$input.$Common::GZEXT")) {
       if ($verbose > 1) { print STDERR "reading <$input>\n"; }

       if (!(-e $input)) {
          my $input2 = Common::replace_special_characters($input);
          my $r = rand($Common::NRAND);
          $randomINPUT = "$Common::DATA_PATH/$Common::TMP/".basename("$input.".$r);
          $randomINPUT2 = "$Common::DATA_PATH/$Common::TMP/".basename("$input2.".$r);
          system "$Common::GUNZIP -c $input2.$Common::GZEXT > $randomINPUT2";
       }

       my $IN;
       if (-e $input) { $IN = new IO::File("< $input") or
                            die "Couldn't open input file: $input\n"; }
       else { $IN = new IO::File("< $randomINPUT") or
                            die "Couldn't open input file: $randomINPUT\n"; }
       my $OUT = new IO::File("> $output");


       my $set;
       if ($type == 0) { $set = 'srcset'; }
       elsif ($type == 1) { $set = 'tstset'; }
       elsif ($type == 2) { $set = 'refset'; }

       my $SET = new XML::Twig::Elt($set);
       my $DOC;
       my $docid = "";
       my $nSEGMENTS = 1;
       while ($nSEGMENTS < scalar@{$idx}) { ## -- DOCUMENTS*
       #while (defined (my $line = $IN->getline())) {
       	  if ($idx->[$nSEGMENTS]->[0] ne $docid) { #new document
       	     if ($docid ne "") { # -> STORE DOCUMENT
                my %docatt = ('docid'=>$docid, 'sysid'=>"$sysid");
                $DOC->set_atts(\%docatt);
                $DOC->paste('last_child', $SET);
       	     }
       	     $docid = $idx->[$nSEGMENTS]->[0];
             $DOC = new XML::Twig::Elt('DOC');             
       	  }
       	  my $line = $IN->getline();
          chomp($line); $line =~ s/ +$//g;
          if ($line eq "") { $line = $Common::EMPTY_ITEM; }
          my $SEG = new XML::Twig::Elt('seg');
          my $s = utf8($line);
          $SEG->set_text($s->utf8);
          #$SEG->set_text($line);
          #my %segatt = ('id'=>$nSEGMENTS + 0);
          #$SEG->set_atts(\%segatt);
          #$SEG->set_id($nSEGMENTS);
          my %segatt = ('id'=>$idx->[$nSEGMENTS]->[3]);
          $SEG->set_atts(\%segatt);
          $SEG->paste('last_child', $DOC);
          $nSEGMENTS++;
       }

       # -> STORE DOCUMENT
       my %docatt = ('docid'=>$docid, 'sysid'=>"$sysid");
       $DOC->set_atts(\%docatt);
       $DOC->paste('last_child', $SET);

       my %setatt = ('setid'=>$idx->[0]->[0], 'srclang'=>$idx->[0]->[1], 'trglang'=>$idx->[0]->[2], 'sysid'=>"$sysid");
       $SET->set_atts(\%setatt);
       $SET->set_pretty_print('record');
       $SET->print($OUT);

       $IN->close();    
       $OUT->close();
 
       my @DOCS = $SET->children;
       for (my $d = 0; $d < scalar(@DOCS); $d += 1) {
          my @SGMS = $DOCS[$d]->children;
          for (my $s = 0; $s < scalar(@SGMS); $s += 1) { $SGMS[$s]->cut_children(); }
          $DOCS[$d]->cut_children();
       }
       $SET->cut_children();

       if (-e $input) {
       #   my $input2 = Common::replace_special_characters($input);
       #   system("$Common::GZIP ".$input2);
       }
       else { system "rm -f $randomINPUT2"; }
    }
    else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }
}

sub METEOR_f_create_mteval_multidoc {
    #description _ creation of a NIST SGML evaluation document from a "sentence-per-line" format corpus
    #              specific for METEOR metric (multi-document)
    #param1  _ input file(s) (hash reference)
    #param2  _ output file
    #param3  _ system id
    #param4  _ candidate index structure
    #param5  _ type (0:srcset :: 1:tstset :: 2:refset)
    #param6  _ verbose (0/1)

    my $Hinput = shift;
    my $output = shift;
    my $sysid = shift;
    my $IDX = shift;
    my $type = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING [", join(" ", sort keys %{$Hinput}), "] for NIST* xml-parsing..."; }

    my $OUT = new IO::File("> $output");

    my $set;
    if ($type == 0) { $set = 'srcset'; }
    elsif ($type == 1) { $set = 'tstset'; }
    elsif ($type == 2) { $set = 'refset'; }

    my $SET = new XML::Twig::Elt($set);

    srand(); my $randomINPUT = ""; my $randomINPUT2 = "";

    my $idx = undef;
    foreach my $sysname (keys %{$Hinput}) {
       my $input = $Hinput->{$sysname};
       if ((-e $input) or (-e "$input.$Common::GZEXT")) {
          if ($verbose > 1) { print STDERR "reading <$input>\n"; }
	      if (!(-e $input)) {
             my $input2 = Common::replace_special_characters($input);
             my $r = rand($Common::NRAND);
             $randomINPUT = "$Common::DATA_PATH/$Common::TMP/".basename("$input.".$r);
             $randomINPUT2 = "$Common::DATA_PATH/$Common::TMP/".basename("$input2.".$r);
	         system "$Common::GUNZIP -c $input2.$Common::GZEXT > $randomINPUT2";
	      }

          my $IN;
          if (-e $input) { $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n"; }
	      else { $IN = new IO::File("< $randomINPUT") or die "Couldn't open input file: $randomINPUT\n"; }
		      
          my $DOC;
          my $docid = "";
          my $nSEGMENTS = 1;
          $idx = $IDX->{$sysname};
          while ($nSEGMENTS < scalar@{$idx}) { ## -- DOCUMENTS*        
          #while (defined (my $line = $IN->getline())) {
             if ($idx->[$nSEGMENTS]->[0] ne $docid) { #new document
       	        if ($docid ne "") { # -> STORE DOCUMENT
                   my %docatt = ('docid'=>$docid, 'sysid'=>"$sysname.$sysid");
                   $DOC->set_atts(\%docatt);
                   $DOC->paste('last_child', $SET);
       	        }
                $docid = $idx->[$nSEGMENTS]->[0];
                $DOC = new XML::Twig::Elt('DOC');             
       	     }
             my $line = $IN->getline();
             chomp($line); $line =~ s/ +$//g;
             if ($line eq "") { $line = $Common::EMPTY_ITEM; }
             my $SEG = new XML::Twig::Elt('seg');
             my $s = utf8($line);
             $SEG->set_text($s->utf8);
             #$SEG->set_text($line);
             #my %segatt = ('id'=>$nSEGMENTS + 0);
             #$SEG->set_atts(\%segatt);
             #$SEG->set_id($nSEGMENTS);
             my %segatt = ('id'=>$idx->[$nSEGMENTS]->[3]);
             $SEG->set_atts(\%segatt);
             $SEG->paste('last_child', $DOC);
             $nSEGMENTS++;
          }

          # -> STORE DOCUMENT
          my %docatt = ('docid'=>$docid, 'sysid'=>"$sysname.$sysid");
          $DOC->set_atts(\%docatt);
          $DOC->paste('last_child', $SET);
          $IN->close();     

          if (!-e $input) { system "rm -f $randomINPUT2"; }
          #   #my $input2 = Common::replace_special_characters($input);
   	      #   #system("$Common::GZIP ".$input2);
	      #}
	      #else { system "rm -f $randomINPUT2"; }
       }
       else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }
    }

    if (defined($idx)) {
       my %setatt = ('setid'=>$idx->[0]->[0], 'srclang'=>$idx->[0]->[1], 'trglang'=>$idx->[0]->[2], 'sysid'=>"$sysid");
       $SET->set_atts(\%setatt);
       $SET->set_pretty_print('record');
       $SET->print($OUT);
    }

    $OUT->close();    

    my @DOCS = $SET->children;
    for (my $d = 0; $d < scalar(@DOCS); $d += 1) {
       my @SGMS = $DOCS[$d]->children;
       for (my $s = 0; $s < scalar(@SGMS); $s += 1) { $SGMS[$s]->cut_children(); }
       $DOCS[$d]->cut_children();
    }
    $SET->cut_children();
}

sub SGML_f_create_mteval_doc {
    #description _ creation of a NIST SGML evaluation document from a "sentence-per-line" format corpus
    #param1  _ input file
    #param2  _ output file
    #param3  _ type (0:srcset :: 1:tstset :: 2:refset)
    #param4  _ verbose (0/1)

    my $input = shift;
    my $output = shift;
    my $type = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING <$input> for NIST xml-parsing [type = ", ($type == 0)? "SRC" : ($type == 1)? "TST" : "REF", "]...\n"; }

    srand(); my $randomINPUT = ""; my $randomINPUT2 = "";

    if ((-e $input) or (-e "$input.$Common::GZEXT")) {
       if ($verbose > 1) { print STDERR "reading <$input>\n"; }

       if (!(-e $input)) {
          my $input2 = Common::replace_special_characters($input);
          my $r = rand($Common::NRAND);
          $randomINPUT = "$Common::DATA_PATH/$Common::TMP/".basename("$input.".$r);
          $randomINPUT2 = "$Common::DATA_PATH/$Common::TMP/".basename("$input2.".$r);
          system "$Common::GUNZIP -c $input2.$Common::GZEXT > $randomINPUT2";
       }

       my $IN;
       if (-e $input) { $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n"; }
       else { $IN = new IO::File("< $randomINPUT") or die "Couldn't open input file: $randomINPUT\n"; }
       my $OUT = new IO::File("> $output");

       my $nSEGMENTS = 1;

       my $set;
       my $sysid;
       if ($type == 0) { $set = 'srcset'; $sysid = "dummysysSRC"; }
       elsif ($type == 1) { $set = 'tstset'; $sysid = "dummysysTST"; }
       elsif ($type == 2) { $set = 'refset'; $sysid = "dummysysREF"; }

       my $SET = new XML::Twig::Elt($set);
       my $DOC = new XML::Twig::Elt('DOC');
       ## -- DOCUMENTS*
       while (defined (my $line = $IN->getline())) {
          chomp($line);
          $line =~ s/ +$//g;
          if ($line eq "") { $line = $Common::EMPTY_ITEM; }
          my $SEG = new XML::Twig::Elt('seg');
          #my %segatt = ('id'=>$nSEGMENTS + 0);
          #$SEG->set_atts(\%segatt);
          $SEG->set_id($nSEGMENTS);
          my $s = utf8($line);
          $SEG->set_text($s->utf8);
          #$SEG->set_text($line);
          $SEG->paste('last_child', $DOC);
          $nSEGMENTS++;
       }

       # -> STORE DOCUMENT
       my %docatt = ('docid'=>"dummydoc", 'sysid'=>"$sysid");
       $DOC->set_atts(\%docatt);
       $DOC->paste('last_child', $SET);

       my %setatt = ('setid'=>"dummyset", 'srclang'=>"dummylang", 'trglang'=>"dummylang");
       $SET->set_atts(\%setatt);
       $SET->set_pretty_print('record');
       $SET->print($OUT);

       $IN->close();    
       $OUT->close();
 
       my @DOCS = $SET->children;
       for (my $d = 0; $d < scalar(@DOCS); $d += 1) {
          my @SGMS = $DOCS[$d]->children;
          for (my $s = 0; $s < scalar(@SGMS); $s += 1) { $SGMS[$s]->cut_children(); }
          $DOCS[$d]->cut_children();
       }
       $SET->cut_children();

       if (-e $input) {
       #   my $input2 = Common::replace_special_characters($input);
       #   system("$Common::GZIP ".$input2);
       }
       else { system "rm -f $randomINPUT2"; }
    }
    else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }
}

sub SGML_f_create_mteval_multidoc {
    #description _ creation of a NIST SGML evaluation document from a "sentence-per-line" format corpus
    #              (multi-document)
    #param1  _ input file(s) (hash reference)
    #param2  _ output file
    #param3  _ type (0:srcset :: 1:tstset :: 2:refset)
    #param4  _ verbose (0/1)

    my $Hinput = shift;
    my $output = shift;
    my $type = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING [", join(" ", sort keys %{$Hinput}), "] for NIST* xml-parsing..."; }

    my $OUT = new IO::File("> $output");

    my $set;
    my $sysid;
    if ($type == 0) { $set = 'srcset'; $sysid = "dummysysSRC"; }
    elsif ($type == 1) { $set = 'tstset'; $sysid = "dummysysTST"; }
    elsif ($type == 2) { $set = 'refset'; $sysid = "dummysysREF"; }

    my $SET = new XML::Twig::Elt($set);

    srand(); my $randomINPUT = ""; my $randomINPUT2 = "";

    foreach my $sysname (keys %{$Hinput}) {
       my $input = $Hinput->{$sysname};
       if ((-e $input) or (-e "$input.$Common::GZEXT")) {
	   if ($verbose > 1) { print STDERR "reading <$input>\n"; }
          if (!(-e $input)) {
             my $input2 = Common::replace_special_characters($input);
             my $r = rand($Common::NRAND);
             $randomINPUT = "$Common::DATA_PATH/$Common::TMP/".basename("$input.".$r);
             $randomINPUT2 = "$Common::DATA_PATH/$Common::TMP/".basename("$input2.".$r);
             system "$Common::GUNZIP -c $input2.$Common::GZEXT > $randomINPUT2";
          }

          my $IN;
          if (-e $input) { $IN = new IO::File("< $input") or
                                die "Couldn't open input file: $input\n"; }
          else { $IN = new IO::File("< $randomINPUT") or
                      die "Couldn't open input file: $randomINPUT\n"; }
          my $DOC = new XML::Twig::Elt('DOC');
          my $nSEGMENTS = 1;

          ## -- DOCUMENTS*
          while (defined (my $line = $IN->getline())) {
             chomp($line);
             $line =~ s/ +$//g;
             if ($line eq "") { $line = $Common::EMPTY_ITEM; }
             my $SEG = new XML::Twig::Elt('seg');
             #my %segatt = ('id'=>$nSEGMENTS + 0);
             #$SEG->set_atts(\%segatt);
             $SEG->set_id($nSEGMENTS);
             my $s = utf8($line);
             $SEG->set_text($s->utf8);
             #$SEG->set_text($line);
             $SEG->paste('last_child', $DOC);
             $nSEGMENTS++;
          }

          # -> STORE DOCUMENT
          my %docatt = ('docid'=>"dummydoc", 'sysid'=>"$sysname");
          $DOC->set_atts(\%docatt);
          $DOC->paste('last_child', $SET);
          $IN->close();

          if (-e $input) {
             #my $input2 = Common::replace_special_characters($input);
             #system("$Common::GZIP ".$input2);
          }
          else {
             system "rm -f $randomINPUT2";
          }
       }
       else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }
    }

    my %setatt = ('setid'=>"dummyset", 'srclang'=>"dummylang", 'trglang'=>"dummylang");
    $SET->set_atts(\%setatt);
    $SET->set_pretty_print('record');
    $SET->print($OUT);

    $OUT->close();    

    my @DOCS = $SET->children;
    for (my $d = 0; $d < scalar(@DOCS); $d += 1) {
       my @SGMS = $DOCS[$d]->children;
       for (my $s = 0; $s < scalar(@SGMS); $s += 1) { $SGMS[$s]->cut_children(); }
       $DOCS[$d]->cut_children();
    }
    $SET->cut_children();
}

sub f_create_mteval_doc ($$$$$$$) {
    #description _ creation of a NIST XML evaluation document from a "sentence-per-line" format corpus
    #              (conforming ftp://jaguar.ncsl.nist.gov/mt/resources/mteval-xml-v1.5.dtd)
    #param1  _ input file
    #param2  _ output file
    #param3  _ target name
    #param4  _ idx structure
    #param5  _ type (0:srcset :: 1:tstset :: 2:refset)
    #param6  _ case (cs/ci)
    #param7  _ verbose (0/1)

    my $input = shift;
    my $output = shift;
    my $TGT = shift;
    my $IDX = shift;
    my $type = shift;
    my $case = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING <$input> for NIST xml-parsing [type = ", ($type == 0)? "SRC" : ($type == 1)? "TST" : "REF", "]...\n"; }
    
    srand(); my $randomINPUT = ""; my $randomINPUT2 = "";

    if ((-e $input) or (-e "$input.$Common::GZEXT")) {
       if ($verbose > 1) { print STDERR "reading <$input>\n"; }

       my $r = rand($Common::NRAND);
       if (!(-e $input)) {
          my $input2 = Common::replace_special_characters($input);
          $randomINPUT = "$Common::DATA_PATH/$Common::TMP/".basename("$input.".$r);
          $randomINPUT2 = "$Common::DATA_PATH/$Common::TMP/".basename("$input2.".$r);
          system "$Common::GUNZIP -c $input2.$Common::GZEXT > $randomINPUT2";
       }

       my $IN;
       if (-e $input) { $IN = new IO::File("< $input") or die "Couldn't open input file: $input\n"; }
       else { $IN = new IO::File("< $randomINPUT") or die "Couldn't open input file: $randomINPUT\n"; }

       my $output_aux = $output."$r";
       my $OUT = new IO::File("> $output_aux") or die "Couldn't open output file: $output_aux\n";

       my $MTEVAL = new XML::Twig::Elt('mteval');

       my $idx;
       my $set;
       my $id_label;
       if ($type == 0) { $set = 'srcset'; $id_label = "srcid"; $idx = $IDX->{"source"}; }
       elsif ($type == 1) { $set = 'tstset'; $id_label = "sysid"; $idx = $IDX->{$TGT}; }
       elsif ($type == 2) { $set = 'refset'; $id_label = "refid"; $idx = $IDX->{$TGT}; }

       my $id = $idx->[1][2];
       my $SET = new XML::Twig::Elt($set);
       my $nSEGMENTS = 1;    
       my $docid = "";  
              
       my $DOC = new XML::Twig::Elt('doc');
       ## -- DOCUMENTS*
       while (defined (my $line = $IN->getline())) {
       	  if ($idx->[$nSEGMENTS]->[0] ne $docid) { # new document
       	     if ($nSEGMENTS > 1) { # -> STORE DOCUMENT
                my %docatt = ('docid'=>$docid, $id_label=>$id, 'genre'=>$idx->[$nSEGMENTS-1]->[1]);
                $DOC->set_atts(\%docatt);
                $DOC->paste('last_child', $SET);
                $DOC = new XML::Twig::Elt('doc');
       	     }
       	  	 $docid = $idx->[$nSEGMENTS]->[0];
       	  }        	
          chomp($line);
          $line =~ s/ +$//g;
          if ($case eq $Common::CASE_CI) { my $line2 = lc $line; $line=$line2; }          
          if ($line eq "") { $line = $Common::EMPTY_ITEM; }
          my $SEG = new XML::Twig::Elt('seg');
          $SEG->set_id($idx->[$nSEGMENTS]->[3]);
	  my $tmpline = $line;
	  $tmpline =~ s/[\x00-\x1F\x7F]//g; 
          my $s = utf8($tmpline);
          $SEG->set_text(Common::replace_xml_entities($s->utf8));
          #$SEG->set_text($s->utf8);
          $SEG->paste('last_child', $DOC);
          $nSEGMENTS++;
       }


       # -> STORE LAST DOCUMENT
       my %docatt = ('docid'=>$docid, $id_label=>$id, 'genre'=>$idx->[$nSEGMENTS-1]->[1]);
       $DOC->set_atts(\%docatt);
       $DOC->paste('last_child', $SET);

       my %setatt = ('setid'=>$idx->[0]->[0], $id_label=>$id, 'srclang'=>$idx->[0]->[1], 'trglang'=>$idx->[0]->[2]);
       $SET->set_atts(\%setatt);
       $SET->paste('last_child', $MTEVAL);

       $MTEVAL->set_pretty_print('record');
       $MTEVAL->print($OUT);

       $IN->close();    
       $OUT->close();

       my @DOCS = $SET->children;
       for (my $d = 0; $d < scalar(@DOCS); $d += 1) {
          my @SGMS = $DOCS[$d]->children;
          for (my $s = 0; $s < scalar(@SGMS); $s += 1) { $SGMS[$s]->cut_children(); }
          $DOCS[$d]->cut_children();
       }
       $SET->cut_children();
       $MTEVAL->cut_children();


       if (-e $input) {
       #   my $input2 = Common::replace_special_characters($input);
       #   system("$Common::GZIP ".$input2);
       }
       else { system "rm -f $randomINPUT2"; }

       repair_file($output_aux, $output);
       system "rm -f $output_aux";
    }
    else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }

}


sub f_create_mteval_multidoc ($$$$$$){
    #description _ creation of a NIST XML evaluation document from a "sentence-per-line" format corpus
    #              (conforming ftp://jaguar.ncsl.nist.gov/mt/resources/mteval-xml-v1.5.dtd)
    #              (multi-document)
    #param1  _ input file(s) (hash reference)
    #param2  _ output file
    #param3  _ idx structure
    #param4  _ type (0:srcset :: 1:tstset :: 2:refset)
    #param5  _ case (cs/ci)
    #param6  _ verbose (0/1)

    my $Hinput = shift;
    my $output = shift;
    my $IDX = shift;
    my $type = shift;
    my $case = shift;
    my $verbose = shift;

    if ($verbose > 1) { print STDERR "OPENING [", join(" ", sort keys %{$Hinput}), "] for NIST* xml-parsing..."; }

    srand();
    my $r = rand($Common::NRAND);

    my $output_aux = $output."$r";
    my $OUT = new IO::File("> $output_aux") or die "Couldn't open output file: $output_aux\n";

    my $MTEVAL = new XML::Twig::Elt('mteval');

    foreach my $name (keys %{$Hinput}) {
       my $idx;
       my $set;
       my $id_label;
       if ($type == 0) { $set = 'srcset'; $id_label = "srcid"; $idx = $IDX->{"source"}; }
       elsif ($type == 1) { $set = 'tstset'; $id_label = "sysid"; $idx = $IDX->{$name}; }
       elsif ($type == 2) { $set = 'refset'; $id_label = "refid"; $idx = $IDX->{$name}; }

       my $id = $idx->[1][2];
       my $SET = new XML::Twig::Elt($set);
       my $randomINPUT = ""; my $randomINPUT2 = "";
       my $input = $Hinput->{$name};
       if ((-e $input) or (-e "$input.$Common::GZEXT")) {
  	      if ($verbose > 1) { print STDERR "reading <$input>\n"; }
          if (!(-e $input)) {
             my $input2 = Common::replace_special_characters($input);
             $randomINPUT = "$Common::DATA_PATH/$Common::TMP/".basename("$input.".$r);
             $randomINPUT2 = "$Common::DATA_PATH/$Common::TMP/".basename("$input2.".$r);
             system "$Common::GUNZIP -c $input2.$Common::GZEXT > $randomINPUT2";
          }
          my $IN;
          if (-e $input) { $IN = new IO::File("< $input") or
                                die "Couldn't open input file: $input\n"; }
          else { $IN = new IO::File("< $randomINPUT") or
                      die "Couldn't open input file: $randomINPUT\n"; }
          my $nSEGMENTS = 1;
          my $docid = "";
            
          my $DOC = new XML::Twig::Elt('doc');
          ## -- DOCUMENTS*
          while (defined (my $line = $IN->getline())) {
             if ($idx->[$nSEGMENTS]->[0] ne $docid) { # new document
       	        if ($nSEGMENTS > 1) { # -> STORE DOCUMENT
                   my %docatt = ('docid'=>$docid, $id_label=>$id, 'sysid'=>$id, 'genre'=>$idx->[$nSEGMENTS-1]->[1]);
                   $DOC->set_atts(\%docatt);
                   $DOC->paste('last_child', $SET);
                   $DOC = new XML::Twig::Elt('doc');
       	        }
       	  	    $docid = $idx->[$nSEGMENTS]->[0];
       	     }        	
             chomp($line);
             $line =~ s/ +$//g;
             if ($case eq $Common::CASE_CI) { my $line2 = lc $line; $line=$line2; }
             if ($line eq "") { $line = $Common::EMPTY_ITEM; }
             my $SEG = new XML::Twig::Elt('seg');

             $SEG->set_id($idx->[$nSEGMENTS]->[3]);
             my $s = utf8($line);
             $SEG->set_text(Common::replace_xml_entities($s->utf8));
             #$SEG->set_text($s->utf8);
             $SEG->paste('last_child', $DOC);
             $nSEGMENTS++;
          }

          # -> STORE LAST DOCUMENT
          my %docatt = ('docid'=>$docid, $id_label=>$id, 'sysid'=>$id, 'genre'=>$idx->[$nSEGMENTS-1]->[1]);
          $DOC->set_atts(\%docatt);
          $DOC->paste('last_child', $SET);

          $IN->close();

          if (-e $input) {
          #   my $input2 = Common::replace_special_characters($input);
	      #   system("$Common::GZIP ".$input2);
          }
          else { system "rm -f $randomINPUT2"; }
       }
       else { print STDERR "\n[ERROR] UNAVAILABLE file <$input>!!!\n"; }

       my %setatt = ('setid'=>$idx->[0]->[0], $id_label=>$id, 'srclang'=>$idx->[0]->[1], 'trglang'=>$idx->[0]->[2]);
       $SET->set_atts(\%setatt);
       $SET->paste('last_child', $MTEVAL);
    }
    $MTEVAL->set_pretty_print('record');
    $MTEVAL->print($OUT);

    my @SETS = $MTEVAL->children;
    for (my $s = 0; $s < scalar(@SETS); $s += 1) {
       my @DOCS = $SETS[$s]->children;
       for (my $d = 0; $d < scalar(@DOCS); $d += 1) {
          my @SGMS = $DOCS[$d]->children;
          for (my $seg = 0; $seg < scalar(@SGMS); $seg += 1) { $SGMS[$seg]->cut_children(); }
          $DOCS[$d]->cut_children();
       }
       $SETS[$s]->cut_children();
    }
    $MTEVAL->cut_children();

    $OUT->close();

    repair_file($output_aux, $output);
    system "rm -f $output_aux";
}

1;

#-------------------
#mteval-xml-v1.5.dtd
#-------------------
#
#<!--ENTITY lt     "&#38;#60;"-->
#<!--ENTITY gt     "&#62;"-->
#<!--ENTITY amp    "&#38;#38;"-->
#<!--ENTITY apos   "&#39;"-->
#<!--ENTITY quot   "&#34;"-->
#
#<!--ELEMENT mteval (srcset | refset+ | tstset+)-->
#<!--ELEMENT srcset (doc+)-->
#<!--ATTLIST srcset setid CDATA #REQUIRED-->
#<!--ATTLIST srcset srclang (Arabic | Chinese | Czech | English | Farsi | French | German | Spanish | Urdu) #REQUIRED-->
#
#<!--ELEMENT refset (doc+)-->
#<!--ATTLIST refset setid CDATA #REQUIRED-->
#<!--ATTLIST refset srclang (Arabic | Chinese | Czech | English | Farsi | French | German | Spanish | Urdu) #REQUIRED-->
#<!--ATTLIST refset trglang (Arabic | Chinese | Czech | English | Farsi | French | German | Spanish | Urdu) #REQUIRED-->
#<!--ATTLIST refset refid CDATA #REQUIRED-->
#
#<!--ELEMENT tstset (doc+)-->
#<!--ATTLIST tstset setid CDATA #REQUIRED-->
#<!--ATTLIST tstset srclang (Arabic | Chinese | Czech | English | Farsi | French | German | Spanish | Urdu) #REQUIRED-->
#<!--ATTLIST tstset trglang (Arabic | Chinese | Czech | English | Farsi | French | German | Spanish | Urdu) #REQUIRED-->
#<!--ATTLIST tstset sysid CDATA #REQUIRED-->
#
#<!--ELEMENT doc (hl | p | poster | seg)*-->
#<!--ATTLIST doc docid CDATA #REQUIRED-->
#<!--ATTLIST doc genre (bc | bn | ed | ng | nw | sp | ps | wb | wl | xx) #REQUIRED-->
#
#<!--ELEMENT hl (seg*)-->
#
#<!--ELEMENT p (seg*)-->
#
#<!--ELEMENT poster (seg*)-->
#
#<!--ELEMENT seg (#PCDATA)-->
#<!--ATTLIST seg id CDATA #REQUIRED-->

