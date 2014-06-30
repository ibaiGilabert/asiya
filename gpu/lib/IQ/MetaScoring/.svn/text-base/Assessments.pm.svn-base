package Assessments;

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
use IO::File;
use Scalar::Util qw(looks_like_number);
use IQ::Common;

sub read_file {
    #description _ read assessments from the given file (into a hash)
    #param1  _ human assessments (filename)
    #param2  _ verbosity

    my $file = shift;
    my $verbose = shift;
    
    if ($verbose) { print STDERR "READING assessments FROM <$file>..."; }

    my %SCORES;
    my $iter = 0;   
    my $F = new IO::File("< $file") or die "Couldn't open input file <$file>\n";
    while (defined( my $line = $F->getline())) {
       chomp($line); my @entry = split(/\s+/, $line);
       if (scalar(@entry) > 1) {
       	  my $id = shift(@entry);  
       	  $id =~s/^S//; $id = "S".$id;
          my $n = pop(@entry);
          $n =~ s/,/./g;
          if (scalar(@entry) == 0) {
             $SCORES{$Common::G_SYS}->{$id} = sprintf("%10.8f", $n);
          }
          if (scalar(@entry) == 1) {
          	 $id .= ":".join(":", @entry);
             $SCORES{$Common::G_DOC}->{$id} = sprintf("%10.8f", $n);
          }
          if (scalar(@entry) == 2) {
          	 $id .= ":".join(":", @entry);
             $SCORES{$Common::G_SEG}->{$id} = sprintf("%10.8f", $n);
          }
       }
       else { die "[ERROR] wrong format in assessments file <$file>!!\n"; }
       
       $iter++;
       if ($verbose) {
          if ($iter%10000 == 0) { print STDERR "."; }
          if ($iter%100000 == 0) { print STDERR ".$iter"; }
       }
    }
    $F->close();
    if ($verbose) { print STDERR "..$iter elements [DONE]\n"; }

    return \%SCORES;
}

sub find_assessment_type_NISTCSV($) {
	#description _ return assessment type
	#param1  _ header (hash ref)
	#@return _ assessment type (string)
	
	my $header = shift;
	
	#print Dumper $header;
	
	my $type;
	if (exists($header->{"score"})) { $type = "score"; }
	#elsif (exists($header->{"scoreQuality"})) { $type = "scoreQuality"; }
	elsif (exists($header->{"rank"})) { $type = "rank"; }
	elsif (exists($header->{"adequacy score"})) { $type = "adequacy score"; }
	elsif (exists($header->{"comprehensibility"})) { $type = "comprehensibility"; }
	elsif (exists($header->{"reference informativeness"})) { $type = "reference informativeness"; }
	#elsif (exists($header->{"preferred"})) { $type = "preferred"; }
	else { die "[ERROR] unkown or not assesment type in header definition <".join(",", sort keys %{$header}).">!!\n"; }
	
	return $type;
}

sub find_field_positions($) {
	my $header = shift;
	
    my $system_pos = -1;
    my $document_pos = -1;
    my $segment_pos = -1;
    my $score_pos = -1;
    my $score_type = find_assessment_type_NISTCSV($header);

    if (exists($header->{"systemId"})) {
       $system_pos = $header->{"systemId"};
       $score_pos = $header->{$score_type};
       if (exists($header->{"documentId"})) { $document_pos = $header->{"documentId"}; }
       if (exists($header->{"segmentId"})) { $segment_pos = $header->{"segmentId"}; }
    }
    else { die "[ERROR] `systemId' position not specified in assessments file!!\n"; }

    return ($system_pos, $document_pos, $segment_pos, $score_pos, $score_type);
}

sub default_field_positions {
    return (0, 1, 2, 3, "score");
}

sub get_field($$) {
	my $entry = shift;
	my $i = shift;

    my $elem;
    if ($i == -1) { $elem = undef; }
    elsif (scalar(@{$entry}) > $i) { $elem = $entry->[$i]; }
    else { die "[ERROR] bad-formed assessment \n'".join(",", @{$entry})."'!!\n"; }	
	
	return $elem;
}

