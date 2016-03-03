#
# DUNGMV1
echo ">>> $0 >>>"

### check params ###
if [ $# -lt 1 ]; then
    echo "Example: Run $0 8088"; exit 1
else
    echo "Your command line contains $# arguments: [$1]"
fi

### include common func ###
function _ERR(){
	[[ $? -eq 0 ]] || {
		echo "### ERROR $? ###"
		exit 1
	}
}

### CONSTANTS ###
PORT=$1
FILE=$PORT.tar.gz
#RESTART_SCRIPT="restart-servers.sh"

if [[ -f $FILE ]]; then
    echo "Removing $PORT/"
    rm -rf $PORT; _ERR
    echo "Found $FILE. Extracting..."
    tar -mzxf $FILE; _ERR
    echo "Running chmod shell in $PORT/..."
    chmod +x $PORT/*.sh; _ERR
	#echo "Restarting servers in $PORT/"
	#cd $PORT/; _ERR
	#./$RESTART_SCRIPT
fi

echo "<<< END $0 <<<"
exit 0