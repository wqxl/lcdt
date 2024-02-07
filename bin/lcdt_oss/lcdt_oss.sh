#!/bin/bash
LCDT_OSS_DIR=$(cd "$(dirname "$0")"; pwd)
LCDT_OSS_SH=$LCDT_OSS_DIR/lcdt_oss.sh
LCDT_OSS_CREATE_SH=$LCDT_OSS_DIR/lcdt_oss_create.sh
LCDT_LOG_SH=$LCDT_OSS_DIR/../lcdt_log/lcdt_log.sh

FUNCTION_NAME=""

function lcdt_oss_usage() {
  echo "usage: lcdt oss [-h] [commands]..."
  echo "options:"
  echo "  -h, --help                      display this help and exit"
  echo "commands:"
  echo "  create                          create a lustre management server"
  echo "  add                             add a lustre management server"
  echo "  destroy                         destroy a lustre management server"
  echo "see 'lcdt oss <command> --help' for more information on a specific command."
}

function lcdt_oss_get_options() {
  FUNCTION_NAME="lcdt_oss_get_options"
  # check parameters count
  if [ $# -eq 0 ]; then
    lcdt_oss_usage
    exit 1
  fi

  # check parameters
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        lcdt_mgs_usage
        exit 0
        ;;
      create)
        shift
        $LCDT_OSS_CREATE_SH $@
        break
        ;;
      add)
        shift
        break
        ;;
      destroy)
        shift
        break
        ;;
      *)
        echo "ERROR: $LCDT_OSS_SH:$FUNCTION_NAME:unknown command: $1"
        exit 1
        ;;
    esac
  done
}

function lcdt_oss_main() {
  FUNCTION_NAME="lcdt_oss_main"
  # get options
  lcdt_oss_get_options $@
}

$LCDT_LOG_SH 3 $@
lcdt_oss_main $@