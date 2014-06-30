package DPmalt;

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
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Overlap;
use IQ::Scoring::Metrics;

our($DPEXT, $rDPeng, $rDPspa, $rDPcat, $TDPeng, $MAXHWC_LENGTH);

my $SEP = "_";
my $DMAX = 4;

$DPmalt::DPEXT = "DPm";
$DPmalt::USE_LOWERCASE = 1;
$DPmalt::MAXHWC_LENGTH = 9;

$DPmalt::TDPdir = { $Common::L_ENG => {"dir" => "malt-1.7.2", "parser" => "maltparser-1.7.2.jar", "model" => "engmalt.poly-1.7"} ,
                    $Common::L_FRN => {"dir" => "malt-1.7.2", "parser" => "maltparser-1.7.2.jar", "model" => "fremalt-1.7" } ,
#                    $Common::L_SPA => {"dir" => "malt-1.4.1", "parser" => "malt.jar", "model" => "spamalt"} ,
                    $Common::L_SPA => {"dir" => "malt-1.7.2", "parser" => "maltparser-1.7.2.jar", "model" => "espmalt-1.0"} ,
                    $Common::L_CAT => {"dir" => "malt-1.4.1", "parser" => "malt.jar", "model" => "catmalt"} };


$DPmalt::TDPparserOpts = { $Common::L_ENG => "-m parse -a nivreeager -nr false -ne true -d POSTAG -s Input[0] -T 1000 -c " . $DPmalt::TDPdir->{$Common::L_ENG}->{"model"} ,
                           $Common::L_FRN => "-m parse -a nivreeager -nr false -ne true -d POSTAG -s Input[0] -T 1000 -c " . $DPmalt::TDPdir->{$Common::L_FRN}->{"model"} ,
                           $Common::L_SPA => "-m parse -a nivreeager -nr false -ne true -d POSTAG -s Input[0] -T 1000 -c " . $DPmalt::TDPdir->{$Common::L_SPA}->{"model"} ,
#                           $Common::L_SPA => "-m parse -a nivreeager -r relaxed -d POSTAG -s Input[0] -T 1000 -c " . $DPmalt::TDPdir->{$Common::L_SPA}->{"model"} ,
                           $Common::L_CAT => "-m parse -a nivreeager -r relaxed -d POSTAG -s Input[0] -T 1000 -c " . $DPmalt::TDPdir->{$Common::L_CAT}->{"model"} };



#POSTAGS: IN	DT	NNP	CD	NN	``	''	POS	(	VBN	NNS	VBP	,	CC	)	VBD	RB	TO	.	VBZ	NNPS	PRP	PRP$	VB	JJ	MD	VBG	RBR	:	WP	WDT	JJR	PDT	RBS	WRB	JJS	$	RP	FW	EX	SYM	#	LS	UH	WP$	PRT
# DEPREL: abbrev acomp advcl advmod amod appos attr aux auxpass cc ccomp complm conj cop csubj csubjpass dep det dobj expl infmod iobj mark measure neg nn nsubj nsubjpass null num number  parataxis  partmod pcomp pobj poss possessive preconj pred predet prep prt punct purpcl quantmod rcmod rel ROOT tmod xcomp 
$DPmalt::rDPeng = { 
                #relationships
                "$DPmalt::DPEXT-Or(abbrev)" => 1, "$DPmalt::DPEXT-Or(acomp)" => 1, "$DPmalt::DPEXT-Or(advcl)" => 1, 
                "$DPmalt::DPEXT-Or(advmod)" => 1, "$DPmalt::DPEXT-Or(amod)" => 1, "$DPmalt::DPEXT-Or(appos)" => 1, 
                "$DPmalt::DPEXT-Or(attr)" => 1, "$DPmalt::DPEXT-Or(aux)" => 1, "$DPmalt::DPEXT-Or(auxpass)" => 1,
                "$DPmalt::DPEXT-Or(cc)" => 1, "$DPmalt::DPEXT-Or(ccomp)" => 1, "$DPmalt::DPEXT-Or(complm)" => 1, 
                "$DPmalt::DPEXT-Or(conj)" => 1, "$DPmalt::DPEXT-Or(cop)" => 1, "$DPmalt::DPEXT-Or(csubj)" => 1, 
                "$DPmalt::DPEXT-Or(csubjpass)" => 1, "$DPmalt::DPEXT-Or(dep)" => 1, "$DPmalt::DPEXT-Or(det)" => 1,
                "$DPmalt::DPEXT-Or(dobj)" => 1, "$DPmalt::DPEXT-Or(expl)" => 1, "$DPmalt::DPEXT-Or(infmod)" => 1,
                "$DPmalt::DPEXT-Or(iobj)" => 1, "$DPmalt::DPEXT-Or(mark)" => 1, "$DPmalt::DPEXT-Or(measure)" => 1,  
                "$DPmalt::DPEXT-Or(neg)" => 1, "$DPmalt::DPEXT-Or(nn)" => 1, "$DPmalt::DPEXT-Or(nsubj)" => 1, 
                "$DPmalt::DPEXT-Or(nsubjpass)" => 1, "$DPmalt::DPEXT-Or(num)" => 1, "$DPmalt::DPEXT-Or(number)" => 1, 
                "$DPmalt::DPEXT-Or(parataxis)" => 1, "$DPmalt::DPEXT-Or(partmod)" => 1, "$DPmalt::DPEXT-Or(pcomp)" => 1, 
                "$DPmalt::DPEXT-Or(pobj)" => 1, "$DPmalt::DPEXT-Or(poss)" => 1, "$DPmalt::DPEXT-Or(possessive)" => 1, 
                "$DPmalt::DPEXT-Or(preconj)" => 1, "$DPmalt::DPEXT-Or(pred)" => 1, "$DPmalt::DPEXT-Or(predet)" => 1, 
                "$DPmalt::DPEXT-Or(prep)" => 1, "$DPmalt::DPEXT-Or(prt)" => 1, "$DPmalt::DPEXT-Or(punct)" => 1, 
                "$DPmalt::DPEXT-Or(purpcl)" => 1, "$DPmalt::DPEXT-Or(quantmod)" => 1, "$DPmalt::DPEXT-Or(rcmod)" => 1, 
                "$DPmalt::DPEXT-Or(rel)" => 1, "$DPmalt::DPEXT-Or(root)" => 1, "$DPmalt::DPEXT-Or(tmod)" => 1, "$DPmalt::DPEXT-Or(xcomp)" => 1, 
                #lex
                "$DPmalt::DPEXT-Ol(1)" => 1, "$DPmalt::DPEXT-Ol(2)" => 1, "$DPmalt::DPEXT-Ol(3)" => 1,
                "$DPmalt::DPEXT-Ol(4)" => 1, "$DPmalt::DPEXT-Ol(5)" => 1, "$DPmalt::DPEXT-Ol(6)" => 1,
                "$DPmalt::DPEXT-Ol(7)" => 1, "$DPmalt::DPEXT-Ol(8)" => 1, "$DPmalt::DPEXT-Ol(9)" => 1,
                #categories 
                "$DPmalt::DPEXT-Oc(I)" => 1, "$DPmalt::DPEXT-Oc(D)" => 1, "$DPmalt::DPEXT-Oc(N)" => 1,
                "$DPmalt::DPEXT-Oc(C)" => 1, "$DPmalt::DPEXT-Oc(``)" => 1, "$DPmalt::DPEXT-Oc(\'\')" => 1, 
                "$DPmalt::DPEXT-Oc(P)" => 1, "$DPmalt::DPEXT-Oc(()" => 1, "$DPmalt::DPEXT-Oc(V)" => 1, 
                "$DPmalt::DPEXT-Oc(,)" => 1, "$DPmalt::DPEXT-Oc())" => 1, "$DPmalt::DPEXT-Oc(R)" => 1, 
                "$DPmalt::DPEXT-Oc(T)" => 1, "$DPmalt::DPEXT-Oc(.)" => 1, "$DPmalt::DPEXT-Oc(J)" => 1, 
                "$DPmalt::DPEXT-Oc(M)" => 1, "$DPmalt::DPEXT-Oc(:)" => 1, "$DPmalt::DPEXT-Oc(W)" => 1,
                "$DPmalt::DPEXT-Oc(F)" => 1, "$DPmalt::DPEXT-Oc(E)" => 1, "$DPmalt::DPEXT-Oc(S)" => 1, 
                "$DPmalt::DPEXT-Oc(#)" => 1, "$DPmalt::DPEXT-Oc(L)" => 1, "$DPmalt::DPEXT-Oc(U)" => 1, 
#                "$DPmalt::DPEXT-Oc(IN)" => 1, "$DPmalt::DPEXT-Oc(DT)" => 1, "$DPmalt::DPEXT-Oc(NNP)" => 1,
#                "$DPmalt::DPEXT-Oc(CD)" => 1, "$DPmalt::DPEXT-Oc(NN)" => 1, "$DPmalt::DPEXT-Oc(``)" => 1,
#                "$DPmalt::DPEXT-Oc(\'\')" => 1, "$DPmalt::DPEXT-Oc(POS)" => 1, "$DPmalt::DPEXT-Oc(()" => 1,
#                "$DPmalt::DPEXT-Oc(VBN)" => 1, "$DPmalt::DPEXT-Oc(NNS)" => 1, "$DPmalt::DPEXT-Oc(VBP)" => 1,
#                "$DPmalt::DPEXT-Oc(,)" => 1, "$DPmalt::DPEXT-Oc(CC)" => 1, "$DPmalt::DPEXT-Oc())" => 1,
#                "$DPmalt::DPEXT-Oc(VBD)" => 1, "$DPmalt::DPEXT-Oc(RB)" => 1, "$DPmalt::DPEXT-Oc(TO)" => 1,
#                "$DPmalt::DPEXT-Oc(.)" => 1, "$DPmalt::DPEXT-Oc(VBZ)" => 1, "$DPmalt::DPEXT-Oc(NNPS)" => 1,
#                "$DPmalt::DPEXT-Oc(PRP)" => 1, "$DPmalt::DPEXT-Oc(PRP\$)" => 1, "$DPmalt::DPEXT-Oc(VB)" => 1,
#                "$DPmalt::DPEXT-Oc(JJ)" => 1, "$DPmalt::DPEXT-Oc(MD)" => 1, "$DPmalt::DPEXT-Oc(VBG)" => 1,
#                "$DPmalt::DPEXT-Oc(RBR)" => 1, "$DPmalt::DPEXT-Oc(:)" => 1, "$DPmalt::DPEXT-Oc(WP)" => 1,
#                "$DPmalt::DPEXT-Oc(WDT)" => 1, "$DPmalt::DPEXT-Oc(JJR)" => 1, "$DPmalt::DPEXT-Oc(PDT)" => 1,
#                "$DPmalt::DPEXT-Oc(RBS)" => 1, "$DPmalt::DPEXT-Oc(WRB)" => 1, "$DPmalt::DPEXT-Oc(JJS)" => 1,
#                "$DPmalt::DPEXT-Oc(\$)" => 1, "$DPmalt::DPEXT-Oc(RP)" => 1, "$DPmalt::DPEXT-Oc(FW)" => 1,
#                "$DPmalt::DPEXT-Oc(EX)" => 1, "$DPmalt::DPEXT-Oc(SYM)" => 1, "$DPmalt::DPEXT-Oc(#)" => 1,
#                "$DPmalt::DPEXT-Oc(LS)" => 1, "$DPmalt::DPEXT-Oc(UH)" => 1, "$DPmalt::DPEXT-Oc(WP\$)" => 1,
#                "$DPmalt::DPEXT-Oc(PRT)" => 1, 
                
                "$DPmalt::DPEXT-Oc(*)" => 1, "$DPmalt::DPEXT-Ol(*)" => 1, "$DPmalt::DPEXT-Or(*)" => 1,
                # head chains
                "$DPmalt::DPEXT-HWCM_w-1" => 1, "$DPmalt::DPEXT-HWCM_w-2" => 1, "$DPmalt::DPEXT-HWCM_w-3" => 1,
                "$DPmalt::DPEXT-HWCM_w-4" => 1, "$DPmalt::DPEXT-HWCM_c-1" => 1, "$DPmalt::DPEXT-HWCM_c-2" => 1,
                "$DPmalt::DPEXT-HWCM_c-3" => 1, "$DPmalt::DPEXT-HWCM_c-4" => 1, "$DPmalt::DPEXT-HWCM_r-1" => 1,
                "$DPmalt::DPEXT-HWCM_r-2" => 1, "$DPmalt::DPEXT-HWCM_r-3" => 1, "$DPmalt::DPEXT-HWCM_r-4" => 1,
                "$DPmalt::DPEXT-HWCMi_w-2" => 1, "$DPmalt::DPEXT-HWCMi_w-3" => 1, "$DPmalt::DPEXT-HWCMi_w-4" => 1,
                "$DPmalt::DPEXT-HWCMi_c-2" => 1, "$DPmalt::DPEXT-HWCMi_c-3" => 1, "$DPmalt::DPEXT-HWCMi_c-4" => 1,
                "$DPmalt::DPEXT-HWCMi_r-2" => 1, "$DPmalt::DPEXT-HWCMi_r-3" => 1, "$DPmalt::DPEXT-HWCMi_r-4" => 1
};

