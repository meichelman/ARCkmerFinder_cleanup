#!/usr/bin/env python


import argparse
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--szInputBedFileWithNonZeroWindows", required = True )
# this is necessary because the argument above doesn't include regions
# that have 0 kmers
parser.add_argument("--szBedFileOfAllWindows", required = True )
parser.add_argument("--szOutputBedFile", required = True )
parser.add_argument("--fTopPercent", required = True, type = float )
args = parser.parse_args()



# get nTotalWindows
szCommand = "wc -l " + args.szBedFileOfAllWindows + " | awk '{print $1}' "
print( "about to execute: " + szCommand )
nTotalWindows = int( subprocess.check_output( szCommand, shell = True ) )

# round
nLineNumberOfTopNPerCent = int( nTotalWindows * args.fTopPercent / 100 + 0.5 )
print( f"nTotalWindows = {nTotalWindows} nLineNumberOfTopNPerCent = {nLineNumberOfTopNPerCent}" )


szCommand = "wc -l " + args.szInputBedFileWithNonZeroWindows + " | awk '{print $1 }' "
print( "about to execute: " + szCommand )
nWindowsWithNonZeroCounts = int( subprocess.check_output( szCommand, shell = True ) )

# this will occur if the genome is smaller than 200 kb
if ( nLineNumberOfTopNPerCent < 1 ):
    nLineNumberOfTopNPerCent = 1


if ( nLineNumberOfTopNPerCent > nWindowsWithNonZeroCounts ):
    # sys.exit( "1% of " + str( nTotalWindows ) + " is " + str( nLineNumberOfTopOnePerCent ) + " but there are only " + str( nWindowsWithNonZeroCounts ) + " windows with non-zero counts so the 1% value is 0" )
    print(f"WARNING: {args.fTopPercent}% of {nTotalWindows} is {nLineNumberOfTopNPerCent} but there are only {nWindowsWithNonZeroCounts} windows with non-zero counts")
    nLineNumberOfTopNPerCent = nWindowsWithNonZeroCounts
# If the number of windows with non-zero counts is <1% of the total number of windows (non-zero and zero counts)
# then proceed with the number of windows with non-zero counts

szCommand = "cat " + args.szInputBedFileWithNonZeroWindows + " |  awk '{print $4}' | sort -nr | sed -n " + str( nLineNumberOfTopNPerCent ) + "p"
print( "about to execute: " + szCommand )
nMinValueOnePerCentile = int( subprocess.check_output( szCommand, shell = True ) )

with open( args.szInputBedFileWithNonZeroWindows, "r" ) as fBedFileOfNonZeroRegions, open( args.szOutputBedFile, "w" ) as fBedFileOfTopOnePerCent:
    while True:
        szLine = fBedFileOfNonZeroRegions.readline()
        if ( szLine == "" ):
            break

        aWords = szLine.split()
        # looks like:
        #test_assembly1   0       475     35
        # 0               1        2      3

        nNumberOfKmersInRegion = int( aWords[3] )

        if ( nNumberOfKmersInRegion >= nMinValueOnePerCentile ):
            fBedFileOfTopOnePerCent.write( szLine )


