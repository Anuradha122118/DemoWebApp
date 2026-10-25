FROM tomcat:9.0-jdk17-temurin

RUN rm -rf /usr/local/tomcat/webapps/* \
    && useradd --system --user-group appuser \
    && chown -R appuser:appuser /usr/local/tomcat

COPY --chown=appuser:appuser target/DemoWebApp.war /usr/local/tomcat/webapps/ROOT.war

USER appuser

EXPOSE 8080

CMD ["catalina.sh", "run"]
