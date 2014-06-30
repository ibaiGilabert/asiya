package Statistics;

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
use Statistics::LSNoHistory;
use Statistics::RankCorrelation;
use Statistics::Distributions;
use Statistics::Descriptive;
use IQ::Common;

our($MINVALUE);
  
$Statistics::MINVALUE = -99999999;

# ========= CONFIDENCE INTERVALS =========================================================
    
#http://onlinestatbook.com/chapter8/correlation_ci.html

sub fisher_transform {
    #description _ compute Fisher transformation of r = z' = 1/2 ln((1+r)/(1-r))
    #param1  _ r coefficient
    #@return _ z'
	
    my $r = shift;
	
    if ($r == 1) { $r = 0.99999999; }
    #return 0.5 * log((1 + $r) / (1 - $r));
    return 0.5 * (log(1 + $r) - log(1 - $r));
}

sub inverse_fisher_transform {
    #description _ compute inverse Fisher transformation of z = r' = (e^(2*z) - 1) / (e^(2*z) + 1)
    #param1  _ z coefficient
    #@return _ r

    my $z = shift;
	
    return (exp(2*$z) - 1) / (exp(2*$z) + 1);
}

sub get_Fisher_confidence_interval($$$) {
	#description _ computes Fisher confidence interval (over a correlation coefficient)
	#param1 _ correlation coefficient
	#param2 _ number of samples
    #param3 _ alfa (i.e., 1 - statistical significance)
    
	my $R = shift;
	my $N = shift;
    my $alfa = shift;

    my $r1 = -1;
    my $r2 = 1;
    if ($N > 3) {
       my $z = fisher_transform($R);
       my $Z = Statistics::Distributions::udistr($alfa / 2);
       my $stderr = $Z / (sqrt($N - 3));
       my $z1 = $z - $stderr;
       my $z2 = $z + $stderr;    
       $r1 = inverse_fisher_transform($z1);
       $r2 = inverse_fisher_transform($z2);
    }
    
    return ($r1, $r2);
}

sub get_t_confidence_interval {
	#description _ computes t-student confidence interval (over a population of correlation coefficients)
	#param1 _ population of correlation coefficients (list ref)
    #param2 _ alfa (i.e., 1 - statistical significance)

	my $lR = shift;
	my $alfa = shift;
	
    my $stat = Statistics::Descriptive::Full->new();
    $stat->add_data(@{$lR}); 
    my $mean = $stat->mean();
    my $var  = $stat->variance();
    #my $stdev  = $stat->standard_deviation();
    #my $tm   = $stat->trimmed_mean(.25);
    #$Statistics::Descriptive::Tolerance = 1e-10;
    #printf "Mean: %10.8f  Var: %10.8f  Std Dev: %10.8f  Trimmed mean: %10.8f\n", $mean, $var, $stdev, $tm;
    my $N = scalar(@{$lR});    
    my $t = Statistics::Distributions::tdistr ($N, $alfa / 2);
    my $d = $t * sqrt($var) / sqrt($N);
  
    return ($mean, $d);
}

sub find_percentile($$) {
	#description _ returns value at the given percentile
	#param1 _ sorted value list
	#param2 _ percentile
	
	my $sorted_scores = shift;
	my $p = shift;
	
    my $v;	
    my $N = $#$sorted_scores + 1;    
	my $k = int(($N + 1) * $p);
	my $d = ($N + 1) * $p - $k;
	if($k == 0){ $v = $sorted_scores->[0]; }
    elsif ($k == $N){ $v = $sorted_scores->[$N - 1]; }
    else { $v = $sorted_scores->[$k - 1] + $d * ($sorted_scores->[$k] - $sorted_scores->[$k - 1]); }
    
    return $v;
}
sub get_percentile_confidence_interval {
	#description _ computes Percentile confidence interval (over a population of correlation coefficients)
	#param1 _ population of correlation coefficients (list ref)
    #param2 _ alfa (i.e., 1 - statistical significance)

	my $lR = shift;
	my $alfa = shift;

    #my $stat = Statistics::Descriptive::Full->new();
    #$stat->add_data(@{$lR}); 
    #my $mean = $stat->mean();
    #my $var  = $stat->variance();
    #my $stdev  = $stat->standard_deviation();
    #my $tm   = $stat->trimmed_mean(.25);
    #$Statistics::Descriptive::Tolerance = 1e-10;
    #printf "Mean: %10.8f  Var: %10.8f  Std Dev: %10.8f  Trimmed mean: %10.8f\n", $mean, $var, $stdev, $tm;
    my $N = scalar(@{$lR});    

	my @sorted_scores = sort {$a <=> $b} @{$lR};
		
	my $r1 = find_percentile(\@sorted_scores, $alfa/2);
	my $r2 = find_percentile(\@sorted_scores, 1.0-$alfa/2);
    my $median = find_percentile(\@sorted_scores, 0.5);

    return ($median, $r1, $r2);
}

