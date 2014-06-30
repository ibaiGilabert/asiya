package AsiyaAPI;

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
use IQ::Scoring::Metrics;
use IQ::MetaScoring::MetaMetrics;
use IQ::InOut::TeX;

sub process_configuration ($) {
	#description _ process configuration options
	#param1  _ configuration options
	
    my $config = shift;

    # ============= NAMES ===============================================================
    Metrics::do_metric_names($config);
    Metrics::do_system_names($config);
    Metrics::do_reference_names($config);

    # ============ TERMINATE ============================================================
    Config::terminate($config);
    # ============= COMPUTE ALIGNMENTS (if necessary) =======================================
    Metrics::do_alignments($config);
    # ============= COMPUTE SCORES (if necessary) =======================================
    my %hOQ;
    Metrics::do_scores($config, \%hOQ);
    # ============= LEARNING ============================================================
    Metrics::do_learning($config);
    # ============= EVALUATION ==========================================================
    Metrics::do_eval($config, \%hOQ);
    # ============= META-EVALUATION =====================================================
    MetaMetrics::do_metaeval($config);
    # ============= OPTIMIZATION ========================================================
    Metrics::do_optimization($config);
    # ============= REPORT GENERATION ===================================================
    TeX::generate_pdf($config);
    TeX::show_pdf($config);
    # ===================================================================================
    Config::finish_asiya($config);
    # ===================================================================================
}

1;
