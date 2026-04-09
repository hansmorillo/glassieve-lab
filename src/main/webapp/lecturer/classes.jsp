<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.portal.util.DBConnection" %>
<%
  if (session == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  int lecturerId = (Integer) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html>
<head>
  <title>glassieve – My Classes</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      max-width: 680px;
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

    h2 {
      font-weight: 400;
      font-size: 1.35rem;
      color: #0f172a;
      margin-bottom: 1.25rem;
    }

    .class-card {
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      padding: 1.1rem 1.25rem;
      margin-bottom: 0.75rem;
      transition: border-color 0.15s, box-shadow 0.15s;
      text-decoration: none;
      color: inherit;
    }

    .class-card:hover {
      border-color: #2563eb;
      box-shadow: 0 2px 8px rgba(37,99,235,0.07);
      text-decoration: none;
    }

    .class-card-left { flex: 1; }

    .class-code {
      font-size: 0.72rem;
      font-weight: 500;
      color: #2563eb;
      text-transform: uppercase;
      letter-spacing: 0.07em;
      margin-bottom: 3px;
    }

    .class-name {
      font-size: 0.97rem;
      font-weight: 500;
      color: #0f172a;
      margin-bottom: 4px;
    }

    .class-desc {
      font-size: 0.82rem;
      color: #9ca3af;
      line-height: 1.5;
    }

    .class-arrow {
      color: #d1d5db;
      font-size: 1rem;
      margin-left: 1rem;
      flex-shrink: 0;
    }

    .back {
      font-size: 0.85rem;
      margin-top: 1.5rem;
      display: block;
      color: #6b7280;
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

<h2>My Classes</h2>

<%
  Connection conn = DBConnection.get();
  PreparedStatement ps = conn.prepareStatement(
          "SELECT c.id, c.code, c.name, c.description " +
                  "FROM classes c JOIN teaches t ON c.id = t.class_id " +
                  "WHERE t.lecturer_id = ? ORDER BY c.code"
  );
  ps.setInt(1, lecturerId);
  ResultSet rs = ps.executeQuery();
  while (rs.next()) {
%>
<a class="class-card"
   href="${pageContext.request.contextPath}/lecturer/submissions.jsp?classId=<%= rs.getInt("id") %>">
  <div class="class-card-left">
    <div class="class-code"><%= rs.getString("code") %></div>
    <div class="class-name"><%= rs.getString("name") %></div>
    <div class="class-desc"><%= rs.getString("description") %></div>
  </div>
  <div class="class-arrow">›</div>
</a>
<%  } rs.close(); conn.close(); %>

<a class="back" href="${pageContext.request.contextPath}/lecturer/dashboard.jsp">
  ← Back to dashboard
</a>
</body>
</html>