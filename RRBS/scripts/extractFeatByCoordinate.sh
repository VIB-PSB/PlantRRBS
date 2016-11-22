date
module load python
python3 --version
output=$1.annot
gff=$2
if [[ $# == 3 ]]; then
	output=$3
fi
echo "input: $1"
echo "output: $output"
python3 ngs/genofeat/gff/extractFeatByCoordinate.py multiple -g $gff--file $1 -o $output --delChr --promotor-length 2000

echo "Finished on $HOSTNAME"
date
