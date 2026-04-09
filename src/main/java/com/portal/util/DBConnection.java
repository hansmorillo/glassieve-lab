package com.portal.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String HOST = System.getenv().getOrDefault("DB_HOST", "localhost");
    private static final String PORT = System.getenv().getOrDefault("DB_PORT", "5432");
    private static final String NAME = System.getenv().getOrDefault("DB_NAME", "submission_portal");
    private static final String USER = System.getenv().getOrDefault("DB_USER", "portal_user");
    private static final String PASS = System.getenv().getOrDefault("DB_PASSWORD", "portal_pass");

    private static final String URL =
        "jdbc:postgresql://" + HOST + ":" + PORT + "/" + NAME;

    // Explicitly register the PostgreSQL driver when this class is first loaded.
    // Tomcat 10's classloader isolation means DriverManager can't auto-discover
    // drivers bundled inside a WAR — we must load it manually.
    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("PostgreSQL JDBC driver not found on classpath", e);
        }
    }

    public static Connection get() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}
