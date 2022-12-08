#!/bin/bash

PROGNAME=$(basename $0)
usage(){
  echo
  echo "usage: $PROGNAME [-f file | -i]"
}

# ./32_posit_param_file_info.sh --file=32_posit_param.sh 
file_info () {
  if [[ -e $1 ]];then
    echo -e "\nFile Type:"
    file $1
    echo -e "\nFile Status:"
    stat $1
  else
    echo "$FUNCNAME: usage: $FUNCNAME file" >&2
    return 1
  fi 
}

for i in "$@"
do
  case $i in
    -h )
      usage
      exit 0;;
    --file=* )
      FILENAME="${i#--file=}" ;; 
    * )
      echo "unknow param $i"
      exit 1;; 
  esac   
done
file_info $FILENAME