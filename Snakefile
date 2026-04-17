import os


configfile: "config.yaml"


# Configuration variables
szAssemblyPath = config["kmer_counting"]["assembly"]
szMerylDatabase = config["kmer_counting"]["existing_meryl_database_path"]
nWindowSize = config["kmer_counting"]["window_size"]
bRemoveIntermediateFiles = config["kmer_counting"]["remove_intermediate_files"]
nTopNPercentOfWindows = config["plotting"]["top_%_of_windows"]
nContigsToDisplay = config["plotting"]["contigs_to_display"]
bMakePlots = config["plotting"]["make_plots"]
szAssemblyBasename = os.path.basename( szAssemblyPath )

# Organizing windows
szAssemblyFai = f"{szAssemblyBasename}.fai"
szAssemblyBed = f"{szAssemblyBasename}.bed"
szWindowsAcrossGenome = f"{szAssemblyBasename}_{nWindowSize}_windows.bed"

# Counting k-mers
szKmerCountWig = f"{szAssemblyBasename}.wig"
szKmerCountBed = f"{szKmerCountWig}.bed"
szKmerCountBedSortedFlag = f"{szKmerCountBed}.sorted_flag"

# Organizing k-mer counts in windows
szKmerCountBedWithWindow = f"{szAssemblyBasename}.bed_with_window"
szKmerCountInWindows = f"{szAssemblyBasename}_in_{nWindowSize}_windows.bed"
szZeroKmerCountWindows = "zero_windows.bed"
szKmerCountInAllWindows = "counts_in_all_windows.bed"
szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers = "windows_across_genome_with_zero_and_nonzero_matching_kmers.bed"
szKmerCountRLE = "kmer_counts_rle.bed"

# Plotting
szKmerCountInWindowsWithColor = f"{szAssemblyBasename}_in_{nWindowSize}_windows_with_color.bed"  
szTopNPerCentKmerCountWindows = "top_N_per_cent_kmer_windows.bed"
szFileOfContigsToDisplayOnLeft  = "contigs_to_display_on_left.txt"
szFileOfContigsToDisplayOnRight = "contigs_to_display_on_right.txt"
fileLimitForHistogram = "x_limit_for_histogram.txt"
szIdeogramFile = f"{szAssemblyBasename}_ideogram.png"
szHistogramFile = f"{szAssemblyBasename}_histogram.png"
szHistogramFileLinearWithLimit = f"{szAssemblyBasename}_with_limit_histogram.png"
szHistogramLogTitle = f"{szAssemblyBasename}_logx"
szHistogramLogFile  = f"{szHistogramLogTitle}_histogram.png"

# Outputs
if bMakePlots:
	outputs = [
		szKmerCountRLE,
		szIdeogramFile,
		szHistogramLogFile,
		szHistogramFileLinearWithLimit,
		szHistogramFile
	]
else:
	outputs = [
		szKmerCountRLE
	]


def is_directly_in_cwd(file_path):
	"""
	Checks if the file_path is located directly in the Current Working Directory (CWD),
	excluding files in subdirectories.
	
	Args:
		file_path (str): The path to check (should represent a file).
					
	Returns:
		bool: True if the file is an immediate member of the CWD.
	"""

	full_path = os.path.abspath(file_path)
	file_dir = os.path.dirname(full_path)
	current_dir = os.getcwd()

	if ( file_dir == current_dir):
		return True
	else:
		return False


rule all:
	input:
		outputs
	localrule: True
	run:
		if bMakePlots:
			files_to_remove = [
				szAssemblyFai,
				szAssemblyBasename + '.gzi',
				szAssemblyBed,
				szWindowsAcrossGenome,
				szKmerCountWig,
				szKmerCountBed,
				szKmerCountBedSortedFlag,
				szKmerCountBedWithWindow,
				szKmerCountInWindows,
				szZeroKmerCountWindows,
				szKmerCountInAllWindows,
				szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers,
				szKmerCountInWindowsWithColor,
				szFileOfContigsToDisplayOnLeft,
				szFileOfContigsToDisplayOnRight,
				fileLimitForHistogram
			]
			szCommand = f"mkdir -p plots && mv *.png plots/"
			shell(szCommand)
			szCommand = f"rm {' '.join(files_to_remove)}"
		else:
			files_to_remove = [
				szAssemblyFai,
				szAssemblyBasename + '.gzi',
				szWindowsAcrossGenome,
				szKmerCountWig,
				szKmerCountBed,
				szKmerCountBedSortedFlag,
				szKmerCountBedWithWindow,
				szKmerCountInWindows,
				szZeroKmerCountWindows,
				szKmerCountInAllWindows,
				szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers
			]
			szCommand = f"rm {' '.join(files_to_remove)}"
		if bRemoveIntermediateFiles:
			shell(szCommand)


