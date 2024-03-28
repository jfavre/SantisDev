uenv start /bret/scratch/cscs/bcumming/images/icon-dsl-3.squashfs
uenv view default

mkdir $SCRATCH/GH/ParaView-CDI
cd $SCRATCH/GH/ParaView-CDI

################
# Catalyst
################

catalyst_version=2.0.0
catalyst_install_dir=$SCRATCH/GH/ParaView-CDI/catalyst-v${catalyst_version}Install

################
# ParaView
################

paraview_version=5.12.0
cd $SCRATCH/GH/ParaView-CDI/ParaView-v${paraview_version}Build-EGL
paraview_install_dir=$SCRATCH/GH/ParaView/5.12-CDI

# testing Catalyst examples
# All examples are created with ctest
# see also below for building one example without ctest in a seperate folder
# They all fail on first instance because of missing libblosc*so and libsz*.so (related to my CDI reader plugin)
# fix it with

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/user-environment/linux-sles15-neoverse_v2/gcc-12.3.0/c-blosc-1.21.5-x5nxps4uvtcnemcbb4v7ypwfwlnafevd/lib64:/user-environment/linux-sles15-neoverse_v2/gcc-12.3.0/libaec-1.0.6-yj4iir764nqlcrbjfucgo4vridnuj7a5/lib64

ctest -R Catalyst2

# the FORTRAN example will also fail; see https://gitlab.kitware.com/paraview/paraview/-/issues/22552
# re-configure
pushd Examples/Catalyst2/Fortran90FullExample
cmake -DCMAKE_Fortran_FLAGS:STRING="-free -ffree-line-length-1024" .
make
popd

# running on the login node:
# Don't write data anywhere undefined, but use $SCRATCH
# The catalyst script to run is in the source directory
#
sed -i '1s/^/import os\n/' ../ParaView-v5.12.0/Examples/Catalyst2/Fortran90FullExample/catalyst_pipeline.py
sed -i '/EnableCatalystLive/aoptions.ExtractsOutputDirectory = os.getenv("SCRATCH")+"/datasets"' ../ParaView-v5.12.0/Examples/Catalyst2/Fortran90FullExample/catalyst_pipeline.py
./Examples/Catalyst2/Fortran90FullExample/bin/Fortran90FullExampleV2 ../ParaView-v5.12.0/Examples/Catalyst2/Fortran90FullExample/catalyst_pipeline.py

# verify that the datasets have been written in $SCRATCH/datasets
#
# running in parallel on a compute node

srun --uenv=/bret/scratch/cscs/bcumming/images/icon-dsl-3.squashfs:/user-environment -u -N 1 -n 4 -c64 /users/jfavre/Projects/SantisDev/ParaView/Testing/select_local_device2.sh ./Examples/Catalyst2/Fortran90FullExample/bin/Fortran90FullExampleV2 ../ParaView-v5.12.0/Examples/Catalyst2/Fortran90FullExample/catalyst_pipeline.py

output looks like that:

------------------- rank 0/4 ----------------------
executing (cycle=10, time=10.0)
bounds: (1.0, 26.0, 0.0, 99.0, 0.0, 99.0)
psi01-u-range: (53.65766155719757, 89.72094738483429)
psi01-v-range: (1.7320507764816284, 116.04740905761719)
psi01-magnitute-range: (54.3586525015928, 130.67281464284315)
------------------------------------------------------------

------------------- rank 1/4 ----------------------
executing (cycle=10, time=10.0)
bounds: (26.0, 51.0, 0.0, 99.0, 0.0, 99.0)
psi01-u-range: (60.069820523262024, 103.00000011920929)
psi01-v-range: (1.7320507764816284, 116.04740905761719)
psi01-magnitute-range: (60.87016774123587, 131.6539138805207)
------------------------------------------------------------

------------------- rank 3/4 ----------------------
executing (cycle=10, time=10.0)
bounds: (76.0, 100.0, 0.0, 99.0, 0.0, 99.0)
psi01-u-range: (52.664459347724915, 87.41154491901398)
psi01-v-range: (1.7320507764816284, 116.04740905761719)
psi01-magnitute-range: (53.35250901802077, 130.32084712260098)
------------------------------------------------------------

------------------- rank 2/4 ----------------------
executing (cycle=10, time=10.0)
bounds: (51.0, 76.0, 0.0, 99.0, 0.0, 99.0)
psi01-u-range: (59.300270199775696, 101.84529888629913)
psi01-v-range: (1.7320507764816284, 116.04740905761719)
psi01-magnitute-range: (60.08703040587155, 131.64620408691496)
------------------------------------------------------------


# see also below for building the Fortran example without ctest in a separate folder
#
cd $SCRATCH/GH/ParaView-CDI

export FC=`which gfortran`
export CC=`which gcc`
export CXX=`which g++`
cp -r $SCRATCH/GH/ParaView/ParaView-v${paraview_version}/Examples/Catalyst2/Fortran90FullExample .

cmake -B Fortran90FullExampleBuild -S Fortran90FullExample \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_Fortran_FLAGS:STRING="-free -ffree-line-length-1024" \
      -Dcatalyst_DIR=${catalyst_install_dir}/lib64/cmake/catalyst-2.0

cmake --build Fortran90FullExampleBuild
# for run-time, we need an environment var

export CATALYST_IMPLEMENTATION_PATHS=$SCRATCH/GH/ParaView/5.12-CDI/lib64/catalyst

# on login node

sed -i '1s/^/import os\n/' ./Fortran90FullExample/catalyst_pipeline.py
sed -i '/EnableCatalystLive/aoptions.ExtractsOutputDirectory = os.getenv("SCRATCH")+"/datasets"' ./Fortran90FullExample/catalyst_pipeline.py
./Fortran90FullExampleBuild/bin/Fortran90FullExampleV2 ./Fortran90FullExample/catalyst_pipeline.py

# on a compute node in parallel

srun --uenv=/bret/scratch/cscs/bcumming/images/icon-dsl-3.squashfs:/user-environment -u -N 1 -n 4 -c64 /users/jfavre/Projects/SantisDev/ParaView/Testing/select_local_device2.sh ./Fortran90FullExampleBuild/bin/Fortran90FullExampleV2 ./Fortran90FullExample/catalyst_pipeline.py
