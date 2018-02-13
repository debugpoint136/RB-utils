#!/bin/bash

INPUT_FILE=$1
UUID=$(python  -c 'import uuid; print uuid.uuid1()')
REFERENCE_GENOME="hg19"

ARTIFACTS_DIR="/home/dpurush/hts/artifacts"
EXEC_BIN="/home/dpurush/bin"
CPG_BED="CpG_no_contig.bed"
SIZE_FILE="hg19_lite.size"

/bin/cat <<EOM >>README
$UUID   $INPUT_FILE
EOM

mkdir $UUID
cd $UUID
ln -s ../$INPUT_FILE .

/bin/cat <<EOM >README
Filename    uuid
$INPUT_FILE $UUID
EOM

/bin/cat <<EOM >Q
squeue -u dpurush
EOM

SCRIPT1="fastq-sam.sh"

/bin/cat <<EOM >$SCRIPT1
#!/bin/sh
#SBATCH --job-name=BWA-$UUID
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --time=168:00:00
#SBATCH --mem=36gb
#SBATCH --output=BWA.$UUID.%J.out
#SBATCH --error=BWA.$UUID.%J.err

module load bwa
bwa mem -a /scratch/ref/genomes/Homo_sapiens/UCSC/hg19/Sequence/BWAIndex/genome.fa $INPUT_FILE -t 8 > $UUID.bwa_mem_alignments.sam

sh sam-bam.sh
EOM


SCRIPT2="sam-bam.sh"

/bin/cat <<EOM >$SCRIPT2
#!/bin/sh

module load samtools

samtools view -bS $UUID.bwa_mem_alignments.sam > $UUID.bam
samtools sort -T temp_ "$UUID.bam" -o "$UUID.bam.sorted"

sh iteres.sh
sh methylQA-cpg-profile.sh
sh methylQA-density.sh
EOM

SCRIPT3="iteres.sh"

/bin/cat <<EOM >$SCRIPT3
#!/bin/sh

$EXEC_BIN/iteres stat $ARTIFACTS_DIR/$SIZE_FILE $ARTIFACTS_DIR/subfam.size $ARTIFACTS_DIR/rmsk.txt $UUID.bam

EOM

SCRIPT4="methylQA-cpg-profile.sh"

/bin/cat <<EOM >$SCRIPT4
#!/bin/sh

$EXEC_BIN/methylQA density $ARTIFACTS_DIR/$SIZE_FILE $UUID.bam

EOM

SCRIPT5="methylQA-density.sh"

/bin/cat <<EOM >$SCRIPT5
#!/bin/sh

$EXEC_BIN/methylQA medip $ARTIFACTS_DIR/$CPG_BED $ARTIFACTS_DIR/$SIZE_FILE $UUID.bam
EOM

sbatch $SCRIPT1

