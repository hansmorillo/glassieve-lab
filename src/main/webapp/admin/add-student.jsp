<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.portal.util.DBConnection" %>
<%
  Connection conn = DBConnection.get();
  PreparedStatement ps = conn.prepareStatement(
          "SELECT id, code, name FROM classes ORDER BY code"
  );
  ResultSet rs = ps.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
  <title>glassieve – Add Student</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      max-width: 520px;
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

    h2 {
      font-weight: 400;
      font-size: 1.35rem;
      color: #0f172a;
      margin-bottom: 1.5rem;
    }

    .card {
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      padding: 1.5rem;
    }

    label {
      display: block;
      font-size: 0.78rem;
      font-weight: 500;
      color: #374151;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      margin-bottom: 5px;
    }

    input[type=text],
    input[type=password] {
      width: 100%;
      padding: 9px 10px;
      border: 1px solid #e5e7eb;
      border-radius: 6px;
      font-family: inherit;
      font-size: 0.9rem;
      margin-bottom: 1.1rem;
      color: #111;
      transition: border-color 0.15s;
    }

    input[type=text]:focus,
    input[type=password]:focus {
      outline: none;
      border-color: #2563eb;
    }

    .divider {
      border: none;
      border-top: 1px solid #e5e7eb;
      margin: 1.25rem 0;
    }

    .section-label {
      font-size: 0.72rem;
      font-weight: 500;
      color: #9ca3af;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      margin-bottom: 10px;
    }

    .class-option {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 9px 0;
      border-bottom: 1px solid #f3f4f6;
    }

    .class-option:last-child { border-bottom: none; }

    .class-option input[type=checkbox] {
      width: 15px;
      height: 15px;
      margin: 0;
      accent-color: #0f172a;
      cursor: pointer;
      flex-shrink: 0;
    }

    .class-option label {
      margin: 0;
      cursor: pointer;
      text-transform: none;
      letter-spacing: 0;
      font-size: 0.875rem;
      font-weight: 400;
      color: #374151;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .class-code {
      font-weight: 500;
      color: #0f172a;
      font-size: 0.875rem;
    }

    .class-name {
      color: #9ca3af;
      font-size: 0.82rem;
    }

    .btn {
      margin-top: 1.25rem;
      width: 100%;
      padding: 10px;
      background: #0f172a;
      color: #f1f5f9;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-family: inherit;
      font-size: 0.9rem;
      font-weight: 500;
      transition: background 0.15s;
    }

    .btn:hover { background: #1e293b; }

    .error {
      font-size: 0.82rem;
      color: #dc2626;
      background: #fef2f2;
      border: 1px solid #fecaca;
      border-radius: 6px;
      padding: 8px 12px;
      margin-bottom: 1rem;
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
  &rsaquo;
  <a href="${pageContext.request.contextPath}/admin/students.jsp">Students</a>
  &rsaquo; Add Student
</div>

<h2>Add Student</h2>

<div class="card">
  <% String error = request.getParameter("error");
    if ("empty".equals(error)) { %>
  <p class="error">Username and password cannot be empty.</p>
  <% } else if ("exists".equals(error)) { %>
  <p class="error">That username is already taken.</p>
  <% } %>

  <form method="post" action="${pageContext.request.contextPath}/admin/students">
    <label>Username</label>
    <input type="text" name="username" required autofocus />

    <label>Password</label>
    <input type="password" name="password" required />

    <hr class="divider"/>

    <p class="section-label">Assign to classes</p>
    <div style="margin-bottom: 0.5rem;">
      <%
        while (rs.next()) {
      %>
      <div class="class-option">
        <input type="checkbox" name="classIds"
               id="class_<%= rs.getInt("id") %>"
               value="<%= rs.getInt("id") %>" />
        <label for="class_<%= rs.getInt("id") %>">
          <span class="class-code"><%= rs.getString("code") %></span>
          <span class="class-name">— <%= rs.getString("name") %></span>
        </label>
      </div>
      <%  } rs.close(); conn.close(); %>
    </div>

    <button type="submit" class="btn">Create Student Account</button>
  </form>
</div>
</body>
</html>