<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Intelligent Market Analysis</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/verdictlogo.png"/>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

    <%-- Iconify CSS icon files --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/analytics.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/brightness.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/moon.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/growth.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/handshake.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/lock.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/package.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/palette.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/money.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/group.css"/>

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:       #00e676;
            --green-dim:   #00c853;
            --green-glow:  rgba(0,230,118,0.2);
            --bg:          #040e07;
            --bg-card:     rgba(4,18,9,0.9);
            --border:      rgba(0,230,118,0.18);
            --border-hi:   rgba(0,230,118,0.4);
            --text:        #e4ffe4;
            --text-sub:    #a8d4b0;
            --muted:       #5a9a6a;
            --surface:     rgba(0,20,8,0.6);
        }
        [data-theme="light"] {
            --bg:          #f0faf2;
            --bg-card:     rgba(255,255,255,0.95);
            --border:      rgba(0,180,80,0.2);
            --border-hi:   rgba(0,180,80,0.5);
            --text:        #0a2e12;
            --text-sub:    #2d6e3e;
            --muted:       #4a8a5a;
            --surface:     rgba(220,245,225,0.7);
            --green:       #00a84a;
            --green-dim:   #007a35;
            --green-glow:  rgba(0,168,74,0.15);
        }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            transition: background 0.3s, color 0.3s;
        }

        /* ── Icon sizing overrides ── */
        .feat-icon {
            display: block;
            margin-bottom: 14px;
        }
        .mingcute--chart-bar-line,
        .fluent--arrow-growth-20-regular,
        .octicon--package-24,
        .streamline-freehand--money-bag,
        .fa--group {
            width: 32px !important;
            height: 32px !important;
        }
        .emojione-monotone--handshake {
            width: 36px !important;
            height: 36px !important;
        }
        .stash--moon {
            width: 20px !important;
            height: 20px !important;
        }

        /* Light theme: tint moon icon to green as well */
        [data-theme="light"] .stash--moon {
            filter: invert(1) brightness(0.3) sepia(1) hue-rotate(90deg) saturate(4);
        }

        /* ── Light theme: shift white SVG icons to green ── */
        [data-theme="light"] .mingcute--chart-bar-line,
        [data-theme="light"] .fluent--arrow-growth-20-regular,
        [data-theme="light"] .octicon--package-24,
        [data-theme="light"] .emojione-monotone--handshake,
        [data-theme="light"] .streamline-freehand--money-bag,
        [data-theme="light"] .fa--group,
        [data-theme="light"] .icon-park-twotone--brightness {
            filter: invert(1) brightness(0.3) sepia(1) hue-rotate(90deg) saturate(4);
        }

        .navbar {
            position: fixed; top: 0; left: 0; right: 0; z-index: 100;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 40px; height: 64px;
            background: var(--bg-card);
            border-bottom: 1px solid var(--border);
            backdrop-filter: blur(16px);
        }
        .nav-brand { display: flex; align-items: center; gap: 12px; text-decoration: none; }
        .nav-logo {
            width: 36px; height: 36px; border-radius: 50%;
            object-fit: contain; border: 1px solid var(--border-hi);
        }
        .nav-name {
            font-family: 'Rajdhani', sans-serif;
            font-size: 20px; font-weight: 700;
            color: var(--green); letter-spacing: 0.08em; text-transform: uppercase;
        }
        .nav-actions { display: flex; align-items: center; gap: 12px; }

        .btn-theme {
            width: 36px; height: 36px;
            background: var(--surface); border: 1px solid var(--border);
            color: var(--muted); cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: border-color 0.2s, color 0.2s;
        }
        .btn-theme:hover { border-color: var(--green); color: var(--green); }

        .btn-outline {
            padding: 9px 20px; background: transparent;
            border: 1px solid var(--border-hi); color: var(--green);
            font-family: 'Rajdhani', sans-serif;
            font-size: 12px; font-weight: 600; letter-spacing: 0.16em;
            text-transform: uppercase; text-decoration: none;
            transition: background 0.2s;
        }
        .btn-outline:hover { background: var(--green-glow); }

        .btn-solid {
            padding: 9px 20px; background: var(--green); color: #020e05;
            border: none; font-family: 'Rajdhani', sans-serif;
            font-size: 12px; font-weight: 700; letter-spacing: 0.16em;
            text-transform: uppercase; text-decoration: none;
            transition: background 0.2s;
            box-shadow: 0 4px 16px var(--green-glow);
        }
        .btn-solid:hover { background: var(--green-dim); }

        .hero {
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            padding: 100px 40px 60px; position: relative; overflow: hidden;
        }
        .hero::before {
            content: ''; position: absolute;
            width: 700px; height: 700px; border-radius: 50%;
            background: radial-gradient(circle, var(--green-glow) 0%, transparent 65%);
            top: 50%; left: 50%; transform: translate(-50%, -50%);
            pointer-events: none;
        }
        .hero-inner {
            position: relative; z-index: 1;
            max-width: 860px; margin: 0 auto; text-align: center;
        }
        .hero-badge {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 6px 16px; background: var(--surface);
            border: 1px solid var(--border);
            font-family: 'Rajdhani', sans-serif;
            font-size: 11px; letter-spacing: 0.22em;
            text-transform: uppercase; color: var(--green); margin-bottom: 28px;
        }
        .hero-badge-dot {
            width: 6px; height: 6px; border-radius: 50%;
            background: var(--green); box-shadow: 0 0 8px var(--green);
        }
        .hero-logo {
            width: 110px; height: 110px; border-radius: 50%;
            object-fit: contain; border: 2px solid var(--border-hi);
            background: var(--surface); margin: 0 auto 28px; display: block;
            box-shadow: 0 0 40px var(--green-glow);
        }
        .hero-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: clamp(42px, 7vw, 76px); font-weight: 700;
            line-height: 1.0; color: var(--text); letter-spacing: 0.03em;
            text-transform: uppercase; margin-bottom: 20px;
        }
        .hero-title .accent { color: var(--green); }
        .hero-desc {
            font-size: 17px; color: var(--text-sub); line-height: 1.7;
            max-width: 580px; margin: 0 auto 40px; font-weight: 300;
        }
        .hero-cta { display: flex; gap: 14px; justify-content: center; flex-wrap: wrap; }

        .btn-hero-primary {
            padding: 14px 36px; background: var(--green); color: #020e05;
            border: none; font-family: 'Rajdhani', sans-serif;
            font-size: 14px; font-weight: 700; letter-spacing: 0.2em;
            text-transform: uppercase; text-decoration: none;
            box-shadow: 0 6px 28px var(--green-glow);
            transition: background 0.2s, transform 0.1s; cursor: pointer;
        }
        .btn-hero-primary:hover { background: var(--green-dim); }
        .btn-hero-primary:active { transform: scale(0.98); }

        .btn-hero-outline {
            padding: 14px 36px; background: transparent;
            border: 1px solid var(--border-hi); color: var(--text);
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px; font-weight: 600; letter-spacing: 0.2em;
            text-transform: uppercase; text-decoration: none;
            transition: background 0.2s, border-color 0.2s, color 0.2s;
        }
        .btn-hero-outline:hover { background: var(--surface); border-color: var(--green); color: var(--green); }

        .stats-bar {
            display: flex; justify-content: center;
            border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);
            background: var(--surface);
        }
        .stat-item {
            flex: 1; max-width: 200px; padding: 28px 20px; text-align: center;
            border-right: 1px solid var(--border);
        }
        .stat-item:last-child { border-right: none; }
        .stat-num {
            font-family: 'Rajdhani', sans-serif; font-size: 32px; font-weight: 700;
            color: var(--green); display: block; line-height: 1;
        }
        .stat-lbl { font-size: 11px; color: var(--muted); margin-top: 6px; letter-spacing: 0.12em; text-transform: uppercase; }

        .section { padding: 80px 40px; max-width: 1100px; margin: 0 auto; }
        .section-eyebrow {
            font-family: 'Rajdhani', sans-serif; font-size: 10px; letter-spacing: 0.28em;
            text-transform: uppercase; color: var(--green); text-align: center; margin-bottom: 10px;
        }
        .section-title {
            font-family: 'Rajdhani', sans-serif; font-size: 36px; font-weight: 700;
            color: var(--text); text-align: center; letter-spacing: 0.04em; margin-bottom: 50px;
        }

        .features-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
        .feature-card {
            background: var(--surface); border: 1px solid var(--border);
            padding: 28px 24px; transition: border-color 0.2s, box-shadow 0.2s;
            position: relative; overflow: hidden;
        }
        .feature-card:hover { border-color: var(--border-hi); box-shadow: 0 0 24px var(--green-glow); }
        .feature-card::before {
            content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 2px;
            background: linear-gradient(90deg, transparent, var(--green), transparent);
            opacity: 0; transition: opacity 0.3s;
        }
        .feature-card:hover::before { opacity: 0.6; }
        .feat-title {
            font-family: 'Rajdhani', sans-serif; font-size: 16px; font-weight: 600;
            color: var(--text); letter-spacing: 0.04em; margin-bottom: 8px;
        }
        .feat-desc { font-size: 13px; color: var(--muted); line-height: 1.6; }

        .steps-grid { display: grid; grid-template-columns: repeat(4, 1fr); border: 1px solid var(--border); }
        .step {
            padding: 32px 24px; text-align: center;
            border-right: 1px solid var(--border); background: var(--surface);
        }
        .step:last-child { border-right: none; }
        .step-num {
            font-family: 'Rajdhani', sans-serif; font-size: 42px; font-weight: 700;
            color: var(--green); opacity: 0.25; line-height: 1; margin-bottom: 12px;
        }
        .step-title {
            font-family: 'Rajdhani', sans-serif; font-size: 14px; font-weight: 600;
            color: var(--text); letter-spacing: 0.06em; text-transform: uppercase; margin-bottom: 8px;
        }
        .step-desc { font-size: 12px; color: var(--muted); line-height: 1.5; }

        .cta-section {
            text-align: center; padding: 80px 40px;
            background: var(--surface);
            border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);
        }
        .cta-title {
            font-family: 'Rajdhani', sans-serif; font-size: 40px; font-weight: 700;
            color: var(--text); letter-spacing: 0.04em; margin-bottom: 14px;
        }
        .cta-sub { font-size: 15px; color: var(--muted); margin-bottom: 32px; }

        .footer {
            padding: 30px 40px; display: flex; align-items: center; justify-content: space-between;
            border-top: 1px solid var(--border);
        }
        .footer-brand {
            font-family: 'Rajdhani', sans-serif; font-size: 16px; font-weight: 600;
            color: var(--green); letter-spacing: 0.08em;
        }
        .footer-copy { font-size: 12px; color: var(--muted); }

        @media (max-width: 900px) {
            .features-grid { grid-template-columns: repeat(2, 1fr); }
            .steps-grid    { grid-template-columns: repeat(2, 1fr); }
            .step { border-bottom: 1px solid var(--border); }
        }
        @media (max-width: 600px) {
            .navbar { padding: 0 20px; }
            .hero   { padding: 90px 20px 50px; }
            .features-grid { grid-template-columns: 1fr; }
            .steps-grid    { grid-template-columns: 1fr; }
            .stats-bar { flex-wrap: wrap; }
            .stat-item { min-width: 50%; border-bottom: 1px solid var(--border); }
            .footer { flex-direction: column; gap: 8px; text-align: center; }
        }
    </style>
