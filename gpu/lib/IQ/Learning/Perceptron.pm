package Perceptron;

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

our($USE_LAST, $USE_AVERAGED, $USE_VOTED);

$Perceptron::USE_LAST = 'last';
$Perceptron::USE_AVERAGED = 'averaged';
$Perceptron::USE_VOTED = 'voted';

sub new {
    #description _ creates a new perceptron
    #param1  _ class name (implicit)
    #param2  _ feature mapping

    my $class = shift;     #implicit parameter
    my $mapping = shift;
        
    my $perceptron = { mapping => $mapping, n_features => scalar(@{$mapping}), n_epochs => 0,
    	               model => [], averaged_model => [], voted_model => [] };

    bless $perceptron, $class;

    return $perceptron;
}

sub initialize_models {
    #description _ initializes models
    #param1  _ object reference (implicit)

    my $perceptron = shift;
    
    $perceptron->{model} = [];
    $perceptron->{averaged_model} = [];
}

sub store_model {
    #description _ adds given weight vector as last in the model
    #param1  _ object reference (implicit)
    #param2  _ weight vector

    my $perceptron = shift;
    my $w = shift;

    my @W = @{$w};
    push(@{$perceptron->{model}}, \@W);
}

sub store_voted_model {
    #description _ adds given weight vector as last in the voted model
    #param1  _ object reference (implicit)
    #param2  _ weight vector
    #param3  _ epoch number
    #param4  _ number of consecutive hits

    my $perceptron = shift;
    my $w = shift;
    my $t = shift;
    my $n = shift;

    my @W = ($n, @{$w});
    push(@{$perceptron->{voted_model}->[$t]}, \@W);
}

sub update_averaged_model {
    #description _ updates averaged model from given weight model after visiting each example
    #param1  _ object reference (implicit)
    #param2  _ current averaged weight model
    #param3  _ current weight model
    #param4  _ number of examples visited since last update

    my $perceptron = shift;
    my $Wavg = shift;
    my $w = shift;
    my $n = shift;
    
    my $i = 0;
    while ($i < scalar(@{$w})) {
       $Wavg->[$i] += $n * $w->[$i];
       $i++;
    }
}

sub normalize_averaged_model {
    #description _ normalizes averaged model by dividing into the total number of examples visited
    #              since last normalization
    #param1  _ object reference (implicit)
    #param2  _ current averaged weight model
    #param3  _ number of examples visited since last normalization

    my $perceptron = shift;
    my $Wavg = shift;
    my $n = shift;
    
    my @W;
    my $i = 0;
    while ($i < scalar(@{$Wavg})) {
       $W[$i] = Common::safe_division($Wavg->[$i], $n);
       $i++;
    }
    
    return \@W;
}

sub store_averaged_model {
    #description _ adds given averaged weight vector as last in the averaged model
    #param1  _ object reference (implicit)
    #param2  _ weight vector

    my $perceptron = shift;
    my $w = shift;

    my @W = @{$w};
    push(@{$perceptron->{averaged_model}}, \@W);
}

sub _initialize_weight_vector($) {
    #description _ creates and initializes weight vector (setting to 0 all components)
    #param1  _ vector size
    #param2  _ feature vector

    my $size = shift;
    
    my @w;
    my $i = 0;
    while ($i < $size) { $w[$i] = 0; $i++; }

    return \@w;
}

sub _initialize_weight_vector_uniform($) {
    #description _ creates and initializes weight vector (setting to 1 all components)
    #param1  _ vector size
    #param2  _ feature vector

    my $size = shift;
    
    my @w;
    my $i = 0;
    while ($i < $size) { $w[$i] = 1; $i++; }

    return \@w;
}

sub _add_weights($$) {
    #description _ adds given feature values to the given weight vector
    #param1  _ weight vector
    #param2  _ feature vector

    my $w = shift;
    my $f = shift;
    
    my $i = 1;
    while ($i < scalar(@{$f})) {
       $w->[$i-1] += $f->[$i];
       $i++;
    }
}

