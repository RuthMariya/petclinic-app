# Use a base image with OpenJDK 17
FROM openjdk:17

# Expose port 8080
EXPOSE 8080


# Set the working directory


# COPY /home/runner/work/petclinic-app/petclinic-app/target/*.jar/artifact.zip /app/artifact.zip

RUN unzip artifact.zip

WORKDIR /app

# Copy the JAR file into the Docker image
COPY artifact/*.jar /app/app.jar

# Define the command to run your application
CMD ["java", "-jar", "app.jar"]