sub get_random_bootstrap_sample {
    #description _ retrieve a new random bootstrap (x, y) sample
    #param1  _ x values
    #param2  _ y values

    my $xvalues = shift;
    my $yvalues = shift;

    srand();
    my @x; my @y;
    my $max = scalar(@{$xvalues});
    for (my $i = 0; $i < $max; $i++) {
       my $r = int(rand($max));
       push(@x, $xvalues->[$r]);
       push(@y, $yvalues->[$r]);
    }

    return (\@x, \@y);
}

sub get_random_paired_bootstrap_sample {
    #description _ retrieve a new random bootstrap (x, y, z) sample
    #param1  _ x values
    #param2  _ y values
    #param3  _ z values

    my $xvalues = shift;
    my $yvalues = shift;
    my $zvalues = shift;

    srand();
    my @x; my @y; my @z;
    my $max = scalar(@{$xvalues});
    for (my $i = 0; $i < $max; $i++) {
       my $r = int(rand($max));
       push(@x, $xvalues->[$r]);
       push(@y, $yvalues->[$r]);
       push(@z, $zvalues->[$r]);
    }

    return (\@x, \@y, \@z);
}

# ========= CORRELATION COEFFICIENTS =========================================================

sub do_spearman {
    #description _ compute Spearman correlation between two given rankings
    #param1  _ ranking 1 (list reference)
    #param2  _ ranking 2 (list reference)
    #param3  _ verbosity
    #@return _ correlation value

    my $xvalues = shift;
    my $yvalues = shift;
    my $verbose = shift;

    #my $c = Statistics::RankCorrelation->new($xvalues , $yvalues);
    #return $c->spearman;
    return Statistics::compute_spearman($xvalues, $yvalues, $verbose);
}

sub valid_values {
    #description _ checks if (x, y) values are valid (at least two points are required)
    #param1  _ ranking 1 (list reference)
    #param2  _ ranking 2 (list reference)
    #@return _ 1 if valid; 0 otherwise

    my $xvalues = shift;
    my $yvalues = shift;

    my $i = 0;
    my $valid = 0;
    my %values;
    while (($i < scalar(@{$xvalues})) and !$valid) {
       if (($i > 0) and !exists($values{$xvalues->[$i]}->{$yvalues->[$i]})) { $valid = 1; }
       $values{$xvalues->[$i]}->{$yvalues->[$i]}++;
       $i++;
    }

    return $valid;
}

sub only_ties{
    #description _ checks if (x, y) values don't contain only ties
    #param1  _ ranking 1 (list reference)
    #param2  _ ranking 2 (list reference)
    #@return _ 1 if valid; 0 otherwise

    my $xvalues = shift;
    my $yvalues = shift;

    my @arr = @{$xvalues};
    my @newarr = unique_values(@arr);

    if ( scalar(@newarr) == 1 ){
	return 1;
    }

    @arr = @{$yvalues};
    @newarr = unique_values(@arr);

    if ( scalar(@newarr) == 1 ){
	return 1;
    }

    return 0;
}

sub unique_values {
    my %seen = ();
    my @r = ();
    foreach my $a (@_) {
        unless ($seen{$a}) {
            push @r, $a;
            $seen{$a} = 1;
        }
    }
    return @r;
}



sub do_pearson {
    #description _ compute pearson correlation between two given rankings
    #              + confidence interval
    #param1  _ ranking 1 (list reference)
    #param2  _ ranking 2 (list reference)
    #param3  _ verbosity
    #@return _ correlation value

    my $xvalues = shift;
    my $yvalues = shift;
    my $verbose = shift;
    
    my @aux_xvalues = @{$xvalues};
    my @aux_yvalues = @{$yvalues};
        
    if (valid_values($xvalues, $yvalues)) {
       #my $LSNoH = Statistics::LSNoHistory->new(xvalues => \@aux_xvalues, yvalues => \@aux_yvalues);    
       #return $LSNoH->pearson_r();
       return Statistics::compute_pearson($xvalues, $yvalues, $verbose);
    }
    else { return undef; }
}

