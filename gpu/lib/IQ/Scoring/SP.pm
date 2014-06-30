package SP;

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
use IO::File;
use File::Basename;
use Unicode::String;
use Scalar::Util 'reftype';
use boolean ':all';
use Encode;
use SVMTool::SVMTAGGER;
use SVMTool::LEMMATIZER;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Overlap;
use IQ::Scoring::NIST;
use IQ::Scoring::BLEUNIST;
use IQ::Scoring::Metrics;

our ($SPEXT, $rSPeng, $rSPspacat, $POSSEP, $CSEP, $SVMT, $DICTS, $BIOS, $TOK, $USE_LEMMAS, $USE_DICTS);

$SP::SPEXT = "SP";
$SP::USE_LEMMAS = 1;
#$SP::USE_LEMMAS = 0;
$SP::USE_DICTS = 1;
#$SP::USE_DICTS = 0;
#$SP::USE_LOWERCASE = 1;
$SP::USE_CHUNKS = 1;
#$SP::USE_CHUNKS = 0;
$SP::POSSEP = "##";
$SP::CSEP = "__";
$SP::SVMT = "svmtool-1.3.1";
$SP::DICTS = "svmtool-1.3.1/dicts"; #fr
$SP::BIOS = "bios-1.1.0";
$SP::TOK = "tokenizer";

$SP::rLANGBIOS = { $Common::L_ENG => 'en', $Common::L_SPA => 'es', $Common::L_CAT => 'ca' };
$SP::rLANGSVM = { $Common::L_ENG => 'en', $Common::L_SPA => 'es', $Common::L_CAT => 'ca', $Common::L_FRN => 'fr' };
$SP::rLANGBKLY = { $Common::L_GER => 'de'};

$SP::rLANGTOK = { $Common::L_ENG => 'en', $Common::L_GER => 'de', $Common::L_SPA => 'es', $Common::L_CAT => 'ca' };
#, $Common::L_ARA => 'ar', $Common::L_FRN => 'fr', $Common::L_ROM => 'ro', $Common::L_CZE => 'cz', $Common::L_ITA => 'it', $Common::L_CHN => 'ch'


# SPA / CAT ---------------------------------------------------------

#AO AQ CC CS DA DD DE DI DN DP DT Faa Fat Fc Fd Fe Fg Fh Fia Fit Fp Fpa Fpt Fs Fx Fz I NC NP P0 PD PE PI PN PP PR PT PX RG RN SP VAG VAI VAM VAN VAP VAS VMG VMI VMM VMN VMP VMS VSG VSI VSM VSN VSP VSS W X Y Z Zm Zp
#A C D F I N P S V VA VM VS
#ADJP ADVP CONJP INTJ NP PP SBAR VP NEG MORFV O

$SP::rSPspacat = { "$SP::SPEXT-Oc(ADJP)" => 1, "$SP::SPEXT-Oc(ADVP)" => 1, "$SP::SPEXT-Oc(CONJP)" => 1,
                   "$SP::SPEXT-Oc(INTJ)" => 1, "$SP::SPEXT-Oc(NP)" => 1, "$SP::SPEXT-Oc(PP)" => 1,
                   "$SP::SPEXT-Oc(SBAR)" => 1, "$SP::SPEXT-Oc(VP)" => 1, "$SP::SPEXT-Oc(NEG)" => 1,
                   "$SP::SPEXT-Oc(MORFV)" => 1, "$SP::SPEXT-Oc(O)" => 1, "$SP::SPEXT-Op(AO)" => 1,
                   "$SP::SPEXT-Op(AQ)" => 1, "$SP::SPEXT-Op(CC)" => 1, "$SP::SPEXT-Op(CS)" => 1,
                   "$SP::SPEXT-Op(DA)" => 1, "$SP::SPEXT-Op(DD)" => 1, "$SP::SPEXT-Op(DE)" => 1,
                   "$SP::SPEXT-Op(DI)" => 1, "$SP::SPEXT-Op(DN)" => 1, "$SP::SPEXT-Op(DP)" => 1,
                   "$SP::SPEXT-Op(DT)" => 1, "$SP::SPEXT-Op(Faa)" => 1, "$SP::SPEXT-Op(Fat)" => 1,
                   "$SP::SPEXT-Op(Fc)" => 1, "$SP::SPEXT-Op(Fd)" => 1, "$SP::SPEXT-Op(Fe)" => 1,
                   "$SP::SPEXT-Op(Fg)" => 1, "$SP::SPEXT-Op(Fh)" => 1, "$SP::SPEXT-Op(Fia)" => 1,
                   "$SP::SPEXT-Op(Fit)" => 1, "$SP::SPEXT-Op(Fp)" => 1, "$SP::SPEXT-Op(Fpa)" => 1,
                   "$SP::SPEXT-Op(Fpt)" => 1, "$SP::SPEXT-Op(Fs)" => 1, "$SP::SPEXT-Op(Fx)" => 1,
                   "$SP::SPEXT-Op(Fz)" => 1, "$SP::SPEXT-Op(I)" => 1, "$SP::SPEXT-Op(NC)" => 1,
                   "$SP::SPEXT-Op(NP)" => 1, "$SP::SPEXT-Op(P0)" => 1, "$SP::SPEXT-Op(PD)" => 1,
                   "$SP::SPEXT-Op(PE)" => 1, "$SP::SPEXT-Op(PI)" => 1, "$SP::SPEXT-Op(PN)" => 1,
                   "$SP::SPEXT-Op(PP)" => 1, "$SP::SPEXT-Op(PR)" => 1, "$SP::SPEXT-Op(PT)" => 1,
                   "$SP::SPEXT-Op(PX)" => 1, "$SP::SPEXT-Op(RG)" => 1, "$SP::SPEXT-Op(RN)" => 1,
                   "$SP::SPEXT-Op(SP)" => 1, "$SP::SPEXT-Op(VAG)" => 1, "$SP::SPEXT-Op(VAI)" => 1,
                   "$SP::SPEXT-Op(VAM)" => 1, "$SP::SPEXT-Op(VAN)" => 1, "$SP::SPEXT-Op(VAP)" => 1,
                   "$SP::SPEXT-Op(VAS)" => 1, "$SP::SPEXT-Op(VMG)" => 1, "$SP::SPEXT-Op(VMI)" => 1,
                   "$SP::SPEXT-Op(VMM)" => 1, "$SP::SPEXT-Op(VMN)" => 1, "$SP::SPEXT-Op(VMP)" => 1,
                   "$SP::SPEXT-Op(VMS)" => 1, "$SP::SPEXT-Op(VSG)" => 1, "$SP::SPEXT-Op(VSI)" => 1,
                   "$SP::SPEXT-Op(VSM)" => 1, "$SP::SPEXT-Op(VSN)" => 1, "$SP::SPEXT-Op(VSP)" => 1,
                   "$SP::SPEXT-Op(VSS)" => 1, "$SP::SPEXT-Op(W)" => 1, "$SP::SPEXT-Op(X)" => 1,
                   "$SP::SPEXT-Op(Y)" => 1, "$SP::SPEXT-Op(Z)" => 1, "$SP::SPEXT-Op(Zm)" => 1,
                   "$SP::SPEXT-Op(Zp)" => 1, "$SP::SPEXT-Op(A)" => 1, "$SP::SPEXT-Op(C)" => 1,
                   "$SP::SPEXT-Op(D)" => 1, "$SP::SPEXT-Op(F)" => 1, "$SP::SPEXT-Op(I)" => 1,
                   "$SP::SPEXT-Op(N)" => 1, "$SP::SPEXT-Op(P)" => 1, "$SP::SPEXT-Op(S)" => 1,
                   "$SP::SPEXT-Op(V)" => 1, "$SP::SPEXT-Op(VA)" => 1, "$SP::SPEXT-Op(VM)" => 1,
                   "$SP::SPEXT-Op(VS)" => 1, "$SP::SPEXT-Op(*)" => 1, "$SP::SPEXT-Oc(*)" => 1,
                   "$SP::SPEXT-lNIST-1" => 1, "$SP::SPEXT-lNIST-2" => 1, "$SP::SPEXT-lNIST-3" => 1,
                   "$SP::SPEXT-lNIST-4" => 1, "$SP::SPEXT-lNIST-5" => 1, "$SP::SPEXT-pNIST-1" => 1,
                   "$SP::SPEXT-pNIST-2" => 1, "$SP::SPEXT-pNIST-3" => 1, "$SP::SPEXT-pNIST-4" => 1,
                   "$SP::SPEXT-pNIST-5" => 1, "$SP::SPEXT-iobNIST-1" => 1, "$SP::SPEXT-iobNIST-2" => 1,
                   "$SP::SPEXT-iobNIST-3" => 1, "$SP::SPEXT-iobNIST-4" => 1, "$SP::SPEXT-iobNIST-5" => 1,
                   "$SP::SPEXT-cNIST-1" => 1, "$SP::SPEXT-cNIST-2" => 1, "$SP::SPEXT-cNIST-3" => 1,
                   "$SP::SPEXT-cNIST-4" => 1, "$SP::SPEXT-cNIST-5" => 1, "$SP::SPEXT-lNISTi-2" => 1,
                   "$SP::SPEXT-lNISTi-3" => 1, "$SP::SPEXT-lNISTi-4" => 1, "$SP::SPEXT-lNISTi-5" => 1,
                   "$SP::SPEXT-pNISTi-2" => 1, "$SP::SPEXT-pNISTi-3" => 1, "$SP::SPEXT-pNISTi-4" => 1,
                   "$SP::SPEXT-pNISTi-5" => 1, "$SP::SPEXT-iobNISTi-2" => 1, "$SP::SPEXT-iobNISTi-3" => 1,
                   "$SP::SPEXT-iobNISTi-4" => 1, "$SP::SPEXT-iobNISTi-5" => 1, "$SP::SPEXT-cNISTi-2" => 1,
                   "$SP::SPEXT-cNISTi-3" => 1, "$SP::SPEXT-cNISTi-4" => 1, "$SP::SPEXT-cNISTi-5" => 1,
                   "$SP::SPEXT-lNIST" => 1, "$SP::SPEXT-pNIST" => 1,
                   "$SP::SPEXT-iobNIST" => 1, "$SP::SPEXT-cNIST" => 1 };

