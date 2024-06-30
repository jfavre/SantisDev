uenv start prgenv-gnu/24.2:latest
uenv view default

mkdir $SCRATCH/GH/ParaView-CDI
cd $SCRATCH/GH/ParaView-CDI
export SPACK_SYSTEM_CONFIG_PATH="/user-environment/config"
spack install ospray@2.12.0 ~mpi+denoiser+volumes~apps~glm
spack install eccodes@2.32.1 +aec +openmp +netcdf
