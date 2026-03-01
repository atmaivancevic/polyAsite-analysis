#!/bin/bash
## Script for running deeptools 
##
## Example usage:
##
## bedDir=L2_with_PAS_expanded \
## bigwig=canonical_PAS_1e-3.bw \
## sampleName=canonical_motif \
## zMax=0.6 \
## outDir=heatmap \
## outFile=L2s_with_canonical_PAS \
## sbatch deeptools_heatmap.sbatch 

# General settings
#SBATCH -p short
#SBATCH -N 1
#SBATCH -c 8
#SBATCH --time=1-00:00
#SBATCH --mem=32GB

# Job name and output
#SBATCH -J deeptools_heatmap
#SBATCH -o /scratch/Users/%u/data/slurmOut/slurm-%j.out
#SBATCH -e /scratch/Users/%u/data/slurmErr/slurm-%j.err

# load modules
module load singularity

# make outDir
mkdir -p $outDir

# define constant variables
deeptools=/scratch/Shares/public/singularity/deeptools-3.0.1-py35_1.img

# set bigwigs and sample labels
wigs=${bigwig}
samplesLabel="$sampleName"

# run the thing
pwd; hostname; date
echo "Starting deeptools..."
echo $(date +"[%b %d %H:%M:%S] Compute matrix...")

# Use "computeMatrix" to generate data underlying heatmap
windowLeft=300
windowRight=3700
binSize=1
numCPU=8

singularity exec --bind /Shares/CL_Shared $deeptools \
computeMatrix reference-point \
--referencePoint TSS \
--scoreFileName ${wigs} \
--regionsFileName ${bedDir}/L2a_expanded_dfam.bed ${bedDir}/L2b_expanded_dfam.bed ${bedDir}/L2c_expanded_dfam.bed ${bedDir}/L2d2_expanded_dfam.bed ${bedDir}/L2d_expanded_dfam.bed ${bedDir}/L2_expanded_dfam.bed \
--beforeRegionStartLength ${windowLeft} \
--afterRegionStartLength ${windowRight} \
--binSize ${binSize} \
--missingDataAsZero \
-o ${outDir}/${outFile}.mat.gz \
-p ${numCPU}

echo $(date +"[%b %d %H:%M:%S] Plot heatmap...")

# Use "plotHeatmap" to create a png or pdf

singularity exec --bind /Shares/CL_Shared $deeptools \
plotHeatmap \
-m ${outDir}/${outFile}.mat.gz \
--outFileName ${outDir}/${outFile}.pdf \
--outFileSortedRegions ${outDir}/${outFile}.dt.bed \
--outFileNameMatrix ${outDir}/${outFile}.matrix.tab \
--sortRegions descend \
--colorMap Blues \
--zMin 0 --yMin 0 \
--zMax=${zMax} \
--samplesLabel ${samplesLabel} \
--regionsLabel L2a L2b L2c L2d2 L2d L2 \
--heatmapHeight 12 \
--heatmapWidth 4

echo $(date +"[%b %d %H:%M:%S] Done!")
