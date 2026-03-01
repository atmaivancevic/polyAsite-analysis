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

### TE-PAS contribtion analysis

   1) [dorado_basecall.sbatch](genome_assembly/dorado_basecall.sbatch)
   2) [dorado_demux.sbatch](genome_assembly/dorado_demux.sbatch)
   3) [nanostat.sbatch](genome_assembly/nanostat.sbatch)