sub get_score($$$) {
	my $entry = shift;
	my $score_pos = shift;
	my $score_type = shift;
	
	my $score = get_field($entry, $score_pos);
	
	if (($score_type eq "rank") and looks_like_number($score)) { $score = 1/$score; }
	
	return $score;
}          

sub read_NISTCSV_file {
    #description _ read assessments from the given NIST CSV file (into a hash)
    #param1  _ human assessments (filename)
    #param2  _ IDX structure
    #param3  _ verbosity

    my $file = shift;
    my $idx = shift;
    my $verbose = shift;
    
    if ($verbose) { print STDERR "READING assessments FROM <$file>..."; }

    my %HEADER;
    my %ASS;
    my $iter = 0;
    my ($system_pos, $document_pos, $segment_pos, $score_pos, $score_type) = default_field_positions();
    
    my $F = new IO::File("< $file") or die "Couldn't open input file <$file>\n";
    
    while (defined( my $line = $F->getline())) {
       chomp($line);
       if ($line =~ /^\#.*Id.*/ ) { #header
          ## systemId,documentId,segmentId,judgeId,referenceId,score,scoreQuality,startTime,endTime
          ## systemId, documentId, judgeId, adequacy score, startTime, endTime
          ## systemId, documentId, segmentId, judgeId, comprehensibility, startTime, endTime
          ## systemId, documentId, segmentId, judgeId, reference informativeness, startTime, endTime
          ## systemId, documentId, judgeId, adequacy score, startTime, endTime
          ## systemId, documentId, segmentId, judgeId, comprehensibility, startTime, endTime
          ## systemId, documentId, segmentId, judgeId, reference informativeness, startTime, endTime
	       $line =~ s/\# *//g;
          my @entry = split(/\s*,\s*/, $line);

          my $i = 0;
          while ($i < scalar(@entry)) { $HEADER{$entry[$i]} = $i; $i++; }
          ($system_pos, $document_pos, $segment_pos, $score_pos, $score_type) = find_field_positions(\%HEADER);
       }
       elsif (($line =~ /^\s*$/) or ($line =~ /^\#.*/)) { #empty line or other comments
          1; #no-op       
       }
       else { #assessment

			my $res = 0;
			if ($score_type eq "rank"){
				my $rankid_pos = -1;
				if ( exists($HEADER{"rankId"}) ){
					$rankid_pos= $HEADER{"rankId"} ;
				}
				$res = read_ranks( $line, $rankid_pos, $score_pos, $score_type, $system_pos, $document_pos, $segment_pos, $idx, $file, \%ASS);
			}
     		else{
				$res = read_scores( $line, $score_pos, $score_type, $system_pos, $document_pos, $segment_pos, $idx, $file, \%ASS);
     		}
     		# print errors 
     		if ( $res == -1 ){ die "[ERROR] bad-formed assessments file '$file' --no systemId-- (line ", $iter + 1, ")\n";	}
     		elsif ( $res == -2 ){ die "[ERROR] bad-formed assessments file '$file' --no segmentId-- (line ", $iter + 1, ")\n"; }
     		elsif ( $res == -3 ){ die "[ERROR] bad-formed assessments file '$file' --no rank -- (line ", $iter + 1, ")\n"; }
        	elsif ( $res == -4 ){ die "[ERROR] bad-formed assessments file '$file' --no rankId-- (line ", $iter + 1, ")\n"; }
			else{ %ASS = %{$res}; }
			
			if ($verbose) {
         	if ($iter%10 == 0) { print STDERR "."; }
            if ($iter%100 == 0) { print STDERR "$iter"; }
         }
         $iter++;
       }
    }

    $F->close();
    if ($verbose) { print STDERR "..$iter assessments read [DONE]\n"; }
	 if ( scalar (keys %ASS) == 0 ) { print "Assessments are empty. Add a header to the assessments file \n";}

    #print "----------- assessments content\n";
    #print Dumper \%ASS;
	 #exit();
	 return ($score_type,\%ASS);
}


sub read_ranks {
	
		my $line = shift;
		my $rankid_pos = shift;
		my $score_pos = shift;
		my $score_type= shift; 
		my $system_pos = shift;
		my $document_pos = shift;
		my $segment_pos = shift;
		my $idx = shift;
		my $file = shift;
		my $refass = shift;
		
		my %ASS = %{$refass}; 

		my @entry = split(/\s*,\s*/, $line);

		#scores
      my $score = get_score(\@entry, $score_pos, $score_type);
		if (looks_like_number($score)) {
		
			my $sysId = get_field(\@entry, $system_pos);
      	if ($sysId eq "") { return -1; }

			my $rankId = get_field(\@entry, $rankid_pos);
      	if ($rankId eq "") { return -4; }

			my $segId = get_field(\@entry, $segment_pos);
			if ($segId eq "") { return -2; }


			my $docId = get_field(\@entry, $document_pos);
      	if ($docId eq "") { 
				my $documentId = $idx->[$segId]->[0];
         	my $segmentId = $idx->[$segId]->[3];
				$ASS{$Common::G_SEG}->{$documentId}->{$segmentId}->{$rankId}->{$sysId} = $score;
			}
			else {
	         $ASS{$Common::G_SEG}->{$docId}->{$segId}->{$rankId}->{$sysId} = $score;
  			}
		}
		else{
			return -3;
		}
	
		return \%ASS;
}


sub read_scores {
	
		my $line = shift;
		my $score_pos = shift;
		my $score_type= shift; 
		my $system_pos = shift;
		my $document_pos = shift;
		my $segment_pos = shift;
		my $idx = shift;
		my $file = shift;
		my $refass = shift;
		
		my %ASS = %{$refass}; 


		my @entry = split(/\s*,\s*/, $line);

		#scores
      my $score = get_score(\@entry, $score_pos, $score_type);
		if (looks_like_number($score)) {
		
			my $sysId = get_field(\@entry, $system_pos);
   	   if ($sysId eq "") { return -1; }

     		if (defined(my $docId = get_field(\@entry, $document_pos))) {
        		if ($docId eq "") {
           		if (defined(my $segId = get_field(\@entry, $segment_pos))) { #document id's are not provided!!
              		if ($segId eq "") { return -2; }
              		else { # automatically assignment of document and segment id's
                 		my $documentId = $idx->[$segId]->[0];
                 		my $segmentId = $idx->[$segId]->[3];
                 		if (exists($ASS{$Common::G_SEG}->{$sysId}->{$documentId}->{$segmentId})) {
								push(@{$ASS{$Common::G_SEG}->{$sysId}->{$documentId}->{$segmentId}}, $score);
							}
							else { $ASS{$Common::G_SEG}->{$sysId}->{$documentId}->{$segmentId} = [$score]; }
						}
					}
					else {
              		if (exists($ASS{$Common::G_SYS}->{$sysId})) { push(@{$ASS{$Common::G_SYS}->{$sysId}}, $score); }
						else { $ASS{$Common::G_SYS}->{$sysId} = [$score]; }
					}
				}
				else {
        			if (defined(my $segId = get_field(\@entry, $segment_pos))) {
		        		if ($segId eq "") { return -2; }
						else {
      	        		if (exists($ASS{$Common::G_SEG}->{$sysId}->{$docId}->{$segId})) {
         	        		push(@{$ASS{$Common::G_SEG}->{$sysId}->{$docId}->{$segId}}, $score);
            	     	}
               	  	else { $ASS{$Common::G_SEG}->{$sysId}->{$docId}->{$segId} = [$score]; }
	              	}	
      	  		}
   	        	else {
         	  		if (exists($ASS{$Common::G_DOC}->{$sysId}->{$docId})) {
            	  		push(@{$ASS{$Common::G_DOC}->{$sysId}->{$docId}}, $score);
              		}
	              	else { $ASS{$Common::G_DOC}->{$sysId}->{$docId} = [$score]; }
   	        	}
     			}
	   	}
			else {
   			if (exists($ASS{$Common::G_SYS}->{$sysId})) { push(@{$ASS{$Common::G_SYS}->{$sysId}}, $score); }
	        	else { $ASS{$Common::G_SYS}->{$sysId} = [$score]; }
			}
		}
		return \%ASS;
}



sub average_assessments{
	 my $type = shift;
	 my $hASS = shift;

	 if ( $type eq "rank" ){
		return average_ranks_to_scores ( $hASS );
	 }
	 else{
	 	return average_assessments_to_scores ( $hASS );
	 }
}

sub average_assessments_to_scores{
    #description _ average the list of assessments into a unique score
    #param1  _ human assessments, hash reference 

	 my $hASS = shift;

	 my %ASS = %{$hASS};
	 
    my %SCORES;
    foreach my $sys (keys %{$ASS{$Common::G_SEG}}) {
       my $sys_score = 0; my $N = 0;
       foreach my $doc (keys %{$ASS{$Common::G_SEG}->{$sys}}) {
          my $doc_score = 0; my $Ndoc = 0;
          foreach my $sgm (keys %{$ASS{$Common::G_SEG}->{$sys}->{$doc}}) {
      	       my $sum = 0;
         	    foreach my $x (@{$ASS{$Common::G_SEG}->{$sys}->{$doc}->{$sgm}}) { $sum += $x; }
            	 my $score = $sum / scalar(@{$ASS{$Common::G_SEG}->{$sys}->{$doc}->{$sgm}});
	             $SCORES{$Common::G_SEG}->{$sys}->{$doc}->{$sgm} = sprintf("%10.8f", $score);
   	          $doc_score += $score;
      	       $sys_score += $score;
         	    $N++; $Ndoc++;
          }
          $SCORES{$Common::G_DOC}->{$sys}->{$doc} = sprintf("%10.8f", $doc_score / $Ndoc);
       }
       $SCORES{$Common::G_SYS}->{$sys} = sprintf("%10.8f", $sys_score / $N);
    }

    foreach my $sys (keys %{$ASS{$Common::G_DOC}}) {
       my $sys_score = 0; my $N = 0;
       foreach my $doc (keys %{$ASS{$Common::G_DOC}->{$sys}}) {
      	    my $sum = 0;
         	 foreach my $x (@{$ASS{$Common::G_DOC}->{$sys}->{$doc}}) { $sum += $x; }
	          my $score = $sum / scalar(@{$ASS{$Common::G_DOC}->{$sys}->{$doc}});
   	       $SCORES{$Common::G_DOC}->{$sys}->{$doc} = sprintf("%10.8f", $score);
      	    $sys_score += $score;
         	 $N++;
       }
       if (!exists($SCORES{$Common::G_SYS}->{$sys})) {
          $SCORES{$Common::G_SYS}->{$sys} = sprintf("%10.8f", $sys_score / $N);
       }
    }

    foreach my $sys (keys %{$ASS{$Common::G_SYS}}) {
	       my $sum = 0;
   	    foreach my $x (@{$ASS{$Common::G_SYS}->{$sys}}) { $sum += $x; }
      	 my $score = $sum / scalar(@{$ASS{$Common::G_SYS}->{$sys}});
	       $SCORES{$Common::G_SYS}->{$sys} = sprintf("%10.8f", $score);
    }

    #print "------------- scores content\n";
    #print Dumper \%SCORES;
    #exit;
    
    return \%SCORES;   
}


sub average_ranks_to_scores{
    #description _ average the list of ranks into a unique score (percent of times that was the winner of the ranking)
    #param1  _ human rankings, hash reference [doc][seg][rankId][sys] -> rank 

	 my $hASS = shift;

	 my %ASS = %{$hASS};
	 
    my %SCORES;
    my %systimeswinner;
    my $N=0;
	 foreach my $doc (keys %{$ASS{$Common::G_SEG}}) {
	 	my %doctimeswinner;
	 	my $Ndoc=0;
		foreach my $seg (keys %{$ASS{$Common::G_SEG}->{$doc}}) {
			my %segtimeswinner;
			my $Nseg=0;
			foreach my $rnk (keys %{$ASS{$Common::G_SEG}->{$doc}->{$seg}} ) {
				#look for the winners
				my @syswins;
				my $scrwins = 0;
				foreach my $sys ( keys %{$ASS{$Common::G_SEG}->{$doc}->{$seg}->{$rnk}} ) {
					my $score = $ASS{$Common::G_SEG}->{$doc}->{$seg}->{$rnk}->{$sys};
					if( $score > $scrwins ){
						$syswins[0] = $sys;
						$scrwins = $score;
					}
					elsif ( $score == $scrwins ){
						push ( @syswins, $sys);
					}
				}

				# add++ to the winners
				for my $sysidx ( 0 .. scalar(@syswins)-1 ){
					my $sysname = $syswins[$sysidx];
					if ( defined ($segtimeswinner{$sysname}) ){ $segtimeswinner{$sysname}++; }
					else { $segtimeswinner{$sysname}=1; } 
					if ( defined ($doctimeswinner{$sysname}) ){ $doctimeswinner{$sysname}++; }
					else { $doctimeswinner{$sysname}=1; } 
					if ( defined ($systimeswinner{$sysname}) ){ $systimeswinner{$sysname}++; }
					else { $systimeswinner{$sysname}=1; } 
				}
				$Nseg++; $Ndoc++; $N++;				
         }
         # %times that winned the rank
         foreach my $sysname ( keys %segtimeswinner ){
         	$SCORES{$Common::G_SEG}->{$sysname}->{$doc}->{$seg} =  sprintf("%10.8f", $segtimeswinner{$sysname} / $Nseg);
         }
       } # fi foreach seg
       # %times that winned in the doc
       foreach my $sysname ( keys %doctimeswinner ){
       	$SCORES{$Common::G_DOC}->{$sysname}->{$doc} =  sprintf("%10.8f", $doctimeswinner{$sysname} / $Ndoc);
      }
    }
    foreach my $sysname ( keys %systimeswinner ){
    	$SCORES{$Common::G_SYS}->{$sysname} =  sprintf("%10.8f", $systimeswinner{$sysname} / $N);
    }

    #print "------------- scores content\n";
    #print Dumper \%SCORES;
    #exit;

    return \%SCORES;   
}



sub get_system_names($) {
	my $config = shift;

    my %names;
    foreach my $system (@{$config->{systems}}) { $names{$system} = $system; }
    
    return \%names;
}

sub select($$) {
	my $config = shift;
	my $G = shift;

    if (!exists($config->{"avgassessments"})) { die "[ERROR] assessments file not defined!!\n"; }

    my %assessments; 
    my $system_names = get_system_names($config);
	 
    if ($G eq $Common::G_SYS) {
       foreach my $sys (keys %{$config->{avgassessments}->{$G}}) {
          if (exists($system_names->{$sys})) { $assessments{$sys} = $config->{avgassessments}->{$G}->{$sys};}
       }
    }
    elsif ($G eq $Common::G_DOC) {
       foreach my $sys (keys %{$config->{avgassessments}->{$G}}) {
          if (exists($system_names->{$sys})) {
             foreach my $doc (sort keys %{$config->{avgassessments}->{$G}->{$sys}}) {
             	$assessments{$sys.$Common::ID_SEPARATOR.$doc} = $config->{avgassessments}->{$G}->{$sys}->{$doc};
             }
          }
       }
    }
    elsif ($G eq $Common::G_SEG) {
       foreach my $sys (keys %{$config->{avgassessments}->{$G}}) {
          if (exists($system_names->{$sys})) {
             foreach my $doc (sort keys %{$config->{avgassessments}->{$G}->{$sys}}) {
                foreach my $sgm (sort keys %{$config->{avgassessments}->{$G}->{$sys}->{$doc}}) {
             	   $assessments{$sys.$Common::ID_SEPARATOR.$doc.$Common::ID_SEPARATOR.$sgm} = $config->{avgassessments}->{$G}->{$sys}->{$doc}->{$sgm};
                }
             }
          }
       }
    }
    else { die "[ERROR] unknown granularity <", $G, ">!\n"; }

    return \%assessments;
}

sub system_select($$) {
	my $config = shift;
	my $G = shift;
    
    my %assessments; 
    my $system_names = get_system_names($config);

    if ($G eq $Common::G_SYS) {
       foreach my $sys (keys %{$config->{avgassessments}->{$G}}) {
          if (exists($system_names->{$sys})) { $assessments{$Common::G_SYS}->{$sys} = $config->{avgassessments}->{$G}->{$sys}; }
          #else{ print "no existeix $sys\n";}
       }
    }
    elsif ($G eq $Common::G_DOC) {
       foreach my $sys (keys %{$config->{avgassessments}->{$G}}) {
          if (exists($system_names->{$sys})) {
             foreach my $doc (sort keys %{$config->{avgassessments}->{$G}->{$sys}}) {
             	$assessments{$doc}->{$sys} = $config->{avgassessments}->{$G}->{$sys}->{$doc};
             }
          }
       }
    }
    elsif ($G eq $Common::G_SEG) {
       foreach my $sys (keys %{$config->{avgassessments}->{$G}}) {
          if (exists($system_names->{$sys})) {
             foreach my $doc (sort keys %{$config->{avgassessments}->{$G}->{$sys}}) {
                foreach my $sgm (sort keys %{$config->{avgassessments}->{$G}->{$sys}->{$doc}}) {
             	   $assessments{$doc.$Common::ID_SEPARATOR.$sgm}->{$sys} = $config->{avgassessments}->{$G}->{$sys}->{$doc}->{$sgm};
                }
             }
          }
       }
    }
    else { die "[ERROR] unknown granularity <", $G, ">!\n"; }
    
    return \%assessments;
}

sub multirank_select($$) {
	my $config = shift;
	my $G = shift;

   
    my %assessments; 
    my $system_names = get_system_names($config);

    if ($G eq $Common::G_SYS) {
       foreach my $sys (keys %{$system_names}) {
          if (exists($config->{avgassessments}->{$G}->{$sys}) ) { $assessments{$Common::G_SYS}->{$sys} = $config->{avgassessments}->{$G}->{$sys}; }
          else { $assessments{$Common::G_SYS}->{$sys} = 0; }
       }
    }
    elsif ($G eq $Common::G_DOC) {
       foreach my $sys (keys %{$system_names} ) {
          if ( exists($config->{avgassessments}->{$G}->{$sys}) ) {
             foreach my $doc (sort keys %{$config->{avgassessments}->{$G}->{$sys}}) {
             	$assessments{$doc}->{$sys} = $config->{avgassessments}->{$G}->{$sys}->{$doc};
             }
          }
       }
       # set the rest of the systems in the docs to 0
       foreach my $doc (keys %assessments){
       	foreach my $sys ( keys %{$system_names} ){
       		if ( !exists($assessments{$doc}->{$sys}) ) {$assessments{$doc}->{$sys} = 0; } 
       	}
       }
    }# here averaged scores are not used. Instead, we have a multi ranking for each human annotationId 
    elsif ($G eq $Common::G_SEG) {
      foreach my $doc (sort keys %{$config->{assessments}->{$G}}) {
			foreach my $sgm (sort keys %{$config->{assessments}->{$G}->{$doc}}) {
         	foreach my $ann (sort keys %{$config->{assessments}->{$G}->{$doc}->{$sgm}}) {
					foreach my $sys (keys %{$config->{assessments}->{$G}->{$doc}->{$sgm}->{$ann}}) {
        				if (exists($system_names->{$sys})) {
        					my $rnk = $config->{assessments}->{$G}->{$doc}->{$sgm}->{$ann}->{$sys};
							$assessments{$ann."##".$doc.$Common::ID_SEPARATOR.$sgm}->{$sys} = $rnk;
						}
					}
				}
			}
		}
    }
    else { die "[ERROR] unknown granularity <", $G, ">!\n"; }

    return \%assessments;
}



1;
