#!/bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

#SBATCH --job-name=nccl-tests
#SBATCH -N 2
#SBATCH --ntasks-per-node 8
#SBATCH --exclusive
#SBATCH --wait-all-nodes=1

set -exuo pipefail

# NOTES:
# 1. build an Enroot image. Refer to examples in the adt repo.
# 2. with your own .sqsh file ready, please change below to point to the .sqsh file.
: "${IMAGE:=/fsx/ubuntu/nvcr-pytorch-aws__24.01.sqsh}"

# Path to nccl-tests binary (inside container), in case you build to a different
# location than the adt example.
: "${NCCL_TESTS_PATH:=/opt/nccl-tests/build}"

export NCCL_DEBUG=INFO

# https://github.com/open-mpi/ompi/issues/11557#issuecomment-1496245026
export PMIX_MCA_psec=^munge

declare -a ARGS=(
    --container-image $IMAGE
)
srun -l "${ARGS[@]}" --mpi=pmix $NCCL_TESTS_PATH/scatter_perf -b 8 -e 2G -f 2 -g 1 -c 1 -n 100
