#!/usr/bin/env python
# encoding: utf-8
"""
repeats_createExpandedRepeatFile_dfam.py
Input: Dfam-formatted repeatmasker out file
Output: a bed file of repeats with expanded coordinates based on "full-length" boundaries
Modified from Ed Chuong's original script for Dfam format
"""
import sys
import optparse
def main():
    parser = optparse.OptionParser()
    parser.add_option('-i', '--input', help="input dfam repeatmasker .out file", 
                      dest='input', action='store', default=None)
    parser.add_option('-f', '--family', help="filter for specific repeat family (e.g., L2)", 
                      dest='family', action='store', default=None)
    
    (opts, args) = parser.parse_args()
    
    if not opts.input:
        print("*** Mandatory option '-i/--input' missing!")
        sys.exit(1)
    
    with open(opts.input) as f:
        for line in f:
            # Skip header lines and empty lines
            if line.startswith('   SW') or line.startswith('score') or len(line.strip()) == 0:
                continue
            
            fields = line.strip().split()
            
            # Dfam .out format (space-delimited, variable spacing)
            # Columns: score div del ins chrom start end left strand repeat class/family rep_start rep_end rep_left id
            if len(fields) < 15:
                continue
            
            try:
                score = fields[0]
                chrom = fields[4]
                start = int(fields[5])
                end = int(fields[6])
                left_paren = fields[7]  # This is like "(248945954)"
                strand = fields[8]
                rep_name = fields[9]
                rep_class_family = fields[10]  # Like "LINE/L1"
                
                # Parse repeat coordinates
                # Format can be: "begin end (left)" for + strand
                # or "(left) end begin" for C (complement/- strand)
                if strand == 'C':
                    strand = '-'
                    # For complement strand: (left) end begin
                    rep_left_str = fields[11]  # like "(2234)"
                    rep_end = int(fields[12])
                    rep_start = int(fields[13])
                    rep_left_value = int(rep_left_str.strip('()'))  # store as positive
                elif strand == '+':
                    # For + strand: begin end (left)
                    rep_start = int(fields[11])
                    rep_end = int(fields[12])
                    rep_left_str = fields[13]  # like "(0)"
                    rep_left_value = int(rep_left_str.strip('()'))  # store as positive
                else:
                    continue
                
                # Calculate expanded coordinates
                # + strand: 5' end is LEFT, 3' end is RIGHT
                #   expand left by (rep_start - 1), expand right by rep_left_value
                # - strand: 5' end is RIGHT, 3' end is LEFT
                #   expand left by rep_left_value, expand right by (rep_start - 1)
                if strand == "+":
                    real_start = start - (rep_start - 1)
                    real_end = end + rep_left_value
                else:
                    real_start = start - rep_left_value
                    real_end = end + (rep_start - 1)
                
                # Filter by family if specified
                if opts.family:
                    # Check if rep_name starts with the family name
                    if not rep_name.startswith(opts.family):
                        continue
                
                print(f"{chrom}\t{real_start}\t{real_end}\t{rep_name}\t{score}\t{strand}")
                
            except (ValueError, IndexError) as e:
                # Skip problematic lines
                continue
if __name__ == "__main__":
    main()