</head>
<body>

<nav class="navbar">
    <a href="#" class="nav-brand">
        <img src="${pageContext.request.contextPath}/images/verdictlogo.png" class="nav-logo" alt="Logo"/>
        <span class="nav-name">StockVerdict</span>
    </a>
    <div class="nav-actions">
        <button class="btn-theme" id="themeToggle" onclick="toggleTheme()" title="Toggle theme">
            <span id="themeIcon" class="icon-park-twotone--brightness"></span>
        </button>
        <a href="${pageContext.request.contextPath}/login.jsp" class="btn-outline">Sign In</a>
        <a href="${pageContext.request.contextPath}/register.jsp" class="btn-solid">Get Started</a>
    </div>
</nav>

<section class="hero">
    <div class="hero-inner">
        <div class="hero-badge">
            <span class="hero-badge-dot"></span>
            Live Market Intelligence Platform
        </div>
        <img src="${pageContext.request.contextPath}/images/verdictlogo.png" class="hero-logo" alt="StockVerdict"/>
        <h1 class="hero-title">
            Trade Smarter.<br/>
            <span class="accent">Decide Faster.</span>
        </h1>
        <p class="hero-desc">
            StockVerdict gives traders and businesses the tools to manage sales,
            track stock, monitor suppliers, and make data-driven decisions — all in one place.
        </p>
        <div class="hero-cta">
            <a href="${pageContext.request.contextPath}/register.jsp" class="btn-hero-primary">Create Free Account →</a>
            <a href="${pageContext.request.contextPath}/login.jsp" class="btn-hero-outline">Sign In</a>
        </div>
    </div>
