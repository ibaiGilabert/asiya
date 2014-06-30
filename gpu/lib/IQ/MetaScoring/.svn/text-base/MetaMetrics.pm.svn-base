package MetaMetrics;

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
use IQ::InOut::IQXML;
use IQ::InOut::NISTXML;
use IQ::InOut::TeX;
use IQ::MetaScoring::Statistics;
use IQ::MetaScoring::Consistency;
use IQ::MetaScoring::Assessments;
use IQ::MetaScoring::ULC;
use IQ::Scoring::Scores;

# *************************************************************************************
# ************************ PRINT METHODS **********************************************
# *************************************************************************************

sub print_KING_table {
    #description _ prints correlation table
    #param1  _ configuration
    #param2  _ metric correlation coefficients (hash ref)
    #param3  _ sort criterion
    #param4  _ evaluation schemes (hash ref)

    my $config = shift;
    my $hR = shift;
    my $sort = shift;
    my $schemes = shift;

    Common::print_hline('-', $Common::HLINE_LENGTH);
    printf "%-20s %-".$config->{float_length}."s\n", "metric", "KING";
    Common::print_hline('-', $Common::HLINE_LENGTH);

    my @metrics;
    if ($sort eq $Common::SORT_NAME) { @metrics = sort keys %{$hR}; }
    elsif ($sort eq $Common::SORT_SCORE) { @metrics = sort {$hR->{$b}->[0] <=> $hR->{$a}->[0]} keys %{$hR}; }
    else {
       if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
       if (exists($schemes->{$Common::S_ULC}) and exists($hR->{$ULC::ULC_NAME})) { push(@metrics, $ULC::ULC_NAME); }
       if (exists($schemes->{$Common::S_QUEEN}) and exists($hR->{$QARLA::QUEEN_NAME})) { push(@metrics, $QARLA::QUEEN_NAME); }
    }

    foreach my $metric (@metrics) {
       printf "%-20s %s\n", $metric, Common::trunk_number($hR->{$metric}->[0], $config->{float_length}, $config->{float_precision});
    }
}

sub print_ORANGE_table {
    #description _ prints correlation table
    #param1  _ configuration
    #param2  _ metric correlation coefficients (hash ref)
    #param3  _ sort criterion
    #param4  _ evaluation schemes (hash ref)

    my $config = shift;
    my $hR = shift;
    my $sort = shift;
    my $schemes = shift;

    Common::print_hline('-', $Common::HLINE_LENGTH);
    printf "%-20s %-".$config->{float_length}."s\n", "metric", "ORANGE";
    Common::print_hline('-', $Common::HLINE_LENGTH);

    my @metrics;
    if ($sort eq $Common::SORT_NAME) { @metrics = sort keys %{$hR}; }
    elsif ($sort eq $Common::SORT_SCORE) { @metrics = sort {$hR->{$b}->[0] <=> $hR->{$a}->[0]} keys %{$hR}; }
    else {
       if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
       if (exists($schemes->{$Common::S_ULC}) and exists($hR->{$ULC::ULC_NAME})) { push(@metrics, $ULC::ULC_NAME); }
       if (exists($schemes->{$Common::S_QUEEN}) and exists($hR->{$QARLA::QUEEN_NAME})) { push(@metrics, $QARLA::QUEEN_NAME); }
    }

    foreach my $metric (@metrics) {
       printf "%-20s %s\n", $metric, Common::trunk_number($hR->{$metric}->[0], $config->{float_length}, $config->{float_precision});
    }
}

sub print_correlation_table {
    #description _ prints correlation table
    #param1  _ configuration
    #param2  _ metric correlation coefficients (hash ref)
    #param3  _ sort criterion
    #param4  _ correlation type ('pearson' / 'spearman' / 'kendall' / 'mrankendall')
    #param5  _ evaluation schemes (hash ref)
    #param6  _ confidence interval method
    #param7  _ granulariy used

    my $config = shift;
    my $hR = shift;
    my $sort = shift;
    my $criterion = shift;
    my $schemes = shift;
    my $ci_method = shift;
	 my $G = shift;
	 
    if ($config->{TEX} or exists($config->{PDF})) { # open table
       my $r = TeX::get_r_symbol($criterion);
       my $fs = TeX::get_font_size($config->{TEX_font_size});
       my $tex_line = "\\begin{table}[tbhp]\n".
                      "\\centering\n".
                      "{$fs\n".
                      "\\begin{tabular}{lrrr}\n".
                      sprintf("%-".($Common::METRIC_NAME_LENGTH * 2)."s & %-".$config->{float_length}."s",
                              "{\\bf metric}", "{\\bf\\boldmath \$".$r."\$}");
       if ($ci_method ne $Common::CI_NONE) {
          $tex_line .= sprintf(" & %-".($config->{float_length} * 2 + 4)."s & %s", "{\\bf confidence interval}", "{\\bf relative}");
       }
       $tex_line .= "\\\\\\hline\n";       
       if ($config->{TEX}) { print $tex_line; }
       if (exists($config->{PDF})) { $config->{TEX_REPORT} .= $tex_line; }
    }
    else {
       Common::print_hline('-', $Common::HLINE_LENGTH);
       printf "%-20s %-".$config->{float_length}."s", "METRIC", "r\t\t$criterion.",".$G";
       if ($ci_method ne $Common::CI_NONE) { printf "  %-".($config->{float_length} * 2 + 4)."s   %s", "confidence interval", "relative"; }
       printf "\n";
       Common::print_hline('-', $Common::HLINE_LENGTH);
    }
    
    my @metrics;
    if ($sort eq $Common::SORT_NAME) { @metrics = sort keys %{$hR}; }
    elsif ($sort eq $Common::SORT_SCORE) { @metrics = sort {$hR->{$b}->[0] <=> $hR->{$a}->[0]} keys %{$hR}; }
    else {
       if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
       if (exists($schemes->{$Common::S_ULC}) and exists($hR->{$ULC::ULC_NAME})) { push(@metrics, $ULC::ULC_NAME); }
       if (exists($schemes->{$Common::S_QUEEN}) and exists($hR->{$QARLA::QUEEN_NAME})) { push(@metrics, $QARLA::QUEEN_NAME); }
    }
   
    foreach my $metric (@metrics) {
       if (scalar(@metrics) > 0) {
          my $R = Common::trunk_number($hR->{$metric}->[0], $config->{float_length}, $config->{float_precision});
          my $Rmin; my $Rmax; my $RelativeCI;
          if (scalar(@{$hR->{$metric}}) == 3) {
             $Rmin = Common::trunk_number($hR->{$metric}->[1], $config->{float_length}, $config->{float_precision});
             $Rmax = Common::trunk_number($hR->{$metric}->[2], $config->{float_length}, $config->{float_precision});
             $RelativeCI = Common::trunk_number(abs(Common::safe_division(($Rmax - $Rmin), (2 * $R))) * 100, $config->{float_length}, $config->{float_precision});
          }

          if ($config->{TEX} or exists($config->{PDF})) {
             my $texmetric = TeX::tex_metric($metric);
             my $tex_line = sprintf("{\\bf\\boldmath %-".($Common::METRIC_NAME_LENGTH * 2)."s}", $texmetric);
             if (scalar(@{$hR->{$metric}}) > 0) {
                $tex_line .= sprintf(" & %-".$config->{float_length}."s", $R);
                if (scalar(@{$hR->{$metric}}) == 3) {
                   $tex_line .= sprintf(" & (%-".$config->{float_length}."s, %-".$config->{float_length}."s) & (\$\\pm\$ %s \\%%)", $Rmin, $Rmax, $RelativeCI);
                }
             }
             $tex_line .= "\\\\\n";
             if ($config->{TEX}) { print $tex_line; }
             if (exists($config->{PDF})) { $config->{TEX_REPORT} .= $tex_line; }
          }     
          else {
             if (scalar(@{$hR->{$metric}}) > 0) {
             	printf "%-20s %s", $metric, $R;
                if (scalar(@{$hR->{$metric}}) == 3) {
                	printf "  (%s, %s)  (+- %s %%)", $Rmin, $Rmax, $RelativeCI;
                }
                print "\n";
             }          	
          }
       }
    }

    if ($config->{TEX} or exists($config->{PDF})) { # close table
       my $tex_line = "\\end{tabular}\n".
                      "}\n".
                      "\\caption{".$Common::appNAME."-generated meta-evaluation report ($criterion, ".$config->{G}."-level)}\n".
                      "\\label{t-".$Common::appNAME."_".$config->{TEX_table_count}."}\n".
                      "\\end{table}\n";       
       $config->{TEX_table_count}++;
       if ($config->{TEX}) { print $tex_line; }
       if (exists($config->{PDF})) { $config->{TEX_REPORT} .= $tex_line; }       
    }
}

