#!/usr/bin/env python


import argparse
import subprocess


parser = argparse.ArgumentParser()
parser.add_argument("--szInputBedFile", required = True )
parser.add_argument("--szOutputBedFile", required = True )
parser.add_argument("--szContig1", required = True )
parser.add_argument("--szContig2", required = True )
args = parser.parse_args()



szCommand = "cat " + args.szInputBedFile + " | sed 's/" + args.szContig1 + "/temp_contig/' | sed 's/" + args.szContig2 + "/" + args.szContig1 + "/' | sed 's/temp_contig/" + args.szContig2 + "/' > " + args.szOutputBedFile
print( f"about to execute: {szCommand}" )
subprocess.call( szCommand, shell = True )

