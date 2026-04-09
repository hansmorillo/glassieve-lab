<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.portal.util.DBConnection" %>
<%
  if (session == null) {
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
  }

  int classId = -1;
  String className = "";
  String classCode = "";
  try {
    classId = Integer.parseInt(request.getParameter("classId"));
  } catch (NumberFormatException e) { /* show all */ }

  Connection conn = DBConnection.get();

  if (classId > 0) {
    PreparedStatement psC = conn.prepareStatement(
            "SELECT code, name FROM classes WHERE id = ?"
    );
    psC.setInt(1, classId);
    ResultSet rsC = psC.executeQuery();
    if (rsC.next()) {
      classCode = rsC.getString("code");
      className = rsC.getString("name");
    }
    rsC.close();
  }

  PreparedStatement ps;
  if (classId > 0) {
    ps = conn.prepareStatement(
            "SELECT s.id, u.username, s.filename, s.submitted_at, g.score, a.title " +
                    "FROM submissions s " +
                    "JOIN users u ON s.student_id = u.id " +
                    "JOIN assignments a ON s.assignment_id = a.id " +
                    "LEFT JOIN grades g ON g.submission_id = s.id " +
                    "WHERE a.class_id = ? " +
                    "ORDER BY s.submitted_at DESC"
    );
    ps.setInt(1, classId);
  } else {
    ps = conn.prepareStatement(
            "SELECT s.id, u.username, s.filename, s.submitted_at, g.score, a.title " +
                    "FROM submissions s " +
                    "JOIN users u ON s.student_id = u.id " +
                    "JOIN assignments a ON s.assignment_id = a.id " +
                    "LEFT JOIN grades g ON g.submission_id = s.id " +
                    "ORDER BY s.submitted_at DESC"
    );
  }
  ResultSet rs = ps.executeQuery();
  boolean hasRows = false;
%>
<!DOCTYPE html>
<html>
<head>
  <title>glassieve – Submissions</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      max-width: 1000px;
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
      margin-bottom: 1.25rem;
    }

    .breadcrumb a { color: #6b7280; }

    h2 {
      font-weight: 400;
      font-size: 1.35rem;
      color: #0f172a;
      margin-bottom: 1.25rem;
    }

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

    .badge {
      display: inline-block;
      padding: 2px 10px;
      border-radius: 99px;
      font-size: 0.75rem;
      font-weight: 500;
    }

    .badge-pending { background: #fef9c3; color: #854d0e; }
    .badge-graded  { background: #dcfce7; color: #166534; }

    .btn {
      display: inline-block;
      padding: 5px 14px;
      background: #0f172a;
      color: #f1f5f9;
      border-radius: 5px;
      font-size: 0.78rem;
      font-weight: 500;
      text-decoration: none;
      transition: background 0.15s;
    }

    .btn:hover { background: #1e293b; color: #f1f5f9; }

    .empty {
      text-align: center;
      padding: 2.5rem;
      color: #9ca3af;
      font-size: 0.875rem;
      background: white;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      margin-top: 0;
    }

    .back {
      font-size: 0.85rem;
      margin-top: 1.25rem;
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

<% if (classId > 0) { %>
<div class="breadcrumb">
  <a href="${pageContext.request.contextPath}/lecturer/classes.jsp">My Classes</a>
  &rsaquo; <%= classCode %>
</div>
<% } %>

<h2><%= classCode.isEmpty() ? "All Submissions" : classCode + " — " + className %></h2>

<% if (hasRows || true) { %>
<div class="table-wrap">
  <table>
    <thead>
    <tr>
      <th>#</th>
      <th>Student</th>
      <th>Assignment</th>
      <th>File</th>
      <th>Submitted</th>
      <th>Status</th>
      <th>Action</th>
    </tr>
    </thead>
    <tbody>
    <%
      while (rs.next()) {
        hasRows = true;
        boolean graded = rs.getObject("score") != null;
    %>
    <tr>
      <td><%= rs.getInt("id") %></td>
      <td><%= rs.getString("username") %></td>
      <td><%= rs.getString("title") %></td>
      <td><%= rs.getString("filename") %></td>
      <td><span class="local-time" data-utc="<%= rs.getTimestamp("submitted_at") %>"></span></td>
      <td>
          <span class="badge <%= graded ? "badge-graded" : "badge-pending" %>">
            <%= graded ? "Graded" : "Pending" %>
          </span>
      </td>
      <td>
        <a class="btn"
           href="${pageContext.request.contextPath}/lecturer/grade.jsp?id=<%= rs.getInt("id") %>">
          View &amp; Mark
        </a>
      </td>
    </tr>
    <%  } %>
    </tbody>
  </table>
</div>
<% } %>

<% if (!hasRows) { %>
<p class="empty">No submissions yet.</p>
<% } %>

<% rs.close(); conn.close(); %>

<a class="back" href="${pageContext.request.contextPath}/lecturer/classes.jsp">
  ← Back to my classes
</a>

<script>
  document.querySelectorAll('.local-time').forEach(function(el) {
    var utc = el.getAttribute('data-utc');
    if (!utc) return;
    var date = new Date(utc.replace(' ', 'T') + 'Z');
    el.textContent = date.toLocaleString([], {
      year: 'numeric', month: 'short', day: 'numeric',
      hour: '2-digit', minute: '2-digit'
    });
  });
</script>
</body>
</html>