FROM ubuntu:latest
MAINTAINER Dan Bryant (daniel.bryant@linux.com)

ENV TZ=Europe/London
ENV DEBIAN_FRONTEND=noninteractive 

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

# install Qt5 dependencies for building tsMuxerGUI for Linux
# make sure to exclude desktop packages from dependency list
RUN apt-get install -y qtbase5-dev qtbase5-dev-tools qtdeclarative5-dev libqt5opengl5-dev qttools5-dev-tools qt5-qmake-bin \
    libxcb1-dev qt5-qmake qtbase5-dev qtdeclarative5-dev qtmultimedia5-dev qttools5-dev \
    gnome-shell- notification-daemon- geoclue-2.0-

# setup osxcross with Qt5
RUN mkdir /usr/lib/osxcross
RUN curl -sLo /tmp/osxcross-7c090bd-20201206.tgz "https://objectstorage.uk-london-1.oraclecloud.com/n/lrglg6cc7bwg/b/bucket-20191211-2226/o/osxcross-7c090bd-20201206.tgz"
RUN tar -xzf /tmp/osxcross-7c090bd-20201206.tgz -C /
RUN rm -f /tmp/osxcross-7c090bd-20201206.tgz

# install tsMuxer OSX build dependencies
ENV MACOSX_DEPLOYMENT_TARGET=10.13
ENV UNATTENDED=1
ENV PATH=/usr/lib/osxcross/bin:/usr/lib/osxcross/tools:$PATH
RUN /usr/lib/osxcross/bin/osxcross-conf && /usr/lib/osxcross/bin/osxcross-macports install freetype && /usr/lib/osxcross/bin/osxcross-macports install zlib

# setup MXE repo (no longer used)
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C6BF758A33A3A276
RUN add-apt-repository -y 'deb https://mirror.mxe.cc/repos/apt stretch main'
RUN apt-get update

# install MXE with GCC 8.3
RUN mkdir -p /usr/lib/mxe
RUN curl -sLo /tmp/mxe-b03103d-20200302.tgz "https://objectstorage.uk-london-1.oraclecloud.com/n/lrglg6cc7bwg/b/bucket-20191211-2226/o/mxe-b03103d-20200302-1.tgz"
RUN tar -xzf /tmp/mxe-b03103d-20200302.tgz -C /usr/lib/mxe
RUN rm -f /tmp/mxe-b03103d-20200302.tgz

# install linuxdeploy and the Qt plugin
RUN curl -sLo /usr/local/bin/linuxdeploy-x86_64.AppImage "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
RUN curl -sLo /usr/local/bin/linuxdeploy-plugin-qt-x86_64.AppImage "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
RUN chmod +x /usr/local/bin/linuxdeploy-x86_64.AppImage
RUN chmod +x /usr/local/bin/linuxdeploy-plugin-qt-x86_64.AppImage

# fix for issue of linuxdeploy in Docker containers
RUN dd if=/dev/zero of=/tmp/linuxdeploy-plugin-qt-x86_64.AppImage conv=notrunc bs=1 count=3 seek=8
RUN dd if=/dev/zero of=/tmp/linuxdeploy-x86_64.AppImage conv=notrunc bs=1 count=3 seek=8

# install Linux tools required to build tsMuxer and create ZIP for distribution
RUN apt-get install -y cmake gcc make ninja-build zip
RUN apt-get upgrade -y

# we need to set up XAR so it can be found by osxcross
RUN apt-get install -y autoconf openssl
RUN git clone https://github.com/tpoechtrager/xar.git /tmp/xar
RUN cd /tmp/xar/xar && ./autogen.sh --prefix=/usr/lib/osxcross
RUN cd /tmp/xar/xar && make && make install 
RUN rm -rf /tmp/xar

# fix some issues with not being able to find libraries
RUN chmod +x /usr/lib/osxcross/lib/libtapi.so.8svn
RUN ln -s /usr/lib/osxcross/macports/pkgs/opt/local/lib/libfreetype.a /usr/lib/osxcross/macports/pkgs/opt/local/lib/libfreetype-static.a
RUN ln -s /usr/lib/osxcross/macports/pkgs/opt/local/lib/libz.a /usr/lib/osxcross/macports/pkgs/opt/local/lib/libz-static.a
RUN ln -s /usr/lib/osxcross/macports/pkgs/opt/local/lib/libbz2.a /usr/lib/osxcross/macports/pkgs/opt/local/lib/libbz2-static.a
RUN ln -s /usr/lib/osxcross/macports/pkgs/opt/local/lib/libpng.a /usr/lib/osxcross/macports/pkgs/opt/local/lib/libpng-static.a
RUN ln -s /usr/lib/osxcross/macports/pkgs/opt/local/lib/libpng16.a /usr/lib/osxcross/macports/pkgs/opt/local/lib/libpng16-static.a

# fix issue with AppImage complaining about missing folders
RUN mkdir /usr/lib/x86_64-linux-gnu/qt5/plugins/mediaservice
RUN mkdir /usr/lib/x86_64-linux-gnu/qt5/plugins/audio
