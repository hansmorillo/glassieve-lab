package com.portal.servlet;

import com.portal.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.sql.*;
import java.nio.file.*;

@WebServlet("/student/submit")
@MultipartConfig(maxFileSize = 1024 * 1024) // 1 MB limit
public class SubmissionServlet extends HttpServlet {

    // Directory inside the container where uploaded files are saved.
    // This matches the volume we defined in docker-compose.yml.
    private static final String UPLOAD_DIR = "/opt/submissions/";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Redirect to login if no session
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int studentId = 0;
        Object idObj = session.getAttribute("userId");

        // ensure userId is available in session
        if (idObj != null) {
            studentId = (int) idObj;
        } else {
            String username = (String) session.getAttribute("username");
            try (Connection conn = DBConnection.get()) {
                PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM users WHERE username = ?"
                );
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    studentId = rs.getInt("id");
                    session.setAttribute("userId", studentId);
                }
            } catch (SQLException e) {
                throw new ServletException("DB error resolving user id", e);
            }
        }

        // Get the uploaded file part
        Part filePart;
        try {
            filePart = req.getPart("file");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/student/submit.jsp?error=1");
            return;
        }

        String filename = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

        // Check file extension
        if (!filename.endsWith(".py")) {
            resp.sendRedirect(req.getContextPath() + "/student/submit.jsp?error=2");
            return;
        }

        // Get assignmentId from form
        int assignmentId;
        try {
            assignmentId = Integer.parseInt(req.getParameter("assignmentId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/student/dashboard.jsp");
            return;
        }

        // Save to disk
        String savePath = UPLOAD_DIR + studentId + "_" + filename;
        Files.createDirectories(Paths.get(UPLOAD_DIR));
        filePart.write(savePath);

        // Record in DB
        try (Connection conn = DBConnection.get()) {
            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO submissions (student_id, assignment_id, filename, file_path) " +
                            "VALUES (?, ?, ?, ?)"
            );
            ps.setInt(1, studentId);
            ps.setInt(2, assignmentId);
            ps.setString(3, filename);
            ps.setString(4, savePath);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException("DB error saving submission", e);
        }

        resp.sendRedirect(req.getContextPath() +
                "/student/submissions.jsp?submitted=1&assignmentId=" + assignmentId);
    }
}