sub print_MMATRIX_header {
    #description _ print matrix score header (on a metric basis)
    #param1  _ configuration 
    #param2  _ evaluation schemes (hash ref)

    my $config = shift;
    my $schemes = shift;

    my @metrics;
    if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
    if (exists($schemes->{$Common::S_ULC})) { push(@metrics, $ULC::ULC_NAME); }
    if (exists($schemes->{$Common::S_QUEEN})) { push(@metrics, $QARLA::QUEEN_NAME); }
    
    my @sorted_metrics;
    if ($config->{SORT} eq $Common::SORT_NAME) { @sorted_metrics = sort @metrics; }
    else { @sorted_metrics = @metrics; }

    my @header;
    foreach my $metric (@sorted_metrics) { push(@header, Common::trunk_string($metric, $Common::METRIC_NAME_LENGTH)); }
    printf "%-".$Common::METRIC_NAME_LENGTH."s %s\n", "MxM", join(" ", @header);
    Common::print_hline('=', ($Common::METRIC_NAME_LENGTH + 1) * (scalar(@metrics) + 1));
}

sub print_metrics_table_pairwise {
    #description _ prints correlation pairwise test table
    #param1  _ configuration
    #param2  _ metric correlation coefficients (hash ref)
    #param3  _ sort criterion
    #param4  _ evaluation schemes (hash ref)

    my $config = shift;
    my $hR = shift;
    my $sort = shift;
    my $schemes = shift;
    
    print_MMATRIX_header($config, $schemes);

    my @metrics;
    if (exists($schemes->{$Common::S_SINGLE})) {
       foreach my $m (@{$config->{metrics}}) { push(@metrics, $m); }
    }
    if (exists($schemes->{$Common::S_ULC})) { push(@metrics, $ULC::ULC_NAME); }
    if (exists($schemes->{$Common::S_QUEEN})) { push(@metrics, $QARLA::QUEEN_NAME); }
    
    my @sorted_metrics;
    if ($config->{SORT} eq $Common::SORT_NAME) { @sorted_metrics = sort @metrics; }
    else { @sorted_metrics = @metrics; }
    
    foreach my $m_x (@sorted_metrics) {
       my @scores_x = (sprintf(""));
       foreach my $m_y (@sorted_metrics) {
       	  if (($m_x eq $m_y) or (!exists($hR->{$m_x}->{$m_y}))) { push(@scores_x, sprintf("%".$Common::METRIC_NAME_LENGTH."s", Common::sprint_hline('-', $config->{float_precision} + 2))); }
       	  else {
             push(@scores_x, Common::trunk_number($hR->{$m_x}->{$m_y}, $Common::METRIC_NAME_LENGTH, $config->{float_precision}));
       	  }
       }
       printf "%-".$Common::METRIC_NAME_LENGTH."s %s\n", $m_x, join(" ", @scores_x);
    }
}

sub print_correlation {
    #description _ prints correlation table
    #param1  _ configuration
    #param2  _ metric correlation coefficients (hash ref)
    #param3  _ sort criterion
    #param4  _ correlation type ('pearson' / 'spearman' / 'kendall' /'king' / 'mrankendall')
    #param5  _ evaluation schemes (hash ref)
    #param6  _ confidence interval method
	 #param7  _ granularity used 
	 
    my $config = shift;
    my $hR = shift;
    my $sort = shift;
    my $criterion = shift;
    my $schemes = shift;
    my $ci_method = shift;
	 my $G = shift;
	 
    if (($ci_method eq $Common::CI_NONE) or
       ($ci_method eq $Common::CI_FISHER) or
       ($ci_method eq $Common::CI_BOOTSTRAP) or
       ($ci_method eq $Common::CI_EXHAUSTIVE_BOOTSTRAP)) {
       print_correlation_table($config, $hR, $sort, $criterion, $schemes, $ci_method, $G);
    }
    elsif (($ci_method eq $Common::CI_PAIRED_BOOTSTRAP) or ($ci_method eq $Common::CI_EXHAUSTIVE_PAIRED_BOOTSTRAP)) {
       print_metrics_table_pairwise($config, $hR, $sort, $schemes);
    }
    else { die "[ERROR] unknown confidence inteval method <", $ci_method, "!\n"; }
}

# *************************************************************************************
# ************************* CORRELATION ***********************************************
# *************************************************************************************

sub build_metric_ranking {
    #description _ prepare metric scores for computing correlation coefficients
	 #param1  _ configuration
    #param2  _ hash of metric scores
    #param3  _ prepared metric scores (hash ref)
    #param4  _ list of document ids
    #param5  _ metric name
    #param6  _ system name
    #param7  _ reference name
    #param8  _ granularity ('sys' / 'doc' /'seg')

    my $config = shift;
    my $hOQ = shift;
    my $hM = shift;
    my $ldocids = shift;
    my $metric = shift;
    my $system = shift;
    my $ref = shift;
    my $G = shift;
    
    my $sysid = $config->{IDX}->{$system}->[1]->[2]; 
    if ($G eq $Common::G_SYS) { # system-level correlation
       $hM->{$metric}->{$sysid} = $hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref};
    }
    elsif ($G eq $Common::G_DOC) { # document-level correlation
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_DOC}}); $i++) {
          my $docid = $ldocids->[$i];
          $hM->{$metric}->{$sysid.$Common::ID_SEPARATOR.$docid} = $hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref};
       }
    }
    elsif ($G eq $Common::G_SEG) { # segment-level correlation
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_SEG}}); $i++) {
          #$hM->{$metric}->{"$system:".($i+1)} = $hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref};
          my $docid = $config->{IDX}->{$system}->[$i + 1]->[0];
          my $segid = $config->{IDX}->{$system}->[$i + 1]->[3];
          $hM->{$metric}->{$sysid.$Common::ID_SEPARATOR.$docid.$Common::ID_SEPARATOR.$segid} = $hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref};
       }
    }
    else { die "[ERROR] unknown granularity <", $G, $Common::G_SEG, ">\n"; }
}

sub build_rankings {
    #description _ reads necessary metric scores and builds the corresponding rankings for computing correlation coefficients
	 #param1  _ configuration
    #param2  _ prepared metric scores (hash ref)
    #param3  _ metric name
    #param4  _ granularity ('sys' / 'doc' /'seg')

    my $config = shift;
    my $hM = shift;
    my $metric = shift;
    my $G = shift;

    if (!exists($hM->{$metric})) {	 
       my $REF = join("_", sort @{$config->{references}});
       foreach my $system (sort @{$config->{systems}}) {
          my %OQ;
          if ($metric eq $ULC::ULC_NAME) { # ULC
             ULC::compute_normalized_ULC($config, \%OQ, [$system], $config->{references}, $config->{COMBO}, $G);
          }
          elsif ($metric eq $QARLA::QUEEN_NAME) { # QUEEN
             QARLA::QUEEN($config, \%OQ, [$system], $config->{references}, $config->{COMBO}, $G);
          }
          else { # INDIVIDUAL METRICS
             IQXML::read_report($system, $REF, $metric, \%OQ, $config->{segments}, $G, $config->{verbose});          
          }
          my $ldocids;
          if ($G eq $Common::G_DOC) { $ldocids = NISTXML::get_docid_list($config->{IDX}->{$system}); } 
          build_metric_ranking($config, \%OQ, $hM, $ldocids, $metric, $system, $REF, $G);      	
       }
    }
}