sub _substract_weights($$) {
    #description _ substracts given feature values from the given weight vector
    #param1  _ weight vector
    #param2  _ feature vector

    my $w = shift;
    my $f = shift;
    
    my $i = 1;
    while ($i < scalar(@{$f})) {
       $w->[$i-1] -= $f->[$i];
       $i++;
    }
}

sub _update_weights_pairwise($$$) {
    #description _ updates the given weight vector with given feature values
    #              adding or substracting according to the correct ranking.
    #param1  _ weight vector
    #param2  _ feature vector 1
    #param3  _ feature vector 2

    my $w = shift;
    my $f1 = shift;
    my $f2 = shift;
    
    my $i = 1;
    
    if ($f1->[0] > $f2->[0]) {
       while ($i < scalar(@{$f1})) {
          $w->[$i-1] += $f1->[$i] - $f2->[$i];
          $i++;
       }
    }
    elsif ($f1->[0] < $f2->[0]) {
       while ($i < scalar(@{$f1})) {
          $w->[$i-1] += $f2->[$i] - $f1->[$i];
          $i++;
       }
    }
}

sub _update_weights($$$) {
    #description _ updates the given weight vector based on the given example.
    #param1  _ weight vector
    #param2  _ example vector
    #param3  _ ranking of the top scored candidate

    my $w = shift;
    my $example = shift;
    my $j = shift;

    my $features_top = $example->[0];
    my $features_i = $example->[$j];

    if ($j > 0) { _update_weights_pairwise($w, $features_top, $features_i); }

    #my $gold_top = $features_top->[0];
    #my $score_top = _compute_score($w, $features_top);

    #my $gold_i = $features_i->[0];
    #my $score_i = _compute_score($w, $features_i);

    #if (($j > 0) and ($gold_i < $gold_top)) { _update_weights_pairwise($w, $features_top, $features_i); }

#    my $i = 1;
#    while ($i < scalar(@{$example})) {
#       my $features_i = $example->[$i];
#       #say join(",", @{$features_i});
#       my $gold_i = $features_i->[0];
#       my $score_i = _compute_score($w, $features2);
#
#          #print "$gold_score1 vs $gold_score2 :: $score1 vs $score2\n";
#          
#          if ((($gold_score1 > $gold_score2) and ($score1 <= $score2)) or
#              (($gold_score1 < $gold_score2) and ($score1 >= $score2))) {
#          #if ((($gold_score1 > $gold_score2 + 1) and ($score1 <= $score2)) or
#          #    (($gold_score1 + 1 < $gold_score2) and ($score1 >= $score2))) {
#             _update_weights_pairwise($w, $features1, $features2);
#          }
#       $i++;
#    }
}

sub _argmax($$) {
    #description _ returns the gold ranking of the top scored candidate in the the given example
    #              (according to the given weight vector).
    #param1  _ weight vector
    #param2  _ example vector
    #@return _ gold ranking of the top scored candidate
    
    my $w = shift;
    my $example = shift;

    my $features_top = $example->[0];
    my $max_score = _compute_score($w, $features_top);
    my $max_ranking = 0;
    my $i = 1;
    while ($i < scalar(@{$example})) {
       my $features = $example->[$i];
       my $score = _compute_score($w, $features);
       if ($score >= $max_score) { $max_score = $score; $max_ranking = $i; }
       $i++;
    }

    return $max_ranking;
}

sub _argmax_voted($$$) {
    #description _ returns the gold ranking of the top scored candidate in the the given example
    #              (according to the given voted model).
    #param1  _ voted model
    #param2  _ last epoch
    #param3  _ example vector
    #@return _ gold ranking of the top scored candidate
    
    my $model = shift;
    my $t = shift;
    my $example = shift;

    my $features_top = $example->[0];
    my $max_score = _compute_score_voted($model, $t, $features_top);
    my $max_ranking = 0;
    my $i = 1;
    while ($i < scalar(@{$example})) {
       my $features = $example->[$i];
       my $score = _compute_score_voted($model, $t, $features);
       if ($score >= $max_score) { $max_score = $score; $max_ranking = $i; }
       $i++;
    }

    return $max_ranking;
}

