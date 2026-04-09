package com.portal.servlet;

import com.portal.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import at.favre.lib.crypto.bcrypt.BCrypt;

import java.io.IOException;
import java.sql.*;

@WebServlet(urlPatterns = {"/login", "/logout"})
public class AuthServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");


        // Fetch user record from DB
        try (Connection conn = DBConnection.get()) {
            PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, password, role FROM users WHERE username = ?"
            );
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String storedHash = rs.getString("password");

                // Verify password
                BCrypt.Result result = BCrypt.verifyer().verify(
                        password.toCharArray(), storedHash
                );

                if (result.verified) {
                    HttpSession session = req.getSession(true);
                    session.setAttribute("userId",   rs.getInt("id"));
                    session.setAttribute("username", username);
                    session.setAttribute("role",     rs.getString("role"));

                    String role = rs.getString("role");
                    if ("admin".equals(role)) {
                        resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
                    } else if ("lecturer".equals(role)) {
                        resp.sendRedirect(req.getContextPath() + "/lecturer/dashboard.jsp");
                    } else {
                        resp.sendRedirect(req.getContextPath() + "/student/dashboard.jsp");
                    }
                } else {
                    resp.sendRedirect(req.getContextPath() + "/login.jsp?error=1");
                }
            } else {
                resp.sendRedirect(req.getContextPath() + "/login.jsp?error=1");
            }

        } catch (SQLException e) {
            throw new ServletException("Database error during login", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        // /logout — invalidate session and return to login
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();
        resp.sendRedirect(req.getContextPath() + "/login.jsp");
    }
}
