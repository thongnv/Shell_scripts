#
# DUNGMV1
# make source to push to local server
echo ">>> $0 >>>"

### check params ###
if [ $# -lt 2 ]; then
	echo "Example: Run $0 8088 msufo"; exit 1
else
    echo "Your command line contains $# arguments: [$1 $2]"
fi

### include common func ###
PWD=$(dirname $0)
source $PWD/common.sh

### CONSTANTS ###
SRC=MSRBF_UPLOAD
PORT=$1
DB=$2
RESTART_SCRIPT="Shell/restart-servers.sh"

echo "Getting latest code $SRC/"
cd $SRC/; _gitPull
echo "Getting latest code motools/"
cd motools/; _gitPull
cd ../..

echo "Making for src=$SRC, dest=$PORT, db=$DB"
echo "Removing $PORT/..."
rm -rf $PORT; _ERR
mkdir $PORT; _ERR

echo "Copying source from $SRC to $PORT/..."
for i in $SRC/* ; do cp -r $i $PORT/; done; _ERR

echo "Copying $RESTART_SCRIPT to $PORT/"
cp $RESTART_SCRIPT $PORT/; _ERR

echo "Modifying port..."
_replace "$PORT/config/__init__.py" 'PORT = .*$' "PORT=$PORT"

echo "Modifying dbconfig.."
_replace "$PORT/config/dbconfig.py" ' NAME.*$' " NAME='$DB'"
_replace "$PORT/motools/config/dbconfig.py" ' NAME.*$' " NAME='$DB'"

echo "Modifying sqs.."
_replace "$PORT/config/awsconfig.py" 'MASTER_QUEUE.*$' "MASTER_QUEUE = 'master_queue_$PORT'"
_replace "$PORT/config/awsconfig.py" 'SECONDARY_QUEUE.*$' "SECONDARY_QUEUE = 'secondary_queue_$PORT'"
_replace "$PORT/motools/config/awsconfig.py" 'MASTER_QUEUE.*$' "MASTER_QUEUE = 'master_queue_$PORT'"
_replace "$PORT/motools/config/awsconfig.py" 'SECONDARY_QUEUE.*$' "SECONDARY_QUEUE = 'secondary_queue_$PORT'"
echo "Set develop mode to False"
_replace "$PORT/motools/config/__init__.py" 'DEVELOP_MODE.*$' "DEVELOP_MODE = False"

echo "Removing $PORT/motools/.git/"
rm -rf $PORT/motools/.git/; _ERR
echo "Dang nen lai... $PORT.tar.gz"
tar -zcf $PORT.tar.gz $PORT; _ERR
echo "Removing $PORT/"
rm -rf $PORT; _ERR

echo "<<< END $0 <<<"
exit 0