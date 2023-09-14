#! /bin/bash -x

#
# environment variables affecting the build:
#
# keep_toolchain=y	-- don't rebuild the toolchain, but rebuild everything else
#

if [ ! -d autoconf-2.71/root/bin ] ; then
	wget https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.xz
	tar -xf autoconf-2.71.tar.xz
	pushd autoconf-2.71
	./configure --prefix=`pwd`/root
	make && make install
	popd
fi
export PATH=`pwd`/autoconf-2.71/root/bin:$PATH

if [ -z "$keep_toolchain" ] ; then
	rm -rf build
fi
mkdir -p build
cd build

#
# dynconfig
#
if [ ! -f xtensa-dynconfig/esp32s3.so ] ; then
	git clone https://github.com/jcmvbkbc/xtensa-dynconfig -b original
	git clone https://github.com/jcmvbkbc/config-esp32s3 esp32s3
	make -C xtensa-dynconfig ORIG=1 CONF_DIR=`pwd` esp32s3.so
fi
export XTENSA_GNU_CONFIG=`pwd`/xtensa-dynconfig/esp32s3.so

#
# toolchain
#
if [ ! -x crosstool-NG/builds/xtensa-esp32s3-linux-uclibcfdpic/bin/xtensa-esp32s3-linux-uclibcfdpic-gcc ] ; then
	git clone https://github.com/jcmvbkbc/crosstool-NG.git -b xtensa-fdpic
	pushd crosstool-NG
	./bootstrap && ./configure --enable-local && make
	./ct-ng xtensa-esp32s3-linux-uclibcfdpic
	CT_PREFIX=`pwd`/builds nice ./ct-ng build
	popd
	[ -x crosstool-NG/builds/xtensa-esp32s3-linux-uclibcfdpic/bin/xtensa-esp32s3-linux-uclibcfdpic-gcc ] || exit 1
fi
