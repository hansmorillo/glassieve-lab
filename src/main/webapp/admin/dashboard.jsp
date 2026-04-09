<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>glassieve – Admin</title>
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
            margin-bottom: 2.5rem;
        }

        .brand { font-weight: 300; font-size: 1.15rem; letter-spacing: -0.5px; color: #0f172a; }
        .nav-right { font-size: 0.85rem; color: #6b7280; }
        a { color: #2563eb; text-decoration: none; }
        a:hover { text-decoration: underline; }

        .greeting {
            font-size: 1.35rem;
            font-weight: 400;
            color: #0f172a;
            margin-bottom: 0.3rem;
        }

        .greeting-sub {
            font-size: 0.875rem;
            color: #9ca3af;
            margin-bottom: 2rem;
        }

        .card-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0.875rem;
        }

        .card {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            padding: 1.25rem 1.35rem;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            gap: 6px;
            transition: border-color 0.15s, box-shadow 0.15s;
        }

        .card:hover {
            border-color: #2563eb;
            box-shadow: 0 2px 8px rgba(37,99,235,0.07);
            text-decoration: none;
        }

        .card-icon { font-size: 1.25rem; margin-bottom: 4px; }

        .card-title {
            font-size: 0.95rem;
            font-weight: 500;
            color: #0f172a;
        }

        .card-desc {
            font-size: 0.8rem;
            color: #9ca3af;
            line-height: 1.5;
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

<p class="greeting">Welcome back, <%= session.getAttribute("username") %>.</p>
<p class="greeting-sub">Manage student accounts and class enrolments.</p>

<div class="card-grid">
    <a class="card" href="${pageContext.request.contextPath}/admin/students.jsp">
        <div class="card-icon">👥</div>
        <div class="card-title">Students</div>
        <div class="card-desc">View all registered students and their class enrolments.</div>
    </a>
    <a class="card" href="${pageContext.request.contextPath}/admin/add-student.jsp">
        <div class="card-icon">➕</div>
        <div class="card-title">Add Student</div>
        <div class="card-desc">Create a new student account and assign them to classes.</div>
    </a>
</div>
</body>
</html>