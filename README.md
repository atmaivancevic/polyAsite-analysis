# polyAsite-analysis

### Programs Used

- **Bedtools** v0.7.2 https://github.com/nanoporetech/dorado
- **NanoStat** v1.6.0 https://github.com/wdecoster/nanostat 
- **Flye** v2.9.5 https://github.com/fenderglass/Flye  
- **Medaka** v2.0.0 https://github.com/nanoporetech/medaka  

---

### PAS expression analysis

Uses PolyASite 3.0 Single Cell Expression Data: <add link>

   1) [flye_assembly.sbatch](genome_assembly/flye_assembly.sbatch)  
   2) [medaka_consensus.sbatch](genome_assembly/medaka_consensus.sbatch)  

### PAS motif analysis

   1) [bbduk_trim.sbatch](genome_assembly/bbduk_trim.sbatch)  
   2) [bwa_mem_align.sbatch](genome_assembly/bwa_mem_align.sbatch)

### PAS within TEs

Identifies which TE loci in the human genome contain polyadenylation sites (PAS), and characterizes their expression levels using single-cell expression data. TEs are classified into five supergroups (LINE, SINE, LTR, DNA, Other) and overlapped with PAS sites using a 10bp window. PAS-containing TEs are further filtered for expression (average expression score > 0.9). Expressed TE-PAS loci are ranked by expression score and intersected with GENCODE gene annotations to identify which genes are associated with TE-derived PAS.

This script requires the following files, or equivalent:

* **hg38.dfam.ucsc.filtered.bed**: BED file containing annotation of human repeats from Dfam, downloaded from the UCSC genome browser track hub for hg38.

* **gencode.v47.simple.bed**: simplified BED of GENCODE v47 gene annotations, downloaded from the UCSC genome browser track hub for hg38.

* **atlas.clusters.3.0.GRCh38.GENCODE_42.bed**: BED file of PAS sites with single-cell expression scores, downloaded from PolyASite 3.0: https://polyasite.unibas.ch/atlas_sc

   1) [te_pas_analysis.sh](PAS_within_TEs/te_pas_analysis.sh)
