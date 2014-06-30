package Consistency;

# ------------------------------------------------------------------------

#Copyright (C) Jesus Gimenez, Meritxell Gonzalez

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



sub compute_multiranks {
    #description _ compute correlation coefficients between given x and y value lists
    #param1  _ correlation type ('consistency' / 'kendall')
    #param2  _ x values (list ref)
    #param3  _ y values (list ref)
    #param4  _ verbosity

    my $ctype = shift;
    my $Mvalues = shift; #system rankings
    my $Gvalues = shift; #assessments file
    my $verbose = shift;

    #if ((scalar(@{$xvalues}) == 0) or (scalar(@{$yvalues}) == 0)) { die "[ERROR] Empty ranking " . scalar(@{$xvalues}) . scalar(@{$yvalues}) . " !!!\n"; }

    my $R;
    if ( $ctype ne $Common::C_CONSISTENCY && $ctype ne $Common::C_MRANKENDALL ) 
    	 { die "[ERROR] unknown correlation type <$ctype> , $Common::C_MRANKENDALL !\n"; }

    my $total = 0;
    my $agree = 0;
    my $disagree = 0;

    foreach my $item (keys %{$Gvalues}) { # the rankings in the assessments file
   	 my @aritem = split ( "##", $item);
    	 my $sitem = ( scalar(@aritem)>1 ) ? $aritem[1] : $aritem[0]; # document@@segment
    	 
       if (exists($Mvalues->{$sitem})) {
       	 my %comparedsystems;
          foreach my $system_A (keys %{$Gvalues->{$item}}) {
             if (exists($Mvalues->{$sitem}->{$system_A})) {
             	 $comparedsystems{$system_A} = 1;
                foreach my $system_B (keys %{$Gvalues->{$item}}) {
                	 # don't compare the systems twice in each direction!
                   if (!exists($comparedsystems{$system_B}) && exists($Mvalues->{$sitem}->{$system_B}) ) {
							my $m_A = $Mvalues->{$sitem}->{$system_A};
							my $m_B = $Mvalues->{$sitem}->{$system_B};
							my $g_A = $Gvalues->{$item}->{$system_A};
							my $g_B = $Gvalues->{$item}->{$system_B};
                     #print "$sitem $system_A $system_B :: $m_A vs $m_B :: $g_A vs $g_B\n";
							if ($g_A != $g_B) { # exclude human assessment ties
								if ( $m_A == $m_B ){ # disagree with two non-tied human assessments
									if ( num_non_tied($sitem, $system_A, $system_B, $Gvalues) > 1 ){ $disagree++; $total++; }
                       		else{ $total++; }
                        }
                        else{
                          	if ((($m_A - $m_B) * ($g_A - $g_B)) > 0) { $agree++; $total++; }
                          	else{ $disagree++; $total++; }
                        }
							}
                   }
                }
             }	
          }
       }
    }

	 if ( $ctype eq $Common::C_CONSISTENCY ){
    	return Common::safe_division($agree, $total);
    }
    elsif ( $ctype eq $Common::C_MRANKENDALL ){
    	print "agree $agree disagree $disagree total $total\n";
    	return Common::safe_division(($agree-$disagree), $total);
    }
}






sub num_non_tied{
    #description _ count the number of non tied assessments between two systems in multiple   
    #param1  _ item doc#seg 
    #param2  _ system1 name
    #param3  _ system2 name
    #param2  _ hash reference of assessments

	my $item = shift;
	my $system_A= shift;
	my $system_B=shift;
	my $ar = shift;

	 my $numann = 0;
	 my $numnontied=0;
	 while ( exists( $ar->{$numann."##".$item}) ){
	 	if ( exists( $ar->{$numann."##".$item}->{$system_A}) && exists( $ar->{$numann."##".$item}->{$system_B}) ){
			my $scr_A = $ar->{$numann."##".$item}->{$system_A};
			my $scr_B = $ar->{$numann."##".$item}->{$system_B};
			if ( $scr_A != $scr_B ){ $numnontied++; } 
	 	}
	 	$numann++;
	 }
	
	 return $numnontied;
}


