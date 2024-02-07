#!/bin/bash
LCDT_MDS_DIR=$(cd "$(dirname "$0")"; pwd)
LCDT_MDS_SH=$LCDT_MDS_SH/lcdt_mds.sh
LCDT_MDS_CREATE_SH=$LCDT_MDS_DIR/lcdt_mds_create.sh
LCDT_LOG_SH=$LCDT_MDS_DIR/../lcdt_log/lcdt_log.sh

FUNCTION_NAME=""

function lcdt_mds_usage() {
  echo "usage: lcdt mds [-h] [commands]..."
  echo "options:"
  echo "  -h, --help                      display this help and exit"
  echo "commands:"
  echo "  create                          create a lustre management server"
  echo "  add                             add a lustre management server"
  echo "  destroy                         destroy a lustre management server"
  echo "see 'lcdt mds <command> --help' for more information on a specific command."
}

function lcdt_mds_get_options() {
  FUNCTION_NAME="lcdt_mds_get_options"

  # check parameters count
  if [ $# -eq 0 ]; then
    lcdt_mds_usage
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
        $LCDT_MDS_CREATE_SH $@
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
        echo "ERROR: $LCDT_MDS_SH:$FUNCTION_NAME:unknown command: $1"
        exit 1
        ;;
    esac
  done
}

function lcdt_mds_main() {
  FUNCTION_NAME="lcdt_mds_main"
  # get options
  lcdt_mds_get_options $@
}

$LCDT_LOG_SH 3 $@
lcdt_mds_main $@