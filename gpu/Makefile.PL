use ExtUtils::MakeMaker;
WriteMakefile(
      'NAME'              => 'Asiya',
      'VERSION_FROM'      => 'lib/IQ/Common.pm', # finds $VERSION
      'PREREQ_PM' => {
                       boolean => 0.23,
                       Modern::Perl => 1.03,
                       Getopt::Long => 2.38,
                       XML::Twig => 3.34,
                       XML::DOM => 1.44,
                       XML::Parser => 2.36,
                       XML::RegExp => 0.02,
                       Data::Dumper => 2.126,
                       IO::File => 1.14,
                       Unicode::String => 2.09,
                       File::Basename =>  2.78,
                       File::ReadBackwards => 1.04,
                       Benchmark => 1.11,
                       Statistics::Descriptive => 3.0100,
                       Statistics::Distributions => 1.02,
                       Statistics::LSNoHistory => 0.01,
                       Statistics::RankCorrelation => 0.11_3,
                       SVMTool::COMMON => 1.3,
                       Scalar::Util => 1.23,
                       List::Util => 1.23
                     }
)
