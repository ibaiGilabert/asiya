#!/usr/bin/env perl
# Authors     : Jesús Giménez
# Date        : October 13, 2006
# Description : Responsible for extracting the txt content from a set of NIST SGML
#               translation documents.

# Usage: IQsgml2txt  input_list output.txt
#                     (input)    (output)
#
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

#Copyright (C) Jesús Giménez

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

use strict;
use Data::Dumper;
use IO;
use IO::File;

sub get_out
{
   $0 =~ /\/([^\/]*$)/;
   print STDERR "Usage : ", $1, " [options]  <file_list>  >  <output_file>\n";
   print STDERR "                           (input)      (output)\n\n";
   print STDERR " options:\n";
   print STDERR "  - m <file_list> : extract only documents matching the given source file list\n";
   print STDERR "  - g             : print genre information\n";
   print STDERR "  - l             : print document/segment ID label\n";
   print STDERR "  - r <number>    : reference translation (default 0)\n";
   print STDERR "  - V <0|1|2>     : verbosity\n";
   print STDERR "                    0 - non-verbose (default)\n";
   print STDERR "                    1 - low verbosity\n";
   print STDERR "                    2 - medium verbosity\n";
   print STDERR "\nExample: $1 -V 1 -g ./source/mt06_arabic_evlset_gale_part_v1.sgm > ./source/mt06_arabic_evlset_gale_part_v1.src.raw\n\n";

   print STDERR "\nExample: $1 -V 1 -m ./source/mt06_arabic_evlset_gale_part_v1.sgm ./reference/mt06_arabic_evlset_gale_part_v1-ref.sgm > ./reference/mt06_arabic_evlset_gale_part_v1-ref.raw\n";
   print STDERR "\nExample: $1 -V 1 -m ./source/mt06_arabic_evlset_gale_part_v1.sgm ./reference/mt06_arabic_evlset_gale_part_v1-ref.sgm | tokenizer.pl > ./reference/mt06_arabic_evlset_gale_part_v1-ref.tok\n";
   print STDERR "\nExample: $1 -V 1 -m ./source/mt06_arabic_evlset_gale_part_v1.sgm ./reference/mt06_arabic_evlset_gale_part_v1-ref.sgm | tokenizer.pl | lc-i.perl -1 > ./reference/mt06_arabic_evlset_gale_part_v1-ref.tok.lc\n\n";

   print STDERR "\nExample: $1 -V 1 -m ./source/mt06_arabic_evlset_gale_part_v1.sgm ./outputs/sys01_arabic_large_primary.sgm >  ./outputs/sys01_arabic_large_primary.gale.raw\n";
   print STDERR "\nExample: $1 -V 1 -m ./source/mt06_arabic_evlset_gale_part_v1.sgm ./outputs/sys01_arabic_large_primary.sgm | tokenizer.pl >  ./outputs/sys01_arabic_large_primary.gale.tok\n";
   print STDERR "\nExample: $1 -V 1 -m ./source/mt06_arabic_evlset_gale_part_v1.sgm ./outputs/sys01_arabic_large_primary.sgm | tokenizer.pl | lc-i.perl -1 >  ./outputs/sys01_arabic_large_primary.tok.gale.lc\n\n";
   exit;
}

# ------------------------------------- MAIN ------------------------------------------
my $NARG = 1;

# check number of arguments
my $ARGLEN = scalar(@ARGV);
if ($ARGLEN < $NARG) { get_out(); }

my $input = "";
my $source = "";
my $verbose = 0;
my $printG = 0;
my $printL = 0;
my $R = 0;

my $ARGOK = 0;
my $i = 0;
while (($i < $ARGLEN) and (!$ARGOK)) {
   my $opt = shift(@ARGV);
   if (($opt eq "-V") or ($opt eq "-v")) { $verbose = shift(@ARGV); }
   elsif (($opt eq "-M") or ($opt eq "-m")) { $source = shift(@ARGV); }
   elsif (($opt eq "-R") or ($opt eq "-r")) { $R = shift(@ARGV); }
   elsif (($opt eq "-G") or ($opt eq "-g")) { $printG = 1; }
   elsif (($opt eq "-L") or ($opt eq "-l")) { $printL = 1; }
   else {
      if ($opt ne "") {
         $input = $opt;
         $ARGOK = 1;
      }
   }
   $i++;
}

if (!($ARGOK)) { get_out(); }

my %G;
my %SOURCE;

