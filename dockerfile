# Use the official Tomcat base image
FROM tomcat:9.0

# Remove the default web apps (optional but cleaner)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR file into the ROOT of the webapps directory
COPY target/producer_consumer_problem.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 (Render automatically handles this)
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
