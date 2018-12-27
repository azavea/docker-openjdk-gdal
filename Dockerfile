FROM openjdk:8u181

### GDAL 2.3.2 ###
ENV ROOTDIR /usr/local/
ENV LD_LIBRARY_PATH /usr/local/lib
ENV GDAL_VERSION 2.3.2
ENV OPENJPEG_VERSION 2.3.0

# Load assets
WORKDIR $ROOTDIR/

ADD http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz $ROOTDIR/src/
ADD https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz $ROOTDIR/src/openjpeg-${OPENJPEG_VERSION}.tar.gz

# Install basic dependencies
RUN apt-get update -y && apt-get install -y \
    software-properties-common \
    python3-software-properties \
    build-essential \
    python-dev \
    python3-dev \
    python-numpy \
    python3-numpy \
    libspatialite-dev \
    sqlite3 \
    libpq-dev \
    libcurl4-gnutls-dev \
    libproj-dev \
    libxml2-dev \
    libgeos-dev \
    libnetcdf-dev \
    libpoppler-dev \
    libhdf4-alt-dev \
    libhdf5-serial-dev \
    wget \
    bash-completion \
    cmake

# Compile and install OpenJPEG
RUN cd src && tar -xvf openjpeg-${OPENJPEG_VERSION}.tar.gz && cd openjpeg-${OPENJPEG_VERSION}/ \
    && mkdir build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$ROOTDIR \
    && make -j3 && make -j3 install && make -j3 clean \
    && cd $ROOTDIR && rm -Rf src/openjpeg*

# Compile and install GDAL
RUN cd src && tar -xvf gdal-${GDAL_VERSION}.tar.gz && cd gdal-${GDAL_VERSION} \
    && ./configure --with-python --with-spatialite --with-pg --with-curl --with-java --with-poppler --with-openjpeg=$ROOTDIR \
    && make -j3 && make -j3 install && ldconfig

# Deps required for GDAL JNI bindings
RUN apt-get install -y swig ant

# Compile and install GDAL JNI and Python bindings
RUN cd $ROOTDIR && cd src/gdal-${GDAL_VERSION}/swig/java && make -j3 && make -j3 install \
    && apt-get update -y \
    && apt-get remove -y --purge build-essential wget \
    && cd $ROOTDIR && cd src/gdal-${GDAL_VERSION}/swig/python \
    && python3 setup.py build \
    && python3 setup.py install \
    && cd $ROOTDIR && cd src/gdal-${GDAL_VERSION}/swig/java && cp -f ./.libs/*.so* /usr/local/lib/ \
    && cd $ROOTDIR && rm -Rf src/gdal*

RUN touch ${JAVA_HOME}/release

# Output version and capabilities by default.
CMD gdalinfo --version && gdalinfo --formats && ogrinfo --formats
