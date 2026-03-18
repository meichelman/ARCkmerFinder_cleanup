szFaiFile=$1
nContigsToDisplayLeftAndRight=$2
szFileOfContigsToDisplayLeft=$3
szFileOfContigsToDisplayRight=$4

nDoubleLeftAndRight=$((2*$nContigsToDisplayLeftAndRight))

nNumberOfContigs=`wc -l $szFaiFile | awk '{print $1}'`



if [ $nNumberOfContigs -lt $nDoubleLeftAndRight ]
then
    echo "Error:  you are specifying $nContigsToDisplayLeftAndRight contigs on the left and $nContigsToDisplayLeftAndRight contigs on the right but there are only $nNumberOfContigs contigs total"
    exit
fi


szTemp=`mktemp`
cat $szFaiFile | sort -k2,2nr | awk '{print $1}' | head -$nDoubleLeftAndRight >$szTemp

head -$nContigsToDisplayLeftAndRight $szTemp >$szFileOfContigsToDisplayLeft
tail -$nContigsToDisplayLeftAndRight $szTemp >$szFileOfContigsToDisplayRight



