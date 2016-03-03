#
echo ">>> $0 >>>"
echo ">>> Script for uploading src tool to ms-ufo-api/ >>>"

PWD=$(dirname $0)
source $PWD/uptool.sh.cfg

echo "Making source code"
$MAKE_SOURCE ;_ERR

echo "Upload to $HOST"
scp $DEST $HOST:/tmp/;_ERR

echo "Copying $DEST from $HOST to ms-ufo-api/"

ssh $HOST "scp -i ~/Settings/ms-ufo.pem /tmp/$DEST 10.16.2.46:~/Source2/"; _ERR
ssh $HOST "ssh -i ~/Settings/ms-ufo.pem 10.16.2.46 'cd ~/Source2/; tar -zxf $DEST; ls motools_upload'"; _ERR

echo "<<< END $0 <<<"
exit 0