# ENG ---------------------------------------------------------------

#CC CD DT EX FW IN JJ JJR JJS LS MD NN NNP NNPS NNS PDT POS PRP PRP$ RB RBR RBS RP SYM TO UH VB VBD VBG VBN VBP VBZ WDT WP WP$ WRB # $ '' ( ) , . : ``
#J N P R V W F
#ADJP ADVP CONJP INTJ LST NP PP PRT SBAR UCP VP

$SP::rSPeng = {"$SP::SPEXT-Oc(ADJP)" => 1, "$SP::SPEXT-Oc(ADVP)" => 1, "$SP::SPEXT-Oc(CONJP)" => 1,
               "$SP::SPEXT-Oc(INTJ)" => 1, "$SP::SPEXT-Oc(LST)" => 1, "$SP::SPEXT-Oc(NP)" => 1,
               "$SP::SPEXT-Oc(O)" => 1, "$SP::SPEXT-Oc(PP)" => 1, "$SP::SPEXT-Oc(PRT)" => 1,
               "$SP::SPEXT-Oc(SBAR)" => 1, "$SP::SPEXT-Oc(UCP)" => 1, "$SP::SPEXT-Oc(VP)" => 1,
               "$SP::SPEXT-Op(CC)" => 1, "$SP::SPEXT-Op(CD)" => 1, "$SP::SPEXT-Op(DT)" => 1,
               "$SP::SPEXT-Op(EX)" => 1, "$SP::SPEXT-Op(FW)" => 1, "$SP::SPEXT-Op(IN)" => 1,
               "$SP::SPEXT-Op(JJ)" => 1, "$SP::SPEXT-Op(JJR)" => 1, "$SP::SPEXT-Op(JJS)" => 1,
               "$SP::SPEXT-Op(LS)" => 1, "$SP::SPEXT-Op(MD)" => 1, "$SP::SPEXT-Op(NN)" => 1,
               "$SP::SPEXT-Op(NNP)" => 1, "$SP::SPEXT-Op(NNPS)" => 1, "$SP::SPEXT-Op(NNS)" => 1,
               "$SP::SPEXT-Op(PDT)" => 1, "$SP::SPEXT-Op(POS)" => 1, "$SP::SPEXT-Op(PRP)" => 1,
               "$SP::SPEXT-Op(PRP\$)" => 1, "$SP::SPEXT-Op(RB)" => 1, "$SP::SPEXT-Op(RBR)" => 1,
               "$SP::SPEXT-Op(RBS)" => 1, "$SP::SPEXT-Op(RP)" => 1, "$SP::SPEXT-Op(SYM)" => 1,
               "$SP::SPEXT-Op(TO)" => 1, "$SP::SPEXT-Op(UH)" => 1, "$SP::SPEXT-Op(VB)" => 1,
               "$SP::SPEXT-Op(VBD)" => 1, "$SP::SPEXT-Op(VBG)" => 1, "$SP::SPEXT-Op(VBN)" => 1,
               "$SP::SPEXT-Op(VBP)" => 1, "$SP::SPEXT-Op(VBZ)" => 1, "$SP::SPEXT-Op(WDT)" => 1,
               "$SP::SPEXT-Op(WP)" => 1, "$SP::SPEXT-Op(WP\$)" => 1, "$SP::SPEXT-Op(WRB)" => 1,
               "$SP::SPEXT-Op(#)" => 1, "$SP::SPEXT-Op(\$)" => 1, "$SP::SPEXT-Op(\'\')" => 1,
               "$SP::SPEXT-Op(()" => 1, "$SP::SPEXT-Op())" => 1, "$SP::SPEXT-Op(,)" => 1,
               "$SP::SPEXT-Op(.)" => 1, "$SP::SPEXT-Op(:)" => 1, "$SP::SPEXT-Op(``)" => 1,
               "$SP::SPEXT-Op(J)" => 1, "$SP::SPEXT-Op(N)" => 1, "$SP::SPEXT-Op(P)" => 1,
               "$SP::SPEXT-Op(R)" => 1, "$SP::SPEXT-Op(V)" => 1, "$SP::SPEXT-Op(W)" => 1,
               "$SP::SPEXT-Op(F)" => 1, "$SP::SPEXT-Op(*)" => 1, "$SP::SPEXT-Oc(*)" => 1,
               "$SP::SPEXT-lNIST-1" => 1, "$SP::SPEXT-lNIST-2" => 1, "$SP::SPEXT-lNIST-3" => 1,
               "$SP::SPEXT-lNIST-4" => 1, "$SP::SPEXT-lNIST-5" => 1, "$SP::SPEXT-pNIST-1" => 1,
               "$SP::SPEXT-pNIST-2" => 1, "$SP::SPEXT-pNIST-3" => 1, "$SP::SPEXT-pNIST-4" => 1,
               "$SP::SPEXT-pNIST-5" => 1, "$SP::SPEXT-iobNIST-1" => 1, "$SP::SPEXT-iobNIST-2" => 1,
               "$SP::SPEXT-iobNIST-3" => 1, "$SP::SPEXT-iobNIST-4" => 1, "$SP::SPEXT-iobNIST-5" => 1,
               "$SP::SPEXT-cNIST-1" => 1, "$SP::SPEXT-cNIST-2" => 1, "$SP::SPEXT-cNIST-3" => 1,
               "$SP::SPEXT-cNIST-4" => 1, "$SP::SPEXT-cNIST-5" => 1, "$SP::SPEXT-lNISTi-2" => 1,
               "$SP::SPEXT-lNISTi-3" => 1, "$SP::SPEXT-lNISTi-4" => 1, "$SP::SPEXT-lNISTi-5" => 1,
               "$SP::SPEXT-pNISTi-2" => 1, "$SP::SPEXT-pNISTi-3" => 1, "$SP::SPEXT-pNISTi-4" => 1,
               "$SP::SPEXT-pNISTi-5" => 1, "$SP::SPEXT-iobNISTi-2" => 1, "$SP::SPEXT-iobNISTi-3" => 1,
               "$SP::SPEXT-iobNISTi-4" => 1, "$SP::SPEXT-iobNISTi-5" => 1, "$SP::SPEXT-cNISTi-2" => 1,
               "$SP::SPEXT-cNISTi-3" => 1, "$SP::SPEXT-cNISTi-4" => 1, "$SP::SPEXT-cNISTi-5" => 1,
               "$SP::SPEXT-lNIST" => 1, "$SP::SPEXT-pNIST" => 1,
               "$SP::SPEXT-iobNIST" => 1, "$SP::SPEXT-cNIST" => 1 };

# FRN ---------------------------------------------------------------
#ADJ ADJWH ADV ADVWH CC CLO CLR CLS CS DET ET I NC NPP P P+D P+PRO PONCT PREF PRO PROREL V VIMP VINF VPP VPR VS

$SP::rSPfrench = { "$SP::SPEXT-Op(ADJ)" => 1, "$SP::SPEXT-Op(ADJWH)" => 1, "$SP::SPEXT-Op(ADV)" => 1,
               "$SP::SPEXT-Op(ADVWH)" => 1, "$SP::SPEXT-Op(CC)" => 1, "$SP::SPEXT-Op(CLO)" => 1,
               "$SP::SPEXT-Op(CLR)" => 1, "$SP::SPEXT-Op(CLS)" => 1, "$SP::SPEXT-Op(CS)" => 1,
               "$SP::SPEXT-Op(DET)" => 1, "$SP::SPEXT-Op(ET)" => 1, "$SP::SPEXT-Op(I)" => 1,
               "$SP::SPEXT-Op(NC)" => 1, "$SP::SPEXT-Op(NPP)" => 1, "$SP::SPEXT-Op(P)" => 1,
               "$SP::SPEXT-Op(P+D)" => 1, "$SP::SPEXT-Op(P+PRO)" => 1, "$SP::SPEXT-Op(PONCT)" => 1,
               "$SP::SPEXT-Op(PREF)" => 1, "$SP::SPEXT-Op(PRO)" => 1, "$SP::SPEXT-Op(PROREL)" => 1,
               "$SP::SPEXT-Op(V)" => 1, "$SP::SPEXT-Op(VIMP)" => 1, "$SP::SPEXT-Op(VINF)" => 1,
               "$SP::SPEXT-Op(VPP)" => 1, "$SP::SPEXT-Op(VPR)" => 1, "$SP::SPEXT-Op(VS)" => 1,
               "$SP::SPEXT-Op(*)" => 1, 
               "$SP::SPEXT-lNIST-1" => 1, "$SP::SPEXT-lNIST-2" => 1, "$SP::SPEXT-lNIST-3" => 1,
               "$SP::SPEXT-lNIST-4" => 1, "$SP::SPEXT-lNIST-5" => 1, "$SP::SPEXT-pNIST-1" => 1,
               "$SP::SPEXT-pNIST-2" => 1, "$SP::SPEXT-pNIST-3" => 1, "$SP::SPEXT-pNIST-4" => 1,
               "$SP::SPEXT-pNIST-5" => 1, "$SP::SPEXT-lNISTi-2" => 1, "$SP::SPEXT-lNISTi-3" => 1, 
               "$SP::SPEXT-lNISTi-4" => 1, "$SP::SPEXT-lNISTi-5" => 1, "$SP::SPEXT-pNISTi-2" => 1, 
               "$SP::SPEXT-pNISTi-3" => 1, "$SP::SPEXT-pNISTi-4" => 1, "$SP::SPEXT-pNISTi-5" => 1, 
               "$SP::SPEXT-lNIST" => 1, "$SP::SPEXT-pNIST" => 1 };


