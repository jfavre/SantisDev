uenv start /bret/scratch/cscs/bcumming/images/icon-dsl-4.squashfs
uenv view default

cd $SCRATCH/GH

# get git-lfs and ispc
#
#

wget https://github.com/ispc/ispc/releases/download/v1.22.0/ispc-v1.22.0-linux.aarch64.tar.gz
gunzip ispc-v1.22.0-linux.aarch64.tar.gz
tar xf ispc-v1.22.0-linux.aarch64.tar
export PATH=$PATH:$SCRATCH/GH/ispc-v1.22.0-linux.aarch64/bin

wget https://github.com/git-lfs/git-lfs/releases/download/v3.5.1/git-lfs-linux-arm64-v3.5.1.tar.gz
gunzip git-lfs-linux-arm64-v3.5.1.tar.gz
tar -xf git-lfs-linux-arm64-v3.5.1.tar
./git-lfs-3.5.1/install.sh --local
export PATH=$PATH:$HOME/.local/bin


################
# Ospray and TBB, without OIDN
################

export FC=`which gfortran`
export CC=`which gcc`
export CXX=`which g++`

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
	-DBUILD_TBB_FROM_SOURCE:BOOL=ON \
	-DCMAKE_INSTALL_PREFIX=$SCRATCH/GH/ospray-v${ospray_version} \
	-DDOWNLOAD_ISPC:BOOL=OFF \
	-DDOWNLOAD_TBB:BOOL=ON \
	-DINSTALL_IN_SEPARATE_DIRECTORIE:BOOL=OFF

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
	-DOIDN_DEVICE_CUDA:BOOOL=ON

cmake --build . --target install
