FROM ubuntu:disco
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
RUN apt-get install -y qt5-default qt5-qmake qtbase5-dev qtdeclarative5-dev qtmultimedia5-dev libqt5multimediawidgets5 libqt5multimedia5-plugins libqt5multimedia5 qttools5-dev

# setup osxcross
RUN mkdir /usr/lib/osxcross
RUN curl -sLo /tmp/osxcross-6acb50-20191025-1.tgz "https://s3.eu.cloud-object-storage.appdomain.cloud/justdan96-public/osxcross-6acb50-20191025-1.tgz"
RUN tar -xzf /tmp/osxcross-6acb50-20191025-1.tgz --strip-components=1 -C /usr/lib/osxcross
RUN rm -f osxcross-6acb50-20191025-1.tgz

# install tsMuxer OSX build dependencies
ENV MACOSX_DEPLOYMENT_TARGET=10.10
ENV UNATTENDED=1
ENV PATH=/usr/lib/osxcross/bin:/usr/lib/osxcross/tools:$PATH
RUN /usr/lib/osxcross/bin/osxcross-conf && /usr/lib/osxcross/bin/osxcross-macports install freetype && /usr/lib/osxcross/bin/osxcross-macports install zlib

# setup Qt5 for MacOS 
RUN curl -sLo /tmp/qt5-mac-5.13.2.tgz "https://justdan96-public.s3.eu.cloud-object-storage.appdomain.cloud/qt5-mac-5.13.2-1.tgz"
RUN tar -xzf /tmp/qt5-mac-5.13.2.tgz --strip-components=1 -C /usr/lib/osxcross/macports/pkgs/opt/local
RUN rm -f /tmp/qt5-mac-5.13.2.tgz

# to work around a bug with the installed OSX Qt5 tools we replace roc, moc and rcc with the native versions
RUN mv /usr/lib/osxcross/macports/pkgs/opt/local/bin/uic /usr/lib/osxcross/macports/pkgs/opt/local/bin/uic_native
RUN cp /usr/bin/uic /usr/lib/osxcross/macports/pkgs/opt/local/bin/uic
RUN mv /usr/lib/osxcross/macports/pkgs/opt/local/bin/moc /usr/lib/osxcross/macports/pkgs/opt/local/bin/moc_native
RUN cp /usr/bin/moc /usr/lib/osxcross/macports/pkgs/opt/local/bin/moc
RUN mv /usr/lib/osxcross/macports/pkgs/opt/local/bin/rcc /usr/lib/osxcross/macports/pkgs/opt/local/bin/rcc_native
RUN cp /usr/bin/rcc /usr/lib/osxcross/macports/pkgs/opt/local/bin/rcc

# setup MXE repo (no longer used)
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C6BF758A33A3A276
RUN add-apt-repository -y 'deb https://mirror.mxe.cc/repos/apt stretch main'
RUN apt-get update

# install MXE with GCC 8.3
RUN mkdir -p /usr/lib/mxe
RUN curl -sLo /tmp/mxe-b03103d-20200302.tgz "https://objectstorage.uk-london-1.oraclecloud.com/n/lrglg6cc7bwg/b/bucket-20191211-2226/o/mxe-b03103d-20200302-1.tgz"
RUN tar -xzf /tmp/mxe-b03103d-20200302.tgz -C /usr/lib/mxe
RUN rm -f mxe-b03103d-20200302.tgz

# install linuxdeploy and the Qt plugin
RUN curl -sLo /usr/local/bin/linuxdeploy-x86_64.AppImage "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
RUN curl -sLo /usr/local/bin/linuxdeploy-plugin-qt-x86_64.AppImage "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
RUN chmod +x /usr/local/bin/linuxdeploy-x86_64.AppImage
RUN chmod +x /usr/local/bin/linuxdeploy-plugin-qt-x86_64.AppImage
RUN cd /tmp && /usr/local/bin/linuxdeploy-x86_64.AppImage --appimage-extract
RUN cd /tmp && /usr/local/bin/linuxdeploy-plugin-qt-x86_64.AppImage --appimage-extract
RUN mv /tmp/squashfs-root /opt/linuxdeploy

# use native versions of lconvert, lrelease and lupdate
RUN cp /usr/bin/lconvert /usr/lib/osxcross/macports/pkgs/opt/local/bin/lconvert
RUN cp /usr/bin/lrelease /usr/lib/osxcross/macports/pkgs/opt/local/bin/lrelease
RUN cp /usr/bin/lupdate /usr/lib/osxcross/macports/pkgs/opt/local/bin/lupdate

# install Linux tools required to build tsMuxer and create ZIP for distribution
RUN apt-get install -y cmake gcc make ninja-build zip
