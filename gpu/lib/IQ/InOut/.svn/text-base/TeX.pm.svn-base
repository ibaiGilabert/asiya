package TeX;

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

sub generate_pdf {
    #description _ genereate pdf report (if applicable)
    #param1  _ configuration
    
    my $config = shift;	

    if (exists($config->{PDF}) and ($config->{TEX_REPORT} ne "")) { generate_pdf_report_from_tex($config->{TEX_REPORT}, $config->{PDF}); }
}

sub show_pdf {
    #description _ shows pdf report (if applicable)
    #param1  _ configuration
    
    my $config = shift;	

    if (exists($config->{PDF})) {
       if ((!-e $config->{PDF}) and ($config->{TEX_REPORT} ne "")) {
    	  generate_pdf_report_from_tex($config->{TEX_REPORT}, $config->{PDF});
       }
       if (-e $config->{PDF}) { system("evince $config->{PDF} &"); }
    }    
}

sub generate_pdf_report_from_tex {
    #description _ generates a pdf report file given a tex content
    #param1  _ input tex string
    #param2  _ output pdf filename
   
    my $tex = shift;
    my $out_pdf = shift;

    $out_pdf =~ s/\.pdf$//;
    my $out_dvi = $out_pdf.".dvi";
    my $out_ps = $out_pdf.".ps";
    $out_pdf .= ".pdf";
    
    srand();
    my $r = rand($Common::NRAND);
    my $tmp_tex = "REPORT.$r.tex";
    #my $tmp_dvi = "REPORT.$r.dvi";
    #my $tmp_ps = "REPORT.$r.ps";
    my $tmp_pdf = "REPORT.$r.pdf";
    my $TEX = new IO::File("> $tmp_tex") or die "Couldn't open output file: $tmp_tex\n";
   
    print $TEX
          "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n".
          "% Asiya report file\n".
          "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n".
          "\\documentclass[11pt, a4paper]{article}\n\n".
          "\\begin{document}\n\n".
 	     $tex.
 	     "\n\\end{document}\n"; 
    $TEX->close();

    system("pdflatex $tmp_tex");
    system("mv $tmp_pdf $out_pdf");
    system("rm REPORT.$r.*");
}

sub tex_metric($) {
	#description _ beautifies a given metric name for LaTeX
	#param1 _ input metric name

	my $metric = shift;

	my $tex_metric = $metric;

    my $MINUS = 0;
    if ($metric =~ /^\-.*/) { # e.g., -TER
       $metric =~ s/^\-//;
       $MINUS = 1;
    }

    my $family = $metric; $family =~ s/^([A-Z]+).*/$1/;
    my $name = $metric; $name =~ s/^[A-Z]+(.*)/$1/;
    #print "FAMILY = $family :: NAME = $name\n";

    if ($name =~ /^[a-z]+$/) { $name = "\$_{".$name."}\$"; }
    elsif ($name =~ /^p-A$/) { $name = "\$_{pA}\$"; }
    elsif ($name =~ /^\-.*/) {
       $name =~ s/([wcr])-4/$1/;
       $name =~ s/iobNIST/NIST\$_{iob}\$/;
       $name =~ s/([lpc])NIST/NIST\$_{$1}\$/;
       if ($family ne "CE") {
          $name =~ s/\-([a-z]+[PC]?)$/\$_{$1}\$/;
       }
       $name =~ s/\-([0-9]+)/\$_{$1}\$/;	
       if ($family eq "ROUGE") {
       	  $name =~ s/\-([LWl])/\$_{$1}\$/;	
          $name =~ s/\-(S[U]*)\*/\$_{$1\\star}\$/;	
       }
       $name =~ s/\(\*\)/\$\(\\star\)\$/g;	
       $name =~ s/\(\*\*\)/\$\(\\star\\star\)\$/g;	
       $name =~ s/^\-([OMM])(r[vp])/-\$$1_{$2}\$/;	
       $name =~ s/^\-([OMN])([erpcl])/-\$$1_{$2}\$/;	
       $name =~ s/_([wcr])/\$_{$1}\$/;	
    }

    $tex_metric = $family.$name;

    if ($MINUS) { $tex_metric = "-".$tex_metric; }
	
	return $tex_metric;
}

sub escape_tex($) {
	#description _ escapes LaTeX special characters in the given string --> _, %, &, {, }
	#param1 _ input string

	my $input = shift;
	
	my $string = $input;
    $string =~ s/_/\\_/g;
    $string =~ s/%/\\%/g;
    $string =~ s/&/\\&/g;
    $string =~ s/{/\\{/g;
    $string =~ s/}/\\}/g;
	
	return $string;
}

sub get_r_symbol {
	#description _ returns the LaTeX symbol for the given correlation type
    #param1  _ correlation type ('pearson' / 'spearman' / 'kendall')
	#@return _ LaTeX symbol

    my $criterion = shift;

    my $r = "r"; # C_PEARSON
    if ($criterion eq $Common::C_SPEARMAN) { $r = "\\rho"; }
    elsif ($criterion eq $Common::C_KENDALL) { $r = "\\tau"; }
    
    return $r;
}

sub get_font_size {
	#description _ returns the LaTeX font size tag for the given size value
    #param1  _ font size ('huge' / 'large' / 'normal' / 'small' / 'tiny')
	#@return _ LaTeX size tag

    my $font_size = shift;

    my $fs = "\\normalsize"; # FS_NORMAL
    if ($font_size eq $Common::FS_HUGE) { $fs = "\\huge"; }
    elsif ($font_size eq $Common::FS_LARGE) { $fs = "\\large"; }
    elsif ($font_size eq $Common::FS_SMALL) { $fs = "\\small"; }
    elsif ($font_size eq $Common::FS_TINY) { $fs = "\\tiny"; }
    
    return $fs;
}

1;