</section>

<div class="stats-bar">
    <div class="stat-item"><span class="stat-num">12K+</span><div class="stat-lbl">Active Traders</div></div>
    <div class="stat-item"><span class="stat-num">$2.4B</span><div class="stat-lbl">Volume Tracked</div></div>
    <div class="stat-item"><span class="stat-num">99.9%</span><div class="stat-lbl">Uptime</div></div>
    <div class="stat-item"><span class="stat-num">256-bit</span><div class="stat-lbl">SSL Encryption</div></div>
    <div class="stat-item"><span class="stat-num">24/7</span><div class="stat-lbl">Data Sync</div></div>
</div>

<div class="section">
    <div class="section-eyebrow">Platform Features</div>
    <div class="section-title">Everything Your Business Needs</div>
    <div class="features-grid">

        <div class="feature-card">
            <span class="feat-icon"><span class="mingcute--chart-bar-line"></span></span>
            <div class="feat-title">Sales Management</div>
            <div class="feat-desc">Record sales instantly, track revenue over time, and manage every transaction with full edit and delete control.</div>
        </div>

        <div class="feature-card">
            <span class="feat-icon"><span class="octicon--package-24"></span></span>
            <div class="feat-title">Stock Management</div>
            <div class="feat-desc">Monitor product inventory in real time. Get alerts when stock runs low and add new products with ease.</div>
        </div>

        <div class="feature-card">
            <span class="feat-icon"><span class="emojione-monotone--handshake"></span></span>
            <div class="feat-title">Supplier Tracking</div>
            <div class="feat-desc">Keep records of all suppliers, track what you owe, and manage your supply chain relationships efficiently.</div>
        </div>

        <div class="feature-card">
            <span class="feat-icon"><span class="fluent--arrow-growth-20-regular"></span></span>
            <div class="feat-title">Analytics Dashboard</div>
            <div class="feat-desc">Visual insights into your revenue, top products, and sales trends. Make informed decisions with real data.</div>
        </div>

        <div class="feature-card">
            <span class="feat-icon"><span class="streamline-freehand--money-bag"></span></span>
            <div class="feat-title">Profit &amp; Expense Tracking</div>
            <div class="feat-desc">Automatically calculate profit margins, monitor expenses, and compare purchase costs with sales revenue for complete financial clarity.</div>
        </div>

        <div class="feature-card">
            <span class="feat-icon"><span class="fa--group"></span></span>
            <div class="feat-title">Multi-Branch &amp; User Management</div>
            <div class="feat-desc">Manage multiple shop locations and assign role-based access to staff while monitoring operations from a central dashboard.</div>
        </div>

    </div>
