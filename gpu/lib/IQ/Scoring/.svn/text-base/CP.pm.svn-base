package CP;

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
use IO::File;
use Data::Dumper;
use Unicode::String;
use IQ::InOut::IQXML;
use IQ::Common;
use IQ::Scoring::Overlap;
use IQ::Scoring::Metrics;

our ($CPEXT, $rCPeng, $rCPspacat, $SPATOOL, $ENGTOOL, $MAXSTM_LENGTH);


$CP::SPATOOL = "collins";
$CP::ENGTOOL = "reranking-parser";
$CP::FRETOOL = "bonsai_v3.2"; #berkeley via bonsai -> remember to set the BKY and CLASSPATH variables
$CP::GERTOOL = "berkeleyparser"; #berkeley
$CP::CPEXT = "CP";
$CP::SNTLEN_COLLINS = 199;
$CP::SNTLEN_CHARNIAK = 399;

$CP::MAXSTM_LENGTH = 9;

$CP::rLANG = { $Common::L_ENG => 'en', $Common::L_SPA => 'es', $Common::L_FRN => 'fr', $Common::L_GER => 'de' };

$CP::rCPeng = { "$CP::CPEXT-STM-1" => 1, "$CP::CPEXT-STM-2" => 1, "$CP::CPEXT-STM-3" => 1, "$CP::CPEXT-STM-4" => 1,
	            "$CP::CPEXT-STM-5" => 1, "$CP::CPEXT-STM-6" => 1, "$CP::CPEXT-STM-7" => 1, "$CP::CPEXT-STM-8" => 1,
	            "$CP::CPEXT-STM-9" => 1, "$CP::CPEXT-STMi-2" => 1, "$CP::CPEXT-STMi-3" => 1,
	            "$CP::CPEXT-STMi-4" => 1, "$CP::CPEXT-STMi-5" => 1, "$CP::CPEXT-STMi-6" => 1,
	            "$CP::CPEXT-STMi-7" => 1, "$CP::CPEXT-STMi-8" => 1, "$CP::CPEXT-STMi-9" => 1,
	            "$CP::CPEXT-Oc(ADJP)" => 1, "$CP::CPEXT-Oc(ADVP)" => 1, "$CP::CPEXT-Oc(CONJP)" => 1,
	            "$CP::CPEXT-Oc(INTJ)" => 1, "$CP::CPEXT-Oc(LST)" => 1, "$CP::CPEXT-Oc(NP)" => 1,
	            "$CP::CPEXT-Oc(O)" => 1, "$CP::CPEXT-Oc(PP)" => 1, "$CP::CPEXT-Oc(PRT)" => 1,
	            "$CP::CPEXT-Oc(SBAR)" => 1, "$CP::CPEXT-Oc(UCP)" => 1, "$CP::CPEXT-Oc(VP)" => 1,
	            "$CP::CPEXT-Oc(FRAG)" => 1, "$CP::CPEXT-Oc(NAC)" => 1, "$CP::CPEXT-Oc(NX)" => 1,
	            "$CP::CPEXT-Oc(PRN)" => 1, "$CP::CPEXT-Oc(QP)" => 1, "$CP::CPEXT-Oc(RRC)" => 1,
	            "$CP::CPEXT-Oc(S)" => 1, "$CP::CPEXT-Oc(SINV)" => 1, "$CP::CPEXT-Oc(SQ)" => 1,
	            "$CP::CPEXT-Oc(WHADJP)" => 1, "$CP::CPEXT-Oc(WHADVP)" => 1, "$CP::CPEXT-Oc(WHNP)" => 1,
	            "$CP::CPEXT-Oc(WHPP)" => 1, "$CP::CPEXT-Oc(X)" => 1, "$CP::CPEXT-Op(CC)" => 1,
	            "$CP::CPEXT-Op(CD)" => 1, "$CP::CPEXT-Op(DT)" => 1, "$CP::CPEXT-Op(EX)" => 1,
	            "$CP::CPEXT-Op(FW)" => 1, "$CP::CPEXT-Op(IN)" => 1, "$CP::CPEXT-Op(JJ)" => 1,
	            "$CP::CPEXT-Op(JJR)" => 1, "$CP::CPEXT-Op(JJS)" => 1, "$CP::CPEXT-Op(LS)" => 1,
	            "$CP::CPEXT-Op(MD)" => 1, "$CP::CPEXT-Op(NN)" => 1, "$CP::CPEXT-Op(NNP)" => 1,
	            "$CP::CPEXT-Op(NNPS)" => 1, "$CP::CPEXT-Op(NNS)" => 1, "$CP::CPEXT-Op(PDT)" => 1,
	            "$CP::CPEXT-Op(POS)" => 1, "$CP::CPEXT-Op(PRP)" => 1, "$CP::CPEXT-Op(PRP\$)" => 1,
	            "$CP::CPEXT-Op(RB)" => 1, "$CP::CPEXT-Op(RBR)" => 1, "$CP::CPEXT-Op(RBS)" => 1,
	            "$CP::CPEXT-Op(RP)" => 1, "$CP::CPEXT-Op(SYM)" => 1, "$CP::CPEXT-Op(TO)" => 1,
	            "$CP::CPEXT-Op(UH)" => 1, "$CP::CPEXT-Op(VB)" => 1, "$CP::CPEXT-Op(VBD)" => 1,
	            "$CP::CPEXT-Op(VBG)" => 1, "$CP::CPEXT-Op(VBN)" => 1, "$CP::CPEXT-Op(VBP)" => 1,
	            "$CP::CPEXT-Op(VBZ)" => 1, "$CP::CPEXT-Op(WDT)" => 1, "$CP::CPEXT-Op(WP)" => 1,
	            "$CP::CPEXT-Op(WP\$)" => 1, "$CP::CPEXT-Op(WRB)" => 1, "$CP::CPEXT-Op(#)" => 1,
	            "$CP::CPEXT-Op(\$)" => 1, "$CP::CPEXT-Op(\'\')" => 1, "$CP::CPEXT-Op(()" => 1,
	            "$CP::CPEXT-Op())" => 1, "$CP::CPEXT-Op(,)" => 1, "$CP::CPEXT-Op(.)" => 1, "$CP::CPEXT-Op(:)" => 1,
	            "$CP::CPEXT-Op(``)" => 1, "$CP::CPEXT-Op(J)" => 1, "$CP::CPEXT-Op(N)" => 1, "$CP::CPEXT-Op(P)" => 1,
	            "$CP::CPEXT-Op(R)" => 1, "$CP::CPEXT-Op(V)" => 1, "$CP::CPEXT-Op(W)" => 1, "$CP::CPEXT-Op(F)" => 1,
	            "$CP::CPEXT-Op(*)" => 1, "$CP::CPEXT-Oc(*)" => 1 };

#POS-eng --->  ,, :, ., ``, '', $, #, -LRB-, -RRB-, CC, CD, DT, EX, IN, JJ, JJR, JJS, LS, LST, MD, NN, NNP, NNPS, NNS, PDT, POS, PRP, PRP$, RB, RBR, RBS, RP, SYM, TO, UH, VB, VBD, VBG, VBN, VBP, VBZ, WDT, WP, WP$, WRB
#PHRASE-eng ---> ADJP, ADVP, CONJP, FRAG, INTJ, LST, NAC, NP, NX, PP, PRN, PRT, QP, RRC, S, SBAR, SINV, SQ, UCP, VP, WHADJP, WHADVP, WHNP, WHPP, X

