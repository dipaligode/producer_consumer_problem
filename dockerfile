# Use Maven to build the project
FROM maven:3.8.6-eclipse-temurin-17 AS build

COPY . /app
WORKDIR /app
RUN mvn clean package

# Tomcat 10.1 supports Jakarta EE 9+
FROM tomcat:10.1

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
