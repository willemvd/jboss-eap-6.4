FROM openjdk:8u121-jdk-alpine

COPY ./jce-unlimited/ /tmp/eap/jce-unlimited/
COPY ./trusted-root-ca/ /tmp/eap/trusted-root-ca/
COPY ./modules/ /tmp/eap/modules/
COPY ./distribution/ /tmp/eap/
COPY ./patches/ /tmp/eap/patches/

EXPOSE 5455 9999 8009 8080 8443 3528 3529 7500 45700 7600 57600 5445 23364 5432 8090 4447 4712 4713 9990 8787

ENV HOME /home/jboss
ENV JBOSS_HOME /opt/jboss-eap-6.4

RUN apk --no-cache add \
      curl \
      openssl && \
      addgroup -g 1000 jboss && \
      adduser -u 1000 -D -s /sbin/nologin -g "JBoss" -G jboss jboss && \
      for f in $(ls /tmp/eap/jce-unlimited); do cp /tmp/eap/jce-unlimited/$f $JAVA_HOME/jre/lib/security/$f; done && \
      for f in $(ls /tmp/eap/trusted-root-ca); do $JAVA_HOME/bin/keytool -import -noprompt -trustcacerts -alias $(echo $f | sed 's/\(.*\)\..*/\1/') -file /tmp/eap/trusted-root-ca/$f -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit; done && \
      mkdir -p $JBOSS_HOME && \
      unzip /tmp/eap/*.zip -d /opt && \
      for f in $(ls /tmp/eap/modules); do echo "Copy module $f" && cp -R /tmp/eap/modules/$f $JBOSS_HOME/modules/$f; done && \
      for f in $(ls -v /tmp/eap/patches); do echo "Apply patch $f" && $JBOSS_HOME/bin/jboss-cli.sh "patch apply /tmp/eap/patches/$f"; done

COPY ./entrypoint.sh $JBOSS_HOME/entrypoint.sh

RUN chmod +x $JBOSS_HOME/entrypoint.sh && \
      chown -R jboss:jboss $JBOSS_HOME && \
      rm -rf /tmp/eap

USER 1000

ENTRYPOINT $JBOSS_HOME/entrypoint.sh