$SP::rSPgerman = { "$SP::SPEXT-Op(\$*LRB*)" => 1, "$SP::SPEXT-Op(\$,)" => 1, "$SP::SPEXT-Op(\$.)" => 1, 
                   "$SP::SPEXT-Op(*T1*)" => 1, "$SP::SPEXT-Op(*T2*)" => 1, "$SP::SPEXT-Op(*T3*)" => 1, 
                   "$SP::SPEXT-Op(*T4*)" => 1, "$SP::SPEXT-Op(*T5*)" => 1, "$SP::SPEXT-Op(*T6*)" => 1, 
                   "$SP::SPEXT-Op(*T7*)" => 1, "$SP::SPEXT-Op(*T8*)" => 1, "$SP::SPEXT-Op(--)" => 1, 
                   "$SP::SPEXT-Op(ADJA)" => 1, "$SP::SPEXT-Op(ADJD)" => 1, "$SP::SPEXT-Op(ADV)" => 1, 
                   "$SP::SPEXT-Op(APPO)" => 1, "$SP::SPEXT-Op(APPR)" => 1, "$SP::SPEXT-Op(APPRART)" => 1, 
                   "$SP::SPEXT-Op(APZR)" => 1, "$SP::SPEXT-Op(ART)" => 1, "$SP::SPEXT-Op(CARD)" => 1, 
                   "$SP::SPEXT-Op(FM)" => 1, "$SP::SPEXT-Op(ITJ)" => 1, "$SP::SPEXT-Op(KOKOM)" => 1, 
                   "$SP::SPEXT-Op(KON)" => 1, "$SP::SPEXT-Op(KOUI)" => 1, "$SP::SPEXT-Op(KOUS)" => 1, 
                   "$SP::SPEXT-Op(NE)" => 1, "$SP::SPEXT-Op(NN)" => 1, "$SP::SPEXT-Op(PDAT)" => 1, 
                   "$SP::SPEXT-Op(PDS)" => 1, "$SP::SPEXT-Op(PIAT)" => 1, "$SP::SPEXT-Op(PIDAT)" => 1, 
                   "$SP::SPEXT-Op(PIS)" => 1, "$SP::SPEXT-Op(PPER)" => 1, "$SP::SPEXT-Op(PPOSAT)" => 1, 
                   "$SP::SPEXT-Op(PPOSS)" => 1, "$SP::SPEXT-Op(PRELAT)" => 1, "$SP::SPEXT-Op(PRELS)" => 1, 
                   "$SP::SPEXT-Op(PRF)" => 1, "$SP::SPEXT-Op(PROAV)" => 1, "$SP::SPEXT-Op(PTKA)" => 1, 
                   "$SP::SPEXT-Op(PTKANT)" => 1, "$SP::SPEXT-Op(PTKNEG)" => 1, "$SP::SPEXT-Op(PTKVZ)" => 1, 
                   "$SP::SPEXT-Op(PTKZU)" => 1, "$SP::SPEXT-Op(PWAT)" => 1, "$SP::SPEXT-Op(PWAV)" => 1, 
                   "$SP::SPEXT-Op(PWS)" => 1, "$SP::SPEXT-Op(TRUNC)" => 1, "$SP::SPEXT-Op(VAFIN)" => 1, 
                   "$SP::SPEXT-Op(VAIMP)" => 1, "$SP::SPEXT-Op(VAINF)" => 1, "$SP::SPEXT-Op(VAPP)" => 1, 
                   "$SP::SPEXT-Op(VMFIN)" => 1, "$SP::SPEXT-Op(VMINF)" => 1, "$SP::SPEXT-Op(VMPP)" => 1, 
                   "$SP::SPEXT-Op(VVFIN)" => 1, "$SP::SPEXT-Op(VVIMP)" => 1, "$SP::SPEXT-Op(VVINF)" => 1, 
                   "$SP::SPEXT-Op(VVIZU)" => 1, "$SP::SPEXT-Op(VVPP)" => 1, "$SP::SPEXT-Op(XY)" => 1, 
                   "$SP::SPEXT-Op(*)" => 1,
                   "$SP::SPEXT-pNIST-1" => 1, "$SP::SPEXT-pNIST-2" => 1, "$SP::SPEXT-pNIST-3" => 1, 
                   "$SP::SPEXT-pNIST-4" => 1, "$SP::SPEXT-pNIST-5" => 1, "$SP::SPEXT-pNISTi-2" => 1, 
                   "$SP::SPEXT-pNISTi-3" => 1, "$SP::SPEXT-pNISTi-4" => 1, "$SP::SPEXT-pNISTi-5" => 1, 
                   "$SP::SPEXT-pNIST" => 1 };


sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;
    if ($language eq $Common::L_ENG) { %metric_set = %{$SP::rSPeng}; }
    elsif  ($language eq $Common::L_SPA) { %metric_set = %{$SP::rSPspacat}; }
    elsif  ($language eq $Common::L_CAT) { %metric_set = %{$SP::rSPspacat}; }
    elsif  ($language eq $Common::L_FRN) { %metric_set = %{$SP::rSPfrench}; }
    elsif  ($language eq $Common::L_GER) { %metric_set = %{$SP::rSPgerman}; }
    
    return \%metric_set;
}

sub trim_string {
   #description _ performs string trimming (white spaces at the end/start of the string are removed)
   #param1  _ input string
   #@return _ trimmed string

   my $string = shift;

   $string =~ s/^\s+//g;
   $string =~ s/\s+$//g;

   return $string;
}

sub tokenize_file {
    #description _ tokenizes the given file
    #param1  _ tools directory 
    #param2  _ input file
    #param3  _ language

    my $tools = shift;
    my $file = shift;
    my $lang = shift;

    srand();
    my $r = rand($Common::NRAND);
    my $aux_file = "$Common::DATA_PATH/$Common::TMP/".basename("$file.$r");
    my $aux_file_tok = "$Common::DATA_PATH/$Common::TMP/".basename("$file.$r.tok");

    open(FILE, " < $file") or die "couldn't open input file: $file\n";
    open(FILE_AUX, " > $aux_file") or die "couldn't open output aux file: $aux_file\n";
    while (defined(my $line = <FILE>)) {
       chomp($line);
       my $newline = Common::normalize_utf8_characters(
                        Common::replace_xml_entities(
                           Common::remove_carriage_return($line)));
       if ($lang eq $Common::L_ENG) { #special cases
          #verb contractions
       	  $newline =~ s/ +' ?s +/'s /g;
       	  $newline =~ s/ +' ?re +/'re /g;
       	  $newline =~ s/ +' ?ll +/'ll /g;
       	  $newline =~ s/ +n ?' ?t +/'nt /g;
       }
       print FILE_AUX $newline, "\n";
    }
    close(FILE);
    close(FILE_AUX);
    
    my $lang_opt = "";
    if (exists($SP::rLANGTOK->{$lang})) { $lang_opt = "-l ".$SP::rLANGTOK->{$lang}; }
    
    Common::execute_or_die("cat $aux_file | $tools/$TOK/tokenizer.pl $lang_opt > $aux_file_tok 2> $aux_file_tok.err",
                           "[ERROR] problems running tokenizer...");
    system "mv $aux_file_tok $file";
    system "rm $aux_file";
    system "rm -f $aux_file_tok.err";
}

sub initialize_svmt {
    #description _ initializes the SVMTool models for languages involved
    #param1  _ tools directory pathname
    #param2  _ language
    #param3  _ case
    #param4  _ verbosity (0/1)
    #@return _ SVMTool model structure (hash reference)

    my $tools = shift;
    my $L = shift;
    my $C = shift;
    my $verbose = shift;

    my $mode = 0;
    my $direction = "LRL";
    my $lpath = "$tools/$SVMT/models/$L/$C/";
    my $lblex;

    if ($L =~ /^$Common::L_SPA.*/) {
       if ($C eq $Common::CASE_CI) { $lpath .= "Ancora_es_lc"; }
       else { $lpath .= "Ancora_es"; }
    }
    elsif ($L eq $Common::L_CAT) {
       if ($C eq $Common::CASE_CI) { $lpath .= "Ancora_ca_lc"; }
       else { $lpath .= "Ancora_ca"; }
    }
    elsif ($L eq $Common::L_ENG) {
       if ($C eq $Common::CASE_CI) { $lpath .= "WSJQB_en_lc"; }
       else { $lpath .= "WSJQB_en"; }
    }    
    elsif ($L eq $Common::L_FRN) {
       $SP::USE_DICTS = 0;
       if ($C eq $Common::CASE_CI) { $lpath .= "FTB_fr_lc"; }
       else { $lpath .= "FTB_fr"; }
    }    
    else { die "SVMTool for '$L' LANGUAGE NOT AVAILABLE!!\n"; }

    if ($SP::USE_DICTS) {
       my $l = substr($L, 0, 2);
       $lblex = "$tools/$DICTS/$l/backup_lexicon.DICT";
    }

    if ($verbose > 1) { print STDERR "<[SVMTool] initializing PoS-tagger [$L] ...>\n"; }
    return SVMTAGGER::SVMT_load($lpath, $mode, $direction, 0, 0, $lblex, $verbose);

    #other backup lexicons [from maco lemma]
    #$tools/SVMT/spa-X/maco.spa.SVMT.DICT"
    #$tools/SVMT/cat-X/maco.cat.SVMT.DICT"
    #$tools/SVMT/eng.lc/maco.eng.SVMT.DICT"
}

