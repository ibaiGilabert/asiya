package Learner;

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
use IQ::InOut::IQXML;
use IQ::MetaScoring::Assessments;
use IQ::Learning::Perceptron;

sub new {
    #description _ creates a new learner
    #param1 _ class name (implicit)
    #param2 _ configuration
     

    my $class = shift;     #implicit parameter
    my $config = shift;
    
    if ($config->{learn_scheme} ne $Common::LEARN_PERCEPTRON) { die "[ERROR] unknown learning type '".$config->{learn_scheme}."'\n"; }

    my $learner;
    
if (1) {  
    my ($cases, $mapping) = Learner::extract_cases($config);
	
    #Learner::print_cases($cases);

    my ($train_cases, $dev_cases, $test_cases) = Learner::split_cases($cases, $config->{train_prop});
    
    #Learner::print_cases($train_cases);
    #Learner::print_cases($dev_cases);
    #Learner::print_cases($test_cases);
    ##Learner::print_cases_pairwise($cases, $config->{min_dist});
    #Learner::print_cases_pairwise($train_cases, $config->{min_dist});
    #Learner::print_cases_pairwise($dev_cases, $config->{min_dist});
    #Learner::print_cases_pairwise($test_cases, $config->{min_dist});

    Learner::write_cases($cases, "$Common::DATA_PATH/$Common::TMP/cases.txt");
    Learner::write_cases($train_cases, "$Common::DATA_PATH/$Common::TMP/cases.train.txt");
    Learner::write_cases($dev_cases, "$Common::DATA_PATH/$Common::TMP/cases.dev.txt");
    Learner::write_cases($test_cases, "$Common::DATA_PATH/$Common::TMP/cases.test.txt");
    Learner::write_cases_pairwise($cases, "$Common::DATA_PATH/$Common::TMP/cases_pw.txt", $config->{min_dist});
    Learner::write_cases_pairwise($train_cases, "$Common::DATA_PATH/$Common::TMP/cases_pw.train.txt", $config->{min_dist});
    Learner::write_cases_pairwise($dev_cases, "$Common::DATA_PATH/$Common::TMP/cases_pw.dev.txt", $config->{min_dist});
    Learner::write_cases_pairwise($test_cases, "$Common::DATA_PATH/$Common::TMP/cases_pw.test.txt", $config->{min_dist});

    $learner = { type => $config->{learn_scheme}, mapping => $mapping, cases => $cases,
                 train_cases => $train_cases, dev_cases => $dev_cases, test_cases => $test_cases };
}
else {
    my @reverse_mapping;
    my $i = 1;
    while ($i <= 14) { push(@reverse_mapping, $i); $i++; }
    my $mapping = \@reverse_mapping;	

    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank_wmt07-09.txt", $config->{verbose});
    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank_wmt07-10.txt", $config->{verbose});
    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank_wmt10.txt", $config->{verbose});
    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank_wmt07-09_newstest.txt", $config->{verbose});
    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank_wmt07-10_newstest.txt", $config->{verbose});
    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank_wmt07-10_es-en_newstest.txt", $config->{verbose});
    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank_wmt07-10_en-es_newstest.txt", $config->{verbose});

    #my ($train_cases, $dev_cases, $test_cases) = Learner::split_cases($cases, $config->{train_prop});

    #my $cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/data/cases.txt", $config->{verbose});
    #my $train_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/data/cases.train.txt", $config->{verbose});
    #my $dev_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/data/cases.dev.txt", $config->{verbose});
    #my $test_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/data/cases.test.txt", $config->{verbose});
    #my $cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/data/cases_pw.txt", $config->{verbose});
    #my $train_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/data/cases_pw.train.txt", $config->{verbose});
    #my $dev_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/data/cases_pw.dev.txt", $config->{verbose});
    #my $test_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/data/cases_pw.test.txt", $config->{verbose});

    #my $train_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/train.pairs.txt", $config->{verbose});

    my $cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/cases_14.txt", $config->{verbose});
    my $train_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/cases_14.train.txt", $config->{verbose});
    my $dev_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/cases_14.dev.txt", $config->{verbose});
    my $test_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/cases_14.test.txt", $config->{verbose});
    #my $cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/lluism/data/pairs/cases.pairs.txt", $config->{verbose}); 
    #my $train_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/lluism/data/pairs/train.pairs.txt", $config->{verbose}); 
    #my $dev_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/lluism/data/pairs/devel.pairs.txt", $config->{verbose});
    #my $test_cases = Learner::read_cases("/home/jgimenez/research/MTEVAL/en-es_wmt08_16000.cs/lluism/data/pairs/test.pairs.txt", $config->{verbose});

    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases.txt", $config->{verbose});
    #my $train_cases = Learner::read_cases("$Common::DATA_PATH/data/cases.train.txt", $config->{verbose});
    #my $dev_cases = Learner::read_cases("$Common::DATA_PATH/data/cases.dev.txt", $config->{verbose});
    #my $test_cases = Learner::read_cases("$Common::DATA_PATH/data/cases.test.txt", $config->{verbose});

    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_adequacy.txt", $config->{verbose});
    #my $train_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_adequacy.train.txt", $config->{verbose});
    #my $dev_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_adequacy.dev.txt", $config->{verbose});
    #my $test_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_adequacy.test.txt", $config->{verbose});

    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_fluency.txt", $config->{verbose});
    #my $train_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_fluency.train.txt", $config->{verbose});
    #my $dev_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_fluency.dev.txt", $config->{verbose});
    #my $test_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_fluency.test.txt", $config->{verbose});

    #my $cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank.txt", $config->{verbose});
    #my $train_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank.train.txt", $config->{verbose});
    #my $dev_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank.dev.txt", $config->{verbose});
    #my $test_cases = Learner::read_cases("$Common::DATA_PATH/data/cases_rank.test.txt", $config->{verbose});

    #Learner::write_cases($cases, "$Common::DATA_PATH/data/cases.txt");
    #Learner::write_cases($train_cases, "$Common::DATA_PATH/data/cases.train.txt");
    #Learner::write_cases($dev_cases, "$Common::DATA_PATH/data/cases.dev.txt");
    #Learner::write_cases($test_cases, "$Common::DATA_PATH/data/cases.test.txt");
    #Learner::write_cases_pairwise($cases, "$Common::DATA_PATH/data/cases_pw.txt", $config->{min_dist});
    #Learner::write_cases_pairwise($train_cases, "$Common::DATA_PATH/data/cases_pw.train.txt", $config->{min_dist});
    #Learner::write_cases_pairwise($dev_cases, "$Common::DATA_PATH/data/cases_pw.dev.txt", $config->{min_dist});
    #Learner::write_cases_pairwise($test_cases, "$Common::DATA_PATH/data/cases_pw.test.txt", $config->{min_dist});
	
    $learner = { type => $config->{learn_scheme}, mapping => $mapping, cases => $cases,
                 train_cases => $train_cases, dev_cases => $dev_cases, test_cases => $test_cases };
}

    bless $learner, $class;

    return $learner;
}

