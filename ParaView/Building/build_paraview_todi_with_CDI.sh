uenv start prgenv-gnu/24.11:v2 --view default
export SPACK_ROOT=$PROJECT/jfavre/spack-daint
. $SPACK_ROOT/share/spack/setup-env.sh
export SPACK_SYSTEM_CONFIG_PATH="/user-environment/config"

spack env activate paraview

export FC=`which gfortran`
export CC=`which gcc`
export CXX=`which g++`

# which python3
# numpy is a must to be able to use programmable filters
# h5py is useful, to read for example SPH-EXA data
# verify they are there 
# python3 -c "import numpy as np; import h5py; import mpi4py"
# this also picks up mpi4py so I must say to use mpi4py from an external source to avoid conflicts. See below
################
# Catalyst
################

#spack install --add libcatalyst@2.0.0 +python  +mpi +fortran

paraview_version=5.13.3
paraview_install_dir=$SCRATCH/GH/ParaView/Daint-5.13
wget https://www.paraview.org/files/v5.13/ParaView-v${paraview_version}.tar.xz
tar xf ParaView-v${paraview_version}.tar.xz

mkdir ParaView-v${paraview_version}Build-EGL
cd    ParaView-v${paraview_version}Build-EGL

cmake -S ../ParaView-v${paraview_version} \
  -DCMAKE_INSTALL_PREFIX=${paraview_install_dir} \
  -DMPI_C_COMPILER=/user-environment/env/default/bin/mpicc \
  -DMPI_C_COMPILER_INCLUDE_DIRS=/user-environment/env/default/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DPARAVIEW_USE_FORTRAN:BOOL=ON \
  -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5:BOOL=ON \
  -DHDF5_DIR:PATH=`spack location -i hdf5`/cmake \
  -DPARAVIEW_USE_MPI:BOOL=ON \
  -DPARAVIEW_BUILD_TESTING:BOOL=OFF \
  -DPARAVIEW_BUILD_EDITION=CANONICAL \
  -DPARAVIEW_USE_PYTHON:BOOL=ON \
  -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB \
  -DTBB_DIR=`spack location -i intel-tbb`/lib64/cmake/TBB \
  -DPARAVIEW_ENABLE_EXAMPLES:BOOL=OFF \
  -DPARAVIEW_ENABLE_ADIOS2:BOOL=ON \
  -DADIOS2_DIR=`spack location -i adios2`/lib64/cmake/adios2 \
  -DPARAVIEW_ENABLE_FIDES:BOOL=ON \
  -DPARAVIEW_ENABLE_CATALYST:BOOL=ON \
  -Dcatalyst_DIR=`spack location -i libcatalyst`/lib64/cmake/catalyst-2.0 \
  -DPARAVIEW_USE_QT:BOOL=OFF \
  -DPARAVIEW_ENABLE_WEB:BOOL=OFF \
  -DVTK_OPENGL_HAS_EGL:BOOL=ON -DVTK_USE_X:BOOL=OFF \
  \
  -DVTK_MODULE_USE_EXTERNAL_VTK_mpi4py:BOOL=ON \
  \
  -DPARAVIEW_PLUGIN_ENABLE_pvNVIDIAIndeX:BOOL=ON \
  -DPARAVIEW_PLUGIN_AUTOLOAD_pvNVIDIAIndeX:BOOL=ON \
  \
  -DPARAVIEW_USE_VTKM=ON -DPARAVIEW_USE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=90 \
  \
  -DPARAVIEW_PLUGIN_AUTOLOAD_CDIReader:BOOL=ON \
  -DPARAVIEW_PLUGIN_ENABLE_CDIReader:BOOL=ON \
  -DCDI_DIR=`spack location -i cdi`/lib/cmake/cdi \
  \
  -DPARAVIEW_PLUGIN_ENABLE_NetCDFTimeAnnotationPlugin:BOOL=ON \
  \
  -DPARAVIEW_ENABLE_RAYTRACING:BOOL=ON \
  -DVTKOSPRAY_ENABLE_DENOISER:BOOL=ON \
  -DOpenImageDenoise_DIR=`spack location -i openimagedenoise`/lib64/cmake/OpenImageDenoise-2.2.2 \
  -Dembree_DIR=`spack location -i embree`/lib64/cmake/embree-4.3.1 \
  -Drkcommon_DIR=`spack location -i rkcommon`/lib64/cmake/rkcommon-1.11.0 \
  -Dopenvkl_DIR=`spack location -i openvkl`/lib64/cmake/openvkl-1.3.2 \
  -Dospray_DIR=`spack location -i ospray`/lib64/cmake/ospray-2.12.0

