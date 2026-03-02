#!/usr/bin/env python


import argparse
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument("--szInputBedFileWithNonZero2kbRegions", required = True )
# this is necessary because the argument above doesn't include regions
# that have 0 kmers
parser.add_argument("--szBedFileOfAll2kbRegions", required = True )
parser.add_argument("--szOutputBedFile", required = True )
parser.add_argument("--fTopPercent", required = True, type = float )
args = parser.parse_args()



# get nTotal2KbRegions

szCommand = "wc -l " + args.szBedFileOfAll2kbRegions + " | awk '{print $1}' "
print( "about to execute: " + szCommand )
nTotalWindows = int( subprocess.check_output( szCommand, shell = True ) )

# round
nLineNumberOfTopOnePerCent = int( nTotalWindows * args.fTopPercent / 100 + 0.5 )
print( f"nTotalWindows = {nTotalWindows} nLineNumberOfTopOnePerCent = {nLineNumberOfTopOnePerCent}" )


szCommand = "wc -l " + args.szInputBedFileWithNonZero2kbRegions + " | awk '{print $1 }' "
print( "about to execute: " + szCommand )
nWindowsWithNonZeroCounts = int( subprocess.check_output( szCommand, shell = True ) )

# this will occur if there are less than 100 2kb regions in the genome, i.e. if the
# genome is smaller than 200 kb
if ( nLineNumberOfTopOnePerCent < 1 ):
    nLineNumberOfTopOnePerCent = 1


if ( nLineNumberOfTopOnePerCent > nWindowsWithNonZeroCounts ):
    # sys.exit( "1% of " + str( nTotalWindows ) + " is " + str( nLineNumberOfTopOnePerCent ) + " but there are only " + str( nWindowsWithNonZeroCounts ) + " windows with non-zero counts so the 1% value is 0" )
    print(f"WARNING: 1% of {nTotalWindows} is {nLineNumberOfTopOnePerCent} but there are only {nWindowsWithNonZeroCounts} windows with non-zero counts")
    nLineNumberOfTopOnePerCent = nWindowsWithNonZeroCounts
# If the number of windows with non-zero counts is <1% of the total number of windows (non-zero and zero counts)
# then proceed with the number of windows with non-zero counts

szCommand = "cat " + args.szInputBedFileWithNonZero2kbRegions + " |  awk '{print $4}' | sort -nr | sed -n " + str( nLineNumberOfTopOnePerCent ) + "p"
print( "about to execute: " + szCommand )
nMinValueOnePerCentile = int( subprocess.check_output( szCommand, shell = True ) )

with open( args.szInputBedFileWithNonZero2kbRegions, "r" ) as fBedFileOfNonZeroRegions, open( args.szOutputBedFile, "w" ) as fBedFileOfTopOnePerCent:
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