$DPmalt::rDPcat = { 
					 #categories (CPOSTAG)
					"$DPmalt::DPEXT-Oc(D)" => 1, "$DPmalt::DPEXT-Oc(N)" => 1, "$DPmalt::DPEXT-Oc(S)" => 1, 
					"$DPmalt::DPEXT-Oc(A)" => 1, "$DPmalt::DPEXT-Oc(P)" => 1, "$DPmalt::DPEXT-Oc(V)" => 1, 
					"$DPmalt::DPEXT-Oc(F)" => 1, "$DPmalt::DPEXT-Oc(C)" => 1, "$DPmalt::DPEXT-Oc(R)" => 1, 
					"$DPmalt::DPEXT-Oc(Z)" => 1, "$DPmalt::DPEXT-Oc(W)" => 1, "$DPmalt::DPEXT-Oc(I)" => 1, 
#					"$DPmalt::DPEXT-Oc(AO)" => 1, "$DPmalt::DPEXT-Oc(AQ)" => 1, "$DPmalt::DPEXT-Oc(CC)" => 1, 
#					"$DPmalt::DPEXT-Oc(CS)" => 1, "$DPmalt::DPEXT-Oc(DA)" => 1, "$DPmalt::DPEXT-Oc(DD)" => 1, 
#					"$DPmalt::DPEXT-Oc(DE)" => 1, "$DPmalt::DPEXT-Oc(DI)" => 1, "$DPmalt::DPEXT-Oc(DN)" => 1, 
#					"$DPmalt::DPEXT-Oc(DP)" => 1, "$DPmalt::DPEXT-Oc(DT)" => 1, "$DPmalt::DPEXT-Oc(FAA)" => 1, 
#					"$DPmalt::DPEXT-Oc(FAT)" => 1, "$DPmalt::DPEXT-Oc(FC)" => 1, "$DPmalt::DPEXT-Oc(FD)" => 1, 
#					"$DPmalt::DPEXT-Oc(FE)" => 1, "$DPmalt::DPEXT-Oc(FG)" => 1, "$DPmalt::DPEXT-Oc(FH)" => 1, 
#					"$DPmalt::DPEXT-Oc(FIA)" => 1, "$DPmalt::DPEXT-Oc(FIT)" => 1, "$DPmalt::DPEXT-Oc(FP)" => 1, 
#					"$DPmalt::DPEXT-Oc(FPA)" => 1, "$DPmalt::DPEXT-Oc(FPT)" => 1, "$DPmalt::DPEXT-Oc(FS)" => 1, 
#					"$DPmalt::DPEXT-Oc(FX)" => 1, "$DPmalt::DPEXT-Oc(FZ)" => 1, "$DPmalt::DPEXT-Oc(I)" => 1, 
#					"$DPmalt::DPEXT-Oc(NC)" => 1, "$DPmalt::DPEXT-Oc(NP)" => 1, "$DPmalt::DPEXT-Oc(P0)" => 1, 
#					"$DPmalt::DPEXT-Oc(PD)" => 1, "$DPmalt::DPEXT-Oc(PE)" => 1, "$DPmalt::DPEXT-Oc(PI)" => 1, 
#					"$DPmalt::DPEXT-Oc(PN)" => 1, "$DPmalt::DPEXT-Oc(PP)" => 1, "$DPmalt::DPEXT-Oc(PR)" => 1, 
#					"$DPmalt::DPEXT-Oc(PT)" => 1, "$DPmalt::DPEXT-Oc(PX)" => 1, "$DPmalt::DPEXT-Oc(RG)" => 1, 
#					"$DPmalt::DPEXT-Oc(RN)" => 1, "$DPmalt::DPEXT-Oc(RP)" => 1, "$DPmalt::DPEXT-Oc(SP)" => 1, 
#					"$DPmalt::DPEXT-Oc(VAG)" => 1, "$DPmalt::DPEXT-Oc(VAI)" => 1, "$DPmalt::DPEXT-Oc(VAM)" => 1, 
#					"$DPmalt::DPEXT-Oc(VAN)" => 1, "$DPmalt::DPEXT-Oc(VAP)" => 1, "$DPmalt::DPEXT-Oc(VAS)" => 1, 
#					"$DPmalt::DPEXT-Oc(VMG)" => 1, "$DPmalt::DPEXT-Oc(VMI)" => 1, "$DPmalt::DPEXT-Oc(VMM)" => 1, 
#					"$DPmalt::DPEXT-Oc(VMN)" => 1, "$DPmalt::DPEXT-Oc(VMP)" => 1, "$DPmalt::DPEXT-Oc(VMS)" => 1, 
#					"$DPmalt::DPEXT-Oc(VSG)" => 1, "$DPmalt::DPEXT-Oc(VSI)" => 1, "$DPmalt::DPEXT-Oc(VSM)" => 1, 
#					"$DPmalt::DPEXT-Oc(VSN)" => 1, "$DPmalt::DPEXT-Oc(VSP)" => 1, "$DPmalt::DPEXT-Oc(VSS)" => 1, 
#					"$DPmalt::DPEXT-Oc(W)" => 1, "$DPmalt::DPEXT-Oc(Z)" => 1, "$DPmalt::DPEXT-Oc(ZM)" => 1, 
#					"$DPmalt::DPEXT-Oc(ZP)" => 1, 
                #lexical chains
                "$DPmalt::DPEXT-Ol(1)" => 1, "$DPmalt::DPEXT-Ol(2)" => 1, "$DPmalt::DPEXT-Ol(3)" => 1,
                "$DPmalt::DPEXT-Ol(4)" => 1, "$DPmalt::DPEXT-Ol(5)" => 1, "$DPmalt::DPEXT-Ol(6)" => 1,
                "$DPmalt::DPEXT-Ol(7)" => 1, "$DPmalt::DPEXT-Ol(8)" => 1, "$DPmalt::DPEXT-Ol(9)" => 1,
                #relationships (PRED)
                "$DPmalt::DPEXT-Or(a)" => 1, "$DPmalt::DPEXT-Or(ao)" => 1, "$DPmalt::DPEXT-Or(atr)" => 1,
                "$DPmalt::DPEXT-Or(c)" => 1, "$DPmalt::DPEXT-Or(cag)" => 1, "$DPmalt::DPEXT-Or(cc)" => 1,
                "$DPmalt::DPEXT-Or(cd)" => 1, "$DPmalt::DPEXT-Or(ci)" => 1, "$DPmalt::DPEXT-Or(conj)" => 1,
                "$DPmalt::DPEXT-Or(coord)" => 1, "$DPmalt::DPEXT-Or(cpred)" => 1, "$DPmalt::DPEXT-Or(creg)" => 1,
                "$DPmalt::DPEXT-Or(d)" => 1, "$DPmalt::DPEXT-Or(et)" => 1, "$DPmalt::DPEXT-Or(f)" => 1,
                "$DPmalt::DPEXT-Or(gerundi)" => 1, "$DPmalt::DPEXT-Or(grup.a)" => 1, "$DPmalt::DPEXT-Or(grup.adv)" => 1,
                "$DPmalt::DPEXT-Or(grup.nom)" => 1, "$DPmalt::DPEXT-Or(grup.verb)" => 1, "$DPmalt::DPEXT-Or(i)" => 1,
                "$DPmalt::DPEXT-Or(impers)" => 1, "$DPmalt::DPEXT-Or(inc)" => 1, "$DPmalt::DPEXT-Or(infinitiu)" => 1,
                "$DPmalt::DPEXT-Or(interjeccio)" => 1, "$DPmalt::DPEXT-Or(mod)" => 1, "$DPmalt::DPEXT-Or(morfema.pronominal)" => 1,
                "$DPmalt::DPEXT-Or(morfema.verbal)" => 1, "$DPmalt::DPEXT-Or(n)" => 1, "$DPmalt::DPEXT-Or(neg)" => 1,
                "$DPmalt::DPEXT-Or(p)" => 1, "$DPmalt::DPEXT-Or(participi)" => 1, "$DPmalt::DPEXT-Or(pass)" => 1,
                "$DPmalt::DPEXT-Or(prep)" => 1, "$DPmalt::DPEXT-Or(r)" => 1, "$DPmalt::DPEXT-Or(relatiu)" => 1,
                "$DPmalt::DPEXT-Or(s)" => 1, "$DPmalt::DPEXT-Or(s.a)" => 1, "$DPmalt::DPEXT-Or(sa)" => 1,
                "$DPmalt::DPEXT-Or(sadv)" => 1, "$DPmalt::DPEXT-Or(sentence)" => 1, "$DPmalt::DPEXT-Or(sn)" => 1,
                "$DPmalt::DPEXT-Or(sp)" => 1, "$DPmalt::DPEXT-Or(spec)" => 1, "$DPmalt::DPEXT-Or(suj)" => 1,
                "$DPmalt::DPEXT-Or(v)" => 1, "$DPmalt::DPEXT-Or(voc)" => 1, "$DPmalt::DPEXT-Or(w)" => 1,
                "$DPmalt::DPEXT-Or(z)" => 1,
                "$DPmalt::DPEXT-Oc(*)" => 1, "$DPmalt::DPEXT-Ol(*)" => 1, "$DPmalt::DPEXT-Or(*)" => 1,
                #head chain
                "$DPmalt::DPEXT-HWCM_w-1" => 1, "$DPmalt::DPEXT-HWCM_w-2" => 1, "$DPmalt::DPEXT-HWCM_w-3" => 1,
                "$DPmalt::DPEXT-HWCM_w-4" => 1, "$DPmalt::DPEXT-HWCM_c-1" => 1, "$DPmalt::DPEXT-HWCM_c-2" => 1,
                "$DPmalt::DPEXT-HWCM_c-3" => 1, "$DPmalt::DPEXT-HWCM_c-4" => 1, "$DPmalt::DPEXT-HWCM_r-1" => 1,
                "$DPmalt::DPEXT-HWCM_r-2" => 1, "$DPmalt::DPEXT-HWCM_r-3" => 1, "$DPmalt::DPEXT-HWCM_r-4" => 1,
                "$DPmalt::DPEXT-HWCMi_w-2" => 1, "$DPmalt::DPEXT-HWCMi_w-3" => 1, "$DPmalt::DPEXT-HWCMi_w-4" => 1,
                "$DPmalt::DPEXT-HWCMi_c-2" => 1, "$DPmalt::DPEXT-HWCMi_c-3" => 1, "$DPmalt::DPEXT-HWCMi_c-4" => 1,
                "$DPmalt::DPEXT-HWCMi_r-2" => 1, "$DPmalt::DPEXT-HWCMi_r-3" => 1, "$DPmalt::DPEXT-HWCMi_r-4" => 1
};