sub retrieve_matching_pairs {
    #description _ build x/y value lists from rankings (only matching items are considered)
    #param1  _ ranking x (hash ref)
    #param2  _ ranking y (hash ref)
	
    my $ranking1 = shift;
    my $ranking2 = shift;

	 #print "ranking 1\n";    
    #print Dumper $ranking1;
    #print "ranking 2\n";
    #print Dumper $ranking2;
    
    my @xvalues;
    my @yvalues;   
    foreach my $id (keys %{$ranking2}) {
       if (exists $ranking1->{$id}) {
          push(@xvalues, $ranking1->{$id});
          push(@yvalues, $ranking2->{$id});
       }
    }  

    #print Dumper \@xvalues;
    #print Dumper \@yvalues;
	
    return (\@xvalues, \@yvalues);
}


sub retrieve_matching_triplets {
    #description _ build x/y/z value lists from rankings (only matching items are considered)
    #param1  _ ranking x (hash ref)
    #param2  _ ranking y (hash ref)
    #param3  _ ranking z (hash ref)
	
    my $ranking1 = shift;
    my $ranking2 = shift;
    my $ranking3 = shift;

    #print Dumper $ranking1;
    #print Dumper $ranking2;
    #print Dumper $ranking3;
    
    my @xvalues;
    my @yvalues;   
    my @zvalues;   
    foreach my $id (keys %{$ranking3}) {
       if ((exists $ranking1->{$id}) and (exists $ranking2->{$id})) {
          push(@xvalues, $ranking1->{$id});
          push(@yvalues, $ranking2->{$id});
          push(@zvalues, $ranking3->{$id});
       }
    }  

    #print Dumper \@xvalues;
    #print Dumper \@yvalues;
    #print Dumper \@zvalues;
	
    return (\@xvalues, \@yvalues, \@zvalues);
}
       
sub do_metric_correlation_Plain($$$$$$) {
    #description _ Computes correlation coefficient + Fisher confidence interval
    #param1  _ configuration
    #param2  _ correlation type ('pearson' / 'spearman' / 'kendall' / 'mrankendall')
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ granularity ('sys' / 'doc' /'seg')
    #param6  _ metric rankings (hash ref)

    my $config = shift;
    my $Ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $G = shift;
    my $rM = shift;

    build_rankings($config, $rM, $metric, $G);            
    my ($Mvalues, $Gvalues) = retrieve_matching_pairs($rM->{$metric}, $assessments);
	 my @result = (Statistics::compute_correlation($Ctype, $Mvalues, $Gvalues, 0));
    return \@result;
}       

sub get_Fisher_correlation_confidence_interval {
    #description _ estimate confidence interval for a given correlation coefficient
    #              Fieller, E.C. et al (1957) Tests for rank correlation coefficients :I. Biometrika 44, 470–481
    #param1  _ x values
    #param2  _ y values
    #param3  _ correlation type
    #param4  _ alfa --> 1 - alfa = statistical significance ([0..1])
    #@return _ (mean, low_threshold, high_threshold)
    
    my $xvalues = shift;
    my $yvalues = shift;
    my $Ctype = shift;
    my $alfa = shift;
    
    my $N = scalar(@{$xvalues});
    my $R = Statistics::compute_correlation($Ctype, $xvalues, $yvalues, 0);

    my ($r1, $r2) = Statistics::get_Fisher_confidence_interval($R, $N, $alfa);
    
    return ($R, $r1, $r2);
}
       
sub do_metric_correlation_Fisher($$$$$$) {
    #description _ Computes correlation coefficient + Fisher confidence interval
    #param1  _ configuration
    #param2  _ correlation type ('pearson' / 'spearman' / 'kendall' / 'mrankendall' )
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ granularity ('sys' / 'doc' /'seg')
    #param6  _ metric rankings (hash ref)

    my $config = shift;
    my $Ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $G = shift;
    my $rM = shift;

    build_rankings($config, $rM, $metric, $G);            
    my ($Mvalues, $Gvalues) = retrieve_matching_pairs($rM->{$metric}, $assessments);
	 my @result = get_Fisher_correlation_confidence_interval($Mvalues, $Gvalues, $Ctype, $config->{alfa});
    return \@result;
}       

# ========= BOOTSTRAP RESAMPLING =========================================================

sub get_bootstrap_xy_sample {
    #description _ retrieve bootstrap (x, y) sample
    #param1  _ sample indices
    #param2  _ x values
    #param3  _ y values

    my $sample = shift;
    my $xvalues = shift;
    my $yvalues = shift;

    my @x; my @y;
    foreach my $id (@{$sample}) {
       push(@x, $xvalues->{$id});
       push(@y, $yvalues->{$id});
    }

    return (\@x, \@y);
}

sub get_bootstrap_correlation_confidence_interval {
    #description _ estimate confidence interval for a given correlation coefficient via bootstrap resampling
    #              Philipp Koehn. Statistical Significance Tests for Machine Translation Evaluation. (EMNLP'04).
    #param1  _ x values
    #param2  _ y values
    #param3  _ correlation type
    #param4  _ samples (list ref)
    #param5  _ alfa --> 1 - alfa = statistical significance ([0..1])
    #@return _ (mean, low_threshold, high_threshold)
	
    my $xvalues = shift;
    my $yvalues = shift;
    my $Ctype = shift;
    my $samples = shift;
    my $alfa = shift;
    
    my @lR;
    foreach my $sample (@{$samples}) {
       my ($x_i, $y_i) = get_bootstrap_xy_sample($sample, $xvalues, $yvalues);
       my $R = Statistics::compute_correlation($Ctype, $x_i, $y_i, 0);
       if (defined($R)) { push(@lR, $R); }
    }
    
    #my ($mean, $d) = get_t_confidence_interval(\@lR, $alfa);
    #my $r1 = $mean - $d; my $r2 = $mean + $d;

    my ($mean, $r1, $r2) = Statistics::get_percentile_confidence_interval(\@lR, $alfa);
  
    return ($mean, $r1, $r2);
}

sub do_metric_correlation_bootstrap($$$$$$$) {
    #description _ Computes correlation coefficient (+ confidence interval via bootstrap resampling)
    #param1  _ configuration
    #param2  _ correlation type ('pearson' / 'spearman' / 'kendall' / 'mrankendall')
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ bootstrap samples (by resampling)
    #param6  _ granularity ('sys' / 'doc' /'seg')
    #param7  _ metric rankings (hash ref)

    my $config = shift;
    my $Ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $bootstrap_samples = shift;
    my $G = shift;
    my $rM = shift;
    
    build_rankings($config, $rM, $metric, $G);            
    my ($Mvalues, $Gvalues) = retrieve_matching_pairs($rM->{$metric}, $assessments);
	 #my @result = Statistics::get_bootstrap_correlation_confidence_interval($Mvalues, $Gvalues, $Ctype, $bootstrap_samples, $config->{alfa});
	 my @result = get_bootstrap_correlation_confidence_interval($rM->{$metric}, $assessments, $Ctype, $bootstrap_samples, $config->{alfa});
    return \@result;
}       

sub get_bootstrap_sample {
    #description _ retrieve a new bootstrap (x, y) sample according to the given permutation
    #param1  _ x values
    #param2  _ y values
    #param3  _ permutation 

    my $xvalues = shift;
    my $yvalues = shift;
    my $permutation = shift;

    my @x; my @y;
    for (my $i = 0; $i < scalar(@{$permutation}); $i++) {
       my $r = $permutation->[$i];
       push(@x, $xvalues->[$r]);
       push(@y, $yvalues->[$r]);
    }    

    return (\@x, \@y);
}
sub do_exhaustive_correlation_bootstrap {
    #description _ exhaustive bootstrap resampling over correlations, recursive function (watch! n^n resamplings are done!)
    #param1  _ x values
    #param2  _ y values
    #param3  _ correlation type
    #param4  _ permutation (input)
    #param5  _ recursion index (input)
    #param6  _ result list (input/output)

    my $xvalues = shift;
    my $yvalues = shift;
    my $Ctype = shift;
    my $permutation = shift;
    my $i = shift;
    my $lR = shift;

    my ($x_i, $y_i) = get_bootstrap_sample($xvalues, $yvalues, $permutation);

    my $R = Statistics::compute_correlation($Ctype, $x_i, $y_i, 0);
    if (defined($R)) { push(@{$lR}, $R); }

    for (my $j = $i; $j < scalar(@{$permutation}); $j++) {
       if ($permutation->[$j] < (scalar(@{$permutation}) - 1)) {
	      my @permutation_j = @{$permutation};
          $permutation_j[$j]++;
          do_exhaustive_correlation_bootstrap($xvalues, $yvalues, $Ctype, \@permutation_j, $j, $lR);
       }
    }
}

