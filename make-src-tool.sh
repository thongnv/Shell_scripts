# make source to push to cloud tool
echo ">>> $0 >>>"

SRC='MSRBF_UPLOAD/motools'
DEST='motools'
FOLDER='motools'
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
cd ../../

echo "Making for src=$SRC, dest=$DEST, db=$DB"
echo "Removing $DEST/..."
rm -rf $DEST; _ERR
mkdir $DEST; _ERR
cd $DEST; _ERR
mkdir $FOLDER; _ERR
cd ..
echo "Copying source from $SRC to $DEST/..."
for i in $SRC/* ; do cp -r $i $DEST/; done; _ERR

echo "Copying $SHELL_DIR/$RESTART_SCRIPT to $DEST/"
cp $SHELL_DIR/$RESTART_SCRIPT $DEST/; _ERR

echo "Modifying config..."
_replace "$DEST/config/__init__.py" 'LOCAL = .*$' "LOCAL = False"
_replace "$DEST/config/__init__.py" 'NAME =.*$' 'NAME = $DB'
_replace "$DEST/config/__init__.py" 'DEVELOP_MODE.*$' "DEVELOP_MODE = False"

echo "Dang nen lai... $DEST.tar.gz"
tar -zcf "$DEST.tar.gz" $DEST; _ERR
echo "Removing $DEST/"
rm -rf $DEST; _ERR

echo "<<< END $0 <<<"

exit 0