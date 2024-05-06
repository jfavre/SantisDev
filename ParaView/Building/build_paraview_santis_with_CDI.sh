uenv start /bret/scratch/cscs/bcumming/images/icon-dsl-3.squashfs
uenv view default

mkdir $SCRATCH/GH/ParaView-CDI
cd $SCRATCH/GH/ParaView-CDI

################
# Catalyst
################

catalyst_version=2.0.0
catalyst_install_dir=$SCRATCH/GH/ParaView-CDI/catalyst-v${catalyst_version}Install

git clone https://gitlab.kitware.com/paraview/catalyst catalyst-v${catalyst_version}
cd catalyst-v${catalyst_version}
git checkout v${catalyst_version}
git submodule update
cd ..

# to pick up numpy required for the Catalyst build
source $HOME/.pyenv310/bin/activate

export FC=`which gfortran`
export CC=`which gcc`
export CXX=`which g++`

cmake -S catalyst-v${catalyst_version} \
      -B catalystBuild \
  -DCATALYST_USE_MPI:BOOL=ON \
  -DCATALYST_WRAP_FORTRAN:BOOL=ON \
  -DCATALYST_WRAP_PYTHON:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${catalyst_install_dir}

cmake --build catalystBuild --target install

################
# CDI
################
cdi_version=2.2.4
cdi_install_dir=$SCRATCH/GH/ParaView-CDI/cdi-v${cdi_version}Install

wget https://code.mpimet.mpg.de/attachments/download/28877/cdi-2.2.4.tar.gz
gunzip cdi-2.2.4.tar.gz
tar xf cdi-2.2.4.tar
cd cdi-2.2.4/
./configure --enable-iso-c-interface \
            --with-netcdf=/user-environment/linux-sles15-neoverse_v2/gcc-12.3.0/netcdf-c-4.9.2-b6jsl6dd6vojrsv6tbmzob4oooubatd6 \
            --prefix=${cdi_install_dir}
make && make install
cd ..


################
# ParaView
################
cd $SCRATCH/GH/ParaView-CDI

paraview_version=5.12.0
paraview_install_dir=$SCRATCH/GH/ParaView/5.12-CDI

wget https://www.paraview.org/files/v5.12/ParaView-v${paraview_version}.tar.xz
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
  -DPARAVIEW_USE_MPI:BOOL=ON \
  -DPARAVIEW_BUILD_TESTING:BOOL=OFF \
  -DPARAVIEW_BUILD_EDITION=CANONICAL \
  -DPARAVIEW_USE_PYTHON:BOOL=ON \
  -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=STDThread \
  -DPARAVIEW_ENABLE_EXAMPLES:BOOL=ON \
  -DPARAVIEW_ENABLE_CATALYST:BOOL=ON \
  -Dcatalyst_DIR=${catalyst_install_dir}/lib64/cmake/catalyst-2.0 \
  -DPARAVIEW_USE_QT:BOOL=OFF \
  -DPARAVIEW_ENABLE_WEB:BOOL=OFF \
  -DVTK_OPENGL_HAS_EGL:BOOL=ON -DVTK_USE_X:BOOL=OFF \
  \
  -DPARAVIEW_PLUGIN_ENABLE_pvNVIDIAIndeX:BOOL=ON \
  -DPARAVIEW_PLUGIN_AUTOLOAD_pvNVIDIAIndeX:BOOL=ON \
  \
  -DPARAVIEW_PLUGIN_AUTOLOAD_CDIReader:BOOL=ON \
  -DPARAVIEW_PLUGIN_ENABLE_CDIReader:BOOL=ON \
  -DCDI_DIR=${cdi_install_dir}/lib/cmake/cdi \
  -DPARAVIEW_PLUGIN_ENABLE_NetCDFTimeAnnotationPlugin:BOOL=ON

make -j32 install
