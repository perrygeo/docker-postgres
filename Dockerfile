#------------------------------------#
# github: perrygeo/docker-postgres
# docker: perrygeo/postgres
#----------------------------------- #
FROM perrygeo/gdal-base:latest as builder

WORKDIR /tmp

ENV POSTGRES_VERSION 11.2
ENV PROTOBUF_VERSION 3.6.1
ENV PROTOBUF_C_VERSION 1.3.1
ENV POSTGIS_VERSION 2.5.2
ENV TIMESCALE_VERSION 1.2.1

RUN wget -q https://ftp.postgresql.org/pub/source/v${POSTGRES_VERSION}/postgresql-${POSTGRES_VERSION}.tar.bz2
RUN wget -q https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz
RUN wget -q https://github.com/protobuf-c/protobuf-c/releases/download/v${PROTOBUF_C_VERSION}/protobuf-c-${PROTOBUF_C_VERSION}.tar.gz
RUN wget -q https://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz
RUN wget -q https://github.com/timescale/timescaledb/releases/download/${TIMESCALE_VERSION}/timescaledb-${TIMESCALE_VERSION}.tar.gz

RUN apt-get install -y --no-install-recommends \
        autoconf automake libreadline-dev zlib1g-dev libxml2-dev llvm-4.0-dev clang-4.0 \
        libjson-c-dev xsltproc docbook-xsl docbook-mathml libssl-dev

    # ./configure --help && exit 1
RUN tar -xjf postgresql-${POSTGRES_VERSION}.tar.bz2 && \
    cd postgresql-${POSTGRES_VERSION} && \
    ./configure \
        --with-llvm \
        --with-openssl \
        --with-python \
        --prefix=/usr/local && \
    make -j${CPUS} && make install

RUN tar -xzf  protobuf-cpp-${PROTOBUF_VERSION}.tar.gz && \
    cd protobuf-${PROTOBUF_VERSION} && \
    ./configure --prefix=/usr/local && \
    make -j${CPUS} && make install

RUN ldconfig
RUN tar -xzf protobuf-c-${PROTOBUF_C_VERSION}.tar.gz && \
    cd protobuf-c-${PROTOBUF_C_VERSION} && \
    ./configure --prefix=/usr/local && \
    make -j${CPUS} && make install

RUN tar -xzf postgis-${POSTGIS_VERSION}.tar.gz && \
    cd postgis-${POSTGIS_VERSION} && \
    ./configure --with-protobufdir=/usr/local --prefix=/usr/local && \
    make -j${CPUS} && make install

RUN rm -rf /usr/local/lib/libcurl.so.4
RUN tar -xzf timescaledb-${TIMESCALE_VERSION}.tar.gz && \
    cd timescaledb && \
    ./bootstrap && \
    cd build && make -j${CPUS} && make install

# Final
FROM python:3.6-slim-stretch as final
# Runtime requirements for dev libraries used above
RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
           llvm-4.0 libssl1.1 libxml2 libjson-c3 libfreexl1 gosu \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local /usr/local
RUN ldconfig

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

RUN useradd -ms /bin/bash postgres
COPY postgresql.conf /etc/postgresql/postgresql.conf
RUN chown postgres /etc/postgresql/postgresql.conf
USER postgres
EXPOSE 5432