sub do_kendall {
    #description _ compute Kendall tau correlation between two given rankings
    #param1  _ ranking 1 (list reference)
    #param2  _ ranking 2 (list reference)
    #param3  _ statistical significance ([0..1])
    #param4  _ verbosity
    #@return _ correlation value

    my $xvalues = shift;
    my $yvalues = shift;
    my $verbose = shift;

#    if (valid_values($xvalues, $yvalues)) {
    if (!only_ties($xvalues, $yvalues)) {

       my $c = Statistics::RankCorrelation->new($xvalues , $yvalues);
       return $c->kendall;
    }
    else { return undef; }
}



sub compute_pearson {
    #description _ compute pearson correlation between two given rankings
    #param1  _ ranking 1 (list reference)
    #param2  _ ranking 2 (list reference)
    #param3  _ verbosity
    #@return _ correlation value + regression line (y = a + bx)

    my $ranking1 = shift;
    my $ranking2 = shift;
    my $verbose = shift;

    if (scalar(@{$ranking1}) != scalar(@{$ranking2})) {
    #if (scalar(keys %{$ranking1}) != scalar(keys %{$ranking2})) {
       die "[Pearson correlation] No correspondence between rankings!!!\n";
    }

    if (scalar(@{$ranking1}) == 0) { die "[Pearson correlation] Empty ranking!!!\n"; }

    my $n = 0;
    my $Sx = 0;   my $Sy = 0;   my $Sx2 = 0;   my $Sy2 = 0;   my $Sxy = 0;

    #foreach my $id (keys %{$ranking1}) {
    #   #if (!(exists $ranking2->{$id})) { die "[Pearson correlation] No correspondence between rankings: id = <$id>!!!\n" ; }
    #   if (exists $ranking2->{$id}) {

    while ($n < scalar(@{$ranking1})) {
       my $r1 = $ranking1->[$n];
       my $r2 = $ranking2->[$n];
       $Sx += $r1;
       $Sy += $r2;
       $Sx2 += $r1**2;
       $Sy2 += $r2**2;
       $Sxy += $r1 * $r2;
       $n++;
    }  


    #y = a + bx -------------------------------------------------
    my $b; my $a;
    if (($n * $Sx2 - $Sx**2) != 0) {
       $b = ($n * $Sxy - $Sx * $Sy) / ($n * $Sx2 - $Sx**2);
       $a = ($Sy - $b * $Sx) / $n;
    }
    #------------------------------------------------------------

    my $r;
    if (((($Sx2 - $Sx**2 / $n) > 0) and (($Sy2 - $Sy**2 / $n) > 0)) or
       ((($Sx2 - $Sx**2 / $n) < 0) and (($Sy2 - $Sy**2 / $n) < 0))) {
       $r = ($Sxy - ($Sx * $Sy / $n)) / sqrt(($Sx2 - $Sx**2 / $n) * ($Sy2 - $Sy**2 / $n));
    }

    #return  ($r, $a, $b);
    return  $r;
}

sub compute_spearman {
    #description _ compute Spearman correlation between two given rankings
    #param1  _ ranking 1 (list reference)
    #param2  _ ranking 2 (list reference)
    #param3  _ verbosity
    #@return _ correlation coefficient

    my $ranking1 = shift;
    my $ranking2 = shift;
    my $verbose = shift;

    if (scalar(@{$ranking1}) != scalar(@{$ranking2})) {
       die "[Spearman correlation] No correspondence between rankings!!!\n";
    }
    
    my $n = scalar(@{$ranking1});
    if ($n == 0) { die "[Spearman correlation] Empty ranking!!!\n"; }
    if ($n == 1) { print STDERR "[Spearman correlation] Only one element!!!\n"; return 0; }

    my %rank1;
    my $posRank = 1;
    my %check_done;
    while ($posRank <= scalar(@{$ranking1})) {
       my $maxScore=$MINVALUE; my $maxDid="";
       my $i = 0;
       while ($i < scalar(@{$ranking1})) {
          if (($ranking1->[$i] >= $maxScore)) {
          	 if ((!exists($check_done{$i})) or (exists($check_done{$i}) and ($check_done{$i} != 1))) {
                $maxScore = $ranking1->[$i]; $maxDid = $i;
          	 }
          	 else{
          	 }
          }
          else{
          }
          $i++;
       }
       $rank1{$maxDid} = $posRank; $check_done{$maxDid} = 1; $posRank++;
    }

    my %rank2;
    $posRank = 1;
    %check_done = ();
    while ($posRank <= scalar(@{$ranking2})) {
       my $maxScore=$MINVALUE; my $maxDid="";
       my $i = 0;
       while ($i < scalar(@{$ranking2})) {
          if (($ranking2->[$i] >= $maxScore)) { 
          	 if ((!exists($check_done{$i})) or (exists($check_done{$i}) and ($check_done{$i} != 1))) {
                $maxScore = $ranking2->[$i]; $maxDid = $i;
             }
          }
          $i++;
       }
       $rank2{$maxDid} = $posRank; $check_done{$maxDid} = 1; $posRank++;
    }

    my $n2 = $n * ($n * $n - 1);
  
    my $sumd2 = 0;
    foreach my $did (keys %rank1) {
       my $r1 = $rank1{$did} || $n+1; my $r2 = $rank2{$did} || $n + 1;
       my $d = abs($r1 - $r2);
       $sumd2 += $d * $d;
    }

    return 1 - (6 * $sumd2 / $n2);
}