sub get_exhaustive_bootstrap_correlation_confidence_interval {
    #description _ estimate confidence interval for a given correlation coefficient via bootstrap resampling
    #              Philipp Koehn. Statistical Significance Tests for Machine Translation Evaluation. (EMNLP'04).
    #param1  _ x values
    #param2  _ y values
    #param3  _ correlation type
    #param4  _ alfa --> 1 - alfa = statistical significance ([0..1])
    #@return _ (mean, low_threshold, high_threshold)
    
    my $xvalues = shift;
    my $yvalues = shift;
    my $Ctype = shift;
    my $alfa = shift;

    my @lR;
    my @permutation;
    for (my $i = 0; $i < scalar(@{$xvalues}); $i++) { push(@permutation, 0); }
 
    do_exhaustive_correlation_bootstrap($xvalues, $yvalues, $Ctype, \@permutation, 0, \@lR);

    #my ($mean, $d) = get_t_confidence_interval(\@lR, $alfa);
    #my $r1 = $mean - $d; my $r2 = $mean + $d;

    my ($mean, $r1, $r2) = Statistics::get_percentile_confidence_interval(\@lR, $alfa);
  
    return ($mean, $r1, $r2);
}

sub do_metric_correlation_exhaustive_bootstrap($$$$$$) {
    #description _ Computes correlation coefficient (+ confidence interval via exhaustive bootstrap resampling)
    #param1  _ configuration
    #param2  _ correlation type ('pearson' / 'spearman' / 'kendall' / 'mrankendall')
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ granularity ('sys' / 'doc' /'seg')
    #param6  _ metric rankings (hash ref)

    my $config = shift;
    my $Ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $G = shift;
    my $rM = shift;

    build_rankings($config, $rM, $metric, $G);            
    my ($Mvalues, $Gvalues) = retrieve_matching_pairs($rM->{$metric}, $assessments);
	 my @result = get_exhaustive_bootstrap_correlation_confidence_interval($Mvalues, $Gvalues, $Ctype, $config->{alfa});
    return \@result;
}       

sub get_bootstrap_xyz_sample {
    #description _ retrieve bootstrap (x, y, z) sample
    #param1  _ sample indices
    #param2  _ x values
    #param3  _ y values
    #param4  _ z values

    my $sample = shift;
    my $xvalues = shift;
    my $yvalues = shift;
    my $zvalues = shift;

    my @x; my @y; my @z;
    foreach my $id (@{$sample}) {
       push(@x, $xvalues->{$id});
       push(@y, $yvalues->{$id});
       push(@z, $zvalues->{$id});
    }

    return (\@x, \@y, \@z);
}

sub do_paired_bootstrap_correlation_test {
    #description _ Paired bootstrap resampling test, given reference scores and two metric scores
    #              Philipp Koehn. Statistical Significance Tests for Machine Translation Evaluation. (EMNLP'04).
    #param1  _ x values
    #param2  _ y values
    #param3  _ ref values
    #param4  _ correlation type
    #param5  _ bootstrap samples (by resampling)
    #@return _ (count X > Y, overall count)
	
    my $xvalues = shift;
    my $yvalues = shift;
    my $refvalues = shift;
    my $Ctype = shift;
    my $bootstrap_samples = shift;

    my $count = 0;
    my $count_x_gt_y = 0;

    foreach my $sample (@{$bootstrap_samples}) {
       my ($x_i, $y_i, $ref_i) = get_bootstrap_xyz_sample($sample, $xvalues, $yvalues, $refvalues);
       #my ($x_i, $y_i, $ref_i) = get_random_paired_bootstrap_sample($xvalues, $yvalues, $refvalues);
       my $Rx = Statistics::compute_correlation($Ctype, $x_i, $ref_i, 0);
       my $Ry = Statistics::compute_correlation($Ctype, $y_i, $ref_i, 0);
       if (defined($Rx) and defined($Ry)) {
       	  if ($Rx > $Ry) { $count_x_gt_y++; }
       	  $count++;
       }
    }

    return ($count_x_gt_y, $count);
}

sub do_metric_correlation_paired_bootstrap($$$$$$$$$) {
    #description _ Computes correlation coefficient (+ confidence interval via paired bootstrap resampling)
    #param1  _ configuration
    #param2  _ correlation type ('pearson' / 'spearman' / 'kendall' / 'mrankendall')
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ bootstrap samples (by resampling)
    #param6  _ granularity ('sys' / 'doc' /'seg')
    #param7  _ evaluation schemes (hash ref)
    #param8  _ already visited metrics (hash ref)
    #param9  _ metric rankings (hash ref)

    my $config = shift;
    my $Ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $bootstrap_samples = shift;
    my $G = shift;
    my $schemes = shift;
    my $already = shift;
    my $rM = shift;
	
    my %result;
    build_rankings($config, $rM, $metric, $G);
    
    my @metrics;
    if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
    if (exists($schemes->{$Common::S_ULC})) { push(@metrics, $ULC::ULC_NAME); }
    if (exists($schemes->{$Common::S_QUEEN})) { push(@metrics, $QARLA::QUEEN_NAME); }
    
    foreach my $m (@metrics) {
       my $p;
   	   if (($metric ne $m) and (!exists($already->{$m}))){
          build_rankings($config, $rM, $m, $G);
          my ($Nx, $N) = do_paired_bootstrap_correlation_test($rM->{$metric}, $rM->{$m}, $assessments, $Ctype, $bootstrap_samples);
          $p = Common::trunk_number($Nx / $N, $Common::METRIC_NAME_LENGTH, $config->{float_precision});
          $result{$m} = $p;
   	   }
    }
	
    return \%result; 
}

sub get_paired_bootstrap_sample {
    #description _ retrieve a new paired bootstrap (x, y, z) sample according to the given permutation
    #param1  _ x values
    #param2  _ y values
    #param3  _ y values
    #param4  _ permutation 

    my $xvalues = shift;
    my $yvalues = shift;
    my $zvalues = shift;
    my $permutation = shift;

    my @x; my @y; my @z;
    for (my $i = 0; $i < scalar(@{$permutation}); $i++) {
       my $r = $permutation->[$i];
       push(@x, $xvalues->[$r]);
       push(@y, $yvalues->[$r]);
       push(@z, $zvalues->[$r]);
    }    

    return (\@x, \@y, \@z);
}

sub do_exhaustive_correlation_paired_bootstrap {
    #description _ exhaustive paired_bootstrap resampling over correlations, recursive function (watch! n^n resamplings are done!)
    #param1  _ x values
    #param2  _ y values
    #param3  _ reference values
    #param4  _ correlation type
    #param5  _ permutation (input)
    #param6  _ recursion index (input)

    my $xvalues = shift;
    my $yvalues = shift;
    my $refvalues = shift;
    my $Ctype = shift;
    my $permutation = shift;
    my $i = shift;

    my $count = 0;
    my $count_x_gt_y = 0;
    my ($x_i, $y_i, $ref_i) = get_paired_bootstrap_sample($xvalues, $yvalues, $refvalues, $permutation);
    my $Rx = Statistics::compute_correlation($Ctype, $x_i, $ref_i, 0);
    my $Ry = Statistics::compute_correlation($Ctype, $y_i, $ref_i, 0);
    if (defined($Rx) and defined($Ry)) {
       if ($Rx > $Ry) { $count_x_gt_y++; }
       $count++;
    }

    for (my $j = $i; $j < scalar(@{$permutation}); $j++) {
       if ($permutation->[$j] < (scalar(@{$permutation}) - 1)) {
	      my @permutation_j = @{$permutation};
          $permutation_j[$j]++;
          my ($count_x_gt_y_i, $count_i) = do_exhaustive_correlation_paired_bootstrap($xvalues, $yvalues, $refvalues,
                                                                                      $Ctype, \@permutation_j, $j);
          $count_x_gt_y += $count_x_gt_y_i;
          $count += $count_i;
       }
    }

    return ($count_x_gt_y, $count);
}

