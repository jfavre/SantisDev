uenv start /bret/scratch/cscs/bcumming/images/icon-dsl-4.squashfs
uenv view default

export SPACK_ROOT=$SCRATCH/spack-santis
if [ -f $SPACK_ROOT/share/spack/setup-env.sh ]; then
  . $SPACK_ROOT/share/spack/setup-env.sh
fi
export SPACK_SYSTEM_CONFIG_PATH="/user-environment/config"

cd $SCRATCH/GH

# spack install failed, but I use the partial results (TBB and ISPC) down further until finally resolve
# spack install ospray@2.12.0 ~mpi+denoiser+volumes~apps~glm
#
# get git-lfs and ispc
#

export PATH=$PATH:`spack location -i ispc`/bin:$PATH

wget https://github.com/git-lfs/git-lfs/releases/download/v3.5.1/git-lfs-linux-arm64-v3.5.1.tar.gz
gunzip git-lfs-linux-arm64-v3.5.1.tar.gz
tar -xf git-lfs-linux-arm64-v3.5.1.tar
./git-lfs-3.5.1/install.sh --local
export PATH=$PATH:$HOME/.local/bin


################
# Ospray and TBB, without OIDN
################

export CC=`which gcc`
export CXX=`which g++`
export TBB_ROOT=`spack location -i intel-tbb/z5`

ospray_version=2.12.0
ospray_install_dir=$SCRATCH/GH/ospray-v${ospray_version}

git clone https://github.com/ospray/ospray.git
cd ospray
git checkout v${ospray_version}
mkdir build;cd build

cmake -S ../scripts/superbuild \
	-DBUILD_EMBREE_FROM_SOURCE:BOOL=ON \
	-DBUILD_GLFW:BOOL=OFF \
	-DBUILD_OIDN:BOOL=OFF \
	-DBUILD_OSPRAY_APPS:BOOL=OFF \
	-DCMAKE_INSTALL_PREFIX=$SCRATCH/GH/ospray-v${ospray_version} \
	-DDOWNLOAD_ISPC:BOOL=OFF \
	-DDOWNLOAD_TBB:BOOL=OFF \
	-DINSTALL_IN_SEPARATE_DIRECTORIES:BOOL=OFF

cmake --build .
cd ../..

################
# OIDN
################
oidn_version=2.2.2
oidn_install_dir=$SCRATCH/GH/ospray-v${ospray_version}

git clone --recursive https://github.com/OpenImageDenoise/oidn.git
cd oidn
git checkout v${oidn_version}
mkdir build;cd build

cmake -S .. \
	-DCMAKE_INSTALL_PREFIX=$SCRATCH/GH/ospray-v${ospray_version} \
	-DOIDN_APPS:BOOL=OFF \
	-DOIDN_DEVICE_CUDA:BOOL=ON

cmake --build . --target install
