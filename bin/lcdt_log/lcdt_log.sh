#!/bin/bash
# This script is used to log messages in LCDT.
# It is used to print messages only if the specified level is greater than the default level.
# DEFAULT_LOG_LEVEL: 0: no log, 1: error, 2: info, 3: debug info
LCDT_SPECIFIED_LOG_LEVEL=2

if [ $# -eq 0 ]; then
  echo "ERROR: $LCDT_LOG_SH:must specify log level and log message"
  exit 1
fi

if ! [[ $1 =~ ^[0-3]$ ]]; then
  echo "ERROR: $LCDT_LOG_SH:must specify valid log level"
  exit 1
fi

DEFAULT_LOG_LEVEL=$1
shift
DEFAULT_LOG_MESSAGE=$@

if [ $LCDT_SPECIFIED_LOG_LEVEL -eq 0 ]; then
  exit 0
fi

if [ $LCDT_SPECIFIED_LOG_LEVEL -eq $DEFAULT_LOG_LEVEL ] || \
    [ $LCDT_SPECIFIED_LOG_LEVEL -gt $DEFAULT_LOG_LEVEL ]; then
  case $DEFAULT_LOG_LEVEL in
    0)
      exit 0
      ;;
    1)
      echo "ERROR: $DEFAULT_LOG_MESSAGE"
      ;;
    2)
      echo "INFO: $DEFAULT_LOG_MESSAGE"
      ;;
    3)
      echo "DEBUG: $DEFAULT_LOG_MESSAGE"
      ;;
  esac
fi