sub do_exhaustive_paired_bootstrap_correlation_test {
    #description _ Exhaustive paired bootstrap resampling test, given reference scores and two metric scores
    #              Philipp Koehn. Statistical Significance Tests for Machine Translation Evaluation. (EMNLP'04).
    #param1  _ x values
    #param2  _ y values
    #param3  _ ref values
    #param4  _ correlation type
    #@return _ (count X > Y, overall count)
	
    my $xvalues = shift;
    my $yvalues = shift;
    my $refvalues = shift;
    my $Ctype = shift;

    my @permutation;
    for (my $i = 0; $i < scalar(@{$xvalues}); $i++) { push(@permutation, 0); }

    my ($count_x_gt_y, $count) = do_exhaustive_correlation_paired_bootstrap($xvalues, $yvalues, $refvalues,
                                                                            $Ctype, \@permutation, 0);

    return ($count_x_gt_y, $count);
}

sub do_metric_correlation_exhaustive_paired_bootstrap($$$$$$$$) {
    #description _ Computes correlation coefficient (+ confidence interval via exhaustive paired bootstrap resampling)
    #param1  _ configuration
    #param2  _ correlation type ('pearson' / 'spearman' / 'kendall' / 'mrankendall' )
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ granularity ('sys' / 'doc' /'seg')
    #param6  _ evaluation schemes (hash ref)
    #param7  _ already visited metrics (hash ref)
    #param8  _ metric rankings (hash ref)

    my $config = shift;
    my $Ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $G = shift;
    my $schemes = shift;
    my $already = shift;
    my $rM = shift;

    my %result;
    build_rankings($config, $rM, $metric, $G);

    my @metrics;
    if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
    if (exists($schemes->{$Common::S_ULC})) { push(@metrics, $ULC::ULC_NAME); }
    if (exists($schemes->{$Common::S_QUEEN})) { push(@metrics, $QARLA::QUEEN_NAME); }

    foreach my $m (@metrics) {
       my $p;
   	   if (($metric ne $m) and (!exists($already->{$m}))){
          build_rankings($config, $rM, $m, $G);
          my ($Mvalues, $mvalues, $Gvalues) = retrieve_matching_triplets($rM->{$metric}, $rM->{$m}, $assessments);
          my ($Nx, $N) = do_exhaustive_paired_bootstrap_correlation_test($Mvalues, $mvalues, $Gvalues, $Ctype);
          $p = Common::trunk_number($Nx / $N, $Common::METRIC_NAME_LENGTH, $config->{float_precision});
          $result{$m} = $p;
   	   }
    }
	
    return \%result; 
}

sub do_metric_correlation($$$$$$$$$$) {
    #description _ compute correlation coefficients for a given metric
    #              (with a provided score list, usually human assessments of some type)
    #param1  _ configuration
    #param2  _ correlation type ('pearson' / 'spearman' / 'kendall' / 'mrankendall' )
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ granularity ('sys' / 'doc' /'seg')
    #param6  _ evaluation schemes (hash ref)
    #param7  _ confidence interval method
    #param8  _ bootstrap samples (by resampling)
    #param9  _ already visited metrics (hash ref)
    #param10 _ metric rankings (hash ref)

    my $config = shift;
    my $Ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $G = shift;
    my $schemes = shift;
    my $ci_method = shift;
    my $bootstrap_samples = shift;
    my $already = shift;
    my $rM = shift;
        
	 #print "evaluation schemes\n";
	 #print Dumper $schemes;
        
    my $result;
    if ($ci_method eq $Common::CI_NONE) {
       $result = do_metric_correlation_Plain($config, $Ctype, $metric, $assessments, $G, $rM);
    }
    elsif ($ci_method eq $Common::CI_FISHER) {
       $result = do_metric_correlation_Fisher($config, $Ctype, $metric, $assessments, $G, $rM);
    }
    elsif ($ci_method eq $Common::CI_BOOTSTRAP) {
       $result = do_metric_correlation_bootstrap($config, $Ctype, $metric, $assessments, $bootstrap_samples, $G, $rM);
    }
    elsif ($ci_method eq $Common::CI_EXHAUSTIVE_BOOTSTRAP) {
       $result = do_metric_correlation_exhaustive_bootstrap($config, $Ctype, $metric, $assessments, $G, $rM);
    }
    elsif ($ci_method eq $Common::CI_PAIRED_BOOTSTRAP) {
       $result = do_metric_correlation_paired_bootstrap($config, $Ctype, $metric, $assessments, $bootstrap_samples, $G, $schemes, $already, $rM);
    }
    elsif ($ci_method eq $Common::CI_EXHAUSTIVE_PAIRED_BOOTSTRAP) {
       $result = do_metric_correlation_exhaustive_paired_bootstrap($config, $Ctype, $metric, $assessments, $G, $schemes, $already, $rM);
    }
    else { die "[ERROR] unknown confidence inteval method <", $ci_method, "!\n"; }
    
    return $result;
}

sub build_bootstrap_samples_by_resampling($$) {
	#description _ builds a set of samples by resampling with replacement
	#param1  _ original sample (hash ref)
	#param2  _ number of resamplings
	
	my $sample = shift;
	my $n_resamplings = shift;
	 
	srand();
	my @resamplings;
    my $max = scalar(keys %{$sample});
    my @sorted_sample_keys = sort keys %{$sample};
     
    for (my $i = 0; $i < $n_resamplings; $i++) {
       $resamplings[$i] = [];
       for (my $j = 0; $j < $max; $j++) {
          my $r = int(rand($max));
          push(@{$resamplings[$i]}, $sorted_sample_keys[$r]);
       }
    }

    return \@resamplings;	
}

sub do_CORRELATION($$$$$$) {
    #description _ compute correlation according to the given configuration
    #param1  _ configuration
    #param2  _ correlation type ('pearson' / 'spearman' / 'kendall' )
    #param3  _ granularity ('sys' / 'doc' /'seg')
    #param4  _ evaluation schemes (hash ref)
    #param5  _ confidence interval method
    #param6  _ verbostiy

    my $config = shift;
    my $Ctype = shift;
    my $G = shift;
    my $schemes = shift;
    my $ci_method = shift;
    my $verbose = shift;

    my $assessments = Assessments::select($config, $G);

	 #print "do CORRELATION assessments for $G";
	 #print Dumper $assessments;
	 
    if ($verbose) {
       print STDERR "[CORRELATION]\n";
       my $n_data_points = scalar(keys %{$assessments});
       print STDERR "  - granularity: $G (data points = ", $n_data_points, ")\n";
       print STDERR "  - type: $Ctype\n";
       print STDERR "  - confidence interval method: ", $ci_method, "\n";
       print STDERR "  - statistical significance: ", (1 - $config->{alfa}) * 100, "%\n";
       if (($ci_method eq $Common::CI_BOOTSTRAP) or ($ci_method eq $Common::CI_PAIRED_BOOTSTRAP)) {
       	  print STDERR "  - number of resamplings: ", $config->{n_resamplings}, "\n";
       }
       elsif (($ci_method eq $Common::CI_EXHAUSTIVE_BOOTSTRAP) or ($ci_method eq $Common::CI_EXHAUSTIVE_PAIRED_BOOTSTRAP)) {
          my $n = $n_data_points ** $n_data_points;
          print STDERR "  - number of resamplings: ", $n, "\n";
          if ($n eq "inf") { die "[ERROR] To the infinity and beyond! Come on...\n"; }
       	  elsif ($n > $Common::SENSIBLE_MAX_N) { print STDERR "[WARNING] This execution may take too long! Consider aborting.\n"; }
       }
    }

    my %hR;
    my @metrics;
    if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
    if (exists($schemes->{$Common::S_ULC})) { push(@metrics, $ULC::ULC_NAME); }
    if (exists($schemes->{$Common::S_QUEEN})) { push(@metrics, $QARLA::QUEEN_NAME); }
    
    my @sorted_metrics;
    if ($config->{SORT} eq $Common::SORT_NAME) { @sorted_metrics = sort @metrics; }
    else { @sorted_metrics = @metrics; }

    if ($verbose) { print STDERR "Computing correlation coefficients."; }
    
    my $bootstrap_samples;
    if (($ci_method eq $Common::CI_BOOTSTRAP) or ($ci_method eq $Common::CI_PAIRED_BOOTSTRAP)) {
	   $bootstrap_samples = build_bootstrap_samples_by_resampling($assessments, $config->{n_resamplings});
	}
	
    my %rM;    
    my %already;
    foreach my $m (@sorted_metrics) {
       if ($verbose) { print STDERR "..$m"; }       
       $hR{$m} = do_metric_correlation($config, $Ctype, $m, $assessments, $G, $schemes, $ci_method, $bootstrap_samples, \%already, \%rM);
       $already{$m} = 1; 
    }
    if ($verbose) { print STDERR "\n"; }       
        
    return \%hR;
}

