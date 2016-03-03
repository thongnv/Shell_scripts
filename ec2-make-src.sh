# make source to push to local server
echo ">>> $0 >>>"

if [ $# -lt 2 ]; then
	echo "Example: Run $0 8088 msufo"
	exit 1
else
    echo "Your command line contains $# arguments: [$1 $2]"
fi

SRC=MSRBF_UPLOAD
PORT=$1
DB=$2
RESTART_SCRIPT="restart-servers.sh"
SHELL_DIR='Shell'

function _ERR(){
	[[ $? -eq 0 ]] || {
		echo "### ERROR $? ###"
		exit 1
	}
}

# call with <fileName> <search_string> <replace_string>
function _replace() {
	sed "s/$2/$3/" "$1" > "/tmp/1.tmp"; _ERR
	cat "/tmp/1.tmp" > "$1"; _ERR
}

# pull lastest source code
function _gitPull(){
    git checkout develop; _ERR
	git pull; _ERR
}

echo "Getting latest code $SRC/"
cd $SRC/
_gitPull
echo "Getting latest code motools/"
cd motools/
_gitPull
cd ../..

echo "Making for src=$SRC, dest=$PORT, db=$DB"
echo "Removing $PORT/..."
rm -rf $PORT; _ERR
mkdir $PORT; _ERR

echo "Copying source from $SRC to $PORT/..."
for i in $SRC/* ; do cp -r $i $PORT/; done; _ERR

echo "Copying $SHELL_DIR/$RESTART_SCRIPT to $PORT/"
cp $SHELL_DIR/$RESTART_SCRIPT $PORT/; _ERR

echo "Modifying port..."
_replace "$PORT/config/__init__.py" 'PORT = .*$' "PORT=$PORT"
_replace "$PORT/config/__init__.py" 'LOCAL = .*$' "LOCAL = False"

#echo "Modifying dbconfig.."
#_replace "$PORT/customfbits/toolbox/drivers/dbconfig.py" ' NAME.*$' " NAME='$DB'"
#_replace "$PORT/config/dbconfig.py" ' NAME.*$' " NAME='$DB'"
#_replace "$PORT/motools/customfbits/toolbox/drivers/dbconfig.py" ' NAME.*$' " NAME='$DB'"
#_replace "$PORT/motools/config/dbconfig.py" ' NAME.*$' " NAME='$DB'"

#echo "Modifying sqs.."
#_replace "$PORT/common/awsmanager/sqs.py" 'q1 = conn.create_queue.*$' "q1=conn.create_queue('master_queue_$PORT')"
#_replace "$PORT/common/awsmanager/sqs.py" 'q2 = conn.create_queue.*$' "q2=conn.create_queue('secondary_queue_$PORT')"
#_replace "$PORT/motools/awsmanager/sqs.py" 'q1 = conn.get_queue.*$' "q1=conn.get_queue('master_queue_$PORT')"
#_replace "$PORT/motools/awsmanager/sqs.py" 'q2 = conn.get_queue.*$' "q2=conn.get_queue('secondary_queue_$PORT')"

echo "Removing $PORT/motools/"
rm -rf "$PORT/motools/"; _ERR
echo "Dang nen lai... $PORT.tar.gz"
tar -zcf "$PORT.tar.gz" $PORT; _ERR
echo "Removing $PORT/"
rm -rf $PORT; _ERR

echo "<<< END $0 <<<"

exit 0