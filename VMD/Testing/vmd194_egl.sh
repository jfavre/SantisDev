#!/bin/bash -l
#SBATCH --job-name="VMDmovie"
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --account=csstaff

export DISPLAY=:0

export PATH=$HOME/Projects/VMD/bin:$PATH
export VMDDIR=$HOME/Projects/VMD/lib

#srun -n 1 -N 1 vmd -size 1920 1080 -dispdev openglpbuffer -eofexit < rendering_OGL.tcl
export VMDSCRSIZE=1920

srun --uenv=/bret/scratch/cscs/bcumming/images/prgenv-gnu-24.2-v2.squashfs:/user-environment -u -N 1 -n 1 vmd -size 1920 1080 -dispdev openglpbuffer -eofexit < rendering_OGL.tcl
#
#srun -n 1 -N 1 vmd -size 1920 1080 -dispdev none -eofexit < renderings_Tachyon1.tcl

