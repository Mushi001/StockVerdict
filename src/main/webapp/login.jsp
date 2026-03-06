<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Login</title>

    <%-- Read theme BEFORE styles to avoid flash --%>
    <script>
        const t = localStorage.getItem('sv_theme') || 'dark';
        document.documentElement.setAttribute('data-theme', t);
    </script>

    <%-- Iconify theme icons --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/brightness.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/moon.css"/>

    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:      #00e676;
            --green-dim:  #00c853;
            --green-glow: rgba(0,230,118,0.2);
            --bg-dark:    #040e07;
            --bg-card:    rgba(4,18,9,0.82);
            --border:     rgba(0,230,118,0.22);
            --text:       #e4ffe4;
            --muted:      #5a9a6a;
            --red:        #ff5252;
        }
        [data-theme="light"] {
            --green:      #00a84a;
            --green-dim:  #007a35;
            --green-glow: rgba(0,168,74,0.15);
            --bg-dark:    #f0faf2;
            --bg-card:    rgba(255,255,255,0.95);
            --border:     rgba(0,180,80,0.3);
            --text:       #0a2e12;
            --muted:      #4a8a5a;
            --red:        #d32f2f;
        }
        [data-theme="light"] .icon-park-twotone--brightness,
        [data-theme="light"] .stash--moon {
            filter: invert(1) brightness(0.3) sepia(1) hue-rotate(90deg) saturate(4);
        }

        /* ── Theme toggle ── */
        .btn-theme {
            position: fixed; top: 16px; right: 20px; z-index: 200;
            width: 36px; height: 36px;
            background: var(--bg-card); border: 1px solid var(--border);
            color: var(--muted); cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            backdrop-filter: blur(10px);
            transition: border-color 0.2s, color 0.2s;
        }
        .btn-theme:hover { border-color: var(--green); color: var(--green); }
        .icon-park-twotone--brightness,
        .stash--moon { width: 18px !important; height: 18px !important; }

        html { scroll-behavior: smooth; }
        body {
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Inter', sans-serif;
            background: var(--bg-dark);
            overflow: hidden; position: relative;
            transition: background 0.3s, color 0.3s;
        }

        .bg-image {
            position: fixed; inset: 0;
            background-image: url('stock-bg.jpg');
            background-size: cover; background-position: center;
            filter: brightness(0.38) saturate(1.3);
            z-index: 0;
            transition: filter 0.3s;
        }
        [data-theme="light"] .bg-image { filter: brightness(0.55) saturate(0.8); }

        .bg-overlay {
            position: fixed; inset: 0;
            background: linear-gradient(135deg, rgba(0,10,4,0.72) 0%, rgba(0,20,8,0.55) 50%, rgba(0,10,4,0.72) 100%);
            z-index: 1;
        }
        [data-theme="light"] .bg-overlay {
            background: linear-gradient(135deg, rgba(220,245,225,0.82) 0%, rgba(240,250,242,0.75) 50%, rgba(220,245,225,0.82) 100%);
        }
        .bg-overlay::after {
            content: ''; position: fixed; inset: 0;
            background: repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(0,230,118,0.018) 3px, rgba(0,230,118,0.018) 4px);
            pointer-events: none;
        }

        .page {
            position: relative; z-index: 10;
            width: 100%; max-width: 480px; padding: 20px;
            animation: fadeUp 0.5s ease both;
        }
        @keyframes fadeUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        .brand { text-align: center; margin-bottom: 28px; }
        .brand-name {
            font-family: 'Rajdhani', sans-serif; font-size: 44px; font-weight: 700;
            color: var(--green); letter-spacing: 0.06em; text-transform: uppercase; line-height: 1;
            text-shadow: 0 0 32px rgba(0,230,118,0.5), 0 0 60px rgba(0,230,118,0.2);
        }
        [data-theme="light"] .brand-name { text-shadow: 0 0 20px rgba(0,168,74,0.3); }
        .brand-line { width: 60px; height: 2px; background: var(--green); margin: 8px auto 10px; box-shadow: 0 0 10px var(--green); }
        .brand-sub { font-size: 11px; letter-spacing: 0.25em; text-transform: uppercase; color: var(--muted); font-family: 'Rajdhani', sans-serif; }

        .card {
            background: var(--bg-card); border: 1px solid var(--border);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            padding: 38px 40px 34px; position: relative;
            box-shadow: 0 0 60px rgba(0,230,118,0.06), 0 24px 60px rgba(0,0,0,0.6);
            transition: background 0.3s, border-color 0.3s;
        }
        .card::before { content: ''; position: absolute; top: -1px; left: -1px; width: 14px; height: 14px; border: 2px solid var(--green); border-right: 0; border-bottom: 0; }
        .card::after  { content: ''; position: absolute; bottom: -1px; right: -1px; width: 14px; height: 14px; border: 2px solid var(--green); border-left: 0; border-top: 0; }

        .card-header { margin-bottom: 28px; padding-bottom: 18px; border-bottom: 1px solid var(--border); }
        .card-label { font-family: 'Rajdhani', sans-serif; font-size: 10px; letter-spacing: 0.25em; text-transform: uppercase; color: var(--green); margin-bottom: 4px; }
        .card-title { font-family: 'Rajdhani', sans-serif; font-size: 26px; font-weight: 600; color: var(--text); letter-spacing: 0.04em; }

        .alert { padding: 10px 14px; margin-bottom: 20px; font-size: 13px; border-left: 3px solid; animation: slideIn 0.3s ease; }
        @keyframes slideIn { from { opacity: 0; transform: translateX(-6px); } to { opacity: 1; transform: translateX(0); } }
        .alert-error   { background: rgba(255,82,82,0.08); border-color: var(--red); color: #ff8a8a; }
        .alert-success { background: rgba(0,230,118,0.08); border-color: var(--green); color: var(--green); }
        [data-theme="light"] .alert-error { color: var(--red); }
        [data-theme="light"] .alert-success { color: var(--green); }

        .field { margin-bottom: 20px; }
        label {
            display: block; font-family: 'Rajdhani', sans-serif; font-size: 11px;
            letter-spacing: 0.2em; text-transform: uppercase; color: var(--muted); margin-bottom: 7px;
        }
        input[type="email"], input[type="password"] {
            width: 100%; background: rgba(0,20,8,0.7); border: 1px solid var(--border);
            color: var(--text); font-family: 'Inter', sans-serif; font-size: 14px;
            padding: 12px 15px; outline: none;
            transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
        }
        [data-theme="light"] input[type="email"],
        [data-theme="light"] input[type="password"] {
            background: rgba(220,245,225,0.6);
            color: var(--text);
        }
        input[type="email"]:focus, input[type="password"]:focus {
            border-color: var(--green); background: rgba(0,30,10,0.8);
            box-shadow: 0 0 0 1px rgba(0,230,118,0.25), inset 0 0 12px rgba(0,230,118,0.04);
        }
        [data-theme="light"] input:focus { background: rgba(200,240,210,0.8); }
        input::placeholder { color: rgba(90,154,106,0.5); font-size: 13px; }

        .btn {
            width: 100%; background: var(--green); color: #020e05; border: none;
            font-family: 'Rajdhani', sans-serif; font-size: 14px; font-weight: 700;
            letter-spacing: 0.2em; text-transform: uppercase; padding: 14px; cursor: pointer;
            margin-top: 6px; box-shadow: 0 4px 20px var(--green-glow);
            transition: background 0.2s, box-shadow 0.2s, transform 0.1s;
        }
        .btn:hover { background: var(--green-dim); box-shadow: 0 4px 28px var(--green-glow); }
        .btn:active { transform: scale(0.99); }

        .divider { display: flex; align-items: center; gap: 12px; margin: 22px 0; font-size: 10px; letter-spacing: 0.15em; color: var(--muted); font-family: 'Rajdhani', sans-serif; }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }

        .footer-link { text-align: center; font-size: 13px; color: var(--muted); }
        .footer-link a { color: var(--green); text-decoration: none; font-weight: 500; transition: text-shadow 0.2s, color 0.2s; }
        .footer-link a:hover { color: var(--green-dim); text-shadow: 0 0 10px var(--green-glow); }

        .status-bar { display: flex; align-items: center; justify-content: center; gap: 8px; margin-top: 20px; font-family: 'Rajdhani', sans-serif; font-size: 11px; letter-spacing: 0.12em; color: var(--muted); }
        .status-dot { width: 7px; height: 7px; border-radius: 50%; background: var(--green); box-shadow: 0 0 8px var(--green); animation: pulse 2s ease infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.4; transform: scale(0.75); } }
    </style>
