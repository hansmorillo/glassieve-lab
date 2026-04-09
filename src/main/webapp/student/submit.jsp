<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
  <title>glassieve – Submit</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      max-width: 560px;
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
      margin-bottom: 6px;
    }

    input[type=file] {
      width: 100%;
      padding: 10px;
      border: 1px dashed #d1d5db;
      border-radius: 6px;
      font-family: inherit;
      font-size: 0.85rem;
      background: #f9fafb;
      margin-bottom: 1.25rem;
      cursor: pointer;
    }

    input[type=file]:hover { border-color: #2563eb; }

    button {
      padding: 9px 24px;
      background: #0f172a;
      color: #f1f5f9;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-family: inherit;
      font-size: 0.88rem;
      font-weight: 500;
      transition: background 0.15s;
    }

    button:hover { background: #1e293b; }

    .error {
      font-size: 0.82rem;
      color: #dc2626;
      background: #fef2f2;
      border: 1px solid #fecaca;
      border-radius: 6px;
      padding: 8px 12px;
      margin-bottom: 1rem;
    }

    .hint {
      font-size: 0.78rem;
      color: #9ca3af;
      margin-top: 0.75rem;
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

  <h2>Submit Assignment</h2>

  <div class="card">
    <% String error = request.getParameter("error");
       if ("1".equals(error)) { %>
      <p class="error">Upload failed. Please try again.</p>
    <% } else if ("2".equals(error)) { %>
      <p class="error">Only .py files are accepted.</p>
    <% } %>

    <form method="post"
          action="${pageContext.request.contextPath}/student/submit"
          enctype="multipart/form-data">
      <input type="hidden" name="assignmentId"
             value="<%= request.getParameter("assignmentId") %>" />
      <label>Select your .py file</label>
      <input type="file" name="file" accept=".py" required />
      <p class="hint">Only .py files are accepted. Maximum size 1 MB.</p>
      <button type="submit">Upload File</button>
    </form>
  </div>

  <a class="back" href="javascript:history.back()">← Back</a>
</body>
</html>
