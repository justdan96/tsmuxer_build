FROM ubuntu:disco
MAINTAINER Dan Bryant (daniel.bryant@linux.com)

# install basic dependencies for tsMuxer Linux build
RUN apt-get update
RUN apt-get install -y nano
RUN apt-get install -y software-properties-common
RUN apt-get install -y apt-transport-https
RUN apt-get install -y build-essential g++-multilib
RUN apt-get install -y libc6-dev libfreetype6-dev zlib1g-dev
RUN apt-get install -y checkinstall clang
RUN apt-get install -y git patch lzma-dev libxml2-dev libssl-dev python curl wget
RUN apt-get install -y openssl

# setup osxcross
RUN mkdir /usr/lib/osxcross
RUN curl -sLo /tmp/osxcross-6acb50-20191025.tgz "https://s3.eu.cloud-object-storage.appdomain.cloud/justdan96-public/osxcross-6acb50-20191025.tgz"
RUN tar -xzf /tmp/osxcross-6acb50-20191025.tgz --strip-components=1 -C /usr/lib/osxcross
RUN rm -f osxcross-6acb50-20191025.tgz

# install tsMuxer OSX build dependencies
ENV MACOSX_DEPLOYMENT_TARGET=10.10
ENV UNATTENDED=1
ENV PATH=/usr/lib/osxcross/bin:/usr/lib/osxcross/tools:$PATH
RUN /usr/lib/osxcross/bin/osxcross-conf && /usr/lib/osxcross/bin/osxcross-macports install freetype && /usr/lib/osxcross/bin/osxcross-macports install zlib

# setup MXE
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C6BF758A33A3A276
RUN add-apt-repository -y 'deb https://mirror.mxe.cc/repos/apt stretch main'
RUN apt-get update
RUN apt-get install -y mxe-x86-64-w64-mingw32.static-zlib
RUN apt-get install -y mxe-x86-64-w64-mingw32.static-harfbuzz
RUN apt-get install -y mxe-x86-64-w64-mingw32.static-freetype
RUN apt-get install -y mxe-x86-64-w64-mingw32.static-cmake
RUN apt-get install -y mxe-x86-64-w64-mingw32.static-ccache
RUN apt-get install -y mxe-x86-64-w64-mingw32.static-openssl
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-autotools
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-ccache
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-cc
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-cmake
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-cmake-conf
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-mxe-conf

# manually fix some weird MXE symlinks
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static-g++
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static-gcc
RUN ln -s /usr/lib/mxe/usr/bin/x86_64-w64-mingw32.static-g++ /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static-g++
RUN ln -s /usr/lib/mxe/usr/bin/x86_64-w64-mingw32.static-gcc /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static-gcc
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/g++
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/gcc
RUN ln -s /usr/lib/mxe/usr/bin/x86_64-w64-mingw32.static-g++ /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/g++
RUN ln -s /usr/lib/mxe/usr/bin/x86_64-w64-mingw32.static-gcc /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/gcc