# Make the histogram of k-mer counts with a log x-axis
rule makeHistogram_logx:
	input:
		szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers
	output:
		szHistogramLogFile
	localrule: True
	run:
		szCommand = f"module load R/4.4.0-openblas-rocky8 && Rscript scripts/histogram_logx.R {output} {szHistogramLogTitle} {input}"
		shell(szCommand)


# Make the histogram of k-mer counts with a linear x-axis and a limit on the x-axis that is determined by the top N % of windows with the highest k-mer counts
rule makeHistogram_linear_with_limit:
	input:
		szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers
	output:
		szHistogramFileLinearWithLimit
	localrule: True
	run:
		szCommand = f"./scripts/findTopNPerCentForHistogramLimit2.py --szInputFile {input} --nWhichColumn 4 --fTopNPerCent {nTopNPercentOfWindows} --szOutputFileContainingMax {fileLimitForHistogram}"
		shell(szCommand)

		szCommand = f"module load R/4.4.0-openblas-rocky8 && Rscript scripts/histogram_linear_with_limit.R {output} {szAssemblyBasename} {input} `cat {fileLimitForHistogram}` "
		shell(szCommand)


# Make the histogram of k-mer counts with a linear x-axis and no limit on the x-axis
rule makeHistogram_linear_no_limit:
	input:
		szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers
	output:
		szHistogramFile
	localrule: True
	run:
		szCommand = f"module load R/4.4.0-openblas-rocky8 && Rscript scripts/histogram_linear_no_limit.R {output} {szAssemblyBasename} {input}"
		shell(szCommand)


# Make the ideogram with the top N % of windows with the highest k-mer counts colored differently
rule makeIdeogram:
	input:
		szKmerCountInWindowsWithColor,
		szTopNPerCentKmerCountWindows,
		szAssemblyBed,
		szFileOfContigsToDisplayOnLeft, 
		szFileOfContigsToDisplayOnRight
	output:
		szIdeogramFile
	localrule: True
	run:
		szCommand = f"module load R/4.4.0-openblas-rocky8 && Rscript scripts/make_ideogram6_rectangles.R {output} {input[0]} {szAssemblyBasename} {input[1]} {input[2]} {input[3]} {input[4]}"
		shell(szCommand)


# Get the top N % of windows with the highest k-mer counts
rule find_top_N_per_cent_bed:
	input:
		szKmerCountInWindows,
		szWindowsAcrossGenome
	output:
		szTopNPerCentKmerCountWindows
	localrule: True
	run:
		szCommand = f"./scripts/makeBedFileWithTopNPerCent.py --fTopPercent {nTopNPercentOfWindows} --szInputBedFileWithNonZeroWindows {input[0]} --szBedFileOfAllWindows {input[1]} --szOutputBedFile {output}"
		shell(szCommand)


# Add colors to the bed file of k-mer counts in windows for the ideograms
rule addColors:
	input:
		szKmerCountInWindows,
		szFileOfContigsToDisplayOnLeft,
		szFileOfContigsToDisplayOnRight
	output:
		szKmerCountInWindowsWithColor
	localrule: True
	run:
		szCommand = f"cat {input[0]} | ./scripts/addColors3.py --szContigsToDisplayOnLeft {input[1]} --szContigsToDisplayOnRight {input[2]} >{output}"
		shell(szCommand)


# Figure out which contigs to display on the left and right of the ideogram
rule figureOutWhichContigsToDisplay:
	input:
		szAssemblyFai
	output:
		szFileOfContigsToDisplayOnLeft, 
		szFileOfContigsToDisplayOnRight
	localrule: True
	run:
		szCommand = f"./scripts/figureOutWhichContigsToDisplay.sh {input} {nContigsToDisplay} {output[0]} {output[1]}"
		shell(szCommand)


# --------------------------------------------------------------------
# Everything below is for generating the archaic k-mer counts bed file
# --------------------------------------------------------------------


# Generate final archaic k-mer counts bed file with the number of matching k-mers in each window (including zero and non-zero windows with matching k-mers)
rule make_archaic_kmer_counts_rle_bed_file:
	input:
		szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers
	output:
		szKmerCountRLE
	localrule: True
	run:
		szCommand = f"./scripts/bed2rle.py {input} {output}"
		print(szCommand)
		shell(szCommand)