sub initialize_lemmatizer
{
    #description _ initializes the LT models for languages involved
    #param1  _ tools directory pathname
    #param2  _ language
    #param3  _ verbosity (0/1)
    #@return _ LT model structure (hash reference)

    my $tools = shift;
    my $L = shift;
    my $verbose = shift;

    my $lt;
    if (exists($SP::rLANGSVM->{$L})) {
       my $ldict = "$tools/$DICTS/$L/lemmas.txt";
       if ($verbose > 1) { print STDERR "<[LT] initializating lemmatizer [$L] ...>\n"; } 
       $lt = LEMMATIZER::LT_load($ldict, $verbose);
    }  
    else { die "LEMMATIZATION for '$L' LANGUAGE NOT AVAILABLE!!\n"; }
    
    return $lt;
}

sub PoS_tag {
    #description _ responsible for monolingual shallow parsing a given input sentence
    #             (WORD + PoS + LEMMA) tagging  [no chunking!]
    #param1  _ shallow parser (hash ref)
    #param2  _ input sentence (white-space tokenized)
    #param3  _ sentence id (for chunking only)
    #@return _ parsed sentence (structure)

    my $PARSER = shift;
    my $sentence = shift;
    my $id = shift;

    my $lang = $PARSER->{LANG};
    
    # Tokenization ------------------------------------------------------
    chomp($sentence);
    my @tokens = split(" ", $sentence);

    # PoS-tagging -------------------------------------------------------
    my @PoS;
    my $direction = "LR";    #direction mode (LR/RL/LRL)
    my $mode = 0;            #mode (tagging strategy)
    my $nbeams = -1;         #beam count cutoff (only applicable under strategy 3)
    my $bratio = 0;          #beam count cutoff (only applicable under strategy 3)
    my $softmax = 1;         #softmax function
    my $svmt;

    my $in = SVMTAGGER::SVMT_prepare_input(\@tokens);
    my ($res, $time) = SVMTAGGER::SVMT_tag($mode, $nbeams, $bratio, $softmax, $direction, $in, $PARSER->{svmt}, 0);
    my $i = 0;
    while ($i < scalar(@{$in})) {
       push(@PoS, $res->[$i]->get_pos);
       $i++;
    }

    # lemmatization ------------------------------------------------------
    my @lemmas;
    $i = 0;
    while ($i < scalar(@tokens)) {
       if ($SP::USE_LEMMAS) {
          my $lemma = LEMMATIZER::LT_tag($PARSER->{lemmatizer}, $tokens[$i], $PoS[$i]);
          push(@lemmas, $lemma);
       }
       else { push(@lemmas, $tokens[$i]); }
       $i++;
    }

    my @RESwp; my @RESwpl;
    $i = 0;
    while ($i < scalar(@tokens)) {
       push(@RESwp, $tokens[$i]." ".$PoS[$i]);
       push(@RESwpl, $tokens[$i]." ".$PoS[$i]." ".$lemmas[$i]);
       $i++;
    }
    return (\@RESwp, \@RESwpl);
}

sub FILE_merge_BIOS {
   #description _ merges tokens in two files so they conform the tokenization of the first file 
   #param1 _ input file 1
   #param2 _ input file 2
   #param3 _ output file

   my $input1 = shift;
   my $input2 = shift;
   my $output = shift;

   open(INPUT1, "< $input1") or die "couldn't open input 1bios file: $input1\n";
   open(INPUT2, "< $input2") or die "couldn't open input 2biox file: $input2\n";
   open(OUTPUT, "> $output") or die "couldn't open output bio file: $output\n";

   my $EMPTY = 1;
   while (defined(my $line1 = <INPUT1>)) {
      if ($line1 =~ /^$/) {
         if ($EMPTY) { # empty sentence
            $EMPTY = 0;
         }
         else { #sentence separator      
            $EMPTY = 1;
         }
         print OUTPUT "\n";
      }
      else {
         my $line2 = <INPUT2>;
         if ($line2 =~ /^$/) { #line2 is empty
            $line2 = <INPUT2>;
         }
         chomp($line1); chomp($line2);
         my @l1 = split(" ", $line1); my @l2 = split(" ", $line2);
         shift(@l2);  ## remove first field of list2
         #if ($l1[0] eq $l2[0]) { shift(@l2); } ## remove first field of list2 (only if it matches first field of list1)
         print OUTPUT join(" ", @l1)." ".join(" ", @l2)."\n";
         $EMPTY = 0;
      }
   }
   close(INPUT1);
   close(INPUT2);
   close(OUTPUT);
}

sub FILE_parse_split {
   #description _ performs the shallow parsing and writes 5 different files (used as input for SP metrics computation)
   #              (ALL_WPLC, PoS, lemma, chunk label, chunk)
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)
   #@return _ list of (shallow-)parsed sentences

   my $input = shift;
   my $PARSER = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   my %parser;

   #check whether chunks were calculated
   my $use_chunks = (exists($SP::rLANGBIOS->{$L})) ? 1: 0 ;
   
   #wplc or wpl 
   my $spfile = ($use_chunks) ? $input.".$SP::SPEXT.wplc" : $input.".$SP::SPEXT.wpl";
   if (!(-e $spfile)) {
      if (-e "$spfile.$Common::GZEXT") { system("$Common::GUNZIP $spfile.$Common::GZEXT"); }
      else { SP::FILE_parse($input, $PARSER, $tools, $L, $C, $verbose); }
   }
   
   my $pfile = $input.".$SP::SPEXT.P";
   my $lfile = $input.".$SP::SPEXT.L";
   my $cfile = $input.".$SP::SPEXT.iob";
   my $Cfile = $input.".$SP::SPEXT.C";
   if (  ((!(-e $pfile)) and (!(-e $pfile.".$Common::GZEXT"))) or # P file does not exist
         ((!(-e $lfile)) and (!(-e $lfile.".$Common::GZEXT"))) or # L file does not exist
         ((!(-e $cfile)) and (!(-e $cfile.".$Common::GZEXT")) and $use_chunks) or # iob file does not exist
         ((!(-e $Cfile)) and (!(-e $Cfile.".$Common::GZEXT")) and $use_chunks) # C file does not exist
      ) {
      
      #open files   
      open(SPFILE, "< $spfile") or die "couldn't open file: $spfile\n";
      open(pFILE, "> $pfile") or die "couldn't open output pFILE file: $pfile\n";
      open(lFILE, "> $lfile") or die "couldn't open output lFILE file: $lfile\n";
      if ($use_chunks) { open(cFILE, "> $cfile") or die "couldn't open output cFILE file: $cfile\n"; }
      if ($use_chunks) { open(CFILE, "> $Cfile") or die "couldn't open output CFILE file: $Cfile\n"; }
      
      #process SPFILE
      my @Lp; my @Ll; my @Lc; my @LC;
      my $EMPTY = 1;
      while (my $line = <SPFILE>) {
      	chomp($line);
         if ($line =~ /^$/) {
            if ($EMPTY) { # empty sentence
	           $EMPTY = 0;
            }
            else { #sentence separator      
               print pFILE join(" ", @Lp), "\n";
               print lFILE join(" ", @Ll), "\n";
               if ($use_chunks) { print cFILE join(" ", @Lc), "\n"; }
               if ($use_chunks) { print CFILE join(" ", @LC), "\n"; }
               $EMPTY = 1;
               @Lp = (); @Ll = (); @Lc = (); @LC = ();
           }
         }
         else {
            chomp($line);
            my @l = split(" ", $line);
            push(@Lp, $l[1]);
            push(@Ll, $l[2]);
            if ($use_chunks) { push(@Lc, $l[3]); }
            if ($use_chunks and $l[3] eq "O") { push(@LC, $l[3]); }
            elsif ($use_chunks and $l[3] =~ /B-.*/) { my @C = split("-", $l[3]); push(@LC, $C[1]); }
	         $EMPTY = 0;
         }
      }
      #close files
      close(SPFILE);
      close(pFILE);
      close(lFILE);
      if ($use_chunks) { close(cFILE); }
      if ($use_chunks) { close(CFILE); }
   }
   system("$Common::GZIP $spfile");
}