# *************************************************************************************
# ******* MULTIRANKS ******************************************************************
# *************************************************************************************

sub build_system_metric_ranking {
    #description _ prepare metric scores for computing consistency
	 #param1  _ configuration
    #param2  _ hash of metric scores
    #param3  _ prepared metric scores (hash ref)
    #param4  _ list of document ids
    #param5  _ metric name
    #param6  _ system name
    #param7  _ reference name
    #param8  _ granularity ('sys' / 'doc' /'seg')

    my $config = shift;
    my $hOQ = shift;
    my $hM = shift;
    my $ldocids = shift;
    my $metric = shift;
    my $system = shift;
    my $ref = shift;
    my $G = shift;
    
    my $sysid = $config->{IDX}->{$system}->[1]->[2]; 
    if ($G eq $Common::G_SYS) { # system-level correlation
       $hM->{$metric}->{$Common::G_SYS}->{$sysid} = $hOQ->{$Common::G_SYS}->{$metric}->{$system}->{$ref};
    }
    elsif ($G eq $Common::G_DOC) { # document-level correlation
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_DOC}}); $i++) {
          my $docid = $ldocids->[$i];
          $hM->{$metric}->{$docid}->{$sysid} = $hOQ->{$Common::G_DOC}->[$i]->{$metric}->{$system}->{$ref};
       }
    }
    elsif ($G eq $Common::G_SEG) { # segment-level correlation
       for (my $i = 0; $i < scalar(@{$hOQ->{$Common::G_SEG}}); $i++) {
          #$hM->{$metric}->{"$system:".($i+1)} = $hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref};
          my $docid = $config->{IDX}->{$system}->[$i + 1]->[0];
          my $segid = $config->{IDX}->{$system}->[$i + 1]->[3];
          $hM->{$metric}->{$docid.$Common::ID_SEPARATOR.$segid}->{$sysid} = $hOQ->{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref};
       }
    }
    else { die "[ERROR] unknown granularity <", $G, $Common::G_SEG, ">\n"; }
}

sub build_system_rankings {
    #description _ reads necessary metric scores and builds the corresponding rankings for computing consistency
	 #param1  _ configuration
    #param2  _ prepared metric scores (hash ref)
    #param3  _ metric name
    #param4  _ granularity ('sys' / 'doc' /'seg')

    my $config = shift;
    my $hM = shift;
    my $metric = shift;
    my $G = shift;

    my $REF = join("_", sort @{$config->{references}});
    foreach my $system (sort @{$config->{systems}}) {
       my %OQ;
       if ($metric eq $ULC::ULC_NAME) { # ULC
          ULC::compute_normalized_ULC($config, \%OQ, [$system], $config->{references}, $config->{COMBO}, $G);
       }
       elsif ($metric eq $QARLA::QUEEN_NAME) { # QUEEN
          QARLA::QUEEN($config, \%OQ, [$system], $config->{references}, $config->{COMBO}, $G);
       }
       else { # INDIVIDUAL METRICS
          IQXML::read_report($system, $REF, $metric, \%OQ, $config->{segments}, $G, $config->{verbose});          
       }
       my $ldocids;
       if ($G eq $Common::G_DOC) { $ldocids = NISTXML::get_docid_list($config->{IDX}->{$system}); } 
       build_system_metric_ranking($config, \%OQ, $hM, $ldocids, $metric, $system, $REF, $G);      	
    }
}

sub do_metric_multiranks_Plain($$$$$) {
    #description _ Computes consistency (no statistical significance test)
    #param1  _ configuration
    #param2  _ correlation type
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ granularity ('sys' / 'doc' /'seg')

    my $config = shift;
    my $ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $G = shift;

    my %rM;
    
    build_system_rankings($config, \%rM, $metric, $G);                    
    my @result = (Consistency::compute_multiranks($ctype, $rM{$metric}, $assessments));
	 return \@result;
}       

sub do_metric_multiranks($$$$$$$) {
    #description _ compute correlation coefficients for a given metric
    #              (with a provided score list, usually human assessments of some type)
    #param1  _ configuration
    #param2  _ correlation type (consistency, kendalls tau)
    #param3  _ metric name
    #param4  _ assessments (hash ref)
    #param5  _ granularity ('sys' / 'doc' /'seg')
    #param6  _ evaluation schemes (hash ref)
    #param7  _ already visited metrics (hash ref)

    my $config = shift;
    my $ctype = shift;
    my $metric = shift;
    my $assessments = shift;
    my $G = shift;
    my $schemes = shift;
    my $already = shift;
    
    my $result;
    
   
    #if (($config->{ci} eq "") or ($config->{ci} eq $Common::CI_FISHER)) {
       $result = do_metric_multiranks_Plain($config, $ctype, $metric, $assessments, $G);
    #}
#    elsif ($config->{ci} eq $Common::CI_BOOTSTRAP) {
#       $result = do_metric_consistency_bootstrap($config, $metric, $assessments, $G);
#    }
#    elsif ($config->{ci} eq $Common::CI_EXHAUSTIVE_BOOTSTRAP) {
#       $result = do_metric_consistency_exhaustive_bootstrap($config, $metric, $assessments, $G);
#    }
#    elsif ($config->{ci} eq $Common::CI_PAIRED_BOOTSTRAP) {
#       $result = do_metric_consistency_paired_bootstrap($config, $metric, $assessments, $G, $schemes, $already);
#    }
#    elsif ($config->{ci} eq $Common::CI_EXHAUSTIVE_PAIRED_BOOTSTRAP) {
#       $result = do_metric_consistency_exhaustive_paired_bootstrap($config, $Ctype, $metric, $assessments, $G, $schemes, $already);
#    }
#    else { die "[ERROR] unknown confidence inteval method <", $config->{ci}, "!\n"; }
    
    return $result;
}

sub do_MULTIRANKS($$$$$) {
    #description _ compute consistency probabilities for the specified metrics
    #param1  _ configuration
    #param2  _ correlation type ( 'consistency' , 'kendall's tau' ) 
    #param3  _ granularity ('sys' / 'doc' /'seg')
    #param4  _ evaluation schemes (hash ref)
    #param5  _ verbostiy

    my $config = shift;
    my $ctype = shift;
    my $G = shift;
    my $schemes = shift;
    my $verbose = shift;

    if (!exists($config->{avgassessments})) { die "[ERROR] assessments file not defined!!\n"; }

    my $assessments = Assessments::multirank_select($config, $G);
	
    if ($verbose) {
       print STDERR "[MULTIRANKS]\n";
       my $n_data_points = scalar(keys %{$assessments});
       print STDERR "  - granularity: $G (data points = ", $n_data_points, ")\n";
		 print STDERR "  - type: $ctype\n";
       print STDERR "  - confidence interval method: ", $config->{ci}, "\n";
       print STDERR "  - statistical significance: ", (1 - $config->{alfa}) * 100, "%\n";
       if ($config->{ci} eq $Common::CI_BOOTSTRAP) {
       	  print STDERR "  - number of resamplings: ", $config->{n_resamplings}, "\n";
       }
       elsif ($config->{ci} eq $Common::CI_EXHAUSTIVE_BOOTSTRAP) {
          my $n = $n_data_points ** $n_data_points;
          print STDERR "  - number of resamplings: ", $n, "\n";
          if ($n eq "inf") { die "[ERROR] To the infinity and beyond! Come on...\n"; }
       	  elsif ($n > $Common::SENSIBLE_MAX_N) { print STDERR "[WARNING] This execution may take too long! Consider aborting.\n"; }
       }
    }

    my %hR;
    my @metrics;
    if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
    if (exists($schemes->{$Common::S_ULC})) { push(@metrics, $ULC::ULC_NAME); }
    if (exists($schemes->{$Common::S_QUEEN})) { push(@metrics, $QARLA::QUEEN_NAME); }
    
    my @sorted_metrics;
    if ($config->{SORT} eq $Common::SORT_NAME) { @sorted_metrics = sort @metrics; }
    else { @sorted_metrics = @metrics; }

    if ($verbose) { print STDERR "Computing consistency probabilities."; }
    
    my %already;    
    foreach my $m (@sorted_metrics) {
       if ($verbose) { print STDERR "..$m"; }       
       $hR{$m} = do_metric_multiranks($config, $ctype, $m, $assessments, $G, $schemes, \%already);
       $already{$m} = 1; 
    }
    if ($verbose) { print STDERR "\n"; }       

    return \%hR;
}