</div>

<div class="section" style="padding-top:0">
    <div class="section-eyebrow">How It Works</div>
    <div class="section-title">Up and Running in Minutes</div>
    <div class="steps-grid">
        <div class="step"><div class="step-num">01</div><div class="step-title">Create Account</div><div class="step-desc">Register as a trader or admin in seconds with secure email verification.</div></div>
        <div class="step"><div class="step-num">02</div><div class="step-title">Add Products</div><div class="step-desc">Set up your product catalog with prices, quantities, and supplier info.</div></div>
        <div class="step"><div class="step-num">03</div><div class="step-title">Record Sales</div><div class="step-desc">Log every sale with product, quantity, price, and payment method.</div></div>
        <div class="step"><div class="step-num">04</div><div class="step-title">Track &amp; Grow</div><div class="step-desc">Use the dashboard to monitor performance and make smarter decisions.</div></div>
    </div>
</div>

<div class="cta-section">
    <div class="cta-title">Ready to Take Control?</div>
    <div class="cta-sub">Join thousands of traders managing their business smarter with StockVerdict.</div>
    <a href="${pageContext.request.contextPath}/register.jsp" class="btn-hero-primary">Get Started for Free →</a>
</div>

<footer class="footer">
    <div class="footer-brand">StockVerdict</div>
    <div class="footer-copy">© 2025 StockVerdict. All rights reserved.</div>
</footer>

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