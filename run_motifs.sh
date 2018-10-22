#!/bin/bash
## simple regulation, negative and positive autoregulation
{ time swipl -l motifcodes/srnarpar.pl > output/srnarpar-out.txt 2>output/srnarpar-err.txt ; } 2>output/srnarpar-time.txt
## bi-fan with two promoters and two repressors
{ time swipl -l motifcodes/bifana.pl > output/bifana-out.txt 2>output/bifana-err.txt ; } 2>output/bifana-time.txt
## bifan with three promoters and one repressor
{ time swipl -l motifcodes/bifanb.pl > output/bifanb-out.txt 2>output/bifanb-err.txt ; } 2>output/bifanb-time.txt
## coherent feed-forward loop
{ time swipl -l motifcodes/cffl1.pl > output/cffl1-out.txt 2>output/cffl1-err.txt ; } 2>output/cffl1-time.txt
## incoherent feed-forward loop
{ time swipl -l motifcodes/iffl1.pl > output/iffl1-out.txt 2>output/iffl1-err.txt ; } 2>output/iffl1-time.txt
## single input module
{ time swipl -l motifcodes/single.pl > output/single-out.txt 2>output/single-err.txt ; } 2>output/single-time.txt
