#!/bin/bash

#SBATCH --ntasks-per-node=1

srun -l ./get-ami-id.sh