sub split_cases {
    #description _ splits a list of cases into TRAINING, DEVELOPMENT and TEST, according to the given training proportion
    #              (same proportion for development and test)
    #param1  _ cases (list ref)
    #param2  _ training proportion
    
    my $cases = shift;
    my $p = shift;

    my @train_cases;
    my @dev_cases;
    my @test_cases;
    
    srand();
    foreach my $case (@{$cases}) {
       my $r = rand(1);
       if ($r <= $p) { push(@train_cases, $case); }
       #elsif (($r > $p) and ($r <= ($p + (1-$p)/2))) { push(@dev_cases, $case); }
       #else { push(@test_cases, $case); }
       else {
       	  if (scalar(@test_cases) == scalar(@dev_cases)) { push(@test_cases, $case); }
       	  else { push(@dev_cases, $case); }
       }
    }

    return (\@train_cases, \@dev_cases, \@test_cases);
}

sub extract_cases {
    #description _ creates the set of learning cases (for measure combination based on ML) according to the given configuration
    #              - examples are segment scores represented as feature vectors (invidividual measures are the features)
    #              - examples are accompanied by human assessments
    #param1  _ configuration

    my $config = shift;

    # --- metrics
    my @metrics = sort @{$config->{metrics}};
    
    # --- mapping
    my %mapping;
    my @reverse_mapping;
    my $i = 1;
    foreach my $metric (@metrics) { $mapping{$metric} = $i; push(@reverse_mapping, $metric); $i++; }

    # --- assessments
    my $assessments = Assessments::select($config, $Common::G_SEG);
    #print Dumper $assessments; 
    
    # --- features
    if ($config->{verbose} == 1) { print STDERR "reading metric scores"; }
    my %OQ;
	foreach my $metric (@metrics) {
       if ($config->{verbose} == 1) { print STDERR "..$metric"; }
       foreach my $system (@{$config->{systems}}) {
          my $REF = join("_", sort @{$config->{references}});
          IQXML::read_report($system, $REF, $metric, \%OQ, $config->{segments}, $Common::G_SEG, $config->{verbose});
       }
    }
    if ($config->{verbose} == 1) { print STDERR "\n"; }
	
    my $ref = join("_", @{$config->{references}});
    my $doALL = (scalar(keys %{$config->{segments}}) == 0);  # if no segments are specified use all

    my @cases;
    for (my $i = 0; $i < scalar(@{$OQ{$Common::G_SEG}}); $i++) {
       if (exists($config->{segments}->{$i + 1}) or $doALL) {
       	  my %system_features;
          foreach my $system (@{$config->{systems}}) {
             my $segid = $config->{IDX}->{$system}->[$i + 1]->[3];
             my $docid = $config->{IDX}->{$system}->[$i + 1]->[0];
             my $sysid = $config->{IDX}->{$system}->[1]->[2];
             if (exists($assessments->{$sysid.$Common::ID_SEPARATOR.$docid.$Common::ID_SEPARATOR.$segid})) {
                my $human_score = 0 + $assessments->{$sysid.$Common::ID_SEPARATOR.$docid.$Common::ID_SEPARATOR.$segid};
                # --- features as a hash
                #my %features;
                #foreach my $metric (@metrics) {
                #   $features{$mapping{$metric}} = 0 + $OQ{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref}
                #}
                #$system_features{$system} = [$human_score, \%features];
                # --- features as an array
                my @features = ($human_score);
                foreach my $metric (@metrics) {
                   $features[$mapping{$metric}] = 0 + $OQ{$Common::G_SEG}->[$i]->{$metric}->{$system}->{$ref}
                }
                $system_features{$system} = \@features;
             }
          }
          if (scalar(keys %system_features) > 0) { push(@cases, \%system_features); }
       }
    }

    return (\@cases, \@reverse_mapping);
}	

