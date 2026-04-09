# glassieve &mdash; assignment submission portal

## Introduction

**glassieve** is an intentionally vulnerable web application built for security education.
It simulates a university assignment submission portal where students upload Python scripts,
lecturers review and grade submissions, and an administrator manages student accounts and enrolments.

The application contains three deliberately introduced vulnerabilities of varying severity.
It is designed to be approached as a **white-box penetration test** — source code is provided
and should be used as part of the assessment.

## Application Stack

| Component | Technology |
|-----------|-----------|
| Frontend  | Java Server Pages (JSP) |
| Backend   | Java Servlets on Apache Tomcat 10 |
| Database  | PostgreSQL 16 |
| Deployment | Docker + Docker Compose |

## Vulnerabilities

There are **three vulnerabilities** to find and exploit.

| # | Title | Difficulty |
|---|-------|------------|
| 1 | Weak Credentials | Low |
| 2 | Broken Access Control | Medium |
| 3 | Remote Code Execution | High |

## Vulnerability Mapping

Mapped to OWASP Top 10:2025:

| Vulnerability | OWASP Category |
|--------------|----------------|
| Weak Credentials | A07:2025 Authentication Failures |
| Broken Access Control | A01:2025 Broken Access Control |
| Remote Code Execution | A05:2025 Injection |


### Challenge descriptions

- **Weak Credentials** — Gain access to an account with unknown credentials
- **Broken Access Control** — As a student, access and modify a resource you should not be able to reach 
- **Remote Code Execution** — Find a way to remotely execute arbitrary commands on the server

For full marks, document each vulnerability with a proof-of-concept and explain how it arises
in the code.

## Credentials

The following credentials are provided as your starting point.

| Role | Username | Password |
|------|----------|----------|
| Student | student-user | P@ssw0rd |
| Lecturer | lecturer | lecturer123 |
| Administrator | admin | P@ssw0rd |

## Deployment

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Starting the challenge

```console
$ git clone https://github.com/hansmorillo/glassieve-lab.git
$ cd glassieve
$ docker compose up -d
```

The application will be available at [http://localhost:8080](http://localhost:8080).

Allow 30–60 seconds on first run for Maven to build the project inside Docker.

### Stopping the challenge

```console
$ docker compose down
```

### Resetting to a clean state

To wipe all data and restart from scratch:

```console
$ docker compose down -v
$ docker compose up -d
```

## Project Structure

```
glassieve/
├── src/main/
│   ├── java/com/portal/
│   │   ├── filter/          Servlet filters
│   │   ├── servlet/         Application servlets
│   │   └── util/            Database utilities
│   ├── resources/
│   │   └── schema.sql       Database schema and seed data
│   └── webapp/
│       ├── admin/           Admin JSP pages
│       ├── lecturer/        Lecturer JSP pages
│       ├── student/         Student JSP pages
│       └── WEB-INF/
├── Dockerfile
├── docker-compose.yml
└── pom.xml
```

## Acknowledgements

Built as part of a Penetration Testing Assignment. Inspired by
[TUDO](https://github.com/bmdyy/tudo) by bmdyy.
