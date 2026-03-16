# ARCkmerFinder

To run the pipeline:
1. `mkdir {new_directory} && cd {new_directory}`
2. `git clone git@github.com:dgordon562/ARCkmerFinder.git .`
3. Edit the assembly and existing meryl database paths lines in config.yaml
4. Run `./sbatch_run_snakemake.sh`

The main output is windows_across_genome_with_zero_and_nonzero_matching_kmers.bed and a number of plots. The file windows_across_genome_with_zero_and_nonzero_matching_kmers.bed has 4 columns:
1. Assembly contig
2. Window start coordinate
3. Window end coordinate
4. K-mer count in the window

Intermediate files (automatic removal is specified in config.yaml):
1. Assembly.wig
2. Assembly.bed
3. Assembly.fai
4. Assembly_{window_size}_windows.bed
5. Assembly.bed_with_window
6. Assembly_in_{window_size}_windows.bed
7. windows_across_genome_with_zero_and_nonzero_matching_kmers.bed

Summary of the ARCkmerFinder pipeline:
For each k-mer in the assembly the pipeline will check if it is found in the provided archaic k-mer database. The meryl-lookup function gives a .wig (1) file that is converted to a .bed file (2) in which each kmer is a single line. There are several other columns in the .bed file which are not used.

A .fai file (3) is made for the assembly, and from this a set of non-overlapping windows that spans the assembly (4). Each window is 2kb by default (can be changed in config.yaml) except, of course, for the final window in each contig. Some fancy bedtools assigns each line in (2) to a window in (4) that gives a file (5) in which each kmer in the assembly has its location and which window it is in. Then, ARCkmerFinder counts how many such lines there are in each window.

ARCkmerFinder combines the number of k-mers in each window (6). This file is sorted such that the contigs are listed in order which is the main output (7). From here, several scripts for plotting information regarding the k-mer counts in the windows across the entire assembly output some histograms and ideograms.

THINGS TO ADD:
- Specify required R libraries
- Resolve fake_introgressed.bed
- Remove switch_haps.py and corresponding rule

<!-- The # of distinct kmers (AAAA is counted once no matter how many AAAA
are in the reads) is counted for each meryl dataset.  (K) This takes a
very long time.  It is used for the curve which I use for deciding how
small a kmer frequency should be considered an error. (L) -->

<!-- meryl print looks like this:
```
AAAAAAAAAAAAAAAAAAAAA   1564811
AAAAAAAAAAAAAAAAAAAAC   65845
.
.
.
```
where the number is the # of times the given kmer is found in the
read dataset.
The number of lines is the number of distinct kmers.  The 2nd column 
is irrelevant.
But if awk '{print $2}' | sort -n | uniq -c
then it will look like this:
```
2073056792 1
89240217 2
19355034 3
8221172 4
which means 
2073056792 kmers that occur 1 time in the read dataset
89240217 kmers that occur 2 times in the read dataset
etc.
```
so the sum of the 1st column gives the number of distinct kmers.
(the sum of the product of the 1st and 2nd columns gives the number
of (nondistinct) kmers in the read dataset, but we aren't using that
number for anything) -->
