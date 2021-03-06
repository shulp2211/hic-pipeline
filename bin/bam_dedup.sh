#! /usr/bin/env bash
# bam_dedup.sh
################
# This script will dedup the bam file. 

set -e 

BIN=$(dirname $0)

function usage(){
echo -e "Usage: $0" 
}

## processing the command options
while getopts ":n:s:h:" OPT
do
    case $OPT in
    n) ID=$OPTARG;;
    s) samtools=$OPTARG;;
    h) help ;;
    \?)
         echo "Invalid option: -$OPTARG" >&2
         usage
         exit 1
         ;;
     :)
         echo "Option -$OPTARG requires an argument." >&2
         usage 
         exit 1 
         ;; 
    esac
done

## beginning the scripts
echo "$(date) Entering $(basename $0)"
MARK_DUP="java -jar $BIN/../lib/MarkDuplicates.jar"

SECONDS=0
$MARK_DUP INPUT=$ID.raw.bam  OUTPUT=$ID.dedup.bam ASSUME_SORTED=true REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=LENIENT TMP_DIR=tmp METRICS_FILE=log/$ID.metrics.log &> log/$ID.markdup.log
grep ^LIBRARY -A 1 log/$ID.metrics.log
$samtools index $ID.dedup.bam
$samtools flagstat $ID.dedup.bam > qc/$ID.dedup.flagstat
grep -H ^[1-9] qc/$ID.dedup.flagstat

echo -en "$(date) Leaving $(basename $0);\t"
echo "$(date -u -d @"$SECONDS" +'%-Hh %-Mm %-Ss') elapsed"


