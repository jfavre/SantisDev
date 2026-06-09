#!/bin/bash

# ENABLING ANARY raytracing in ParaView master (31/10/2025)

CUDA_ARCH="${CUDA_ARCH:=86}"
root_dir=$(pwd)
root_dir="${prefix:=${root_dir}}"
build_jobs="${build_jobs:=12}"
# root_dir is where we will build and install
# override with `prefix` env var
if [ ! -d ${root_dir} ]; then
  mkdir -p ${root_dir}
fi

echo "*** prefix:       ${root_dir}"
echo "*** build_jobs: ${build_jobs}"
cd ${root_dir}
# Compile ANARI

git clone https://github.com/KhronosGroup/ANARI-SDK
cd ANARI-SDK
git checkout v0.15.0

cmake -S . -B build \
  -DCMAKE_INSTALL_PREFIX=`pwd`/install
cmake --build build -j${build_jobs} -t install

# Compile VISRTX
cd ${root_dir}
git clone https://github.com/NVIDIA/VisRTX
cd VisRTX
git checkout v0.13.0
cmake -S . -B build \
  -Danari_DIR=${root_dir}/ANARI-SDK/install/lib/cmake/anari-0.15.0 \
  -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCH} \
  -DVISRTX_BUILD_RTX_DEVICE=ON \
  -DVISRTX_ENABLE_MDL_SUPPORT=OFF \
  -DCMAKE_INSTALL_PREFIX=`pwd`/install
cmake --build build -j${build_jobs} -t install

# Get NVIDIA Material Definition Language SDK (optional)
cd ${root_dir}
wget https://github.com/NVIDIA/MDL-SDK/releases/download/2025.0.5/MDL-SDK-2025.0.5-387700.3418-linux-x86-64.tgz
tar zxf MDL-SDK-2025.0.5-387700.3418-linux-x86-64.tgz

cd ${root_dir}/VisRTX/build
cmake . -DVISRTX_ENABLE_MDL_SUPPORT=ON -DMDL_SDK_ROOT=${root_dir}/MDL-SDK-2025.0.5-387700.3418-linux-x86-64
make -j${build_jobs} install

# We're done. Configure now ParaView (version > 6.1) with the libraries just compiled.
# cd to your ParaView build tree
cd /local/apps/ParaView/ParaViewBuild
cmake . -DPARAVIEW_ENABLE_ANARI=ON \
        -Danari_DIR=${root_dir}/ANARI-SDK/install/lib/cmake/anari-0.15.0
ninja -j${build_jobs}

# We're done. Test ParaView specifying the run-time option
LD_LIBRARY_PATH=${root_dir}/ANARI-SDK/install/lib:${root_dir}/VisRTX/install/lib:$LD_LIBRARY_PATH:${root_dir}/MDL-SDK-2025.0.5-387700.3418-linux-x86-64/lib
echo "LD_LIBRARY_PATH=${root_dir}/ANARI-SDK/install/lib:${root_dir}/VisRTX/install/lib:${root_dir}/MDL-SDK-2025.0.5-387700.3418-linux-x86-64/lib:$LD_LIBRARY_PATH"
export ANARI_LIBRARY=visrtx


