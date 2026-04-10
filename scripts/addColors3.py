#!/usr/bin/env python

import sys
import argparse

 
parser = argparse.ArgumentParser()
parser.add_argument("--szContigsToDisplayOnLeft", required = True )
parser.add_argument("--szContigsToDisplayOnRight", required = True )
args = parser.parse_args()




dictColors = {}

for szFileToOpen in (args.szContigsToDisplayOnLeft, args.szContigsToDisplayOnRight ):

    n = 0
    with open( szFileToOpen, "r" ) as fContigNames:
        while True:
            szLine = fContigNames.readline()

            if ( szLine == "" ):
                break

            szContigName = szLine.rstrip()
            n += 1
            if ( n % 2 == 0 ):
                szColor = "burlywood"
            else:
                szColor = "gold1"

            dictColors[ szContigName ] = szColor
    # with open( szFileToOpen, "r" ) as fContigNames:


while True:
    szLine = sys.stdin.readline()
    if ( szLine == "" ):
        break

    aWords = szLine.split()
    
    szContig = aWords[0]
    if ( szContig in dictColors ):
        szColor = dictColors[ szContig ]
    else:
        szColor = "black"

    aWords.append( szColor )

    szNewLine = " ".join( aWords )

    sys.stdout.write( szNewLine + "\n" )


    