sub read_cases {
    #description _ reads a set of learning cases from the given file
    #param1  _ case file
    #param2  _ verbosity

    my $file = shift;
    my $verbose = shift;

    my @cases;

    my $CASES = new IO::File("< $file") or die "Couldn't open input file: $file\n";

    if ($verbose) { print STDERR "READING CASES FROM FILE '$file'..."; }
 
    while (defined(my $line = $CASES->getline())) {
       chomp($line);
       my @entry = split(" ", $line);
       my %system_features;
       my $i = 0;
       while ($i < scalar(@entry)) { # systems
          my $human_score = $entry[$i];
          my @features = ($human_score);
          my @subentry = split(",", $entry[$i+1]);
          my $j = 0;
          while ($j < scalar(@subentry)) { # system features
             # --- features as an array
             my @item = split(":", $subentry[$j]);
             my $feature = $item[0];
             my $value = $item[1];
             #if (($feature < 7) or ($feature > 9)) {
             #   if ($feature > 9) { $feature-=3; }
             $features[$feature] = $value;
             #}
             $j++;
          }
          $system_features{$i} = \@features;
          $i += 2;
       }
       if (scalar(keys %system_features) > 0) { push(@cases, \%system_features); }
    }
    
    if ($verbose) { print STDERR scalar(@cases), " cases read\n"; }

    $CASES->close();
    	
    return \@cases;
}

sub _get_feature_vector {
    #description _ creates a representation of the feature vector
    #param1 _ feature vector (list ref)

    my $feature_list = shift;

    my @features;
    # --- features as a hash
    #foreach my $feature (sort { $a <=> $b } keys %{$case->{$system}->[1]}) {
    #	 push(@features, $feature.":".$case->{$system}->[1]->{$feature});
    #}
    # --- features as an array

    my $i = 1;
    while ($i < scalar(@{$feature_list})) {
       if (defined(my $value = $feature_list->[$i])) {
          push(@features, $i.":".$value);
       }
       $i++;
    }

    return \@features;
}

