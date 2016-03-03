if [ $# -lt 1 ]; then
	echo "Example: Run $0 8088"
	exit
else
    echo "Your command line contains $# arguments: [$1]"
fi

PORT=$1
FILE="$PORT.tar.gz"

if [[ -f $FILE ]]; then
	echo "Removing $PORT/"
	rm -rf $PORT
	echo "Found $FILE. Extracting..."
	tar -zxf $FILE
	echo "Running chmod shell in $PORT/..."
	chmod -v +x $PORT/*.sh
fi
