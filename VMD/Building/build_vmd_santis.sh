uenv start prgenv-gnu/24.11:v1 --view default

cd $HOME/Projects/
# see https://www.tcl.tk/doc/howto/compile.html
wget http://prdownloads.sourceforge.net/tcl/tcl8.6.14-src.tar.gz
tar xf tcl8.6.14-src.tar.gz
pushd tcl8.6.14/unix
./configure --enable-shared --enable-threads --prefix=$HOME/Projects/Tcl --enable-64bit

make -j8
make install
popd

pushd $HOME/Projects/VMD
mkdir build; cd build
tar xf $HOME/Projects/VMD/vmd-1.9.4a57.src.tar.gz
pushd plugins

sed -i 's/ltcl8.5/ltcl8.6/g' Make-arch

sed -i '/switch/a ## CSCS Daint\n case daint-ln00*:\n    echo "Using build settings for CSCS Santis ARM64"\n    setenv TCLINC -I$HOME/Projects/Tcl/include\n    setenv TCLLIB -L$HOME/Projects/Tcl/lib\n    cd $unixdir; make LINUXARM64 >& log.LINUXARM64.$DATE < /dev/null &\n    echo "Waiting for all plugin make jobs to complete..."\n    wait;\n    echo "^G^G^G^G"\n    echo "Plugin builds done..."\n    breaksw;\n' build.csh

./build.csh

export PLUGINDIR=$HOME/Projects/VMD/plugins
make distrib

popd
cd vmd-1.9.4a57

export TCL_INCLUDE_DIR=$HOME/Projects/Tcl/include
export TCL_LIBRARY_DIR=$HOME/Projects/Tcl/lib
ln -s $HOME/Projects/VMD/plugins .

export VMDINSTALLBINDIR=$HOME/Projects/VMD/bin
export VMDINSTALLLIBRARYDIR=$HOME/Projects/VMD/lib

sed -i 's/ltcl8.5/ltcl8.6/g' configure
./configure LINUXARM64 EGLPBUFFER PTHREADS GCC SHARED TCL NOSTATICPLUGINS LIBPNG ZLIB
cd src; make -j12

make install
pushd $HOME/Projects/VMD/lib
ln -s vmd.so vmd_LINUXARM64