sub _compute_score($$) {
    #description _ computes the perceptron score for a given feature vector,
    #              i.e., the scalar product of weights and features
    #param1  _ weight vector
    #param2  _ feature vector
    #@retur  _ score
    
    my $w = shift;
    my $f = shift;
        
    my $score = 0;
    my $i = 1;
    while ($i < scalar(@{$f})) {
       if (defined($w->[$i-1])) { $score += $w->[$i-1] * $f->[$i]; }
       $i++;
    }
    
    return $score;
}

sub _compute_score_voted($$$) {
    #description _ computes the perceptron score for a given feature vector,
    #              i.e., the scalar product of weights and features
    #param1  _ voted model
    #param2  _ last epoch
    #param3  _ feature vector
    #@retur  _ score
    
    my $model = shift;
    my $T = shift;
    my $f = shift;
        
    my $score = 0;
    my $t = 0;
    while ($t <= $T) {    	
       foreach my $w (@{$model->[$t]}) {
          my $score_i = 0;
          my $i = 1;   
          while ($i < scalar(@{$f})) {
             if (defined($w->[$i])) { $score += $w->[$i] * $f->[$i]; }
             $i++;
          }
          $score += $w->[0] * $score_i;
       }
       $t++;
    }
    
    return $score;
}

sub _normalize_weights($) {
    #description _ normalizes weight vector so that all its components are in a [0..1] range
    #param1  _ weight vector

    my $w = shift;
    
    my $i = 0;
    my $max = -1;
    while ($i < scalar(@{$w})) {
       if ($w->[$i] > $max) { $max = $w->[$i]; }
       $i++;
    }
    
    $i = 0;
    while ($i < scalar(@{$w})) {
       $w->[$i] /= $max;
       $i++;
    }
}

sub _pw_dist($) {
    #description _ returns the distance between the two elements in the pairwise example
    #param1  _ pairwise example

    my $example = shift;

    my $score_A = $example->[0][0];
    my $score_B = $example->[1][0];

    return (abs($score_A - $score_B));
}

sub _print_vector_stderr($$) {
    #description _ prints given vector onto stderr
    #param1  _ vector
    #param2  _ vector name

    my $w = shift;
    my $name = shift;
    
    say STDERR "$name = [", join(",", @{$w}), "]";
}

sub _rank_examples($$) {
    #description _ ranks the given set of examples according to the given weight vector
    #param1  _ weight vector
    #param2  _ list of pairwise examples
    #@return _ (number of hits, total number of examples ranked)

    my $w = shift;
    my $examples = shift;
    
    my $n_miss = 0;
    my $i = 0;
    while ($i < scalar(@{$examples})) {    	
       my $j = _argmax($w, $examples->[$i]);
       if ($j > 0) { # top scored candidate according to the perceptron is not the best candidate according to gold scores
          $n_miss++;          	
       }
       $i++;
    }
    
    return ($i - $n_miss, $i);
}

sub _rank_examples_voted($$$) {
    #description _ ranks the given set of examples according to the given voted model
    #param1  _ model (list of weight vectors)
    #param2  _ last epoch
    #param3  _ list of pairwise examples
    #@return _ (number of hits, total number of examples ranked)

    my $model = shift;
    my $t = shift;
    my $examples = shift;
    
    my $n_miss = 0;
    my $i = 0;
    while ($i < scalar(@{$examples})) {
       my $j = _argmax_voted($model, $t, $examples->[$i]);
       if ($j > 0) { # top scored candidate according to the perceptron is not the best candidate according to gold scores
          $n_miss++;          	
       }
       $i++;
    }
    
    return ($i - $n_miss, $i);
}

