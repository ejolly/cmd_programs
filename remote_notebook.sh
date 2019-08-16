#!/bin/bash

# Open a remote jupyter notebook using remote (non-container) Anaconda environment, optionally in a specific directory otherwise in datax
# Aliased to jpr [filepath]
BASEDIR="/dartfs/rc/lab/D/DBIC/cosanlab/datax/Projects"
PORT=9767
if [ $# -eq 0 ]; then
  DIR="$BASEDIR/Data/ejolly"
elif [ "$1" == "-h" ]; then
  echo "Start a remote jupyter notebook on ndoli in the specified directory provided by the first argument. Path should be relative to datax. Otherwise start a notebook within datax/Data/ejolly (aka old idata home)."
  echo "./remote_notebook"
  echo "specific directory: ./remote_notebook Projects/fnl_memory/code"
  exit 0
else
  DIR="$BASEDIR/$1"
fi

ssh -L 127.0.0.1:3130:127.0.0.1:9767 f000f7b@ndoli.dartmouth.edu "source ~/.bash_profile; source activate base; cd $DIR; jp"

# Holdover snippet from initializing at a random port
# if [ $# -eq 0 ]; then
# 	PORT=$(( ( RANDOM % 49151 )  + 10000 ))
# elif [ "$1" == "-r" ]; then
# 	PORT=$(( ( RANDOM % 49151 )  + 10000 ))
# elif [ "$1" == "-h" ]; then
#   echo "Start a remote jupyter notebook on ndoli on a random port or preferred port. Deploys with user's jupyter install."
#   echo "random port: ./remote_notebook or ./remote_notebook -r"
#   echo "preferred port: ./remote_notebook 9119"
#   echo "specific directory: ./remote_notebook -r /path/to/dir"
#   exit 0
# else
# 	PORT=$1
# fi

# if (($# == 2)); then
# 	DIR=$2
# else
# 	DIR='~'
# fi

# ssh -L 127.0.0.1:3129:127.0.0.1:$PORT ejolly@ndoli.dartmouth.edu "cd $DIR && ~/anaconda2/bin/jupyter notebook --port=$PORT --ip=0.0.0.0 --no-browser"