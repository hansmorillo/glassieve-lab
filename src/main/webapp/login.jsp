<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
  <title>glassieve – Login</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500&display=swap" rel="stylesheet">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      display: flex;
      min-height: 100vh;
      background: #f8f9fb;
    }

    .left-panel {
      width: 380px;
      min-height: 100vh;
      background: #0f172a;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      padding: 3rem 2.5rem;
      flex-shrink: 0;
    }

    .left-panel .portal-name {
      font-size: 1.3rem;
      font-weight: 300;
      letter-spacing: -0.5px;
      color: #f1f5f9;
    }

    .left-panel .tagline {
      color: #64748b;
      font-size: 0.85rem;
      line-height: 1.6;
      margin-top: 0.5rem;
    }

    .left-panel .footer-note {
      font-size: 0.75rem;
      color: #334155;
    }

    .right-panel {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }

    .box {
      background: white;
      padding: 2.5rem;
      border-radius: 12px;
      border: 1px solid #e5e7eb;
      width: 100%;
      max-width: 360px;
    }

    h2 {
      font-weight: 400;
      font-size: 1.4rem;
      letter-spacing: -0.3px;
      margin-bottom: 0.4rem;
      color: #0f172a;
    }

    .form-subtitle {
      font-size: 0.85rem;
      color: #9ca3af;
      margin-bottom: 1.75rem;
    }

    label {
      display: block;
      font-size: 0.8rem;
      font-weight: 500;
      color: #374151;
      margin-bottom: 5px;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }

    input {
      width: 100%;
      padding: 9px 12px;
      margin-bottom: 1.1rem;
      border: 1px solid #e5e7eb;
      border-radius: 6px;
      font-family: inherit;
      font-size: 0.9rem;
      color: #111;
      transition: border-color 0.15s;
    }

    input:focus {
      outline: none;
      border-color: #2563eb;
    }

    button {
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
      letter-spacing: 0.02em;
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
      margin-bottom: 1.25rem;
    }

    @media (max-width: 640px) {
      .left-panel { display: none; }
    }
  </style>
</head>
<body>
<div class="left-panel">
  <div>
    <div class="portal-name">glassieve</div>
    <div class="tagline">Assignment submission portal for students and staff.</div>
  </div>
  <div class="footer-note">For technical issues, contact your system administrator.</div>
</div>

<div class="right-panel">
  <div class="box">
    <h2>Sign in</h2>
    <p class="form-subtitle">Enter your institutional credentials to continue.</p>

    <% if ("1".equals(request.getParameter("error"))) { %>
    <p class="error">Invalid username or password.</p>
    <% } %>

    <form method="post" action="${pageContext.request.contextPath}/login">
      <label>Username</label>
      <input type="text" name="username" required autofocus />
      <label>Password</label>
      <input type="password" name="password" required />
      <button type="submit">Continue</button>
    </form>
  </div>
</div>
</body>
</html>