sub rank {
    #description _ ranks the given set of examples according to the given strategy
    #param1  _ object reference (implicit)
    #param2  _ list of pairwise examples
    #param3  _ strategy ('last' | 'averaged' | 'voted')
    #param4  _ last epoch
    #param5  _ verbosity
	
    my $perceptron = shift;
    my $examples = shift;
    my $strategy = shift;
    my $t = shift;
    my $verbose = shift;

    if ($verbose) { printf STDERR "ranking (%d examples)\n", scalar(@{$examples}); }

    my $last_epoch = $t;
    if ($t >= $perceptron->{n_epochs}) { $last_epoch = $perceptron->{n_epochs} - 1; }
    
    my ($nhits, $n);
    
    if ($strategy eq $Perceptron::USE_LAST) {
       my $W = $perceptron->{model}->[$last_epoch];
       ($nhits, $n) = _rank_examples($W, $examples);
    }	
    elsif ($strategy eq $Perceptron::USE_VOTED) {
       my $model = $perceptron->{voted_model};
       ($nhits, $n) = _rank_examples_voted($model, $last_epoch, $examples);
    }	
    elsif ($strategy eq $Perceptron::USE_AVERAGED) {
       my $Wavg = $perceptron->{averaged_model}->[$last_epoch];
       ($nhits, $n) = _rank_examples($Wavg, $examples);    	
    }
    else { die "[ERROR] unkonwn ranking strategy '$strategy'\n"; }
    
    return ($nhits, $n);
}

sub save {
    #description _ stores perceptron onto disk
    #param1  _ object reference (implicit)
    #param2  _ model file
    #param3  _ verbosity

    my $perceptron = shift;
    my $model_file = shift;
    my $verbose = shift;
	
    if (!(-d "$Common::DATA_PATH/$Common::MODELS")) { system "mkdir $Common::DATA_PATH/$Common::MODELS"; } #MODEL DIRECTORY

    #print Dumper $perceptron->{mapping};

    my $MODEL = new IO::File("> $model_file") or die "Couldn't open output file: $model_file\n";
        
    # --- save models
	my $i = 0;
	while ($i < scalar(@{$perceptron->{model}})) {
       my @weights = ("LAST_".($i+1));
       my $j = 0;
       while ($j < scalar(@{$perceptron->{model}->[$i]})) {
       	  #push(@weights, $perceptron->{mapping}->[$j].":".$perceptron->{model}->[$i]->[$j]);
       	  push(@weights, ($j+1).":".$perceptron->{model}->[$i]->[$j]);
	      $j++;
       }
       print $MODEL join(" ", @weights), "\n";
	   $i++;
	}

    # --- save averaged models
	$i = 0;
	while ($i < scalar(@{$perceptron->{averaged_model}})) {
       my @weights = ("AVG_".($i+1));
       my $j = 0;
       while ($j < scalar(@{$perceptron->{averaged_model}->[$i]})) {
       	  #push(@weights, $perceptron->{mapping}->[$j].":".$perceptron->{averaged_model}->[$i]->[$j]);
       	  push(@weights, ($j+1).":".$perceptron->{averaged_model}->[$i]->[$j]);
	      $j++;
       }
       print $MODEL join(" ", @weights), "\n";
	   $i++;
	}

    # --- save voted models
    my $t = 0;
	while ($t < scalar(@{$perceptron->{voted_model}})) {
       my $i = 0;
	   while ($i < scalar(@{$perceptron->{voted_model}->[$t]})) {
          my @weights = ("VOTED_".$t."_".($i+1), $perceptron->{voted_model}->[$t]->[$i]->[0]);
          my $j = 1;
          while ($j < scalar(@{$perceptron->{voted_model}->[$t]->[$i]})) {
       	     #push(@weights, $perceptron->{mapping}->[$j-1].":".$perceptron->{voted_model}->[$t]->[$i]->[$j]); 
          	 push(@weights, $j.":".$perceptron->{voted_model}->[$t]->[$i]->[$j]);
	         $j++;
          }
          print $MODEL join(" ", @weights), "\n";
	      $i++;
	   }
	   $t++;
	}

    $MODEL->close();
}

