#
echo ">>> $0 >>>"

PORT=${PWD##*/}
IFS='
'

function _ERR(){
	[[ $? -eq 0 ]] || {
		echo "### ERROR $? ###"
		exit 1
	}
}

for i in `ps aux|grep python`;do
  pid=`echo $i|awk '{print $2'}`; _ERR
  #echo $pid;
  pid2=`pwdx $pid 2>/dev/null|grep $PORT|awk -F':' '{print $1}'`; _ERR
  #echo $pid2;
  if [[ $pid2 ]]; then 
    echo "Found: pid=$pid2, killing...";
    sudo kill -9 $pid2;
  fi;
done

echo "Start servers..."
export FDK_EXE=/home/fsu15/Sources/FDK/Tools/win; _ERR
python server.py &
if [[ -f motools/server.py ]]; then
    python motools/server.py &
fi

echo "<<< END $0 <<<"
exit 0