sub FILE_parse_SVM {
   #description _ performs the shallow parsing and writes a several files (using SVMTool)
   #              (wplc -> TOKEN PoS LEMMA CHUNK)
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)
   #@return  _ number of lines processed
   
   my $input = shift;
   my $parser = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   if (!keys %{$parser}) {
      SP::start_parser($tools, $L, $C, $parser, 0, (($verbose > 0)? $verbose - 1 : 0));
   }

   my $wpfile = $input.".$SP::SPEXT.wp";
   my $wplfile = $input.".$SP::SPEXT.wpl";
   my $conllfile = $input.".$SP::SPEXT.conll";
      
   open(INPUT, "< $input") or die "couldn't open input file: $input\n";
   open(WPFILE, "> $wpfile") or die "couldn't open output WPFILE file: $wpfile\n";
   open(WPLFILE, "> $wplfile") or die "couldn't open output WPLFILE file: $wplfile\n";
   open(CONLLFILE, "> $conllfile") or die "couldn't open output CONLLFILE file: $conllfile\n";

   my $iter = 0;
   while (my $line = <INPUT>) {
      chomp($line);
      my ($resWP, $resWPL) = SP::PoS_tag($parser, $line, $iter);
      print WPFILE join("\n", @{$resWP})."\n\n";
      print WPLFILE join("\n", @{$resWPL})."\n\n";
      
      my $wcount = 1;
      foreach my $line (@{$resWPL}) {
        $line =~ s/  / /g;
        my ($w, $p, $l) = split(" ", $line);
   	  print CONLLFILE "$wcount\t$w\t$l\t".substr($p, 0, 1)."\t$p\t_\n";
   	  $wcount++;
      }
      print CONLLFILE "\n";

      if ($verbose > 1) {
         if (($iter%10) == 0) { print STDERR "."; }
         if (($iter%100) == 0) { print STDERR $iter; }
      }
      $iter++;
   }
   close(INPUT);
   close(WPFILE);
   close(WPLFILE);
   close(CONLLFILE);

   return $iter;
}


sub BKLY_extract_POS {
   #description _ extracts the pos from the berkeley trees
   #param1  _ berkeley tree
   #@return _ array of wpl for each token

   my $segment = shift;
   
   my $wp; my $wpl;
   
   if (defined($segment->[2])) { #node, recursive call
      my $children = $segment->[2];
      my @arwp;
      my @arwpl;
      foreach my $child (@{$children}) {
         if (defined($child) ){
            ($wp,$wpl)  = BKLY_extract_POS($child);
         }
         if ( ref($wp) eq 'ARRAY' ){ # array
            push(@arwp, @{$wp});
            push(@arwpl,@{$wpl});
         }
         else{ # string
            push(@arwp, $wp." ".$segment->[0]);
            push(@arwpl,$wp." ".$segment->[0]." "."-");
         }
      }
      $wp = \@arwp;
      $wpl = \@arwpl;
   }
   else{ #leave, extract the word
      $wp = $segment->[0];
      $wpl = "";
   }
  
   return ($wp,$wpl);
}

sub FILE_parse_BKLY {
   #description _ performs the constituency parsing with berkeleyparser and then extracts the shallow parsing informations and writes a several files
   #              (wplc -> TOKEN PoS LEMMA CHUNK)
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)
   #@return  _ number of lines processed
   
   my $input = shift;
   my $parser = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   #parse with BERKELEY
   my $Pout = CP::parse_FULL($tools, $L, $C, $input, $parser, (($verbose > 0)? $verbose - 1 : 0));

   #print STDERR Dumper $Pout;

   my $wpfile = $input.".$SP::SPEXT.wp";
   my $wplfile = $input.".$SP::SPEXT.wpl";
   my $conllfile = $input.".$SP::SPEXT.conll";
   
   open(WPFILE, "> $wpfile") or die "couldn't open output WPFILE file: $wpfile\n";
   open(WPLFILE, "> $wplfile") or die "couldn't open output WPLFILE file: $wplfile\n";
   open(CONLLFILE, "> $conllfile") or die "couldn't open output CONLLFILE file: $conllfile\n";
   
   
   my $iter = 0;
   if (defined($Pout)) {
      foreach my $segment (@{$Pout}) {
         my ($resWP,$resWPL) = BKLY_extract_POS($segment);
         #print STDERR Dumper $resWP;
         print WPFILE join("\n", @{$resWP})."\n\n";
         print WPLFILE join("\n", @{$resWPL})."\n\n";
            
         my $wcount = 1;
         foreach my $line (@{$resWPL}) {
	         my ($w, $p, $l) = split(/\s/, $line);
	         print CONLLFILE "$wcount\t$w\t$l\t".substr($p, 0, 1)."\t$p\t_\n";
	         $wcount++;
         }
         print CONLLFILE "\n";
         if ($verbose > 1) {
            if (($iter%10) == 0) { print STDERR "."; }
            if (($iter%100) == 0) { print STDERR $iter; }
         }
         $iter++;
      }
   }
   close(WPFILE);
   close(WPLFILE);
   close(CONLLFILE);
   
   return $iter;
}

sub FILE_parse_BIOS {
   #description _ performs the shallow parsing and writes a several files (using SVMTool)
   #              (wplc -> TOKEN PoS LEMMA CHUNK)
   #param1  _ input file
   #param2  _ TOOL directory
   #param3  _ language
   #param4  _ case

   my $input = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;

   my $wplcfile = $input.".$SP::SPEXT.wplc";
   my $wpfile = $input.".$SP::SPEXT.wp";
   my $wplfile = $input.".$SP::SPEXT.wpl";

   my $wcfile = $input.".$SP::SPEXT.wc";
   if ((!(-e $wcfile)) and (!(-e "$wcfile.$Common::GZEXT"))) {
      if ((!(-e $wpfile)) and (-e "$wpfile.$Common::GZEXT")) { system("$Common::GUNZIP $wpfile.$Common::GZEXT"); }
      my $command = "cat $wpfile | java -Dfile.encoding=UTF-8 -Xmx1024m -cp $tools/$BIOS/output/classes/:".
                             "$tools/mill/output/classes:$tools/$BIOS/jars/maxent-2.3.0.jar:".
                             "$tools/$BIOS/jars/trove.jar:$tools/$BIOS/jars/antlr-2.7.5.jar:".
                             "$tools/$BIOS/jars/log4j.jar bios.chunker.Chunker".
                             " --predict --data=$tools/$BIOS/data/chunker/".$SP::rLANGBIOS->{$L}.
                             " --model=conll.paum.".(($C eq $Common::CASE_CI)? "ci" : "cs").".model".
                             " --type=paum --case-sensitive=".(($C eq $Common::CASE_CI)? "false" : "true").
                             " --log4j=$tools/$BIOS/log4j.properties > $wcfile 2> $wcfile.err";
      Common::execute_or_die($command, "[ERROR] problems running BIOS...");

      system("rm -f $wcfile.err");

      my $wpcfile = $input.".$SP::SPEXT.wpc";
      #merging tagging + chunking
      SP::FILE_merge_BIOS($wpfile, $wcfile, $wpcfile);
      #merging tagging + lemma + chunking
      if ((!(-e $wplfile)) and (-e "$wplfile.$Common::GZEXT")) { system("$Common::GUNZIP $wplfile.$Common::GZEXT"); }
      SP::FILE_merge_BIOS($wplfile, $wcfile, $wplcfile);
   }
}

sub FILE_parse {
   #description _ performs the shallow parsing and writes a several files (using SVMTool and BIOS)
   #              (wplc -> TOKEN PoS LEMMA CHUNK)
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)

   my $input = shift;
   my $parser = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   my $use_chunks = ( exists($SP::rLANGBIOS->{$L}) ) ? 1 : 0;
   
   if (exists($SP::rLANGSVM->{$L}) || exists($SP::rLANGBKLY->{$L}) ) {

      my $spfile = ($use_chunks) ? $input.".$SP::SPEXT.wplc" : $input.".$SP::SPEXT.wpl";

      if ((!(-e $spfile)) and (!(-e "$spfile.$Common::GZEXT"))) {
         my $wpfile = $input.".$SP::SPEXT.wp";
         my $wplfile = $input.".$SP::SPEXT.wpl";
         my $conllfile = $input.".$SP::SPEXT.conll";
         if ((!(-e $wpfile)) and (!(-e "$wpfile.$Common::GZEXT"))) {
            #tokenizing + tagging via SVMTool (en, ca, es) or Berkeley (fr, de)
            if ($verbose > 1) { print STDERR "running shallow-parsing [$wpfile -> $wpfile]\n"; }
            my $iter = 0;
            if (exists($SP::rLANGSVM->{$L}) ){
               $iter = FILE_parse_SVM($input, $parser, $tools, $L, $C, $verbose);
            }
            elsif (exists($SP::rLANGBKLY->{$L}) ) {            
               $SP::USE_LEMMAS = 0;
               $iter = FILE_parse_BKLY($input, $parser, $tools, $L, $C, $verbose);
            }

            if ($verbose > 1) { print STDERR "..", $iter, " segments [DONE]\n"; }
         }

         #chunking via BIOS
         if ($use_chunks) {
            my $wcfile = $input.".$SP::SPEXT.wc";
            my $wpcfile = $input.".$SP::SPEXT.wpc";
            FILE_parse_BIOS($input, $tools, $L, $C);
            #end - gzip the files
            system("$Common::GZIP $wpcfile");
            system("$Common::GZIP $wcfile");
         }
         #else { die "[ERROR] Chunker not available for '$L' language!!\n"; }
         
         #end - gzip the files, DON'T zip before because bios use them!
         system("$Common::GZIP $wpfile");
         system("$Common::GZIP $wplfile");
         system("$Common::GZIP $conllfile");
      }      
   }
   else { die "[ERROR] Shallow parser not available for '$L' language!!\n"; }
}


sub FILE_parse_and_read {
   #description _ reads "wplc or wpl" file, performing the shallow parsing (using SVMTool and BIOS) only if required
   #              (wplc -> TOKEN PoS LEMMA CHUNK)
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)
   #@return _ list of (shallow-)parsed sentences

   my $input = shift;
   my $parser = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   my @FILE;
   SP::FILE_parse($input, $parser, $tools, $L, $C, $verbose);

   #WPLC
   my $spfile = $input.".$SP::SPEXT.wplc";
   if ( (!(-e $spfile)) and (!(-e "$spfile.$Common::GZEXT")) ){
      #WPL (without C)
      $spfile = $input.".$SP::SPEXT.wpl";
   }
   #unzip
   if ((!(-e $spfile)) and (-e "$spfile.$Common::GZEXT")) { system("$Common::GUNZIP $spfile.$Common::GZEXT"); }
   
   open(SPFILE, "< $spfile") or die "couldn't open file: $spfile\n";
   my $i = 0;
   while (my $line = <SPFILE>) {
      if ($line =~ /^$/) { # sentence separator
         $i++;
      }
      else {
         if (!defined($FILE[$i])) { @{$FILE[$i]} = (); }
         chomp($line);
         my @elem = split(" ", $line);
         push(@{$FILE[$i]}, \@elem);
      }
   }
   close(SPFILE);

   system("$Common::GZIP $spfile");

   return \@FILE;
}

