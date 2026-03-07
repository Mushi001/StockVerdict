<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Intelligent Market Analysis</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo2.png"/>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/ai.css"/>

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
        .lucide--brain,
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
        [data-theme="light"] .lucide--brain,
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
            transition: all 0.3s ease;
        }
        .nav-brand:hover .nav-logo {
            transform: scale(1.08) rotate(-5deg);
            border-color: var(--green);
            box-shadow: 0 0 15px var(--green-glow);
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
            border-radius: 6px;
            transition: all 0.2s ease;
        }
        .btn-theme:hover {
            border-color: var(--green);
            color: var(--green);
            transform: scale(1.05);
        }

        .btn-outline {
            padding: 9px 20px; background: transparent;
            border: 1px solid var(--border-hi); color: var(--green);
            font-family: 'Rajdhani', sans-serif;
            font-size: 12px; font-weight: 600; letter-spacing: 0.16em;
            text-transform: uppercase; text-decoration: none;
            border-radius: 6px;
            transition: all 0.2s ease;
        }
        .btn-outline:hover {
            background: var(--green-glow);
            transform: translateY(-2px);
        }

        .btn-solid {
            padding: 9px 20px; background: var(--green); color: #020e05;
            border: none; font-family: 'Rajdhani', sans-serif;
            font-size: 12px; font-weight: 700; letter-spacing: 0.16em;
            text-transform: uppercase; text-decoration: none;
            border-radius: 6px;
            transition: all 0.2s ease;
            box-shadow: 0 4px 16px var(--green-glow);
            cursor: pointer;
        }
        .btn-solid:hover {
            background: var(--green-dim);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px var(--green-glow);
        }

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
            animation: pulse-glow 3s ease-in-out infinite;
        }
        @keyframes pulse-glow {
            0%, 100% { transform: translate(-50%, -50%) scale(1); }
            50% { transform: translate(-50%, -50%) scale(1.05); }
        }
        .hero-inner {
            position: relative; z-index: 1;
            max-width: 860px; margin: 0 auto; text-align: center;
        }
        .hero-badge {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 8px 18px; background: var(--surface);
            border: 1px solid var(--border-hi);
            font-family: 'Rajdhani', sans-serif;
            font-size: 11px; letter-spacing: 0.22em;
            text-transform: uppercase; color: var(--green); margin-bottom: 28px;
            border-radius: 20px;
            transition: all 0.3s ease;
        }
        .hero-badge:hover {
            border-color: var(--green);
            box-shadow: 0 0 15px var(--green-glow);
        }
        .hero-badge-dot {
            width: 6px; height: 6px; border-radius: 50%;
            background: var(--green); box-shadow: 0 0 8px var(--green);
            animation: blink 2s infinite;
        }
        @keyframes blink {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.4; }
        }
        .hero-logo {
            width: 110px; height: 110px; border-radius: 50%;
            object-fit: contain; border: 2px solid var(--border-hi);
            background: var(--surface); margin: 0 auto 28px; display: block;
            box-shadow: 0 0 40px var(--green-glow);
            transition: all 0.3s ease;
        }
        .hero-logo:hover {
            transform: scale(1.08);
            border-color: var(--green);
            box-shadow: 0 0 50px var(--green-glow);
        }
        .hero-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: clamp(42px, 7vw, 76px); font-weight: 700;
            line-height: 1.0; color: var(--text); letter-spacing: 0.03em;
            text-transform: uppercase; margin-bottom: 20px;
        }
        .hero-title .accent {
            color: var(--green);
            animation: glow-text 3s ease-in-out infinite;
        }
        @keyframes glow-text {
            0%, 100% { text-shadow: 0 0 10px var(--green-glow); }
            50% { text-shadow: 0 0 20px var(--green-glow); }
        }
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
            border-radius: 6px;
            box-shadow: 0 6px 28px var(--green-glow);
            transition: all 0.2s ease; cursor: pointer;
        }
        .btn-hero-primary:hover {
            background: var(--green-dim);
            transform: translateY(-3px);
            box-shadow: 0 8px 32px var(--green-glow);
        }
        .btn-hero-primary:active { transform: scale(0.98); }

        .btn-hero-outline {
            padding: 14px 36px; background: transparent;
            border: 1.5px solid var(--border-hi); color: var(--text);
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px; font-weight: 600; letter-spacing: 0.2em;
            text-transform: uppercase; text-decoration: none;
            border-radius: 6px;
            transition: all 0.2s ease;
        }
        .btn-hero-outline:hover {
            background: var(--surface);
            border-color: var(--green);
            color: var(--green);
            transform: translateY(-3px);
        }

        .stats-bar {
            display: flex; justify-content: center;
            border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);
            background: var(--surface);
            margin: 40px 0;
        }
        .stat-item {
            flex: 1; max-width: 200px; padding: 28px 20px; text-align: center;
            border-right: 1px solid var(--border);
            transition: all 0.3s ease;
        }
        .stat-item:hover {
            background: rgba(0,230,118,0.05);
            transform: translateY(-4px);
        }
        .stat-item:last-child { border-right: none; }
        .stat-num {
            font-family: 'Rajdhani', sans-serif; font-size: 32px; font-weight: 700;
            color: var(--green); display: block; line-height: 1;
        }
        .stat-lbl { font-size: 11px; color: var(--muted); margin-top: 6px; letter-spacing: 0.12em; text-transform: uppercase; }

        .section { padding: 60px 40px; max-width: 1100px; margin: 0 auto; }
        .section + .section { margin-top: -10px; }
        .section-eyebrow {
            font-family: 'Rajdhani', sans-serif; font-size: 10px; letter-spacing: 0.28em;
            text-transform: uppercase; color: var(--green); text-align: center; margin-bottom: 10px;
        }
        .section-title {
            font-family: 'Rajdhani', sans-serif; font-size: 36px; font-weight: 700;
            color: var(--text); text-align: center; letter-spacing: 0.04em; margin-bottom: 50px;
        }

        .features-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; }
        .feature-card {
            background: var(--surface); border: 1px solid var(--border);
            padding: 32px 28px; transition: all 0.3s ease;
            position: relative; overflow: hidden;
            border-radius: 8px;
        }
        .feature-card:hover {
            border-color: var(--border-hi);
            box-shadow: 0 0 24px var(--green-glow);
            transform: translateY(-6px);
        }
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

        .steps-grid { display: grid; grid-template-columns: repeat(4, 1fr); border: 1px solid var(--border); border-radius: 8px; overflow: hidden; }
        .step {
            padding: 32px 24px; text-align: center;
            border-right: 1px solid var(--border); background: var(--surface);
            transition: all 0.3s ease;
        }
        .step:hover {
            background: rgba(0,230,118,0.05);
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
            text-align: center; padding: 70px 40px;
            background: var(--surface);
            border-top: 1px solid var(--border); border-bottom: 1px solid var(--border);
            margin: 40px 0;
        }
        .cta-title {
            font-family: 'Rajdhani', sans-serif; font-size: 40px; font-weight: 700;
            color: var(--text); letter-spacing: 0.04em; margin-bottom: 14px;
        }
        .cta-sub { font-size: 15px; color: var(--muted); margin-bottom: 32px; }

        /* ── Pricing Section ── */
        .pricing-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 28px; }
        .pricing-card {
            background: var(--surface); border: 1px solid var(--border);
            padding: 40px 30px; text-align: center; position: relative;
            transition: all 0.3s ease;
            border-radius: 8px;
        }
        .pricing-card:hover {
            transform: translateY(-8px);
            border-color: var(--border-hi);
            box-shadow: 0 0 24px var(--green-glow);
        }
        .highlight-card {
            border-color: var(--green);
            box-shadow: 0 0 30px var(--green-glow);
            transform: scale(1.02);
        }
        .highlight-card::before {
            content: 'BEST VALUE'; position: absolute; top: -12px; left: 50%; transform: translateX(-50%);
            background: var(--green); color: #020e05; padding: 6px 14px; font-size: 10px; font-weight: 700;
            letter-spacing: 0.15em; border-radius: 20px; box-shadow: 0 4px 12px var(--green-glow);
        }
        .price-title { color: var(--text-sub); font-size: 18px; margin-bottom: 12px; font-weight: 500; }
        .price-amount { font-family: 'Rajdhani', sans-serif; font-size: 48px; color: var(--green); font-weight: 700; line-height: 1; margin-bottom: 8px; }
        .price-duration { color: var(--muted); font-size: 13px; margin-bottom: 24px; }
        .price-desc { color: var(--text-sub); font-size: 14px; line-height: 1.6; margin-bottom: 20px; }

        /* ── Scroll Reveal Animation ── */
        .reveal { opacity: 0; transform: translateY(40px); transition: all 0.8s cubic-bezier(0.2, 0.8, 0.2, 1); }
        .reveal.visible { opacity: 1; transform: translateY(0); }

        /* ── Navigation Links ── */
        .nav-links { display: flex; gap: 32px; margin-left: 40px; margin-right: auto; }
        .nav-link {
            color: var(--text-sub); text-decoration: none;
            font-size: 14px; font-weight: 600; font-family: 'Rajdhani', sans-serif;
            letter-spacing: 0.08em; text-transform: uppercase;
            transition: color 0.3s; position: relative; padding: 4px 0;
        }
        .nav-link:hover { color: var(--green); }
        .nav-link::after {
            content: ''; position: absolute; left: 0; bottom: 0;
            width: 0%; height: 2px; background: var(--green);
            transition: width 0.3s ease;
        }
        .nav-link:hover::after { width: 100%; box-shadow: 0 0 8px var(--green); }

        /* ── Feature / Analytics Sections ── */
        .split-section { display: grid; grid-template-columns: 1fr 1fr; gap: 60px; align-items: center; }
        .split-text { padding-right: 20px; }
        .split-visual {
            position: relative; height: 350px; border-radius: 12px;
            background: linear-gradient(135deg, var(--surface) 0%, transparent 100%);
            border: 1px solid var(--border);
            display: flex; align-items: center; justify-content: center;
            overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.5);
            transition: all 0.3s ease;
        }
        .split-visual:hover {
            border-color: var(--green);
            box-shadow: 0 20px 50px var(--green-glow);
        }
        .abstract-chart {
            width: 80%; height: 60%; position: relative;
        }
        .abstract-bar {
            position: absolute; bottom: 0; width: 12%; background: var(--green-dim);
            border-radius: 4px 4px 0 0; box-shadow: 0 0 15px var(--green-glow);
            animation: growBar 3s infinite alternate ease-in-out;
        }
        @keyframes growBar { 0% { height: 20%; } 100% { height: 90%; } }

        /* ── Contact Section ── */
        .contact-container {
            display: grid; grid-template-columns: 1fr 1fr; gap: 60px;
            background: var(--surface); border: 1px solid var(--border);
            padding: 50px; border-radius: 12px; position: relative; overflow: hidden;
        }
        .contact-container::before {
            content: ''; position: absolute; top: 0; right: 0; width: 300px; height: 300px;
            background: radial-gradient(circle, var(--green-glow) 0%, transparent 70%);
            transform: translate(30%, -30%); pointer-events: none;
        }
        .contact-socials { display: flex; flex-direction: column; gap: 16px; margin-top: 20px; }
        .social-btn {
            display: inline-flex; align-items: center; gap: 12px; max-width: 250px;
            padding: 12px 20px; background: rgba(0,230,118,0.05); border: 1px solid var(--border);
            border-radius: 6px; color: var(--text); text-decoration: none; font-size: 14px;
            font-weight: 500; transition: all 0.3s ease;
        }
        [data-theme="light"] .social-btn { background: rgba(0,168,74,0.05); }
        .social-btn:hover {
            background: var(--green-glow);
            border-color: var(--green);
            color: var(--green);
            transform: translateX(6px);
        }
        .social-btn i { font-size: 18px; color: var(--green); }

        .contact-form { display: flex; flex-direction: column; gap: 16px; position: relative; z-index: 1; }

        .c-input {
            background: rgba(0,20,8,0.5); border: 1px solid var(--border);
            color: var(--text); padding: 12px 16px; font-family: 'Inter', sans-serif; font-size: 14px;
            outline: none; transition: all 0.2s ease;
            border-radius: 6px;
        }
        [data-theme="light"] .c-input { background: rgba(220,245,225,0.5); }
        .c-input:focus {
            border-color: var(--green);
            background: rgba(0,30,10,0.7);
            box-shadow: 0 0 12px var(--green-glow);
        }
        [data-theme="light"] .c-input:focus { background: rgba(200,240,210,0.8); }
        .c-input::placeholder { color: var(--muted); }

        /* ── FOOTER ── */

        .footer {
            background: var(--bg-card);
            border-top: 1px solid var(--border);
            padding: 80px 40px 40px;
            color: var(--text-sub);
        }
        .footer-grid {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1.5fr;
            gap: 40px;
            max-width: 1100px;
            margin: 0 auto;
        }
        .footer-col-title {
            font-family: 'Rajdhani', sans-serif;
            font-size: 14px; font-weight: 700;
            color: var(--green); letter-spacing: 0.1em;
            text-transform: uppercase; margin-bottom: 24px;
        }
        .footer-about-text {
            font-size: 14px; line-height: 1.6; color: var(--muted);
            margin-bottom: 20px;
        }
        .footer-links { list-style: none; }
        .footer-links li { margin-bottom: 12px; }
        .footer-links a {
            font-size: 14px; color: var(--text-sub); text-decoration: none;
            transition: all 0.2s ease;
        }
        .footer-links a:hover {
            color: var(--green);
            margin-left: 4px;
        }
        .footer-social { display: flex; gap: 12px; margin-top: 24px; flex-wrap: wrap; }
        .social-pill {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 8px 16px; border-radius: 20px;
            background: var(--surface); border: 1px solid var(--border);
            color: var(--text); text-decoration: none; font-size: 12px;
            font-weight: 500; transition: all 0.3s ease;
        }
        .social-pill:hover {
            background: var(--green-glow); border-color: var(--green); color: var(--green);
            transform: translateY(-3px); box-shadow: 0 4px 12px var(--green-glow);
        }
        .social-pill i { font-size: 14px; color: var(--green); }
        .footer-bottom {
            margin-top: 60px; padding-top: 30px;
            border-top: 1px solid var(--border);
            text-align: center; font-size: 13px; color: var(--muted);
        }
        .footer-bottom strong { color: var(--green); }

        @media (max-width: 900px) {
            .nav-links { display: none; }
            .features-grid { grid-template-columns: repeat(2, 1fr); }
            .steps-grid    { grid-template-columns: repeat(2, 1fr); }
            .step { border-bottom: 1px solid var(--border); }
            .split-section { grid-template-columns: 1fr; gap: 40px; }
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
        <img src="${pageContext.request.contextPath}/logo2.png" class="nav-logo" alt="Logo"/>
        <span class="nav-name">StockVerdict</span>
    </a>
    <div class="nav-links">
        <a href="#features-section" class="nav-link">Features</a>
        <a href="#analytics-section" class="nav-link">Analytics</a>
        <a href="#pricing-section" class="nav-link">Pricing</a>
        <a href="#enterprise-section" class="nav-link">Enterprise</a>
    </div>
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
        <img src="${pageContext.request.contextPath}/logo2.png" class="hero-logo" alt="StockVerdict"/>
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

<div class="stats-bar reveal">
    <div class="stat-item"><span class="stat-num">12K+</span><div class="stat-lbl">Active Traders</div></div>
    <div class="stat-item"><span class="stat-num">$2.4B</span><div class="stat-lbl">Volume Tracked</div></div>
    <div class="stat-item"><span class="stat-num">99.9%</span><div class="stat-lbl">Uptime</div></div>
    <div class="stat-item"><span class="stat-num">256-bit</span><div class="stat-lbl">SSL Encryption</div></div>
    <div class="stat-item"><span class="stat-num">24/7</span><div class="stat-lbl">Data Sync</div></div>
</div>

<div class="section reveal" id="features-section">
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
            <span class="feat-icon"><span class="lucide--brain"></span></span>
            <div class="feat-title">AI-Powered Analytics</div>
            <div class="feat-desc">Predict market trends, optimize stock levels, and get intelligent business insights powered by upcoming embedded AI integration.</div>
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

<div class="section reveal" id="analytics-section">
    <div class="split-section">
        <div class="split-text">
            <div class="section-eyebrow" style="text-align: left;">AI-Powered Insights</div>
            <h2 class="section-title" style="text-align: left; margin-bottom: 24px;">See the Future of Your Business</h2>
            <p class="hero-desc" style="text-align: left; margin-left: 0;">Our embedded AI engine processes thousands of data points to predict market trends before they happen. Optimize your stock levels and maximize your revenue with automated, intelligent insights.</p>
            <ul style="list-style: none; color: var(--text-sub); margin-top: 24px;">
                <li style="margin-bottom: 12px;"><i class="fa-solid fa-check" style="color: var(--green); margin-right: 12px;"></i> Predictive Stock Depletion</li>
                <li style="margin-bottom: 12px;"><i class="fa-solid fa-check" style="color: var(--green); margin-right: 12px;"></i> Revenue Forecasting Reports</li>
                <li style="margin-bottom: 12px;"><i class="fa-solid fa-check" style="color: var(--green); margin-right: 12px;"></i> Automated Buy Recommendations</li>
            </ul>
        </div>
        <div class="split-visual">
            <div class="abstract-chart">
                <div class="abstract-bar" style="left: 10%; animation-delay: 0s;"></div>
                <div class="abstract-bar" style="left: 30%; animation-delay: 0.5s;"></div>
                <div class="abstract-bar" style="left: 50%; animation-delay: 1.2s; background: var(--green); box-shadow: 0 0 25px var(--green);"></div>
                <div class="abstract-bar" style="left: 70%; animation-delay: 0.8s;"></div>
            </div>
        </div>
    </div>
</div>

<div class="section reveal" style="padding-top:40px">
    <div class="section-eyebrow">How It Works</div>
    <div class="section-title">Up and Running in Minutes</div>
    <div class="steps-grid">
        <div class="step"><div class="step-num">01</div><div class="step-title">Create Account</div><div class="step-desc">Register as a trader or admin in seconds with secure email verification.</div></div>
        <div class="step"><div class="step-num">02</div><div class="step-title">Add Products</div><div class="step-desc">Set up your product catalog with prices, quantities, and supplier info.</div></div>
        <div class="step"><div class="step-num">03</div><div class="step-title">Record Sales</div><div class="step-desc">Log every sale with product, quantity, price, and payment method.</div></div>
        <div class="step"><div class="step-num">04</div><div class="step-title">Track &amp; Grow</div><div class="step-desc">Use the dashboard to monitor performance and make smarter decisions.</div></div>
    </div>
</div>

<div class="section reveal" id="pricing-section">
    <div class="section-eyebrow">Clear & Simple Pricing</div>
    <div class="section-title">Invest in Your Business</div>
    <div class="pricing-grid">
        <div class="pricing-card">
            <div class="price-title">Trial Period</div>
            <div class="price-amount">Free</div>
            <div class="price-duration">First 2 Months</div>
            <p class="price-desc">Experience the full power of StockVerdict with zero commitment. Perfect for getting your business onboarded and seeing real results.</p>
        </div>
        <div class="pricing-card">
            <div class="price-title">Monthly Plan</div>
            <div class="price-amount">$29</div>
            <div class="price-duration">per month</div>
            <p class="price-desc">Flexible, pay-as-you-go subscription. Includes all features, unlimited products, and priority support.</p>
        </div>
        <div class="pricing-card highlight-card">
            <div class="price-title">Yearly Plan</div>
            <div class="price-amount">$290</div>
            <div class="price-duration">per year (Save 17%)</div>
            <p class="price-desc">Best value for growing businesses. Secure a full year of Intelligent Market Analysis at a discounted rate.</p>
        </div>
    </div>
</div>

<div class="section reveal" id="enterprise-section" style="background: var(--surface); border: 1px solid var(--border); border-radius: 12px; margin-top: 40px; margin-bottom: 40px; padding: 60px;">
    <div style="text-align: center; max-width: 600px; margin: 0 auto;">
        <div class="section-eyebrow">StockVerdict Enterprise</div>
        <h2 class="section-title" style="margin-bottom: 24px;">Built for Scale</h2>
        <p class="hero-desc">Need a dedicated instance, high-availability SLA, and deep API integrations? StockVerdict Enterprise offers everything you need to manage a nationwide chain of stores.</p>
        <a href="#contact-section" class="btn-solid" style="display: inline-block;">Contact Sales <i class="fa-solid fa-arrow-right" style="margin-left: 8px;"></i></a>
    </div>
</div>

<div class="section reveal" id="developers-section">
    <div class="split-section" style="gap: 40px;">
        <div style="background: var(--surface); border: 1px solid var(--border); padding: 40px; border-radius: 12px; transition: transform 0.3s;" onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='translateY(0)'">
            <i class="fa-solid fa-code" style="font-size: 32px; color: var(--green); margin-bottom: 24px;"></i>
            <h3 style="font-family: 'Rajdhani', sans-serif; font-size: 24px; font-weight: 700; color: var(--text); margin-bottom: 12px;">Developers & API</h3>
            <p style="color: var(--text-sub); font-size: 14px; line-height: 1.6; margin-bottom: 24px;">Integrate StockVerdict directly into your existing ERP systems. Our robust REST API and detailed documentation make custom solutions effortless.</p>
            <a href="#" class="btn-outline">Read Documentation</a>
        </div>
        <div id="security-section" style="background: var(--surface); border: 1px solid var(--border); padding: 40px; border-radius: 12px; transition: transform 0.3s;" onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='translateY(0)'">
            <i class="fa-solid fa-shield-halved" style="font-size: 32px; color: var(--green); margin-bottom: 24px;"></i>
            <h3 style="font-family: 'Rajdhani', sans-serif; font-size: 24px; font-weight: 700; color: var(--text); margin-bottom: 12px;">Bank-Grade Security</h3>
            <p style="color: var(--text-sub); font-size: 14px; line-height: 1.6; margin-bottom: 24px;">Your data is protected with 256-bit SSL encryption, automated daily backups, and stringent access controls to keep your business records safe.</p>
            <a href="#" class="btn-outline">View Security Details</a>
        </div>
    </div>
</div>

<div class="section reveal" id="contact-section">
    <div class="section-eyebrow">Get In Touch</div>
    <div class="section-title">Connect With Us</div>
    <div class="contact-container">
        <div class="contact-info">
            <h3 style="color: var(--green); margin-bottom: 20px; font-family: 'Rajdhani', sans-serif; font-size: 24px;">Drop us a message</h3>
            <p style="color: var(--muted); margin-bottom: 30px; font-size: 15px; line-height: 1.6;">Whether you have a question, need support, or want to inquire about enterprise plans, our team is here to help.</p>
            <div class="contact-socials">
                <a href="#" class="social-btn"><i class="fa-brands fa-instagram"></i> Instagram</a>
                <a href="#" class="social-btn"><i class="fa-brands fa-linkedin"></i> LinkedIn</a>
                <a href="#" class="social-btn"><i class="fa-brands fa-x-twitter"></i> Twitter</a>
            </div>
        </div>
        <div class="contact-form-wrap">
            <form class="contact-form">
                <input type="text" placeholder="Your Name" required class="c-input">
                <input type="email" placeholder="Your Email" required class="c-input">
                <textarea placeholder="Your Message" rows="5" required class="c-input"></textarea>
                <button type="button" class="btn-solid" style="width: 100%; border-radius: 6px; font-size: 14px; padding: 12px; display: block; margin-top: 10px; cursor: pointer;">Send Message</button>
            </form>
        </div>
    </div>
</div>

<div class="cta-section reveal">
    <div class="cta-title">Ready to Take Control?</div>
    <div class="cta-sub">Join thousands of traders managing their business smarter with StockVerdict.</div>
    <a href="${pageContext.request.contextPath}/register.jsp" class="btn-hero-primary">Get Started for Free →</a>
</div>

<footer class="footer">
    <div class="footer-grid">
        <div class="footer-col">
            <a href="#" class="nav-brand" style="margin-bottom: 20px; display: inline-flex;">
                <img src="${pageContext.request.contextPath}/logo2.png" class="nav-logo" alt="Logo"/>
                <span class="nav-name">StockVerdict</span>
            </a>
            <p class="footer-about-text">
                Empowering traders with intelligent market analysis and seamless stock management.
                Real-time data for better business decisions.
            </p>
            <div class="footer-social">
                <a href="#" class="social-pill" title="Twitter"><i class="fa-brands fa-x-twitter"></i> Twitter</a>
                <a href="#" class="social-pill" title="LinkedIn"><i class="fa-brands fa-linkedin-in"></i> LinkedIn</a>
                <a href="#" class="social-pill" title="GitHub"><i class="fa-brands fa-github"></i> GitHub</a>
            </div>
        </div>
        <div class="footer-col">
            <h4 class="footer-col-title">Product</h4>
            <ul class="footer-links">
                <li><a href="#features-section">Features</a></li>
                <li><a href="#pricing-section">Pricing</a></li>
                <li><a href="#">Analytics</a></li>
                <li><a href="#">Enterprise</a></li>
            </ul>
        </div>
        <div class="footer-col">
            <h4 class="footer-col-title">Support</h4>
            <ul class="footer-links">
                <li><a href="#">Documentation</a></li>
                <li><a href="#">API Status</a></li>
                <li><a href="#contact-section">Contact Us</a></li>
                <li><a href="#">Security</a></li>
            </ul>
        </div>
        <div class="footer-col">
            <h4 class="footer-col-title">Newsletter</h4>
            <p class="footer-about-text" style="font-size: 12px;">Stay updated with our latest features and market insights.</p>
            <form style="display: flex; gap: 8px; margin-top: 12px;">
                <input type="email" placeholder="email@example.com" style="flex: 1; background: var(--surface); border: 1px solid var(--border); padding: 8px 12px; color: var(--text); font-size: 13px; outline: none; border-radius: 6px;">
                <button type="submit" class="btn-solid" style="padding: 8px 16px; font-size: 10px;">Join</button>
            </form>
        </div>
    </div>
    <div class="footer-bottom">
        <p>&copy; 2025 <strong>StockVerdict</strong>. Handcrafted for the next generation of traders.</p>
    </div>
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

    // Scroll Reveal Animation Observer
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, { threshold: 0.1 });
    document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
</script>
</body>
</html>
