# Initial version

1. Allocate a few nodes (it also works with 1), but with more nodes you are more likely to hit the issue

   salloc -N 14 --ntasks-per-node 32 --cpus-per-task 9

2. Compile and execute:

   bash run.sh

3. Check the output in out.log

   ==> The runtimes should vary a lot. An example is included in the output.

4. You can change the file wrapper.sh and bind to specific cores (there is a note in the file)
   and then run with

   ```
   salloc -N 1 --ntasks-per-node 32 --cpus-per-task 9
   SLURM_NTASKS=1 bash run.sh
   ```

   If you bind to the "right" cores, it happens on single node, too.


# Update 1

I think for a first step we should focus on one node:

1. Get only one node:

   salloc -N 1 --ntasks-per-node 32 --cpus-per-task 9

2. In wrapper.sh, set explicity pinning:

   ```
   mycpus=91-92
   exec="numactl -m $numanode -N $numanode --physcpubind=$mycpus"
   ```

3. Run with two cores only:

   ```
   SLURM_CPUS_PER_TASK=2 SLURM_NTASKS=1 bash run.sh
   ```

4. In a good case, you will see something like:

   ```
   Took   4.8179 ms/it
   Took   4.8224 ms/it
   Took   4.8513 ms/it
   Took   4.8549 ms/it
   Took   4.8483 ms/it
   Took   4.8524 ms/it
   Took   4.8456 ms/it
   Took   4.8336 ms/it
   Took   4.8203 ms/it
   Took   4.8193 ms/it
   Took   4.8594 ms/it
   Took   4.8370 ms/it
   Took   4.8050 ms/it
   Took   4.8060 ms/it
   Took   4.8231 ms/it
   Took   4.7473 ms/it
   Took   4.8511 ms/it
   Took   4.8666 ms/it
   Took   4.7746 ms/it
   Took   4.8802 ms/it
   Took   4.8781 ms/it
   Took   4.8512 ms/it
   Took   4.8997 ms/it
   Took   4.8810 ms/it
   Took   4.8907 ms/it
   Took   4.8803 ms/it
   Took   4.8750 ms/it
   Took   4.8824 ms/it
   Took   4.8691 ms/it
   Took   4.8963 ms/it
   Took   4.8816 ms/it
   ```

   In a bad case it looks like

   ```
   Took   5.3904 ms/it
   Took   4.8839 ms/it
   Took   4.8632 ms/it
   Took   5.4341 ms/it
   Took   5.4105 ms/it
   Took   5.0067 ms/it
   Took   4.9437 ms/it
   Took   5.1092 ms/it
   Took   5.5243 ms/it
   Took   4.8811 ms/it
   Took   4.8869 ms/it
   Took   5.4357 ms/it
   Took   5.4438 ms/it
   Took   4.8978 ms/it
   Took   4.9020 ms/it
   Took   5.1576 ms/it
   Took   5.2897 ms/it
   Took   4.8802 ms/it
   Took   4.8708 ms/it
   Took   5.0797 ms/it
   Took   4.9033 ms/it
   Took   4.8619 ms/it
   Took   4.8972 ms/it
   Took   5.4781 ms/it
   Took   4.8993 ms/it
   Took   4.8734 ms/it
   Took   4.9015 ms/it
   Took   5.0298 ms/it
   ```

   The numbers keep changing a bit in the beginning, after a while they should become quite constant like in the first
   case.


5. You can also comment out the `mpi_barrier`, it won't change anything for the single node setup of course.

6. If you want to figure out how to do the bad pinning, hop on the node, to htop, press shift+k, and look out for
   kworker/xx:yy-events-freezable-power

   `xx` is the core you want to bind to to get bad performance. There can be several of those, depending on the node.


