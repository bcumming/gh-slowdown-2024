#!/bin/bash

set -ex

srun -n 1 \
    --uenv=/bret/scratch/cscs/bcumming/images/icon-dsl-4.squashfs \
    bash --login -c "uenv view default; mpif90 -lnvhpcwrapnvtx -fopenmp -o out -Minfo=all test.F90"

sleep 1

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
srun -n $SLURM_NTASKS \
    --cpu-bind=none \
    -o "out.log" \
    --uenv=/bret/scratch/cscs/bcumming/images/icon-dsl-4.squashfs \
    bash --login -c "uenv view default>/dev/null; bash wrapper.sh ./out"