# *************************************************************************************
# ******* KING and ORANGE *************************************************************
# *************************************************************************************

sub do_metric_KING($$$) {
    #description _ compute KING probabilities for a given metric
    #param1  _ configuration
    #param2  _ metric name
    #param3  _ granularity ('sys' / 'doc' /'seg')
    
    my $config = shift;
    my $metric = shift;
    my $G = shift;

    my $doALL = (scalar(keys %{$config->{segments}}) == 0);  # if no segments are specified, print all
    
    my $count = 0; my $hits = 0;    
    foreach my $ref (@{$config->{references}}) {
       my @all_other_refs;
       foreach my $r (@{$config->{references}}) { if ($r ne $ref) { push(@all_other_refs, $r); } }
       if (scalar(@all_other_refs)) { 
          my %OQ;
          if ($metric eq $ULC::ULC_NAME) { # ULC
             ULC::compute_normalized_ULC($config, \%OQ, [$ref], \@all_other_refs, $config->{metrics}, $G);
             foreach my $sys (@{$config->{systems}}) {
                ULC::compute_normalized_ULC($config, \%OQ, [$sys], \@all_other_refs, $config->{metrics}, $G);
             }
          }
          elsif ($metric eq $QARLA::QUEEN_NAME) { # QUEEN
             QARLA::QUEEN($config, \%OQ, [$ref], \@all_other_refs, $config->{metrics}, $G);
             foreach my $sys (@{$config->{systems}}) {
                QARLA::QUEEN($config, \%OQ, [$sys], \@all_other_refs, $config->{metrics}, $G);
             }
          }
          else { # INDIVIDUAL METRICS
             Scores::load(\%OQ, [$metric], $config->{segments}, $config->{systems}, \@all_other_refs, $G, 0, 1, 0, 0, 0);
             Scores::load(\%OQ, [$metric], $config->{segments}, [$ref], \@all_other_refs, $G, 0, 1, 0, 0, 0);
          }
          my $other_refs = join("_", sort @all_other_refs);
          if (($G eq $Common::G_SEG) or ($G eq $Common::G_DOC)) {
             for (my $i = 0; $i < scalar(@{$OQ{$G}}); $i++) {
                if (exists($config->{segments}->{$i + 1}) or $doALL or ($G eq $Common::G_DOC)) {
                   my $hit = 1;
                   my $ref_quality = $OQ{$G}->[$i]->{$metric}->{$ref}->{$other_refs};
                   foreach my $sys (@{$config->{systems}}) {
             	      my $sys_quality = $OQ{$G}->[$i]->{$metric}->{$sys}->{$other_refs};
                      if ($sys_quality > $ref_quality) { $hit = 0; last; }
                   }
                   $hits += $hit;
          	       $count++;                	
                }
             }
          }
          elsif ($G eq $Common::G_SYS) {
             my $hit = 1;
             my $ref_quality = $OQ{$Common::G_SYS}->{$metric}->{$ref}->{$other_refs};
             foreach my $sys (@{$config->{systems}}) {
             	my $sys_quality = $OQ{$Common::G_SYS}->{$metric}->{$sys}->{$other_refs};
                if ($sys_quality > $ref_quality) { $hit = 0; last; }
             }
             $hits += $hit;
          	 $count++;
          }
          else { die "[ERROR] unknown granularity <", $G, $Common::G_SEG, ">\n"; }
       }       	
    }
        
    return [Common::safe_division($hits, $count), $hits, $count];
}

sub do_KING($$$$) {
    #description _ compute KING probabilities for the specified metrics
    #param1  _ configuration
    #param2  _ granularity ('sys' / 'doc' /'seg')
    #param3  _ evaluation schemes (hash ref)
    #param4  _ verbostiy

    my $config = shift;
    my $G = shift;
    my $schemes = shift;
    my $verbose = shift;

    if (scalar(@{$config->{references}}) < 2) { die "[ERROR] KING computation requires at least two references!!\n"; }
	
    if ($verbose) {
       print STDERR "[KING]\n";
       my $n_data_points = scalar(@{$config->{references}}) * scalar(@{$config->{systems}});
       if ($G eq $Common::G_DOC) { $n_data_points *= NISTXML::get_number_of_documents($config->{IDX}->{"source"}); }
       if ($G eq $Common::G_SEG) { $n_data_points *= NISTXML::get_number_of_segments($config->{IDX}->{"source"}); }
       print STDERR "  - granularity: $G (data points = ", $n_data_points, ")\n";
    }

    my @metrics;
    if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
    if (exists($schemes->{$Common::S_ULC})) { push(@metrics, $ULC::ULC_NAME); }
    if (exists($schemes->{$Common::S_QUEEN})) { push(@metrics, $QARLA::QUEEN_NAME); }
    
    my @sorted_metrics;
    if ($config->{SORT} eq $Common::SORT_NAME) { @sorted_metrics = sort @metrics; }
    else { @sorted_metrics = @metrics; }

    if ($verbose) { print STDERR "Computing KING probabilities."; }

    my %hKING;    
    foreach my $m (@sorted_metrics) {
       if ($verbose) { print STDERR "..$m"; }       
       $hKING{$m} = do_metric_KING($config, $m, $G);
    }
    if ($verbose) { print STDERR "\n"; }       
    
    return \%hKING
}

sub do_metric_ORANGE($$$) {
    #description _ compute ORANGE probabilities for a given metric
    #param1  _ configuration
    #param2  _ metric name
    #param3  _ granularity ('sys' / 'doc' /'seg')
    
    my $config = shift;
    my $metric = shift;
    my $G = shift;

    my $doALL = (scalar(keys %{$config->{segments}}) == 0);  # if no segments are specified, print all
    
    my $count = 0; my $hits = 0;    
    foreach my $ref (@{$config->{references}}) {
       my @all_other_refs;
       foreach my $r (@{$config->{references}}) { if ($r ne $ref) { push(@all_other_refs, $r); } }
       if (scalar(@all_other_refs)) { 
          my %OQ;
          if ($metric eq $ULC::ULC_NAME) { # ULC
             ULC::compute_normalized_ULC($config, \%OQ, [$ref], \@all_other_refs, $config->{metrics}, $G);
             foreach my $sys (@{$config->{systems}}) {
                ULC::compute_normalized_ULC($config, \%OQ, [$sys], \@all_other_refs, $config->{metrics}, $G);
             }
          }
          elsif ($metric eq $QARLA::QUEEN_NAME) { # QUEEN
             QARLA::QUEEN($config, \%OQ, [$ref], \@all_other_refs, $config->{metrics}, $G);
             foreach my $sys (@{$config->{systems}}) {
                QARLA::QUEEN($config, \%OQ, [$sys], \@all_other_refs, $config->{metrics}, $G);
             }
          }
          else { # INDIVIDUAL METRICS
             Scores::load(\%OQ, [$metric], $config->{segments}, $config->{systems}, \@all_other_refs, $G, 0, 1, 0, 0, 0);
             Scores::load(\%OQ, [$metric], $config->{segments}, [$ref], \@all_other_refs, $G, 0, 1, 0, 0, 0);
          }
          my $other_refs = join("_", sort @all_other_refs);
          if (($G eq $Common::G_SEG) or ($G eq $Common::G_DOC)) {
             for (my $i = 0; $i < scalar(@{$OQ{$G}}); $i++) {
                if (exists($config->{segments}->{$i + 1}) or $doALL or ($G eq $Common::G_DOC)) {
                   my $hit = 1;
                   my $ref_quality = $OQ{$G}->[$i]->{$metric}->{$ref}->{$other_refs};
                   foreach my $sys (@{$config->{systems}}) {
             	      my $sys_quality = $OQ{$G}->[$i]->{$metric}->{$sys}->{$other_refs};
                      if ($sys_quality <= $ref_quality) { $hits++; }
                      $count++;
                   }
                }
             }
          }
          elsif ($G eq $Common::G_SYS) {
             my $ref_quality = $OQ{$Common::G_SYS}->{$metric}->{$ref}->{$other_refs};
             foreach my $sys (@{$config->{systems}}) {
             	my $sys_quality = $OQ{$Common::G_SYS}->{$metric}->{$sys}->{$other_refs};
                if ($sys_quality <= $ref_quality) { $hits++; }
                $count++;
             }
          }
          else { die "[ERROR] unknown granularity <", $G, $Common::G_SEG, ">\n"; }
       }       	
    }
        
    return [Common::safe_division($hits, $count), $hits, $count];
}

