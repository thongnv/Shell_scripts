IFS='
'

for i in `ps aux|grep python`;do
  pid=`echo $i|awk '{print $2'}`;
  pwdx $pid 2>/dev/null;
done

