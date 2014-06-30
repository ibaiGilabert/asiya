package ULC;

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
our($ULC_NAME);

$ULC::ULC_NAME = 'ULC';


sub compute_normalized_ULC {
    #description _ computes normalized ULC (i.e., normalized arithmetic mean) of metric scores (ULC scores are in the [0..1] range)
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

    my $ref = join("_", sort @{$references});

    foreach my $system (@{$systems}) {
       Scores::load($hOQ, $metrics, $config->{segments}, [$system], $references, $G, 0, 1, 0, 0, 0);
       foreach my $g (keys %{$hOQ}) {
       	 if ($g eq $Common::G_ALL) {
       	 	# skip
       	 }
          elsif ($g eq $Common::G_SYS) {
             my $x = 0;
             foreach my $m (@{$metrics}) {
                if ( $config->{min_score}->{$g}->{$m} < 0 ){ #metrics with negative values
                  $x += Common::safe_division($hOQ->{$g}->{$m}->{$system}->{$ref}+abs($config->{min_score}->{$g}->{$m}), $config->{max_score}->{$g}->{$m}+abs($config->{min_score}->{$g}->{$m}));
                }
                else{
                  $x += Common::safe_division($hOQ->{$g}->{$m}->{$system}->{$ref}, $config->{max_score}->{$g}->{$m});
                }
             }
             $hOQ->{$g}->{$ULC::ULC_NAME}->{$system}->{$ref} = Common::safe_division($x, scalar(@{$metrics}));
             
          }
          else {
             for (my $i = 0; $i < scalar(@{$hOQ->{$g}}); $i++) {
                my $x = 0;
                foreach my $m (@{$metrics}) {
                   if ( $config->{min_score}->{$g}->{$m} < 0 ){ #metrics with negative values
                	   $x += Common::safe_division($hOQ->{$g}->[$i]->{$m}->{$system}->{$ref}+abs($config->{min_score}->{$g}->{$m}), $config->{max_score}->{$g}->{$m}+abs($config->{min_score}->{$g}->{$m}));
                	}
                	else{
                	   $x += Common::safe_division($hOQ->{$g}->[$i]->{$m}->{$system}->{$ref}, $config->{max_score}->{$g}->{$m});
                	}
                }
                $hOQ->{$g}->[$i]->{$ULC::ULC_NAME}->{$system}->{$ref} = Common::safe_division($x, scalar(@{$metrics}));
             }
          }
       }
    }
}

1;
