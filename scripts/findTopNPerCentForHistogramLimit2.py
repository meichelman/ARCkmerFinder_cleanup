#!/usr/bin/env python


import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--szInputFile", required = True )
parser.add_argument("--nWhichColumn", required = True, type = int )
parser.add_argument("--fTopNPerCent", required = True, type = float )
parser.add_argument("--szOutputFileContainingMax", required = True )
args = parser.parse_args()


szCommand = "cat " + args.szInputFile + " | wc -l | awk '{print $1}'"
print( "about to execute: " + szCommand )
nLinesInFile = int( subprocess.check_output( szCommand, shell = True ) )


# figure out which line to use as the limit:

nLineAtTopNPerCent = int( nLinesInFile * float( 100.0 - args.fTopNPerCent ) / 100.0 )

szCommand = "cat " + args.szInputFile + " | awk '{print $" + str( args.nWhichColumn ) + " }' | sort -n | sed -n '" + str( nLineAtTopNPerCent ) + "p'"
print( "about to execute: " + szCommand )
nMaxLimit = int( subprocess.check_output( szCommand, shell = True ) )

with open( args.szOutputFileContainingMax, "w" ) as fOutputFileContainingMax:
    fOutputFileContainingMax.write( f"{nMaxLimit}\n" )