sub create_PoS_file($$$$$$) {
   #description _ creates a one-sentence per line PoS file, and returns its name
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)
   #@return _ PoS file name

   my $input = shift;
   my $parser = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   my $wplcfile = $input.".$SP::SPEXT.wplc";
   my $pfile = $input.".$SP::SPEXT.pos";
   
   if (!(-e $pfile)) {
   	  if (-e "$pfile.$Common::GZEXT") { system("$Common::GUNZIP $pfile.$Common::GZEXT"); }
   	  else {
         SP::FILE_parse($input, $parser, $tools, $L, $C, $verbose);

         if ((!(-e $wplcfile)) and (-e "$wplcfile.$Common::GZEXT")) { system("$Common::GUNZIP $wplcfile.$Common::GZEXT"); }

         open(P, "> $pfile") or die "couldn't open file: $pfile\n";
         open(WPLC, "< $wplcfile") or die "couldn't open file: $wplcfile\n";
         my $i = 0;
         my @sentence;
         my $EMPTY = 1;
         while (my $line = <WPLC>) {
            if ($line =~ /^$/) { # sentence separator
               if ($EMPTY) { # empty sentence
	              $EMPTY = 0;
               }
               else {
               	  print P join(" ", @sentence), "\n";
                  @sentence = ();
                  $EMPTY = 1;
               }
            }
            else {
               chomp($line);
               my @elem = split(" ", $line);
               push(@sentence, $elem[1]);
   	           $EMPTY = 0;
            }
         }
         close(WPLC);
         close(P);
         system("$Common::GZIP $wplcfile");
   	  }	
   }

   return $pfile;
}

sub create_lemma_file($$$$$$) {
   #description _ creates a one-sentence per line lemma file, and returns its name
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)
   #@return _ lemma file name

   my $input = shift;
   my $parser = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   my $wplcfile = $input.".$SP::SPEXT.wplc";
   my $lfile = $input.".$SP::SPEXT.lemma";
   
   if (!(-e $lfile)) {
   	  if (-e "$lfile.$Common::GZEXT") { system("$Common::GUNZIP $lfile.$Common::GZEXT"); }
   	  else {
         SP::FILE_parse($input, $parser, $tools, $L, $C, $verbose);

         if ((!(-e $wplcfile)) and (-e "$wplcfile.$Common::GZEXT")) { system("$Common::GUNZIP $wplcfile.$Common::GZEXT"); }

         open(L, "> $lfile") or die "couldn't open file: $lfile\n";
         open(WPLC, "< $wplcfile") or die "couldn't open file: $wplcfile\n";
         my $i = 0;
         my @sentence;
         my $EMPTY = 1;
         while (my $line = <WPLC>) {
            if ($line =~ /^$/) { # sentence separator
               if ($EMPTY) { # empty sentence
	              $EMPTY = 0;
               }
               else {
               	  print L join(" ", @sentence), "\n";
                  @sentence = ();
                  $EMPTY = 1;
               }
            }
            else {
               chomp($line);
               my @elem = split(" ", $line);
               push(@sentence, $elem[2]);
   	           $EMPTY = 0;
            }
         }
         close(WPLC);
         close(L);
         system("$Common::GZIP $wplcfile");
   	  }	
   }

   return $lfile;
}

sub create_chunk_file($$$$$$) {
   #description _ creates a one-sentence per line Chunk file, and returns its name
   #param1  _ input file
   #param2  _ parser object
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ verbosity (0/1)
   #@return _ Chunk file name

   my $input = shift;
   my $parser = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $verbose = shift;

   my $wplcfile = $input.".$SP::SPEXT.wplc";
   my $cfile = $input.".$SP::SPEXT.chunks";
   
   if (!(-e $cfile)) {
   	  if (-e "$cfile.$Common::GZEXT") { system("$Common::GUNZIP $cfile.$Common::GZEXT"); }
   	  else {
         SP::FILE_parse($input, $parser, $tools, $L, $C, $verbose);

         if ((!(-e $wplcfile)) and (-e "$wplcfile.$Common::GZEXT")) { system("$Common::GUNZIP $wplcfile.$Common::GZEXT"); }

         open(C, "> $cfile") or die "couldn't open file: $cfile\n";
         open(WPLC, "< $wplcfile") or die "couldn't open file: $wplcfile\n";
         my $i = 0;
         my @sentence;
         my $EMPTY = 1;
         while (my $line = <WPLC>) {
            if ($line =~ /^$/) { # sentence separator
               if ($EMPTY) { # empty sentence
	              $EMPTY = 0;
               }
               else {
               	  print C join(" ", @sentence), "\n";
                  @sentence = ();
                  $EMPTY = 1;
               }
            }
            else {
               chomp($line);
               my @l = split(" ", $line);
               if ($l[3] =~ /B-.*/) { my @C = split("-", $l[3]); push(@sentence, $C[1]); }
   	           $EMPTY = 0;
            }
         }
         close(WPLC);
         close(C);
         system("$Common::GZIP $wplcfile");
   	  }	
   }

   return $cfile;
}


sub parse {
    #description _ responsible for monolingual shallow parsing a given input sentence
    #             (WORD + PoS + LEMMA) tagging
    #param1  _ shallow parser (hash ref)
    #param2  _ input sentence (white-space tokenized)
    #param3  _ sentence id (for chunking only)
    #param4  _ which components should be run?  [0: all, 1:PoS-tagger, 2:+lemmatizer, 3:+chunker]
    #@return _ parsed sentence (structure)

    my $PARSER = shift;
    my $sentence = shift;
    my $id = shift;
    my $which = shift;

    chomp($sentence);
    my @tokens = split(" ", $sentence);

    # PoS-tagging -------------------------------------------------------
    my @PoS;
    my $direction = "LR";    #direction mode (LR/RL/LRL)
    my $mode = 0;            #mode (tagging strategy)
    my $nbeams = -1;         #beam count cutoff (only applicable under strategy 3)
    my $bratio = 0;          #beam count cutoff (only applicable under strategy 3)
    my $softmax = 1;         #softmax function
    my $in = SVMTAGGER::SVMT_prepare_input(\@tokens);
    my ($res, $time) = SVMTAGGER::SVMT_tag($mode, $nbeams, $bratio, $softmax, $direction, $in, $PARSER->{svmt}, 0);

    my $i = 0;
    while ($i < scalar(@{$in})) {
       push(@PoS, $res->[$i]->get_pos);
       $i++;
    }

    # lemmatization ------------------------------------------------------
    my @lemmas;
    if (($which == 0) or ($which > 1)) {
       $i = 0;
       while ($i < scalar(@tokens)) {
          if ($SP::USE_LEMMAS) { 
             my $lemma = LEMMATIZER::LT_tag($PARSER->{lemmatizer}, $tokens[$i], $PoS[$i]);
             push(@lemmas, $lemma);
          }
          else { push(@lemmas, $tokens[$i]); }
          $i++;
       }
    }

    my @RES;
    $i = 0;
    while ($i < scalar(@tokens)) {
       push(@RES, $tokens[$i].$POSSEP.$PoS[$i].((($which == 0) or ($which > 1))? $POSSEP.$lemmas[$i] : ""));
       $i++;
    }
    return join(" ", @RES);
}

sub FILE_PoS_tag_and_lemmatize {
   #description _ runs shallow-parsing of a given file (1 sentence per line)
   #              and returns the resulting tagged text (shallow-parsed file)
   #param1  _ input file
   #param2  _ shallow parser (object)
   #param3  _ TOOL directory
   #param4  _ language
   #param5  _ case
   #param6  _ which components should be run?  [0: all, 1:PoS-tagger, 2:+lemmatizer]
   #param7  _ verbosity (0/1)
   #@return _ list of (shallow-)parsed sentences

   my $input = shift;
   my $PARSER = shift;
   my $tools = shift;
   my $L = shift;
   my $C = shift;
   my $which = shift;
   my $verbose = shift;

   my %parser;

   my @FILE;

   my $file = $input.".$SP::SPEXT.W".((($which == 0) or ($which > 1))? "L" : "")."P".((($which == 0) or ($which > 2))? "C" : "").(($L =~ /.*c$/)? "c":"");

   if (!(-e $file)) {
      if (-e "$file.$Common::GZEXT") { system("$Common::GUNZIP $file.$Common::GZEXT"); }
      else {
         if ($verbose > 1) { print STDERR "running shallow-parsing [$file -> $file]\n"; }

         SP::start_parser($tools, $L, $C, \%parser, $which, (($verbose > 0)? $verbose - 1 : 0));

         open(INPUT, "< $input") or die "couldn't open input file: $input\n";
         open(FILE, "> $file") or die "couldn't open output PoS file: $file\n";
         my $iter = 0;
         while (my $line = <INPUT>) {
            chomp($line);
            $line = trim_string($line);
            if ($line ne "") {
               my $res = parse(\%parser, $line, $iter, $which);
               print FILE $res."\n";
            }
            else { print FILE "\n"; }
            if ($verbose > 1) {
               if (($iter%10) == 0) { print STDERR "."; }
               if (($iter%100) == 0) { print STDERR $iter; }
            }
            $iter++;
         }
         close(INPUT);
         close(FILE);
         if ($verbose > 1) { print STDERR "..", $iter, " segments [DONE]\n"; }
      }
   }

   open(AUX, "< $file") or die "couldn't open file: $file\n";
   while (my $line = <AUX>) {
      chomp($line);
      my @snt;
      foreach my $elem (split(" ", $line)) {
         my @laux = split($POSSEP, $elem);
         push(@snt, \@laux);
      }
      push(@FILE, \@snt);
   }
   close(AUX);

   #print "*****************************\n";
   #print Dumper \@FILE;
   #print "*****************************\n";

   #print "### TOPICS = ", scalar(@FILE), "\n";

   system("$Common::GZIP $file");

   return \@FILE;
}

