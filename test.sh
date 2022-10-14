#!/bin/bash

while [[ -n $1 ]]
do
case "$1" in
  unzip)
    shift
    action=gunzip
    ;;
  zip)
    shift
    action=gzip
    ;;
  *)
    file=$1
    shift
esac
done

echo action: $action file: $file

if [[ -n $action ]]; then
$action $file &
result=`lsof $file | tail -n1 | awk '{print $2, $4, $7}'`
IFS=' '
read -raresults<<<"$result"
echo $result
pid=${results[0]}
fid=${results[1]%?} # remove last character (we know it is 'r')
size=${results[2]}
echo $pid $fid $size
fi

# clear disk cache
# sync; echo 1 > sudo /proc/sys/vm/drop_caches