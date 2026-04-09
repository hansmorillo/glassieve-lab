<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.portal.util.DBConnection" %>
<%
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Resolve studentId
    int studentId = 0;
    Object idObj = session.getAttribute("userId");
    if (idObj != null) {
        studentId = (int) idObj;
    } else {
        String username = (String) session.getAttribute("username");
        try (Connection c = DBConnection.get()) {
            PreparedStatement psu = c.prepareStatement(
                    "SELECT id FROM users WHERE username = ?"
            );
            psu.setString(1, username);
            ResultSet ru = psu.executeQuery();
            if (ru.next()) {
                studentId = ru.getInt("id");
                session.setAttribute("userId", studentId);
            }
        }
    }

    // Optional assignment filter
    int assignmentId = -1;
    String assignmentTitle = "My Submissions";
    try {
        assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
    } catch (NumberFormatException e) { /* show all */ }

    Connection conn = DBConnection.get();

    // Load assignment title if scoped to a specific assignment
    if (assignmentId > 0) {
        PreparedStatement psA = conn.prepareStatement(
                "SELECT title FROM assignments WHERE id = ?"
        );
        psA.setInt(1, assignmentId);
        ResultSet rsA = psA.executeQuery();
        if (rsA.next()) assignmentTitle = rsA.getString("title");
        rsA.close();
    }

    // Build query — filtered by assignment or show all
    PreparedStatement ps;
    if (assignmentId > 0) {
        ps = conn.prepareStatement(
                "SELECT s.id, s.filename, s.submitted_at, g.score, g.comments " +
                        "FROM submissions s " +
                        "LEFT JOIN grades g ON g.submission_id = s.id " +
                        "WHERE s.student_id = ? AND s.assignment_id = ? " +
                        "ORDER BY s.submitted_at DESC"
        );
        ps.setInt(1, studentId);
        ps.setInt(2, assignmentId);
    } else {
        ps = conn.prepareStatement(
                "SELECT s.id, s.filename, s.submitted_at, g.score, g.comments " +
                        "FROM submissions s " +
                        "LEFT JOIN grades g ON g.submission_id = s.id " +
                        "WHERE s.student_id = ? " +
                        "ORDER BY s.submitted_at DESC"
        );
        ps.setInt(1, studentId);
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
            max-width: 820px;
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

        .success {
            font-size: 0.85rem;
            color: #16a34a;
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 6px;
            padding: 8px 12px;
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

        .empty {
            text-align: center;
            padding: 2.5rem;
            color: #9ca3af;
            font-size: 0.875rem;
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
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

<h2><%= assignmentTitle %></h2>

<% if ("1".equals(request.getParameter("submitted"))) { %>
<p class="success">File uploaded successfully.</p>
<% } %>

<div class="table-wrap">
    <table>
    <thead>
    <tr>
        <th>#</th>
        <th>File</th>
        <th>Submitted</th>
        <th>Status</th>
        <th>Score</th>
        <th>Comments</th>
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
        <td><%= rs.getString("filename") %></td>
        <td><span class="local-time" data-utc="<%= rs.getTimestamp("submitted_at") %>"></span></td>
        <td>
          <span class="badge <%= graded ? "badge-graded" : "badge-pending" %>">
            <%= graded ? "Graded" : "Pending" %>
          </span>
        </td>
        <td><%= graded ? rs.getInt("score") + " / 100" : "–" %></td>
        <td><%= graded && rs.getString("comments") != null ? rs.getString("comments") : "–" %></td>
    </tr>
    <%  } %>
    </tbody>
    </table>
</div>

<% if (!hasRows) { %>
<p class="empty">No submissions yet.</p>
<% } %>

<% rs.close(); conn.close(); %>

<a class="back" href="javascript:history.back()">← Back</a>

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