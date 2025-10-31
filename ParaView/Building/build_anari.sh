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

# install_dir is where we will install
# override with `install_dir` env var
install_dir="${install_dir:=$root_dir/install}"

echo "*** prefix:       ${root_dir}"
echo "*** install root: ${install_dir}"
echo "*** build_jobs: ${build_jobs}"
cd ${root_dir}
# Compile ANARI

git clone https://github.com/KhronosGroup/ANARI-SDK
cd ANARI-SDK
git checkout v0.14.1

cmake -S . -B build \
  -DCMAKE_INSTALL_PREFIX=${install_dir}/anari
cmake --build build -j${build_jobs} -t install

# Compile VISRTX
cd ${root_dir}
git clone https://github.com/NVIDIA/VisRTX
cd VisRTX
git checkout v0.11.0
cmake -S . -B build \
  -Danari_DIR=${install_dir}/anari/lib/cmake/anari-0.14.1 \
  -DCMAKE_CUDA_HOST_COMPILER=/usr/bin/g++-12 \
  -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCH} \
  -DVISRTX_BUILD_RTX_DEVICE=ON \
  -DVISRTX_ENABLE_MDL_SUPPORT=OFF \
  -DCMAKE_INSTALL_PREFIX=${install_dir}/visrtx
cmake --build build -j${build_jobs} -t install

# Get NVIDIA Material Definition Language SDK (optional)
cd ${root_dir}
wget https://github.com/NVIDIA/MDL-SDK/releases/download/2024.1.4/MDL-SDK-2024.1.4-381500.6583-linux-x86-64.tgz
tar zxf MDL-SDK-2024.1.4-381500.6583-linux-x86-64.tgz
popd

cd ${root_dir}/VisRTX/build
cmake . -DVISRTX_ENABLE_MDL_SUPPORT=ON -DMDL_SDK_ROOT=${root_dir}/MDL-SDK-2024.1.4-381500.6583-linux-x86-64
make -j${build_jobs} install

# We're done. Configure now ParaView with the libraries just compiled.
# cd to your ParaView build tree
cd /local/apps/ParaView/ParaViewBuild
cmake . -DPARAVIEW_ENABLE_RAYTRACING=ON \
  -DPARAVIEW_ENABLE_ANARI=ON \
  -Danari_DIR=${install_dir}/anari/lib/cmake/anari-0.14.1
ninja -j${build_jobs}

# We're done. Test ParaView specifying the run-time option
LD_LIBRARY_PATH=${install_dir}/anari/lib:${install_dir}/visrtx/lib:$LD_LIBRARY_PATH:${root_dir}/MDL-SDK-2024.1.4-381500.6583-linux-x86-64/lib
echo "LD_LIBRARY_PATH=${install_dir}/anari/lib:${install_dir}/visrtx/lib:${root_dir}/MDL-SDK-2024.1.4-381500.6583-linux-x86-64/lib:$LD_LIBRARY_PATH"
export ANARI_LIBRARY=visrtx


