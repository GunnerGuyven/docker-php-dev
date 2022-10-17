#!/bin/bash

# Utility to monitor a zip (or unzip)
# action and report percentage progress.

while [[ -n $1 ]]; do
case "$1" in
  unzip)
    shift
    action='unzip'
    action_exe='gzip -d'
    ;;
  zip)
    shift
    action='zip'
    action_exe='gzip'
    ;;
  *)
    file=$1
    shift
esac
done

# echo action: $action file: $file

if [[ -n $action ]]; then
  $action_exe $file &
  result=`lsof $file | tail -n1 | awk '{print $2, $4, $7}'`
  IFS=' '
  read -raresults<<<"$result"
  pid=${results[0]}
  fid=${results[1]%?} # remove last character (we know it is 'r')
  size=${results[2]}
  percent_size=$((size/100))
  # echo $pid $fid $size
  
  fopen=`cat /proc/$pid/fdinfo/$fid`
  while [[ $? -eq 0 ]]; do
    pos=`echo $fopen | head -n1 | awk '{print $2}'`
    progress=`bc<<<"scale=2; $pos/$percent_size"`
    echo -ne " $progress %\r"
    sleep 0.1
    {
      fopen=`cat /proc/$pid/fdinfo/$fid`
    } &> /dev/null
  done

  echo "$action complete"

fi

# clear disk cache
# sync; echo 1 > sudo /proc/sys/vm/drop_caches