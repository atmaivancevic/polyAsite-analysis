# polyAsite-analysis

### Programs Used:

- **Bedtools** v2.28.0 https://bedtools.readthedocs.io/en/latest/
- **Deeptools** v3.0.1 https://deeptools.readthedocs.io/en/develop/index.html
- **Fimo** v5.1.0 https://meme-suite.org/meme/doc/fimo.html


---

### 1. PAS expression analysis

Identifies L2 subfamily elements in the human genome that contain expressed polyadenylation sites (PAS), in order to visualize PAS signal enrichment at the 3' end.

- [polyasite_download_and_convert.sbatch](PAS_expression_analysis/polyasite_download_and_convert.sbatch) — downloads the PolyASite 3.0 atlas and converts to a bigWig weighted by average RPM expression
- [L2_overlap_PAS.sbatch](PAS_expression_analysis/L2_overlap_PAS.sbatch) — overlaps L2 subfamily elements with expressed PAS sites (expression score > 0.9, window = 10bp)
- [L2_expand_coordinates.sbatch](PAS_expression_analysis/L2_expand_coordinates.sbatch) — expands each L2 element to its theoretical full-length coordinates using Dfam repeat annotations; requires [subset_dfam_for_L2_of_interest.sh](PAS_expression_analysis/subset_dfam_for_L2_of_interest.sh) and [repeats_createExpandedRepeatFile_dfam.py](PAS_expression_analysis/repeats_createExpandedRepeatFile_dfam.py)
- [deeptools_heatmap.sbatch](PAS_expression_analysis/deeptools_heatmap.sbatch) — generates a deeptools heatmap of polyAsite RPM signal across full-length L2 elements, e.g. [L2s_with_expressed_PAS.pdf](PAS_expression_analysis/L2s_with_expressed_PAS.pdf)

This analysis requires the following files, or equivalent:

**atlas.clusters.3.0.GRCh38.GENCODE_42.bed**: BED file of PAS sites with single-cell expression scores, downloaded from PolyASite 3.0: https://polyasite.unibas.ch/atlas_sc

**hg38.dfam.fa.out**: RepeatMasker output file containing Dfam repeat annotations for hg38, used to determine the relative position of each L2 fragment within its consensus sequence

**hg38.main.chrom.sizes**: chromosome sizes for hg38 genome

**L2_elements/**: directory containing BED files for each L2 subfamily (L2, L2a, L2b, L2c, L2d, L2d2), included in this repository

### 2. PAS motif analysis

Identifies canonical polyadenylation signal hexamers across the human genome using FIMO, independent of expression data, and visualizes their enrichment in L2 elements. Used as an unbiased complement to the PolyASite expression-based analysis.

- [fimo.sbatch](PAS_motif_analysis/fimo.sbatch) — scans the hg38 genome for PAS hexamers using FIMO and converts output to bigWig; run separately for canonical (AATAAA) and variant motifs using the provided MEME files:
   - [canonical_PAS.meme](PAS_motif_analysis/canonical_PAS.meme) — canonical AATAAA hexamer
   - [variant_PAS.meme](PAS_motif_analysis/variant_PAS.meme) — 11 known variant PAS hexamers (ATTAAA, AGTAAA, TATAAA, etc.)
- [deeptools_heatmap.sbatch](PAS_expression_analysis/deeptools_heatmap.sbatch) — same script as in PAS expression analysis; run with the fimo bigWig instead

This analysis requires the following files:

**hg38.main.fa**: hg38 reference genome FASTA, used by FIMO to scan for motif occurrences

**hg38.main.chrom.sizes**: chromosome sizes for hg38 genome

### 3. PAS within TEs

- [te_pas_analysis.sbatch](PAS_within_TEs/te_pas_analysis.sbatch)
- [te_pie.R](PAS_within_TEs/te_pie.R) to generate [te_pie.pdf](PAS_within_TEs/te_pie.pdf)
- [te_bar_counts.R](PAS_within_TEs/TE_bar_counts.R) to generate [te_bar_counts.pdf](PAS_within_TEs/te_bar_counts.pdf)

Identifies which TE loci in the human genome contain polyadenylation sites, and characterizes their expression levels. TEs are classified into five classes (LINE, SINE, LTR, DNA, Other) and overlapped with PAS sites using a 10bp window. PAS-containing TEs are filtered for expression (average expression score > 0.9). Expressed TE-PAS loci are ranked by expression score and intersected with GENCODE gene annotations to identify which genes are associated with TE-derived PAS.

This script requires the following files, or equivalent:

**hg38.dfam.ucsc.filtered.bed**: BED file containing annotation of human repeats from Dfam, downloaded from the UCSC genome browser track hub for hg38.

**gencode.v47.simple.bed**: simplified BED of GENCODE v47 gene annotations, derived from the BED file on UCSC.

**atlas.clusters.3.0.GRCh38.GENCODE_42.bed**: BED file of PAS sites with single-cell expression scores, downloaded from PolyASite 3.0: https://polyasite.unibas.ch/atlas_sc
