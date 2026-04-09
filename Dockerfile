# ─── Stage 1: Build ───────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -q
COPY src ./src
RUN mvn clean package -q

# ─── Stage 2: Runtime ─────────────────────────────────────────────
FROM tomcat:10.1-jdk17

# Install Python3 into the Tomcat container
RUN apt-get update && apt-get install -y python3 --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from builder
COPY --from=builder /app/target/glassieve.war /usr/local/tomcat/webapps/ROOT.war

# Create uploads directory
RUN mkdir -p /opt/submissions

EXPOSE 8080
