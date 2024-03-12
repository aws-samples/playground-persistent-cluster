#!/bin/bash

# No set -u  to prevent crash when array aws_cli_args is empty
set -eo pipefail

declare -a HELP=(
    "[-h|--help]"
    "[-r|--region]"
    "[-p|--profile]"
    "CLUSTER_NAME"
)

declare -a aws_cli_args=()
cluster_name=""
: "${SMHP_REGION:=}"

parse_args() {
    local key
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -h|--help)
            echo "Create a HyperPod Slurm cluster."
            echo "Usage: $(basename ${BASH_SOURCE[0]}) ${HELP[@]}"
            exit 0
            ;;
        -r|--region)
            SMHP_REGION="$2"
            shift 2
            ;;
        -p|--profile)
            aws_cli_args+=(--profile "$2")
            shift 2
            ;;
        *)
            [[ "$cluster_name" == "" ]] \
                && cluster_name="$key" \
                || { echo "Must define one cluster name only" ; exit -1 ; }
            shift
            ;;
        esac
    done

    [[ "$cluster_name" != "" ]] || { echo "Must define a cluster name" ; exit -1 ; }
    [[ "${SMHP_REGION}" == "" ]] || aws_cli_args+=(--region $SMHP_REGION)
}

parse_args $@

# We've been hit several time with stale LCC scripts on S3, so let's enforce the sync every time
# we create a cluster.
BIN_DIR=$(dirname $(realpath ${BASH_SOURCE[@]}))
$BIN_DIR/prep-s3.sh

set -x
aws sagemaker create-cluster "${aws_cli_args[@]}" \
    --cli-input-json file://cluster-config.json \
    --cluster-name "${cluster_name}" \
    | jq .
