#!/bin/bash

## Script for running fimo
## Date: April 13 2020

## Example usage:
## genomeName=hg38 pvalue=1e-4 motifFile=/Shares/CL_Shared/data/atma/QUARANTINE/fimo_test/meme_motifs/MA0106.1_P53.meme name=MA0106.1 outDir=/Shares/CL_Shared/data/atma/QUARANTINE/fimo_test/MA0106.1_P53.meme sbatch fimo.sbatch

# General settings
#SBATCH -p short
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --time=12:00:00
#SBATCH --mem=32GB

# Job name and output
#SBATCH -J fimo
#SBATCH -o /scratch/Users/%u/data/slurmOut/slurm-%j.out
#SBATCH -e /scratch/Users/%u/data/slurmErr/slurm-%j.err

# load modules
module load python/2.7.14/numpy/1.14.1
module load bedtools

# Define key variables
fastaFile=/Shares/CL_Shared/db/genomes/${genomeName}/fa/${genomeName}.main.fa
chromSizes=/Shares/CL_Shared/db/genomes/${genomeName}/fa/${genomeName}.main.chrom.sizes

# Make output directories
pwd; hostname; date

echo "fimo version: "$(fimo --version)
echo "bedtools version: "$(bedtools --version)

echo "Making output directories..."

mkdir -p ${outDir}/pval_${pvalue}

# Run fimo
echo $(date +"[%b %d %H:%M:%S] Running fimo...")

fimo \
--text \
--parse-genomic-coord \
--thresh ${pvalue} \
${motifFile} \
${fastaFile} \
> ${outDir}/pval_${pvalue}/${name}_${pvalue}.txt

# Convert output to bed & add pval as a file suffix
echo $(date +"[%b %d %H:%M:%S] Convert fimo output to bed format...")

/opt/python/2.7.14/bin/python2.7 /Shares/CL_Shared/scripts/ed/fimo_analysis.py \
-i ${outDir}/pval_${pvalue}/${name}_${pvalue}.txt \
-o ${outDir}/pval_${pvalue}

mv ${outDir}/pval_${pvalue}/${name}.bed ${outDir}/pval_${pvalue}/${name}_${pvalue}.bed 

# Create a bedgraph from the bed output
echo $(date +"[%b %d %H:%M:%S] Create a bedgraph from bed output...")

bedtools sort -i ${outDir}/pval_${pvalue}/${name}_${pvalue}.bed \
| bedtools merge -i - -o max -c 5 \
> ${outDir}/pval_${pvalue}/${name}_${pvalue}.bdg

# Create a bigwig from the bedgraph output
echo $(date +"[%b %d %H:%M:%S] Create a bigwig from bedgraph output...")

/Shares/CL_Shared/programs/ucsc/bedGraphToBigWig \
${outDir}/pval_${pvalue}/${name}_${pvalue}.bdg \
${chromSizes} \
${outDir}/pval_${pvalue}/${name}_${pvalue}.bw

echo $(date +"[%b %d %H:%M:%S] Done!")
