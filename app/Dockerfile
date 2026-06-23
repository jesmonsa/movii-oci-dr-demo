# Build
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
RUN mvn -q -e -B dependency:go-offline || true
COPY src ./src
RUN mvn -q -B package

# Runtime
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /src/target/dr-demo.jar /app/dr-demo.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/dr-demo.jar"]
