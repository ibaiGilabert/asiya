package Scores;

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
#use IQ::Common;

sub load($$$$$$$$$$$) {
    #description _ given a set of metrics, systems and human references reloads (only if necessary) similarities
    #              for a given set of segments.
    #param1  _ metric scores
    #param2  _ set of metrics
    #param3  _ set of segments
    #param4  _ set of systems
    #param5  _ set of references
    #param6  _ granularity ('sys' / 'doc' /'seg')
    #param7  _ load single-reference scores
    #param8  _ load multiple-reference scores
    #param9  _ load reference-reference scores
    #param10 _ load system-system scores
    #param11 _ verbosity (0/1)
 
    my $hOQ = shift;
    my $metrics = shift;
    my $segments = shift;
    my $systems = shift;
    my $references = shift;
    my $G = shift;
    my $doSINGLE = shift;
    my $doMULTIPLE = shift;
    my $doREFS = shift;
    my $doSYSTEMS = shift;
    my $verbose = shift;

    if ($verbose) { print STDERR "["; }

    foreach my $m (@{$metrics}) {
       if ($verbose) { print STDERR "$m.."; }

       if ($doSINGLE) {
          foreach my $s (@{$systems}) {
             foreach my $r (@{$references}) {
                IQXML::read_report($s, $r, $m, $hOQ, $segments, $G, $verbose);
             }
          }
       }
       
       if ($doMULTIPLE) {
          foreach my $s (@{$systems}) {
             my $r = join("_", @{$references});
             IQXML::read_report($s, $r, $m, $hOQ, $segments, $G, $verbose);
          }
       }

       if ($doREFS) {
          foreach my $r1 (@{$references}) {
             foreach my $r2 (@{$references}) {
                if ($r1 ne $r2) {
                   IQXML::read_report($r1, $r2, $m, $hOQ, $segments, $G, $verbose);
                }
             }
          }
       }

       if ($doSYSTEMS) {
          foreach my $s1 (@{$systems}) {
             foreach my $s2 (@{$systems}) {
                if ($s1 ne $s2) {
                   IQXML::read_report($s1, $s2, $m, $hOQ, $segments, $G, $verbose);
                }
             }
          }
       }
    }
    
    if ($verbose) { print STDERR "]\n"; }
}



# ------------------------------------------------------------------------
# ------------------------------------------------------------------------

sub save_hash_scores{
    #description _ saves as a hash of scores
    #param1  _ SYS level scores
    #param2  _ DOC level scores
    #param3  _ SEG level scores
    #param4  _ hash of scores

	 my $metric_name = shift;
	 my $system_name = shift;
	 my $refere_name = shift;
	 my $sys_score  = shift;
	 my $doc_scores = shift;
	 my $seg_scores = shift;
	 my $hOQ = shift;
	 
	 #system-level
	 $hOQ->{$Common::G_SYS}->{$metric_name}->{$system_name}->{$refere_name} = $sys_score;
	 
	 #document-level
 	 for (my $d=0; $d < scalar(@{$doc_scores}) ; $d++ ){
		 $hOQ->{$Common::G_DOC}->[$d]->{$metric_name}->{$system_name}->{$refere_name} = $doc_scores->[$d];
	 }

	 #segment-level
 	 for (my $s=0; $s < scalar(@{$seg_scores}) ; $s++ ){
		 $hOQ->{$Common::G_SEG}->[$s]->{$metric_name}->{$system_name}->{$refere_name} = $seg_scores->[$s];
	 }
	 $hOQ->{$Common::G_ALL}->{$metric_name}->{$system_name}->{$refere_name} = {};
}


1;

