#!/bin/bash

## Script for downloading the PolyASite 3.0 atlas and converting to bigWig
## Date: February 2026

## Example usage:
## outDir=polyasite_atlas \
## sbatch polyasite_download_and_convert.sbatch

# General settings
#SBATCH -p short
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --time=2:00:00
#SBATCH --mem=16GB

# Job name and output
#SBATCH -J polyasite_download
#SBATCH -o /scratch/Users/%u/data/slurmOut/slurm-%j.out
#SBATCH -e /scratch/Users/%u/data/slurmErr/slurm-%j.err

# Load modules
module load bedtools

# Define key variables
chromSizes=/Shares/CL_Shared/db/genomes/hg38/fa/hg38.main.chrom.sizes
atlasURL=https://polyasite.unibas.ch/download/atlas/3.0/GRCh38.GENCODE_42/atlas.clusters.3.0.GRCh38.GENCODE_42.bed.gz
atlasBed=atlas.clusters.3.0.GRCh38.GENCODE_42.bed

# Make output directory
pwd; hostname; date

echo "bedtools version: "$(bedtools --version)

echo "Making output directories..."
mkdir -p ${outDir}
cd ${outDir}

# Download the PolyASite 3.0 atlas
echo $(date +"[%b %d %H:%M:%S] Downloading PolyASite 3.0 atlas...")
wget ${atlasURL}

# Uncompress
echo $(date +"[%b %d %H:%M:%S] Uncompressing...")
gunzip ${atlasBed}.gz

# Convert BED to bedGraph, weighted by average RPM expression (column 5)
echo $(date +"[%b %d %H:%M:%S] Converting BED to bedGraph...")
awk 'OFS="\t" {print $1, $2, $3, $5}' ${atlasBed} > polyasite_RPM.bedGraph

# Sort bedGraph
echo $(date +"[%b %d %H:%M:%S] Sorting bedGraph...")
bedtools sort -i polyasite_RPM.bedGraph > polyasite_RPM.sorted.bedGraph

# Merge overlapping regions, taking the maximum signal
echo $(date +"[%b %d %H:%M:%S] Merging overlapping regions...")
bedtools merge -i polyasite_RPM.sorted.bedGraph -c 4 -o max > polyasite_RPM.merged.bedGraph

# Convert to bigWig
echo $(date +"[%b %d %H:%M:%S] Converting to bigWig...")
/Shares/CL_Shared/programs/ucsc/bedGraphToBigWig \
    polyasite_RPM.merged.bedGraph \
    ${chromSizes} \
    polyasite_RPM.bw

echo $(date +"[%b %d %H:%M:%S] Done!")
