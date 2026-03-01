#!/bin/bash

## Script for characterizing TE loci with polyadenylation sites
## Date: February 2026

## Example usage:
## teFile=hg38.dfam.ucsc.filtered.bed \
## pasFile=atlas.clusters.3.0.GRCh38.GENCODE_42.bed \
## geneFile=gencode.v47.simple.bed \
## outDir=TE_contribution_analysis \
## sbatch te_pas_analysis.sbatch

# General settings
#SBATCH -p short
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --time=1:00:00
#SBATCH --mem=32GB

# Job name and output
#SBATCH -J te_pas_analysis
#SBATCH -o /scratch/Users/%u/data/slurmOut/slurm-%j.out
#SBATCH -e /scratch/Users/%u/data/slurmErr/slurm-%j.err

# Load modules
module load bedtools

# Make output directory
pwd; hostname; date

echo "bedtools version: "$(bedtools --version)

echo "Making output directories..."
mkdir -p ${outDir}

# Remove annotations on unknown/random chromosomes
echo $(date +"[%b %d %H:%M:%S] Filtering to main chromosomes...")
grep -v "chrUn\|_random\|_alt" ${teFile} > ${outDir}/hg38.dfam.ucsc.filtered.mainChrOnly.bed

# Overlap TEs with PAS, allowing a window of 10bp between them
echo $(date +"[%b %d %H:%M:%S] Overlapping TEs with PAS (window=10bp)...")
bedtools window -w 10 \
  -a ${outDir}/hg38.dfam.ucsc.filtered.mainChrOnly.bed \
  -b ${pasFile} \
  > ${outDir}/TEs_with_PAS.bed

# Uniqueify the list (eg collapse multiple PAS per TE into one line)
echo $(date +"[%b %d %H:%M:%S] Collapsing to unique TE loci...")
bedtools groupby \
  -i ${outDir}/TEs_with_PAS.bed \
  -g 1,2,3,4,5,6,7 \
  -c 8,9,10,11,12,13,14,15,16,17,18 \
  -o collapse,collapse,collapse,collapse,collapse,collapse,collapse,collapse,collapse,collapse,collapse \
  > ${outDir}/unique_TEs_with_PAS.bed

# Filter for expressed PAS (average expression > 0.9)
echo $(date +"[%b %d %H:%M:%S] Filtering for expressed PAS (score > 0.9)...")
awk '{if ($12>0.9) print}' ${outDir}/TEs_with_PAS.bed > ${outDir}/TEs_with_PAS_0.9.bed

# Uniqueify expressed subset
bedtools groupby \
  -i ${outDir}/TEs_with_PAS_0.9.bed \
  -g 1,2,3,4,5,6,7 \
  -c 8,9,10,11,12,13,14,15,16,17,18 \
  -o collapse,collapse,collapse,collapse,collapse,collapse,collapse,collapse,collapse,collapse,collapse \
  > ${outDir}/unique_TEs_with_PAS_0.9.bed

# Print summary statistics
echo $(date +"[%b %d %H:%M:%S] Summary statistics...")
total_TEs=$(wc -l < ${outDir}/hg38.dfam.ucsc.filtered.mainChrOnly.bed)
TEs_with_PAS=$(wc -l < ${outDir}/unique_TEs_with_PAS.bed)
TEs_expressed=$(wc -l < ${outDir}/unique_TEs_with_PAS_0.9.bed)
echo "Total TE loci: ${total_TEs}"
echo "TE loci with PAS: ${TEs_with_PAS} ($(echo "scale=1; ${TEs_with_PAS}/${total_TEs}*100" | bc)%)"
echo "TE loci with expressed PAS: ${TEs_expressed} ($(echo "scale=2; ${TEs_expressed}/${total_TEs}*100" | bc)% of all TEs)"

# Rank all TE-PAS by expression score and intersect with genes
echo $(date +"[%b %d %H:%M:%S] Ranking by expression score and intersecting with genes...")
sort -nrk12 ${outDir}/TEs_with_PAS.bed \
  > ${outDir}/All_TEderived_PAS_ranked_by_expression_score.bed

bedtools intersect \
  -a ${outDir}/All_TEderived_PAS_ranked_by_expression_score.bed \
  -b ${geneFile} -loj \
  > ${outDir}/All_TEderived_PAS_ranked_by_expression_score_with_genes.bed

# Per-class TE analysis
# Classify TEs into 5 supergroups: LINE, SINE, LTR, DNA, Other
echo $(date +"[%b %d %H:%M:%S] Per-class analysis...")

classify_by_class() {
  local inFile=$1
  local col=$2
  awk -v col=${col} '
  {
    cls = $col
    if (cls ~ /^LINE/) group = "LINE"
    else if (cls ~ /^SINE/) group = "SINE"
    else if (cls ~ /^(DNA|RC)/) group = "DNA"
    else if (cls ~ /^LTR/) group = "LTR"
    else group = "Other"
    counts[group]++
  } END { for (g in counts) print counts[g], g }' ${inFile} | sort -k2
}

echo "--- Total TE loci per class ---"
classify_by_class ${outDir}/hg38.dfam.ucsc.filtered.mainChrOnly.bed 6

echo "--- TE loci with PAS per class ---"
classify_by_class ${outDir}/unique_TEs_with_PAS.bed 6

echo "--- TE loci with expressed PAS per class ---"
classify_by_class ${outDir}/unique_TEs_with_PAS_0.9.bed 6

echo $(date +"[%b %d %H:%M:%S] Done!")
