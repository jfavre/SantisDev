#!/bin/bash
# select_cpu_device wrapper script
GPUS=(0 1 2 3)
let lrank=$SLURM_LOCALID%4
export VTK_DEFAULT_EGL_DEVICE_INDEX=${GPUS[lrank]}

# add numpy
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/users/jfavre/.pyenv310/lib/python3.10/site-packages/numpy/lib

# add ParaView and NVIDIA IndeX
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SCRATCH/GH/ParaView/5.12-CDI/lib64:$SCRATCH/ParaView/nvidia-index-libs-5.12.0.20231121-linux-aarch64/lib
export PATH=$SCRATCH/GH/ParaView/5.12-CDI/bin:$PATH

# add libraries used by the CDI reader
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/user-environment/linux-sles15-neoverse_v2/gcc-12.3.0/libaec-1.0.6-yj4iir764nqlcrbjfucgo4vridnuj7a5/lib64:/user-environment/linux-sles15-neoverse_v2/gcc-12.3.0/c-blosc-1.21.5-x5nxps4uvtcnemcbb4v7ypwfwlnafevd/lib64

# add TBB libraries for raytracing
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:`spack location -i intel-tbb/z5`/lib64
# add ospray/oidn libraries for raytracing
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/bret/scratch/cscs/jfavre/GH/ospray-v2.12.0/lib64

export PYTHONPATH=$PYTHONPATH:/users/jfavre/.pyenv310/lib/python3.10/site-packages
export NVINDEX_PVPLUGIN_HOME=$SCRATCH/ParaView

export LOCAL_RANK=$SLURM_LOCALID
export GLOBAL_RANK=$SLURM_PROCID

# affinity for devices indexed by numa node
export NUMA_NODE=$LOCAL_RANK
export CUDA_VISIBLE_DEVICES=$LOCAL_RANK
export MPICH_GPU_SUPPORT_ENABLED=1

numactl --cpunodebind=$NUMA_NODE --membind=$NUMA_NODE "$@"


