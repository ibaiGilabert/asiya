package TSDatabase;

# ------------------------------------------------------------------------

#Copyright (C) Meritxell Gonzàlez

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
use Cwd 'abs_path';


$TSDatabase::TSEARCH = "tsearch";
$TSDatabase::TSEARCHSCRIPT = "add_testbed-2.pl";


sub new {
    #description _ creates a new TSearch
    #param1  _ class name (implicit)
    #param2  _ testbed id
    #param3  _ config file
    #param3  _ datapath

    my $class = shift;     #implicit parameter
    my $testbedid = shift;
    my $configfile = shift;
    my $datapath = shift;
    my $tools = shift;

    my $tsearch = { testbedid => $testbedid, config => $configfile, datapath => $datapath, tools => $tools };

    bless $tsearch, $class;

    #call to tsearch start
    $tsearch->do_start();

    return $tsearch;
}

sub do_start {
    #description _ creates the database for the testbed
    #param1  _ object reference (implicit)

    my $tsearch = shift;

    #my $result = Tsearch::start_new_testbed($tsearch->{testbedid}, $tsearch->{config}, $tsearch->{datapath} );
    my $pathtodata = abs_path($tsearch->{datapath});
    my $command = "perl $tsearch->{tools}/$TSDatabase::TSEARCH/$TSDatabase::TSEARCHSCRIPT s $tsearch->{testbedid} $tsearch->{config} $pathtodata >&2";
    print STDERR "[TSEARCH]: creating the database for testbed $tsearch->{testbedid}\n"; 
    #print STDERR "tsearch: $command \n";
    Common::execute_or_die("$command", "[ERROR] problems running TSEARCH START...$command");
#    if ( $result < 0){
#        print STDERR "[ERROR] The system could not create the database.\n";
#        return $result;
#    } 
#    else{
     #print STDERR "start done: ". $tsearch->{testbedid} . ",". $tsearch->{config} . ", ". $tsearch->{datapath}."\n"; 
#    }
    return 0;
}

sub do_insert {
    #description _ insert the scores for a given system
    #param1  _ object reference (implicit)
    #param2  _ current system name

    my $tsearch = shift;
    my $sysname = shift;
    my $scores_path = shift;

    #print STDERR "ENTRO A INSERT $sysname\n";
    my @scorefiles = read_scores($scores_path);
    
    #my $result = Tsearch::initialize( $tsearch->{testbedid}, $tsearch->{datapath},@scorefiles);
    my $pathtodata = abs_path($tsearch->{datapath});
    my $command = "perl $tsearch->{tools}/$TSDatabase::TSEARCH/$TSDatabase::TSEARCHSCRIPT i $tsearch->{testbedid} $pathtodata $sysname >&2";
    #print STDERR "[TSEARCH]: inserting the evaluation results in the database for testbed $tsearch->{testbedid} \n";
    #print STDERR "tsearch INSERT: $command \n";
    Common::execute_or_die("$command", "[ERROR] problems running TSEARCH INSERT...$command");

#    if ( $result < 0){
#        print STDERR "[ERROR] The system could not insert the scores [$sysname].\n";
#        return $result;
#    } 
#    else{
	#print STDERR "insert done: ". $tsearch->{testbedid} . ",". $sysname . ", ". $scores_path."\n"; 
#    }
    return 0;

}

sub read_scores {

    my $directory = shift;

    #print STDERR "open directory $directory\n";
    my @listoffiles = ();

    opendir (SYSDIR, $directory) or die $!;

    while (my $refdir = readdir(SYSDIR)) {
        #print STDERR "reading $directory/$refdir \n";

        next unless (-d "$directory/$refdir");
        next if ($refdir =~ m/^\./ );

        opendir (REFDIR, "$directory/$refdir");

        while (my $scorefile = readdir(REFDIR)) {

            #print STDERR "reading score file $scorefile\n";
            next if ($scorefile =~ m/^\./ );
            next unless (-f "$directory/$refdir/$scorefile");
            next unless ( $scorefile =~ m/\.xml\.gz/ );
            push ( @listoffiles, "$directory/$refdir/$scorefile");
            
        }
        closedir (REFDIR);
    }

    closedir(SYSDIR);
    return @listoffiles;

}


sub do_finalize {
    #description _ 
    #param1  _ object reference (implicit)

    my $tsearch = shift;

    my $pathtodata = abs_path($tsearch->{datapath});
    my $command = "perl $tsearch->{tools}/$TSDatabase::TSEARCH/$TSDatabase::TSEARCHSCRIPT e $tsearch->{testbedid} $pathtodata >&2";

    #print STDERR "tsearch FINZALIZE: $command \n";
    print STDERR "[TSEARCH]: inserting the evaluation scores in the database for testbed $tsearch->{testbedid}\n";
    Common::execute_or_die("$command", "[ERROR] problems running TSEARCH INITIALIZE...$command");

#    my $result = Tsearch::insert_scores( $tsearch->{testbedid}, $tsearch->{datapath} );
#    if ( $result < 0){
#        print STDERR "[ERROR] The system could not initialize scores.\n";
#        return $result;
#    } 
#    else{
	#print STDERR "initialize done: ". $tsearch->{testbedid} . "\n"; 
#    }
    return 0;
}

1;
