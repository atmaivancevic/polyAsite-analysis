#!/bin/bash

## Script for overlapping L2 elements with PAS sites
## Date: February 2026

## Example usage:
## pasFile=polyasite_atlas/atlas.clusters.3.0.GRCh38.GENCODE_42.bed \
## l2Dir=L2_elements \
## outDir=L2_with_PAS \
## sbatch L2_overlap_PAS.sbatch

# General settings
#SBATCH -p short
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --time=2:00:00
#SBATCH --mem=16GB

# Job name and output
#SBATCH -J L2_overlap_PAS
#SBATCH -o /scratch/Users/%u/data/slurmOut/slurm-%j.out
#SBATCH -e /scratch/Users/%u/data/slurmErr/slurm-%j.err

# Load modules
module load bedtools

# Make output directory
pwd; hostname; date

echo "bedtools version: "$(bedtools --version)

echo "Making output directories..."
mkdir -p ${outDir}

# For each L2 subfamily, find elements overlapping an expressed PAS (score > 0.9)
echo $(date +"[%b %d %H:%M:%S] Overlapping L2 subfamilies with PAS (window=10bp, min expression=0.9)...")

summaryFile=${outDir}/L2_PAS_summary.txt
echo -e "Subfamily\tN_elements_with_PAS" > ${summaryFile}

for i in L2 L2a L2b L2c L2d L2d2; do
    echo $(date +"[%b %d %H:%M:%S] Processing ${i}...")

    bedtools window \
        -a ${l2Dir}/${i}.bed \
        -b ${pasFile} \
        -w 10 \
    | awk '{if ($11>0.9) print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $6 "\t" $10 "\t" $11}' \
    > ${outDir}/${i}_with_PAS_min0.9.bed

    # Count unique L2 elements with PAS
    n=$(awk '{print $1":"$2":"$3":"$4}' ${outDir}/${i}_with_PAS_min0.9.bed | sort | uniq | wc -l)
    echo -e "${i}\t${n}" >> ${summaryFile}
done

echo $(date +"[%b %d %H:%M:%S] Summary of L2 elements with expressed PAS:")
cat ${summaryFile}

echo $(date +"[%b %d %H:%M:%S] Done!")
