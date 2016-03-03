#
echo ">>> $0 >>>"

if [ $# -lt 2 ]; then
	echo "Example: $0 8088 msufo"
	exit
else
    echo "Your command line contains $# arguments: [$1 $2]"
fi

USER=fsu15
HOST='ec2-user@54.92.93.18'
KEY='ms-ufo.pem'
PORT=$1
DB=$2
MAKE_SOURCE=ec2-make-src.sh
EXTRACT_RUN=extract-run.sh
SHELL_DIR='Shell'

function _ERR(){
	[[ $? -eq 0 ]] || {
		echo "### ERROR $? ###"
		exit 1
	}
}

echo "Making source code $PORT/"
$MAKE_SOURCE $PORT $DB
_ERR

echo "Upload to $HOST"
scp -i $SHELL_DIR/$KEY $SHELL_DIR/$EXTRACT_RUN "$PORT.tar.gz" "$HOST:~/Sources/"
_ERR

echo "Running script $EXTRACT_RUN on $HOST"
ssh -i $SHELL_DIR/$KEY $HOST "cd ~/Sources/; chmod +x $EXTRACT_RUN; export FDK_EXE=/home/fsu15/Sources/FDK/Tools/win;./$EXTRACT_RUN $PORT;"
_ERR

echo "<<< END $0 <<<"
exit 0