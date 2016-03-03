#
echo ">>> $0 >>>"
echo ">>> Script for uploading src tool to ms-ufo-api/ >>>"

if [ $# -lt 1 ]; then
	echo "Example: $0 msufo"
	exit 1
else
    echo "Your command line contains $# arguments: [$1]"
fi

HOST='ec2-user@54.92.93.18'
KEY='ms-ufo.pem'
DB=$1
MAKE_SOURCE='make-src-tool.sh'
EXTRACT_RUN='extract-run.sh'
SHELL_DIR='Shell'
DEST='motools.tar.gz'
TOOL_HOST='10.16.2.46'
TOOL_HOST_SSH='ssh -i ~/Settings/ms-ufo.pem 10.16.2.46'

function _ERR(){
	[[ $? -eq 0 ]] || {
		echo "### ERROR $? ###"
		exit 1
	}
}

echo "Making source code"
$MAKE_SOURCE $DB ;_ERR

echo "Upload to $HOST"
scp -i $SHELL_DIR/$KEY $DEST $HOST:/tmp/;_ERR

echo "Copying $DEST from $HOST to $TOOL_HOST"
ssh -i $SHELL_DIR/$KEY $HOST "scp -i ~/Settings/ms-ufo.pem /tmp/$DEST $TOOL_HOST:~/Source/"; _ERR
echo "Copying $DEST from $HOST to $TOOL_HOST"
ssh -i $SHELL_DIR/$KEY $HOST "ssh -i ~/Settings/ms-ufo.pem $TOOL_HOST 'cd ~/Source/; mkdir motools; cd motools;'"; _ERR
ssh -i $SHELL_DIR/$KEY $HOST "ssh -i ~/Settings/ms-ufo.pem $TOOL_HOST 'cd ~/Source/; tar -zxf $DEST;'"; _ERR
ssh -i $SHELL_DIR/$KEY $HOST "ssh -i ~/Settings/ms-ufo.pem $TOOL_HOST 'cd ~/Source/; tar -zxf $DEST; ls motools_upload'"; _ERR
ssh -i $SHELL_DIR/$KEY $HOST "ssh -i ~/Settings/ms-ufo.pem $TOOL_HOST 'cp ~/Source/FDK/Tools/Programs/makeotf/exe/linux/release/makeotfexe ~/Source/motools_upload/utils/FDK/'"; _ERR

echo "<<< END $0 <<<"
exit 0