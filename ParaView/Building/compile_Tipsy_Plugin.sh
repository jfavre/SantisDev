cd /users/jfavre/Projects/Tipsy/ParaViewTipsyPlugin/build513
cdi_version=2.2.4
cdi_install_dir=$SCRATCH/GH/ParaView-CDI/cdi-v${cdi_version}Install
catalyst_version=2.0.0
catalyst_install_dir=$SCRATCH/GH/ParaView-CDI/catalyst-v${catalyst_version}Install
export TBB_ROOT=`spack location -i intel-tbb`

export CC=`which gcc`
export CXX=`which g++`

cmake -S .. \
  -DBUILD_TESTING:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DParaView_DIR=$SCRATCH/GH/ParaView/Todi-5.13/lib64/cmake/paraview-5.13 \
  -DCDI_DIR=${cdi_install_dir}/lib/cmake/cdi \
  -Dcatalyst_DIR=${catalyst_install_dir}/lib64/cmake/catalyst-2.0 

make 
