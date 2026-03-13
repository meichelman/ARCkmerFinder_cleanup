#!/usr/bin/env python

import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--szWindowsAcrossGenome", required = True )
parser.add_argument("--szKmerCountInWindows", required = True )
parser.add_argument("--szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers", required = True )
args = parser.parse_args()



sz0Windows = "zero_windows.bed"
szCommand = "module load bedtools/2.29.2 && bedtools subtract -a " + args.szWindowsAcrossGenome + " -b " + args.szKmerCountInWindows + " | awk '{print $0\"\t0\" }' >" + sz0Windows
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )


szCountInAllWindows = "counts_in_all_windows.bed"
szCommand = "cat " + args.szKmerCountInWindows + f" {sz0Windows} >{szCountInAllWindows}"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )


szCommand = f"cat {szCountInAllWindows} | sort -k1,1V -k2,2n >{args.szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers}"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )


szCommand = f"rm {sz0Windows} {szCountInAllWindows}"
print("about to execute: " + szCommand )
subprocess.call( szCommand, shell = True )
