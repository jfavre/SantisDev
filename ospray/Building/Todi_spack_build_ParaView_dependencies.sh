uenv start prgenv-gnu/24.7:v3
uenv view default

mkdir $SCRATCH/GH/ParaView-CDI
cd $SCRATCH/GH/ParaView-CDI
export SPACK_SYSTEM_CONFIG_PATH="/user-environment/config"
spack install ospray@2.12.0 ~mpi+denoiser+volumes~apps~glm
spack install ospray@3.1.0 ~mpi+denoiser+volumes~apps~glm
spack install eccodes@2.32.1 +aec +openmp +netcdf
spack install ffmpeg@5.1.4 +libx264 +lzma +shared  +libvpx +libvorbis +libssh

export FC=`which gfortran`
export CC=`which gcc`
export CXX=`which g++`

cdi_version=2.2.4
cdi_install_dir=$SCRATCH/GH/ParaView-CDI/cdi-v${cdi_version}Install
wget https://code.mpimet.mpg.de/attachments/download/28877/cdi-2.2.4.tar.gz
gunzip cdi-2.2.4.tar.gz
tar xf cdi-2.2.4.tar
cd cdi-2.2.4
pushd `spack location -i eccodes`
ln -s lib64 lib
popd
./configure --enable-iso-c-interface --with-netcdf=`spack location -i netcdf-c` --with-eccodes=`spack location -i eccodes` --prefix=${cdi_install_dir} --enable-grib=no
make && make install


