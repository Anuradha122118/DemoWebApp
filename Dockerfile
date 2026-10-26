FROM tomcat:9.0-jdk17-temurin

RUN rm -rf /usr/local/tomcat/webapps/* \
    && groupadd -g 10001 appgroup \
    && useradd -u 10001 -g 10001 -M -s /usr/sbin/nologin appuser \
    && mkdir -p /usr/local/tomcat/conf/Catalina/localhost \
                /usr/local/tomcat/webapps/ROOT \
                /usr/local/tomcat/work \
                /usr/local/tomcat/temp \
                /usr/local/tomcat/logs \
    && chown -R 10001:10001 /usr/local/tomcat/webapps \
                              /usr/local/tomcat/work \
                              /usr/local/tomcat/temp \
                              /usr/local/tomcat/logs

COPY --chown=10001:10001 target/DemoWebApp.war /tmp/DemoWebApp.war

RUN cd /usr/local/tomcat/webapps/ROOT \
    && jar -xf /tmp/DemoWebApp.war \
    && rm /tmp/DemoWebApp.war \
    && chown -R 10001:10001 /usr/local/tomcat/webapps/ROOT

USER 10001:10001

EXPOSE 8080

CMD ["catalina.sh", "run"]
