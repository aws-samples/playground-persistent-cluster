#!/bin/bash

# No set -u  to prevent crash when array aws_cli_args is empty
set -eo pipefail

declare -a HELP=(
    "[-h|--help]"
    "[-r|--region]"
    "[-p|--profile]"
    "[-g|--instance-group]"
    "CLUSTER_NAME"
    "[-- AWSLOGS_CLI_ARGS]"
)

: "${SMHP_REGION:=}"
declare -a args=()
cluster_name=""
node_group="controller-machine"
AWSLOGS_ARGS=0

parse_args() {
    local key
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -h|--help)
            echo "Create a tmux session to watch the status and logs of cluster creation. By default, watch the controller node."
            echo "Usage: $(basename ${BASH_SOURCE[0]}) ${HELP[@]}"
            exit 0
            ;;
        -g|--instance-group)
            node_group="$2"
            shift 2
            ;;
        -r|--region)
            args+=( "$key" "$2" )
            shift 2
            ;;
        -p|--profile)
            args+=( "$key" "$2" )
            shift 2
            ;;
        --)
            AWSLOGS_ARGS=1
            shift
            ;;
        *)
            if [[ $AWSLOGS_ARGS == 0 ]]; then
                [[ "$cluster_name" == "" ]] \
                    && cluster_name="$key" \
                    || { echo "Must define one cluster name only" ; exit -1 ;  }
            else
                awslogs_cli_args+=($key)
            fi
            shift
            ;;
        esac
    done

    [[ "$cluster_name" != "" ]] || { echo "Must define a cluster name" ; exit -1 ; }
}

BIN_DIR=$(dirname $(realpath ${BASH_SOURCE[@]}))
parse_args $@
set -x
tmux \
    new-session "${BIN_DIR}/cluster-status.sh ${args[@]} ${cluster_name} --watch" ';' \
    split-window -h "sleep 1 ; ${BIN_DIR}/cluster-log.sh ${args[@]} ${cluster_name} -g ${node_group} --watch -f -- ${awslogs_cli_args[@]}" ';' \
    set -w remain-on-exit on ';' \
    bind-key e kill-session ';' \
    rename-window "Press C-e to exit... (By default: C is Ctrl-B)"