sub write_cases {
    #description _ prints learning cases onto the given file
    #param1  _ cases (list reference)
    #param2  _ case file
	
    my $cases = shift;
    my $file = shift;

    my $CASES = new IO::File("> $file") or die "Couldn't open output file: $file\n";

    foreach my $case (@{$cases}) {
       if (scalar(keys %{$case}) > 0) {
          my @feature_vectors;
          foreach my $system (sort { $case->{$b}->[0] <=> $case->{$a}->[0] } keys %{$case}) {
             push(@feature_vectors, $case->{$system}->[0]." ".join(",", @{_get_feature_vector($case->{$system})}));
          }
          say $CASES join(" ", @feature_vectors);
       }
    }

    $CASES->close();
}

sub write_cases_pairwise {
    #description _ prints learning cases onto the given file (pairwisely)
    #param1  _ cases (list reference)
    #param2  _ case file
    #param3  _ example selection strategy ('all examples' | ...)

    my $cases = shift;
    my $file = shift;
    my $min_dist = shift;

    my $CASES = new IO::File("> $file") or die "Couldn't open output file: $file\n";
	
    my @examples;
    foreach my $case (@{$cases}) {
       if (scalar(keys %{$case}) > 0) {
          my @systems = sort { $case->{$b}->[0] <=> $case->{$a}->[0] } keys %{$case};
          my @systems_left = @systems;
          foreach my $s1 (@systems) {
	         my $s1_feature_vector = $case->{$s1}->[0]." ".join(",", @{_get_feature_vector($case->{$s1})});
             shift(@systems_left);
             foreach my $s2 (@systems_left) {
                if ($case->{$s1}->[0] > $case->{$s2}->[0] + $min_dist) { # use only translations ranked as different according to human assessors
                   my $s2_feature_vector = $case->{$s2}->[0]." ".join(",", @{_get_feature_vector($case->{$s2})});
                   say $CASES $s1_feature_vector." ".$s2_feature_vector;
                }
             }
          }
       }
    }

    $CASES->close();
}

sub print_cases {
    #description _ prints learning cases onto STDOUT
    #param1  _ cases (list reference)
	
    my $cases = shift;

    foreach my $case (@{$cases}) {
       if (scalar(keys %{$case}) > 0) {
          my @feature_vectors;
          foreach my $system (sort { $case->{$b}->[0] <=> $case->{$a}->[0] } keys %{$case}) {
             push(@feature_vectors, $case->{$system}->[0]." ".join(",", @{_get_feature_vector($case->{$system})}));
          }
          say join(" ", @feature_vectors);
       }
    }
}

sub print_cases_pairwise {
    #description _ prints learning cases onto STDOUT (pairwisely)
    #param1  _ cases (list reference)
    #param2  _ example selection strategy ('all examples' | ...)

    my $cases = shift;
    my $min_dist = shift;
	
    my @examples;
    foreach my $case (@{$cases}) {
       if (scalar(keys %{$case}) > 0) {
          my @systems = sort { $case->{$b}->[0] <=> $case->{$a}->[0] } keys %{$case};
          my @systems_left = @systems;
          foreach my $s1 (@systems) {
	         my $s1_feature_vector = $case->{$s1}->[0]." ".join(",", @{_get_feature_vector($case->{$s1})});
             shift(@systems_left);
             foreach my $s2 (@systems_left) {
                if ($case->{$s1}->[0] > $case->{$s2}->[0] + $min_dist) { # use only translations ranked as different according to human assessors
                   my $s2_feature_vector = $case->{$s2}->[0]." ".join(",", @{_get_feature_vector($case->{$s2})});
                   say $s1_feature_vector." ".$s2_feature_vector;
                }
             }
          }
       }
    }
}

