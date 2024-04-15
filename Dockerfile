# Use a base image with OpenJDK 17
FROM openjdk:17

# Expose port 8080
EXPOSE 8080

# RUN apt-get update && apt-get install unzip -y

# Set the working directory


COPY staging/artifact/*.jar app.jar

RUN chmod +755 -R app.jar

CMD ["java", "-jar", "app.jar"]
