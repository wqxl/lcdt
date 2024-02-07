#!/bin/bash
LCDT_DIR=$(cd "$(dirname "$0")" && pwd)
LCDT_SH=$LCDT_DIR/lcdt.sh
LCDT_INSSTALL_SH=$LCDT_DIR/bin/lcdt_install/lcdt_install.sh
LCDT_REMOVE_SH=$LCDT_DIR/bin/lcdt_remove/lcdt_remove.sh
LCDT_PURGE_SH=$LCDT_DIR/bin/lcdt_purge/lcdt_purge.sh
LCDT_MGS_SH=$LCDT_DIR/bin/lcdt_mgs/lcdt_mgs.sh
LCDT_MDS_SH=$LCDT_DIR/bin/lcdt_mds/lcdt_mds.sh
LCDT_OSS_SH=$LCDT_DIR/bin/lcdt_oss/lcdt_oss.sh

FUNCTION_NAME=""

function lcdt_usage() {
  echo "usage: lcdt [-h] [commands]"
  echo "options:"
  echo "  -h, --help      display this help and exit"
  echo "  -v, --version   display version information and exit"
  echo "commands:"
  echo "  install         install lustre packages on remote hosts"
  echo "  remove          remove lustre packages from remote hosts"
  echo "  purge           remove both lustre packages and data from remote hosts"
  echo "  mgs             lustre mgs daemon management"
  echo "  mds             lustre mds daemon management"
  echo "  oss             lustre oss daemon management"
  echo "see 'lcdt <command> --help' for more information on a specific command."
}

function lcdt_main() {
  FUNCTION_NAME="lcdt_main"
  # check parameters count
  if [ $# -eq 0 ]; then
    lcdt_usage
    exit 1
  fi

  # check parameters
  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help)
        lcdt_usage
        exit 0
        ;;
      -v|--version)
        echo "lcdt version 0.0.1"
        exit 0
        ;;
      install)
        shift
        $LCDT_INSSTALL_SH $@
        break
        ;;
      remove)
        shift
        $LCDT_REMOVE_SH $@
        break
        ;;
      purge)
        shift
        $LCDT_PURGE_SH $@
        break
        ;;
      mgs)
        shift
        $LCDT_MGS_SH $@
        break
        ;;
      mds)
        shift
        $LCDT_MDS_SH $@
        break
        ;;
      oss)
        shift
        $LCDT_OSS_SH $@
        break
        ;;
      *)
        echo "ERROR: $LCDT_SH:$FUNCTION_NAME:unknown command: $1"
        exit 1
        ;;
    esac
  done
}

lcdt_main $@