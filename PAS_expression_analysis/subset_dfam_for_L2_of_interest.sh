#!/bin/bash

# Script to subset Dfam repeatmasker file to only include L2 elements with PAS
# Input: ${inDir}/*_with_PAS_min*.bed files
# Output: ${outDir}/*_subset.dfam.out files

# Create output directory if it doesn't exist
mkdir -p "$outDir"

echo "Using input directory: $inDir"
echo "Using output directory: $outDir"

module load bedtools

for i in L2 L2a L2b L2c L2d L2d2; do
    echo "Processing $i..."
    
    # Create a lookup file with 1-based coordinates from your BED file
    # Format: chr:start:end:name (using 1-based start)
    awk 'OFS="\t" {print $1":"$2+1":"$3":"$4}' "$inDir"/"$i"_with_PAS_min*.bed > "$i"_lookup.txt
    
    # Extract matching lines from Dfam file
    awk -v lookup="$i"_lookup.txt '
    BEGIN {
        # Read lookup coordinates into array
        while ((getline < lookup) > 0) {
            split($1, a, ":")
            key = a[1]":"a[2]":"a[3]":"a[4]
            coords[key] = 1
        }
        close(lookup)
    }
    # Print header lines
    /^   SW/ || /^score/ || NF == 0 {print; next}
    # Check if this line matches our coordinates
    NF >= 15 {
        chr = $5
        start = $6
        end = $7
        name = $10
        key = chr":"start":"end":"name
        if (key in coords) print
    }
    ' /Shares/CL_Shared/db/genomes/hg38/repeats/hg38.dfam.fa.out > "$outDir"/"$i"_subset.dfam.out
    
    # Count actual data lines (exclude headers)
    echo "  Elements in subset: $(grep -c '^[[:space:]]*[0-9]' "$outDir"/"$i"_subset.dfam.out)"
    
    # Clean up lookup file
    rm "$i"_lookup.txt
done

echo "Done! Subset Dfam files created in $outDir/ for all L2 subfamilies."