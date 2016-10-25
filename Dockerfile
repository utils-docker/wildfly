FROM frolvlad/alpine-oraclejdk8:slim
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Install Wildfly"

# Set some variables to continue with the build process
ENV WILDFLY_VERSION="9.0.1.Final"
ENV DOWNLOAD_URL="http://download.jboss.org/wildfly/"$WILDFLY_VERSION"/wildfly-"$WILDFLY_VERSION".tar.gz" \
    SSH_PASSWORD="password" \
    KEYSTORE_PASSWORD='password'

WORKDIR /opt

RUN apk update \
  && apk --update --no-cache add tar curl openssh supervisor \
  && printf "$SSH_PASSWORD\n$SSH_PASSWORD" | adduser wildfly \
  && printf "\n\n" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && printf "\n\n" | ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && printf "\n\n" | ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
  && printf "\n\n" | ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
  && echo 'AllowUsers wildfly' >> /etc/ssh/sshd_config \
  && curl -L $DOWNLOAD_URL > wildfly.tar.gz \
  && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz \
  && mv $directory wildfly

WORKDIR /opt/wildfly

RUN printf "localhost\n\n\n\n\n\nyes\n" | keytool -genkeypair -alias serverkey -keyalg RSA -keysize 2048 -validity 7360 -keystore  /opt/wildfly/standalone/configuration/server.keystore -keypass $KEYSTORE_PASSWORD -storepass $KEYSTORE_PASSWORD \
  && sed -i '/<security-realm name="ApplicationRealm">/a <server-identities><ssl><keystore path="server.keystore" relative-to="jboss.server.config.dir" keystore-password="'$KEYSTORE_PASSWORD'" alias="serverkey" key-password="'$KEYSTORE_PASSWORD'"\/></ssl></server-identities>' standalone/configuration/standalone.xml \
  && sed -i '/<http-listener name="default" socket-binding="http" redirect-socket="https"\/>/a <https-listener name="httpsServer" socket-binding="https" security-realm="ApplicationRealm" \/>' standalone/configuration/standalone.xml \
  && chown wildfly:wildfly /opt/wildfly -R

COPY files/* /etc/

EXPOSE 22/tcp 8443/tcp 8080/tcp

ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf", "-j", "/tmp/supervisord.pid", "-l", "/var/log/supervisord.log"]
