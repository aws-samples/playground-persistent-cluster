#!/bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

#SBATCH --job-name=nccl-tests
#SBATCH -N 2
#SBATCH --ntasks-per-node 8
#SBATCH --exclusive
#SBATCH --wait-all-nodes=1

set -exuo pipefail

CUDA_VERSION=12.1
NCCL_TEST_PATH=/usr/local/cuda-${CUDA_VERSION}/efa/test-cuda-${CUDA_VERSION}
MPI_PATH=/opt/amazon/openmpi

export LD_LIBRARY_PATH=/opt/aws-ofi-nccl/lib:/opt/amazon/efa/lib:/opt/amazon/openmpi/lib:/usr/local/cuda-${CUDA_VERSION}/efa/lib:/usr/local/cuda-${CUDA_VERSION}/lib:/usr/local/cuda-${CUDA_VERSION}/lib64:/usr/local/cuda-${CUDA_VERSION}:/usr/local/cuda-${CUDA_VERSION}/extras/CUPTI/lib64:/usr/local/cuda-${CUDA_VERSION}/targets/x86_64-linux/lib

# See: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start-nccl.html
declare -a MPIARGS=(
    -x LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
    -x FI_EFA_USE_DEVICE_RDMA=1
    -x NCCL_DEBUG=INFO
    --mca pml ^cm
    --mca btl tcp,self
    --mca btl_tcp_if_exclude lo,docker0
    --bind-to none
)

echo "
################################################################################
# $NCCL_TEST_PATH/all_reduce_perf
################################################################################
"
$MPI_PATH/bin/mpirun --map-by ppr:8:node --rank-by slot \
                     "${MPIARGS[@]}" \
                     $NCCL_TEST_PATH/all_reduce_perf -b 8 -e 1G -f 2 -g 1 -c 1 -n 100 \
    > slurm-${SLURM_JOB_ID}_all-reduce-perf.txt

sleep 5
echo "
################################################################################
# $NCCL_TEST_PATH/all_gather_perf
################################################################################
"
$MPI_PATH/bin/mpirun --map-by ppr:8:node --rank-by slot \
                     "${MPIARGS[@]}" \
                     $NCCL_TEST_PATH/all_gather_perf -b 8 -e 1G -f 2 -g 1 -c 1 -n 100 \
    > slurm-${SLURM_JOB_ID}_all-gather-perf.txt

sleep 5
echo "
################################################################################
# $NCCL_TEST_PATH/reduce_scatter_perf
################################################################################
"
$MPI_PATH/bin/mpirun --map-by ppr:8:node --rank-by slot \
                     "${MPIARGS[@]}" \
                     $NCCL_TEST_PATH/reduce_scatter_perf -b 8 -e 1G -f 2 -g 1 -c 1 -n 100 \
> slurm-${SLURM_JOB_ID}_reduce-scatter-perf.txt