sub load {
    #description _ loads perceptron from disk
    #param1  _ object reference (implicit)
    #param2  _ verbosity
    #param3  _ model file

    my $perceptron = shift;
    my $model_file = shift;
    my $verbose = shift;
    
    my $MODEL = new IO::File("< $model_file") or die "Couldn't open input file: $model_file\n";
    $perceptron->{n_epochs} = 0;
    while (defined(my $line = $MODEL->getline())) {
       $perceptron->{n_epochs}++;
    }
    $MODEL->close();
    
    $MODEL = new IO::File("< $model_file") or die "Couldn't open input file: $model_file\n";
    $perceptron->initialize_models();
    while (defined(my $line = $MODEL->getline())) {
       chomp($line);
       my @entry = split(" ", $line);
       my $label = shift(@entry);
       my @l_label = split("_", $label);
       my $type = $l_label[0];
       my $n_epoch = $l_label[1]; 
       my $n_consecutive_hits = 1;
       if ($type eq "VOTED") { $n_consecutive_hits = shift(@entry); }
       my @W;
       foreach my $item (@entry) {
       	  my @elem = split(":", $item);
	      $W[$elem[0]-1] = $elem[1];
       }
       if ($type eq "LAST") { $perceptron->store_model(\@W); }
       elsif ($type eq "AVG") { $perceptron->store_averaged_model(\@W); }
       elsif ($type eq "VOTED") {
       	  #my $i = $l_label[2];
       	  $perceptron->store_voted_model(\@W, $n_epoch, $n_consecutive_hits);
       }
    }
    $MODEL->close();
}

sub eval_indiv {
    #description _ evaluates the performance of individual features over the given set of examples
    #param1  _ object reference (implicit)
    #param3  _ list of pairwise test examples
    #param4  _ verbosity

    my $perceptron = shift;
    my $examples = shift;
    my $verbose = shift;

    if ($verbose) { printf STDERR "\n>>>> evaluating individual features (%d examples)\n", scalar(@{$examples}); }

    my $i = 0;
    my $max_accuracy = 0;
    while ($i < $perceptron->{n_features}) {
       if ($verbose) { print STDERR "\n--- feature #".($i+1)."\n";}
       my $W = _initialize_weight_vector($perceptron->{n_features});
       $W->[$i] = 1;
       my ($n_hits, $n) = _rank_examples($W, $examples);
       my $accuracy = Common::safe_division($n_hits, $n);
       if ($accuracy > $max_accuracy) { $max_accuracy = $accuracy; }
       if ($verbose) { printf STDERR "Accuracy = %d / %d =  %6.4f\n", $n_hits, $n, $accuracy;}
       $i++;
    }
    
    if ($verbose) { printf STDERR "\nMAX_INDIVIDUAL_ACCURACY =  %6.4f\n", $max_accuracy;   }
}

sub eval_uniform_combination {
    #description _ evaluates the performance of a baseline combination of all features being assigned the same weight.
    #param1  _ object reference (implicit)
    #param3  _ list of pairwise test examples
    #param4  _ verbosity

    my $perceptron = shift;
    my $examples = shift;
    my $verbose = shift;

    if ($verbose) { printf STDERR "\n>>>> evaluating uniform feature combination (%d examples)\n", scalar(@{$examples}); }

    my $W = _initialize_weight_vector_uniform($perceptron->{n_features});
    my ($n_hits, $n) = _rank_examples($W, $examples);
    if ($verbose) { printf STDERR "ULC_ACCURACY = %d / %d =  %6.4f\n", $n_hits, $n, Common::safe_division($n_hits, $n);}
}

