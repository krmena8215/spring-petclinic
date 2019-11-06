FROM registry.access.redhat.com/openjdk/openjdk-11-rhel8:latest
ADD ["target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar", "app.jar"]
EXPOSE 8080 8080
RUN sh -c 'touch /app.jar'
ENTRYPOINT [ "sh", "-c", "java -jar /app.jar" ]
