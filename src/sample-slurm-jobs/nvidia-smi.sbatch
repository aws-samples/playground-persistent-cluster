#!/bin/bash

#SBATCH --ntasks-per-node=1
#SBATCH --exclusive

srun -l bash -c 'hostname >> nvidia-smi-${SLURM_JOBID}-$(hostname).txt ; nvidia-smi >> nvidia-smi-${SLURM_JOBID}-$(hostname).txt'
