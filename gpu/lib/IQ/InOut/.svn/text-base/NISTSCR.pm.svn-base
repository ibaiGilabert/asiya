package NISTSCR;

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
use IQ::Common;

sub read_scr_file {
    #description _ reads a given MetricsMaTr format scr file (of a given granularity)
    #param1  _ filename
    #param2  _ granularity
    #param3  _ do_negation? 0-> return scores :: 1-> return -scores
    #@return _ score list ref

    my $file = shift;
    my $G = shift;
    my $do_neg = shift;
    
    my %scores;
    my $F = new IO::File("< $file") or die "[ERROR] unavailable file <$file>\n";
    while (defined(my $line = $F->getline())) {
       chomp($line); my @l = split(/\s/, $line);
       (my $k, my $n) = get_score(\@l, $G, $do_neg);
       $scores{$k}=$n;
    }
    $F->close();

    return \%scores;
}

sub get_score {
    #description _ reads the score from the corresponding column according to the given granularity
    #param1  _ input list ref
    #param2  _ granularity
    #param3  _ do_negation? 0-> return scores :: 1-> return -scores
    #@return _ score 

    my $l = shift;
    my $G = shift;
    my $do_neg = shift;

    my $n = undef;    my $k = undef;
    if ($G eq $Common::G_SYS) { $k="sys::".$l->[1]; $n = negate_or_not($l->[2], $do_neg); }
    elsif ($G eq $Common::G_DOC) { $k="sys::".$l->[1]."::doc::".$l->[2]; $n = negate_or_not($l->[3], $do_neg); }
    elsif ($G eq $Common::G_SEG) { $k="sys::".$l->[1]."::doc::".$l->[2]."::seg::".$l->[3]; $n = negate_or_not($l->[4], $do_neg); }

    return ($k,$n);
}

sub negate_or_not {
    #description _ negates the given arithmetic value iff do_neg is true, otherwise returns the value as is
    #param1  _ input number
    #param3  _ do_negation? 0-> return score :: 1-> return -score
    #@return _ score

    my $n = shift;
    my $do_neg = shift;

    return ($do_neg? -$n : $n);

}

1;