</head>
<body>

<div class="bg-image"></div>
<div class="bg-overlay"></div>

<%-- Theme toggle button --%>
<button class="btn-theme" id="themeToggle" onclick="toggleTheme()" title="Toggle theme">
    <span id="themeIcon" class="icon-park-twotone--brightness"></span>
</button>

<div class="page">
    <div class="brand">
        <div class="brand-name">StockVerdict</div>
        <div class="brand-line"></div>
        <div class="brand-sub">Intelligent Market Analysis</div>
    </div>
    <div class="card">
        <div class="card-header">
            <div class="card-label">Secure Access</div>
            <div class="card-title">Sign In to Your Account</div>
        </div>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <div class="alert alert-error">⚠ <%= error %></div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-error">⚠ Invalid email or password. Please try again.</div>
        <% } %>
        <% String success = request.getParameter("success"); %>
        <% if ("registered".equals(success)) { %>
        <div class="alert alert-success">✓ Account created successfully. You can now sign in.</div>
        <% } else if ("loggedout".equals(success)) { %>
        <div class="alert alert-success">✓ You have been signed out securely.</div>
        <% } %>

        <form action="user" method="post">
            <input type="hidden" name="action" value="login"/>
            <div class="field">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" placeholder="trader@example.com" required/>
            </div>
            <div class="field">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="••••••••" required/>
            </div>
            <button type="submit" class="btn">ACCESS ACCOUNT →</button>
        </form>

        <div class="divider">or</div>
        <div class="footer-link">New to StockVerdict? <a href="register.jsp">Create an account</a></div>
    </div>
    <div class="status-bar">
        <div class="status-dot"></div>
        Markets Live &nbsp;·&nbsp; NYSE &nbsp;·&nbsp; NASDAQ &nbsp;·&nbsp; LSE
    </div>
</div>

<script>
    const THEME_KEY = 'sv_theme';
    const themeIcon = document.getElementById('themeIcon');

    function applyTheme(t) {
        document.documentElement.setAttribute('data-theme', t);
        themeIcon.className = t === 'dark' ? 'icon-park-twotone--brightness' : 'stash--moon';
        localStorage.setItem(THEME_KEY, t);
    }
    function toggleTheme() {
        const cur = document.documentElement.getAttribute('data-theme') || 'dark';
        applyTheme(cur === 'dark' ? 'light' : 'dark');
    }
    applyTheme(localStorage.getItem(THEME_KEY) || 'dark');
</script>
</body>
</html>