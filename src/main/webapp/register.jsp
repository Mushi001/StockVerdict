<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Register</title>

    <%-- Read theme BEFORE styles to avoid flash --%>
    <script>
        const t = localStorage.getItem('sv_theme') || 'dark';
        document.documentElement.setAttribute('data-theme', t);
    </script>

    <%-- Iconify theme icons --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/brightness.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/moon.css"/>

    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo2.png"/>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
    <script src="https://www.google.com/recaptcha/api.js" async defer></script>

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:      #00e676;
            --green-dim:  #00c853;
            --green-glow: rgba(0,230,118,0.2);
            --bg-dark:    #040e07;
            --bg-card:    rgba(4,18,9,0.82);
            --bg-panel:   rgba(0,20,8,0.6);
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
            --bg-panel:   rgba(220,245,225,0.85);
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
            padding: 20px;
            position: relative;
            overflow-x: hidden;
            transition: background 0.3s, color 0.3s;
        }

        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image:
                    linear-gradient(rgba(0,230,118,0.04) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(0,230,118,0.04) 1px, transparent 1px);
            background-size: 40px 40px;
            animation: gridShift 25s linear infinite;
            pointer-events: none; z-index: 0;
        }
        [data-theme="light"] body::before {
            background-image:
                    linear-gradient(rgba(0,168,74,0.06) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(0,168,74,0.06) 1px, transparent 1px);
        }
        @keyframes gridShift { 0% { transform: translateY(0); } 100% { transform: translateY(40px); } }

        body::after {
            content: '';
            position: fixed; inset: 0;
            background: repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(0,230,118,0.015) 3px, rgba(0,230,118,0.015) 4px);
            pointer-events: none; z-index: 0;
        }

        .wrapper {
            position: relative; z-index: 10;
            width: 100%; max-width: 900px;
            display: flex;
            box-shadow: 0 0 80px rgba(0,230,118,0.07), 0 30px 80px rgba(0,0,0,0.7);
            border: 1px solid var(--border);
            animation: fadeUp 0.6s ease both;
            margin-top: 30px;
            transition: border-color 0.3s;
        }
        [data-theme="light"] .wrapper { box-shadow: 0 0 40px rgba(0,168,74,0.1), 0 20px 50px rgba(0,0,0,0.15); }
        @keyframes fadeUp { from { opacity: 0; transform: translateY(24px); } to { opacity: 1; transform: translateY(0); } }

        /* ── Left panel ── */
        .left-panel {
            width: 340px; flex-shrink: 0;
            background: linear-gradient(rgba(4,14,7,0.8), rgba(4,14,7,0.85)), url('${pageContext.request.contextPath}/signup.jpg') center/cover;
            border-right: 1px solid var(--border);
            padding: 44px 36px;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            position: relative; overflow: hidden;
            transition: border-color 0.3s;
        }
        [data-theme="light"] .left-panel {
            background: linear-gradient(rgba(240,250,242,0.85), rgba(240,250,242,0.9)), url('${pageContext.request.contextPath}/signup.jpg') center/cover;
        }
        .left-panel::before {
            content: ''; position: absolute;
            width: 260px; height: 260px; border-radius: 50%;
            background: radial-gradient(circle, rgba(0,230,118,0.1) 0%, transparent 70%);
            top: 50%; left: 50%; transform: translate(-50%, -50%);
            pointer-events: none;
        }

        .logo-container { position: relative; z-index: 1; text-align: center; }
        .logo-img-wrap {
            width: 70px; height: 70px; margin: 0 auto 16px;
            border-radius: 50%;
            background: rgba(0,230,118,0.06); border: 2px solid rgba(0,230,118,0.2);
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 0 30px rgba(0,230,118,0.15), 0 0 60px rgba(0,230,118,0.06);
            animation: logoPulse 3s ease infinite; overflow: hidden;
        }
        @keyframes logoPulse {
            0%, 100% { box-shadow: 0 0 20px rgba(0,230,118,0.15), 0 0 40px rgba(0,230,118,0.06); }
            50%       { box-shadow: 0 0 30px rgba(0,230,118,0.28), 0 0 50px rgba(0,230,118,0.1); }
        }
        .logo-img-wrap img { width: 44px; height: 44px; object-fit: contain; }

        .brand-name {
            font-family: 'Rajdhani', sans-serif; font-size: 26px; font-weight: 700;
            color: var(--green); letter-spacing: 0.06em; text-transform: uppercase;
            text-shadow: 0 0 24px rgba(0,230,118,0.4); line-height: 1;
        }
        [data-theme="light"] .brand-name { text-shadow: 0 0 16px rgba(0,168,74,0.3); }
        .brand-line { width: 40px; height: 2px; background: var(--green); margin: 8px auto; box-shadow: 0 0 8px var(--green); }
        .brand-sub { font-size: 10px; letter-spacing: 0.22em; text-transform: uppercase; color: var(--muted); font-family: 'Rajdhani', sans-serif; }

        .back-btn {
            position: absolute; top: 24px; left: 40px;
            font-family: 'Rajdhani', sans-serif; font-size: 12px; font-weight: 600;
            color: var(--muted); text-decoration: none;
            transition: color 0.2s; z-index: 50; text-transform: uppercase; letter-spacing: 0.1em;
        }
        .back-btn:hover { color: var(--green); }
        .feature-item {
            display: flex; align-items: flex-start; gap: 12px;
            padding: 12px 0; border-bottom: 1px solid rgba(0,230,118,0.08);
        }
        .feature-item:last-child { border-bottom: none; }
        .feature-icon {
            width: 32px; height: 32px; border-radius: 7px;
            background: rgba(0,230,118,0.1); border: 1px solid rgba(0,230,118,0.2);
            display: flex; align-items: center; justify-content: center;
            font-size: 15px; flex-shrink: 0;
        }
        .feature-text { flex: 1; }
        .feature-title { font-size: 13px; font-weight: 500; color: var(--text); margin-bottom: 2px; }
        .feature-desc  { font-size: 11px; color: var(--muted); line-height: 1.4; }

        .market-stats {
            margin-top: auto; padding-top: 28px; width: 100%;
            display: flex; gap: 8px;
        }
        .mstat {
            flex: 1; background: rgba(0,230,118,0.05);
            border: 1px solid var(--border); border-radius: 7px;
            padding: 10px 8px; text-align: center;
        }
        .mstat-val { font-family: 'Rajdhani', sans-serif; font-size: 16px; font-weight: 700; color: var(--green); display: block; }
        .mstat-label { font-size: 9px; color: var(--muted); letter-spacing: 0.1em; text-transform: uppercase; }

        /* ── Right panel ── */
        .right-panel {
            flex: 1; background: var(--bg-card); backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px); padding: 44px 40px;
            position: relative; transition: background 0.3s;
        }
        .right-panel::before {
            content: ''; position: absolute; top: -1px; right: -1px;
            width: 14px; height: 14px;
            border: 2px solid var(--green); border-left: 0; border-bottom: 0;
        }
        .right-panel::after {
            content: ''; position: absolute; bottom: -1px; left: -1px;
            width: 14px; height: 14px;
            border: 2px solid var(--green); border-right: 0; border-top: 0;
        }

        .form-header { margin-bottom: 28px; padding-bottom: 18px; border-bottom: 1px solid var(--border); }
        .form-label-top { font-family: 'Rajdhani', sans-serif; font-size: 10px; letter-spacing: 0.25em; text-transform: uppercase; color: var(--green); margin-bottom: 4px; }
        .form-title { font-family: 'Rajdhani', sans-serif; font-size: 24px; font-weight: 600; color: var(--text); letter-spacing: 0.04em; }

        .alert { padding: 10px 14px; margin-bottom: 18px; font-size: 13px; border-left: 3px solid; animation: slideIn 0.3s ease; }
        @keyframes slideIn { from { opacity: 0; transform: translateX(-6px); } to { opacity: 1; transform: translateX(0); } }
        .alert-error   { background: rgba(255,82,82,0.08); border-color: var(--red); color: #ff8a8a; }
        .alert-success { background: rgba(0,230,118,0.08); border-color: var(--green); color: var(--green); }
        [data-theme="light"] .alert-error { color: var(--red); }
        [data-theme="light"] .alert-success { color: var(--green); }

        .form-row { display: flex; gap: 14px; }
        .form-row .field { flex: 1; }
        .field { margin-bottom: 16px; }

        label {
            display: block; font-family: 'Rajdhani', sans-serif; font-size: 11px;
            letter-spacing: 0.2em; text-transform: uppercase; color: var(--muted); margin-bottom: 7px;
        }
        input[type="text"], input[type="email"], input[type="password"], select {
            width: 100%; background: rgba(0,20,8,0.7); border: 1px solid var(--border);
            color: var(--text); font-family: 'Inter', sans-serif; font-size: 14px;
            padding: 11px 14px; outline: none;
            transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
            appearance: none; -webkit-appearance: none; border-radius: 0;
        }
        [data-theme="light"] input[type="text"],
        [data-theme="light"] input[type="email"],
        [data-theme="light"] input[type="password"],
        [data-theme="light"] select {
            background: rgba(220,245,225,0.6); color: var(--text);
        }
        input:focus, select:focus {
            border-color: var(--green); background: rgba(0,30,10,0.8);
            box-shadow: 0 0 0 1px rgba(0,230,118,0.25), inset 0 0 12px rgba(0,230,118,0.04);
        }
        [data-theme="light"] input:focus,
        [data-theme="light"] select:focus { background: rgba(200,240,210,0.8); }
        input::placeholder { color: rgba(90,154,106,0.5); font-size: 13px; }

        .select-wrap { position: relative; }
        .select-wrap::after { content: '▾'; position: absolute; right: 12px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: 14px; pointer-events: none; }
        select option { background: #061409; color: var(--text); }
        [data-theme="light"] select option { background: #fff; color: #0a2e12; }

        .recaptcha-wrap { margin: 14px 0; transform-origin: left top; }
        @media (max-width: 500px) { .recaptcha-wrap { transform: scale(0.85); } }

        .btn-submit {
            width: 100%; background: var(--green); color: #020e05; border: none;
            padding: 14px; font-family: 'Rajdhani', sans-serif; font-size: 14px;
            font-weight: 700; letter-spacing: 0.2em; text-transform: uppercase;
            cursor: pointer; margin-top: 4px;
            box-shadow: 0 4px 20px var(--green-glow);
            transition: background 0.2s, box-shadow 0.2s, transform 0.1s;
        }
        .btn-submit:hover { background: var(--green-dim); box-shadow: 0 4px 28px var(--green-glow); }
        .btn-submit:active { transform: scale(0.99); }

        .divider { display: flex; align-items: center; gap: 12px; margin: 18px 0; font-size: 10px; letter-spacing: 0.15em; color: var(--muted); font-family: 'Rajdhani', sans-serif; }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }

        .footer-link { text-align: center; font-size: 13px; color: var(--muted); }
        .footer-link a { color: var(--green); text-decoration: none; font-weight: 500; transition: text-shadow 0.2s, color 0.2s; }
        .footer-link a:hover { color: var(--green-dim); text-shadow: 0 0 10px var(--green-glow); }

        .status-bar { display: flex; align-items: center; justify-content: center; gap: 8px; margin-top: 18px; font-family: 'Rajdhani', sans-serif; font-size: 11px; letter-spacing: 0.12em; color: var(--muted); }
        .status-dot { width: 7px; height: 7px; border-radius: 50%; background: var(--green); box-shadow: 0 0 8px var(--green); animation: pulse 2s ease infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.4; transform: scale(0.75); } }

        @media (max-width: 720px) {
            .wrapper { flex-direction: column; max-width: 480px; }
            .left-panel { width: 100%; padding: 32px 28px; }
            .features { display: none; }
            .market-stats { margin-top: 20px; padding-top: 20px; }
            .right-panel { padding: 32px 28px; }
            .form-row { flex-direction: column; gap: 0; }
        }
    </style>
</head>
<body>

<%-- Theme toggle button --%>
<button class="btn-theme" id="themeToggle" onclick="toggleTheme()" title="Toggle theme">
    <span id="themeIcon" class="icon-park-twotone--brightness"></span>
</button>

<div class="wrapper">

    <!-- LEFT PANEL -->
    <div class="left-panel">
        <div class="logo-container">
            <div class="logo-img-wrap">
                <img src="${pageContext.request.contextPath}/logo2.png" alt="StockVerdict Logo"/>
            </div>
            <div class="brand-name">StockVerdict</div>
            <div class="brand-line"></div>
            <div class="brand-sub">Intelligent Market Analysis</div>
        </div>
    </div>

    <!-- RIGHT PANEL -->
    <div class="right-panel">
        <a href="javascript:history.back()" class="back-btn">← Back</a>
        <div class="form-header">
            <div class="form-label-top">New Account</div>
            <div class="form-title">Create Your Account</div>
        </div>

        <c:if test="${not empty error}">
            <div class="alert alert-error">⚠ ${error}</div>
        </c:if>
        <c:if test="${not empty success}">
            <div class="alert alert-success">✓ ${success}</div>
        </c:if>
        <% String err = (String) request.getAttribute("error"); %>
        <% if (err != null) { %>
        <div class="alert alert-error">⚠ <%= err %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/user" method="post">
            <input type="hidden" name="action" value="register"/>

            <div class="field">
                <label for="name">Full Name</label>
                <input type="text" id="name" name="name" placeholder="John Smith" required/>
            </div>

            <div class="field">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" placeholder="trader@example.com" required/>
            </div>
            <div class="field">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" placeholder="Create a strong password" required/>
            </div>
            <div class="field">
                <label for="confirm">Confirm Password</label>
                <input type="password" id="confirm" name="confirm" placeholder="Re-enter your password" required/>
            </div>

            <div class="recaptcha-wrap">
                <div class="g-recaptcha"
                     data-sitekey="6LeuOnosAAAAAJW_PUdg221dMEq5Xokfbn0SVO5y"
                     data-theme="dark"></div>
            </div>

            <button type="submit" class="btn-submit">CREATE ACCOUNT →</button>
        </form>

        <div class="divider">or</div>
        <div class="footer-link">Already have an account? <a href="${pageContext.request.contextPath}/login.jsp">Sign in</a></div>

        <div class="status-bar">
            <div class="status-dot"></div>
            Secure Registration &nbsp;·&nbsp; 256-bit SSL Encrypted
        </div>
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