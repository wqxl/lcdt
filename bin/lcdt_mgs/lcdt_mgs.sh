#!/bin/bash
LCDT_MGS_DIR=$(cd "$(dirname "$0")"; pwd)
LCDT_MGS_SH=$LCDT_MGS_DIR/lcdt_mgs.sh
LCDT_MGS_CREATE_SH=$LCDT_MGS_DIR/lcdt_mgs_create.sh
LCDT_LOG_SH=$LCDT_MGS_DIR/../lcdt_log/lcdt_log.sh

FUNCTION_NAME=""

function lcdt_mgs_usage() {
  echo "usage: lcdt mgs [-h] [commands]..."
  echo "options:"
  echo "  -h, --help                      display this help and exit"
  echo "commands:"
  echo "  create                          create a lustre management server"
  echo "  destroy                         destroy a lustre management server"
  echo "see 'lcdt mgs <command> --help' for more information on a specific command."
}

function lcdt_mgs_get_options() {
  FUNCTION_NAME="lcdt_mgs_get_options"
  # check parameters count
  if [ $# -eq 0 ]; then
    lcdt_mgs_usage
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
        $LCDT_MGS_CREATE_SH $@
        break
        ;;
      destroy)
        shift
        break
        ;;
      *)
        echo "ERROR: $LCDT_MGS_SH:$FUNCTION_NAME:unknown command: $1"
        exit 1
        ;;
    esac
  done
}

function lcdt_mgs_main() {
  FUNCTION_NAME="lcdt_mgs_main"
  # get options
  lcdt_mgs_get_options $@
}

$LCDT_LOG_SH 3 $@
lcdt_mgs_main $@