#SPANISH - MALT 1.7 
# categories : v d n r a s f c z w p i _
# relationships (DEPREL): _ adv atr aux byag comp comp-gap compl conj coord do io mimpers mod mod-gap mpas mpron oblc oprd pp-dir pp-loc prd prdc punct root spec subj subj-gap


$DPmalt::rDPspa = { 
					 #categories (CPOSTAG)
					"$DPmalt::DPEXT-Oc(V)" => 1, "$DPmalt::DPEXT-Oc(D)" => 1, "$DPmalt::DPEXT-Oc(N)" => 1, 
					"$DPmalt::DPEXT-Oc(R)" => 1, "$DPmalt::DPEXT-Oc(A)" => 1, "$DPmalt::DPEXT-Oc(S)" => 1, 
					"$DPmalt::DPEXT-Oc(F)" => 1, "$DPmalt::DPEXT-Oc(C)" => 1, "$DPmalt::DPEXT-Oc(Z)" => 1, 
					"$DPmalt::DPEXT-Oc(W)" => 1, "$DPmalt::DPEXT-Oc(P)" => 1, "$DPmalt::DPEXT-Oc(I)" => 1, 
					"$DPmalt::DPEXT-Oc(_)" => 1, 
                #lexical chains
                "$DPmalt::DPEXT-Ol(1)" => 1, "$DPmalt::DPEXT-Ol(2)" => 1, "$DPmalt::DPEXT-Ol(3)" => 1,
                "$DPmalt::DPEXT-Ol(4)" => 1, "$DPmalt::DPEXT-Ol(5)" => 1, "$DPmalt::DPEXT-Ol(6)" => 1,
                "$DPmalt::DPEXT-Ol(7)" => 1, "$DPmalt::DPEXT-Ol(8)" => 1, "$DPmalt::DPEXT-Ol(9)" => 1,
                #relationships (PRED)
					 "$DPmalt::DPEXT-Or(_)" => 1, "$DPmalt::DPEXT-Or(adv)" => 1, "$DPmalt::DPEXT-Or(atr)" => 1, 
					 "$DPmalt::DPEXT-Or(aux)" => 1, "$DPmalt::DPEXT-Or(byag)" => 1, "$DPmalt::DPEXT-Or(comp)" => 1, 
					 "$DPmalt::DPEXT-Or(comp-gap)" => 1, "$DPmalt::DPEXT-Or(compl)" => 1, "$DPmalt::DPEXT-Or(conj)" => 1, 
					 "$DPmalt::DPEXT-Or(coord)" => 1, "$DPmalt::DPEXT-Or(do)" => 1, "$DPmalt::DPEXT-Or(io)" => 1, 
					 "$DPmalt::DPEXT-Or(mimpers)" => 1, "$DPmalt::DPEXT-Or(mod)" => 1, "$DPmalt::DPEXT-Or(mod-gap)" => 1, 
					 "$DPmalt::DPEXT-Or(mpas)" => 1, "$DPmalt::DPEXT-Or(mpron)" => 1, "$DPmalt::DPEXT-Or(oblc)" => 1, 
					 "$DPmalt::DPEXT-Or(oprd)" => 1, "$DPmalt::DPEXT-Or(pp-dir)" => 1, "$DPmalt::DPEXT-Or(pp-loc)" => 1, 
					 "$DPmalt::DPEXT-Or(prd)" => 1, "$DPmalt::DPEXT-Or(prdc)" => 1, "$DPmalt::DPEXT-Or(punct)" => 1, 
					 "$DPmalt::DPEXT-Or(root)" => 1, "$DPmalt::DPEXT-Or(spec)" => 1, "$DPmalt::DPEXT-Or(subj)" => 1, 
					 "$DPmalt::DPEXT-Or(subj-gap)" => 1, 

                "$DPmalt::DPEXT-Oc(*)" => 1, "$DPmalt::DPEXT-Ol(*)" => 1, "$DPmalt::DPEXT-Or(*)" => 1,
                #head chain
                "$DPmalt::DPEXT-HWCM_w-1" => 1, "$DPmalt::DPEXT-HWCM_w-2" => 1, "$DPmalt::DPEXT-HWCM_w-3" => 1,
                "$DPmalt::DPEXT-HWCM_w-4" => 1, "$DPmalt::DPEXT-HWCM_c-1" => 1, "$DPmalt::DPEXT-HWCM_c-2" => 1,
                "$DPmalt::DPEXT-HWCM_c-3" => 1, "$DPmalt::DPEXT-HWCM_c-4" => 1, "$DPmalt::DPEXT-HWCM_r-1" => 1,
                "$DPmalt::DPEXT-HWCM_r-2" => 1, "$DPmalt::DPEXT-HWCM_r-3" => 1, "$DPmalt::DPEXT-HWCM_r-4" => 1,
                "$DPmalt::DPEXT-HWCMi_w-2" => 1, "$DPmalt::DPEXT-HWCMi_w-3" => 1, "$DPmalt::DPEXT-HWCMi_w-4" => 1,
                "$DPmalt::DPEXT-HWCMi_c-2" => 1, "$DPmalt::DPEXT-HWCMi_c-3" => 1, "$DPmalt::DPEXT-HWCMi_c-4" => 1,
                "$DPmalt::DPEXT-HWCMi_r-2" => 1, "$DPmalt::DPEXT-HWCMi_r-3" => 1, "$DPmalt::DPEXT-HWCMi_r-4" => 1
};

