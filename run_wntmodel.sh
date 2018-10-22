#!/bin/bash
{ time swipl -l WntModel.pl > output/WntModel-out.txt 2>output/WntModel-err.txt ; } 2>output/WntModel-time.txt
