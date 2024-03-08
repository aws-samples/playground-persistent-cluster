#!/bin/bash

# No set -u  to prevent crash when array aws_cli_args is empty
set -eo pipefail

declare -a HELP=(
    "[-h|--help]"
    "[-r|--region]"
    "[-p|--profile]"
    "[-w|--watch]"
    "[-n|--watch-interval SECONDS]"
    "[-e|--export-cluster-config]"
    "CLUSTER_NAME"
)

: "${SMHP_REGION:=}"
declare -a aws_cli_args=()
cluster_name=""
WATCH=0
WATCH_INTERVAL=60
EXPORT_CLUSTER_CONFIG=0

parse_args() {
    local key
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -h|--help)
            echo "Watch a HyperPod Slurm cluster."
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
        -w|--watch)
            WATCH=1
            shift
            ;;
        -n|--watch-interval)
            WATCH_INTERVAL="$2"
            shift
            ;;
        -e|--export-cluster-config)
            EXPORT_CLUSTER_CONFIG=1
            shift
            ;;
        *)
            [[ "$cluster_name" == "" ]] \
                && cluster_name="$key" \
                || { echo "Must define one cluster name only" ; exit -1 ; }
            shift
            ;;
        esac
    done

    if [[ "$cluster_name" == "" ]]; then
        echo "Must define a cluster name"
        exit -1
    fi

    [[ "${SMHP_REGION}" == "" ]] || aws_cli_args+=(--region $SMHP_REGION)

    if [[ $EXPORT_CLUSTER_CONFIG == 1 ]]; then
        local jmes="{
    InstanceGroups: InstanceGroups[].{
        InstanceGroupName: @.InstanceGroupName,
        InstanceType: @.InstanceType,
        InstanceCount: @.TargetCount,
        LifeCycleConfig: @.LifeCycleConfig,
        ExecutionRole: @.ExecutionRole,
        ThreadsPerCore: @.ThreadsPerCore
    }
}"
        [[ $WATCH == 0 ]] && aws_cli_args+=(--query "$jmes") || aws_cli_args+=(--query \"$jmes\")
    fi
}

parse_args $@

if [[ $WATCH == 1 ]]; then
    # flatten_aws_cli_args="${aws_cli_args[@]}"
    watch --color -n ${WATCH_INTERVAL} "
echo Press ^C to exit...
set -x
aws sagemaker describe-cluster ${aws_cli_args[@]} --cluster-name $cluster_name | jq -C .
"
else
    set -x
    aws sagemaker describe-cluster "${aws_cli_args[@]}" --cluster-name $cluster_name | jq .
fi