sub start_parser
{
    #description _ responsible for starting the shallow parser  [allowing for loading individual components]
    #              (WORD + PoS + LEMMA) tagging
    #param1  _ tools directory pathname
    #param2  _ language
    #param3  _ case
    #param4  _ PARSER object (hash ref)    [in/out]
    #param5  _ which components should be loaded?  [0: all, 1:PoS-taggers, 2:+lemmatizers]
    #param6  _ verbosity (0/1)

    my $tools = shift;
    my $L = shift;
    my $C = shift;
    my $PARSER = shift;
    my $which = shift;
    my $verbose = shift;

    if ($verbose) { print STDERR "\n[PARSER] starting parser...\n"; }
    #------------------------------------------------------------------
    #initializing pos-tagger
    my $svmtool = initialize_svmt($tools, $L, $C, $verbose);
    #------------------------------------------------------------------
    #initializing lemmatizer
    my $lemmatizer;
    if ((($which == 0) or ($which > 1)) and ($SP::USE_LEMMAS)) {
    	$lemmatizer = initialize_lemmatizer($tools, $L, $verbose);
    }
    #------------------------------------------------------------------
    $PARSER->{svmt} = $svmtool;
    if ($SP::USE_LEMMAS) { $PARSER->{lemmatizer} = $lemmatizer; }

    $PARSER->{LANG} = $L;
}

sub remove_parse_split_files {
    #description _ removes auxiliar files created for NERC computation
    #param1  _ input file
    #param2  _ verbosity (0/1)

    my $input = shift;
    my $verbose = shift;

    my $pfile = $input.".$SP::SPEXT.P";
    my $lfile = $input.".$SP::SPEXT.L";
    my $cfile = $input.".$SP::SPEXT.iob";
    my $Cfile = $input.".$SP::SPEXT.C";

    if ($verbose > 1) { print STDERR "[SP] erasing SP auxiliar files [PLcC]...\n"; }
    if (-e $pfile) { system("rm -f $pfile"); }
    #if (-e "$pfile.$Common::GZEXT") { system("rm -f $pfile.$Common::GZEXT"); }
    if (-e $lfile) { system("rm -f $lfile"); }
    #if (-e "$lfile.$Common::GZEXT") { system("rm -f $lfile.$Common::GZEXT"); }
    if (-e $cfile) { system("rm -f $cfile"); }
    #if (-e "$cfile.$Common::GZEXT") { system("rm -f $cfile.$Common::GZEXT"); }
    if (-e $Cfile) { system("rm -f $Cfile"); }
    #if (-e "$Cfile.$Common::GZEXT") { system("rm -f $Cfile.$Common::GZEXT"); }
}

sub SNT_extract_features {
   #description _ extracts features from a given shallow-parsed sentence.
   #param1  _ sentence
   #param2  _ use lemmas? (0/1)
   #@return _ sentence (+features)

   my $snt = shift;
   my $use_lemmas = shift;
   my $use_chunks = shift;

   my %SNT;
   my %nP;
   my %nT;
   foreach my $elem (@{$snt}) {  	  
      my ($word, $pos, $lemma, $chunklabel);
      if ($use_chunks) {
         ($word, $pos, $lemma, $chunklabel) = @{$elem};
      }
      else{
         ($word, $pos, $lemma) = @{$elem};
         $chunklabel = "";
      }
      
      my $chunk = $chunklabel;
      $chunk =~ s/^[BI]\-//g;
      #printf "%-40s %-10s %-10s %10s [%s]\n", $word, $pos, $lemma, $chunklabel, $chunk;
      # chunk-based
      if ($use_lemmas) {
         $SNT{C}->{$chunk}->{W}->{$lemma}++;
         $SNT{P}->{$pos}->{W}->{$lemma}++;
      }
      else {
         $SNT{C}->{$chunk}->{W}->{$word}++;
         $SNT{P}->{$pos}->{W}->{$word}++;
      }

      #if ($chunklabel =~ /^B\-.*/) { $SNT{C}->{$chunk}->{Bn}++; }
      #$SNT{C}->{$chunk}->{n}++;
      #$SNT{C}->{$chunk}->{P}->{$pos}++;
      # PoS-based
      #$SNT{P}->{$pos}->{n}++;
   }

   #print Dumper \%SNT;

   return \%SNT;
}

