#!/bin/bash
# Use > 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to > 0 the /etc/hosts part is not recognized ( may be a bug )

function print_usage(){
	echo -e "up3.sh [options] <port> <database>\n"\
			"options:\n"\
			"-bw|--branch-web: select branch web to upload\n"\
			"-bt|--branch-tool: select branch tool to upload\n"\
			"-iw|--ignore-web: don't upload web source\n"\
			"-it|--ignore-tool: don't upload tool source\n"\
			"--mode=local|cloud. Default=local. Upload to local or cloud\n"\
			"-h|--help. Print this help"
	exit 0
}

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

while [[ $# > 0 ]]
do
key="$1"

case $key in
    -bw|--branch-web)
    BRANCH_WEB="$2"
    shift # past argument
    ;;
	-bt|--branch-tool)
    BRANCH_TOOL="$2"
    shift # past argument
    ;;
	-iw|--ignore-web)
	IGNORE_WEB=True
	#echo "Not Implemented"; exit 1
	shift
	;;
	-it|--ignore-tool)
	IGNORE_TOOL=True
	#echo "Not Implemented"; exit 1
	shift
	;;
	-m|--mode)
	MODE=$2
	shift
	;;
	-h|--help)
	print_usage
	;;
    --default)
    DEFAULT=YES
	;;
    *)
    # parse port & database
	PORT="$1"
	DATABASE="$2"
	break
    ;;
esac
shift # past argument or value
done

### check params ###
([[ -z $PORT ]] || [[ -z $DATABASE ]]) && print_usage
[[ -z $BRANCH_WEB ]] && BRANCH_WEB=develop
[[ -z $BRANCH_TOOL ]] && BRANCH_TOOL=develop
[[ -z $MODE ]] && MODE=local

echo ">>> $0 >>>"
echo ">>> Script upload source web+tool to local/ >>>"
echo PORT  = "${PORT}"
echo DATABASE = "${DATABASE}"
echo BRANCH_WEB = "${BRANCH_WEB}"
echo BRANCH_TOOL = "${BRANCH_TOOL}"
echo MODE = "${MODE}"
echo IGNORE_WEB = "${IGNORE_WEB}"
echo IGNORE_TOOL = "${IGNORE_TOOL}"

### include common func ###
#PWD=$(dirname $0)
#source $PWD/common.sh

### CONSTANTS ###
HOST='fsu15@10.16.9.50'; [[ $MODE == "cloud" ]] && HOST='ec2-user@54.92.93.18'
SRC=MSRBF_UPLOAD
MOTOOLS=motools
EXTRACT_RUN_SCRIPT=extract-run.sh
RESTART_SCRIPT=Shell/restart-servers.sh
PORT_TAR_GZ=$PORT.tar.gz
UPLOAD_DEST_DIR='~/Sources/'
SHELL_DIR='Shell'
KEY='ms-ufo.pem'

echo "Making source code $PORT/"
echo "Getting latest code $SRC/"
cd $SRC/; git fetch; git checkout $BRANCH_WEB; _ERR; git pull; _ERR;
echo "Getting latest code $MOTOOLS/"
cd $MOTOOLS/; git fetch; git checkout $BRANCH_TOOL; _ERR; git pull; git gc; _ERR;
cd ../../

echo "Making for SRC=$SRC, PORT=$PORT, DATABASE=$DATABASE"
echo "Removing $PORT/..."
rm -rf $PORT; _ERR
mkdir $PORT; _ERR