sub eval {
    #description _ evaluates the perceptron over the given set of test examples
    #param1  _ object reference (implicit)
    #param2  _ number of epochs
    #param3  _ list of pairwise test examples
    #param4  _ verbosity

    my $perceptron = shift;
    my $n_epochs = shift;
    my $examples = shift;
    my $verbose = shift;

    if ($verbose) { printf STDERR "\n>>>> evaluating (%d examples)\n", scalar(@{$examples}); }

    my $t = 0;
    my $max_accuracy_last = 0;
    my $max_t_last = 0;
    my $max_accuracy_avg = 0;
    my $max_t_avg = 0;
    my @ACCURACY_AVG;
    my @ACCURACY_LAST;
    while (($t < $n_epochs) and ($t < $perceptron->{n_epochs})) {  
       if ($verbose) { print STDERR "\n--- epoch #".($t+1)."\n"; }
       my ($n_hits_last, $n) = $perceptron->rank($examples, $Perceptron::USE_LAST, $t, 0);
       my $accuracy_last = Common::safe_division($n_hits_last, $n);
       if ($verbose) { printf STDERR "Accuracy_last = %d / %d =  %6.4f\n", $n_hits_last, $n, $accuracy_last;}
       if ($accuracy_last > $max_accuracy_last) {
       	  $max_accuracy_last = $accuracy_last;
       	  $max_t_last = $t;
       }
       my ($n_hits_avg, undef) = $perceptron->rank($examples, $Perceptron::USE_AVERAGED, $t, 0);
       my $accuracy_avg = Common::safe_division($n_hits_avg, $n);
       if ($verbose) { printf STDERR "Accuracy_avg = %d / %d =  %6.4f\n", $n_hits_avg, $n, $accuracy_avg;}
       if ($accuracy_avg > $max_accuracy_avg) {
       	  $max_accuracy_avg = $accuracy_avg;
       	  $max_t_avg = $t;
       }

       push(@ACCURACY_LAST, $accuracy_last);
       push(@ACCURACY_AVG, $accuracy_avg);

       #my ($n_hits_voted, undef) = $perceptron->rank($examples, $Perceptron::USE_VOTED, $t, 0);
       #printf STDERR "Accuracy_voted = %d / %d =  %6.4f\n", $n_hits_voted, $n, Common::safe_division($n_hits_voted, $n);
       $t++;
    }

    if ($verbose) { 
      printf STDERR "\nMax Accuracy_last =  %6.4f (epoch %d)\n", $max_accuracy_last, $max_t_last;   
      printf STDERR "\nMax Accuracy_avg =  %6.4f (epoch %d)\n", $max_accuracy_avg, $max_t_avg;   
    }

    return (\@ACCURACY_LAST, \@ACCURACY_AVG, $max_t_last, $max_t_avg);
}

