SRC='MSRBF'
SRC='motools'
DEST='MSRBF-UT'
DEST2='motools-UT'

echo "Removing source code in $DEST"
cd $DEST
for i in *; do rm -r $i; done

echo "Copying new code from $SRC to $DEST"
cd ..
cp -r MSRBF/* MSRBF-UT/

echo "Removing source code in $DEST2"
cd $DEST2
for i in *; do rm -r $i; done

echo "Copying new code from $SRC2 to $DEST2"
cd ..
cp -r motools/* motools-UT/
