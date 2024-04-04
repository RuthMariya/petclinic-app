FROM openjdk:17
EXPOSE 8080
WORKDIR /app
RUN unzip artifact.zip
COPY *.jar app.jar
RUN chmod +755 -R /app
CMD ["java", "-jar", "app.jar"]
