#!/bin/bash

## Script for expanding L2 elements to full-length coordinates using Dfam annotation
## Date: February 2026

## Example usage:
##
## l2PASDir=L2_with_PAS \
## dfamFile=/Shares/CL_Shared/db/genomes/hg38/repeats/hg38.dfam.fa.out \
## outDir=L2_with_PAS_expanded \
## sbatch L2_expand_coordinates.sbatch

# General settings
#SBATCH -p short
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --time=2:00:00
#SBATCH --mem=16GB

# Job name and output
#SBATCH -J L2_expand_coordinates
#SBATCH -o /scratch/Users/%u/data/slurmOut/slurm-%j.out
#SBATCH -e /scratch/Users/%u/data/slurmErr/slurm-%j.err

# Load modules
module load python/3.6.3

# Make output directory
pwd; hostname; date

echo "Making output directories..."
mkdir -p ${outDir}

# Step 1: Subset the Dfam file for L2 elements of interest
echo $(date +"[%b %d %H:%M:%S] Subsetting Dfam file for L2 elements with PAS...")
inDir=${l2PASDir} outDir=${outDir} dfamFile=${dfamFile} bash subset_dfam_for_L2_of_interest.sh

# Step 2: Expand each L2 subfamily to full-length coordinates
echo $(date +"[%b %d %H:%M:%S] Expanding L2 elements to full-length coordinates...")
for i in L2 L2a L2b L2c L2d L2d2; do
    echo $(date +"[%b %d %H:%M:%S] Expanding ${i}...")
    python3 repeats_createExpandedRepeatFile_dfam.py \
        -i ${outDir}/${i}_subset.dfam.out \
        -f ${i} \
        > ${outDir}/${i}_expanded_dfam.bed
done

echo $(date +"[%b %d %H:%M:%S] Done!")

