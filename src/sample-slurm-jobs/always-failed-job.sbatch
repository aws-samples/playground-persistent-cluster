#!/bin/bash

set -euo pipefail

env | grep SLURM
echo "Sbatch script runs on node $(hostname)$"
srun --auto-resume=1 bash -c 'nvidia-smi ; exit -1'
