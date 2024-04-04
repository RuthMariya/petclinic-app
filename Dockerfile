# Use a base image with OpenJDK 17
FROM openjdk:17

# Expose port 8080
EXPOSE 8080

# Set the working directory
WORKDIR /app

# Copy the artifact.zip file into the Docker image
COPY artifact.zip /app/artifact.zip

# Unzip the artifact.zip file
RUN unzip artifact.zip

# Copy the .jar file into the Docker image
COPY *.jar /app/app.jar

# Change permissions if necessary (you can adjust permissions as per your needs)
RUN chmod +755 -R /app

# Define the command to run your application
CMD ["java", "-jar", "app.jar"]
