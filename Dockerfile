FROM fabioluciano/jdk:v1.8
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Install Wildfly"

# Set some variables to continue with the build process
ENV WILDFLY_VERSION="10.1.0.Final"
ENV DOWNLOAD_URL="http://download.jboss.org/wildfly/"$WILDFLY_VERSION"/wildfly-"$WILDFLY_VERSION".tar.gz"

WORKDIR /opt

RUN apk update \
  && apk --update --no-cache add tar curl supervisor \
  && curl -L $DOWNLOAD_URL > wildfly.tar.gz \
  && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz \
  && mv $directory wildfly

COPY files/* /etc/

EXPOSE 8443/tcp 8080/tcp
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf", "-j", "/tmp/supervisord.pid"]
