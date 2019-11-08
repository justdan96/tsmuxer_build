# tsMuxer Build Dockerfile

[Docker](http://docker.com) container to build [tsMuxer](https://github.com/justdan96/tsMuxer).


## Usage

### Install

Pull `justdan96/tsmuxer_build` from the Docker repository:
```
docker pull justdan96/tsmuxer_build
```

Or build `justdan96/tsmuxer_build` from source:
```
git clone https://github.com/justdan96/tsmuxer_build.git
cd tsmuxer_build
docker build -t justdan96/tsmuxer_build .
```

### Run

This image is designed to build tsMuxer. So once you have the image, browse to the tsMuxer repository and run one of the following commands:

*Linux*
```
docker run -it --rm -v $(pwd):/workdir -w="/workdir" justdan96/tsmuxer_build bash -c ". rebuild_linux_docker.sh"
```

*Windows*
```
docker run -it --rm -v $(pwd):/workdir -w="/workdir" justdan96/tsmuxer_build bash -c ". rebuild_mxe_docker.sh"
```

*OSX*
```
docker run -it --rm -v $(pwd):/workdir -w="/workdir" justdan96/tsmuxer_build bash -c ". rebuild_osxcross_docker.sh"
```

The executable binary will be saved to the "\bin" folder.