$CP::rCPspacat = { "$CP::CPEXT-STM-1" => 1, "$CP::CPEXT-STM-2" => 1, "$CP::CPEXT-STM-3" => 1,
	               "$CP::CPEXT-STM-4" => 1, "$CP::CPEXT-STM-5" => 1, "$CP::CPEXT-STM-6" => 1,
	               "$CP::CPEXT-STM-7" => 1, "$CP::CPEXT-STM-8" => 1, "$CP::CPEXT-STM-9" => 1,
	               "$CP::CPEXT-STMi-2" => 1, "$CP::CPEXT-STMi-3" => 1, "$CP::CPEXT-STMi-4" => 1,
	               "$CP::CPEXT-STMi-5" => 1, "$CP::CPEXT-STMi-6" => 1, "$CP::CPEXT-STMi-7" => 1,
	               "$CP::CPEXT-STMi-8" => 1, "$CP::CPEXT-STMi-9" => 1, "$CP::CPEXT-Op(aop)" => 1,
	               "$CP::CPEXT-Op(aos)" => 1, "$CP::CPEXT-Op(aqn)" => 1, "$CP::CPEXT-Op(aqp)" => 1,
	               "$CP::CPEXT-Op(aqs)" => 1, "$CP::CPEXT-Op(cc)" => 1, "$CP::CPEXT-Op(cs)" => 1,
	               "$CP::CPEXT-Op(dn)" => 1, "$CP::CPEXT-Op(dp)" => 1, "$CP::CPEXT-Op(ds)" => 1,
	               "$CP::CPEXT-Op(F)" => 1, "$CP::CPEXT-Op(i)" => 1, "$CP::CPEXT-Op(n0)" => 1,
	               "$CP::CPEXT-Op(nn)" => 1, "$CP::CPEXT-Op(np)" => 1, "$CP::CPEXT-Op(ns)" => 1,
	               "$CP::CPEXT-Op(p0)" => 1, "$CP::CPEXT-Op(pn)" => 1, "$CP::CPEXT-Op(pp)" => 1,
	               "$CP::CPEXT-Op(ps)" => 1, "$CP::CPEXT-Op(rg)" => 1, "$CP::CPEXT-Op(rn)" => 1,
	               "$CP::CPEXT-Op(sps)" => 1, "$CP::CPEXT-Op(v0g)" => 1, "$CP::CPEXT-Op(v0n)" => 1,
	               "$CP::CPEXT-Op(vpi)" => 1, "$CP::CPEXT-Op(vpm)" => 1, "$CP::CPEXT-Op(vpp)" => 1,
	               "$CP::CPEXT-Op(vps)" => 1, "$CP::CPEXT-Op(vsi)" => 1, "$CP::CPEXT-Op(vsm)" => 1,
	               "$CP::CPEXT-Op(vsp)" => 1, "$CP::CPEXT-Op(vss)" => 1, "$CP::CPEXT-Op(w)" => 1,
	               "$CP::CPEXT-Op(z)" => 1, "$CP::CPEXT-Oc(conj)" => 1, "$CP::CPEXT-Oc(coord)" => 1,
	               "$CP::CPEXT-Oc(CP)" => 1, "$CP::CPEXT-Oc(data)" => 1, "$CP::CPEXT-Oc(espec)" => 1,
	               "$CP::CPEXT-Oc(gerundi)" => 1, "$CP::CPEXT-Oc(gv)" => 1, "$CP::CPEXT-Oc(INC)" => 1,
	               "$CP::CPEXT-Oc(infinitiu)" => 1, "$CP::CPEXT-Oc(interjeccio)" => 1, "$CP::CPEXT-Oc(morf)" => 1,
	               "$CP::CPEXT-Oc(neg)" => 1, "$CP::CPEXT-Oc(numero)" => 1, "$CP::CPEXT-Oc(prep)" => 1,
	               "$CP::CPEXT-Oc(relatiu)" => 1, "$CP::CPEXT-Oc(s.)" => 1, "$CP::CPEXT-Oc(S)" => 1,
	               "$CP::CPEXT-Oc(sa)" => 1, "$CP::CPEXT-Oc(sadv)" => 1, "$CP::CPEXT-Oc(SBAR)" => 1,
	               "$CP::CPEXT-Oc(sn)" => 1, "$CP::CPEXT-Oc(sp)" => 1, "$CP::CPEXT-Oc(TOP)" => 1,
	               "$CP::CPEXT-Op(A)" => 1, "$CP::CPEXT-Op(C)" => 1, "$CP::CPEXT-Op(D)" => 1, "$CP::CPEXT-Op(F)" => 1,
	               "$CP::CPEXT-Op(I)" => 1, "$CP::CPEXT-Op(N)" => 1, "$CP::CPEXT-Op(P)" => 1, "$CP::CPEXT-Op(S)" => 1,
	               "$CP::CPEXT-Op(V)" => 1, "$CP::CPEXT-Op(VA)" => 1, "$CP::CPEXT-Op(VM)" => 1,
	               "$CP::CPEXT-Op(VS)" => 1, "$CP::CPEXT-Op(*)" => 1, "$CP::CPEXT-Oc(*)" => 1 };

#"$CP::CPEXT-Oc(grup)" => 1 --- removed

#POS-spacat ---> aop, aos, aqn, aqp, aqs, cc, cs, dn, dp, ds, F, i, n0, nn, np, ns, p0, pn, pp, ps, rg, rn, sps, v0g, v0n, vpi, vpm, vpp, vps, vsi, vsm, vsp, vss, w, z
#PHRASE-spacat ---> conj, coord, CP, data, espec, gerundi, grup, gv, INC, infinitiu, interjeccio, morf, neg, numero, prep, relatiu, s., S, sa, sadv, SBAR, sn, sp, TOP


