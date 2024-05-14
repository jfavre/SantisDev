cd /users/jfavre/Projects/Tipsy/ParaViewTipsyPlugin/build512
cdi_version=2.2.4
cdi_install_dir=$SCRATCH/GH/ParaView-CDI/cdi-v${cdi_version}Install
catalyst_version=2.0.0
catalyst_install_dir=$SCRATCH/GH/ParaView-CDI/catalyst-v${catalyst_version}Install
export TBB_ROOT=`spack location -i intel-tbb/z5`

export CC=`which gcc`
export CXX=`which g++`

ccmake -S .. \
  -BUILD_TESTING:BOOL=ON \
  -DParaView_DIR=/bret/scratch/cscs/jfavre/GH/ParaView/5.12-CDI/lib64/cmake/paraview-5.12 \
  -Dcatalyst_DIR=${catalyst_install_dir}/lib64/cmake/catalyst-2.0 \
  -DCDI_DIR=${cdi_install_dir}/lib/cmake/cdi

make 
