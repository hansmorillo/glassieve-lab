package com.portal.servlet;

import at.favre.lib.crypto.bcrypt.BCrypt;
import com.portal.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.*;

@WebServlet("/admin/students")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // AdminFilter already guarantees only admins reach this point
        String username  = req.getParameter("username").trim();
        String password  = req.getParameter("password").trim();
        String[] classIds = req.getParameterValues("classIds");

        // Validate inputs
        if (username.isEmpty() || password.isEmpty()) {
            resp.sendRedirect(req.getContextPath() +
                    "/admin/add-student.jsp?error=empty");
            return;
        }

        // Hash the password — admin panel always stores hashed passwords
        String hashed = BCrypt.withDefaults()
                .hashToString(12, password.toCharArray());

        try (Connection conn = DBConnection.get()) {

            // Check username not already taken
            PreparedStatement check = conn.prepareStatement(
                    "SELECT id FROM users WHERE username = ?"
            );
            check.setString(1, username);
            if (check.executeQuery().next()) {
                resp.sendRedirect(req.getContextPath() +
                        "/admin/add-student.jsp?error=exists");
                return;
            }

            // Insert new student
            PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO users (username, password, role) VALUES (?, ?, 'student')",
                    Statement.RETURN_GENERATED_KEYS
            );
            insert.setString(1, username);
            insert.setString(2, hashed);
            insert.executeUpdate();

            // Get the new student's id
            ResultSet keys = insert.getGeneratedKeys();
            if (!keys.next()) throw new ServletException("Failed to get new user id");
            int newStudentId = keys.getInt(1);

            // Enroll in selected classes
            if (classIds != null) {
                PreparedStatement enroll = conn.prepareStatement(
                        "INSERT INTO enrollments (student_id, class_id) VALUES (?, ?) " +
                                "ON CONFLICT DO NOTHING"
                );
                for (String classId : classIds) {
                    try {
                        enroll.setInt(1, newStudentId);
                        enroll.setInt(2, Integer.parseInt(classId));
                        enroll.executeUpdate();
                    } catch (NumberFormatException ignored) {}
                }
            }

        } catch (SQLException e) {
            throw new ServletException("DB error creating student", e);
        }

        resp.sendRedirect(req.getContextPath() +
                "/admin/students.jsp?created=1");
    }
}