if ($source ne "") { # matching source documents
   if ($verbose > 1) {
      print STDERR "PROCESSING <$source>\n";
   }
   my $FLIST = new IO::File("ls $source |") or die "Couldn't open input files <$source>\n";
   while (defined( my $file = $FLIST->getline())) {
      chomp($file);
      my $FILE = new IO::File("< $file") or die "Couldn't open input file <$file>\n";
      while (defined( my $line = $FILE->getline())) {
         chomp($line);
         if (lc($line) =~ /.*<doc .*/) {
            my @l;
            if ($line =~ /.*<doc .*/) { @l = split("<doc", $line); }
            else { @l = split("<DOC", $line); }

            my @ll = split(" ", $l[1]);
            my $i = 0;
            my $DOCid = "UNKNOWN_DOC";
            while ($i < scalar(@ll)) {
   	           if ($ll[$i] =~ /^docid/) {
                  my @lll = split(/\"/, $ll[$i]);
                  $DOCid = $lll[1];
	           }
               $i++;
	        }
            $SOURCE{$DOCid} = 1;
         }
      }
      $FILE->close();
   }
   $FLIST->close();

   if ($verbose > 1) {
      print STDERR "DOCUMENTS\n";
      print STDERR "---------\n";
     foreach my $d (keys %SOURCE) { print STDERR $d, "\n"; }
  }
}

if ($verbose) {
   print STDERR "PROCESSING <$input>...";
}

my %DOCS;

my $iter = 0;
my $DOCid = "";
my $n = -1;
my $FLIST = new IO::File("ls $input |") or die "Couldn't open input files <$input>\n";
while (defined( my $file = $FLIST->getline())) {
   chomp($file);
   my $FILE = new IO::File("< $file") or die "Couldn't open input file <$file>\n";
   while (defined( my $line = $FILE->getline())) {
      chomp($line);
      $line =~ s/^ +//;
      if (lc($line) =~ /.*<doc .*/) {
         my @l;
         if ($line =~ /.*<doc .*/) { @l = split("<doc", $line); }
         else { @l = split("<DOC", $line); }
         my @ll = split(" ", $l[1]);
         my $i = 0;
         my $g = "";
         while ($i < scalar(@ll)) {
	    if ($ll[$i] =~ /^docid/) {
               my @lll = split(/\"/, $ll[$i]);
               $DOCid = $lll[1];
	    }
	    elsif ($ll[$i] =~ /^genre/) {
               my @lll = split(/\"/, $ll[$i]);
               $g = $lll[1];
	    }
            $i++;
	 }
         $G{$DOCid} = $g;
         $n = 0;
      }
      elsif (lc($line) =~ /^<seg[^>]*>.*<\/seg>/) {
         chomp($line);
         my @l = split(/[<>]/, $line);
         my $segment = $l[2];
         $segment =~ s/^ +//g;
         $segment =~ s/ +$//g;
         push(@{$DOCS{$DOCid}->{$n}}, $segment);
         if ($verbose) {
            if (($iter%100) == 0) { print STDERR "."; }
            if (($iter%1000) == 0) { print STDERR "$iter"; }
         }
         $iter++;
         $n++;
      }
      elsif ((lc($line) =~ /^<seg[^>]*>$/) or (lc($line) =~ /^<seg[^>]*> +$/)) {
         $line = $FILE->getline();
         chomp($line);
         my $segment = $line;
         $segment =~ s/^ +//g;
         $segment =~ s/ +$//g;
         push(@{$DOCS{$DOCid}->{$n}}, $segment);
         if ($verbose) {
            if (($iter%100) == 0) { print STDERR "."; }
            if (($iter%1000) == 0) { print STDERR "$iter"; }
         }
         $iter++;
         $n++;
      }
      #elsif ($line =~ /^<seg[^>]*>/) {
      elsif (lc($line) =~ /^<seg .*/) {
         chomp($line);
         my @l = split(/[<>]/, $line);
         my $segment = $l[2];
         $segment =~ s/^ +//g;
         $segment =~ s/ +$//g;
         push(@{$DOCS{$DOCid}->{$n}}, $segment);
         if ($verbose) {
            if (($iter%100) == 0) { print STDERR "."; }
            if (($iter%1000) == 0) { print STDERR "$iter"; }
         }
         $iter++;
         $n++;
      }
      #else { print STDERR "NOTHING TO DO!\n"; }
   }
   $FILE->close();
}
$FLIST->close();

if ($verbose) { print STDERR "..$iter segments processed "; }

my $N = 1;
my %GENRES;
foreach my $d (sort keys %DOCS) {
   if (($source eq "") or (exists($SOURCE{$d}))) { # document matches source
      foreach my $s (sort {$a<=>$b} keys %{$DOCS{$d}}) {
         if ($printL) {
            print $d.":".$s.": ";
	 }
         print $DOCS{$d}->{$s}->[$R], "\n";
         push(@{$GENRES{$G{$d}}}, $N);
         $N++;
      }
   }
}

if ($verbose) { print STDERR "(", $N - 1, " segments extracted) [DONE]\n"; }

if ($printG) {
   foreach my $g (sort keys %GENRES) {
      print STDERR "segments_$g=", join(",", @{$GENRES{$g}}), "\n";
   }
}
