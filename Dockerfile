FROM frolvlad/alpine-oraclejdk8:slim
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Install Wildfly 10.1.0.Final"

# Set some variables to continue with the build process
ENV WILDFLY_VERSION="10.1.0.Final"
ENV DOWNLOAD_URL="http://download.jboss.org/wildfly/"$WILDFLY_VERSION"/wildfly-"$WILDFLY_VERSION".tar.gz"
ENV PASSWORD="senha"

WORKDIR /opt

RUN apk update \
  && apk --update --no-cache add tar curl openssh supervisor \
  && printf "$PASSWORD\n$PASSWORD" | adduser wildfly \
  && printf "\n\n" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && printf "\n\n" | ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && printf "\n\n" | ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
  && printf "\n\n" | ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
  && echo 'AllowUsers wildfly' >> /etc/ssh/sshd_config \
  && curl -L $DOWNLOAD_URL > wildfly.tar.gz \
  && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz \
  && mv $directory wildfly

COPY files/* /etc/

EXPOSE 22/tcp 8443/tcp 8080/tcp

ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf", "-j", "/tmp/supervisord.pid", "-l", "/var/log/supervisord.log"]