sub do_ORANGE($$$$) {
    #description _ compute ORANGE probabilities for the specified metrics
    #param1  _ configuration
    #param2  _ granularity ('sys' / 'doc' /'seg')
    #param3  _ evaluation schemes (hash ref)
    #param4  _ verbostiy

    my $config = shift;
    my $G = shift;
    my $schemes = shift;
    my $verbose = shift;

    if (scalar(@{$config->{references}}) < 2) { die "[ERROR] ORANGE computation requires at least two references!!\n"; }
	
    if ($verbose) {
       print STDERR "[ORANGE]\n";
       my $n_data_points = scalar(@{$config->{references}}) * scalar(@{$config->{systems}});
       if ($G eq $Common::G_DOC) { $n_data_points *= NISTXML::get_number_of_documents($config->{IDX}->{"source"}); }
       if ($G eq $Common::G_SEG) { $n_data_points *= NISTXML::get_number_of_segments($config->{IDX}->{"source"}); }
       print STDERR "  - granularity: $G (data points = ", $n_data_points, ")\n";
    }

    my @metrics;
    if (exists($schemes->{$Common::S_SINGLE})) { @metrics = @{$config->{metrics}}; }
    if (exists($schemes->{$Common::S_ULC})) { push(@metrics, $ULC::ULC_NAME); }
    if (exists($schemes->{$Common::S_QUEEN})) { push(@metrics, $QARLA::QUEEN_NAME); }
    
    my @sorted_metrics;
    if ($config->{SORT} eq $Common::SORT_NAME) { @sorted_metrics = sort @metrics; }
    else { @sorted_metrics = @metrics; }

    if ($verbose) { print STDERR "Computing ORANGE probabilities."; }

    my %hORANGE;    
    foreach my $m (@sorted_metrics) {
       if ($verbose) { print STDERR "..$m"; }       
       $hORANGE{$m} = do_metric_ORANGE($config, $m, $G);
    }
    if ($verbose) { print STDERR "\n"; }       
    
    return \%hORANGE
}

# *************************************************************************************
# *************************************************************************************

sub metaprint {
	#description _ prints meta-evaluation scores for the given criterion and config conditions
    #param1  _ configuration
    #param2  _ meta-evaluation criterion ('pearson' / 'spearman' / 'kendall' / 'mrankendall' /'king' / 'orange')
    #param3  _ evaluation schemes (hash ref)
    #param4  _ meta-evaluation scores
    #param5  _ confidence interval method
    #param6  _ sort criterion
	 #param7  _ granularity used
	 
    my $config = shift;
    my $criterion = shift;
    my $schemes = shift;
    my $metascores = shift;
    my $ci_method = shift;
    my $sort = shift;
    my $G = shift;
    
    if (exists($Common::rCORRS->{$criterion}) or (exists($Common::rMRANKS->{$criterion})) ){
       MetaMetrics::print_correlation($config, $metascores, $sort, $criterion, $schemes, $ci_method, $G);
    }
   	elsif ($criterion eq $Common::C_KING) {
       MetaMetrics::print_KING_table($config, $metascores, $sort, $schemes);
    }
   	elsif ($criterion eq $Common::C_ORANGE) {
       MetaMetrics::print_ORANGE_table($config, $metascores, $sort, $schemes);
    }
    else { die "[ERROR] unknown meta-evaluation criterion '$criterion'!!\n"; }
}

sub metaeval($$$$$$) {
	#description _ performs meta-evaluation according to the given criterion and config conditions
    #param1  _ configuration
    #param2  _ meta-evaluation scheme ('pearson' / 'spearman' / 'kendall' / 'mrankendall' /'king' / 'orange')
    #param3  _ granularity ('sys' / 'doc' /'seg')
    #param4  _ evaluation schemes (hash ref)
    #param5  _ confidence interval method
    #param6  _ verbostiy

    my $config = shift;
    my $criterion = shift;
    my $G = shift;
    my $schemes = shift;
    my $ci_method = shift;
    my $verbose = shift;

    my $metascores;
    if (exists($Common::rCORRS->{$criterion})){
       $metascores = MetaMetrics::do_CORRELATION($config, $criterion, $G, $schemes, $ci_method, $verbose);
    }
    elsif ($criterion eq $Common::C_KING) {
       $metascores = MetaMetrics::do_KING($config, $G, $schemes, $verbose);
    }
    elsif ($criterion eq $Common::C_ORANGE) {
       $metascores = MetaMetrics::do_ORANGE($config, $G, $schemes, $verbose);
    }
    elsif (exists($Common::rMRANKS->{$criterion})) {
       $metascores = MetaMetrics::do_MULTIRANKS($config, $criterion, $G, $schemes, $verbose);
    }
    else {
    die "[ERROR] unknown meta-evaluation criterion '$criterion'!!\n"; }

    return $metascores;	
}

# *************************************************************************************
# ******************************* PUBLIC METHODS **************************************
# *************************************************************************************

sub do_metaeval {
	#description _ performs evaluation of evaluation methods according to the given criteria and config conditions
	#param1  _ configuration

    my $config = shift;

    # ============= COMPUTE SCORES (if necessary) =======================================	

    foreach my $criterion (@{$config->{metaeval_criteria_list}}) { #meta-evaluation criteria
       if ($config->{G} eq $Common::G_ALL) {
          my $hMETAsys = MetaMetrics::metaeval($config, $criterion, $Common::G_SYS, $config->{metaeval_schemes}, $config->{ci}, $config->{verbose});
          my $hMETAdoc = MetaMetrics::metaeval($config, $criterion, $Common::G_DOC, $config->{metaeval_schemes}, $config->{ci}, $config->{verbose});
          my $hMETAseg = MetaMetrics::metaeval($config, $criterion, $Common::G_SEG, $config->{metaeval_schemes}, $config->{ci}, $config->{verbose});
          MetaMetrics::metaprint($config, $criterion, $config->{metaeval_schemes}, $hMETAsys, $config->{ci}, $config->{SORT}, $Common::G_SYS);
          MetaMetrics::metaprint($config, $criterion, $config->{metaeval_schemes}, $hMETAdoc, $config->{ci}, $config->{SORT}, $Common::G_DOC);
          MetaMetrics::metaprint($config, $criterion, $config->{metaeval_schemes}, $hMETAseg, $config->{ci}, $config->{SORT}, $Common::G_SEG);
          #TO DO: MetaMetrics::metaprint_sys_doc_seg($hRsys, $hRdoc, $hRseg);
       }
       else {
          my $hMETA = MetaMetrics::metaeval($config, $criterion, $config->{G}, $config->{metaeval_schemes}, $config->{ci}, $config->{verbose});
          MetaMetrics::metaprint($config, $criterion, $config->{metaeval_schemes}, $hMETA, $config->{ci}, $config->{SORT}, $config->{G});
       }
    }
}

1;
