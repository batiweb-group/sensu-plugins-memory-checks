#!/usr/bin/env /bin/sh
#
# Evaluate free system memory from Linux based systems.
#
# Date: 2007-11-12
# Author: Thomas Borger - ESG
# Date: 2012-04-02
# Modified: Norman Harman - norman.harman@mutualmobile.com
#
# The memory check is done with following command line:
# free -m | grep buffers/cache | awk '{ print $4 }'

# set lang
LANG=C

# get arguments

# #RED
while getopts 'w:c:hp' OPT; do
  case $OPT in
    w)  WARN=$OPTARG;;
    c)  CRIT=$OPTARG;;
    h)  hlp="yes";;
    p)  perform="yes";;
    *)  unknown="yes";;
  esac
done

# usage
HELP="
    usage: $0 [ -w value -c value -p -h ]

        -w --> Warning MB < value
        -c --> Critical MB < value
        -p --> print out performance data
        -h --> print this help screen
"

if [ "$hlp" = "yes" ]; then
  echo "$HELP"
  exit 0
fi

if [ -z "$WARN" ] || [ -z "$CRIT" ]; then
  echo "You must provide both warning and critical values"
  exit 3
fi

set -o pipefail
FREE_MEMORY=$(free -m | grep buffers/cache | awk '{ print $4 }')
if [ $? -ne 0 ]; then
  FREE_MEMORY=$(free -m | grep Mem | awk '{ print $7 }')
fi

if [ "$FREE_MEMORY" = "" ]; then
  echo "MEM UNKNOWN -"
  exit 3
fi

if [ "$perform" = "yes" ]; then
  output="free system memory: $FREE_MEMORY MB | free memory="$FREE_MEMORY"MB;$WARN;$CRIT;0"
else
  output="free system memory: $FREE_MEMORY MB"
fi

if [ $FREE_MEMORY -le $CRIT ]; then
  echo "MEM CRITICAL - $output"
  exit 2
elif [ $FREE_MEMORY -le $WARN ]; then
  echo "MEM WARNING - $output"
  exit 1
else
  echo "MEM OK - $output"
  exit 0
fi
