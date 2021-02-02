FROM arm32v7/openjdk:8-jdk 

ARG NEXUS_VERSION=3.29.2-02
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz
ARG NEXUS_DOWNLOAD_SHA256_HASH=bc7cbb577db195868f25d73ca22de3f7cc1e39d7384794bae03c28f5823ca3a7

# configure nexus runtime
ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus \
    NEXUS_DATA=/nexus-data \
    NEXUS_CONTEXT=''

# Install
RUN curl -L ${NEXUS_DOWNLOAD_URL} -o nexus-unix.tar.gz
RUN mkdir -p ${SONATYPE_DIR}
RUN tar xvf nexus-unix.tar.gz -C /tmp
RUN mv /tmp/nexus-${NEXUS_VERSION} ${SONATYPE_DIR}/nexus 

ARG user=nexus
ARG group=nexus
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} && useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user}
RUN chown -R ${user}:${group} ${SONATYPE_DIR}

WORKDIR ${NEXUS_HOME}

VOLUME ${NEXUS_DATA}

EXPOSE 8081

USER nexus

RUN mkdir -p ${NEXUS_DATA}

ENV INSTALL4J_ADD_VM_PARAMS="-Xms2703m -Xmx2703m -XX:MaxDirectMemorySize=2703m -Djava.util.prefs.userRoot=${NEXUS_DATA}/javaprefs"

ADD docker-entrypoint.sh .

CMD ["sh", "docker-entrypoint.sh"]