sub SNT_compute_overlap_scores {
   #description _ computes distances between a candidate and a reference sentence (+features)
   #param1 _ candidate sentence (+features)
   #param2 _ reference sentence (+features)
   #param3 _ language
   #param4 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $Tout = shift;
   my $Tref = shift;
   my $LANG = shift;
   my $LC = shift;

   my %SCORES;

	#print "features in shallow parsing\n";
	#print Dumper $Tref;

   # $SP::SPEXT-Oc(*)  -----------------------------------------------------------------------------
   my $HITS = 0;   my $TOTAL = 0;   my %F;
   foreach my $C (keys %{$Tout->{C}}) { $F{$C} = 1; }
   foreach my $C (keys %{$Tref->{C}}) { $F{$C} = 1; }
   foreach my $C (keys %F) {
      my ($hits, $total) = Overlap::compute_overlap($Tout->{C}->{$C}->{W}, $Tref->{C}->{$C}->{W}, $LC);
      $SCORES{"$SP::SPEXT-Oc($C)"} = ($total == 0)? 0 : ($hits / $total);
      $HITS += $hits; $TOTAL += $total;
   }
   $SCORES{"$SP::SPEXT-Oc(*)"} = ($TOTAL == 0)? 0 : ($HITS / $TOTAL);


   # $SP::SPEXT-Op(*)  -----------------------------------------------------------------------------
   $HITS = 0;   $TOTAL = 0;   my %ADD;   my %TADD;   %F = ();
   foreach my $P (keys %{$Tout->{P}}) { $F{$P} = 1; }
   foreach my $P (keys %{$Tref->{P}}) { $F{$P} = 1; }
   foreach my $P (keys %F) {
      my ($hits, $total) = Overlap::compute_overlap($Tout->{P}->{$P}->{W}, $Tref->{P}->{$P}->{W}, $LC);
      $SCORES{"$SP::SPEXT-Op($P)"} = ($total == 0)? 0 : ($hits / $total);
      $HITS += $hits; $TOTAL += $total;

      # additional --
      if (($LANG eq $Common::L_SPA) or ($LANG eq $Common::L_CAT)) {
         if ($P =~ /^A.*/) { $ADD{"A"} += $hits; $TADD{"A"} += $total; }
         elsif ($P =~ /^C.*/) { $ADD{"C"} += $hits; $TADD{"C"} += $total; }
         elsif ($P =~ /^D.*/) { $ADD{"D"} += $hits; $TADD{"D"} += $total; }
         elsif ($P =~ /^F.*/) { $ADD{"F"} += $hits; $TADD{"F"} += $total; }
         elsif ($P =~ /^I.*/) { $ADD{"I"} += $hits; $TADD{"I"} += $total; }
         elsif ($P =~ /^N.*/) { $ADD{"N"} += $hits; $TADD{"N"} += $total; }
         elsif ($P =~ /^P.*/) { $ADD{"P"} += $hits; $TADD{"P"} += $total; }
         elsif ($P =~ /^S.*/) { $ADD{"S"} += $hits; $TADD{"S"} += $total; }
         elsif ($P =~ /^V.*/) { $ADD{"V"} += $hits; $TADD{"V"} += $total; }
         elsif ($P =~ /^VA.*/) { $ADD{"VA"} += $hits; $TADD{"VA"} += $total; }
         elsif ($P =~ /^VS.*/) { $ADD{"VS"} += $hits; $TADD{"VS"} += $total; }
         elsif ($P =~ /^VM.*/) { $ADD{"VM"} += $hits; $TADD{"VM"} += $total; }
      }
      elsif ($LANG eq $Common::L_ENG) {
         if ($P =~ /^JJ.*/) { $ADD{"J"} += $hits; $TADD{"J"} += $total; }
         elsif ($P =~ /^NN.*/) { $ADD{"N"} += $hits; $TADD{"N"} += $total; }
         elsif ($P =~ /^PRP.*/) { $ADD{"P"} += $hits; $TADD{"P"} += $total; }
         elsif ($P =~ /^RB.*/) { $ADD{"R"} += $hits; $TADD{"R"} += $total; }
         elsif (($P =~ /^VB.*/) or ($P =~ /^MD.*/)) { $ADD{"V"} += $hits; $TADD{"V"} += $total; }
         elsif ($P =~ /^W.*/) { $ADD{"W"} += $hits; $TADD{"W"} += $total; }
         elsif ($P =~ /^[\#\$\'\(\)\,\.\:\`].*/) { $ADD{"F"} += $hits; $TADD{"F"} += $total; }
      }
   }
   $SCORES{"$SP::SPEXT-Op(*)"} = ($TOTAL == 0)? 0 : ($HITS / $TOTAL);

   foreach my $P (keys %TADD) {
      $SCORES{"$SP::SPEXT-Op($P)"} = ($TADD{$P} == 0)? 0 : ($ADD{$P} / $TADD{$P});
   }

   return \%SCORES;
}

sub FILE_compute_overlap_metrics {
   #description _ computes SP scores (single reference)
   #param1 _ candidate list of parsed sentences (+features)
   #param2 _ reference list of parsed sentences (+features)
   #param3 _ language
   #param4 _ do_lower_case evaluation ( 1:yes -> case_insensitive  ::  0:no -> case_sensitive )
   #param5 _ use lemmas? (0/1)

   my $FOUT = shift;
   my $FREF = shift;
   my $LANG = shift;
   my $LC = shift;
   my $UL = shift;

   #print Dumper($FOUT);
   #print Dumper($FREF);

   my @SCORES;
   my $topic = 0;
   while ($topic < scalar(@{$FREF})) {
      #print "*********** ", $topic + 1, " / ", scalar(@{$FREF}), "**********\n";

      #print Dumper $FOUT->[$topic];
      my $OUTSNT = SNT_extract_features($FOUT->[$topic], $UL, exists($SP::rLANGBIOS->{$LANG}) );
      #print Dumper $OUTSNT;

      #print "---------------------------------------------------------\n";

      #print Dumper $FREF->[$topic];
      my $REFSNT = SNT_extract_features($FREF->[$topic], $UL, exists($SP::rLANGBIOS->{$LANG}));
      #print Dumper $REFSNT;

      #print "---------------------------------------------------------\n";

      $SCORES[$topic] = SNT_compute_overlap_scores($OUTSNT, $REFSNT, $LANG, $LC);
      #print Dumper $SCORES[$topic];
      $topic++;
   }

   return \@SCORES;
}


sub FILE_compute_MultiNIST_metrics {
   #description _ computes SP scores (single reference) on a NIST basis
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param6  _ verbosity (0/1)
   #param7  _ hash of scores

   my $config = shift;
   my $TGT = shift;
   my $out = shift;
   my $REF = shift;
   my $Href = shift;
   my $verbose = shift;
   my $hOQ = shift;
   
   my $src = $config->{src};                    # source file 
   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $M = $config->{Hmetrics};                 # set of metrics
   
   my $use_chunks = (exists($SP::rLANGBIOS->{$config->{LANG}})) ? 1: 0 ;   
 
   my $pfile_out = $out.".$SP::SPEXT.P";
   my $lfile_out = $out.".$SP::SPEXT.L";
   my $cfile_out = $out.".$SP::SPEXT.iob";
   my $Cfile_out = $out.".$SP::SPEXT.C";

   my %lHref; my %pHref; my %cHref; my %CHref;
   foreach my $r (keys %{$Href}) { $lHref{$r} = $Href->{$r}.".$SP::SPEXT.L"; }
   foreach my $r (keys %{$Href}) { $pHref{$r} = $Href->{$r}.".$SP::SPEXT.P"; }
   if ($use_chunks) { foreach my $r (keys %{$Href}) { $cHref{$r} = $Href->{$r}.".$SP::SPEXT.iob"; } }
   if ($use_chunks) { foreach my $r (keys %{$Href}) { $CHref{$r} = $Href->{$r}.".$SP::SPEXT.C"; } }

   my $VERBOSE = $config->{verbose};
   $config->{verbose} = $verbose;

   NIST::doMultiNIST($config, $TGT, $pfile_out, $REF, \%pHref, "$SP::SPEXT-p", $hOQ);
   BLEUNIST::doMultiNIST($config, $TGT, $pfile_out, $REF, \%pHref, "$SP::SPEXT-p", $hOQ);
   if ($SP::USE_LEMMAS) {
   	  NIST::doMultiNIST($config, $TGT, $lfile_out, $REF, \%lHref, "$SP::SPEXT-l", $hOQ);
   	  BLEUNIST::doMultiNIST($config, $TGT, $lfile_out, $REF, \%lHref, "$SP::SPEXT-l", $hOQ);
   }	
   if ( $use_chunks ){
      NIST::doMultiNIST($config, $TGT, $cfile_out, $REF, \%cHref, "$SP::SPEXT-iob", $hOQ);
      BLEUNIST::doMultiNIST($config, $TGT, $cfile_out, $REF, \%cHref, "$SP::SPEXT-iob", $hOQ);
      NIST::doMultiNIST($config, $TGT, $Cfile_out, $REF, \%CHref, "$SP::SPEXT-c", $hOQ);
      BLEUNIST::doMultiNIST($config, $TGT, $Cfile_out, $REF, \%CHref, "$SP::SPEXT-c", $hOQ);
   }
   $config->{verbose} = $VERBOSE;
}

sub doMultiSP {
   #description _ computes SP scores (multiple references)
   #param1  _ configuration
   #param2  _ target NAME
   #param3  _ candidate file
   #param4  _ reference NAME
   #param5  _ reference file(s) [hash reference]
   #param6  _ hash of scores

   my $config = shift;
   my $TGT = shift;
   my $out = shift;
   my $REF = shift;
   my $Href = shift;
	my $hOQ = shift;
	
   my $src = $config->{src};                    # source file 
   my $remakeREPORTS = $config->{remake};       # remake reports? (1 - yes :: 0 - no)
   my $tools = $config->{tools};                # TOOL directory
   my $parser = $config->{parser};              # shallow parser (object)
   my $M = $config->{Hmetrics};                 # set of metrics
   my $L = $config->{LANG};                     # language
   my $C = $config->{CASE};                     # case
   my $verbose = $config->{verbose};            # verbosity (0/1)

   my $rF;
   if (($L eq $Common::L_SPA) or ($L eq $Common::L_CAT)) { $rF = $SP::rSPspacat; }
   elsif ($L eq $Common::L_FRN)  { $rF = $SP::rSPfrench; }
   elsif ($L eq $Common::L_GER)  { $rF = $SP::rSPgerman; }
   else { $rF = $SP::rSPeng; }

   my $GO_ON = 0;
   my $GO_NIST = 0;
   foreach my $metric (keys %{$rF}) {
      if ($M->{$metric}) {
    	 $GO_ON = 1;
         if ($metric =~ /.*NIST.*/) { $GO_NIST = 1; }
      }
   }

   if ($GO_ON) {
      if ($verbose == 1) { print STDERR "$SP::SPEXT.."; }
      my $DO_METRICS = $remakeREPORTS;
      my $DO_NIST_METRICS = $remakeREPORTS;
      if (!$DO_METRICS) {
         foreach my $metric (keys %{$rF}) {
            my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
            if ($M->{$metric} and !(-e $report_xml) and !(-e $report_xml.".$Common::GZEXT")) {
               $DO_METRICS = 1;
               if ($metric =~ /.*NIST.*/) { $DO_NIST_METRICS = 1; }
            }
         }
      }
      if ($DO_METRICS) {
         my $FDout = SP::FILE_parse_and_read($out, $parser, $tools, $L, $C, (($verbose > 0)? $verbose - 1 : 0));
         my @maxscores;
         foreach my $ref (keys %{$Href}) {
            my $FDref = SP::FILE_parse_and_read($Href->{$ref}, $parser, $tools, $L, $C, (($verbose > 0)? $verbose - 1 : 0));
            my $scores = SP::FILE_compute_overlap_metrics($FDout, $FDref, $L, ($C ne $Common::CASE_CI), $SP::USE_LEMMAS);
            foreach my $metric (keys %{$rF}) {
	           if ($M->{$metric}) {
                  my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 0);
                  my ($SYS, $SEGS) = Overlap::get_segment_scores($scores, $metric, 2); 
                  my $i = 0;
                  while ($i < scalar(@{$SEGS})) { #update max scores
                     if (defined($MAXSEGS->[$i])) {
                        if ($SEGS->[$i] > $MAXSEGS->[$i]) {
                           if (exists($scores->[$i]->{$metric})) {
                              $maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
  	  	                     }
                        }
                     }
                     else { $maxscores[$i]->{$metric} = $scores->[$i]->{$metric}; }
                     $i++;
                  }
               }
	        }
	        
            if ($GO_NIST and $DO_NIST_METRICS) {
  	           SP::FILE_parse_split($Href->{$ref}, $parser, $tools, $L, $C, (($verbose > 0)? $verbose - 1 : 0));
            }
         }

         foreach my $metric (keys %{$rF}) {
	        if (($M->{$metric}) and (!($metric =~ /.*NIST.*/))) {
               my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
               if ((!(-e $report_xml) and (!(-e $report_xml.".$Common::GZEXT"))) or $remakeREPORTS) {
                  #my ($SYS, $SEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 1);
                  my ($SYS, $SEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 2);
                  my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
                  if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, $metric, $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            		Scores::save_hash_scores($metric, $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
               }
            }
         }

         if ($GO_NIST and $DO_NIST_METRICS) {
            SP::FILE_parse_split($out, $parser, $tools, $L, $C, (($verbose > 0)? $verbose - 1 : 0));
            SP::FILE_compute_MultiNIST_metrics($config, $TGT, $out, $REF, $Href, (($verbose > 0)? $verbose - 1 : 0), $hOQ);
            SP::remove_parse_split_files($out, $verbose);
            foreach my $ref (keys %{$Href}) { SP::remove_parse_split_files($Href->{$ref}, $verbose); }
         }
      }
   }
}

1;
