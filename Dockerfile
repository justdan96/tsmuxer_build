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

# install Qt5 dependencies for building tsMuxerGUI for Linux
RUN apt-get install -y qt5-default qt5-qmake qtbase5-dev qtdeclarative5-dev qtmultimedia5-dev libqt5multimediawidgets5 libqt5multimedia5-plugins libqt5multimedia5

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
RUN curl -sLo /tmp/qt5-mac-5.13.2.tgz "https://s3.eu.cloud-object-storage.appdomain.cloud/justdan96-public/qt5-mac-5.13.2.tgz"
RUN tar -xzf /tmp/qt5-mac-5.13.2.tgz --strip-components=1 -C /usr/lib/osxcross/macports/pkgs/opt/local
RUN rm -f /tmp/qt5-mac-5.13.2.tgz

# to work around a bug with the installed OSX Qt5 tools we replace roc, moc and rcc with the native versions
RUN mv /usr/lib/osxcross/macports/pkgs/opt/local/bin/uic /usr/lib/osxcross/macports/pkgs/opt/local/bin/uic_native
RUN cp /usr/bin/uic /usr/lib/osxcross/macports/pkgs/opt/local/bin/uic
RUN mv /usr/lib/osxcross/macports/pkgs/opt/local/bin/moc /usr/lib/osxcross/macports/pkgs/opt/local/bin/moc_native
RUN cp /usr/bin/moc /usr/lib/osxcross/macports/pkgs/opt/local/bin/moc
RUN mv /usr/lib/osxcross/macports/pkgs/opt/local/bin/rcc /usr/lib/osxcross/macports/pkgs/opt/local/bin/rcc_native
RUN cp /usr/bin/rcc /usr/lib/osxcross/macports/pkgs/opt/local/bin/rcc

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
RUN apt-get install -y mxe-i686-w64-mingw32.static-zlib
RUN apt-get install -y mxe-i686-w64-mingw32.static-harfbuzz
RUN apt-get install -y mxe-i686-w64-mingw32.static-freetype
RUN apt-get install -y mxe-i686-w64-mingw32.static-cmake
RUN apt-get install -y mxe-i686-w64-mingw32.static-ccache
RUN apt-get install -y mxe-i686-w64-mingw32.static-openssl
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-autotools
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-ccache
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-cc
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-cmake
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-cmake-conf
RUN apt-get install -y mxe-x86-64-pc-linux-gnu-mxe-conf

# setup Qt5 dependency for tsMuxerGUI build for MXE
RUN apt-get install -y mxe-x86-64-w64-mingw32.static-qt5
RUN apt-get install -y mxe-i686-w64-mingw32.static-qt5

# manually fix some weird MXE symlinks
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static-g++
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static-gcc
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/i686-w64-mingw32.static-g++
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/i686-w64-mingw32.static-gcc
RUN ln -s /usr/lib/mxe/usr/bin/x86_64-w64-mingw32.static-g++ /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static-g++
RUN ln -s /usr/lib/mxe/usr/bin/x86_64-w64-mingw32.static-gcc /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/x86_64-w64-mingw32.static-gcc
RUN ln -s /usr/lib/mxe/usr/bin/i686-w64-mingw32.static-g++ /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/i686-w64-mingw32.static-g++
RUN ln -s /usr/lib/mxe/usr/bin/i686-w64-mingw32.static-gcc /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/i686-w64-mingw32.static-gcc
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/g++
RUN rm -f /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/gcc
RUN ln -s /usr/lib/mxe/usr/bin/x86_64-w64-mingw32.static-g++ /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/g++
RUN ln -s /usr/lib/mxe/usr/bin/x86_64-w64-mingw32.static-gcc /usr/lib/mxe/usr/x86_64-pc-linux-gnu/bin/gcc

# install linuxdeploy and the Qt plugin
RUN curl -sLo /usr/local/bin/linuxdeploy-x86_64.AppImage "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
RUN curl -sLo /usr/local/bin/linuxdeploy-plugin-qt-x86_64.AppImage "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
RUN chmod +x /usr/local/bin/linuxdeploy-x86_64.AppImage
RUN chmod +x /usr/local/bin/linuxdeploy-plugin-qt-x86_64.AppImage
RUN cd /tmp && /usr/local/bin/linuxdeploy-x86_64.AppImage --appimage-extract
RUN cd /tmp && /usr/local/bin/linuxdeploy-plugin-qt-x86_64.AppImage --appimage-extract
RUN mv /tmp/squashfs-root /opt/linuxdeploy
