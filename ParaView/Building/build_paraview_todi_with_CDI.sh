cd $SCRATCH/GH/ParaView-CDI
paraview_version=5.13.0-RC1
paraview_install_dir=$SCRATCH/GH/ParaView/Todi-5.13
wget https://www.paraview.org/files/v5.13/ParaView-v${paraview_version}.tar.xz
tar xf ParaView-v${paraview_version}.tar.xz

mkdir ParaView-v${paraview_version}Build-EGL
cd    ParaView-v${paraview_version}Build-EGL

export FC=`which gfortran`
export CC=`which gcc`
export CXX=`which g++`

cmake -S ../ParaView-v${paraview_version} \
  -DCMAKE_INSTALL_PREFIX=${paraview_install_dir} \
  -DMPI_C_COMPILER=/user-environment/env/default/bin/mpicc \
  -DMPI_C_COMPILER_INCLUDE_DIRS=/user-environment/env/default/include \
  -DCMAKE_BUILD_TYPE=Release \
  -DPARAVIEW_USE_FORTRAN:BOOL=ON \
  -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5:BOOL=OFF \
  -DPARAVIEW_USE_MPI:BOOL=ON \
  -DPARAVIEW_BUILD_TESTING:BOOL=OFF \
  -DPARAVIEW_BUILD_EDITION=CANONICAL \
  -DPARAVIEW_USE_PYTHON:BOOL=ON \
  -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB \
  -DTBB_DIR=`spack location -i intel-tbb`/lib64/cmake/TBB \
  -DPARAVIEW_ENABLE_EXAMPLES:BOOL=OFF \
  -DPARAVIEW_ENABLE_CATALYST:BOOL=OFF \
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
  -DPARAVIEW_PLUGIN_ENABLE_NetCDFTimeAnnotationPlugin:BOOL=OFF \
  \
  -DPARAVIEW_ENABLE_RAYTRACING:BOOL=ON \
  -DVTKOSPRAY_ENABLE_DENOISER:BOOL=ON \
  -DOpenImageDenoise_DIR=`spack location -i openimagedenoise`/lib64/cmake/OpenImageDenoise-2.2.2 \
  -Dembree_DIR=`spack location -i embree`/lib64/cmake/embree-4.3.1 \
  -Drkcommon_DIR=`spack location -i rkcommon`/lib64/cmake/rkcommon-1.11.0 \
  -Dopenvkl_DIR=`spack location -i openvkl`/lib64/cmake/openvkl-1.3.2 \
  -Dospray_DIR=`spack location -i ospray`/lib64/cmake/ospray-2.12.0