# DEPREL: abbrev acomp advcl advmod amod appos attr aux auxpass cc ccomp complm conj cop csubj csubjpass dep det dobj expl infmod iobj mark measure neg nn nsubj nsubjpass null num number  parataxis  partmod pcomp pobj poss possessive preconj pred predet prep prt punct purpcl quantmod rcmod rel ROOT tmod xcomp 
#---- French ----------------------------------
#Categories:
# A 	   adjective
# ADV	   adverb
# C	   conjunction
# CL     clitic pronoun
# D	   determiner
# ET	   foreign word
# I	   interjection
# N	   noun
# P	   preposition
# P+D	   preposition+determiner amalgam
# P+PRO	prepositon+pronoun amalgam
# PONCT	punctuation mark
# PREF	prefix
# PRO	   full pronoun
# V      verb form
#-----------------------------------------------
#Relations:
# a_obj # aff # arg # ato # ats # aux_caus # aux_pass # aux_tps # comp # coord # de_obj # dep # dep_coord # det # missinghead # mod # mod_rel # obj # obj1 # p_obj # ponct # root # suj
#-----------------------------------------------

$DPmalt::rDPfre = { 
                #relationships
                "$DPmalt::DPEXT-Or(a_obj)" => 1, "$DPmalt::DPEXT-Or(aff)" => 1, "$DPmalt::DPEXT-Or(arg)" => 1, 
                "$DPmalt::DPEXT-Or(ato)" => 1, "$DPmalt::DPEXT-Or(ats)" => 1, "$DPmalt::DPEXT-Or(aux_caus)" => 1, 
                "$DPmalt::DPEXT-Or(aux_pass)" => 1, "$DPmalt::DPEXT-Or(aux_tps)" => 1, "$DPmalt::DPEXT-Or(comp)" => 1,
                "$DPmalt::DPEXT-Or(coord)" => 1, "$DPmalt::DPEXT-Or(de_obj)" => 1, "$DPmalt::DPEXT-Or(dep)" => 1, 
                "$DPmalt::DPEXT-Or(dep_coord)" => 1, "$DPmalt::DPEXT-Or(det)" => 1, "$DPmalt::DPEXT-Or(missinghead)" => 1, 
                "$DPmalt::DPEXT-Or(mod)" => 1, "$DPmalt::DPEXT-Or(mod_rel)" => 1, "$DPmalt::DPEXT-Or(obj)" => 1,
                "$DPmalt::DPEXT-Or(obj1)" => 1, "$DPmalt::DPEXT-Or(p_obj)" => 1, "$DPmalt::DPEXT-Or(ponct)" => 1,
                "$DPmalt::DPEXT-Or(root)" => 1, "$DPmalt::DPEXT-Or(suj)" => 1,
                #lex
                "$DPmalt::DPEXT-Ol(1)" => 1, "$DPmalt::DPEXT-Ol(2)" => 1, "$DPmalt::DPEXT-Ol(3)" => 1,
                "$DPmalt::DPEXT-Ol(4)" => 1, "$DPmalt::DPEXT-Ol(5)" => 1, "$DPmalt::DPEXT-Ol(6)" => 1,
                "$DPmalt::DPEXT-Ol(7)" => 1, "$DPmalt::DPEXT-Ol(8)" => 1, "$DPmalt::DPEXT-Ol(9)" => 1,
                #categories
#                "$DPmalt::DPEXT-Oc(IN)" => 1, "$DPmalt::DPEXT-Oc(DT)" => 1, "$DPmalt::DPEXT-Oc(NNP)" => 1,
#                "$DPmalt::DPEXT-Oc(CD)" => 1, "$DPmalt::DPEXT-Oc(NN)" => 1, "$DPmalt::DPEXT-Oc(``)" => 1,
#                "$DPmalt::DPEXT-Oc(\'\')" => 1, "$DPmalt::DPEXT-Oc(POS)" => 1, "$DPmalt::DPEXT-Oc(()" => 1,
#                "$DPmalt::DPEXT-Oc(VBN)" => 1, "$DPmalt::DPEXT-Oc(NNS)" => 1, "$DPmalt::DPEXT-Oc(VBP)" => 1,
#                "$DPmalt::DPEXT-Oc(,)" => 1, "$DPmalt::DPEXT-Oc(CC)" => 1, "$DPmalt::DPEXT-Oc())" => 1,
#                "$DPmalt::DPEXT-Oc(VBD)" => 1, "$DPmalt::DPEXT-Oc(RB)" => 1, "$DPmalt::DPEXT-Oc(TO)" => 1,
#                "$DPmalt::DPEXT-Oc(.)" => 1, "$DPmalt::DPEXT-Oc(VBZ)" => 1, "$DPmalt::DPEXT-Oc(NNPS)" => 1,
#                "$DPmalt::DPEXT-Oc(PRP)" => 1, "$DPmalt::DPEXT-Oc(PRP\$)" => 1, "$DPmalt::DPEXT-Oc(VB)" => 1,
#                "$DPmalt::DPEXT-Oc(JJ)" => 1, "$DPmalt::DPEXT-Oc(MD)" => 1, "$DPmalt::DPEXT-Oc(VBG)" => 1,
#                "$DPmalt::DPEXT-Oc(RBR)" => 1, "$DPmalt::DPEXT-Oc(:)" => 1, "$DPmalt::DPEXT-Oc(WP)" => 1,
#                "$DPmalt::DPEXT-Oc(WDT)" => 1, "$DPmalt::DPEXT-Oc(JJR)" => 1, "$DPmalt::DPEXT-Oc(PDT)" => 1,
#                "$DPmalt::DPEXT-Oc(RBS)" => 1, "$DPmalt::DPEXT-Oc(WRB)" => 1, "$DPmalt::DPEXT-Oc(JJS)" => 1,
#                "$DPmalt::DPEXT-Oc(\$)" => 1, "$DPmalt::DPEXT-Oc(RP)" => 1, "$DPmalt::DPEXT-Oc(FW)" => 1,
#                "$DPmalt::DPEXT-Oc(EX)" => 1, "$DPmalt::DPEXT-Oc(SYM)" => 1, "$DPmalt::DPEXT-Oc(#)" => 1,
#                "$DPmalt::DPEXT-Oc(LS)" => 1, "$DPmalt::DPEXT-Oc(UH)" => 1, "$DPmalt::DPEXT-Oc(WP\$)" => 1,
#                "$DPmalt::DPEXT-Oc(PRT)" => 1, 
                "$DPmalt::DPEXT-Oc(I)" => 1, "$DPmalt::DPEXT-Oc(D)" => 1, "$DPmalt::DPEXT-Oc(C)" => 1, 
                "$DPmalt::DPEXT-Oc(``)" => 1, "$DPmalt::DPEXT-Oc(\')" => 1, "$DPmalt::DPEXT-Oc(()" => 1,
					 "$DPmalt::DPEXT-Oc(N)" => 1, "$DPmalt::DPEXT-Oc(,)" => 1, "$DPmalt::DPEXT-Oc())" => 1,
                "$DPmalt::DPEXT-Oc(V)" => 1, "$DPmalt::DPEXT-Oc(T)" => 1, "$DPmalt::DPEXT-Oc(.)" => 1, 
                "$DPmalt::DPEXT-Oc(P)" => 1, "$DPmalt::DPEXT-Oc(J)" => 1, "$DPmalt::DPEXT-Oc(M)" => 1, 
                "$DPmalt::DPEXT-Oc(R)" => 1, "$DPmalt::DPEXT-Oc(:)" => 1, "$DPmalt::DPEXT-Oc(W)" => 1, 
                "$DPmalt::DPEXT-Oc(\$)" => 1, "$DPmalt::DPEXT-Oc(F)" => 1, "$DPmalt::DPEXT-Oc(E)" => 1, 
                "$DPmalt::DPEXT-Oc(S)" => 1, "$DPmalt::DPEXT-Oc(#)" => 1, "$DPmalt::DPEXT-Oc(L)" => 1, 
                "$DPmalt::DPEXT-Oc(U)" => 1, 
                
                "$DPmalt::DPEXT-Oc(*)" => 1, "$DPmalt::DPEXT-Ol(*)" => 1, "$DPmalt::DPEXT-Or(*)" => 1,
                # head chains
                "$DPmalt::DPEXT-HWCM_w-1" => 1, "$DPmalt::DPEXT-HWCM_w-2" => 1, "$DPmalt::DPEXT-HWCM_w-3" => 1,
                "$DPmalt::DPEXT-HWCM_w-4" => 1, "$DPmalt::DPEXT-HWCM_c-1" => 1, "$DPmalt::DPEXT-HWCM_c-2" => 1,
                "$DPmalt::DPEXT-HWCM_c-3" => 1, "$DPmalt::DPEXT-HWCM_c-4" => 1, "$DPmalt::DPEXT-HWCM_r-1" => 1,
                "$DPmalt::DPEXT-HWCM_r-2" => 1, "$DPmalt::DPEXT-HWCM_r-3" => 1, "$DPmalt::DPEXT-HWCM_r-4" => 1,
                "$DPmalt::DPEXT-HWCMi_w-2" => 1, "$DPmalt::DPEXT-HWCMi_w-3" => 1, "$DPmalt::DPEXT-HWCMi_w-4" => 1,
                "$DPmalt::DPEXT-HWCMi_c-2" => 1, "$DPmalt::DPEXT-HWCMi_c-3" => 1, "$DPmalt::DPEXT-HWCMi_c-4" => 1,
                "$DPmalt::DPEXT-HWCMi_r-2" => 1, "$DPmalt::DPEXT-HWCMi_r-3" => 1, "$DPmalt::DPEXT-HWCMi_r-4" => 1
};


sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;
    if     ($language eq $Common::L_ENG) { %metric_set = %{$DPmalt::rDPeng}; }
    elsif  ($language eq $Common::L_SPA) { %metric_set = %{$DPmalt::rDPspa}; }
    elsif  ($language eq $Common::L_CAT) { %metric_set = %{$DPmalt::rDPcat}; }
    elsif  ($language eq $Common::L_FRN) { %metric_set = %{$DPmalt::rDPfre}; }

    return \%metric_set;
}

sub FOREST_parse {
   #description _ runs MALTparser on a given file (1 sentence per line)
   #              and returns the resulting dependency forest
   #param1  _ input file
   #param2  _ kind of trees (0 - constituency trees :: 1 - dependency trees)
   #param3  _ tools
   #param4  _ verbosity (0/1)
   #param4  _ configuration
   #@return _ forest (list of dependency trees)

   my $file = shift;
   my $kind = shift;	             # Ignored
   my $tools = shift;
   my $verbose = shift;
   my $config = shift;
   my $parser = $config->{parser};   # shallow parser (object)
   my $L = $config->{LANG};          # language
   my $C = $config->{CASE};          # case
   

   my @FOREST;

   my $forest = $file.".$DPmalt::DPEXT.".($kind?"d":"c")."-forest";

   if (!(-e $forest)) {
      if (-e "$forest.$Common::GZEXT") { system("gunzip $forest.$Common::GZEXT");  }
      else {
         my $conllfile = $file.".$SP::SPEXT.conll";
         if ( !(-e $conllfile) and !(-e "$conllfile.$Common::GZEXT") ){ 
	         SP::FILE_parse($file, $parser, $tools, $L, $C, $verbose); 
	         system("$Common::GUNZIP $conllfile.$Common::GZEXT");
	         my $spfile = $file.".$SP::SPEXT.wplc";
	         if (-e $spfile) { system("$Common::GZIP $spfile"); }
	         $spfile = $file.".$SP::SPEXT.wpl";
	         if (-e $spfile) { system("$Common::GZIP $spfile"); }
         }

         if ($verbose > 1 ) { print STDERR "running malt parser [$file -> $forest]\n"; }
         # Parser command depends on language
         my $parserOpts = $DPmalt::TDPparserOpts->{$L};
         my $toolDPdir = "$tools/".$DPmalt::TDPdir->{$L}->{"dir"};
         my $pwd = readpipe("pwd");
         chomp($pwd);
         #chdir($toolDPdir); # Malt parser works only from its own directory
         if ( !(-e $conllfile) and (-e "$conllfile.$Common::GZEXT")) { system("$Common::GUNZIP $conllfile.$Common::GZEXT"); }

         if ( $conllfile =~ m/\.\// ) {
   	     $conllfile =~ s/\.\///;
   	     $conllfile = "$pwd/$conllfile";
     	   }
         elsif ( $conllfile !~ m/\// ) { $conllfile = "$pwd/$conllfile";
     	   }

         if ( $forest =~ m/\.\// ){
   	     $forest =~ s/\.\///;
	        $forest= "$pwd/$forest";
	      }
         elsif ( $forest !~ m/\// ){ $forest= "$pwd/$forest"; }
         
	      # print STDERR "cd $toolDPdir; java -Xmx1024M -jar ".$DPmalt::TDPdir->{$L}->{"parser"}." $parserOpts -i $conllfile -o $forest ; cd $pwd; ";
         Common::execute_or_die("cd $toolDPdir; java -Xmx1024M -jar ".$DPmalt::TDPdir->{$L}->{"parser"}." $parserOpts -i $conllfile -o $forest 2> /dev/null; cd $pwd; ", "[ERROR] problems running dependency parser..."); #updated to meet cluster conditions to execute java

         #chdir($pwd); # Return to former directory
         system("$Common::GZIP $conllfile");
      }
   }

   open(AUX, "< $forest") or die "couldn't open file: $forest\n";
   while (my $line = <AUX>) {
	  my @tree;
      chomp($line);
      while ($line ne '') {
         my @fields = split(/\t/,$line);
         my @entry = ();
         push(@entry, $fields[0]);  # idNode
         push(@entry, $fields[1]);  # word
         push(@entry, uc($fields[3]));  # cat
         push(@entry, ($fields[6] == 0 ? '*' : $fields[6]));  # nodeF; zero value causes infinite recursion !
         push(@entry, $fields[7]);  # catNode
         #print Dumper(\@entry);
         push(@tree, \@entry);
         #ENTRY = idNode word lemma cat fullCat _ nodeF catNode _ _
         if($line = <AUX>) { chomp($line); }
         else { $line = ''; }
      } 
      if(@tree > 0) {
         # print "*****************************\n";
         # print Dumper \@tree;
         # print "*****************************\n";
         push(@FOREST, \@tree);  
      }
   }

   close(AUX);

   #print "*****************************\n";
   #print Dumper \@FOREST;
   #print "*****************************\n";

   #print "### TOPICS = ", scalar(@FOREST), "\n";

   system("$Common::GZIP $forest");

   return \@FOREST;
}

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

sub TREE_extract_base_features {
   #description _ extracts base features from a given tree.
   #param1  _ tree
   #@return _ tree (+features)

   my $tree = shift;

   my %TREE;
   my %nP;
   my %nT;
   foreach my $elem (@{$tree}) {
      my ($node,$term,$cat,$dad,$role)=@{$elem};
      # print "NODE = $node :: TERM = $term :: CAT = $cat :: FATHER = $dad :: ROLE = $role\n";
      $nP{$node}=$dad;
      $nT{$node}=1;
      $nT{$dad}=1;
      $TREE{nodeRol}->{$node} = $role;
      $TREE{nodeCat}->{$node} = $cat;
      push(@{$TREE{children}->{$dad}}, $node); #########
      $TREE{nodeTerm}->{$node} = $term;
      if ($term ne ""){
          push(@{$TREE{featureTerms}->{"$DPmalt::DPEXT-Oc(".$cat.")"}}, $term); 
      }
   }
   foreach my $n (keys %nT){
      if (!exists($nP{$n})) { push(@{$TREE{children}->{"0"}}, $n); }
      else {
         if (!($nP{$n}=~/\S/)){ push(@{$TREE{children}->{"0"}}, $n); }
      }
   }

   #print Dumper \%TREE;

   return \%TREE;
}

sub TREE_extract_recursive_features {
   #description _ recursively extracts features from a given tree.
   #param1  _ tree (+ only base features)
   #param2  _ current node
   #param3  _ current level
   #@return _ set of visited terms (synthesized)

   my $tree=shift;
   my $node=shift;
   my $level=shift;

#   print "NODE = $node :: LEVEL = $level\n";

   my @terms;
   if (exists($tree->{nodeTerm}->{$node})) {
      if (($tree->{nodeTerm}->{$node} ne "")) { $level++; }
      foreach my $n ($tree->{nodeTerm}->{$node}) { if ((defined($n)) and ($n ne "")) { push(@terms, $n); } }
   }

   my $hwcW;
   my $hwcC;
   my $hwcR;

   if (exists($tree->{children}->{$node})) { # NON-TERMINAL NODE
      foreach my $child (@{$tree->{children}->{$node}}) {
         if ($child ne ""){
            my ($aux, $rW, $rC, $rR) = TREE_extract_recursive_features($tree, $child, $level);
            foreach my $a (@{$aux}) { if ((defined($a)) and ($a ne "")) { push(@terms, $a); } }
            if (defined($rW)) {
               my $i = 0;
               if (!defined($hwcW)) { my @hwc; $hwcW = \@hwc; }
               while ($i < scalar(@{$rW})) {
                  if (!defined($hwcW->[$i])) { my @hwci; $hwcW->[$i] = \@hwci; }
                  foreach my $chain (@{$rW->[$i]}) {
                     push(@{$hwcW->[$i]}, $chain);
                  }
  	              $i++;
	           }
	        }
            if (defined($rC)) {
               my $i = 0;
               if (!defined($hwcC)) { my @hwc; $hwcC = \@hwc; }
               while ($i < scalar(@{$rC})) {
                  if (!defined($hwcC->[$i])) { my @hwci; $hwcC->[$i] = \@hwci; }
                  foreach my $chain (@{$rC->[$i]}) {
                     push(@{$hwcC->[$i]}, $chain);
                  }
                  $i++;
               }
            }
            if (defined($rR)) {
               my $i = 0;
               if (!defined($hwcR)) { my @hwc; $hwcR = \@hwc; }
               while ($i < scalar(@{$rR})) {
                  if (!defined($hwcR->[$i])) { my @hwci; $hwcR->[$i] = \@hwci; }
                  foreach my $chain (@{$rR->[$i]}) {
                     push(@{$hwcR->[$i]}, $chain);
                  }
                  $i++;
               }
            }
         }
      }
      # ~(HWCM) head-word chain matching (Liu and Gildea, 2005) --------------------------------------------------
      if (exists($tree->{nodeTerm}->{$node})) {
         if ($tree->{nodeTerm}->{$node} ne "") {
            if (!defined($hwcW)) { my @hwc; $hwcW = \@hwc; }
            my $i = scalar(@{$hwcW});
            if ($i > $DMAX - 1) { $i = $DMAX - 1; }
            while ($i > 0 ) {
               foreach my $chain (@{$hwcW->[$i-1]}) {
                  my @newchain = @{$chain};
                  unshift(@newchain, $tree->{nodeTerm}->{$node});
                  push(@{$hwcW->[$i]}, \@newchain);
   	           }
	           $i--;
            }
            my @chain = ($tree->{nodeTerm}->{$node});
            push(@{$hwcW->[0]}, \@chain);
         }
      }
      if (exists($tree->{nodeCat}->{$node})) {
         if ($tree->{nodeCat}->{$node} ne "") {
            if (!defined($hwcC)) { my @hwc; $hwcC = \@hwc; }
            my $i = scalar(@{$hwcC});
            if ($i > $DMAX - 1) { $i = $DMAX - 1; }
            while ($i > 0 ) {
               foreach my $chain (@{$hwcC->[$i-1]}) {
                  my @newchain = @{$chain};
                  unshift(@newchain, $tree->{nodeCat}->{$node});
                  push(@{$hwcC->[$i]}, \@newchain);
               }
               $i--;
            }
            my @chain = ($tree->{nodeCat}->{$node});
            push(@{$hwcC->[0]}, \@chain);
         }
      }
      if (exists($tree->{nodeRol}->{$node})) {
         if ($tree->{nodeRol}->{$node} ne "") {
            if (!defined($hwcR)) { my @hwc; $hwcR = \@hwc; }
            my $i = scalar(@{$hwcR});
            if ($i > $DMAX - 1) { $i = $DMAX - 1; }
            while ($i > 0 ) {
               foreach my $chain (@{$hwcR->[$i-1]}) {
                  my @newchain = @{$chain};
                  unshift(@newchain, $tree->{nodeRol}->{$node});
                  push(@{$hwcR->[$i]}, \@newchain);
   	           }
               $i--;
            }
            my @chain = ($tree->{nodeRol}->{$node});
            push(@{$hwcR->[0]}, \@chain);
         }
      }
   }
   else { # TERMINAL NODE (LEAVE)
      if (exists($tree->{nodeTerm}->{$node})) {
         if ($tree->{nodeTerm}->{$node} ne "") {
            if (!defined($hwcW)) { my @hwc; $hwcW = \@hwc; }
            my @chain = ($tree->{nodeTerm}->{$node});
            push(@{$hwcW->[0]}, \@chain);
         }
      }
      if (exists($tree->{nodeCat}->{$node})) {
         if ($tree->{nodeCat}->{$node} ne "") {
            if (!defined($hwcC)) { my @hwc; $hwcC = \@hwc; }
            my @chain = ($tree->{nodeCat}->{$node});
            push(@{$hwcC->[0]}, \@chain);
         }
      }
      if (exists($tree->{nodeRol}->{$node})) {
         if ($tree->{nodeRol}->{$node} ne "") {
            if (!defined($hwcR)) { my @hwc; $hwcR = \@hwc; }
            my @chain = ($tree->{nodeRol}->{$node});
            push(@{$hwcR->[0]}, \@chain);
         }
      }
   }
   # ------------------------------------------------------------------------------------------

   if (scalar(@terms)) {
      if (exists($tree->{nodeRol}->{$node})) {
         my $featureTree="$DPmalt::DPEXT-Or(".lc($tree->{nodeRol}->{$node}).")";
         #my $featureTree="$DPmalt::DPEXT-Or(".$tree->{nodeRol}->{$node}.")";
         foreach my $elem (@terms) { push(@{$tree->{featureTerms}->{$featureTree}}, $elem); }
      }
      if ($level > 0) {
         foreach my $elem (@terms) { push(@{$tree->{featureTerms}->{"$DPmalt::DPEXT-Ol(".$level.")"}}, $elem); }
      }
   } 

   return (\@terms, $hwcW, $hwcC, $hwcR);
}

sub compute_hwcm {
   #description _ computes HWCM between elems in candidate and reference list of features
   #param1 _ candidate list of features
   #param2 _ reference list of features
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $L1 = shift;
   my $L2 = shift;
   my $LC = shift;

   my %H1; my %H2; my %H12;   my $hits=0;   my $total=0;
   foreach my $l (@{$L1}) { $H1{$LC? lc(join($SEP, @{$l})) : join($SEP, @{$l})}++;
                            $H12{$LC? lc(join($SEP, @{$l})) : join($SEP, @{$l})}++; }
   foreach my $l (@{$L2}) { $H2{$LC? lc(join($SEP, @{$l})) : join($SEP, @{$l})}++;
                            $H12{$LC? lc(join($SEP, @{$l})) : join($SEP, @{$l})}++; }
   foreach my $elem (keys %H12){
      if ($H1{$elem} and $H2{$elem}) {
	 if ($H1{$elem} > $H2{$elem}) { $hits += $H2{$elem}; $total += $H1{$elem}; }
         else { $hits += $H1{$elem}; $total += $H2{$elem}; }
      }
      elsif ($H1{$elem}) { $total += $H1{$elem}; }
      elsif ($H2{$elem}) { $total += $H2{$elem}; }
   }

   return ($hits, $total);
}

sub TREE_compute_score {
   #description _ computes distances between a candidate and a reference tree (+features)
   #param1 _ candidate tree (+features)
   #param2 _ reference tree (+features)
   #param3 _ do_lower_case matching (1:yes->case_insensitive :: 0:no->case_sensitive)

   my $Tout = shift;
   my $Tref = shift;
   my $LC = shift;

   my %F;
   foreach my $f (keys %{$Tout->{featureTerms}}) { $F{$f} = 1; }
   foreach my $f (keys %{$Tref->{featureTerms}}) { $F{$f} = 1; }

   my %SCORES;
   foreach my $feature (keys %F) {
      if ((exists($Tout->{featureTerms}->{$feature})) and (exists($Tref->{featureTerms}->{$feature}))) {
         my ($hits, $total) = Overlap::compute_overlap_l($Tout->{featureTerms}->{$feature}, $Tref->{featureTerms}->{$feature}, $LC);
         $SCORES{$feature} = Common::safe_division($hits, $total);
      }
      else { 
      	$SCORES{$feature} = 0; 
      }
   }

   # HWCM_word -----------------------------------------------------------------------------
   if (defined($Tout->{hwcW}) and defined($Tref->{hwcW})) {
      my $L1; my $L2;
      if (scalar(@{$Tout->{hwcW}}) > scalar(@{$Tref->{hwcW}})) { $L1 = $Tout->{hwcW}; $L2 = $Tref->{hwcW}; }
      else { $L1 = $Tref->{hwcW}; $L2 = $Tout->{hwcW}; } 
      my $i = 0;
      my $HITS = 0;   my $TOTAL = 0;
      while ($i < $DPmalt::MAXHWC_LENGTH) {
         if (defined($L1->[$i]) and defined($L2->[$i])) {
            my ($hits, $total) = compute_hwcm($L1->[$i], $L2->[$i], $LC);
            $SCORES{$DPmalt::DPEXT."-HWCMi_w-".($i+1)} = Common::safe_division($hits, $total);
            $HITS += $hits; $TOTAL += $total;
            $SCORES{$DPmalt::DPEXT."-HWCM_w-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         else {
            $SCORES{$DPmalt::DPEXT."-HWCMi_w-".($i+1)} = 0;
            $TOTAL += (defined($L1->[$i])? scalar(@{$L1->[$i]}) : 0) + (defined($L2->[$i])? scalar(@{$L2->[$i]}) : 0);
      	    $SCORES{$DPmalt::DPEXT."-HWCM_w-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         $i++;
      }
   }
   # HWCM_cat ------------------------------------------------------------------------------
   if (defined($Tout->{hwcC}) and defined($Tref->{hwcC})) {
      my $L1; my $L2;
      if (scalar(@{$Tout->{hwcC}}) > scalar(@{$Tref->{hwcC}})) { $L1 = $Tout->{hwcC}; $L2 = $Tref->{hwcC}; }
      else { $L1 = $Tref->{hwcC}; $L2 = $Tout->{hwcC}; } 
      my $i = 0;
      my $HITS = 0;   my $TOTAL = 0;
      while ($i < $DPmalt::MAXHWC_LENGTH) {
         if (defined($L1->[$i]) and defined($L2->[$i])) {
            my ($hits, $total) = compute_hwcm($L1->[$i], $L2->[$i], $LC);
            $SCORES{$DPmalt::DPEXT."-HWCMi_c-".($i+1)} = Common::safe_division($hits, $total);
            $HITS += $hits; $TOTAL += $total;
            $SCORES{$DPmalt::DPEXT."-HWCM_c-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         else {
            $SCORES{$DPmalt::DPEXT."-HWCMi_c-".($i+1)} = 0;
            $TOTAL += (defined($L1->[$i])? scalar(@{$L1->[$i]}) : 0) + (defined($L2->[$i])? scalar(@{$L2->[$i]}) : 0);
      	    $SCORES{$DPmalt::DPEXT."-HWCM_c-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         $i++;
      }
   }

   # HWCM_r ------------------------------------------------------------------------------
   if (defined($Tout->{hwcR}) and defined($Tref->{hwcR})) {
      my $L1; my $L2;
      if (scalar(@{$Tout->{hwcR}}) > scalar(@{$Tref->{hwcR}})) { $L1 = $Tout->{hwcR}; $L2 = $Tref->{hwcR}; }
      else { $L1 = $Tref->{hwcR}; $L2 = $Tout->{hwcR}; } 
      my $i = 0;
      my $HITS = 0;   my $TOTAL = 0;
      while ($i < $DPmalt::MAXHWC_LENGTH) {
         if (defined($L1->[$i]) and defined($L2->[$i])) {
            my ($hits, $total) = compute_hwcm($L1->[$i], $L2->[$i], $LC);
            $SCORES{$DPmalt::DPEXT."-HWCMi_r-".($i+1)} = Common::safe_division($hits, $total);
            $HITS += $hits; $TOTAL += $total;
            $SCORES{$DPmalt::DPEXT."-HWCM_r-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         else {
            $SCORES{$DPmalt::DPEXT."-HWCMi_r-".($i+1)} = 0;
            $TOTAL += (defined($L1->[$i])? scalar(@{$L1->[$i]}) : 0) + (defined($L2->[$i])? scalar(@{$L2->[$i]}) : 0);
      	    $SCORES{$DPmalt::DPEXT."-HWCM_r-".($i+1)} = Common::safe_division($HITS, $TOTAL);
         }
         $i++;
      }
   }

   return \%SCORES;
}

sub TREE_print_features {
   #description _ prints features in a given tree
   #param1 _ tree (+features)

   my $T = shift;

   foreach my $feature (keys %{$T->{featureTerms}}) {
      print "$feature = ", join(" ", @{$T->{featureTerms}->{$feature}}), "\n";
   }
}

sub FOREST_compute_metrics {
   #description _ computes MALT scores (single reference)
   #param1  _ candidate forest (+features)
   #param2  _ reference forest (+features)
   #param3  _ do_lower_case evaluation (1:yes->case_insensitive :: 0:no->case_sensitive)
   #@return _ scores (list -> one item per tree)

   my $FOUT = shift;
   my $FREF = shift;
   my $LC = shift;

   #print Dumper($FOUT);
   #print Dumper($FREF);

   my @SCORES;
   ### TREE/LEVEL --------------------------------------------------------
   my $topic = 0;
   while ($topic < scalar(@{$FREF})) {
      #print "*********** ", $topic + 1, " / ", scalar(@{$FREF}), "**********\n";
      #print Dumper $FOUT->[$topic];
      my $OUTTREE = TREE_extract_base_features($FOUT->[$topic]);
      #print Dumper $OUTTREE;
      my ($OUTdummy, $OUThwcW, $OUThwcC, $OUThwcR) = TREE_extract_recursive_features($OUTTREE,"0",0);
      $OUTTREE->{hwcW} = $OUThwcW; $OUTTREE->{hwcC} = $OUThwcC; $OUTTREE->{hwcR} = $OUThwcR;
      #print Dumper $OUTTREE;
      #TREE_print_features($OUTTREE);
      #print "---------------------------------------------------------\n";
      #print Dumper $FREF->[$topic];
      my $REFTREE = TREE_extract_base_features($FREF->[$topic]);
      #print Dumper $REFTREE;
      my ($REFdummy, $REFhwcW, $REFhwcC, $REFhwcR) = TREE_extract_recursive_features($REFTREE,"0",0);
      $REFTREE->{hwcW} = $REFhwcW; $REFTREE->{hwcC} = $REFhwcC; $REFTREE->{hwcR} = $REFhwcR;
      #print Dumper $REFTREE;
      #TREE_print_features($REFTREE);
      #print "---------------------------------------------------------\n";
      $SCORES[$topic] = TREE_compute_score($OUTTREE, $REFTREE, $LC);
      #print Dumper $SCORES[$topic];
      $topic++;
   }

   return \@SCORES;
}

sub get_segment_scores {
   #description _ retrieves scores at the segment level for the given feature
   #              as well as the average system score (dealing with void values
   #              according to the given 'mode' value)
   #param1  _ MALT feature scores
   #param2  _ feature
   #param3  _ mode
   #@return _ (system score, segment scores)

   my $scores = shift;
   my $feature = shift;
   my $mode = shift;

   my @Fscores;
   
   my $SYSscore = 0; my $N = 0;
   foreach my $topic (@{$scores}) {
      my $n = 0;
      my $SEGscore = 0;
      if ($feature eq "$DPmalt::DPEXT-Oc(*)") { # average feature Oc(*=
         #print Dumper keys %{$topic};
         foreach my $f (keys %{$topic}) {
            if ($f =~ /^DPm-Oc\(.*/) {
	          if (defined($topic->{$f})) { 
	            $SEGscore += $topic->{$f}; $n++; 
	          }
            }
         }
      }
      elsif ($feature eq "$DPmalt::DPEXT-Ol(*)") { # average feature Ol(*)
         foreach my $f (keys %{$topic}) {
            if ($f =~ /^DPm-Ol\(.*/) {
   	       if (defined($topic->{$f})) { $SEGscore += $topic->{$f}; $n++; }
            }
         }
      }
      elsif ($feature eq "$DPmalt::DPEXT-Or(*)") { # average feature Or(*)
         foreach my $f (keys %{$topic}) {
            if ($f =~ /^DPm-Or\(.*/) {
   	       if (defined($topic->{$f})) { $SEGscore += $topic->{$f}; $n++; }
            }
         }
      }
      else { # individual feature (Oc(*) / Or(*) /Ol(*)
         if (exists($topic->{$feature})) {
            if (defined($topic->{$feature})) {
               $SEGscore = $topic->{$feature};
               $n = 1;
	    }
         }
      }
      $SYSscore += $SEGscore;
      $N += $n;


      if ($mode == 0) {
	 if ($n == 0) { push(@Fscores, undef); }
         else { push(@Fscores, $SEGscore / $n); }
      }
      elsif ($mode == 1) {
         if ($n == 0) { $SEGscore = 1; $n = 1; } ##### !!!
         push(@Fscores, $SEGscore / $n);
      }
      elsif ($mode == 2) {
         if ($n == 0) { $SEGscore = 0; $n = 1; } ##### !!!
         push(@Fscores, $SEGscore / $n);
      }
   }

   if ($N == 0) { $SYSscore = (($mode == 0) or ($mode == 2))? 0 : 1; } ##### !!!
   else { $SYSscore /= $N; } 

   return ($SYSscore, \@Fscores);
}

sub doMultiDP {
   #description _ computes DP metric scores (multiple references)
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

   my $rF; # AVAILABLE SET OF METRICS
   if    ($L eq $Common::L_SPA)  { $rF = $DPmalt::rDPspa; } # SPANISH 
   elsif ($L eq $Common::L_CAT)  { $rF = $DPmalt::rDPcat; } # CATALAN
   elsif ($L eq $Common::L_FRN)  { $rF = $DPmalt::rDPfre; } # FRENCH
   else { $rF = $DPmalt::rDPeng; } #ENGLISH and default

   my $GO_ON = 0;
   foreach my $metric (keys %{$rF}) {
      if ($M->{$metric}) { $GO_ON = 1; }
   }

   if ($GO_ON) {
      if ($verbose == 1) { print STDERR "$DPmalt::DPEXT.."; }

      my $DO_METRICS = $remakeREPORTS;
      if (!$DO_METRICS) {
         foreach my $metric (keys %{$rF}) {
            my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
            if ($M->{$metric} and !(-e $report_xml) and !(-e $report_xml.".$Common::GZEXT")) { $DO_METRICS = 1; }
         }
      }

		if ($DO_METRICS) {
			my $FDout = DPmalt::FOREST_parse($out, 1, $tools, $verbose, $config);
			my @maxscores;
			foreach my $ref (keys %{$Href}) {
				my $FDref = DPmalt::FOREST_parse($Href->{$ref}, 1, $tools, $verbose, $config);
				my $scores = DPmalt::FOREST_compute_metrics($FDout, $FDref, $DPmalt::USE_LOWERCASE);
				#save the max value of the scores compared to previous references
				foreach my $metric (keys %{$rF}) {
					if (($M->{$metric}) or 
						 (($M->{"$DPmalt::DPEXT-Oc(*)"}) and ($metric =~ /^DPm-Oc\(.*/)) or 
						 (($M->{"$DPmalt::DPEXT-Ol(*)"}) and ($metric =~ /^DPm-Ol\(.*/)) or 
						 (($M->{"$DPmalt::DPEXT-Or(*)"}) and ($metric =~ /^DPm-Or\(.*/))) {

						my ($MAXSYS, $MAXSEGS) = DPmalt::get_segment_scores(\@maxscores, $metric, 0);
						my ($SYS, $SEGS) = DPmalt::get_segment_scores($scores, $metric, 0); 
						my $i = 0;
						while ($i < scalar(@{$SEGS})) { #update max scores
							if (defined($SEGS->[$i])) {
								if (defined($MAXSEGS->[$i])) {
									if ($SEGS->[$i] > $MAXSEGS->[$i]) {
										if (exists($scores->[$i]->{$metric})) {
											$maxscores[$i]->{$metric} = $scores->[$i]->{$metric};
										}
									}
								}
								else { $maxscores[$i]->{$metric} = $scores->[$i]->{$metric}; }
							}
							else { $maxscores[$i]->{$metric} = $scores->[$i]->{$metric}; }
							$i++;
						}
					}
				}
			}
			
			#WRITE THE REPORTS
			foreach my $metric (keys %{$rF}) {
				if ($M->{$metric}) {
					my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
					my $report_xmlgz = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT.$Common::GZEXT";
					if ((!(-e $report_xml) and (!(-e $report_xmlgz))) or $remakeREPORTS) {
						#my ($SYS, $SEGS) = DPmalt::get_segment_scores(\@maxscores, $metric, 1);
						my ($SYS, $SEGS) = DPmalt::get_segment_scores(\@maxscores, $metric, 2);
						my ($d_scores, $s_scores) = Metrics::get_seg_doc_scores($SEGS, 0, $config->{IDX}->{$TGT});         
						if ($config->{O_STORAGE} == 1 ) { IQXML::write_report($TGT, $REF, $metric, $SYS, $d_scores, $s_scores, $config->{IDX}->{$TGT}, $verbose); }
            		Scores::save_hash_scores($metric, $TGT, $REF, $SYS, $d_scores, $s_scores,$hOQ);
					}
				}
			}
		}
	}
}

1;