$CP::rCPfrench = { "$CP::CPEXT-STM-1" => 1, "$CP::CPEXT-STM-2" => 1, "$CP::CPEXT-STM-3" => 1,
	               "$CP::CPEXT-STM-4" => 1, "$CP::CPEXT-STM-5" => 1, "$CP::CPEXT-STM-6" => 1,
	               "$CP::CPEXT-STM-7" => 1, "$CP::CPEXT-STM-8" => 1, "$CP::CPEXT-STM-9" => 1,
	               "$CP::CPEXT-STMi-2" => 1, "$CP::CPEXT-STMi-3" => 1, "$CP::CPEXT-STMi-4" => 1,
	               "$CP::CPEXT-STMi-5" => 1, "$CP::CPEXT-STMi-6" => 1, "$CP::CPEXT-STMi-7" => 1,
	               "$CP::CPEXT-STMi-8" => 1, "$CP::CPEXT-STMi-9" => 1,
                   "$CP::CPEXT-Oc(AP)" => 1, "$CP::CPEXT-Oc(AdP)" => 1, "$CP::CPEXT-Oc(NP)" => 1, 
                       "$CP::CPEXT-Oc(PP)" => 1, "$CP::CPEXT-Oc(VN)" => 1, "$CP::CPEXT-Oc(VPinf)" => 1, 
                       "$CP::CPEXT-Oc(VPpart)" => 1, "$CP::CPEXT-Oc(SENT)" => 1, "$CP::CPEXT-Oc(Sint)" => 1, 
                       "$CP::CPEXT-Oc(Srel)" => 1, "$CP::CPEXT-Oc(Ssub)" => 1, "$CP::CPEXT-Oc(*)" => 1,
                   "$CP::CPEXT-Op(A)" => 1, "$CP::CPEXT-Op(ADV)" => 1, "$CP::CPEXT-Op(CC)" => 1, 
                       "$CP::CPEXT-Op(CL)" => 1, "$CP::CPEXT-Op(CS)" => 1, "$CP::CPEXT-Op(D)" => 1, 
                       "$CP::CPEXT-Op(ET)" => 1, "$CP::CPEXT-Op(I)" => 1, "$CP::CPEXT-Op(NC)" => 1,
                       "$CP::CPEXT-Op(NP)" => 1, "$CP::CPEXT-Op(P)" => 1, "$CP::CPEXT-Op(PREF)" => 1, 
                       "$CP::CPEXT-Op(PRO)" => 1, "$CP::CPEXT-Op(V)" => 1, "$CP::CPEXT-Op(PONCT)" => 1, 
                       "$CP::CPEXT-Op(,)" => 1, "$CP::CPEXT-Op(:)" => 1, "$CP::CPEXT-Op(.)" => 1, 
                       "$CP::CPEXT-Op('')" => 1, "$CP::CPEXT-Op(()" => 1, "$CP::CPEXT-Op())" => 1, 
                       "$CP::CPEXT-Op(prs)" => 1, "$CP::CPEXT-Op(N)" => 1, "$CP::CPEXT-Op(C)" => 1, 
                       "$CP::CPEXT-Op(Afs)" => 1, "$CP::CPEXT-Op(PC)" => 1, "$CP::CPEXT-Op(ND)" => 1, 
                       "$CP::CPEXT-Op(X)" => 1, "$CP::CPEXT-Op(p)" => 1, "$CP::CPEXT-Op(Dmp)" => 1, 
                       "$CP::CPEXT-Op(pr)" => 1, "$CP::CPEXT-Op(ADVP)" => 1, "$CP::CPEXT-Op(S)" => 1, 
                       "$CP::CPEXT-Op(*)" => 1 };

#PHRASE-french grammar --> 
#    AP (adjectival phrases)
#    AdP (adverbial phrases) 
#    NP (noun phrases)
#    PP (prepositional phrases)
#    VN (verbal nucleus)
#    VPinf (infinitive clauses)
#    VPpart (nonfinite clauses)
#    SENT (sentences)
#    Sint, Srel, Ssub (finite clauses)


#POS-french grammar -->
#    A (adjective)
#    ADV (adverb)
#    CC (coordinating conjunction)
#    CL (weak clitic pronoun)
#    CS (subordinating conjunction)
#    D (determiner)
#    ET (foreign word)
#    I (interjection)
#    NC (common noun)
#    NP (proper noun)
#    P (preposition)
#    PREF (prefix)
#    PRO (strong pronoun)
#    V (verb)
#    PONCT (punctuation mark)
#    , : . " -LRB- -RRB-
#    prs N C Afs PC ND X p Dmp pr ADVP S (?)

$CP::rCPgerman = { "$CP::CPEXT-STM-1" => 1, "$CP::CPEXT-STM-2" => 1, "$CP::CPEXT-STM-3" => 1,
	               "$CP::CPEXT-STM-4" => 1, "$CP::CPEXT-STM-5" => 1, "$CP::CPEXT-STM-6" => 1,
	               "$CP::CPEXT-STM-7" => 1, "$CP::CPEXT-STM-8" => 1, "$CP::CPEXT-STM-9" => 1,
	               "$CP::CPEXT-STMi-2" => 1, "$CP::CPEXT-STMi-3" => 1, "$CP::CPEXT-STMi-4" => 1,
	               "$CP::CPEXT-STMi-5" => 1, "$CP::CPEXT-STMi-6" => 1, "$CP::CPEXT-STMi-7" => 1,
	               "$CP::CPEXT-STMi-8" => 1, "$CP::CPEXT-STMi-9" => 1, 
                   "$CP::CPEXT-Oc(S)" => 1, "$CP::CPEXT-Oc(NP)" => 1, "$CP::CPEXT-Oc(PP)" => 1,
                       "$CP::CPEXT-Oc(CNP)" => 1, "$CP::CPEXT-Oc(CS)" => 1, "$CP::CPEXT-Oc(VP)" => 1,
                       "$CP::CPEXT-Oc(CVP)" => 1, "$CP::CPEXT-Oc(ISU)" => 1, "$CP::CPEXT-Oc(AP)" => 1,
                       "$CP::CPEXT-Oc(PSEUDO)" => 1, "$CP::CPEXT-Oc(MPN)" => 1, "$CP::CPEXT-Oc(CAP)" => 1,
                       "$CP::CPEXT-Oc(CAVP)" => 1, "$CP::CPEXT-Oc(CO)" => 1, "$CP::CPEXT-Oc(AVP)" => 1,
                       "$CP::CPEXT-Oc(CPP)" => 1, "$CP::CPEXT-Oc(DP)" => 1, "$CP::CPEXT-Oc(---CJ)" => 1,
                       "$CP::CPEXT-Oc(CAC)" => 1, "$CP::CPEXT-Oc(NM)" => 1, "$CP::CPEXT-Oc(CVZ)" => 1,
                       "$CP::CPEXT-Oc(QL)" => 1, "$CP::CPEXT-Oc(MTA)" => 1, "$CP::CPEXT-Oc(CH)" => 1,
                       "$CP::CPEXT-Oc(AA)" => 1, "$CP::CPEXT-Oc(VZ)" => 1, "$CP::CPEXT-Oc(CCP)" => 1,
                       "$CP::CPEXT-Oc(*)" => 1,
                   "$CP::CPEXT-Op(\$*LRB*)" => 1, "$CP::CPEXT-Op(\$,)" => 1, "$CP::CPEXT-Op(\$.)" => 1, 
                        "$CP::CPEXT-Op(*T1*)" => 1, "$CP::CPEXT-Op(*T2*)" => 1, "$CP::CPEXT-Op(*T3*)" => 1, 
                        "$CP::CPEXT-Op(*T4*)" => 1, "$CP::CPEXT-Op(*T5*)" => 1, "$CP::CPEXT-Op(*T6*)" => 1, 
                        "$CP::CPEXT-Op(*T7*)" => 1, "$CP::CPEXT-Op(*T8*)" => 1, "$CP::CPEXT-Op(--)" => 1, 
                        "$CP::CPEXT-Op(ADJA)" => 1, "$CP::CPEXT-Op(ADJD)" => 1, "$CP::CPEXT-Op(ADV)" => 1, 
                        "$CP::CPEXT-Op(APPO)" => 1, "$CP::CPEXT-Op(APPR)" => 1, "$CP::CPEXT-Op(APPRART)" => 1, 
                        "$CP::CPEXT-Op(APZR)" => 1, "$CP::CPEXT-Op(ART)" => 1, "$CP::CPEXT-Op(CARD)" => 1, 
                        "$CP::CPEXT-Op(FM)" => 1, "$CP::CPEXT-Op(ITJ)" => 1, "$CP::CPEXT-Op(KOKOM)" => 1, 
                        "$CP::CPEXT-Op(KON)" => 1, "$CP::CPEXT-Op(KOUI)" => 1, "$CP::CPEXT-Op(KOUS)" => 1, 
                        "$CP::CPEXT-Op(NE)" => 1, "$CP::CPEXT-Op(NN)" => 1, "$CP::CPEXT-Op(PDAT)" => 1, 
                        "$CP::CPEXT-Op(PDS)" => 1, "$CP::CPEXT-Op(PIAT)" => 1, "$CP::CPEXT-Op(PIDAT)" => 1, 
                        "$CP::CPEXT-Op(PIS)" => 1, "$CP::CPEXT-Op(PPER)" => 1, "$CP::CPEXT-Op(PPOSAT)" => 1, 
                        "$CP::CPEXT-Op(PPOSS)" => 1, "$CP::CPEXT-Op(PRELAT)" => 1, "$CP::CPEXT-Op(PRELS)" => 1, 
                        "$CP::CPEXT-Op(PRF)" => 1, "$CP::CPEXT-Op(PROAV)" => 1, "$CP::CPEXT-Op(PTKA)" => 1, 
                        "$CP::CPEXT-Op(PTKANT)" => 1, "$CP::CPEXT-Op(PTKNEG)" => 1, "$CP::CPEXT-Op(PTKVZ)" => 1, 
                        "$CP::CPEXT-Op(PTKZU)" => 1, "$CP::CPEXT-Op(PWAT)" => 1, "$CP::CPEXT-Op(PWAV)" => 1, 
                        "$CP::CPEXT-Op(PWS)" => 1, "$CP::CPEXT-Op(TRUNC)" => 1, "$CP::CPEXT-Op(VAFIN)" => 1, 
                        "$CP::CPEXT-Op(VAIMP)" => 1, "$CP::CPEXT-Op(VAINF)" => 1, "$CP::CPEXT-Op(VAPP)" => 1, 
                        "$CP::CPEXT-Op(VMFIN)" => 1, "$CP::CPEXT-Op(VMINF)" => 1, "$CP::CPEXT-Op(VMPP)" => 1, 
                        "$CP::CPEXT-Op(VVFIN)" => 1, "$CP::CPEXT-Op(VVIMP)" => 1, "$CP::CPEXT-Op(VVINF)" => 1, 
                        "$CP::CPEXT-Op(VVIZU)" => 1, "$CP::CPEXT-Op(VVPP)" => 1, "$CP::CPEXT-Op(XY)" => 1, 
                        "$CP::CPEXT-Op(*)" => 1 };

