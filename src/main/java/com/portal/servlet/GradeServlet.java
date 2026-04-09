package com.portal.servlet;

import com.portal.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.*;
import java.sql.*;

@WebServlet("/lecturer/grade")
public class GradeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        int submissionId;
        try {
            submissionId = Integer.parseInt(req.getParameter("submissionId"));
        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid submission ID");
            return;
        }

        if ("run".equals(action)) {
            handleRun(req, resp, submissionId);
        } else if ("save".equals(action)) {
            handleSave(req, resp, submissionId);
        } else {
            resp.sendError(400, "Unknown action");
        }
    }


    private void handleRun(HttpServletRequest req, HttpServletResponse resp,
                           int submissionId) throws ServletException, IOException {

        // Fetch file path from DB
        String filePath;
        try (Connection conn = DBConnection.get()) {
            PreparedStatement ps = conn.prepareStatement(
                    "SELECT file_path FROM submissions WHERE id = ?"
            );
            ps.setInt(1, submissionId);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) { resp.sendError(404, "Submission not found"); return; }
            filePath = rs.getString("file_path");
        } catch (SQLException e) {
            throw new ServletException("DB error fetching submission", e);
        }

        // Run submitted script
        String execOutput;
        try {
            Process process = Runtime.getRuntime().exec(
                    new String[]{"python3", filePath}
            );

            BufferedReader stdOut = new BufferedReader(
                    new InputStreamReader(process.getInputStream())
            );
            BufferedReader stdErr = new BufferedReader(
                    new InputStreamReader(process.getErrorStream())
            );

            StringBuilder output = new StringBuilder();
            String line;
            while ((line = stdOut.readLine()) != null) output.append(line).append("\n");
            while ((line = stdErr.readLine()) != null) output.append("[stderr] ").append(line).append("\n");

            process.waitFor();
            execOutput = output.toString().trim();
            if (execOutput.isEmpty()) execOutput = "(no output)";

        } catch (Exception e) {
            execOutput = "Execution failed: " + e.getMessage();
        }

        // Store output in session so grade.jsp can display it after redirect
        req.getSession().setAttribute("execOutput_" + submissionId, execOutput);

        // Redirect back to the grade page — output will be shown there
        resp.sendRedirect(req.getContextPath() +
                "/lecturer/grade.jsp?id=" + submissionId + "&ran=1");
    }

    private void handleSave(HttpServletRequest req, HttpServletResponse resp,
                            int submissionId) throws ServletException, IOException {

        int score;
        try {
            score = Integer.parseInt(req.getParameter("score"));
        } catch (NumberFormatException e) {
            resp.sendError(400, "Invalid score");
            return;
        }
        String comments = req.getParameter("comments");

        // Retrieve the last execution output stored in session (may be empty if
        // lecturer saves without running first)
        String execOutput = (String) req.getSession()
                .getAttribute("execOutput_" + submissionId);
        if (execOutput == null) execOutput = "(not run)";

        // INSERT or UPDATE — no duplicates
        try (Connection conn = DBConnection.get()) {
            PreparedStatement check = conn.prepareStatement(
                    "SELECT id FROM grades WHERE submission_id = ?"
            );
            check.setInt(1, submissionId);
            ResultSet existing = check.executeQuery();

            if (existing.next()) {
                PreparedStatement update = conn.prepareStatement(
                        "UPDATE grades SET score = ?, comments = ?, exec_output = ?, " +
                                "graded_at = NOW() WHERE submission_id = ?"
                );
                update.setInt(1, score);
                update.setString(2, comments);
                update.setString(3, execOutput);
                update.setInt(4, submissionId);
                update.executeUpdate();
            } else {
                PreparedStatement insert = conn.prepareStatement(
                        "INSERT INTO grades (submission_id, score, comments, exec_output) " +
                                "VALUES (?, ?, ?, ?)"
                );
                insert.setInt(1, submissionId);
                insert.setInt(2, score);
                insert.setString(3, comments);
                insert.setString(4, execOutput);
                insert.executeUpdate();
            }

        } catch (SQLException e) {
            throw new ServletException("DB error saving grade", e);
        }

        // Clean up session output after saving
        req.getSession().removeAttribute("execOutput_" + submissionId);

        resp.sendRedirect(req.getContextPath() +
                "/lecturer/submissions.jsp?graded=1");
    }
}