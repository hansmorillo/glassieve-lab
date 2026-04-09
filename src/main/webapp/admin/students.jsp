<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.portal.util.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
  <title>glassieve – Students</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      max-width: 800px;
      margin: 48px auto;
      padding: 0 1.5rem;
      color: #111;
      background: #f8f9fb;
    }

    nav {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-bottom: 1rem;
      border-bottom: 1px solid #e5e7eb;
      margin-bottom: 2rem;
    }

    .brand { font-weight: 300; font-size: 1.15rem; letter-spacing: -0.5px; color: #0f172a; }
    .nav-right { font-size: 0.85rem; color: #6b7280; }
    a { color: #2563eb; text-decoration: none; }
    a:hover { text-decoration: underline; }

    .breadcrumb {
      font-size: 0.82rem;
      color: #9ca3af;
      margin-bottom: 1.5rem;
    }

    .breadcrumb a { color: #6b7280; }

    .toolbar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 1.25rem;
    }

    h2 {
      font-weight: 400;
      font-size: 1.35rem;
      color: #0f172a;
    }

    .success {
      font-size: 0.85rem;
      color: #16a34a;
      background: #f0fdf4;
      border: 1px solid #bbf7d0;
      border-radius: 6px;
      padding: 8px 12px;
      margin-bottom: 1.25rem;
    }

    .btn {
      display: inline-block;
      padding: 8px 16px;
      background: #0f172a;
      color: #f1f5f9;
      border-radius: 6px;
      font-size: 0.82rem;
      font-weight: 500;
      text-decoration: none;
      transition: background 0.15s;
    }

    .btn:hover { background: #1e293b; color: #f1f5f9; }

    .table-wrap {
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      overflow: hidden;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.875rem;
    }

    th {
      text-align: left;
      padding: 10px 14px;
      background: #f9fafb;
      border-bottom: 1px solid #e5e7eb;
      font-weight: 500;
      color: #6b7280;
      font-size: 0.75rem;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }

    td {
      padding: 11px 14px;
      border-bottom: 1px solid #f3f4f6;
      vertical-align: middle;
      color: #374151;
    }

    tr:last-child td { border-bottom: none; }
    tr:hover td { background: #fafafa; }

    .tag {
      display: inline-block;
      background: #f3f4f6;
      color: #374151;
      padding: 2px 8px;
      border-radius: 4px;
      font-size: 0.75rem;
      margin: 2px 2px 2px 0;
      font-weight: 500;
    }

    .footer-note {
      color: #9ca3af;
      font-size: 0.8rem;
      margin-top: 1.25rem;
      line-height: 1.6;
    }

    .empty {
      text-align: center;
      padding: 2.5rem;
      color: #9ca3af;
      font-size: 0.875rem;
    }
  </style>
</head>
<body>
<nav>
  <span class="brand">glassieve</span>
  <span class="nav-right">
      Logged in as <strong><%= session.getAttribute("username") %></strong>
      &nbsp;|&nbsp;
      <a href="${pageContext.request.contextPath}/logout">Logout</a>
    </span>
</nav>

<div class="breadcrumb">
  <a href="${pageContext.request.contextPath}/admin/dashboard.jsp">Admin</a>
  &rsaquo; Students
</div>

<% if ("1".equals(request.getParameter("created"))) { %>
<p class="success">Student account created successfully.</p>
<% } %>

<div class="toolbar">
  <h2>All Students</h2>
  <a class="btn" href="${pageContext.request.contextPath}/admin/add-student.jsp">
    + Add Student
  </a>
</div>

<%
  Connection conn = DBConnection.get();
  PreparedStatement ps = conn.prepareStatement(
          "SELECT u.id, u.username, " +
                  "STRING_AGG(c.code, ', ' ORDER BY c.code) AS classes " +
                  "FROM users u " +
                  "LEFT JOIN enrollments e ON u.id = e.student_id " +
                  "LEFT JOIN classes c ON e.class_id = c.id " +
                  "WHERE u.role = 'student' " +
                  "GROUP BY u.id, u.username " +
                  "ORDER BY u.username"
  );
  ResultSet rs = ps.executeQuery();
  boolean hasRows = false;
%>

<div class="table-wrap">
  <table>
    <thead>
    <tr>
      <th>#</th>
      <th>Username</th>
      <th>Enrolled Classes</th>
    </tr>
    </thead>
    <tbody>
    <%
      while (rs.next()) {
        hasRows = true;
        String classes = rs.getString("classes");
    %>
    <tr>
      <td><%= rs.getInt("id") %></td>
      <td><%= rs.getString("username") %></td>
      <td>
        <% if (classes != null) {
          for (String cls : classes.split(", ")) { %>
        <span class="tag"><%= cls.trim() %></span>
        <%   } } else { %>
        <span style="color:#9ca3af;">None</span>
        <% } %>
      </td>
    </tr>
    <%  } %>
    </tbody>
  </table>
  <% if (!hasRows) { %>
  <p class="empty">No students yet.</p>
  <% } %>
</div>

<% rs.close(); conn.close(); %>

<p class="footer-note">
  Showing all registered student accounts. To modify class enrolments,
  remove and re-create the account or contact the system administrator.
</p>

<!--
TODO: remove before prod
legacy encoding (not secure):
c3R1ZGVudDpCQkFBQkJBQUJBQkFBQkJBQUJBQQ==
Hint: breakfast comes after decoding
-->
</body>
</html>