#PHRASE german grammar --> S NP PP CNP CS VP CVP ISU AP PSEUDO MPN CAP CAVP CO AVP CPP DL ---CJ CAC NM CVZ QL MTA CH AA VZ CCP
#POS german grammar --> $*LRB* $, $. *T1* *T2* *T3* *T4* *T5* *T6* *T7* *T8* -- ADJA ADJD ADV APPO APPR APPRART APZR ART CARD FM ITJ KOKOM KON KOUI KOUS NE NN PDAT PDS PIAT PIDAT PIS PPER PPOSAT PPOSS PRELAT PRELS PRF PROAV PTKA PTKANT PTKNEG PTKVZ PTKZU PWAT PWAV PWS TRUNC VAFIN VAIMP VAINF VAPP VMFIN VMINF VMPP VVFIN VVIMP VVINF VVIZU VVPP XY 

$CP::CSEP = "__";
$CP::EMPTY_ITEM = "*";

sub metric_set {
    #description _ returns the set of available metrics for the given language
    #param1  _ language
    #@return _ metric set structure (hash ref)

    my $language = shift;

    my %metric_set;
    if ($language eq $Common::L_ENG) { %metric_set = %{$CP::rCPeng}; }
    elsif  ($language eq $Common::L_FRN) { %metric_set = %{$CP::rCPfrench}; }
    elsif  ($language eq $Common::L_GER) { %metric_set = %{$CP::rCPgerman}; }
    elsif  ($language eq $Common::L_SPA) { %metric_set = %{$CP::rCPspacat}; }
    #elsif  ($language eq $Common::L_CAT) { %metric_set = %{$CP::rCPspacat}; }

    return \%metric_set;
}

sub SNT_extract_features {
   #description _ extracts features from a given FULLY-parsed sentence.
   #param1  _ sentence
   #@return _ sentence (+features)

   my $node = shift;

   my @SUBTREES;
   my %TAGS;

   if (defined($node)) {
      if (defined($node->[2])) {
         my $children = $node->[2];
         foreach my $child (@{$children}) {
            my @chain;
            my %tags;
 	    extract_features($child, \@chain, \@SUBTREES, \%tags, \%TAGS);
	 }
      }
   }

   my %snt;
   $snt{subtrees} = \@SUBTREES;
   $snt{tags} = \%TAGS;

   return \%snt;
}

sub extract_features {
   #description _ adds subtrees and tag-word associations below the given node
   #              to the inherited collections of subtrees and tag-word occurrences.
   #              New subtrees are also linked to previous subtrees above the
   #              given node in the path bettwen the node and the tree root.
   #param1  _ current node
   #param2  _ chain of tags visited so far (inherited)
   #param3  _ collection of subtrees (inherited + synthesized)
   #param4  _ distinct tags seen so far (inherited)
   #param5  _ collection of tag-word occurrences (inherited + synthesized)

   my $node = shift;
   my $chain = shift;
   my $SUBTREES = shift;
   my $tags = shift;
   my $TAGS = shift;

   if (defined($node)) {
      if (scalar(@{$node}) > 0) { 
         my @l = @{$chain};
         my $j = 0;
         #print Dumper $node;
         my $tag = shrink_tag($node->[0]);  # tag = [ phrase type / PoS / word ]
         while ($j < scalar(@{$chain})) {
            $SUBTREES->[scalar(@l)+1]->{join($CP::CSEP, @l).$CP::CSEP.$tag}++;
            shift(@l);
            $j++;
         }
         $SUBTREES->[1]->{$tag}++;
   
         if (defined($node->[2])) {
   	 if (defined($node->[2]->[0]->[2])) { $tags->{$tag}++; } # a phrase chunk type
            my $children = $node->[2];
            push(@{$chain}, $tag);
            foreach my $child (@{$children}) {
               my @chain = @{$chain};   #copy list of tags
               my %tags = %{$tags};     #copy hash of tags
               extract_features($child, \@chain, $SUBTREES, \%tags, $TAGS);
   	 }
         }
         else {
            my $word = $node->[0];
            #print Dumper $tags;
            foreach my $t (keys %{$tags}) {
   	    $TAGS->{C}->{$t}->{W}->{$word}++;
   	 }
            $TAGS->{P}->{rename_tag($node->[1]->[0])}->{W}->{$word}++; # PoS type is in the parent node
         }
      }
   }
}