sub extract_pairwise_examples {
    #description _ extracts a list of pairwise examples from the ranked collection of cases
    #param1  _ cases (list ref)
    #param2  _ example selection strategy ('all examples' | ...)
    #@return _ list of pairwise examples
	
    my $cases = shift;
    my $min_dist = shift;
	
    my @examples;
    foreach my $case (@{$cases}) {
       if (scalar(keys %{$case}) > 0) {
          my @systems = sort { $case->{$b}->[0] <=> $case->{$a}->[0] } keys %{$case};
          my @systems_left = @systems;
          foreach my $s1 (@systems) {
             shift(@systems_left);
             foreach my $s2 (@systems_left) {
                if ($case->{$s1}->[0] > $case->{$s2}->[0] + $min_dist) { # use only translations ranked as different according to human assessors
                   push(@examples, [$case->{$s1}, $case->{$s2}]);
                }
             }
          }
       }
    }
    
    return \@examples;
}

sub go {
    #description _ performs the learning (on the given collection of cases)
    #              and stores learned models under the 'data_path/models' folder
    #param1  _ learner object (implicit)
    #param2  _ minimum distance for example selection
    #param3  _ number of epochs
    #param4  _ model file
    #param5  _ verbosity
	
    my $learner = shift;
    my $min_dist = shift;
    my $n_epochs = shift;
    my $model_file = shift;
    my $verbose = shift;

    if ($learner->{type} eq $Common::LEARN_PERCEPTRON) {
       # --- create models ----------------------------------------------------
       # --- learn (for t = 1..T epochs) from training data (or load)
       my $train_examples = Learner::extract_pairwise_examples($learner->{train_cases}, $min_dist);
       #my $train_examples = Learner::extract_pairwise_examples($learner->{train_cases}, 0);
       my $perceptron = new Perceptron($learner->{mapping});
       $perceptron->learn($n_epochs, $train_examples, $min_dist, $verbose);
       # --- store model (onto disk)
       $perceptron->save($model_file, $verbose);
       # --- load model (from disk)
       #$perceptron->load($model_file);

       # --- evaluate (over dev data) -----------------------------------------
       my $dev_examples = Learner::extract_pairwise_examples($learner->{dev_cases}, $min_dist);
       #my $dev_examples = Learner::extract_pairwise_examples($learner->{dev_cases}, 0);
       $perceptron->eval_indiv($dev_examples, $verbose);
       $perceptron->eval_uniform_combination($dev_examples, $verbose);
       my ($dev_accuracy_last, $dev_accuracy_avg, $dev_max_t_last, $dev_max_t_avg) = $perceptron->eval($n_epochs, $dev_examples, $verbose);
       if ($verbose) { 
          print STDERR "\n";
          print STDERR "DEV_ACCURACY_LAST_per_epoch = [ ", join(", ", @{$dev_accuracy_last}), " ]\n";
          print STDERR "\n";
          print STDERR "DEV_ACCURACY_AVG_per_epoch = [ ", join(", ", @{$dev_accuracy_avg}), " ]\n";
       }
       # --- evaluate (over test data) -----------------------------------------
       my $test_examples = Learner::extract_pairwise_examples($learner->{test_cases}, $min_dist);
       #my $test_examples = Learner::extract_pairwise_examples($learner->{test_cases}, 0);
       $perceptron->eval_indiv($test_examples, $verbose);
       $perceptron->eval_uniform_combination($test_examples, $verbose);
       my ($test_accuracy_last, $test_accuracy_avg, $test_max_t_last, $test_max_t_avg) = $perceptron->eval($n_epochs, $test_examples, $verbose);
       if ($verbose) { 
         print STDERR "\n";
         print STDERR "TEST_ACCURACY_LAST_per_epoch = [ ", join(", ", @{$test_accuracy_last}), " ]\n";
         print STDERR "\n";
         print STDERR "TEST_ACCURACY_AVG_per_epoch = [ ", join(", ", @{$test_accuracy_avg}), " ]\n";

          # --- test accuracy using optimal epoch from development
          print STDERR "\n";
          print STDERR "TEST RESULTS (using optimal dev epoch models)\n";
          print STDERR "---------------------------------------------\n";
          print STDERR "\n";
          printf STDERR "TEST_ACCURACY_LAST = %6.4f (epoch %d)\n", $test_accuracy_last->[$dev_max_t_last], $dev_max_t_last;
          print STDERR "\n";
          printf STDERR "TEST_ACCURACY_AVG = %6.4f (epoch %d)\n", $test_accuracy_avg->[$dev_max_t_avg], $dev_max_t_avg;
       }
    }
    else { die "[ERROR] Learning type '".$learner->{type}."' not yet implemented!!\n"; }
}


1;
