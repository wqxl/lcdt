#!/bin/bash
LCDT_MDS_DIR=$(cd "$(dirname "$0")"; pwd)
LCDT_MDS_CREATE_SH=$LCDT_MDS_DIR/lcdt_mds_create.sh
LCDT_LOG_SH=$LCDT_MDS_DIR/../lcdt_log/lcdt_log.sh

FUNCTION_NAME=""
MDS_FAILOVER=""
MDS_ID=0
MDS_HOSTS_LIST=()
MDS_BACKENDFS_TYPE=""
MDS_DEVICES_NAME=""

function lcdt_mds_create_usage() {
  echo "usage: lcdt mds create [-h] [-r <id>] -i <id> -f <ho/ap> -b <zfs/ldiskfs> -d <device> host [host...]"
  echo "options:"
  echo "  -h, --help                      display this help and exit"
  echo "  -f, --failover                  failover type: 'ho' 'aa' 'ap', default: 'ho'"
  echo "                                  ho: host only, aa: active/active, ap: active/passive"
  echo "  -r, --replace <id>              replace mds with <id>"
  echo "  -i, --index <id>                mds id, default: 0"
  echo "  -b, --backend <zfs/ldiskfs>     lustre backend fs type"
  echo "  -d, --data <device>             mds data device, eg: sdb, sdc"
}

function lcdt_mds_create_get_options() {
  FUNCTION_NAME="lcdt_mds_create_get_options"
  # check parameters count
  if [ $# -eq 0 ]; then
    lcdt_mds_create_usage
    exit 1
  fi

  options="hr:f:b:d:i:"
  loptions="help,replace:,failover:,backend:data:index:"
  parameters=$(getopt -o $options -l $loptions -n "$LCDT_MDS_CREATE_SH" -- "$@")

  # check parse result
  if [ $? -ne 0 ]; then
    exit 1
  fi

  eval set -- "$parameters"

  while true; do
    case "$1" in
      -h|--help)
        lcdt_mds_create_usage
        exit 0
        ;;
      -f|--failover)
        if [ "$2" != "ho" ] && [ "$2" != "ap" ] && [ "$2" != "aa" ]; then
          echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:unknown failover: $2"
          exit 1
        fi
        MDS_FAILOVER="$2"
        shift 2
        ;;
      -r|--replace)
        MDS_ID=$2
        shift 2
        ;;
      -b|--backend)
        if [ "$2" != "zfs" ] && [ "$2" != "ldiskfs" ]; then
          echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:unknown backend: $2"
          exit 1
        fi
        MDS_BACKENDFS_TYPE=$2
        shift 2
        ;;
      -d|--data)
        MDS_DEVICES_NAME=$2
        shift 2
        ;;
      --)
        shift
        get_command $@
        break
        ;;
      *)
        echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:unknown option: $1"
        exit 1
        ;;
    esac
  done

  MDS_HOSTS_LIST=($@)
}

function lcdt_mds_create_check_options() {
  FUNCTION_NAME="lcdt_mds_create_check_options"
  # check failover
  if [ "$MDS_FAILOVER" == "" ]; then
    echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:no failover specified"
    exit 1
  fi

  # check backend
  if [ "$MDS_BACKENDFS_TYPE" == "" ]; then
    echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:no backend specified"
    exit 1
  fi

  # check device
  if [ "$MDS_DEVICES_NAME" == "" ]; then
    echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:no data device specified"
    exit 1
  fi

  # check hosts
  if [ ${#MDS_HOSTS_LIST[@]} -eq 0 ]; then
    echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:no host specified"
    exit 1
  fi

  if [ "$MDS_FAILOVER" == "ho" ]; then
    if [ ${#MDS_HOSTS_LIST[@]} -ne 1 ]; then
      echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:only one host can be specified when failover=ho"
      exit 1
    fi
  fi

  if [ "$MDS_FAILOVER" == "ap" ]; then
    if [ ${#MDS_HOSTS_LIST[@]} -lt 2 ]; then
      echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:at least two hosts must be specified when failover=ap"
      exit 1
    fi
  fi

  if [ "$MDS_FAILOVER" == "aa" ]; then
    if [ ${#MDS_HOSTS_LIST[@]} -lt 2 ]; then
      echo "ERROR: $LCDT_MDS_CREATE_SH:$FUNCTION_NAME:at least two hosts must be specified when failover=aa"
      exit 1
    fi
  fi

  $LCDT_LOG_SH 3 "$LCDT_MDS_CREATE_SH:$FUNCTION_NAME:$MDS_ID $MDS_BACKENDFS_TYPE $MDS_DEVICES_NAME ${MDS_HOSTS_LIST[@]}"
}

function lcdt_mds_create_main() {
  FUNCTION_NAME="lcdt_mds_create_main"
  # get options
  lcdt_mds_create_get_options $@
  # check options
  lcdt_mds_create_check_options
}

$LCDT_LOG_SH 3 $@
lcdt_mds_create_main $@