rule make_archaic_kmer_counts_bed_file:
	input:
		szWindowsAcrossGenome,
		szKmerCountInWindows
	output: 
		szWindowsAcrossGenomeWithZeroAndNonZeroMatchingKmers
	localrule: True
	run:
		szCommand = f"module load bedtools/2.29.2 && bedtools subtract -a {input[0]} -b {input[1]} | sed 's/$/\\t0/' > {szZeroKmerCountWindows}"
		print(szCommand)
		shell(szCommand)

		szCommand = f"cat {input[1]} {szZeroKmerCountWindows} > {szKmerCountInAllWindows}"
		print(szCommand)
		shell(szCommand)

		szCommand = f"cat {szKmerCountInAllWindows} | sort -k1,1V -k2,2n >{output}"
		print(szCommand)
		shell(szCommand)


# Groupby the bed file of k-mer counts at each base position to get the number of matching k-mers in each window
rule groupby_kmer_counts_in_windows:
	input:
		szKmerCountBedWithWindow
	output:
		szKmerCountInWindows
	localrule: True
	run:
		szCommand = "module load bedtools/2.29.2 && bedtools groupby -i {input} -g 6,7,8 -o count -c 5 >{output}"
		shell(szCommand)


# Assign the k-mer counts at each base position to the windows across the genome, so that
# we can then groupby to get the number of matching k-mers in each window
rule assign_kmer_counts_to_windows:
	input:
		szWindowsAcrossGenome,
		szKmerCountBed,
		szKmerCountBedSortedFlag
	output:
		szKmerCountBedWithWindow
	localrule: True
	run:
		szCommand = "module load bedtools2/2.31.0-gcc-8.2.0-7j35k74 && bedtools intersect -sorted -a {input[1]} -b {input[0]} -wa -wb >{output}"
		shell(szCommand)

		szCommand = "sort -k1,1V -k2,2n -c {output}"
		shell(szCommand)


# Check if the bed file of k-mer counts is sorted, and if not, sort it
rule check_bed_sorted:
	input:
		szKmerCountBed
	output:
		szKmerCountBedSortedFlag
	resources:
		threads=2,
		mem=8,
		disk=8
	run:
		szCommand = (
			"if ! sort -k1,1V -k2,2n -c \"{input}\" 2>/dev/null; "
			"then tmp=$(mktemp); "
			"sort -k1,1V -k2,2n \"{input}\" > \"$tmp\" && mv \"$tmp\" \"{input}\"; "
			"fi"
			" && touch {output}"
		)
		shell(szCommand)


# Convert the wig file of k-mer counts to a bed file of k-mer counts
rule convert_wig_to_bed:
	input:
		szKmerCountWig
	output:
		szKmerCountBed
	localrule: True
	run:
		szCommand = "module load bedops/2.4.41 && wig2bed --do-not-sort <{input} >{output}"
		shell(szCommand)


# Generate a wig file with the k-mer counts at each base position in the assembly
rule make_meryl_lookup:
	output:
		szKmerCountWig
	resources:
		threads=8,
		mem=32
	run:
		szCommand = f"module load meryl/1.4.1 && meryl-lookup -wig-count -output {output} -sequence {szAssemblyPath} -mers {szMerylDatabase}"
		print(szCommand)
		shell(szCommand)


# Generate a bed file of nWindowSize windows across the genome
rule make_windows_across_genome:
	input:
		szAssemblyFai
	output:
		szWindowsAcrossGenome
	localrule: True
	run:
		szCommand = f"module load bedtools2/2.31.0-gcc-8.2.0-7j35k74 && bedtools makewindows -g {input} -w {nWindowSize} >{output}"
		shell(szCommand)

		szCommand = (
			"if ! sort -k1,1V -k2,2n -c \"{output}\" 2>/dev/null; "
			"then tmp=$(mktemp); "
			"sort -k1,1V -k2,2n \"{output}\" > \"$tmp\" && mv \"$tmp\" \"{output}\"; "
			"fi"
		)
		shell(szCommand)


# Generate a bed file of the assembly from the fai file
rule assemblyFaiToBed:
	input:
		szAssemblyFai
	output:
		szAssemblyBed
	localrule: True
	run:
		szCommand = "cat {input} | awk '{{print $1\"\t1\t\"$2}}' >{output}"
		shell(szCommand)


# Generate the indexed assembly file
rule make_fai:
	input:
		szAssemblyPath
	output:
		szAssemblyFai
	localrule: True
	run:
		bIsInCWD = is_directly_in_cwd(str(input))
		# print(f"is in current directory {bIsInCWD}")

		if not bIsInCWD:
			szCommand = f"ln -sf {input}"
			shell(szCommand)
                        
		szCommand = f"module load samtools/1.20 && samtools faidx {szAssemblyBasename}"
		shell(szCommand)
