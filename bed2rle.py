#!/usr/bin/env python

import argparse


def parse_args():
    parser = argparse.ArgumentParser(
        description="Convert a kmer BED file to a run-length encoded (RLE)."
    )
    parser.add_argument(
        "count_file",
        help="Input file with columns: contig, start, end, count"
    )
    parser.add_argument(
        "output_file",
        help="Output RLE mask file"
    )
    return parser.parse_args()


def make_rle(count_file, output_file):
    prev_contig = None
    run_start = None
    run_end = None
    
    with open(count_file, 'r') as f, open(output_file, 'w') as out:
        for line in f:
            contig, start, end, count = line.strip().split('\t')
            start = int(start)
            end = int(end)
            if contig != prev_contig:
                if run_start is not None:
                    out.write(f"{prev_contig}\t{run_start}\t{run_end}\t0\n")
                    run_start = None
                    run_end = None
                prev_contig = contig

            if count == '0':
                if run_start is None:
                    run_start = start
                    run_end = end
                else:
                    run_end = end
            else:
                if run_start is not None:
                    out.write(f"{contig}\t{run_start}\t{run_end}\t0\n")
                    run_start = None
                    run_end = None

                out.write(line)

        if run_start is not None:
            out.write(f"{prev_contig}\t{run_start}\t{run_end}\t0\n")


def main():
    args = parse_args()
    
    make_rle(args.bed_file, args.output_file)


if __name__ == "__main__":
    main()