# docker-openjdk-gdal

![](https://github.com/azavea/docker-openjdk-gdal/workflows/CI/badge.svg)

This repository contains a collection of templated `Dockerfile`s for image variants
designed to support the usage of GDAL with Java bindings. Python bindings
are also installed for your convenience.

## Usage

### Template variables

* `GDAL_VERSION` - Version number for GDAL installation
* `OPENJPEG_VERSION` - Version number for OpenJPEG installation
* `VARIANT` - Base container image variant (`alpine` or `slim`)
* `OPENJDK_VERSION`- Base container image JDK version
* `LIBRPOJ_VERSION` - Version number for Proj4 installation
* `CORES` - Amount of cores used to build libraries

### Testing

An example of how to use `cibuild` to build and test an image:

```
GDAL_VERSION=3.1.2 OPENJDK_VERSION=8 OPENJPEG_VERSION=2.3.0 LIBPROJ_VERSION=7.1.0 CORES=3 VARIANT=slim ./scripts/cibuild
```

This image exists primarily to help bundle GDAL for use with
[GeoTrellis](https://github.com/geotrellis/geotrellis-server). To run GeoTrellis
tests against the images, clone
[`geotrellis-server`](https://github.com/geotrellis/geotrellis-server)
and use the image you created with `cibuild` to run tests:

```
docker run \
  -v $(pwd)/build.sbt:/root/build.sbt \
  -v $(pwd)/project:/root/project \
  -v $(pwd)/core:/root/core \
  -v $(pwd)/sbt:/root/sbt \
  -w /root \
  quay.io/azavea/openjdk-gdal:3.1-slim \
  ./sbt "project core" test
```

You can run a similar test suite in the
[`geotrellis-gdal`](https://github.com/geotrellis/geotrellis-gdal/) repo
for additional testing:

```
docker run \
  -v $(pwd)/build.sbt:/root/build.sbt \
  -v $(pwd)/project:/root/project \
  -v $(pwd)/gdal:/root/gdal \
  -v $(pwd)/src:/root/src \
  -v $(pwd)/sbt:/root/sbt \
  -w /root \
  quay.io/azavea/openjdk-gdal:3.1-slim \
  ./sbt "project gdal" test
```
