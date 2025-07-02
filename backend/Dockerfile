# Use the official Gradle image to build the project
FROM gradle:7.2-jdk17 AS build

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Clean Gradle cache and build the project
RUN gradle clean build --no-daemon

# Use the official OpenJDK image to run the application
FROM openjdk:17-jre-slim

# Set the working directory
WORKDIR /app

# Copy the built jar file from the build stage
COPY --from=build /app/build/libs/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
