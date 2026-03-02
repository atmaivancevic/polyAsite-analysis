# polyAsite-analysis

### Programs Used:

- **Bedtools** v2.28.0 https://bedtools.readthedocs.io/en/latest/
- **Deeptools** v3.0.1 https://deeptools.readthedocs.io/en/develop/index.html
- **Fimo** v5.1.0 https://meme-suite.org/meme/doc/fimo.html


--------------------------------------------------------------------------------------------------------------------------------------------

### 1. PAS expression analysis

Identifies L2 subfamily elements in the human genome that contain expressed polyadenylation sites (PAS), in order to visualize PAS signal enrichment at the 3' end.

- [polyasite_download_and_convert.sbatch](PAS_expression_analysis/polyasite_download_and_convert.sbatch)
- [L2_overlap_PAS.sbatch](PAS_expression_analysis/L2_overlap_PAS.sbatch)
- [L2_expand_coordinates.sbatch](PAS_expression_analysis/L2_expand_coordinates.sbatch), which requires [subset_dfam_for_L2_of_interest.sh](PAS_expression_analysis/subset_dfam_for_L2_of_interest.sh) and [repeats_createExpandedRepeatFile_dfam.py](PAS_expression_analysis/repeats_createExpandedRepeatFile_dfam.py)
- [deeptools_heatmap.sbatch](PAS_expression_analysis/deeptools_heatmap.sbatch) to generate [L2s_with_expressed_PAS.pdf](PAS_expression_analysis/L2s_with_expressed_PAS.pdf)

This analysis requires the following files, or equivalent:

**atlas.clusters.3.0.GRCh38.GENCODE_42.bed**: BED file of PAS sites with single-cell expression scores, downloaded from PolyASite 3.0: https://polyasite.unibas.ch/atlas_sc

**hg38.main.chrom.sizes**: chromosome sizes for the primary chromosomes of the hg38 genome

**hg38.dfam.fa.out**: Dfam repeat annotations for hg38, used to determine the relative position of each L2 fragment within its consensus sequence

**hg38.dfam.info** [optional]: repeat divergence information for each TE subfamily

**L2_elements/**: directory containing BED files for each L2 subfamily (L2, L2a, L2b, L2c, L2d, L2d2), included in this repository

--------------------------------------------------------------------------------------------------------------------------------------------

### 2. PAS motif analysis

Identifies canonical polyadenylation signal hexamers across the human genome using FIMO, independent of expression data, and visualizes their enrichment in L2 elements. Used as an unbiased complement to the PolyASite expression-based analysis.

- [fimo.sbatch](PAS_motif_analysis/fimo.sbatch), which uses [canonical_PAS.meme](PAS_motif_analysis/canonical_PAS.meme)
- [deeptools_heatmap.sbatch](PAS_motif_analysis/deeptools_heatmap.sbatch) to generate [L2s_with_canonical_PAS.pdf](PAS_motif_analysis/L2s_with_canonical_PAS.pdf)

This analysis requires the following files:

**hg38.main.fa**: hg38 reference genome FASTA, used by FIMO to scan for motif occurrences

**hg38.main.chrom.sizes**: chromosome sizes for hg38 genome

--------------------------------------------------------------------------------------------------------------------------------------------

### 3. PAS within TEs

Identifies which TE loci in the human genome contain polyadenylation sites, and characterizes their expression levels. TEs are classified into five classes (LINE, SINE, LTR, DNA, Other) and overlapped with PAS sites using a 10bp window. PAS-containing TEs are filtered for expression (average expression score > 0.9). Expressed TE-PAS loci are ranked by expression score and intersected with GENCODE gene annotations to identify which genes are associated with TE-derived PAS.

- [te_pas_analysis.sbatch](PAS_within_TEs/te_pas_analysis.sbatch)
- [te_pie.R](PAS_within_TEs/te_pie.R) to generate [te_pie.pdf](PAS_within_TEs/te_pie.pdf)
- [te_bar_counts.R](PAS_within_TEs/TE_bar_counts.R) to generate [te_bar_counts.pdf](PAS_within_TEs/te_bar_counts.pdf)

This analysis requires the following files, or equivalent:

**hg38.dfam.ucsc.filtered.bed**: BED file containing annotation of human repeats from Dfam, downloaded from the UCSC genome browser track hub for hg38.

**gencode.v47.simple.bed**: simplified BED of GENCODE v47 gene annotations, derived from the BED file on UCSC.

**atlas.clusters.3.0.GRCh38.GENCODE_42.bed**: As above, BED file of PAS sites with single-cell expression scores, downloaded from PolyASite 3.0: https://polyasite.unibas.ch/atlas_sc
