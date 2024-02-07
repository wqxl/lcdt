#!/bin/bash
LCDT_INSTALL_DIR=$(cd "$(dirname "$0")" && pwd)
LCDT_INSTALL_SH=$LCDT_INSTALL_DIR/lcdt_install.sh
LCDT_LOG_SH=$LCDT_INSTALL_DIR/../lcdt_log/lcdt_log.sh

ALL_ENABLED=0
DEPEND_ENABLED=0
INSTALL_TYPE=""
BACKENDFS_TYPE=""
ROLE_TYPE=""
HOSTS_LIST=()
FUNCTION_NAME=""

function lcdt_install_usage() {
  echo "usage: lcdt install <-a|-d> -b <zfs/ldiskfs> -r <server/client> host [host...]"
  echo "options:"
  echo "  -h, --help                      display this help and exit"
  echo "  -d, --depend                    install only depandencies packages"
  echo "  -a, --all                       install both depandencies and lustre packages"
  echo "  -b, --backend <zfs/ldiskfs>     lustre backend fs type"
  echo "  -r, --role <server/client>      lustre packages type"
}

function lcdt_install_get_options() {
  FUNCTION_NAME="lcdt_install_get_options"
  if [ $# -eq 0 ]; then
    lcdt_install_usage
    exit 1
  fi

  options="hadb:r:"
  loptions="help,all,depend,backend:,role:"
  parameters=$(getopt -o $options -l $loptions -n "$LCDT_INSTALL_SH" -- "$@")

  # check parse result
  if [ $? -ne 0 ]; then
    exit 1
  fi

  eval set -- "$parameters"

  while true; do
    case "$1" in
      -h|--help)
        lcdt_install_usage
        exit 0
        ;;
      -a|--all)
        ALL_ENABLED=1
        shift
        ;;
      -d|--depend)
        DEPEND_ENABLED=1
        shift
        ;;
      -b|--backend)
        BACKENDFS_TYPE=$2
        shift 2
        ;;
      -r|--role)
        ROLE_TYPE=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      *)
        echo "ERROR: $LCDT_INSTALL_SH:$FUNCTION_NAME:unknown command: $1"
        exit 1
        ;;
    esac
  done
  # get hosts
  HOSTS_LIST=($@)
  $LCDT_LOG_SH 3 "$LCDT_INSTALL_SH:$FUNCTION_NAME:$INSTALL_TYPE $BACKENDFS_TYPE $ROLE_TYPE ${HOSTS_LIST[@]}"
}

function lcdt_install_check_options {
  FUNCTION_NAME="lcdt_install_check_options"
  # check hosts
  if [ ${#HOSTS_LIST[@]} -eq 0  ]; then
    echo "ERROR: $LCDT_INSTALL_SH:$FUNCTION_NAME:must specify hosts"
    exit 1
  fi

  # ALL_ENABLED=1
  if [ $ALL_ENABLED -eq 1 ] ; then
    INSTALL_TYPE="all"
    # check backendfs
    if [ "$BACKENDFS_TYPE" != "zfs" ] && [ "$BACKENDFS_TYPE" != "ldiskfs" ]; then
      echo "ERROR: $LCDT_INSTALL_SH:$FUNCTION_NAME:must specify backendfs type"
      exit 1
    fi
    # check role
    if [ "$ROLE_TYPE" != "server" ] && [ "$ROLE_TYPE" != "client" ]; then
      echo "ERROR: $LCDT_INSTALL_SH:$FUNCTION_NAME:must specify role type"
      exit 1
    fi
  fi

  # ALL_ENABLED=0
  if [ $ALL_ENABLED -eq 0 ] ; then
    INSTALL_TYPE="depend"
    # check depend
    if [ $DEPEND_ENABLED -eq 0 ]; then
      echo "ERROR: $LCDT_INSTALL_SH:$FUNCTION_NAME:must install dependency or both depandencies and lustre"
      exit 1
    fi
    # check backendfs
    if [ "$BACKENDFS_TYPE" != "zfs" ] && [ "$BACKENDFS_TYPE" != "ldiskfs" ]; then
      echo "ERROR: $LCDT_INSTALL_SH:$FUNCTION_NAME:must specify backendfs type"
      exit 1
    fi
    # check role
    if [ "$ROLE_TYPE" != "server" ] && [ "$ROLE_TYPE" != "client" ]; then
      echo "ERROR: $LCDT_INSTALL_SH:$FUNCTION_NAME:must specify role type"
      exit 1
    fi
  fi

  $LCDT_LOG_SH 3 "$LCDT_INSTALL_SH:$FUNCTION_NAME:$INSTALL_TYPE $BACKENDFS_TYPE $ROLE_TYPE ${HOSTS_LIST[@]}"
}

function lcdt_install_packages() {
  FUNCTION_NAME="lcdt_install_packages"
  for node in ${HOSTS_LIST[@]}; do
    case "$INSTALL_TYPE" in
      depend)
        $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:installing dependencies packages"
        if [ "$BACKENDFS_TYPE" = "zfs" ]; then
          $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:ssh $node yum install zfs packages"
        else
          $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:ssh $node yum install ldiskfs packages"
        fi
        ;;
      all)
        $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:installing dependency packages"
        if [ "$BACKENDFS_TYPE" = "zfs" ]; then
          $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:ssh $node yum install zfs packages"
        else
          $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:ssh $node yum install ldiskfs packages"
        fi
        $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:installing lustre packages"
        if [ "$ROLE_TYPE" = "server" ]; then
          $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:ssh $node yum install server packages"
        else
          $LCDT_LOG_SH 2 "$LCDT_INSTALL_SH:$FUNCTION_NAME:ssh $node yum install client packages"
        fi
        ;;
    esac
  done
}

function lcdt_install_main() {
  FUNCTION_NAME="lcdt_install_main"
  # get options
  lcdt_install_get_options $@
  # check options
  lcdt_install_check_options
  # install packages
  lcdt_install_packages
}

$LCDT_LOG_SH 3 $@
lcdt_install_main $@