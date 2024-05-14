#!/bin/bash -l
#SBATCH --job-name=Ospray_Raytracing
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --time=03:59:59
#SBATCH --account=csstaff
#SBATCH --partition=normal
#SBATCH --cpus-per-task=64
#SBATCH --hint=multithread
#

time srun --uenv=/bret/scratch/cscs/bcumming/images/icon-dsl-4.squashfs:/user-environment -u -N 1 -n 1 -c64 /users/jfavre/Projects/ParaView/select_local_device3.sh pvbatch pvRayTracingTests.01.py

#time srun --uenv=/bret/scratch/cscs/ialberto/paraview-cdi_and_raycasting.squashfs:/user-environment -u -N 1 -n 1 -c64 /users/jfavre/Projects/ParaView/select_local_device3_alberto.sh /user-environment/env/default/bin/pvbatch pvRayTracingTests.01.py

