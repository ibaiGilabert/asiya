#$ -S /bin/bash
#$ -V
#$ -cwd
#$ -m eas
#$ -M gilabert@lsi.upc.edu
#$ -l h_vmem=4G


. /home/usuaris/gilabert/asiya/gpu/ASIYA12.04.PATH

which Asiya.pl

DATAPATH=/home/usuaris/gilabert/asiya/gpu/sample

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 1 ] || die "1 argument required: name of the metric family (i.e., BLEU, NIST, TER, PER, ..), $# provided."


i=$1

echo "Asiya.pl Asiya.config -v -eval single -metric_set metric_$i -data_path $DATAPATH > $i.report"
Asiya.pl Asiya.config -v -eval single -metric_set metrics_$i > $i.report