# Adding a new build for ospray v3.1

paraview_version=5.13.1
paraview_install_dir=$SCRATCH/GH/ParaView/Todi-5.13-Ospray31
mkdir ParaView-v${paraview_version}Build-EGL-Ospray31
cd    ParaView-v${paraview_version}Build-EGL-Ospray31

cmake -S ../ParaView-v${paraview_version} \
  -DCMAKE_INSTALL_PREFIX=${paraview_install_dir} \
  -DMPI_C_COMPILER=/user-environment/env/default/bin/mpicc \
  -DMPI_C_COMPILER_INCLUDE_DIRS=/user-environment/env/default/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DPARAVIEW_USE_FORTRAN:BOOL=ON \
  -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5:BOOL=ON \
  -DHDF5_DIR:PATH=`spack location -i hdf5/aiimm22`/cmake \
  -DPARAVIEW_USE_MPI:BOOL=ON \
  -DPARAVIEW_BUILD_TESTING:BOOL=OFF \
  -DPARAVIEW_BUILD_EDITION=CANONICAL \
  -DPARAVIEW_USE_PYTHON:BOOL=ON \
  -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB \
  -DTBB_DIR=`spack location -i intel-tbb`/lib64/cmake/TBB \
  -DPARAVIEW_ENABLE_EXAMPLES:BOOL=OFF \
  -DPARAVIEW_ENABLE_ADIOS2:BOOL=ON \
  -DADIOS2_DIR=`spack location -i adios2`/lib64/cmake/adios2 \
  -DPARAVIEW_ENABLE_FIDES:BOOL=ON \
  -DPARAVIEW_ENABLE_CATALYST:BOOL=ON \
  -Dcatalyst_DIR=`spack location -i libcatalyst`/lib64/cmake/catalyst-2.0 \
  -DPARAVIEW_USE_QT:BOOL=OFF \
  -DPARAVIEW_ENABLE_WEB:BOOL=OFF \
  -DVTK_OPENGL_HAS_EGL:BOOL=ON -DVTK_USE_X:BOOL=OFF \
  \
  -DPARAVIEW_PLUGIN_ENABLE_pvNVIDIAIndeX:BOOL=ON \
  -DPARAVIEW_PLUGIN_AUTOLOAD_pvNVIDIAIndeX:BOOL=ON \
  \
  -DPARAVIEW_USE_VTKM=ON -DPARAVIEW_USE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=90 \
  \
  -DPARAVIEW_PLUGIN_AUTOLOAD_CDIReader:BOOL=ON \
  -DPARAVIEW_PLUGIN_ENABLE_CDIReader:BOOL=ON \
  -DCDI_DIR=${cdi_install_dir}/lib/cmake/cdi \
  \
  -DPARAVIEW_PLUGIN_ENABLE_NetCDFTimeAnnotationPlugin:BOOL=ON \
  \
  -DPARAVIEW_ENABLE_RAYTRACING:BOOL=ON \
  -DVTKOSPRAY_ENABLE_DENOISER:BOOL=ON \
  -DOpenImageDenoise_DIR=`spack location -i openimagedenoise`/lib64/cmake/OpenImageDenoise-2.2.2 \
  -Dembree_DIR=`spack location -i embree`/lib64/cmake/embree-4.3.1 \
  -Drkcommon_DIR=`spack location -i rkcommon/lnwwsxc`/lib64/cmake/rkcommon-1.13.0 \
  -Dopenvkl_DIR=`spack location -i openvkl/qjcbccz`/lib64/cmake/openvkl-2.0.1 \
  -Dospray_DIR=`spack location -i ospray/ck2oipm`/lib64/cmake/ospray-3.1.0
