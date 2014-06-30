package QARLA;

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
use IQ::Common;
use IQ::Scoring::Scores;

our($QUEEN_NAME);

$QARLA::QUEEN_NAME = 'QUEEN';


# *************************************************************************************
# ******************************* PUBLIC METHODS **************************************
# *************************************************************************************


sub QUEEN($$$$$$) {
    #description _ compute QUEEN
    #param1  _ configuration
    #param2  _ scores
    #param3  _ system set
    #param4  _ reference set
    #param5  _ metric set
    #param6  _ granularity
    
    my $config = shift;
    my $hOQ = shift;
    my $systems = shift;
    my $references = shift;
    my $metrics = shift;
    my $G = shift;

    if (scalar(@{$references}) < 3) { die "[ERROR] QUEEN computation requires at least three references!!\n"; }
    
    my $doALL = (scalar(keys %{$config->{segments}}) == 0);  # if no segments are specified, print all

    my $ref = join("_", sort @{$references});

    foreach my $system (@{$systems}) {    
       my @QTOPICS;
       my @STOPICS;
       Scores::load($hOQ, $metrics, $config->{segments}, [$system], $references, $Common::G_SEG, 1, 0, 1, 0, 0);
       foreach my $r0 (@{$references}) {	 
          if ($system ne $r0) { 	   
             foreach my $r1 (@{$references}) { 
                if ($system ne $r1) { 	   
                   foreach my $r2 (@{$references}) {
                      if (($system ne $r2) && ($r1 ne $r2)) {
                         for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_SEG}}); $i++) {
                            if (exists($config->{segments}->{$i + 1}) or $doALL) {
    	                       $STOPICS[$i]++;
                               my $queen_condition = 1;
                               foreach my $m (@{$metrics}) {
                                  if ($hOQ->{$Common::G_SEG}->[$i]->{$m}->{$system}->{$r0} <
                                      $hOQ->{$Common::G_SEG}->[$i]->{$m}->{$r1}->{$r2})
                                  { $queen_condition = 0; last; }
                               }
                               if ($queen_condition == 1) { $QTOPICS[$i]++; }
        	                }
                         }
                      }
                   }
                }
             }
          }
       }
    
       my $q_sys = 0; my $n_sys = 0;
       my $q_doc = 0; my $n_doc = 0; my $ndoc = 0; my $docid = "";
       my $i = 0;
       while ($i < scalar(@{$hOQ->{$Common::G_SEG}})) {
          if (($G eq $Common::G_DOC) or ($G eq $Common::G_ALL)) {
             if ($config->{IDX}->{$system}->[$i + 1]->[0] ne $docid) { # new document
                if ($docid ne "") {
                   $hOQ->{$Common::G_DOC}->[$ndoc]->{$QARLA::QUEEN_NAME}->{$system}->{$ref} = Common::safe_division($q_doc, $n_doc);
                   $ndoc++;
                }
                my $q_doc = 0; my $n_doc = 0;
                $docid = $config->{IDX}->{$system}->[$i + 1]->[0];
             }
          }
          my $n = 0; my $q = 0;
          if (defined($STOPICS[$i])) {
    	     $n = $STOPICS[$i];
             if (defined($QTOPICS[$i])) { $q = $QTOPICS[$i]; }
          }
          if (($G eq $Common::G_SEG) or ($G eq $Common::G_ALL)) {
             $hOQ->{$Common::G_SEG}->[$i]->{$QARLA::QUEEN_NAME}->{$system}->{$ref} = Common::safe_division($q, $n);
          }
          $n_doc += $n; $q_doc += $q;
          $n_sys += $n; $q_sys += $q;
          $i++;
       }
   
       if (($G eq $Common::G_DOC) or ($G eq $Common::G_ALL)) {
          $hOQ->{$Common::G_DOC}->[$ndoc]->{$QARLA::QUEEN_NAME}->{$system}->{$ref} = Common::safe_division($q_doc, $n_doc);
       }
   
       if (($G eq $Common::G_SYS) or ($G eq $Common::G_ALL)) {
          $hOQ->{$Common::G_SYS}->{$QARLA::QUEEN_NAME}->{$system}->{$ref} = Common::safe_division($q_sys, $n_sys);
       }
    }
}

1;