echo "Copying source from $SRC to $PORT/..."
for i in $SRC/* ; do cp -r $i $PORT/; done; _ERR

echo "Copying $RESTART_SCRIPT to $PORT/"
cp $RESTART_SCRIPT $PORT/; _ERR

echo "Modifying port=$PORT..."
_replace "$PORT/config/__init__.py" 'PORT = .*$' "PORT=$PORT"

if [[ $MODE == 'local' ]]; then
	echo "Modifying dbconfig.."
	_replace "$PORT/config/dbconfig.py" ' NAME.*$' " NAME='$DATABASE'"
	_replace "$PORT/$MOTOOLS/config/dbconfig.py" ' NAME.*$' " NAME='$DATABASE'"

	echo "Modifying sqs.."
	_replace "$PORT/common/awsmanager/sqs.py" 'q1 = conn.create_queue.*$' "q1=conn.create_queue('master_queue_$PORT')"
	_replace "$PORT/common/awsmanager/sqs.py" 'q2 = conn.create_queue.*$' "q2=conn.create_queue('secondary_queue_$PORT')"
	_replace "$PORT/$MOTOOLS/awsmanager/sqs.py" 'q1 = conn.get_queue.*$' "q1=conn.get_queue('master_queue_$PORT')"
	_replace "$PORT/$MOTOOLS/awsmanager/sqs.py" 'q2 = conn.get_queue.*$' "q2=conn.get_queue('secondary_queue_$PORT')"
elif [[ $MODE == 'cloud' ]]; then
	echo "Modifying LOCAL=False.."
	_replace "$PORT/config/__init__.py" 'LOCAL = .*$' "LOCAL=False"
	_replace "$PORT/$MOTOOLS/config/__init__.py" 'LOCAL = .*$' "LOCAL=False"
else
	echo 'Not Implemented'; exit 1
fi

echo "Removing $PORT/$MOTOOLS/.git/"
rm -rf $PORT/$MOTOOLS/.git/; _ERR
echo "Dang nen lai... $PORT_TAR_GZ"
tar -zcf $PORT_TAR_GZ $PORT; _ERR
echo "Removing $PORT/"
rm -rf $PORT; _ERR

echo "Upload to $HOST"
scp Shell/$EXTRACT_RUN_SCRIPT $PORT_TAR_GZ $HOST:$UPLOAD_DEST_DIR; _ERR

if [[ $MODE == 'local' ]]; then
	# extract web + tool in local
	echo "Running script $EXTRACT_RUN_SCRIPT on $HOST"
	ssh $HOST "cd $UPLOAD_DEST_DIR; chmod +x $EXTRACT_RUN_SCRIPT;./$EXTRACT_RUN_SCRIPT $PORT;"; _ERR
	
elif [[ $MODE == 'cloud' ]]; then
	if [[ -z $IGNORE_WEB ]]; then
		echo "Running script $EXTRACT_RUN_SCRIPT on $HOST"
		ssh -i $SHELL_DIR/$KEY $HOST "cd $UPLOAD_DEST_DIR; chmod +x $EXTRACT_RUN_SCRIPT;./$EXTRACT_RUN_SCRIPT $PORT;"; _ERR
	fi
	if [[ -z $IGNORE_TOOL ]]; then
		echo "Copying $UPLOAD_DEST_DIR/$PORT_TAR_GZ from $HOST to 10.16.2.46"
		ssh -i $SHELL_DIR/$KEY $HOST "ssh -i ~/Settings/ms-ufo.pem 10.16.2.46 'mkdir -p $UPLOAD_DEST_DIR/'"; _ERR
		ssh -i $SHELL_DIR/$KEY $HOST "scp -i ~/Settings/ms-ufo.pem $UPLOAD_DEST_DIR/$PORT_TAR_GZ 10.16.2.46:$UPLOAD_DEST_DIR/"; _ERR
		ssh -i $SHELL_DIR/$KEY $HOST "ssh -i ~/Settings/ms-ufo.pem 10.16.2.46 'cd $UPLOAD_DEST_DIR/; tar -zxf $PORT_TAR_GZ;'"; _ERR
		ssh -i $SHELL_DIR/$KEY $HOST "ssh -i ~/Settings/ms-ufo.pem 10.16.2.46 'cp ~/Source/FDK/Tools/Programs/makeotf/exe/linux/release/makeotfexe ~/Source/motools_upload/utils/FDK/'"; _ERR
	fi
fi

echo "<<< END $0 <<<"
exit 0
