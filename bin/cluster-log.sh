#!/bin/bash

# No set -u  to prevent crash when array aws_cli_args is empty
set -eo pipefail

if ! command -v awslogs &> /dev/null; then
    echo 'Could not find awslogs. See https://github.com/jorgebastida/awslogs for installation.'
    exit -1
fi

declare -a HELP=(
    "[-h|--help]"
    "[-c|--controller-group]"
    "[-r|--region]"
    "[-p|--profile]"
    "CLUSTER_NAME"
    "[-- AWSLOGS_CLI_ARGS]"
)

: "${SMHP_REGION:=}"
declare -a aws_cli_args=()
declare -a awslogs_cli_args=()
awslogs_prefix=""
cluster_name=""
node_group="controller-machine"
cluster_id=""
instance_id=""
WATCH=0
AWSLOGS_ARGS=0

parse_args() {
    local key
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
        -h|--help)
            echo "Get the Cloudwatch log."
            echo "Usage: $(basename ${BASH_SOURCE[0]}) ${HELP[@]}"
            exit 0
            ;;
        -c|--controller-group)
            node_group="$2"
            shift 2
            ;;
        -d|--cluster-id)
            cluster_id="$2"
            shift 2
            ;;
        -i|--instance-id)
            instance_id="$2"
            shift 2
            ;;
        -r|--region)
            SMHP_REGION="$2"
            shift 2
            ;;
        -p|--profile)
            aws_cli_args+=(--profile "$2")
            awslogs_prefix="AWS_PROFILE=$2"
            shift 2
            ;;
        -w|--watch)
            WATCH=1
            shift
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

    [[ "$cluster_name" == "" ]] && { echo "Must define a cluster name" ; exit -1 ;  }
    [[ "${SMHP_REGION}" == "" ]] ||  { aws_cli_args+=(--region $SMHP_REGION) ; awslogs_cli_args+=(--aws-region=$SMHP_REGION) ;}
}

parse_args $@
[[ $cluster_id == "" ]] \
    && cluster_id=$(aws sagemaker describe-cluster "${aws_cli_args[@]}" --cluster-name $cluster_name | jq '.ClusterArn' | awk -F/ '{gsub(/"/, "", $NF); print $NF}')

[[ $instance_id == "" ]] \
    && instance_id=$(aws sagemaker list-cluster-nodes "${aws_cli_args[@]}" --cluster-name $cluster_name --instance-group-name-contains ${node_group} | jq '.ClusterNodeSummaries[0].InstanceId' | tr -d '"')

group=/aws/sagemaker/Clusters/${cluster_name}/${cluster_id}
stream=LifecycleConfig/$node_group/$instance_id

echo "Cluster id: ${cluster_id}"
echo "Instance id: ${instance_id}"
echo "Node Group: ${node_group}"
echo "Cloudwatch log group: ${group}"
echo "Cloudwatch log stream: ${stream}"

# [[ $WATCH == 1 ]] \
#     && $awslogs_prefix awslogs get -GS $group $stream --watch -i 30 -s10min "${awslogs_cli_args[@]}" \
#     || $awslogs_prefix awslogs get -GS $group $stream -s4d "${awslogs_cli_args[@]}"

[[ $WATCH == 1 ]] \
    && cmd="$awslogs_prefix awslogs get -GS $group $stream --watch -i 30 -s10min ${awslogs_cli_args[@]}" \
    || cmd="$awslogs_prefix awslogs get -GS $group $stream -s4d ${awslogs_cli_args[@]}"

echo To fetch log with this command: "$cmd"
$cmd