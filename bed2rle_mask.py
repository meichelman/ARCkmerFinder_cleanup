#!/usr/bin/env python

import sys
import argparse
from itertools import groupby


def parse_args():
    parser = argparse.ArgumentParser(
        description="Convert a kmer BED file to a run-length encoded (RLE) binary mask. "
                    "Bases overlapping a kmer are encoded as 1, all others as 0."
    )
    parser.add_argument(
        "bed_file",
        help="Input BED file with columns: contig, start, end, id, multiplicity"
    )
    parser.add_argument(
        "fai_file",
        help="FASTA index file (.fai) produced by samtools faidx, used to get contig lengths"
    )
    parser.add_argument(
        "output_file",
        help="Output RLE mask file"
    )
    parser.add_argument(
        "--kmer-size", type=int, default=21,
        help="Kmer size used to override end position in BED (default: 21). "
             "Use --no-fix-ends to trust the BED end positions as-is."
    )
    parser.add_argument(
        "--no-fix-ends", action="store_true",
        help="Trust the end positions in the BED file rather than recomputing as start + kmer-size - 1"
    )
    return parser.parse_args()


def read_fai(fai_file):
    contig_lengths = {}
    with open(fai_file) as f:
        for line in f:
            fields = line.strip().split('\t')
            if len(fields) < 2:
                continue
            contig_lengths[fields[0]] = int(fields[1])
    return contig_lengths


def build_masks(bed_file, contig_lengths, fix_ends, kmer_size):
    masks = {contig: bytearray(length) for contig, length in contig_lengths.items()}
    skipped_contigs = set()
    n_intervals = 0

    with open(bed_file) as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            fields = line.split('\t')
            if len(fields) < 3:
                print(f"Warning: line {lineno} has fewer than 3 fields, skipping: {line}",
                      file=sys.stderr)
                continue

            contig = fields[0]
            try:
                start = int(fields[1])
                end = int(fields[2])
            except ValueError:
                print(f"Warning: line {lineno} has non-integer start/end, skipping: {line}",
                      file=sys.stderr)
                continue

            if fix_ends:
                end = start + kmer_size

            if contig not in masks:
                if contig not in skipped_contigs:
                    print(f"Warning: contig '{contig}' not in fai file, skipping all intervals on it",
                          file=sys.stderr)
                    skipped_contigs.add(contig)
                continue

            clamped_end = min(end, contig_lengths[contig])
            if start >= clamped_end:
                print(f"Warning: line {lineno} has start >= end after clamping, skipping",
                      file=sys.stderr)
                continue

            masks[contig][start:clamped_end] = b'\x01' * (clamped_end - start)
            n_intervals += 1

    print(f"Processed {n_intervals} intervals from BED file", file=sys.stderr)
    if skipped_contigs:
        print(f"Skipped {len(skipped_contigs)} contigs not found in fai: {sorted(skipped_contigs)}",
              file=sys.stderr)
    return masks


def masks_to_rle(masks, contig_lengths, output_file):
    total_runs = 0
    with open(output_file, 'w') as out:
        for contig in sorted(masks, key=lambda c: (contig_lengths[c], c), reverse=True):
            rle = [
                (state, sum(1 for _ in group))
                for state, group in groupby(masks[contig])
            ]
            total_runs += len(rle)
            rle_str = '\t'.join(f"{state},{length}" for state, length in rle)
            out.write(f"{contig}\t{rle_str}\n")
    print(f"Wrote {total_runs} total RLE runs across {len(masks)} contigs", file=sys.stderr)


def main():
    args = parse_args()
    fix_ends = not args.no_fix_ends

    print(f"Reading contig lengths from {args.fai_file}", file=sys.stderr)
    contig_lengths = read_fai(args.fai_file)
    print(f"Found {len(contig_lengths)} contigs in fai", file=sys.stderr)

    print(f"Building masks from {args.bed_file} (fix_ends={fix_ends}, kmer_size={args.kmer_size})",
          file=sys.stderr)
    masks = build_masks(args.bed_file, contig_lengths, fix_ends, args.kmer_size)

    print(f"Writing RLE mask to {args.output_file}", file=sys.stderr)
    masks_to_rle(masks, contig_lengths, args.output_file)
    print("Done", file=sys.stderr)


if __name__ == "__main__":
    main()