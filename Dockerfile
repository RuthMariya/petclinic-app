FROM openjdk:17
EXPOSE 8080
# Update package lists
RUN apt-get update -y && apt-get upgrade -y

# Install unzip utility
RUN apt-get install -y unzip
WORKDIR /app
RUN unzip artifact.zip
COPY *.jar app.jar
RUN chmod +755 -R /app
CMD ["java", "-jar", "app.jar"]
