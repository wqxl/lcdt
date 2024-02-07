#!/bin/bash
LCDT_MGS_DIR=$(cd "$(dirname "$0")"; pwd)
LCDT_MGS_CREATE_SH=$LCDT_MGS_DIR/lcdt_mgs_create.sh
LCDT_LOG_SH=$LCDT_MGS_DIR/../lcdt_log/lcdt_log.sh

FUNCTION_NAME=""
MGS_FAILOVER=""
MGS_ID=0
MGS_HOSTS_LIST=()
MGS_BACKENDFS_TYPE=""
MGS_DEVICES_NAME=""

function lcdt_mgs_create_usage() {
  echo "usage: lcdt mgs create [-h] [-r <id>] -f <ho/ap> -b <zfs/ldiskfs> -d <device> host [host...]"
  echo "options:"
  echo "  -h, --help                      display this help and exit"
  echo "  -f, --failover                  failover type: 'ho' 'ap', default: 'ho'"
  echo "                                  ho: host only, ap: active/passive"
  echo "  -r, --replace <id>              replace mgs with <id>"
  echo "  -b, --backend <zfs/ldiskfs>     lustre backend fs type"
  echo "  -d, --data <device>             mgs data device, eg: sdb, sdc"
}


function lcdt_mgs_create_get_options() {
  FUNCTION_NAME="lcdt_mgs_create_get_options"
  # check parameters count
  if [ $# -eq 0 ]; then
    lcdt_mgs_create_usage
    exit 1
  fi

  options="hr:f:b:d:"
  loptions="help,replace:,failover:,backend:,data:"
  parameters=$(getopt -o $options -l $loptions -n "$LCDT_MGS_CREATE_SH" -- "$@")

  # check parse result
  if [ $? -ne 0 ]; then
    exit 1
  fi

  eval set -- "$parameters"

  while true; do
    case "$1" in
      -h|--help)
        lcdt_mgs_create_usage
        exit 0
        ;;
      -f|--failover)
        if [ "$2" != "ho" ] && [ "$2" != "ap" ]; then
          echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:unknown failover: $2"
          exit 1
        fi
        MGS_FAILOVER="$2"
        shift 2
        ;;
      -r|--replace)
        MGS_ID=$2
        shift 2
        ;;
      -b|--backend)
        if [ "$2" != "zfs" ] && [ "$2" != "ldiskfs" ]; then
          echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:unknown backend: $2"
          exit 1
        fi
        MGS_BACKENDFS_TYPE=$2
        shift 2
        ;;
      -d|--data)
        MGS_DEVICES_NAME=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      *)
        echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:unknown option: $1"
        exit 1
        ;;
    esac
  done

  MGS_HOSTS_LIST=($@)
}

function lcdt_mgs_create_check_options() {
  FUNCTION_NAME="lcdt_mgs_create_check_options"
  # check failover
  if [ "$MGS_FAILOVER" == "" ]; then
    echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:no failover specified"
    exit 1
  fi

  # check backend
  if [ "$MGS_BACKENDFS_TYPE" == "" ]; then
   echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:no backend specified"
    exit 1
  fi

  # check device
  if [ "$MGS_DEVICES_NAME" == "" ]; then
    echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:no data device specified"
    exit 1
  fi

  # check hosts
  if [ ${#MGS_HOSTS_LIST[@]} -eq 0 ]; then
   echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:no host specified"
    exit 1
  fi

  if [ "$MGS_FAILOVER" == "ho" ]; then
    if [ ${#MGS_HOSTS_LIST[@]} -ne 1 ]; then
      echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:only one host can be specified when failover=ho"
      exit 1
    fi
    
  fi

  if [ "$MGS_FAILOVER" == "ap" ]; then
    if [ ${#MGS_HOSTS_LIST[@]} -lt 2 ]; then
      echo "ERROR: $LCDT_MGS_CREATE_SH:$FUNCTION_NAME:at least two hosts should be specified when failover=ap"
      exit 1
    fi
  fi

  $LCDT_LOG_SH 3 "$LCDT_MGS_CREATE_SH:$FUNCTION_NAME:$MGS_ID $MGS_BACKENDFS_TYPE $MGS_DEVICES_NAME ${MGS_HOSTS_LIST[@]}"
}

function lcdt_mgs_create_main() {
  FUNCTION_NAME="lcdt_mgs_create"
  # get options
  lcdt_mgs_create_get_options $@
  # check options
  lcdt_mgs_create_check_options
}

$LCDT_LOG_SH 3 $@
lcdt_mgs_create_main $@
