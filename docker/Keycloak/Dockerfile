FROM openjdk:11-jdk-oraclelinux7

ENV KEYCLOAK_VERSION 12.0.1

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV PROXY_ADDRESS_FORWARDING false
ENV JBOSS_HOME /opt/jboss/keycloak
ENV LANG en_US.UTF-8

ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

USER root

RUN yum update -y && yum install -y glibc-langpack-en gzip hostname openssl tar which && yum clean all

ADD tools /opt/jboss/tools
RUN /opt/jboss/tools/build-keycloak.sh

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]