#!/bin/bash -e

###########################
# Build/download Keycloak #
###########################

echo "Keycloak from [download]: $KEYCLOAK_DIST"

cd /opt/jboss/
curl -L $KEYCLOAK_DIST | tar zx
mv /opt/jboss/keycloak-* /opt/jboss/keycloak

######################
# Configure Keycloak #
######################

cd /opt/jboss/keycloak

bin/jboss-cli.sh --file=/opt/jboss/tools/cli/standalone-configuration.cli
rm -rf /opt/jboss/keycloak/standalone/configuration/standalone_xml_history

bin/jboss-cli.sh --file=/opt/jboss/tools/cli/standalone-ha-configuration.cli
rm -rf /opt/jboss/keycloak/standalone/configuration/standalone_xml_history

###########
# Garbage #
###########

rm -rf /opt/jboss/keycloak/standalone/tmp/auth
rm -rf /opt/jboss/keycloak/domain/tmp/auth

###################
# Set permissions #
###################

echo "jboss:x:0:root" >> /etc/group
echo "jboss:x:1000:0:JBoss user:/opt/jboss:/sbin/nologin" >> /etc/passwd
chown -R jboss:root /opt/jboss
chmod -R g+rwX /opt/jboss
