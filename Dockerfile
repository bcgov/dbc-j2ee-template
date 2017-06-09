FROM tomcat:8-jre8-alpine
MAINTAINER leo.lou@gov.bc.ca

#Prepair ENV

ENV CATALINA_HOME="/usr/local/tomcat" \
    LANG=C.UTF-8 \
    GLIBC_VERSION=2.25-r0 \
    JAVA_VERSION=8 \
    JAVA_UPDATE=131 \
    JAVA_BUILD=11 \
    JAVA_HOME="/opt/jdk"

ENV JRE_DL_URL=http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}/d54c1d3a095b4ff2b6607d096fa80163/server-jre-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz

#Patch GLIBC required by Oracle JDK 
RUN apk upgrade --update && apk add --update libstdc++ curl wget ca-certificates && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib
RUN \
    for tbd in `ls /usr/lib/jvm/java-1.8-openjdk/bin/`; do rm -f /usr/bin/$tbd; done && \
    rm -rf /usr/lib/jvm/*

#Install Oracle Server Side JRE minimal edition
WORKDIR /tmp
RUN curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O $JRE_DL_URL && \
    mkdir /opt && \
    tar -xvf "server-jre-${JAVA_VERSION}u${JAVA_UPDATE}-linux-x64.tar.gz" -C /opt
RUN ln -s /opt/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE} $JAVA_HOME && \
    ln -s $JAVA_HOME/bin/* /usr/bin/ && \
    if [ "${JAVA_JCE}" == "unlimited" ]; then echo "Installing Unlimited JCE policy" >&2 && \
      curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/jce_policy-${JAVA_VERSION}.zip $JCE_DL_URL && \
      cd /tmp && unzip /tmp/jce_policy-${JAVA_VERSION}.zip && \
      cp -v /tmp/UnlimitedJCEPolicyJDK8/*.jar /opt/jdk/jre/lib/security; \
    fi && \
    sed -i s/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=30/ $JAVA_HOME/jre/lib/security/java.security && \
    apk del curl glibc-i18n && \	
    rm /tmp/*.tar.gz && \
    rm -rf $JAVA_HOME/lib/missioncontrol \
           $JAVA_HOME/lib/visualvm \
           $JAVA_HOME/lib/*javafx* \
           $JAVA_HOME/jre/lib/plugin.jar \
           $JAVA_HOME/jre/lib/ext/jfxrt.jar \
           $JAVA_HOME/jre/bin/javaws \
           $JAVA_HOME/jre/lib/javaws.jar \
           $JAVA_HOME/jre/lib/desktop \
           $JAVA_HOME/jre/plugin \
           $JAVA_HOME/jre/lib/deploy* \
           $JAVA_HOME/jre/lib/*javafx* \
           $JAVA_HOME/jre/lib/*jfx* \
           $JAVA_HOME/jre/lib/amd64/libdecora_sse.so \
           $JAVA_HOME/jre/lib/amd64/libprism_*.so \
           $JAVA_HOME/jre/lib/amd64/libfxplugins.so \
           $JAVA_HOME/jre/lib/amd64/libglass.so \
           $JAVA_HOME/jre/lib/amd64/libgstreamer-lite.so \
           $JAVA_HOME/jre/lib/amd64/libjavafx*.so \
           $JAVA_HOME/jre/lib/amd64/libjfx*.so \
		   /tmp/* /var/cache/apk/*

RUN apk update \
  && apk add alpine-sdk \
  && git config --global url.https://github.com/.insteadOf git://github.com/

RUN rm -rf /usr/local/tomcat/webapps/* && mkdir /usr/local/tomcat/config /usr/local/tomcat/webapps/ROOT
RUN wget -O /tmp/app.war $APPBIN \
  && unzip /tmp/app.war -d /usr/local/tomcat/webapps/ROOT

#Setup runtime configuration
##Add Tomcat Servlet Services configuration, if you have additional configuration file added here
COPY tomcat/server.xml $CATALINA_HOME/conf/server.xml


WORKDIR $CATALINA_HOME

RUN adduser -S tomcat
RUN chown -R tomcat:0 /usr/local/tomcat && chmod -R 770 /usr/local/tomcat
RUN apk del --purge alpine-sdk 

USER tomcat

EXPOSE 8080
ENTRYPOINT ["catalina.sh", "run"]