#sub do_multiple_rank_kendall {
    #description _ compute kendall's tau correlation between two ranking lists 
    #param1  _ ranking 1 (list reference) 
    #param2  _ ranking 2 (list reference) - having the number of the ranking in the key as NUM##!
	
#    my $Mvalues = shift;
#    my $Gvalues = shift;
	
#    my $total = 0;
#    my $agree = 0;
#    my $disagree = 0;

#    foreach my $item (keys %{$Gvalues}) { # the rankings in the assessments file
#    	 my @aritem = split ( "##", $item);
#    	 my $sitem = ( scalar(@aritem)>1 ) ? $aritem[1] : $aritem[0]; # document@@segment
#       if (exists($Mvalues->{$sitem})) {
#          foreach my $system_A (keys %{$Gvalues->{$item}}) {
#             if (exists($Mvalues->{$sitem}->{$system_A})) {
#                foreach my $system_B (keys %{$Gvalues->{$item}}) {
#                   if ($system_A ne $system_B) {
#                      if (exists($Mvalues->{$sitem}->{$system_B})) {
#                         my $m_A = $Mvalues->{$sitem}->{$system_A};
#                         my $m_B = $Mvalues->{$sitem}->{$system_B};
#                         my $g_A = $Gvalues->{$item}->{$system_A};
#                         my $g_B = $Gvalues->{$item}->{$system_B};
#                         #print "$sitem $system_A $system_B :: $m_A vs $m_B :: $g_A vs $g_B\n";
#                         if ($g_A != $g_B) { # exclude human assessment ties
#                         	if ( $m_A == $m_B ){ # disagree with two non-tied human assessments
#                         		if ( num_non_tied($sitem, $system_A, $system_B, $Gvalues) > 1 ){ $disagree++; }
#                         		else{ $agree++; }
#                         	}
#                         	else{
#                           	if ((($m_A - $m_B) * ($g_A - $g_B)) > 0) { $agree++; }
#                           	else{ $disagree++; }
#                           }
#                           $total++;
#                         }
#                      }
#                   }
#                }
#             }	
#          }
#       }
#    }

#    return Common::safe_division(($agree-$disagree), $total);
#}




#sub compute_consistency($$) {
    #description _ compute consistency between two ranking lists 
    #param1  _ ranking 1 (list reference)
    #param2  _ ranking 2 (list reference)
	
#    my $Mvalues = shift;
#    my $Gvalues = shift;
	
#    my $total = 0;
#    my $hits = 0;

    #print Dumper $Mvalues;
    #print Dumper $Gvalues;
#    foreach my $item (keys %{$Gvalues}) {
#    	 my @aritem = split ( "##", $item);
#    	 my $sitem = ( scalar(@aritem)>1 ) ? $aritem[1] : $aritem[0]; # document@@segment
#       if (exists($Mvalues->{$item})) {
#          foreach my $system_A (keys %{$Gvalues->{$item}}) {
#             if (exists($Mvalues->{$item}->{$system_A})) {
#                foreach my $system_B (keys %{$Gvalues->{$item}}) {
#                   if ($system_A ne $system_B) {
#                      if (exists($Mvalues->{$item}->{$system_B})) {
#                         my $m_A = $Mvalues->{$item}->{$system_A};
#                         my $m_B = $Mvalues->{$item}->{$system_B};
#                         my $g_A = $Gvalues->{$item}->{$system_A};
#                         my $g_B = $Gvalues->{$item}->{$system_B};
#                         #print "$item $system_A $system_B :: $m_A vs $m_B :: $g_A vs $g_B\n";
#                         if ($g_A != $g_B) { # exclude ties
#                            if ((($m_A - $m_B) * ($g_A - $g_B)) > 0) { $hits++; }
#                            $total++;
#                         }
#                      }
#                   }
#                }
#             }	
#          }
#       }    	
#    }
        	
#    return Common::safe_division($hits, $total);
#}


        	
#    return Common::safe_division($hits, $


1;