# *************************************************************************************
# ******************************* PUBLIC METHODS **************************************
# *************************************************************************************

sub compute_correlation {
    #description _ compute correlation coefficients between given x and y value lists
    #param1  _ correlation type ('pearson' / 'spearman' / 'kendall')
    #param2  _ x values (list ref)
    #param3  _ y values (list ref)
    #param4  _ verbosity

    my $Ctype = shift;
    my $xvalues = shift;
    my $yvalues = shift;
    my $verbose = shift;

    if ((scalar(@{$xvalues}) == 0) or (scalar(@{$yvalues}) == 0)) { die "[ERROR] Empty ranking " . scalar(@{$xvalues}) . scalar(@{$yvalues}) . " !!!\n"; }

    my $R;
    if (lc($Ctype) eq $Common::C_PEARSON) { $R = Statistics::compute_pearson($xvalues, $yvalues, $verbose); }
    elsif (lc($Ctype) eq $Common::C_SPEARMAN) { $R = Statistics::compute_spearman($xvalues, $yvalues, $verbose); }
    elsif (lc($Ctype) eq $Common::C_KENDALL) { $R = Statistics::do_kendall($xvalues, $yvalues, $verbose); }
    elsif (lc($Ctype) eq $Common::C_MRANKENDALL) { $R = Statistics::do_multiple_ranks_kendall($xvalues, $yvalues, $verbose); }
    else { die "[ERROR] unknown correlation type <$Ctype>!\n"; }

    if (!defined($R)) { $R = 0; }
    
    return $R;
}

#sub sign_test {
#   #description _ computes the sign test
#   #param1  _ n1 A > B
#   #param2  _ n2 A < B
#   #param3  _ alpha
#   #@return _ 1:  A better than B   0:  A equal than B   -1:  A worse than B
#
#   my $n1 = shift;
#   my $n2 = shift;
#   my $alpha = shift;
#
#   my $imp = 0;
#   my $min = $n1; if ($n2 < $n1) { $min = $n2; }
#   my $test = pbinom($min, ($n1 + $n2), 0.5);    #Statistical Significance sign-test
#   if (($n1 > $n2) and ($test < $alpha)) { $imp = 1; } 
#   elsif (($n1 < $n2) and ($test < $alpha)) { $imp = -1; }
#   else { $imp = 0; }
#
#   return ($test, $imp);
#}


sub get_bootstrap_correlation_confidence_intervals_90_95_99 {
    #description _ estimate confidence interval for a given correlation coefficient via bootstrap resampling
    #              Philipp Koehn. Statistical Significance Tests for Machine Translation Evaluation. (EMNLP'04).
    #param1  _ x values
    #param2  _ y values
    #param3  _ correlation type
    #param4  _ number of resamplings
    #@return _ (mean, low_threshold, high_threshold)
	
    my $xvalues = shift;
    my $yvalues = shift;
    my $Ctype = shift;
    my $n = shift;

    my @lR;
    for (my $i = 0; $i < $n; $i++) {
       my ($x_i, $y_i) = get_random_bootstrap_sample($xvalues, $yvalues);
       my $R = compute_correlation($Ctype, $x_i, $y_i, 0);
       if (defined($R)) { push(@lR, $R); }
    }

    #my ($mean_95, $d_95) = get_t_confidence_interval(\@lR, 0.05);
    #my ($mean_99, $d_99) = get_t_confidence_interval(\@lR, 0.01);
    #return ($mean_95, $d_95, $d_99);
    
    my ($mean_90, $r1_90, $r2_90) = get_percentile_confidence_interval(\@lR, 0.1);
    my ($mean_95, $r1_95, $r2_95) = get_percentile_confidence_interval(\@lR, 0.05);
    my ($mean_99, $r1_99, $r2_99) = get_percentile_confidence_interval(\@lR, 0.01);
  
    return ($mean_95, $r1_90, $r2_90, $r1_95, $r2_95, $r1_99, $r2_99);
}


1;
