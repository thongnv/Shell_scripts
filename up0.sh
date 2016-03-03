#
# DUNGMV1
echo ">>> $0 >>>"
echo ">>> Script upload source web+tool to local/ >>>"

### check params ###
if [ $# -lt 2 ]; then
	echo "Example: $0 8088 msufo"; exit 1
else
    echo "Your command line contains $# arguments: [$1 $2]"
fi

### include common func ###
PWD=$(dirname $0)
source $PWD/common.sh

### CONSTANTS ###
HOST='fsu15@10.16.9.50'
DEST=$1
DB=$2
MAKE_SOURCE_SCRIPT=make-src-all-local.sh
EXTRACT_RUN_SCRIPT=extract-run.sh
SHELL_DIR='Shell'

echo "Making source code $DEST/"
$MAKE_SOURCE_SCRIPT $DEST $DB; _ERR

echo "Upload to $HOST"
scp $SHELL_DIR/$EXTRACT_RUN_SCRIPT $DEST.tar.gz $HOST:~/Sources/; _ERR

echo "Running script $EXTRACT_RUN_SCRIPT on $HOST"
ssh $HOST "cd ~/Sources/; chmod +x $EXTRACT_RUN_SCRIPT; export FDK_EXE=/home/fsu15/Sources/FDK/Tools/win;./$EXTRACT_RUN_SCRIPT $DEST;"; _ERR
ssh $HOST "cp ~/Sources/FDK/Tools/Programs/makeotf/exe/linux/debug/makeotfexe ~/Sources/$DEST/motools/utils/FDK/"; _ERR

echo "<<< END $0 <<<"
exit 0
