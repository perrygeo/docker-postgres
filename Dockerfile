#------------------------------------#
# github: perrygeo/docker-postgres
# docker: perrygeo/postgres
#----------------------------------- #
FROM perrygeo/gdal-base:latest as builder

WORKDIR /tmp

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    autoconf automake libreadline-dev zlib1g-dev libxml2-dev llvm-dev clang \
    libjson-c-dev xsltproc docbook-xsl docbook-mathml libssl-dev

ENV POSTGRES_VERSION 13.1
RUN wget -q https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.bz2
RUN tar -xjf postgresql-${POSTGRES_VERSION}.tar.bz2 && \
    cd postgresql-${POSTGRES_VERSION} && \
    ./configure \
    --with-llvm \
    --with-openssl \
    --with-python \
    --prefix=/usr/local && \
    make world -j${CPUS} && make install-world

ENV PROTOBUF_VERSION 3.14.0
ENV PROTOBUF_C_VERSION 1.3.3
RUN wget -q https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz
RUN wget -q https://github.com/protobuf-c/protobuf-c/releases/download/v${PROTOBUF_C_VERSION}/protobuf-c-${PROTOBUF_C_VERSION}.tar.gz
RUN tar -xzf  protobuf-cpp-${PROTOBUF_VERSION}.tar.gz && \
    cd protobuf-${PROTOBUF_VERSION} && \
    ./configure --prefix=/usr/local && \
    make -j${CPUS} && make install
RUN ldconfig
RUN tar -xzf protobuf-c-${PROTOBUF_C_VERSION}.tar.gz && \
    cd protobuf-c-${PROTOBUF_C_VERSION} && \
    ./configure --prefix=/usr/local && \
    make -j${CPUS} && make install

ENV POSTGIS_VERSION 3.1.0
ENV POSTGIS_FULL_VERSION 3.1.0
RUN wget -q https://download.osgeo.org/postgis/source/postgis-${POSTGIS_FULL_VERSION}.tar.gz
RUN tar -xzf postgis-${POSTGIS_FULL_VERSION}.tar.gz && \
    cd postgis-${POSTGIS_FULL_VERSION} && \
    ldconfig && \
    ./configure --with-protobufdir=/usr/local --prefix=/usr/local \
    --with-protobuf-inc=/usr/local/include --with-protobuf-lib=/usr/local/lib && \
    make -j${CPUS} && make install

ENV H3_VERSION 3.7.0
RUN wget -q https://github.com/bytesandbrains/h3-pg/archive/v${H3_VERSION}.tar.gz 
RUN apt-get install -y git
RUN tar -xzf v${H3_VERSION}.tar.gz && \
    cd h3-pg-${H3_VERSION} && \
    make && make install

# Timescale doesn't support pg13 yet
# ENV TIMESCALE_VERSION 1.3.0
# RUN wget -q https://github.com/timescale/timescaledb/releases/download/${TIMESCALE_VERSION}/timescaledb-${TIMESCALE_VERSION}.tar.lzma
# RUN rm -rf /usr/local/lib/libcurl.so.4
# RUN tar --lzma -xf timescaledb-${TIMESCALE_VERSION}.tar.lzma && \
#     cd timescaledb && \
#     ./bootstrap && \
#     cd build && make -j${CPUS} && make install

# Installing some of the packages --no-binary ensures they get linked
# against the system gdal and geos libraries
RUN pip install rasterstats rasterio[s3] fiona shapely pyproj --no-binary rasterio,fiona,shapely,pyproj

ENV PGROUTING_VERSION 3.1.1
RUN wget -q https://github.com/pgRouting/pgrouting/releases/download/v${PGROUTING_VERSION}/pgrouting-${PGROUTING_VERSION}.tar.gz
RUN apt-get -y install --no-install-recommends libboost-graph1.67-dev libboost-graph-parallel1.67-dev
RUN tar -xzf pgrouting-${PGROUTING_VERSION}.tar.gz && \
    cd pgrouting-${PGROUTING_VERSION} && \
    mkdir build && cd build && cmake .. && make -j${CPUS} && make install

# Final
FROM python:3.8-slim-buster as final
# Runtime requirements for dev libraries used above
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
    llvm libssl1.1 libxml2 libjson-c3 libfreexl1 gosu libboost-graph1.67.0 libboost-graph-parallel1.67.0 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local /usr/local
RUN ldconfig

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

RUN useradd -ms /bin/bash postgres
COPY postgresql.conf /etc/postgresql/postgresql.conf
RUN chown postgres /etc/postgresql/postgresql.conf
RUN mkdir -p /var/lib/pgsql/data
RUN chown postgres:postgres /var/lib/pgsql/data

USER postgres
EXPOSE 5432

# To enable "Out-of-DB" rasters
ENV POSTGIS_GDAL_ENABLED_DRIVERS='ENABLE_ALL'
ENV POSTGIS_ENABLE_OUTDB_RASTERS=1
ENV GDAL_DISABLE_READDIR_ON_OPEN='TRUE'

