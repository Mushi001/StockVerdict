<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Verify OTP</title>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green:      #00e676;
            --green-dim:  #00c853;
            --green-glow: rgba(0,230,118,0.22);
            --bg:         #040e07;
            --bg-card:    rgba(4,18,9,0.85);
            --border:     rgba(0,230,118,0.22);
            --text:       #e4ffe4;
            --text-sub:   #a8d4b0;
            --muted:      #5a9a6a;
            --surface:    rgba(0,20,8,0.6);
            --red:        #ff5252;
        }
        [data-theme="light"] {
            --bg:         #f0faf2;
            --bg-card:    rgba(255,255,255,0.92);
            --border:     rgba(0,180,80,0.2);
            --text:       #0a2e12;
            --text-sub:   #2d6e3e;
            --muted:      #4a8a5a;
            --surface:    rgba(220,245,225,0.7);
            --green:      #00a84a;
            --green-dim:  #007a35;
        }
        body {
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--text);
            overflow: hidden; position: relative;
            transition: background 0.3s, color 0.3s;
        }
        .bg-image {
            position: fixed; inset: 0;
            background-image: url('stock-bg.jpg');
            background-size: cover; background-position: center;
            filter: brightness(0.38) saturate(1.3);
            z-index: 0;
        }
        .bg-overlay {
            position: fixed; inset: 0;
            background: linear-gradient(135deg, rgba(0,10,4,0.72) 0%, rgba(0,20,8,0.55) 50%, rgba(0,10,4,0.72) 100%);
            z-index: 1;
        }
        .bg-overlay::after {
            content: ''; position: fixed; inset: 0;
            background: repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(0,230,118,0.018) 3px, rgba(0,230,118,0.018) 4px);
            pointer-events: none;
        }
        .ticker {
            position: fixed; top: 0; left: 0; right: 0;
            background: rgba(0,230,118,0.1); border-bottom: 1px solid var(--border);
            font-family: 'Rajdhani', sans-serif; font-size: 12px; font-weight: 600;
            letter-spacing: 0.08em; padding: 5px 0; overflow: hidden;
            z-index: 100; backdrop-filter: blur(6px);
        }
        .ticker-inner { display: flex; white-space: nowrap; animation: ticker 28s linear infinite; }
        .ticker-item { padding: 0 28px; }
        .ticker-item.up   { color: var(--green); }
        .ticker-item.down { color: #ff6b6b; }
        @keyframes ticker { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }

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
        .brand-line { width: 60px; height: 2px; background: var(--green); margin: 8px auto 10px; box-shadow: 0 0 10px var(--green); }
        .brand-sub { font-size: 11px; letter-spacing: 0.25em; text-transform: uppercase; color: var(--muted); font-family: 'Rajdhani', sans-serif; }

        .card {
            background: var(--bg-card); border: 1px solid var(--border);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            padding: 38px 40px 34px; position: relative;
            box-shadow: 0 0 60px rgba(0,230,118,0.06), 0 24px 60px rgba(0,0,0,0.6);
        }
        .card::before { content: ''; position: absolute; top: -1px; left: -1px; width: 14px; height: 14px; border: 2px solid var(--green); border-right: 0; border-bottom: 0; }
        .card::after  { content: ''; position: absolute; bottom: -1px; right: -1px; width: 14px; height: 14px; border: 2px solid var(--green); border-left: 0; border-top: 0; }

        .card-header { margin-bottom: 28px; padding-bottom: 18px; border-bottom: 1px solid var(--border); }
        .card-label { font-family: 'Rajdhani', sans-serif; font-size: 10px; letter-spacing: 0.25em; text-transform: uppercase; color: var(--green); margin-bottom: 4px; }
        .card-title { font-family: 'Rajdhani', sans-serif; font-size: 26px; font-weight: 600; color: var(--text); letter-spacing: 0.04em; }
        .card-subtitle { margin-top: 10px; font-size: 13px; line-height: 1.55; color: var(--muted); }

        .alert { padding: 10px 14px; margin-bottom: 20px; font-size: 13px; border-left: 3px solid; animation: slideIn 0.3s ease; }
        @keyframes slideIn { from { opacity: 0; transform: translateX(-6px); } to { opacity: 1; transform: translateX(0); } }
        .alert-error   { background: rgba(255,82,82,0.08); border-color: var(--red); color: #ff8a8a; }
        .alert-success { background: rgba(0,230,118,0.08); border-color: var(--green); color: var(--green); }

        .field { margin-bottom: 18px; }
        label { display: block; font-family: 'Rajdhani', sans-serif; font-size: 11px; letter-spacing: 0.2em; text-transform: uppercase; color: var(--muted); margin-bottom: 7px; }
        input[type="text"] {
            width: 100%; background: var(--surface); border: 1px solid var(--border);
            color: var(--text); font-family: 'Inter', sans-serif; font-size: 16px;
            padding: 12px 15px; outline: none;
            transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
        }
        input[type="text"]:focus {
            border-color: var(--green);
            box-shadow: 0 0 0 1px var(--green-glow), inset 0 0 12px var(--green-glow);
        }
        input::placeholder { color: rgba(90,154,106,0.5); font-size: 13px; }
        .hint { margin-top: 8px; font-size: 12px; color: rgba(90,154,106,0.75); }

        .btn {
            width: 100%; background: var(--green); color: #020e05; border: none;
            font-family: 'Rajdhani', sans-serif; font-size: 14px; font-weight: 700;
            letter-spacing: 0.2em; text-transform: uppercase; padding: 14px; cursor: pointer;
            margin-top: 6px; box-shadow: 0 4px 20px rgba(0,230,118,0.3);
            transition: background 0.2s, box-shadow 0.2s, transform 0.1s;
        }
        .btn:hover { background: #1ffb85; box-shadow: 0 4px 28px rgba(0,230,118,0.5); }
        .btn:active { transform: scale(0.99); }

        .footer-link { text-align: center; font-size: 13px; color: var(--muted); margin-top: 18px; }
        .footer-link a { color: var(--green); text-decoration: none; font-weight: 500; transition: text-shadow 0.2s, color 0.2s; }
        .footer-link a:hover { color: #1ffb85; text-shadow: 0 0 10px rgba(0,230,118,0.5); }

        .status-bar { display: flex; align-items: center; justify-content: center; gap: 8px; margin-top: 20px; font-family: 'Rajdhani', sans-serif; font-size: 11px; letter-spacing: 0.12em; color: var(--muted); }
        .status-dot { width: 7px; height: 7px; border-radius: 50%; background: var(--green); box-shadow: 0 0 8px var(--green); animation: pulse 2s ease infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.4; transform: scale(0.75); } }
    </style>
</head>
<body>
<div class="bg-image"></div>
<div class="bg-overlay"></div>

<div class="ticker">
    <div class="ticker-inner">
        <span class="ticker-item up">▲ Secure Login + OTP</span>
        <span class="ticker-item up">▲ StockVerdict Verification</span>
        <span class="ticker-item down">▼ OTP Expires in 5 Minutes</span>
        <span class="ticker-item up">▲ Secure Login + OTP</span>
        <span class="ticker-item up">▲ StockVerdict Verification</span>
        <span class="ticker-item down">▼ OTP Expires in 5 Minutes</span>
    </div>
</div>

<div class="page">
    <div class="brand">
        <div class="brand-name">StockVerdict</div>
        <div class="brand-line"></div>
        <div class="brand-sub">Two-Factor Verification</div>
    </div>

    <div class="card">
        <div class="card-header">
            <div class="card-label">OTP Verification</div>
            <div class="card-title">Enter Your 6‑Digit Code</div>
            <div class="card-subtitle">
                We sent a one-time password to your email. Enter it below to complete login.
            </div>
        </div>

        <% String error = (String) request.getAttribute("error"); %>
        <% if (error != null) { %>
        <div class="alert alert-error">⚠ <%= error %></div>
        <% } %>

        <% String successMsg = (String) request.getAttribute("success"); %>
        <% if (successMsg != null) { %>
        <div class="alert alert-success">✓ <%= successMsg %></div>
        <% } %>


        <form action="${pageContext.request.contextPath}/user" method="post">
            <input type="hidden" name="action" value="verifyOtp"/>
            <div class="field">
                <label for="otp">One-Time Password (OTP)</label>
                <input
                        type="text"
                        id="otp"
                        name="otp"
                        inputmode="numeric"
                        autocomplete="one-time-code"
                        pattern="[0-9]{6}"
                        maxlength="6"
                        placeholder="e.g. 123456"
                        required
                />
                <div class="hint">Code expires in 5 minutes. Check your inbox (and spam folder).</div>
            </div>

            <button type="submit" class="btn">VERIFY & CONTINUE →</button>
        </form>

        <div class="footer-link">
            Didn’t receive a code? <a href="${pageContext.request.contextPath}/login.jsp">Go back to login</a>
        </div>
    </div>

    <div class="status-bar">
        <div class="status-dot"></div>
        Verification Active &nbsp;·&nbsp; Encrypted Session
    </div>
</div>

<div style="position: fixed; top: 15px; right: 20px; z-index: 500;">
    <button id="themeToggle" onclick="toggleTheme()" style="width: 36px; height: 36px; background: var(--surface); border: 1px solid var(--border); border-radius: 4px; color: var(--muted); cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px;">🌙</button>
</div>

<script>
    const THEME_KEY = 'sv_theme';
    function applyTheme(t) {
        document.documentElement.setAttribute('data-theme', t);
        const btn = document.getElementById('themeToggle');
        if (btn) btn.textContent = t === 'light' ? '🌙' : '☀️';
        localStorage.setItem(THEME_KEY, t);
        
        // Hide/Show background elements based on theme
        const bgImg = document.querySelector('.bg-image');
        const bgOverlay = document.querySelector('.bg-overlay');
        if (bgImg) bgImg.style.display = t === 'light' ? 'none' : 'block';
        if (bgOverlay) bgOverlay.style.display = t === 'light' ? 'none' : 'block';
    }
    function toggleTheme() {
        applyTheme((document.documentElement.getAttribute('data-theme') || 'dark') === 'dark' ? 'light' : 'dark');
    }
    // Set initial theme
    const savedTheme = localStorage.getItem(THEME_KEY) || 'dark';
    applyTheme(savedTheme);
</script>
</body>
</html>

