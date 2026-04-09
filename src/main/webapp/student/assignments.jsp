<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.portal.util.DBConnection" %>
<%
  if (session == null || session.getAttribute("username") == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }
  int studentId = (Integer) session.getAttribute("userId");

  int classId;
  try {
    classId = Integer.parseInt(request.getParameter("classId"));
  } catch (NumberFormatException e) {
    response.sendRedirect(request.getContextPath() + "/student/classes.jsp");
    return;
  }

  // Load class info
  String className = "";
  String classCode = "";
  Connection conn = DBConnection.get();
  PreparedStatement psClass = conn.prepareStatement(
          "SELECT code, name FROM classes c " +
                  "JOIN enrollments e ON c.id = e.class_id " +
                  "WHERE c.id = ? AND e.student_id = ?"
  );
  psClass.setInt(1, classId);
  psClass.setInt(2, studentId);
  ResultSet rsClass = psClass.executeQuery();
  if (rsClass.next()) {
    classCode = rsClass.getString("code");
    className = rsClass.getString("name");
  } else {
    // Student not enrolled in this class
    response.sendRedirect(request.getContextPath() + "/student/classes.jsp");
    return;
  }
  rsClass.close();
%>
<!DOCTYPE html>
<html>
<head>
  <title>glassieve – <%= classCode %></title>
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

    .breadcrumb {
      font-size: 0.82rem;
      color: #9ca3af;
      margin-bottom: 1.5rem;
    }

    .breadcrumb a { color: #6b7280; }

    .page-header { margin-bottom: 1.75rem; }

    h2 {
      font-weight: 400;
      font-size: 1.35rem;
      color: #0f172a;
      margin-bottom: 2px;
    }

    .subtitle {
      font-size: 0.82rem;
      color: #9ca3af;
    }

    .assign-card {
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      padding: 1.25rem 1.35rem;
      margin-bottom: 0.875rem;
    }

    .assign-title {
      font-size: 0.97rem;
      font-weight: 500;
      color: #0f172a;
      margin-bottom: 6px;
    }

    .assign-desc {
      font-size: 0.83rem;
      color: #6b7280;
      line-height: 1.6;
      margin-bottom: 1rem;
    }

    .btn {
      display: inline-block;
      padding: 7px 16px;
      border-radius: 6px;
      font-size: 0.83rem;
      text-decoration: none;
      font-weight: 500;
      transition: background 0.15s;
    }

    .btn-primary {
      background: #0f172a;
      color: #f1f5f9;
    }

    .btn-primary:hover { background: #1e293b; color: #f1f5f9; }

    .btn-secondary {
      background: #f3f4f6;
      color: #374151;
      border: 1px solid #e5e7eb;
      margin-left: 6px;
    }

    .btn-secondary:hover { background: #e5e7eb; color: #374151; }

    .no-upload {
      font-size: 0.8rem;
      color: #9ca3af;
      font-style: italic;
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

<div class="breadcrumb">
  <a href="${pageContext.request.contextPath}/student/classes.jsp">My Classes</a>
  &rsaquo; <%= classCode %>
</div>

<div class="page-header">
  <h2><%= className %></h2>
  <p class="subtitle"><%= classCode %></p>
</div>

<%
  PreparedStatement psAssign = conn.prepareStatement(
          "SELECT id, title, description, accepts_files FROM assignments " +
                  "WHERE class_id = ? ORDER BY id"
  );
  psAssign.setInt(1, classId);
  ResultSet rsAssign = psAssign.executeQuery();
  boolean hasAssignments = false;
  while (rsAssign.next()) {
    hasAssignments = true;
    int    assignId      = rsAssign.getInt("id");
    String assignTitle   = rsAssign.getString("title");
    String assignDesc    = rsAssign.getString("description");
    boolean acceptsFiles = rsAssign.getBoolean("accepts_files");
%>
<div class="assign-card">
  <div class="assign-title"><%= assignTitle %></div>
  <div class="assign-desc"><%= assignDesc %></div>
  <% if (acceptsFiles) { %>
  <a class="btn btn-primary"
     href="${pageContext.request.contextPath}/student/submit.jsp?assignmentId=<%= assignId %>">
    Submit File
  </a>
  &nbsp;
  <a class="btn btn-secondary"
     href="${pageContext.request.contextPath}/student/submissions.jsp?assignmentId=<%= assignId %>">
    My Submissions
  </a>
  <% } else { %>
  <span class="no-upload">No file submission required for this assignment.</span>
  <% } %>
</div>
<%  }
  if (!hasAssignments) { %>
<p style="color:#9ca3af;">No assignments posted yet.</p>
<% }
  rsAssign.close();
  conn.close();
%>

<a class="back" href="${pageContext.request.contextPath}/student/classes.jsp">
  ← Back to my classes
</a>
</body>
</html>