sub shrink_tag{
   #description _ selects the 'right' portion of tag
   #param1  _ input tag
   #@return _ shrunk tag

   my $intag = shift;

   my $tag = $intag;
   if (($tag ne "-" ) and ($tag ne "#")) {
      $tag = rename_tag($tag);
      my @T = split(/[\#\-]/, $tag);
      my $tag = $T[0];
   }

   if ($tag =~ /^SBAR.*/) { $tag = "SBAR"; }
   elsif ($tag =~ /^S[0-9]+/) { $tag = "S"; }

   return $tag;
}

sub rename_tag{
   #description _ renames some tags
   #param1  _ input tag
   #@return _ shrunk tag

   my $intag = shift;

   if ($intag eq "-LRB-") { $intag = "("; }
   elsif ($intag eq "\$*LRB*") { $intag = "("; }
   elsif ($intag eq "-RRB-") { $intag = ")"; }
   elsif ($intag eq "PUNCF") { $intag = "F"; }
   elsif ($intag eq "\"") { $intag = "''"; }

   return $intag;
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

	#print "features in constituency parser\n";
	#print Dumper $Tref;

   my %SCORES;

   # ~(STM) subtree metrics (Liu and Gildea, 2005) --------------------------------------------------
   if ((scalar(@{$Tref->{subtrees}}) > 1) and (scalar(@{$Tout->{subtrees}}) > 1)) {  # BOTH SEGMENTS CORRECTLY FULLY-PARSED
      my $HITS = 0;   my $TOTAL = 0;
      my $i = 1;
      while ($i <= $CP::MAXSTM_LENGTH){
	  #print "REF\n";
	  #print Dumper $Tref->{subtrees}->[$i];
	  #print "OUT\n";
	  #print Dumper $Tout->{subtrees}->[$i];
         if ((defined($Tref->{subtrees}->[$i])) and (defined($Tout->{subtrees}->[$i]))) { # BOTH CONTAIN i-subtrees
            my ($hits, $total) = Overlap::compute_overlap($Tout->{subtrees}->[$i], $Tref->{subtrees}->[$i], $LC);
            $SCORES{"$CP::CPEXT-STMi-".$i} =  ($total == 0)? 0 : ($hits / $total);
            $HITS += $hits; $TOTAL += $total;
            $SCORES{"$CP::CPEXT-STM-".$i} =  ($TOTAL == 0)? 0 : ($HITS / $TOTAL);
         }
         else {
            $SCORES{"$CP::CPEXT-STMi-".$i} = 0;
            $TOTAL += (defined($Tref->{subtrees}->[$i])? Overlap::compute_total($Tref->{subtrees}->[$i]) : 0) +
                      (defined($Tout->{subtrees}->[$i])? Overlap::compute_total($Tout->{subtrees}->[$i]) : 0);
      	    $SCORES{"$CP::CPEXT-STM-".$i} = Common::safe_division($HITS, $TOTAL);
         }
         $i++;
      }
      #$SCORES{"$CP::CPEXT-STM(*)"} =  ($TOTAL == 0)? 0 : ($HITS / $TOTAL);
   }

   #Overlap (Gimenez and Marquez, 2007)
   # $CP::CPEXT-Oc(*)  -----------------------------------------------------------------------------
   my $HITS = 0;   my $TOTAL = 0;   my %F;
   foreach my $C (keys %{$Tout->{tags}->{C}}) { $F{$C} = 1; }
   foreach my $C (keys %{$Tref->{tags}->{C}}) { $F{$C} = 1; }
   foreach my $C (keys %F) {
      my ($hits, $total) = Overlap::compute_overlap($Tout->{tags}->{C}->{$C}->{W}, $Tref->{tags}->{C}->{$C}->{W}, $LC);
      $SCORES{"$CP::CPEXT-Oc($C)"} = ($total == 0)? 0 : ($hits / $total);
      $HITS += $hits; $TOTAL += $total;
   }
   $SCORES{"$CP::CPEXT-Oc(*)"} = ($TOTAL == 0)? 0 : ($HITS / $TOTAL);

   # $CP::CPEXT-Op(*)  -----------------------------------------------------------------------------
   $HITS = 0;   $TOTAL = 0;   my %ADD;   my %TADD;   %F = ();
   foreach my $P (keys %{$Tout->{tags}->{P}}) { $F{$P} = 1; }
   foreach my $P (keys %{$Tref->{tags}->{P}}) { $F{$P} = 1; }
   foreach my $P (keys %F) {
      my ($hits, $total) = Overlap::compute_overlap($Tout->{tags}->{P}->{$P}->{W}, $Tref->{tags}->{P}->{$P}->{W}, $LC);
      $SCORES{"$CP::CPEXT-Op($P)"} = ($total == 0)? 0 : ($hits / $total);
      $HITS += $hits; $TOTAL += $total;
      #POS-spacat ---> aop, aos, aqn, aqp, aqs, cc, cs, dn, dp, ds, F, i, n0, nn, np, ns, p0, pn, pp, ps, rg, rn, sps, v0g, v0n, vpi, vpm, vpp, vps, vsi, vsm, vsp, vss, w, z
      #if (($LANG eq $Common::L_SPA) or ($LANG eq $Common::L_CAT)) {
      if (($LANG eq $Common::L_SPA)) {
         if ($P =~ /^[Aa].*/) { $ADD{"A"} += $hits; $TADD{"A"} += $total; }
         elsif ($P =~ /^[Cc].*/) { $ADD{"C"} += $hits; $TADD{"C"} += $total; }
         elsif ($P =~ /^[Dc].*/) { $ADD{"D"} += $hits; $TADD{"D"} += $total; }
         elsif ($P =~ /^[Ff].*/) { $ADD{"F"} += $hits; $TADD{"F"} += $total; }
         elsif ($P =~ /^[Ii].*/) { $ADD{"I"} += $hits; $TADD{"I"} += $total; }
         elsif ($P =~ /^[Nn].*/) { $ADD{"N"} += $hits; $TADD{"N"} += $total; }
         elsif ($P =~ /^[Pp].*/) { $ADD{"P"} += $hits; $TADD{"P"} += $total; }
         elsif ($P =~ /^[Ss].*/) { $ADD{"S"} += $hits; $TADD{"S"} += $total; }
         elsif ($P =~ /^[Vv].*/) { $ADD{"V"} += $hits; $TADD{"V"} += $total; }
         elsif ($P =~ /^[Vv][Aa].*/) { $ADD{"VA"} += $hits; $TADD{"VA"} += $total; }
         elsif ($P =~ /^[Vv][Ss].*/) { $ADD{"VS"} += $hits; $TADD{"VS"} += $total; }
         elsif ($P =~ /^[Vv][Mm].*/) { $ADD{"VM"} += $hits; $TADD{"VM"} += $total; }
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
   $SCORES{"$CP::CPEXT-Op(*)"} = ($TOTAL == 0)? 0 : ($HITS / $TOTAL);

   foreach my $P (keys %TADD) {
      $SCORES{"$CP::CPEXT-Op($P)"} = ($TADD{$P} == 0)? 0 : ($ADD{$P} / $TADD{$P});
   }

   return \%SCORES;
}

sub FILE_compute_overlap_metrics {
   #description _ computes CHUNK scores (single reference)
   #param1 _ candidate list of parsed sentences (+features)
   #param2 _ reference list of parsed sentences (+features)
   #param3 _ language
   #param4 _ do_lower_case evaluation ( 1:yes -> case_insensitive  ::  0:no -> case_sensitive )

   my $FOUT = shift;
   my $FREF = shift;
   my $LANG = shift;
   my $LC = shift;

   #print Dumper($FOUT);
   #print Dumper($FREF);

   my @SCORES;
   my $topic = 0;
   while ($topic < scalar(@{$FREF})) {
      #print "*********** ", $topic + 1, " / ", scalar(@{$FREF}), "**********\n";
      #print Dumper $FOUT->[$topic];
      my $OUTSNT = SNT_extract_features($FOUT->[$topic]);
      #print Dumper $OUTSNT;
      #print "---------------------------------------------------------\n";
      #print Dumper $FREF->[$topic];
      my $REFSNT = SNT_extract_features($FREF->[$topic]);
      #print Dumper $REFSNT;
      #print "---------------------------------------------------------\n";
      $SCORES[$topic] = SNT_compute_overlap_scores($OUTSNT, $REFSNT, $LANG, $LC);
      #print Dumper $SCORES[$topic];
      #foreach my $f (keys %{$SCORES[$topic]}) { $FEATURES{$f} = 1; }
      $topic++;
   }

   return \@SCORES;
}

sub parse_FULL
{
    #description _ responsible for FULL PARSING (by calling Charniak-Johnson's
    #                                            MaxEnt reranking parser)
    #              <s> sentence </s>  ->  (parse_tree)
    #param1  _ IQMT TOOL directory pathname
    #param2  _ parsing LANGUAGE 1
    #param3  _ case 1
    #param4  _ input file
    #param5  _ shallow parser (object)
    #param6  _ verbosity (0/1)
    #@return _ parsed forest (list -> one item per tree)

    my $IQMT = shift;
    my $L = shift;
    my $C = shift;
    my $input = shift;
    my $parser = shift;
    my $verbose = shift;

    # -------------------------------------------------------------------------

    my $CPfile = $input.".$CP::CPEXT";
    my $FILE;

    if (exists($CP::rLANG->{$L})) {
       if ($L eq $Common::L_ENG) {
          if ((!(-e $CPfile)) and (!(-e "$CPfile.$Common::GZEXT"))) { 
             my $SinputS = $input.".$CP::CPEXT.SS";
             prepare4charniak($input, $SinputS);
             # -K to avoid tokenization
             Common::execute_or_die("cd $Common::DATA_PATH; $IQMT/$CP::ENGTOOL/first-stage/PARSE/parseIt -l999 -N50 -K $IQMT/$CP::ENGTOOL/first-stage/DATA/EN/ $SinputS | $IQMT/$CP::ENGTOOL/second-stage/programs/features/best-parses -l $IQMT/$CP::ENGTOOL/second-stage/models/ec50spfinal/features.gz $IQMT/$CP::ENGTOOL/second-stage/models/ec50spfinal/cvlm-l1c10P1-weights.gz > $CPfile 2> /dev/null", "[ERROR] problems running $L constituency parser...");
             system "rm -f $SinputS";
          }
          $FILE = read_CHARNIAK_BERKELEY_parsing($input, $CPfile, $L);
       }
       elsif ($L eq $Common::L_FRN ) {
          if ((!(-e $CPfile)) and (!(-e "$CPfile.$Common::GZEXT"))) { 
             my $inputBKY = $input.".$CP::CPEXT.BKY";
             prepare4berkeley($input, $inputBKY);
             #print STDERR "\ncat $inputBKY | $IQMT/$CP::FRETOOL/bin/bonsai_bky_parse.sh -n -f const -l fr > $CPfile\n";
             Common::execute_or_die("cat $inputBKY | $IQMT/$CP::FRETOOL/bin/bonsai_bky_parse.sh -n -f const -l fr > $CPfile", "[ERROR] problems running $L constituency parser...");
             system "rm -f $inputBKY";
          }
          $FILE = read_CHARNIAK_BERKELEY_parsing($input, $CPfile, $L);
       }
       elsif ($L eq $Common::L_GER ) {
          if ((!(-e $CPfile)) and (!(-e "$CPfile.$Common::GZEXT"))) { 
             my $inputBKY = $input.".$CP::CPEXT.BKY";
             prepare4berkeley($input, $inputBKY);
             print STDERR "\ncat $inputBKY | java -Xmx1800m -jar $IQMT/$CP::GERTOOL/berkeleyParser.jar -accurate -gr $IQMT/$CP::GERTOOL/data/ger_sm5.gr > $CPfile \n";
             Common::execute_or_die("cat $inputBKY | java -Xmx1024m -jar $IQMT/$CP::GERTOOL/berkeleyParser.jar -accurate -gr $IQMT/$CP::GERTOOL/data/ger_sm5.gr > $CPfile 2>$CPfile.err", "[ERROR] problems running $L constituency parser...");
             #system "rm -f $inputBKY";
	     #system "rm -f $CPfile.err";
          }
          $FILE = read_CHARNIAK_BERKELEY_parsing($input, $CPfile, $L);
       }
       #mgb collins parser not publicly available... only allowed to JGimenez
       elsif ($L eq $Common::L_SPA) {
          if ((!(-e $CPfile)) and (!(-e "$CPfile.$Common::GZEXT"))) {
             my $ftagged = $input.".$SP::SPEXT.WPc";
             my $fparsed = $input.".$CP::CPEXT.ascii";
             my $f4c = $ftagged.".4c";
             my $f4cascii = $f4c.".ascii";
	     
             if ((!(-e $ftagged)) and (!(-e "$ftagged.$Common::GZEXT"))) {
                SP::FILE_PoS_tag_and_lemmatize($input, $parser, $IQMT, $L."/4c", $C, 1, $verbose);
             }
             if (-e "$ftagged.$Common::GZEXT") { system("$Common::GUNZIP $ftagged.$Common::GZEXT"); }

             prepare4collins($ftagged, $f4c);

             #system "$IQMT/$CP::SPATOOL/utils/latin12ascii.o < $f4c > $f4cascii";
             system "$IQMT/$CP::SPATOOL/utils/latin12ascii.2.o < $f4c > $f4cascii";
             system "$IQMT/$CP::SPATOOL/sp_parser/parser $f4cascii $IQMT/$CP::SPATOOL/model/whole_grammar 10000 1 1 1 1 < $IQMT/$CP::SPATOOL/events/whole_corpus.events | grep '(TOP' > $fparsed";
             system "$IQMT/$CP::SPATOOL/utils/ascii2latin1.o < $fparsed > $CPfile";

             system "rm -rf $f4c";
             system "rm -rf $f4cascii";
             system "rm -rf $fparsed";
             system("$Common::GZIP $ftagged");
          }
          $FILE = read_COLLINS_parsing($input, $CPfile);
       }
    }
    else { die "[CP] tool for <$L> unavailable!!!\n"; }

    #print Dumper $FILE;

    system("$Common::GZIP $CPfile");

    return $FILE;
}

sub read_COLLINS_parsing
{
    #description _ responsible for reading Collins' parser output into memory
    #param1  _ input file
    #param2  _ input parsed file
    #@return _ parsed forest (list -> one item per tree)

    my $input = shift;
    my $CPfile = shift;

    my @FILE;


    if ((!(-e $CPfile)) and (-e "$CPfile.$Common::GZEXT")) { system("$Common::GUNZIP $CPfile.$Common::GZEXT"); }

    open(IN, "< $input") or die "couldn't open file: $input\n";
    open(CP, "< $CPfile") or die "couldn't open file: $CPfile\n";

    #PRESIDENCIA DEL CHAIR: MR ONYSZKIEWICZVice-President
    #----------------------------------------------------
    #(TOP~PRESIDENCIA~1~1
    #  (S~PRESIDENCIA~2~1
    #    (sn~PRESIDENCIA~1~1
    #      (grup~PRESIDENCIA~2~1
    #        (grup~PRESIDENCIA~1~1 PRESIDENCIA/n0.pos ) 
    #        (sn~CHAIR:~1~1
    #          (grup~CHAIR:~2~2 DEL/n0.pos CHAIR:/n0.pos )
    #        )
    #      )
    #    )
    #    (sn~ONYSZKIEWICZVice-President~1~1
    #      (grup~ONYSZKIEWICZVice-President~2~2 MR/n0.pos ONYSZKIEWICZVice-President/n0.pos )
    #    )
    #  )
    #)

    #empty parse tree <-- failed
    #TIME 0
    #PROB 0 0 0
    #(TOP~blah~1~1 (S~blah~1~1 word-1/pos-1 ... word-n/pos-n ) )

    while (my $line = <CP>) {
       if ($line =~ /^\(TOP/) {
          #print $line;
          chomp($line);
          my $in = <IN>; chomp($in);
          my @tree = ("*START*", 0);
          if (!(($in =~ /^$/) or ($in =~ /^[!?.]$/))) {
             #print $line;
             my @entry = split(/ +/, $line);
             #print Dumper \@entry;
             my $depth = 0;
             my $root = \@tree;
             my $i = 0;
             while ($i < scalar(@entry)) {
                if ($entry[$i] =~ /\(.*/) { # OPEN-tag
                   my @T = split("~", $entry[$i]);
                   my $tag = $T[0]; $tag =~ s/\(//g;
                   my @node = ($tag, $root);
                   push(@{$root->[2]}, \@node);
                   $root = \@node;
                   $depth++;
   	            }
                elsif ($entry[$i] =~ /.*\)/) { # CLOSE-tag
                   $root = $root->[1];
                }
                else { # INSIDE    "word/PoS"
                   my @T = split("/", $entry[$i]);
                   my $tag = $T[1]; $tag =~ s/\.pos//g;
                   my $word = $T[0];
                   my @node = ($tag, $root);
                   my @child = ($word, \@node);
                   push(@{$node[2]}, \@child);
                   push(@{$root->[2]}, \@node);
                }
                $i++;
             }
          }
          push(@FILE, \@tree);
          collapse_grups(\@tree);
       }
    }
    close(CP);
    close(IN);

    return \@FILE;
}

sub collapse_grups {
   #description _ collapse "grup" tags hanging below the given node in the syntactic tree.
   #param1 _ tree object

   my $node = shift;

   if (defined($node)) {
      if ($node->[0] =~ /grup.*/) {
         my $parent = $node->[1];
         my $i = 0; my $found = 0;
         while (($i < scalar(@{$parent->[2]})) and (!$found)) {
            if ($parent->[2]->[$i] == $node) { splice(@{$parent->[2]}, $i, 1); $found = 1; }
            else { $i++; }
         }
         if (defined($node->[2])) {
            my $children = $node->[2];
            foreach my $child (@{$children}) {
               $child->[1] = $parent;
               #push(@{$parent->[2]}, $child);
               #unshift(@{$parent->[2]}, $child);
               splice(@{$parent->[2]}, $i, 0, $child);
               $i++;
            }
         }
      }
      if (defined($node->[2])) {
         my $children = $node->[2];
         foreach my $child (@{$children}) {
            my @chain;
            collapse_grups($child);
         }
      }
   }

   return $node;
}

sub read_CHARNIAK_BERKELEY_parsing
{
    #description _ responsible for reading Charniak's parser output into memory
    #param1  _ input file
    #param2  _ input parsed file
    #param3  _ language/output format (en = charniak, [fr|de] = berkeley)
    #@return _ parsed forest (list -> one item per tree)

    my $input = shift;
    my $CPfile = shift;
    my $L = shift;

    my @FILE;

    if ((!(-e $CPfile)) and (-e "$CPfile.$Common::GZEXT")) { system("$Common::GUNZIP $CPfile.$Common::GZEXT"); }

    #print "IN is $input\n";
    #print "CP is $CPfile\n";
    open(IN, "< $input") or die "couldn't open file: $input\n";
    open(CP, "< $CPfile") or die "couldn't open file: $CPfile\n";

    while (my $line = <CP>) {
       chomp($line);

       if ( $L eq $Common::L_FRN or $L eq $Common::L_GER ){
          #remove extra root that favors higher scores in BERKELEY PARSING
          $line =~ s/^\( \(ROOT/(ROOT/;
          $line =~ s/\) \)$/)/;
       }
 
       my $in = <IN>; chomp($in);
       
       my @tree = ("*START*", 0);
       if (!(($in =~ /^$/) or ($in =~ /^[!?.]$/))) {
          my @entry = split(/ +/, $line);
          my @segment = split(/ +/, $in);
          my $segidx=0;
          my $depth = 0;
          my $root = \@tree;
          my $i = 0;
          while ($i < scalar(@entry)) {
             if ($entry[$i] =~ /\(.*/) { # OPEN-tag
                my $tag = $entry[$i]; $tag =~ s/\(//g;
                my @node = ($tag, $root);
                push(@{$root->[2]}, \@node);
                $root = \@node;
                $depth++;
             }
            elsif ($entry[$i] =~ /.*\)/) { # CLOSE-tag		
                if ( defined($segment[$segidx]) && $segment[$segidx] =~ m/\)/ ){ 
                   #remove ) in the lexical entry
                   my $newtok = $segment[$segidx];
                   $newtok =~ s/\)/*RRB*/g;
                   $entry[$i] =~ s/\Q$segment[$segidx]\E/$newtok/;
                }  
                my $count = 0;
                my @chars = split(//, $entry[$i]);
                foreach my $letter (@chars) { if ($letter eq ')') { $count++; } }
                my $tag = $entry[$i]; $tag =~ s/\)//g;
                my @node = ($tag, $root);
                push(@{$root->[2]}, \@node);
                my $j = 0; while ($j < $count) { $root = $root->[1]; $j++; }
                $segidx++;
             }
           $i++;
          }
       }
       push(@FILE, \@tree);
    }
    close(CP);
    close(IN);

    return \@FILE;
}




sub prepare4berkeley {
    #description _ responsible for adapting input file to a format
    #             that's convenient for bonsai-berkeley's parser (jsut tokenized text).
    #param1  _ input file
    #param2  _ output file

    my $input = shift;
    my $output = shift;

    open(IN, "< $input") or die "couldn't open file: $input\n";
    open(OUT, "> $output") or die "couldn't open file: $output\n";
    binmode(IN, ":utf8");
    binmode(OUT, ":utf8");
    while (my $line = <IN>) {
       chomp($line);
       $line =~ s/ \( / *LRB* /g;
       $line =~ s/ \) / *LRB* /g;
       $line =~ s/ +/ /g;
       $line =~ s/^ //g;
       $line =~ s/ $//g;
       $line =~ s/^\( /*LRB* /g;
       $line =~ s/ \)$/ *LRB*/g;
       $line =~ s/\s+/ /g;
       print OUT "$line\n";
    }
    close(OUT);
    close(IN);
}


sub prepare4charniak {
    #description _ responsible for adapting input file to a format
    #             that's convenient for Charniak's parser (<s> ... </s>)
    #param1  _ input file
    #param2  _ output file

    my $input = shift;
    my $output = shift;

    open(IN, "< $input") or die "couldn't open file: $input\n";
    open(OUT, "> $output") or die "couldn't open file: $output\n";

    while (my $line = <IN>) {
       chomp($line);
       if ($line =~ /^$/) { $line = $CP::EMPTY_ITEM." "."."; }
       elsif ($line =~ /^[!?.]$/) { $line = $CP::EMPTY_ITEM." ".$line; }
     	 elsif ($line =~ m/^[\s[:punct:]]*$/ ){ $line = $CP::EMPTY_ITEM." ".$line; }
       else { #check sentence length
          my @L = split(" ", $line);
          if (scalar(@L) > $CP::SNTLEN_CHARNIAK) { 
             while (scalar(@L) > $CP::SNTLEN_CHARNIAK) { pop(@L); }
             $line = join(" ", @L);
	   	}
	   	$line =~ s/ \( / -mgbLRB- /g;
		   $line =~ s/ \) / -mgbRRB- /g;
		   $line =~ s/\(/-lrb-/g;
		   $line =~ s/\)/-rrb-/g;
	   	$line =~ s/ -mgbLRB- / ( /g;
	   	$line =~ s/ -mgbRRB- / ) /g;
       }
       print OUT "<s> ".$line." </s>\n";
    }
    close(OUT);
    close(IN);
}

sub prepare4collins {
    #description _ responsible for adapting PoS tagged file to a format
    #             that's convenient for Collins' parser (WORD PoS.pos)
    #param1  _ input file
    #param2  _ output file

    my $input = shift;
    my $output = shift;

    open(IN, "< $input") or die "couldn't open file: $input\n";
    open(OUT, "> $output") or die "couldn't open file: $output\n";

    my $numline=1;
    while (my $line = <IN>) {
       chomp($line);
       my @wp = split(" ", $line);
       my @snt;
       #foreach my $elem (@wp) {
       my $i = 0;
       while (($i < scalar(@wp)) and ((scalar(@snt) / 2) < $CP::SNTLEN_COLLINS)) {
          my $elem = $wp[$i];
          my @laux = split($SP::POSSEP, $elem);
          my $word = $laux[0];                             #($laux[0] eq "(")? "LPAREN" : ($laux[0] eq ")")? "RPAREN" : $laux[0];
          $word =~ s/\(/LPAREN/g; $word =~ s/\)/RPAREN/g;
          my $pos = $laux[1];
          if ($pos =~ "^F.*") { $pos = "F"; }
          else {
	     $pos = lc($pos);
	     
             if ($pos eq "spc") { #contracciones ---
	         if ($word ne "l") {
                   my @celem = split("(l)", $word);
                   push(@snt, $celem[0]);
                   push(@snt, "sps.pos");
                   $word = "el";
                   $pos = "ds"; 
                } 
                else { $pos = "ds"; }
             }
             elsif ($pos eq "pc") { $pos = "pn"; }
             elsif ($pos eq "nc") { $pos = "ns"; }
             elsif ($pos eq "a00") { $pos = "aq0"; }
             elsif ($pos eq "v0i") { $pos = "vsi"; }
             elsif ($pos eq "vcn") { $pos = "v0n"; }
             elsif ($pos eq "aqc") { $pos = "aqs"; }
             elsif ($pos eq "dc") { $pos = "dn"; }
             elsif ($pos eq "ao") { $pos = "aos"; }
             elsif ($pos =~ "pp.*") { $pos = "pp"; }
	     elsif ($pos eq "pd0") { $pos = "ps"; }
	     elsif ($pos eq "sp") { $pos = "sps"; }
	     elsif ($pos eq "di") { $pos = "ds"; }
	     elsif ($pos eq "pi") { $pos = "ps"; }

             $pos .= ".pos";
          }
          # ---
          #push(@snt, $word);
	  
          my $w = Common::latinize($word);
          if ($w ne "") {
             push(@snt, $w);
    	     push(@snt, $pos);
          }
          $i++;
       }
       unshift(@snt, scalar(@snt) / 2);
       print OUT join(" ", @snt), "\n";
       $numline++;
    }

    close(OUT);
    close(IN);
}


sub delete_node {
   #description _ deletes a tree node (free memory)

   my $node = shift;

   if (defined($node->[2])) { foreach my $child (@{$node->[2]}) { delete_node($child, 0); } }
   undef @{$node};
}

sub delete_FOREST {
   #description _ deletes a forest of parse trees (free memory)
   #param1 _ input forest (list reference)

   my $F = shift;

   my $i = 0; while ($i < scalar(@{$F})) { delete_node($F->[$i]); $i++; }
}





sub doMultiCP {
   #description _ computes CP scores (multiple references)
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
   #if (($L eq $Common::L_SPA) or ($L eq $Common::L_CAT)) { $rF = $CP::rCPspacat; } # SPANISH / CATALAN
   if (($L eq $Common::L_SPA)) { $rF = $CP::rCPspacat; } # SPANISH / CATALAN
   elsif ($L eq $Common::L_FRN ) { $rF = $CP::rCPfrench; } #FRENCH
   elsif ($L eq $Common::L_GER ) { $rF = $CP::rCPgerman; } #GERMAN
   else { $rF = $CP::rCPeng; } #ENGLISH

   my $GO_ON = 0;
   foreach my $metric (keys %{$rF}) {
      if ($M->{$metric}) { $GO_ON = 1; }
   }

   if ($GO_ON) {
      if ($verbose == 1) { print STDERR "$CP::CPEXT.."; }

      my $DO_METRICS = $remakeREPORTS;
      if (!$DO_METRICS) {
         foreach my $metric (keys %{$rF}) {
            my $report_xml = "$Common::DATA_PATH/$Common::REPORTS/$TGT/$REF/$metric.$Common::XMLEXT";
            if ($M->{$metric} and !(-e $report_xml) and !(-e $report_xml.".$Common::GZEXT")) { $DO_METRICS = 1; }
         }
      }

      if ($DO_METRICS) {
         my $Fout = CP::parse_FULL($tools, $L, $C, $out, $parser, $verbose);
         my @maxscores;

         foreach my $ref (keys %{$Href}) {
            my $Fref = CP::parse_FULL($tools, $L, $C, $Href->{$ref}, $parser, $verbose);
            my $scores = CP::FILE_compute_overlap_metrics($Fout, $Fref, $L, ($C ne $Common::CASE_CI));
            delete_FOREST($Fref); 
            foreach my $metric (keys %{$rF}) {
  	          if ($M->{$metric}) {
                  my ($MAXSYS, $MAXSEGS) = Overlap::get_segment_scores(\@maxscores, $metric, 0);
                  my ($SYS, $SEGS) = Overlap::get_segment_scores($scores, $metric, 0); 
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
	     }
         delete_FOREST($Fout);

         foreach my $metric (keys %{$rF}) {
            if ($M->{$metric}) {
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
      }
   }
}

1;

