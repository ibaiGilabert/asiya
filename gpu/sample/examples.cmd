-- Basic test, eval default the metrics

$Asiya.pl Asiya.config -eval single,ulc

-- test CE metrics

$Asiya.pl Asiya.config -metric_set metrics_CE_14 -eval single

-- test optimization

$Asiya.pl Asiya.config -optimize single pearson -assessments assessments.csv

-- test meta-evaluation

$Asiya.pl Asiya.config -metaeval single pearson -assessments assessments.csv -ci fisher 

-- test learning options

$ Asiya.pl Asiya.config -learn perceptron -assessments assessments.csv 





