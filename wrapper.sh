#!/bin/bash

this_file=$(readlink -f $0)
this_path=$(dirname $this_file)

ulimit -s unlimited

total_numa_nodes=4
tasks_per_numa_node=$((($SLURM_NTASKS_PER_NODE+$total_numa_nodes-1)/$total_numa_nodes))
numanode=$(($SLURM_LOCALID/$tasks_per_numa_node))

mycpus=$((SLURM_LOCALID*9))-$((SLURM_LOCALID*9+8))

# Note that it can be helpful to bind the processes to specific cores
# There are some indications that binding them to cores with much activity
# of freezable_power_... makes the error happen more often
#mycpus=120-129
#exec="numactl -m $numanode -N $numanode --physcpubind=$mycpus"

# whether the binding is done or not, doesn't really matter
exec="numactl -m $numanode -N $numanode "
echo $exec

#if [[ $SLURM_PROCID -eq 0 ]]; then
#  export NSYS_MPI_STORE_TEAMS_PER_RANK=1
#  $exec nsys profile -s none --cpuctxsw=system-wide -t nvtx -o out-$SLURM_PROCID -f true $@
#else
  $exec $@
#fi