sub learn {
    #description _ learns over the given set of examples
    #param1  _ object reference (implicit)
    #param2  _ number of epochs
    #param3  _ list of pairwise learning examples
    #param4  _ minimum distance for example selection
    #param5  _ verbosity

    my $perceptron = shift;
    my $n_epochs = shift;
    my $examples = shift;
    my $min_dist = shift;
    my $verbose = shift;

    if ($n_epochs > 0) { $perceptron->{n_epochs} = $n_epochs; }
    else { $perceptron->{n_epochs} = 1; }
    
    if ($verbose) { printf STDERR "\n>>>> learning (%d examples)\n", scalar(@{$examples}); }
    
    $perceptron->initialize_models();
    my $W = _initialize_weight_vector($perceptron->{n_features});
    my $Wavg = _initialize_weight_vector($perceptron->{n_features});
    
    my $t = 0;
    my $i = 0;
    my $n_samples = 0;
    my @TRAIN_ACCURACY_AVG;
    my @TRAIN_ACCURACY_LAST;
    while ($t < $perceptron->{n_epochs}) {  
       if ($verbose) { print STDERR "\n--- epoch #".($t+1)." "; } 
       my $n_miss = 0;
       my $n_consecutive_hits = 0;
       $i = 0;
       $n_samples = 0;
       while ($i < scalar(@{$examples})) {
          #say "EPOCH #$t --- EXAMPLE #$i -----------------------------------------";
          if (_pw_dist($examples->[$i]) > $min_dist) {
             my $j = _argmax($W, $examples->[$i]);
             if ($j > 0) { # top scored candidate according to the perceptron is not the best candidate according to gold scores
                if ($n_consecutive_hits > 0) {
                   # --- update averaged weight vector       
                   $perceptron->update_averaged_model($Wavg, $W, $n_consecutive_hits);
                   # --- store voted model
                   #$perceptron->store_voted_model($W, $t, $n_consecutive_hits);
                }
                # --- update weight vector       
                _update_weights($W, $examples->[$i], $j);
                $n_miss++;
                $n_consecutive_hits = 1;
             }
             else { $n_consecutive_hits++; }
             $n_samples++;
	  }
          $i++;

          if ($verbose) { Common::show_progress($i, 1000, 10000); }
       }

       if ($verbose) { printf STDERR "..%d examples\n", $i; }
       
       # --- store weight vector at the end of current epoch
       $perceptron->store_model($W);
       # --- store voted model
       #$perceptron->store_voted_model($W, $t, $n_consecutive_hits);
       # --- update averaged weight vector       
       $perceptron->update_averaged_model($Wavg, $W, $n_consecutive_hits);
       # --- normalize and stored averaged weight vector at the end of current epoch  
       my $Wavg_t = $perceptron->normalize_averaged_model($Wavg, $i * ($t + 1));
       $perceptron->store_averaged_model($Wavg_t);

       my ($n_hits_last, $n) = $perceptron->rank($examples, $Perceptron::USE_LAST, $t, 0);
       my ($n_hits_avg, undef) = $perceptron->rank($examples, $Perceptron::USE_AVERAGED, $t, 0);
       #my ($n_hits_voted, undef) = $perceptron->rank($examples, $Perceptron::USE_VOTED, $t, 0);

       my $accuracy_last = Common::safe_division($n_hits_last, $n);
       push(@TRAIN_ACCURACY_LAST, $accuracy_last);
       my $accuracy_avg = Common::safe_division($n_hits_avg, $n);
       push(@TRAIN_ACCURACY_AVG, $accuracy_avg);
       #my $accuracy_voted = Common::safe_division($n_hits_voted, $n);
       #push(@TRAIN_ACCURACY_VOTED, $accuracy_voted);
       
       if ($verbose) {
       	  printf STDERR "errors = %d / %d = %6.4f\n", $n_miss, $n_samples, Common::safe_division($n_miss, $n_samples);
       	  printf STDERR "Accuracy_last = %d / %d =  %6.4f\n", $n_hits_last, $n, $accuracy_last;
       	  printf STDERR "Accuracy_avg = %d / %d =  %6.4f\n", $n_hits_avg, $n, $accuracy_avg;
       	  #printf STDERR "Accuracy_voted = %d / %d =  %6.4f\n", $n_hits_voted, $n, $accuracy_voted);
       	  _print_vector_stderr($W, "W");
       	  _print_vector_stderr($Wavg_t, "Wavg");
       }

       $t++;
    }

    if ($verbose) { 
       print STDERR "\n";
       print STDERR "TRAIN_ACCURACY_LAST_per_epoch = [ ", join(", ", @TRAIN_ACCURACY_LAST), " ]\n";
       print STDERR "\n";
       print STDERR "TRAIN_ACCURACY_AVG_per_epoch = [ ", join(", ", @TRAIN_ACCURACY_AVG), " ]\n";
    }
    my $Wavg_t = $perceptron->normalize_averaged_model($Wavg, $n_samples * $t);
    
    if ($verbose) {
       print STDERR "\nFinal weight vectors:\n\n";
       _print_vector_stderr($W, "W");
       print STDERR "\n";
       _print_vector_stderr($Wavg_t, "Wavg");
    }
}

1;
