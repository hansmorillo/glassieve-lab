<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="com.portal.util.DBConnection" %>
<%
    if (session == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int subId;
    try {
        subId = Integer.parseInt(request.getParameter("id"));
    } catch (NumberFormatException e) {
        response.sendRedirect(request.getContextPath() + "/lecturer/submissions.jsp");
        return;
    }

    String studentName      = "";
    String filename         = "";
    String filePath         = "";
    String fileContent      = "";
    String execOutput       = "";
    boolean justRan         = "1".equals(request.getParameter("ran"));
    boolean alreadyGraded   = false;
    int existingScore       = 0;
    String existingComments = "";

    Connection conn = DBConnection.get();

    PreparedStatement ps = conn.prepareStatement(
            "SELECT s.filename, s.file_path, u.username " +
                    "FROM submissions s JOIN users u ON s.student_id = u.id " +
                    "WHERE s.id = ?"
    );
    ps.setInt(1, subId);
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        filename    = rs.getString("filename");
        filePath    = rs.getString("file_path");
        studentName = rs.getString("username");
    }
    rs.close();

    try {
        fileContent = new String(Files.readAllBytes(Paths.get(filePath)));
    } catch (Exception e) {
        fileContent = "(could not read file: " + e.getMessage() + ")";
    }

    PreparedStatement ps2 = conn.prepareStatement(
            "SELECT score, comments, exec_output FROM grades " +
                    "WHERE submission_id = ? ORDER BY graded_at DESC LIMIT 1"
    );
    ps2.setInt(1, subId);
    ResultSet rs2 = ps2.executeQuery();
    if (rs2.next()) {
        alreadyGraded    = true;
        existingScore    = rs2.getInt("score");
        existingComments = rs2.getString("comments") != null ? rs2.getString("comments") : "";
        execOutput       = rs2.getString("exec_output") != null ? rs2.getString("exec_output") : "";
    }
    rs2.close();
    conn.close();

    String sessionOutput = (String) session.getAttribute("execOutput_" + subId);
    if (sessionOutput != null) {
        execOutput = sessionOutput;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>glassieve – Grade Submission</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            max-width: 860px;
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

        .page-header { margin-bottom: 1.75rem; }

        h2 {
            font-weight: 400;
            font-size: 1.35rem;
            color: #0f172a;
            margin-bottom: 4px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .meta { color: #9ca3af; font-size: 0.85rem; }

        .badge-graded {
            display: inline-block;
            padding: 2px 10px;
            border-radius: 99px;
            background: #dcfce7;
            color: #166534;
            font-size: 0.75rem;
            font-weight: 500;
        }

        .section-label {
            font-size: 0.72rem;
            font-weight: 500;
            color: #9ca3af;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            margin-bottom: 8px;
        }

        .code-block {
            background: #1e1e2e;
            color: #cdd6f4;
            padding: 1.25rem;
            border-radius: 10px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.8rem;
            line-height: 1.65;
            white-space: pre-wrap;
            word-break: break-all;
            margin-bottom: 1.25rem;
            max-height: 380px;
            overflow-y: auto;
        }

        .exec-block {
            background: #0f172a;
            color: #94a3b8;
            padding: 1rem 1.25rem;
            border-radius: 8px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.8rem;
            line-height: 1.65;
            white-space: pre-wrap;
            word-break: break-all;
            margin-top: 1rem;
        }

        .card {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            padding: 1.35rem 1.5rem;
            margin-bottom: 1rem;
        }

        .card-title {
            font-size: 0.95rem;
            font-weight: 500;
            color: #0f172a;
            margin-bottom: 4px;
        }

        .card-desc {
            font-size: 0.82rem;
            color: #9ca3af;
            margin-bottom: 1rem;
            line-height: 1.5;
        }

        .output-pending {
            font-size: 0.82rem;
            color: #9ca3af;
            font-style: italic;
            margin-top: 0.75rem;
        }

        label {
            display: block;
            font-size: 0.78rem;
            font-weight: 500;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            margin-bottom: 6px;
        }

        input[type=number] {
            width: 130px;
            padding: 8px 10px;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            font-family: inherit;
            font-size: 0.9rem;
            margin-bottom: 1rem;
        }

        input[type=number]:focus { outline: none; border-color: #2563eb; }

        textarea {
            width: 100%;
            padding: 9px 10px;
            border: 1px solid #e5e7eb;
            border-radius: 6px;
            font-family: inherit;
            font-size: 0.875rem;
            resize: vertical;
            margin-bottom: 1rem;
            line-height: 1.5;
        }

        textarea:focus { outline: none; border-color: #2563eb; }

        .current-score {
            font-size: 0.85rem;
            color: #6b7280;
            margin-bottom: 1rem;
        }

        .btn-run {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 9px 20px;
            background: #0f766e;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-family: inherit;
            font-size: 0.875rem;
            font-weight: 500;
            transition: background 0.15s;
        }

        .btn-run:hover { background: #0d6b63; }

        .btn-save {
            display: inline-block;
            padding: 9px 24px;
            background: #0f172a;
            color: #f1f5f9;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-family: inherit;
            font-size: 0.875rem;
            font-weight: 500;
            transition: background 0.15s;
        }

        .btn-save:hover { background: #1e293b; }

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

<div class="page-header">
    <h2>
        <%= filename %>
        <% if (alreadyGraded) { %>
        <span class="badge-graded">Graded</span>
        <% } %>
    </h2>
    <p class="meta">Submitted by <strong style="color:#374151"><%= studentName %></strong></p>
</div>

<p class="section-label">Submitted code</p>
<div class="code-block"><%= fileContent %></div>

<!-- Run Code card -->
<div class="card">
    <div class="card-title">Test execution</div>
    <div class="card-desc">
        Run the submitted code on the server to verify its output before grading.
    </div>
    <form method="post" action="${pageContext.request.contextPath}/lecturer/grade">
        <input type="hidden" name="submissionId" value="<%= subId %>" />
        <input type="hidden" name="action" value="run" />
        <button type="submit" class="btn-run">&#9654;&nbsp; Run Code</button>
    </form>

    <% if (justRan || alreadyGraded) { %>
    <div class="exec-block"><%= execOutput.isEmpty() ? "(no output)" : execOutput %></div>
    <% } else { %>
    <p class="output-pending">No output yet — click Run Code to execute.</p>
    <% } %>
</div>

<!-- Save Grade card -->
<div class="card">
    <div class="card-title"><%= alreadyGraded ? "Update grade" : "Grade this submission" %></div>
    <% if (alreadyGraded) { %>
    <p class="current-score">Current score: <strong><%= existingScore %> / 100</strong></p>
    <% } else { %>
    <div class="card-desc">Enter a score and optional comments, then save.</div>
    <% } %>
    <form method="post" action="${pageContext.request.contextPath}/lecturer/grade">
        <input type="hidden" name="submissionId" value="<%= subId %>" />
        <input type="hidden" name="action" value="save" />
        <label>Score (0 – 100)</label>
        <input type="number" name="score" min="0" max="100"
               value="<%= alreadyGraded ? existingScore : "" %>" required />
        <label>Comments</label>
        <textarea name="comments" rows="4"><%= alreadyGraded ? existingComments : "" %></textarea>
        <button type="submit" class="btn-save">Save Grade</button>
    </form>
</div>

<a class="back" href="${pageContext.request.contextPath}/lecturer/submissions.jsp">
    ← Back to all submissions
</a>
</body>
</html>