#!/bin/bash
# -- Compile Yosys script

REL=0 # 1: load from release tag. 0: load from source code

VER=670468cf92577d1193196367c19db9fcd4d3413c
YOSYS=yosys-yosys-$VER
TAR_YOSYS=yosys-$VER.tar.gz
REL_YOSYS=https://github.com/xobs/yosys/archive/$TAR_YOSYS
GIT_YOSYS=https://github.com/xobs/yosys.git

cd $UPSTREAM_DIR

if [ $REL -eq 1 ]; then
    # -- Check and download the release
    test -e $TAR_YOSYS || wget $REL_YOSYS
    # -- Unpack the release
    tar zxf $TAR_YOSYS
else
    # -- Clone the sources from github
    git clone -b smtbmc-msvc2-build-fixes --depth=1 $GIT_YOSYS $YOSYS
    git -C $YOSYS pull
    echo ""
    git -C $YOSYS reset --hard $VER
    git -C $YOSYS log -1
fi

# -- Copy the upstream sources into the build directory
rsync -a $YOSYS $BUILD_DIR --exclude .git

cd $BUILD_DIR/$YOSYS

# -- Compile it
if [ $ARCH == "darwin" ]; then
    make config-clang
    sed -i "" "s/-Wall -Wextra -ggdb/-w/;" Makefile
    CXXFLAGS="-I/tmp/conda/include -std=c++11" LDFLAGS="-L/tmp/conda/lib" make \
            -j$J YOSYS_VER="$VER (Fomu build)" \
            ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_PYOSYS=0 \
            ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" OPTFLAGS=\"-O\" \
                       ARCHFLAGS=\"$ABC_ARCHFLAGS\" ABC_USE_NO_READLINE=1"

elif [ ${ARCH:0:7} == "windows" ]; then
    x86_64-w64-mingw32-g++ -dM -E - < /dev/null
    make config-msys2-64
    make -j$J YOSYS_VER="$VER (Fomu build)" PRETTY=0 \
              ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_PYOSYS=0
else
  make config-gcc
  sed -i "s/-Wall -Wextra -ggdb/-w/;" Makefile
  sed -i "s/LD = gcc$/LD = $CC/;" Makefile
  sed -i "s/CXX = gcc$/CXX = $CC/;" Makefile
  sed -i "s/LDFLAGS += -rdynamic/LDFLAGS +=/;" Makefile
  make -j$J YOSYS_VER="$VER (Fomu build)" \
            LDLIBS="-static -lstdc++ -lm" \
            ENABLE_TCL=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0 ENABLE_ZLIB=0 ENABLE_PYOSYS=0 \
            ABCMKARGS="CC=\"$CC\" CXX=\"$CXX\" LIBS=\"-static -lm -ldl -pthread\" OPTFLAGS=\"-O\" \
                       ARCHFLAGS=\"$ABC_ARCHFLAGS -Wno-unused-but-set-variable\" ABC_USE_NO_READLINE=1"
fi

EXE_O=
if [ -f yosys.exe ]; then
    EXE_O=.exe
    PY=.exe
fi

# -- Test the generated executables
test_bin yosys$EXE_O
test_bin yosys-abc$EXE_O
test_bin yosys-config
test_bin yosys-filterlib$EXE_O
test_bin yosys-smtbmc$EXE_O

# -- Copy the executable files
cp yosys$EXE_O $PACKAGE_DIR/$NAME/bin/yosys$EXE
cp yosys-abc$EXE_O $PACKAGE_DIR/$NAME/bin/yosys-abc$EXE
cp yosys-config $PACKAGE_DIR/$NAME/bin/yosys-config
cp yosys-filterlib$EXE_O $PACKAGE_DIR/$NAME/bin/yosys-filterlib$EXE
cp yosys-smtbmc$EXE_O $PACKAGE_DIR/$NAME/bin/yosys-smtbmc$PY

# -- Copy the share folder to the package folder
mkdir -p $PACKAGE_DIR/$NAME/share/yosys
cp -r share/* $PACKAGE_DIR/$NAME/share/yosys
