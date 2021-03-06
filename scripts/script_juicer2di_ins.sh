# "pairs2di_ins.sh"
#
###################
#set -x
set -e

SCP=$(dirname $0)
LIB=$SCP/../lib/
chr=$1
REF=$2
bin_size=$3
bin_num=$4
gnf=$5
sample=$6

mkdir -p $sample/matrix
cd $sample
chr_size=$(awk -v chr=$chr '{{if($1==chr)print $2}}' ${REF}.fa.fai)
# pairs to matrix
# ${SCP}/pairs2mat.awk -v chr=$chr -v bin_size=$bin_size \
#   -v chr_size=$chr_size ${sample}.valid_pairs.dedup.sorted.txt > \
#   matrix/${sample}.${chr}.asc

#extract matrix using straw
${LIB}/straw KR ${sample}.hic $chr $chr BP $bin_size |\
  ${SCP}/col2mat.awk -v chr=$chr -v bin_size=$bin_size -v chr_size=$chr_size \
  > matrix/${sample}.${chr}.norm.asc

# normalize matrix
#Rscript ${SCP}/asc2norm.R matrix/${sample}.${chr}.asc $gnf $chr #> \
#  matrix/${sample}.${chr}.norm.asc

# matrix to directionality index
Rscript $SCP/asc2di.R matrix/$sample.$chr.norm.asc $chr $bin_size $bin_num \
  matrix/${sample}.$chr.norm.DI
# matrix to insulation score
Rscript $SCP/mat2insulation.R  -m matrix/$sample.$chr.norm.asc  -b $bin_size \
  -w $((bin_size*bin_num)) -c $chr -o matrix/$sample.$chr.insulation.bed

