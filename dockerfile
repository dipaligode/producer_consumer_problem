# Use Maven to build the project
FROM maven:3.8.6-eclipse-temurin-17 AS build

# Copy the entire project folder (make sure you have the correct build context in your Docker build)
COPY ./producer-consumer-problem /app
WORKDIR /app

# Run Maven to clean and package the project
RUN mvn clean package

# Tomcat 10.1 supports Jakarta EE 9+
FROM tomcat:10.1

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from the build stage to Tomcat's webapps folder
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
