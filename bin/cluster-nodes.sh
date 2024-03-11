#!/bin/bash

# No set -u  to prevent crash when array aws_cli_args is empty
set -eo pipefail

declare -a HELP=(
    "[-h|--help]"
    "[-r|--region]"
    "[-p|--profile]"
    "[-w|--watch]"
    "[-e|--except-running]"
    "CLUSTER_NAME"
)

: "${SMHP_REGION:=}"
declare -a aws_cli_args=()
cluster_name=""
EXCEPT_RUNNING=0
WATCH=0
jq_filter="."

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
        -e|--except-running)
            jq_filter='{ClusterNodeSummaries: [.ClusterNodeSummaries[] | select( .InstanceStatus.Status != "Running")]}'
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

    [[ "$cluster_name" != "" ]] ||  { echo "Must define a cluster name" ; exit -1 ; }
    [[ "${SMHP_REGION}" == "" ]] || aws_cli_args+=(--region $SMHP_REGION)
}

parse_args $@

if [[ $WATCH == 1 ]]; then
    watch --color -n60 "
echo Press ^C to exit...
set -x
aws sagemaker list-cluster-nodes ${aws_cli_args[@]} --cluster-name $cluster_name | jq -C $(printf '%q' "$jq_filter")
"
else
    set -x
    aws sagemaker list-cluster-nodes "${aws_cli_args[@]}" --cluster-name $cluster_name | jq "${jq_filter}"
fi
