# ARCkmerFinder

ARCkmerFinder is a pipeline that searches an assembly for k-mers matching those in a k-mer database.
See [preARCkmerFinder](https://github.com/hsiehphLab/preARCkmerFinder) for details on creating the 
k-mer database.

## Getting started

To get setup do the following:
```shell
mkdir {new_directory} && cd {new_directory}
git clone https://github.com/hsiehphLab/ARCkmerFinder.git .
```

## Initial configuration

The required R libraries can be installed with install.packages({package_name}).

Required R packages:
- ggplot2
- gridExtra
- ggpubr
- karyoploteR
- plyranges
- tidyr
- dplyr
- stringr
- ggplotify
- cowplot

<!-- For users outside our lab we need to provide an environment.yaml and change the run_snakemake and sbatch_run_snakemake scripts -->

## Running ARCkmerFinder

1. Edit the assembly and existing meryl database path lines in config.yaml.
    - You may also edit the other variables.
2. Run `./sbatch_run_snakemake` to submit to the cluster, or run `./run_snakemake` to run locally.

## How it works

ARCkmerFinder scans through the assembly looking at every k-mer and asks whether that k-mer is found
in the provided k-mer database. The number of matching k-mers, that is k-mers found in both the assembly 
and k-mer database are counted and binned into windows. The size of the windows can be changed in the 
config.yaml file; however, the default and recommended size is 2000 (for 2000 base pairs, or 2kb). The 
main output is kmer_counts_rle.bed. This files contains a run-length-encoding of the k-mers found in 
every window across the assembly such that consecutive windows with a k-mer count of 0 are written into 
a single line with the start position matching the start position of the first window in the run and the 
end positions matching the end position of the last window in the run. Windows with 1 matching k-mer or 
more are written into their own line. When ARCkmerFinder is run with a private (an outgroup has been 
subtracted from the database) archaic k-mer database (Neanderthal or Denisovan) many of the windows are 
expected to be zero. Thus, using a run-length-encoding minimizes the disk space required and improves IO 
streaming for downstream analysis.

The output file kmer_counts_rle.bed has 4 columns:
1. Assembly contig
2. Window start coordinate
3. Window end coordinate
4. K-mer count in the window

ARCkmerFinder generates several files in the process (intermediate files can be automatically removed 
using a variable in config.yaml). These files have information on the assembly window boundaries, 
the positions of matching k-mers, the number of matching k-mers in the windows, and more. Some of the 
files are plots providing information on the location of k-mers in the contigs. The files are listed 
below.
1. {Assembly} (file is a link if the assembly is not in the current directory)
2. {Assembly}.bed
3. {Assembly}.bed_with_window
4. {Assembly}.fai
5. {Assembly}.gzi
6. {Assembly}.wig
7. {Assembly}.wig.bed
8. {Assembly}.wig.bed.sorted_flag
9. {Assembly}_{window_size}_windows.bed
10. {Assembly}_in_{window_size}_windows.bed
11. {Assembly}_in_{window_size}_windows_with_color.bed
12. contigs_to_display_on_left.txt
13. contigs_to_display_on_right.txt
14. counts_in_all_windows.bed
15. kmer_counts_rle.bed
16. top_N_per_cent_kmer_windows.bed
17. windows_across_genome_with_zero_and_nonzero_matching_kmers.bed
18. x_limit_for_histogram.txt
19. zero_windows.bed

The only file that is kept when intermediate file removal is specified is kmer_counts_rle.bed (14).

Summary of the ARCkmerFinder pipeline:
For each k-mer in the assembly the pipeline will check if it is found in the provided private archaic 
k-mer database. This is done using the meryl-lookup function which gives a .wig (6) file that is 
converted to a .bed file (7) in which each k-mer is a single line. There are several other columns 
in the .bed file which are not used.

A .fai file (4 and 5) is made for the assembly, and from this a set of non-overlapping windows that spans 
the assembly (9). Each window is 2kb by default (can be changed in config.yaml) except, of course, for 
the final window in each contig. Some fancy bedtools assigns each line in (7) to a window in (9) that 
gives a file (3) in which each kmer in the assembly has its location and which window it is in. Then, 
ARCkmerFinder counts how many such lines there are in each window to make (10).

ARCkmerFinder fills in the gaps with windows containing a k-mer count of 0 (14). This file is sorted 
such that the contigs are listed in order (17). From here, several scripts for plotting information 
regarding the k-mer counts in the windows across the entire assembly output some histograms and ideograms. 
Lastly, a run-length-encoding of k-mers is created (15).

## Configuration variables

Assembly: the path to the assembly (.fasta, .fa., .fasta.gz, etc.).

Existing meryl database path: the path to the k-mer database created with preARCkmerFinder.

Window size: the size of the bins for counting the matching k-mers (default: 2000)

Remove intermediate files: whether or not to remove the intermediate files (default: True)

Make plots: whether or not to make the plots for additional information about the matching k-mers (default: False)

Top percent of windows: the % of windows with the highest matching k-mer counts to plot (default: 1.0)

Contigs to display: the number of contigs to display in the plots (default: 12)



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

<!-- szKmerCountInWindows has a number, for each 2kb window, of kmers from
PNG16_vs_Chagyrskaya_minus_HG03516_greater_than_5.  If a kmer is found
more than once in the 2kb window, it is counted more than once?  Yes.
meryl-lookup notes for each kmer, how many times it is found in the
reads (by the meryl database).  But that count is ignored by this
pipeline.  Each kmer found is assigned to a 2kb window.  bedtools
groupby then counts how many kmers for each 2kb are found in the
meryl database.  Some of these kmers may be the same.  We don't know
and don't care.  Just how many kmers in each 2kb region are found in
the meryl database. -->
