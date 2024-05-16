uenv start /bret/scratch/cscs/ialberto/paraview+cdi+raytracing+libcatalyst.squashfs
uenv view default

export FC=`which gfortran`
export CC=`which gcc`
export CXX=`which g++`
# needs the path to the souce code of ParaView. Mine is in $SCRATCH/GH/ParaView/ParaView-v5.12.0/
# first clean up old test
rm -rf $SCRATCH/Fortran90FullExample*

cp -r $SCRATCH/GH/ParaView/ParaView-v5.12.0/Examples/Catalyst2/Fortran90FullExample $SCRATCH

cd $SCRATCH
cmake -B Fortran90FullExampleBuild -S Fortran90FullExample \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_Fortran_FLAGS:STRING="-free -ffree-line-length-1024" 


cmake --build Fortran90FullExampleBuild
# for run-time, we need an environment var

export CATALYST_IMPLEMENTATION_PATHS=`spack location -i paraview`/lib64/catalyst
# N.B. I need this var also in the wrapper script below
#
# on login node, modify the script to tell it to save data in $SCRATCH/datasets
# we will also need LD_LIBRARY_PATH loaded with the `spack location -i paraview`/lib64/catalyst and the `spack location -i libcatalyst`/lib64. See the wrapper script

sed -i '1s/^/import os\n/' ./Fortran90FullExample/catalyst_pipeline.py
sed -i '/EnableCatalystLive/aoptions.ExtractsOutputDirectory = os.getenv("SCRATCH")+"/datasets"' ./Fortran90FullExample/catalyst_pipeline.py
./Fortran90FullExampleBuild/bin/Fortran90FullExampleV2 ./Fortran90FullExample/catalyst_pipeline.py

# on a compute node in parallel

srun --uenv=/bret/scratch/cscs/ialberto/paraview+cdi+raytracing+libcatalyst.squashfs:/user-environment -u -N 1 -n 4 -c64 /users/jfavre/Projects/SantisDev/ParaView/Testing/select_local_device3_alberto.sh ./Fortran90FullExampleBuild/bin/Fortran90FullExampleV2 ./Fortran90FullExample/catalyst_pipeline.py
