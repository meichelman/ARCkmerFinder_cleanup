#!/usr/bin/env python

import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--szWindowsAcrossGenome", required = True )
parser.add_argument("--szKmerCountInWindows", required = True )
parser.add_argument("--szBedFileOfPutativeIntrogressedRegions", required = True )
parser.add_argument("--szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersAndIncludingIntrogressedAndNoIntrogressedRegions", required = True )
args = parser.parse_args()


# Input to this directory:
#       count.bed which is the 2kb regions with non-zero kmer counts
#       assembly.haplotype1.windows.bed is the assembly broken into 2kb
#             windows
# find_0_kmer_windows.py
#       generates 2kb regions with no kmers:  zero_windows.bed
#       cat's this with count.bed to make counts_with_0_windows.bed
#       which has kmer counts for all 2kb regions including those with
#       no matching kmers

# find_introgressed.sh
#       takes counts_with_0_windows.bed and
#       regions_in_PNG16_2kb_windows.bed (which I believe is
#       introgressed regions) and generates introgressed_2kb_counts.bed

#       takes counts_with_0_windows.bed and
#       not_regions_in_PNG16_2kb_windows.bed (2kb regions with no
#       introgressed bases) and generates:
#       nonintrogressed_2kb_counts.bed

#       It adds "introgressed" or "nonintrogressed" to each of these
#       generating both.bed
# output: --szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersAndIncludingIntrogressedAndNoIntrogressedRegions is kmer counts
#       for each 2kb region (including those with no kmers) and "introgressed" or "nonintrogressed" regions.


sz0Windows = "zero_windows.bed"
szCommand = "module load bedtools/2.29.2 && bedtools subtract -a " + args.szWindowsAcrossGenome + " -b " + args.szKmerCountInWindows + " | awk '{print $0\"\t0\" }' >" + sz0Windows
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )


szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers = "counts_in_all_windows.bed"

szCommand = "cat " + args.szKmerCountInWindows + f" {sz0Windows} >{szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers}"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )

# now we have counts for each window.
# Now we will annotate each window whether it is introgressed or not

szWindowsIncludingIntrogressedRegions = "windows_including_introgressed_regions.bed"
szWindowsNotIncludingIntrogressedRegions = "windows_not_including_introgressed_regions.bed"
szWindowsIncludingIntrogressedAndNoIntrogressedRegions = "windows_including_introgressed_and_no_introgressed_regions.bed"


# -u makes it output any feature in a (once) if it overlaps a feature in b
szCommand = f"module load bedtools/2.29.2 && bedtools intersect -u -a " + args.szWindowsAcrossGenome + " -b " + args.szBedFileOfPutativeIntrogressedRegions + f" >{szWindowsIncludingIntrogressedRegions}"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )

# find windows with *no* introgression

szCommand = f"module load bedtools/2.29.2 && bedtools subtract -a " + args.szWindowsAcrossGenome + f" -b {szWindowsIncludingIntrogressedRegions} > {szWindowsNotIncludingIntrogressedRegions}"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )


# find count in introgressed and non-introgressed regions

szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersJustIntrogressed = "windowsAcrossGenomeWithZeroAndNonZeroMatchingKmersJustIntrogressed.bed"
szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersJustNonIntrogressed = "windowsAcrossGenomeWithZeroAndNonZeroMatchingKmersJustNonIntrogressed.bed"


szCommand = f"module load bedtools/2.29.2 && bedtools intersect -a {szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers} -b {szWindowsIncludingIntrogressedRegions} >{szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersJustIntrogressed}"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )

szCommand = f"module load bedtools/2.29.2 && bedtools intersect -a {szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers} -b {szWindowsNotIncludingIntrogressedRegions} >{szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersJustNonIntrogressed}"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )


with open( args.szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersAndIncludingIntrogressedAndNoIntrogressedRegions + ".tmp", "w" ) as fOutput:
    with open( szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersJustIntrogressed, "r" ) as fIntrogressed:
        while True:
            szLine = fIntrogressed.readline()
            if ( szLine == "" ):
                break

            szLine = szLine.rstrip()
            szLine += "\tintrogressed\n"

            fOutput.write( szLine )

    with open( szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersJustNonIntrogressed, "r" ) as fNotIntrogressed:
        while True:
            szLine = fNotIntrogressed.readline()
            if ( szLine == "" ):
                break

            szLine = szLine.rstrip()
            szLine += "\tnonintrogressed\n"
            
            fOutput.write( szLine )


szCommand = f"cat {args.szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersAndIncludingIntrogressedAndNoIntrogressedRegions}.tmp | sort -k1,1V -k2,2n >{args.szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersAndIncludingIntrogressedAndNoIntrogressedRegions} && rm {args.szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmersAndIncludingIntrogressedAndNoIntrogressedRegions}.tmp"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )


