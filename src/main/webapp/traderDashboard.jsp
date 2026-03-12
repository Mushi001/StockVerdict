<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<c:if test="${empty sessionScope.currentUser}">
    <c:redirect url="${pageContext.request.contextPath}/login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo2.png"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/edit.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/delete.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/money.css"/>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --green:      #00e676;
            --green-dim:  #00c853;
            --green-glow: rgba(0,230,118,0.18);
            --bg:         #040e07;
            --bg-card:    rgba(4,18,9,0.95);
            --bg-sidebar: #020a04;
            --border:     rgba(0,230,118,0.15);
            --border-hi:  rgba(0,230,118,0.4);
            --text:       #e4ffe4;
            --text-sub:   #a8d4b0;
            --muted:      #5a9a6a;
            --surface:    rgba(0,20,8,0.6);
            --red:        #ff5252;
            --amber:      #ffb300;
        }
        [data-theme="light"] {
            --green:      #008b3e;
            --green-dim:  #006b2e;
            --green-glow: rgba(0,139,62,0.1);
            --bg:         #f4fdf6;
            --bg-card:    #ffffff;
            --bg-sidebar: #e1f2e5;
            --border:     rgba(0,100,40,0.12);
            --border-hi:  rgba(0,100,40,0.3);
            --text:       #051a0b;
            --text-sub:   #1b4d2b;
            --muted:      #457a53;
            --surface:    rgba(255,255,255,0.8);
            --red:        #d32f2f;
            --amber:      #f57c00;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg); color: var(--text);
            min-height: 100vh; display: flex;
            transition: background 0.3s, color 0.3s;
            overflow-x: hidden;
        }

        /* ── SIDEBAR ── */
        .sidebar {
            width: 240px; flex-shrink: 0;
            background: var(--bg-sidebar);
            border-right: 1px solid var(--border);
            display: flex; flex-direction: column;
            position: fixed; top: 0; left: 0; bottom: 0;
            z-index: 50; transition: transform 0.3s, background 0.3s;
        }
        .sidebar-top {
            padding: 24px 20px; border-bottom: 1px solid var(--border);
            display: flex; align-items: center; gap: 12px;
        }
        .sidebar-logo {
            width: 40px; height: 40px; border-radius: 50%;
            object-fit: contain; border: 1px solid var(--border-hi);
        }
        .sidebar-brand {
            font-family: 'Rajdhani', sans-serif; font-size: 18px; font-weight: 700;
            color: var(--green); letter-spacing: 0.08em; text-transform: uppercase;
        }
        .sidebar-user { padding: 18px 20px; border-bottom: 1px solid var(--border); }
        .sidebar-user-name {
            font-family: 'Rajdhani', sans-serif; font-size: 14px; font-weight: 600; color: var(--text);
            margin-bottom: 4px;
        }
        .sidebar-user-role { font-size: 11px; color: var(--muted); letter-spacing: 0.1em; text-transform: uppercase; margin-top: 4px; }
        .sidebar-nav { flex: 1; padding: 16px 0; overflow-y: auto; }
        .nav-section-label {
            padding: 12px 20px 6px;
            font-family: 'Rajdhani', sans-serif; font-size: 9px; letter-spacing: 0.3em;
            text-transform: uppercase; color: var(--muted); font-weight: 700;
        }
        .nav-item {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 20px; color: var(--muted); text-decoration: none;
            font-size: 13px; font-weight: 500; cursor: pointer;
            border: none; background: none; width: 100%; text-align: left;
            transition: all 0.25s ease;
            border-left: 3px solid transparent;
        }
        .nav-item:hover { color: var(--text); background: var(--green-glow); border-left-color: var(--green); }
        .nav-item.active { color: var(--green); border-left-color: var(--green); background: var(--green-glow); font-weight: 600; }
        .nav-item.danger { color: var(--red); margin-top: 8px; }
        .nav-item.danger:hover { background: rgba(255,82,82,0.1); }
        .nav-icon { font-size: 16px; width: 20px; text-align: center; flex-shrink: 0; }
        .sidebar-bottom { padding: 16px 0; border-top: 1px solid var(--border); }

        /* ── MAIN ── */
        .main-content { margin-left: 240px; flex: 1; min-height: 100vh; display: flex; flex-direction: column; }

        .topbar {
            height: 64px; background: var(--bg-card); border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 28px; position: sticky; top: 0; z-index: 40; gap: 20px;
        }
        .topbar-left {
            display: flex; align-items: center; gap: 16px; flex: 1;
        }
        .back-button {
            background: transparent; border: 1px solid var(--border); color: var(--text);
            width: 40px; height: 40px; border-radius: 4px; cursor: pointer;
            display: flex; align-items: center; justify-content: center; font-size: 16px;
            transition: all 0.25s ease;
        }
        .back-button:hover { border-color: var(--green); color: var(--green); background: var(--green-glow); }
        .topbar-title {
            font-family: 'Rajdhani', sans-serif; font-size: 18px; font-weight: 600;
            color: var(--text); letter-spacing: 0.06em; text-transform: uppercase;
        }
        .topbar-right { display: flex; align-items: center; gap: 12px; }
        .btn-theme {
            width: 40px; height: 40px; background: var(--surface); border: 1px solid var(--border);
            color: var(--muted); cursor: pointer; font-size: 16px;
            display: flex; align-items: center; justify-content: center; border-radius: 4px;
            transition: all 0.25s ease;
        }
        .btn-theme:hover { border-color: var(--green); color: var(--green); background: var(--green-glow); }
        .btn-logout-top {
            background: rgba(255,82,82,0.1); border: 1px solid var(--red); color: var(--red);
            padding: 8px 16px; border-radius: 4px; cursor: pointer;
            font-family: 'Rajdhani', sans-serif; font-size: 11px; font-weight: 600;
            letter-spacing: 0.1em; text-transform: uppercase;
            transition: all 0.25s ease; text-decoration: none; display: flex; align-items: center; gap: 6px;
        }
        .btn-logout-top:hover { background: rgba(255,82,82,0.2); }

        /* ── SECTIONS ── */
        .page-section { display: none; padding: 32px; flex: 1; overflow-y: auto; }
        .page-section.active { display: block; }

        .sec-header {
            display: flex; align-items: flex-end; justify-content: space-between;
            margin-bottom: 32px; padding-bottom: 20px; border-bottom: 1px solid var(--border);
            gap: 16px; flex-wrap: wrap;
        }
        .topbar-title {
            font-family: 'Rajdhani', sans-serif; font-size: 18px; font-weight: 700;
            color: var(--text); letter-spacing: 0.1em; text-transform: uppercase;
        }
        .menu-toggle {
            display: none; background: none; border: none; color: var(--text);
            font-size: 20px; cursor: pointer; margin-right: 12px; transition: color 0.2s;
        }
        .menu-toggle:hover { color: var(--green); }
        @media(max-width:900px) {
            .menu-toggle { display: block; }
        }
        .sec-eyebrow {
            font-family: 'Rajdhani', sans-serif; font-size: 10px; letter-spacing: 0.26em;
            text-transform: uppercase; color: var(--green); margin-bottom: 4px;
        }
        .sec-title {
            font-family: 'Rajdhani', sans-serif; font-size: 28px; font-weight: 700;
            color: var(--text); letter-spacing: 0.03em; line-height: 1;
        }
        .sec-sub { font-size: 13px; color: var(--muted); margin-top: 5px; line-height: 1.5; }

        .btn-primary {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 11px 22px; background: var(--green); color: #020e05;
            border: none; cursor: pointer;
            font-family: 'Rajdhani', sans-serif; font-size: 12px; font-weight: 700;
            letter-spacing: 0.16em; text-transform: uppercase;
            box-shadow: 0 4px 16px var(--green-glow);
            transition: all 0.25s ease; text-decoration: none; border-radius: 4px;
        }
        .btn-primary:hover { background: var(--green-dim); box-shadow: 0 6px 24px rgba(0,230,118,0.35); transform: translateY(-2px); }
        .btn-primary:active { transform: scale(0.98); }

        /* ── STATS ── */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 32px; }
        .stat-card {
            background: var(--surface); border: 1px solid var(--border);
            padding: 24px; position: relative; overflow: hidden; border-radius: 4px;
            transition: all 0.25s ease;
        }
        .stat-card:hover { border-color: var(--green); background: var(--green-glow); }
        .stat-card::after {
            content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 2px;
            background: linear-gradient(90deg, transparent, var(--green), transparent); opacity: 0.4;
        }
        .stat-lbl {
            font-family: 'Rajdhani', sans-serif; font-size: 10px; letter-spacing: 0.2em;
            text-transform: uppercase; color: var(--muted); margin-bottom: 10px; font-weight: 700;
        }
        .stat-val { font-family: 'Rajdhani', sans-serif; font-size: 32px; font-weight: 700; color: var(--green); line-height: 1; margin-bottom: 6px; }
        .stat-hint { font-size: 11px; color: var(--muted); }

        /* ── TABLE ── */
        .table-wrap { background: var(--surface); border: 1px solid var(--border); overflow: hidden; margin-bottom: 28px; border-radius: 4px; }
        .table-hdr {
            display: flex; align-items: center; justify-content: space-between;
            padding: 16px 20px; border-bottom: 1px solid var(--border); background: rgba(0,230,118,0.03);
        }
        .table-hdr-title {
            font-family: 'Rajdhani', sans-serif; font-size: 12px; font-weight: 600;
            letter-spacing: 0.14em; text-transform: uppercase; color: var(--text);
        }
        .table-hdr-count { font-size: 11px; color: var(--muted); }
        table { width: 100%; border-collapse: collapse; }
        thead th {
            padding: 14px 16px;
            font-family: 'Rajdhani', sans-serif; font-size: 10px; font-weight: 600;
            letter-spacing: 0.18em; text-transform: uppercase; color: var(--muted);
            border-bottom: 1px solid var(--border); text-align: left;
        }
        thead th:last-child { text-align: center; }
        tbody tr { border-bottom: 1px solid rgba(0,230,118,0.07); transition: background 0.15s ease; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: var(--green-glow); }
        tbody td { padding: 14px 16px; font-size: 13px; color: var(--text); vertical-align: middle; }
        tbody td:last-child { text-align: center; }
        .td-green { color: var(--green); font-family: 'Rajdhani', sans-serif; font-size: 14px; font-weight: 600; }
        .td-muted { color: var(--muted); font-size: 12px; }
        .badge {
            display: inline-block; padding: 3px 11px;
            font-family: 'Rajdhani', sans-serif; font-size: 10px; font-weight: 600;
            letter-spacing: 0.12em; text-transform: uppercase; border: 1px solid; border-radius: 2px;
        }
        .badge-green { border-color: rgba(0,230,118,0.3); color: var(--green); background: var(--green-glow); }
        .badge-amber { border-color: rgba(255,179,0,0.3); color: var(--amber); background: rgba(255,179,0,0.08); }
        .badge-red   { border-color: rgba(255,82,82,0.3); color: var(--red); background: rgba(255,82,82,0.08); }

        .action-btns { display: flex; gap: 8px; justify-content: center; }
        .btn-edit {
            padding: 5px 12px; background: var(--green-glow);
            border: 1px solid rgba(0,230,118,0.25); color: var(--green);
            font-family: 'Rajdhani', sans-serif; font-size: 10px; font-weight: 600;
            letter-spacing: 0.1em; text-transform: uppercase; cursor: pointer; transition: background 0.2s; border-radius: 2px;
        }
        .btn-edit:hover { background: rgba(0,230,118,0.2); }
        .btn-del {
            padding: 5px 12px; background: rgba(255,82,82,0.08);
            border: 1px solid rgba(255,82,82,0.25); color: var(--red);
            font-family: 'Rajdhani', sans-serif; font-size: 10px; font-weight: 600;
            letter-spacing: 0.1em; text-transform: uppercase; cursor: pointer; transition: background 0.2s; border-radius: 2px;
        }
        .btn-del:hover { background: rgba(255,82,82,0.18); }
        .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); font-size: 13px; }
        .empty-icon { font-size: 48px; margin-bottom: 16px; opacity: 0.5; }

        /* ── MODAL ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0; z-index: 500;
            background: rgba(2,8,4,0.82); backdrop-filter: blur(4px);
            align-items: center; justify-content: center; padding: 20px;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: var(--bg-card); border: 1px solid var(--border-hi);
            width: 100%; max-width: 500px;
            box-shadow: 0 0 60px var(--green-glow), 0 40px 80px rgba(0,0,0,0.7);
            animation: modalIn 0.22s ease both; position: relative; border-radius: 4px;
            max-height: 90vh; overflow-y: auto;
        }
        @keyframes modalIn { from{opacity:0;transform:translateY(12px) scale(0.98)} to{opacity:1;transform:translateY(0) scale(1)} }
        .modal-hdr {
            display: flex; align-items: center; justify-content: space-between;
            padding: 20px 24px 16px; border-bottom: 1px solid var(--border); flex-shrink: 0;
        }
        .modal-eyebrow { font-family:'Rajdhani',sans-serif; font-size:9px; letter-spacing:0.3em; text-transform:uppercase; color:var(--green); margin-bottom:4px; font-weight: 700; }
        .modal-title   { font-family:'Rajdhani',sans-serif; font-size:20px; font-weight:700; color:var(--text); }
        .modal-close   { background:none; border:none; cursor:pointer; color:var(--muted); font-size:20px; padding:4px 8px; transition:color 0.2s; }
        .modal-close:hover { color:var(--text); }
        .modal-body { padding: 24px; }
        .modal-footer { display:flex; gap:12px; justify-content:flex-end; padding:16px 24px; border-top:1px solid var(--border); flex-shrink: 0; }
        .field { margin-bottom: 18px; }
        .field label {
            display: block; font-family:'Rajdhani',sans-serif; font-size:10px;
            letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); margin-bottom:6px; font-weight: 700;
        }
        .field input, .field select, .field textarea {
            width: 100%; background: var(--surface); border: 1px solid var(--border);
            color: var(--text); font-family:'Inter',sans-serif; font-size:13px;
            padding: 10px 13px; outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            appearance: none; border-radius: 2px; resize: vertical;
        }
        .field input:focus, .field select:focus, .field textarea:focus {
            border-color: var(--green); box-shadow: 0 0 0 2px var(--green-glow);
        }
        .field input::placeholder, .field textarea::placeholder { color: rgba(90,154,106,0.4); }
        .select-wrap { position: relative; }
        .select-wrap::after { content:'▾'; position:absolute; right:11px; top:50%; transform:translateY(-50%); color:var(--muted); pointer-events:none; }
        select option { background: #061409; color: var(--text); }
        .field-row { display:flex; gap:14px; }
        .field-row .field { flex:1; }
        .btn-cancel {
            padding:10px 20px; background:transparent; border:1px solid var(--border); color:var(--muted);
            font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.15em;
            text-transform:uppercase; cursor:pointer; transition:all 0.25s ease; border-radius: 2px;
        }
        .btn-cancel:hover { border-color:var(--border-hi); color:var(--text); }
        .btn-danger {
            padding:10px 20px; background:rgba(255,82,82,0.1); border:1px solid var(--red); color:var(--red);
            font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.15em;
            text-transform:uppercase; cursor:pointer; transition:background 0.2s;
            text-decoration:none; display:inline-flex; align-items:center; gap: 6px; border-radius: 2px;
        }
        .btn-danger:hover { background:rgba(255,82,82,0.2); }
        .confirm-icon { text-align:center; font-size:42px; margin-bottom:16px; }
        .confirm-msg  { text-align:center; color:var(--muted); font-size:14px; line-height:1.6; margin-bottom:12px; }
        .confirm-name { text-align:center; font-family:'Rajdhani',sans-serif; font-size:16px; color:var(--green); font-weight:600; margin-bottom:20px; }

        .alert { padding:12px 16px; margin-bottom:24px; font-size:13px; border-left:3px solid; border-radius: 2px; animation: slideIn 0.3s ease; }
        @keyframes slideIn { from { opacity: 0; transform: translateX(-10px); } to { opacity: 1; transform: translateX(0); } }
        .alert-success { background:rgba(0,230,118,0.08); border-color:var(--green); color:var(--green); }
        .alert-error   { background:rgba(255,82,82,0.08); border-color:var(--red); color:#ff8a8a; }

        .cta-buttons { display: flex; gap: 14px; flex-wrap: wrap; margin-bottom: 32px; }

        @media(max-width:900px) {
            .sidebar { transform:translateX(-100%); }
            .sidebar.open { transform:translateX(0); }
            .main-content { margin-left:0; }
            .stats-grid { grid-template-columns:repeat(2,1fr); }
            .topbar { padding: 0 16px; }
        }
        @media(max-width:600px) {
            .stats-grid { grid-template-columns:1fr; }
            .page-section { padding:16px; }
            .sec-title { font-size: 24px; }
            .cta-buttons { flex-direction: column; }
            .cta-buttons .btn-primary { width: 100%; }
        }
    </style>
</head>
<body>

<aside class="sidebar" id="sidebar">
    <a href="${pageContext.request.contextPath}/dashboard" class="sidebar-brand">
        <img src="${pageContext.request.contextPath}/logo2.png" class="sidebar-logo" alt="Logo"/>
        <span class="sidebar-name">StockVerdict</span>
    </a>
    <div class="sidebar-user">
        <div class="sidebar-user-name">${sessionScope.currentUser.name}</div>
        <div class="sidebar-user-role">${sessionScope.currentUser.role}</div>
    </div>

    <nav class="sidebar-nav">
        <div class="nav-section-label">Navigation</div>
        <a href="/" class="nav-item">
            <span class="nav-icon"><i class="fas fa-home"></i></span> Home
        </a>
        <a id="nav-dashboard" class="nav-item active" onclick="showSection('dashboard', this)">
            <span class="nav-icon"><i class="fas fa-th-large"></i></span> Dashboard
        </a>
        <a id="nav-sales" class="nav-item" onclick="showSection('sales', this)">
            <span class="nav-icon"><i class="fas fa-chart-line"></i></span> Sales
        </a>

        <div class="nav-section-label">Inventory</div>
        <a id="nav-stock" class="nav-item" onclick="showSection('stock', this)">
            <span class="nav-icon"><i class="fas fa-cubes"></i></span> Stock Management
        </a>
        <a id="nav-suppliers" class="nav-item" onclick="showSection('suppliers', this)">
            <span class="nav-icon"><i class="fas fa-handshake"></i></span> Suppliers
        </a>
        <a id="nav-customers" class="nav-item" onclick="showSection('customers', this)">
            <span class="nav-icon"><i class="fas fa-users"></i></span> Customers
        </a>

        <div class="nav-section-label">Account</div>
        <a id="nav-settings" class="nav-item" onclick="showSection('settings', this)">
            <span class="nav-icon"><i class="fas fa-cog"></i></span> Settings
        </a>
        <button class="nav-item danger" onclick="openLogoutModal()">
            <span class="nav-icon"><i class="fas fa-sign-out-alt"></i></span> Logout
        </button>
    </nav>

    <div class="sidebar-bottom">
        <div style="padding:10px 20px; font-size:11px; color:var(--muted); font-family: 'Rajdhani', sans-serif;">
            <span id="sidebarClock"></span>
        </div>
    </div>
</aside>

<div class="main-content">
    <div class="topbar">
        <div class="topbar-left">
            <button class="menu-toggle" onclick="toggleSidebar()"><i class="fas fa-bars"></i></button>
            <div class="topbar-title" id="topbarTitle">Dashboard</div>
        </div>
        <div class="topbar-right">
            <button class="btn-theme" id="themeToggle" onclick="toggleTheme()" title="Toggle dark/light theme">
                <i class="fas fa-moon"></i>
            </button>
            <button type="button" onclick="openLogoutModal()" class="btn-logout-top">
                <i class="fas fa-sign-out-alt"></i> Logout
            </button>
        </div>
    </div>

    <!-- ══ DASHBOARD ══ -->
    <div class="page-section active" id="sec-dashboard">
        <c:if test="${not empty param.success || not empty success}">
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> ${not empty success ? success : 'Operation completed successfully.'}
            </div>
        </c:if>
        <c:if test="${param.error == 'invalidPrice' || error == 'invalidPrice'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Error: Selling Price cannot be lower than Cost Price.</div>
        </c:if>
        <c:if test="${param.error == 'barcodeExists' || error == 'barcodeExists'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Error: A product with this barcode already exists.</div>
        </c:if>
        <c:if test="${param.error == 'supplierEmailExists' || error == 'supplierEmailExists'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Error: A supplier with this email already exists.</div>
        </c:if>
        <c:if test="${param.error == 'customerEmailExists' || error == 'customerEmailExists'}">
            <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> Error: A customer with this email already exists.</div>
        </c:if>
        <c:if test="${not empty param.error || not empty error}">
            <c:set var="errCode" value="${not empty error ? error : param.error}"/>
            <c:if test="${errCode != 'invalidPrice' && errCode != 'barcodeExists' && errCode != 'supplierEmailExists' && errCode != 'customerEmailExists'}">
                <div class="alert alert-error"><i class="fas fa-exclamation-circle"></i> ${not empty error ? error : 'An error occurred. Please try again.'}</div>
            </c:if>
        </c:if>

        <div class="sec-header">
            <div>
                <div class="sec-eyebrow">Overview</div>
                <div class="sec-title">Welcome back, ${sessionScope.currentUser.name}</div>
                <div class="sec-sub">Here's what's happening with your business today.</div>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-lbl">Total Sales</div>
                <div class="stat-val"><c:choose><c:when test="${not empty totalSales}">${totalSales}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">All time transactions</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Revenue</div>
                <div class="stat-val">Rwf <c:choose><c:when test="${not empty totalRevenue}"><fmt:formatNumber value="${totalRevenue}" pattern="#,##0"/></c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Gross earnings</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Products</div>
                <div class="stat-val"><c:choose><c:when test="${not empty totalProducts}">${totalProducts}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">In inventory</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Suppliers</div>
                <div class="stat-val"><c:choose><c:when test="${not empty totalSuppliers}">${totalSuppliers}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Active partners</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Customers</div>
                <div class="stat-val"><c:choose><c:when test="${not empty totalCustomers}">${totalCustomers}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Registered clients</div>
            </div>
        </div>

        <div class="cta-buttons">
            <button class="btn-primary" onclick="showSection('sales',null); openAddSaleModal()"><i class="fas fa-plus-circle"></i> New Sale</button>
            <button class="btn-primary" onclick="showSection('stock',null); openAddProductModal()"><i class="fas fa-plus-circle"></i> Add Product</button>
            <button class="btn-primary" onclick="showSection('suppliers',null); openAddSupplierModal()"><i class="fas fa-plus-circle"></i> Add Supplier</button>
        </div>

        <div class="table-wrap">
            <div class="table-hdr">
                <span class="table-hdr-title">Recent Sales</span>
                <a onclick="showSection('sales', document.getElementById('nav-sales'))" style="font-size:11px;color:var(--green);text-decoration:none;cursor:pointer;">View All <i class="fas fa-arrow-right" style="font-size:9px;margin-left:4px;"></i></a>
            </div>
            <c:choose>
                <c:when test="${empty recentSales}">
                    <div class="empty-state"><div class="empty-icon"><i class="fas fa-receipt"></i></div>No sales yet.</div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead><tr><th>Date</th><th>Product</th><th>Qty</th><th>Total</th><th>Status</th></tr></thead>
                        <tbody>
                        <c:forEach var="s" items="${recentSales}">
                            <tr>
                                <td class="td-muted">${s.saleDate.toLocalDate()}</td>
                                <td class="td-green"><c:choose><c:when test="${not empty s.saleItems}">${s.saleItems[0].product.name}</c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                <td>Rwf <fmt:formatNumber value="${s.totalAmount}" pattern="#,##0"/></td>
                                <td><span class="badge badge-green">Completed</span></td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ══ STOCK MANAGEMENT ══ -->
    <div class="page-section" id="sec-stock">
        <div class="sec-header">
            <div>
                <div class="sec-eyebrow">Inventory</div>
                <div class="sec-title">Stock Management</div>
                <div class="sec-sub">Add products, update quantities, monitor stock levels</div>
            </div>
            <button class="btn-primary" onclick="openAddProductModal()"><i class="fas fa-plus-circle"></i> Add Product</button>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-lbl">Total Products</div>
                <div class="stat-val"><c:choose><c:when test="${not empty productList}">${productList.size()}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">In catalog</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Low Stock</div>
                <div class="stat-val" style="color:var(--amber);"><c:choose><c:when test="${not empty lowStockCount}">${lowStockCount}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Below threshold</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Out of Stock</div>
                <div class="stat-val" style="color:var(--red);"><c:choose><c:when test="${not empty outOfStockCount}">${outOfStockCount}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Needs restock</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Stock Value</div>
                <div class="stat-val">Rwf <c:choose><c:when test="${not empty totalStockValue}"><fmt:formatNumber value="${totalStockValue}" pattern="#,##0"/></c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">At cost price</div>
            </div>
        </div>

        <div class="table-wrap">
            <div class="table-hdr">
                <span class="table-hdr-title">All Products</span>
                <span class="table-hdr-count"><c:choose><c:when test="${not empty productList}">${productList.size()} items</c:when><c:otherwise>0 items</c:otherwise></c:choose></span>
            </div>
            <c:choose>
                <c:when test="${empty productList}">
                    <div class="empty-state"><div class="empty-icon"><i class="fas fa-boxes"></i></div>No products yet. Add your first product above.</div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead><tr><th>#</th><th>Name</th><th>Barcode</th><th>Cost</th><th>Price</th><th>Stock</th><th>Reorder Level</th><th>Status</th><th>Actions</th></tr></thead>
                        <tbody>
                        <c:forEach var="p" items="${productList}" varStatus="vs">
                            <tr>
                                <td class="td-muted">${vs.count}</td>
                                <td class="td-green">${p.name}</td>
                                <td class="td-muted">${p.barcode}</td>
                                <td>Rwf <fmt:formatNumber value="${p.purchasePrice}" pattern="#,##0.00"/></td>
                                <td class="td-green">Rwf <fmt:formatNumber value="${p.sellingPrice}" pattern="#,##0.00"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.quantityInStock == 0}"><span style="color:var(--red)">${p.quantityInStock}</span></c:when>
                                        <c:when test="${p.quantityInStock <= 5}"><span style="color:var(--amber)">${p.quantityInStock}</span></c:when>
                                        <c:otherwise>${p.quantityInStock}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="td-muted">${p.reorderLevel}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.quantityInStock == 0}"><span class="badge badge-red">Out of Stock</span></c:when>
                                        <c:when test="${p.quantityInStock <= 5}"><span class="badge badge-amber">Low Stock</span></c:when>
                                        <c:otherwise><span class="badge badge-green">In Stock</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="action-btns">
                                        <button class="btn-edit" onclick="openEditProductModal('${p.id}','${p.name}','${p.barcode}','${p.purchasePrice}','${p.sellingPrice}','${p.quantityInStock}','${p.reorderLevel}','${p.supplier.id}')">Edit</button>
                                        <button class="btn-del"  onclick="openDeleteProductModal('${p.id}','${p.name}')">Delete</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ══ SUPPLIERS ══ -->
    <div class="page-section" id="sec-suppliers">
        <div class="sec-header">
            <div>
                <div class="sec-eyebrow">Supply Chain</div>
                <div class="sec-title">Suppliers</div>
                <div class="sec-sub">Manage suppliers, track balances, and supply relationships</div>
            </div>
            <button class="btn-primary" onclick="openAddSupplierModal()"><i class="fas fa-plus-circle"></i> Add Supplier</button>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-lbl">Total Suppliers</div>
                <div class="stat-val"><c:choose><c:when test="${not empty supplierList}">${supplierList.size()}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Active partners</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Total Owed</div>
                <div class="stat-val" style="color:var(--red);">Rwf <c:choose><c:when test="${not empty totalOwed}"><fmt:formatNumber value="${totalOwed}" pattern="#,##0"/></c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Outstanding balance</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Paid This Month</div>
                <div class="stat-val">Rwf <c:choose><c:when test="${not empty paidThisMonth}"><fmt:formatNumber value="${paidThisMonth}" pattern="#,##0"/></c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Cleared balances</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Products Supplied</div>
                <div class="stat-val"><c:choose><c:when test="${not empty totalProducts}">${totalProducts}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">Across all suppliers</div>
            </div>
        </div>

        <div class="table-wrap">
            <div class="table-hdr">
                <span class="table-hdr-title">Supplier Directory</span>
                <span class="table-hdr-count"><c:choose><c:when test="${not empty supplierList}">${supplierList.size()} suppliers</c:when><c:otherwise>0 suppliers</c:otherwise></c:choose></span>
            </div>
            <c:choose>
                <c:when test="${empty supplierList}">
                    <div class="empty-state"><div class="empty-icon"><i class="fas fa-people-arrows"></i></div>No suppliers added yet.</div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead><tr><th>#</th><th>Company</th><th>Contact</th><th>Phone</th><th>Email</th><th>Balance Owed</th><th>Status</th><th>Actions</th></tr></thead>
                        <tbody>
                        <c:forEach var="sup" items="${supplierList}" varStatus="vs">
                            <tr>
                                <td class="td-muted">${vs.count}</td>
                                <td class="td-green">${sup.name}</td>
                                <td class="td-muted">${sup.contactPerson}</td>
                                <td class="td-muted">${sup.phone}</td>
                                <td class="td-muted">${sup.email}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${sup.balanceOwed > 0}"><span style="color:var(--red);">Rwf <fmt:formatNumber value="${sup.balanceOwed}" pattern="#,##0.00"/></span></c:when>
                                        <c:otherwise><span style="color:var(--green);">Rwf 0.00</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${sup.balanceOwed > 0}"><span class="badge badge-red">Owes</span></c:when>
                                        <c:otherwise><span class="badge badge-green">Clear</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="action-btns">
                                        <button class="btn-edit" onclick="openEditSupplierModal('${sup.id}','${sup.name}','${sup.contactPerson}','${sup.phone}','${sup.email}','${sup.balanceOwed}')">Edit</button>
                                        <button class="btn-del"  onclick="openDeleteSupplierModal('${sup.id}','${sup.name}')">Delete</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ══ CUSTOMER MANAGEMENT ══ -->
    <div class="page-section" id="sec-customers">
        <div class="sec-header">
            <div>
                <div class="sec-eyebrow">Client Base</div>
                <div class="sec-title">Customer Management</div>
                <div class="sec-sub">View and manage your registered customers and their contact details</div>
            </div>
            <button class="btn-primary" onclick="openAddCustomerModal()"><i class="fas fa-plus-circle"></i> Add Customer</button>
        </div>

        <div class="table-wrap">
            <div class="table-hdr">
                <span class="table-hdr-title">Customer List</span>
                <span class="table-hdr-count"><c:choose><c:when test="${not empty customerList}">${customerList.size()} customers</c:when><c:otherwise>0 customers</c:otherwise></c:choose></span>
            </div>
            <c:choose>
                <c:when test="${empty customerList}">
                    <div class="empty-state"><div class="empty-icon"><i class="fas fa-users"></i></div>No customers registered yet.</div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead><tr><th>#</th><th>Name</th><th>Phone</th><th>Email</th><th>Address</th><th>Date Added</th><th>Actions</th></tr></thead>
                        <tbody>
                        <c:forEach var="cust" items="${customerList}" varStatus="vs">
                            <tr>
                                <td class="td-muted">${vs.count}</td>
                                <td class="td-green">${cust.name}</td>
                                <td class="td-muted">${cust.phone}</td>
                                <td class="td-muted">${cust.email}</td>
                                <td class="td-muted">${cust.address}</td>
                                <td class="td-muted">${cust.createdAt.toLocalDate()}</td>
                                <td>
                                    <div class="action-btns">
                                        <button class="btn-edit" 
                                                data-id="${cust.id}" 
                                                data-name="${fn:escapeXml(cust.name)}" 
                                                data-phone="${cust.phone}" 
                                                data-email="${cust.email}" 
                                                data-address="${fn:escapeXml(cust.address)}"
                                                onclick="openEditCustomerModalFromBtn(this)">Edit</button>
                                        <button class="btn-del"  
                                                data-id="${cust.id}" 
                                                data-name="${fn:escapeXml(cust.name)}"
                                                onclick="openDeleteCustomerModalFromBtn(this)">Delete</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ══ SALES MANAGEMENT ══ -->
    <div class="page-section" id="sec-sales">
        <div class="sec-header">
            <div>
                <div class="sec-eyebrow">Trader Panel</div>
                <div class="sec-title">Sales Management</div>
                <div class="sec-sub">Record, track, and manage your sales transactions</div>
            </div>
            <button class="btn-primary" onclick="openAddSaleModal()">
                <i class="fa-solid fa-plus"></i> Add New Sale
            </button>
        </div>

        <!-- STATS -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-lbl">Total Sales</div>
                <div class="stat-val"><c:choose><c:when test="${not empty salesList}">${salesList.size()}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">In current view</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Total Revenue</div>
                <div class="stat-val">Rwf <c:choose><c:when test="${not empty totalRevenue}"><fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/></c:when><c:otherwise>0.00</c:otherwise></c:choose></div>
                <div class="stat-hint">Current filter</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">This Month</div>
                <div class="stat-val">Rwf <c:choose><c:when test="${not empty monthRevenue}"><fmt:formatNumber value="${monthRevenue}" pattern="#,##0.00"/></c:when><c:otherwise>0.00</c:otherwise></c:choose></div>
                <div class="stat-hint">Current month</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Avg Sale Value</div>
                <div class="stat-val">Rwf <c:choose><c:when test="${not empty avgSaleValue}"><fmt:formatNumber value="${avgSaleValue}" pattern="#,##0.00"/></c:when><c:otherwise>0.00</c:otherwise></c:choose></div>
                <div class="stat-hint">Per transaction</div>
            </div>
        </div>

        <!-- FILTER -->
        <form method="get" action="${pageContext.request.contextPath}/dashboard">
            <input type="hidden" name="section" value="sales"/>
            <div style="display:flex; align-items:center; gap:12px; margin-bottom:18px; flex-wrap:wrap;">
                <div style="display:flex; align-items:center; gap:8px;">
                    <span style="font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); white-space:nowrap;">From</span>
                    <input type="date" class="field" style="width: auto; padding: 6px 10px;" name="dateFrom" value="${param.dateFrom}"/>
                </div>
                <div style="display:flex; align-items:center; gap:8px;">
                    <span style="font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); white-space:nowrap;">To</span>
                    <input type="date" class="field" style="width: auto; padding: 6px 10px;" name="dateTo" value="${param.dateTo}"/>
                </div>
                <div style="display:flex; align-items:center; gap:8px;">
                    <span style="font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); white-space:nowrap;">Product</span>
                    <div class="select-wrap">
                        <select class="field" style="width: auto; padding: 6px 30px 6px 10px;" name="productFilter">
                            <option value="">All Products</option>
                            <c:forEach var="product" items="${productList}">
                                <option value="${product.id}" <c:if test="${param.productFilter == product.id}">selected</c:if>>${product.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn-primary" style="padding: 6px 14px; font-size: 11px;"><i class="fa-solid fa-filter"></i> Apply</button>
                <a href="${pageContext.request.contextPath}/dashboard?section=sales" class="btn-cancel" style="padding: 6px 14px; font-size: 11px; text-decoration: none;"><i class="fa-solid fa-xmark"></i> Clear</a>
            </div>
        </form>

        <!-- TABLE -->
        <div class="table-wrap">
            <div class="table-hdr">
                <span class="table-hdr-title"><i class="fa-solid fa-list" style="margin-right:6px;"></i>Sales Transactions</span>
                <span class="table-hdr-count"><c:choose><c:when test="${not empty salesList}">${salesList.size()} record(s)</c:when><c:otherwise>0 records</c:otherwise></c:choose></span>
            </div>
            <c:choose>
                <c:when test="${empty salesList}">
                    <div class="empty-state">
                        <div class="empty-icon"><i class="fa-regular fa-clipboard"></i></div>
                        No sales recorded yet. Click "Add New Sale" to get started.
                    </div>
                </c:when>
                <c:otherwise>
                    <table>
                        <thead>
                        <tr><th>#</th><th>Date</th><th>Product</th><th>Qty</th><th>Unit Price</th><th>Total</th><th>Payment</th><th>Customer</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                        <c:forEach var="sale" items="${salesList}" varStatus="loop">
                            <tr>
                                <td class="td-muted">${loop.count}</td>
                                <td class="td-muted">${sale.saleDate.toLocalDate()}</td>
                                <td class="td-green"><c:choose><c:when test="${not empty sale.saleItems}">${sale.saleItems[0].product.name}</c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                <td><c:choose><c:when test="${not empty sale.saleItems}">${sale.saleItems[0].quantity}</c:when><c:otherwise>0</c:otherwise></c:choose></td>
                                <td><c:choose><c:when test="${not empty sale.saleItems}">Rwf <fmt:formatNumber value="${sale.saleItems[0].priceAtSale}" pattern="#,##0.00"/></c:when><c:otherwise>Rwf 0.00</c:otherwise></c:choose></td>
                                <td class="td-green">Rwf <fmt:formatNumber value="${sale.totalAmount}" pattern="#,##0.00"/></td>
                                <td><span class="badge badge-green">${sale.paymentMethod}</span></td>
                                <td class="td-muted"><c:choose><c:when test="${not empty sale.customer}">${sale.customer.name}</c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                <td>
                                    <div class="action-btns">
                                         <button class="btn-edit" 
                                                 data-id="${sale.id}"
                                                 data-product-id="${not empty sale.saleItems ? sale.saleItems[0].product.id : ''}"
                                                 data-qty="${not empty sale.saleItems ? sale.saleItems[0].quantity : ''}"
                                                 data-price="${not empty sale.saleItems ? sale.saleItems[0].priceAtSale : ''}"
                                                 data-payment="${sale.paymentMethod}"
                                                 data-customer-id="${not empty sale.customer ? sale.customer.id : ''}"
                                                 onclick="openEditSaleModalFromBtn(this)"><i class="fa-solid fa-pen"></i> Edit</button>
                                         <button class="btn-del"  
                                                 data-id="${sale.id}"
                                                 data-product-name="${not empty sale.saleItems ? fn:escapeXml(sale.saleItems[0].product.name) : 'Unknown'}"
                                                 onclick="openDeleteSaleModalFromBtn(this)"><i class="fa-solid fa-trash"></i> Delete</button>
                                     </div>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- ══ SETTINGS ══ -->
    <div class="page-section" id="sec-settings">
        <div class="sec-header">
            <div>
                <div class="sec-eyebrow">Account</div>
                <div class="sec-title">Settings</div>
                <div class="sec-sub">Manage your preferences and account security</div>
            </div>
        </div>

        <div style="display:grid;grid-template-columns:repeat(2,1fr);gap:20px;max-width:800px;">
            <div class="table-wrap" style="padding:22px;">
                <div style="font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;color:var(--text);letter-spacing:0.06em;margin-bottom:16px;text-transform:uppercase;"><i class="fas fa-palette"></i> Appearance</div>
                <div style="display:flex;gap:10px;margin-top:6px;">
                    <button onclick="applyTheme('dark')"  id="btn-dark"  style="flex:1;padding:10px;font-family:'Rajdhani',sans-serif;font-size:12px;font-weight:600;letter-spacing:0.1em;text-transform:uppercase;cursor:pointer;border:1px solid var(--border);color:var(--muted);background:transparent;transition:all 0.2s;border-radius:2px;"><i class="fas fa-moon"></i> Dark</button>
                    <button onclick="applyTheme('light')" id="btn-light" style="flex:1;padding:10px;font-family:'Rajdhani',sans-serif;font-size:12px;font-weight:600;letter-spacing:0.1em;text-transform:uppercase;cursor:pointer;border:1px solid var(--border);color:var(--muted);background:transparent;transition:all 0.2s;border-radius:2px;"><i class="fas fa-sun"></i> Light</button>
                </div>
            </div>

            <div class="table-wrap" style="padding:22px;">
                <div style="font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;color:var(--text);letter-spacing:0.06em;margin-bottom:16px;text-transform:uppercase;"><i class="fas fa-user-circle"></i> Profile</div>
                <div style="font-size:12px;color:var(--muted);margin-bottom:4px;">Name</div>
                <div style="font-size:14px;color:var(--text);font-weight:500;margin-bottom:12px;">${sessionScope.currentUser.name}</div>
                <div style="font-size:12px;color:var(--muted);margin-bottom:4px;">Email</div>
                <div style="font-size:14px;color:var(--green);margin-bottom:12px;">${sessionScope.currentUser.email}</div>
                <div style="font-size:12px;color:var(--muted);margin-bottom:4px;">Role</div>
                <span class="badge badge-green">${sessionScope.currentUser.role}</span>
            </div>

            <div class="table-wrap" style="padding:22px;grid-column:1/-1;">
                <div style="font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;color:var(--text);letter-spacing:0.06em;margin-bottom:16px;text-transform:uppercase;"><i class="fas fa-lock"></i> Change Password</div>
                <form action="${pageContext.request.contextPath}/user" method="post" style="display:grid;grid-template-columns:repeat(3,1fr);gap:14px;align-items:end;">
                    <input type="hidden" name="action" value="changePassword"/>
                    <div class="field" style="margin:0;"><label>Current Password</label><input type="password" name="currentPassword" placeholder="••••••••" required/></div>
                    <div class="field" style="margin:0;"><label>New Password</label><input type="password" name="newPassword" placeholder="••••••••" required/></div>
                    <div class="field" style="margin:0;"><label>Confirm New Password</label><input type="password" name="confirmPassword" placeholder="••••••••" required/></div>
                    <div style="grid-column:1/-1;"><button type="submit" class="btn-primary"><i class="fas fa-check"></i> Update Password</button></div>
                </form>
            </div>

            <div class="table-wrap" style="padding:22px;border-color:rgba(255,82,82,0.2);grid-column:1/-1;">
                <div style="font-family:'Rajdhani',sans-serif;font-size:14px;font-weight:700;color:var(--red);letter-spacing:0.06em;margin-bottom:16px;text-transform:uppercase;"><i class="fas fa-exclamation-triangle"></i> Danger Zone</div>
                <div style="display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:14px;">
                    <div>
                        <div style="font-size:14px;color:var(--text);font-weight:500;margin-bottom:4px;">Log Out of StockVerdict</div>
                        <div style="font-size:12px;color:var(--muted);">This will end your current session.</div>
                    </div>
                    <button class="btn-danger" onclick="openLogoutModal()"><i class="fas fa-sign-out-alt"></i> Logout</button>
                </div>
            </div>
        </div>
    </div>

</div><!-- end main-content -->

<!-- ══ MODALS ══ -->

<!-- LOGOUT -->
<div class="modal-overlay" id="logoutModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Confirm</div><div class="modal-title">Log Out</div></div>
            <button class="modal-close" onclick="closeModal('logoutModal')"><i class="fas fa-times"></i></button>
        </div>
        <div class="modal-body">
            <div class="confirm-icon"><i class="fas fa-sign-out-alt"></i></div>
            <div class="confirm-msg">Are you sure you want to log out of StockVerdict?</div>
            <div class="confirm-name">Any unsaved changes will be lost.</div>
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" onclick="closeModal('logoutModal')">Stay Logged In</button>
            <a href="${pageContext.request.contextPath}/user?action=logout" class="btn-danger"><i class="fas fa-check"></i> Yes, Log Out</a>
        </div>
    </div>
</div>

<!-- ADD PRODUCT -->
<div class="modal-overlay" id="addProductModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Inventory</div><div class="modal-title">Add New Product</div></div>
            <button class="modal-close" onclick="closeModal('addProductModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/products" method="post" onsubmit="return validateProductForm(this)">
            <input type="hidden" name="action" value="addProduct"/>
            <div class="modal-body">
                <div class="field-row">
                    <div class="field"><label>Product Name</label><input type="text" name="name" placeholder="e.g. Laptop Pro X" required/></div>
                    <div class="field"><label>Barcode (optional)</label><input type="text" name="barcode" placeholder="e.g. 123456789"/></div>
                </div>
                <div class="field">
                    <label>Supplier</label>
                    <select name="supplierId" required style="width:100%; padding:0.6rem; border:1px solid var(--border-light); border-radius:6px; background:var(--bg-mid); color:var(--text); font-family:inherit;">
                        <option value="">Select a Supplier...</option>
                        <c:forEach var="sup" items="${supplierList}">
                            <option value="${sup.id}">${sup.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="field-row">
                    <div class="field"><label>Cost Price (Rwf)</label><input type="number" name="purchasePrice" step="0.01" min="0" placeholder="0.00" required/></div>
                    <div class="field"><label>Selling Price (Rwf)</label><input type="number" name="sellingPrice" step="0.01" min="0" placeholder="0.00" required/></div>
                </div>
                <div class="field-row">
                    <div class="field"><label>Stock Quantity</label><input type="number" name="quantityInStock" min="0" placeholder="0" required/></div>
                    <div class="field"><label>Reorder Level</label><input type="number" name="reorderLevel" min="0" placeholder="10" required/></div>
                </div>
                <div class="field"><label>Description (optional)</label><textarea name="description" rows="2" placeholder="Brief product description..."></textarea></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addProductModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fas fa-check"></i> Save Product</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT PRODUCT -->
<div class="modal-overlay" id="editProductModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Inventory</div><div class="modal-title">Edit Product</div></div>
            <button class="modal-close" onclick="closeModal('editProductModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/products" method="post" onsubmit="return validateProductForm(this)">
            <input type="hidden" name="action" value="updateProduct"/>
            <input type="hidden" name="id" id="editProductId"/>
            <div class="modal-body">
                <div class="field-row">
                    <div class="field"><label>Product Name</label><input type="text" name="name" id="editProductName" required/></div>
                    <div class="field"><label>Barcode (optional)</label><input type="text" name="barcode" id="editProductBarcode"/></div>
                </div>
                <div class="field">
                    <label>Supplier</label>
                    <select name="supplierId" id="editProductSupplier" required style="width:100%; padding:0.6rem; border:1px solid var(--border-light); border-radius:6px; background:var(--bg-mid); color:var(--text); font-family:inherit;">
                        <option value="">Select a Supplier...</option>
                        <c:forEach var="sup" items="${supplierList}">
                            <option value="${sup.id}">${sup.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="field-row">
                    <div class="field"><label>Cost Price (Rwf)</label><input type="number" name="purchasePrice" id="editCostPrice" step="0.01" min="0" required/></div>
                    <div class="field"><label>Selling Price (Rwf)</label><input type="number" name="sellingPrice" id="editSellingPrice" step="0.01" min="0" required/></div>
                </div>
                <div class="field-row">
                    <div class="field"><label>Stock Quantity</label><input type="number" name="quantityInStock" id="editStockQty" min="0" required/></div>
                    <div class="field"><label>Reorder Level</label><input type="number" name="reorderLevel" id="editProductReorder" min="0" required/></div>
                </div>
                <div class="field"><label>Description (optional)</label><textarea name="description" id="editProductDesc" rows="2"></textarea></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editProductModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fas fa-check"></i> Update Product</button>
            </div>
        </form>
    </div>
</div>

<!-- DELETE PRODUCT -->
<div class="modal-overlay" id="deleteProductModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Confirm</div><div class="modal-title">Delete Product</div></div>
            <button class="modal-close" onclick="closeModal('deleteProductModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/products" method="post">
            <input type="hidden" name="action" value="deleteProduct"/>
            <input type="hidden" name="id" id="deleteProductId"/>
            <div class="modal-body">
                <div class="confirm-icon"><i class="fas fa-trash-alt"></i></div>
                <div class="confirm-msg">Permanently delete this product?</div>
                <div class="confirm-name" id="deleteProductName"></div>
                <div class="confirm-msg" style="font-size:12px;">This cannot be undone.</div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('deleteProductModal')">Cancel</button>
                <button type="submit" class="btn-danger"><i class="fas fa-check"></i> Yes, Delete</button>
            </div>
        </form>
    </div>
</div>

<!-- ADD SUPPLIER -->
<div class="modal-overlay" id="addSupplierModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Supply Chain</div><div class="modal-title">Add Supplier</div></div>
            <button class="modal-close" onclick="closeModal('addSupplierModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/supplier" method="post">
            <input type="hidden" name="action" value="addSupplier"/>
            <div class="modal-body">
                <div class="field-row">
                    <div class="field"><label>Company Name</label><input type="text" name="name" placeholder="e.g. TechDistrib Ltd" required/></div>
                    <div class="field"><label>Contact Person</label><input type="text" name="contactPerson" placeholder="e.g. John Doe"/></div>
                </div>
                <div class="field-row">
                    <div class="field"><label>Phone</label><input type="text" name="phone" placeholder="+250 ..."/></div>
                    <div class="field"><label>Email</label><input type="email" name="email" placeholder="supplier@example.com"/></div>
                </div>
                <div class="field-row">
                    <div class="field"><label>Address</label><input type="text" name="address" placeholder="Kigali, Rwanda"/></div>
                    <div class="field"><label>Opening Balance Owed (Rwf)</label><input type="number" name="balanceOwed" step="0.01" min="0" value="0.00"/></div>
                </div>
                <div class="field"><label>Notes (optional)</label><textarea name="notes" rows="2" placeholder="Any additional information..."></textarea></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addSupplierModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fas fa-check"></i> Save Supplier</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT SUPPLIER -->
<div class="modal-overlay" id="editSupplierModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Supply Chain</div><div class="modal-title">Edit Supplier</div></div>
            <button class="modal-close" onclick="closeModal('editSupplierModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/supplier" method="post">
            <input type="hidden" name="action" value="updateSupplier"/>
            <input type="hidden" name="id" id="editSupplierId"/>
            <div class="modal-body">
                <div class="field-row">
                    <div class="field"><label>Company Name</label><input type="text" name="name" id="editSupplierName" required/></div>
                    <div class="field"><label>Contact Person</label><input type="text" name="contactPerson" id="editSupplierContact"/></div>
                </div>
                <div class="field-row">
                    <div class="field"><label>Phone</label><input type="text" name="phone" id="editSupplierPhone"/></div>
                    <div class="field"><label>Email</label><input type="email" name="email" id="editSupplierEmail"/></div>
                </div>
                <div class="field"><label>Balance Owed (Rwf)</label><input type="number" name="balanceOwed" id="editSupplierBalance" step="0.01" min="0"/></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editSupplierModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fas fa-check"></i> Update Supplier</button>
            </div>
        </form>
    </div>
</div>

<!-- DELETE SUPPLIER -->
<div class="modal-overlay" id="deleteSupplierModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Confirm Action</div><div class="modal-title">Delete Supplier</div></div>
            <button class="modal-close" onclick="closeModal('deleteSupplierModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/supplier" method="post">
            <input type="hidden" name="action" value="deleteSupplier"/>
            <input type="hidden" name="id" id="deleteSupplierId"/>
            <div class="modal-body">
                <div class="confirm-icon"><i class="fas fa-exclamation-triangle" style="color:var(--red);"></i></div>
                <div class="confirm-msg">You are about to permanently delete this supplier.</div>
                <div class="confirm-name" id="deleteSupplierName"></div>
                <div class="confirm-msg">All products associated with this supplier will lose their supplier link. This action cannot be undone.</div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('deleteSupplierModal')">Cancel</button>
                <button type="submit" class="btn-danger"><i class="fas fa-trash"></i> Yes, Delete</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ ADD SALE MODAL ══ -->
<div class="modal-overlay" id="addSaleModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">New Transaction</div><div class="modal-title">Add New Sale</div></div>
            <button class="modal-close" onclick="closeModal('addSaleModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/sales" method="post" id="addSaleForm">
            <input type="hidden" name="action" value="createSale"/>
            <div class="modal-body">
                <div class="field">
                    <label>Product</label>
                    <div style="position:relative;">
                        <input type="text" id="addSearchInput" list="productsList" placeholder="Type to search products..." oninput="onProductSearchSelect(this)" autocomplete="off" required>
                        <datalist id="productsList">
                            <c:forEach var="product" items="${productList}">
                                <option value="${product.name} [ID: ${product.id}]" data-id="${product.id}" data-price="${product.sellingPrice}" data-stock="${product.quantityInStock}"></option>
                            </c:forEach>
                        </datalist>
                        <input type="hidden" name="productId" id="hiddenProductId" required>
                    </div>
                </div>
                <div class="field-row">
                    <div class="field">
                        <label>Quantity</label>
                        <input type="number" name="quantity" id="addQty" min="1" placeholder="e.g. 5" required oninput="calcTotal('add')"/>
                        <div style="font-size:11px; color:var(--muted); margin-top:4px;" id="stockNote"></div>
                    </div>
                    <div class="field">
                        <label>Unit Price (Rwf)</label>
                        <input type="number" name="unitPrice" id="addPrice" step="0.01" min="0" placeholder="0.00" required oninput="calcTotal('add')"/>
                    </div>
                </div>
                <div class="field-row">
                    <div class="field">
                        <label>Payment Method</label>
                        <div class="select-wrap">
                            <select name="paymentMethod" required>
                                <option value="CASH">Cash</option>
                                <option value="CARD">Card</option>
                                <option value="MOBILE">Mobile Money</option>
                                <option value="TRANSFER">Bank Transfer</option>
                            </select>
                        </div>
                    </div>
                    <div class="field">
                        <label>Customer (optional)</label>
                        <div class="select-wrap">
                            <select name="customerId" id="addCustomerSelect" onchange="toggleNewCustomer()">
                                <option value="">— Walk-in customer —</option>
                                <option value="NEW" style="color:var(--green); font-weight:600;">+ Register New Customer</option>
                                <c:forEach var="customer" items="${customerList}">
                                    <option value="${customer.id}">${customer.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="field-row" id="newCustomerFields" style="display:none;">
                    <div class="field"><label>New Customer Name</label><input type="text" name="newCustomerName" id="newCName"/></div>
                    <div class="field"><label>New Customer Phone</label><input type="text" name="newCustomerPhone" id="newCPhone"/></div>
                </div>
                <div style="background:var(--green-glow); border:1px solid rgba(0,230,118,0.2); padding:12px 16px; margin-bottom:16px; display:flex; align-items:center; justify-content:space-between;">
                    <span style="font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.18em; text-transform:uppercase; color:var(--muted);">Total Amount</span>
                    <span style="font-family:'Rajdhani',sans-serif; font-size:22px; font-weight:700; color:var(--green);" id="addTotal">Rwf 0.00</span>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addSaleModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fa-solid fa-floppy-disk"></i> Save Sale</button>
            </div>
        </form>
    </div>
</div>

<!-- ADD CUSTOMER MODAL -->
<div class="modal-overlay" id="addCustomerModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Client Base</div><div class="modal-title">Add New Customer</div></div>
            <button class="modal-close" onclick="closeModal('addCustomerModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/customer" method="post">
            <input type="hidden" name="action" value="addCustomer"/>
            <div class="modal-body">
                <div class="field"><label>Full Name</label><input type="text" name="name" placeholder="e.g. Jean Doe" required/></div>
                <div class="field-row">
                    <div class="field"><label>Phone Number</label><input type="text" name="phone" placeholder="+250 ..."/></div>
                    <div class="field"><label>Email Address</label><input type="email" name="email" placeholder="customer@example.com"/></div>
                </div>
                <div class="field"><label>Physical Address</label><input type="text" name="address" placeholder="e.g. Kigali, Rwanda"/></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addCustomerModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fas fa-check"></i> Save Customer</button>
            </div>
        </form>
    </div>
</div>

<!-- EDIT CUSTOMER MODAL -->
<div class="modal-overlay" id="editCustomerModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Client Base</div><div class="modal-title">Edit Customer</div></div>
            <button class="modal-close" onclick="closeModal('editCustomerModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/customer" method="post">
            <input type="hidden" name="action" value="updateCustomer"/>
            <input type="hidden" name="id" id="editCustomerId"/>
            <div class="modal-body">
                <div class="field"><label>Full Name</label><input type="text" name="name" id="editCustomerName" required/></div>
                <div class="field-row">
                    <div class="field"><label>Phone Number</label><input type="text" name="phone" id="editCustomerPhone"/></div>
                    <div class="field"><label>Email Address</label><input type="email" name="email" id="editCustomerEmail"/></div>
                </div>
                <div class="field"><label>Physical Address</label><input type="text" name="address" id="editCustomerAddress"/></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editCustomerModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fas fa-check"></i> Update Customer</button>
            </div>
        </form>
    </div>
</div>

<!-- DELETE CUSTOMER MODAL -->
<div class="modal-overlay" id="deleteCustomerModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Confirm Action</div><div class="modal-title">Delete Customer</div></div>
            <button class="modal-close" onclick="closeModal('deleteCustomerModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/customer" method="post">
            <input type="hidden" name="action" value="deleteCustomer"/>
            <input type="hidden" name="id" id="deleteCustomerId"/>
            <div class="modal-body">
                <div class="confirm-icon"><i class="fas fa-exclamation-triangle" style="color:var(--red);"></i></div>
                <div class="confirm-msg">Are you sure you want to delete this customer?</div>
                <div class="confirm-name" id="deleteCustomerName"></div>
                <div class="confirm-msg">This action cannot be undone.</div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('deleteCustomerModal')">Cancel</button>
                <button type="submit" class="btn-danger"><i class="fas fa-trash"></i> Yes, Delete</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ EDIT SALE MODAL ══ -->
<div class="modal-overlay" id="editSaleModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Update Transaction</div><div class="modal-title">Edit Sale</div></div>
            <button class="modal-close" onclick="closeModal('editSaleModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/sales" method="post">
            <input type="hidden" name="action" value="updateSale"/>
            <input type="hidden" name="saleId" id="editSaleId"/>
            <div class="modal-body">
                <div class="field">
                    <label>Product</label>
                    <div class="select-wrap">
                        <select name="productId" id="editProduct" required>
                            <option value="">— Select a product —</option>
                            <c:forEach var="product" items="${productList}">
                                <option value="${product.id}" data-price="${product.sellingPrice}">${product.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div class="field-row">
                    <div class="field"><label>Quantity</label><input type="number" name="quantity" id="editQty" min="1" required oninput="calcTotal('edit')"/></div>
                    <div class="field"><label>Unit Price (Rwf)</label><input type="number" name="unitPrice" id="editPrice" step="0.01" min="0" required oninput="calcTotal('edit')"/></div>
                </div>
                <div class="field-row">
                    <div class="field">
                        <label>Payment Method</label>
                        <div class="select-wrap">
                            <select name="paymentMethod" id="editPayment">
                                <option value="CASH">Cash</option>
                                <option value="CARD">Card</option>
                                <option value="MOBILE">Mobile Money</option>
                                <option value="TRANSFER">Bank Transfer</option>
                            </select>
                        </div>
                    </div>
                    <div class="field">
                        <label>Customer (optional)</label>
                        <div class="select-wrap">
                            <select name="customerId" id="editCustomer">
                                <option value="">— Walk-in customer —</option>
                                <c:forEach var="customer" items="${customerList}">
                                    <option value="${customer.id}">${customer.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>
                <div style="background:var(--green-glow); border:1px solid rgba(0,230,118,0.2); padding:12px 16px; margin-bottom:16px; display:flex; align-items:center; justify-content:space-between;">
                    <span style="font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.18em; text-transform:uppercase; color:var(--muted);">Total Amount</span>
                    <span style="font-family:'Rajdhani',sans-serif; font-size:22px; font-weight:700; color:var(--green);" id="editTotal">Rwf 0.00</span>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editSaleModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fa-solid fa-floppy-disk"></i> Update Sale</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ DELETE SALE CONFIRM MODAL ══ -->
<div class="modal-overlay" id="deleteSaleModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Confirm Action</div><div class="modal-title">Delete Sale</div></div>
            <button class="modal-close" onclick="closeModal('deleteSaleModal')"><i class="fas fa-times"></i></button>
        </div>
        <form action="${pageContext.request.contextPath}/sales" method="post">
            <input type="hidden" name="action" value="deleteSale"/>
            <input type="hidden" name="saleId" id="deleteSaleId"/>
            <div class="modal-body">
                <div class="confirm-icon"><i class="fa-solid fa-triangle-exclamation" style="color:var(--red);font-size:38px;"></i></div>
                <div class="confirm-msg">You are about to permanently delete this sale record.</div>
                <div class="confirm-name" id="deleteSaleName"></div>
                <div class="confirm-msg">This action cannot be undone. associated stock will be returned to inventory.</div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('deleteSaleModal')">Cancel</button>
                <button type="submit" class="btn-danger"><i class="fa-solid fa-trash"></i> Yes, Delete</button>
            </div>
        </form>
    </div>
</div>

<script>
    // --- Theme Control ---
    const THEME_KEY = 'sv_theme';
    function applyTheme(t) {
        if (!t) t = 'dark';
        document.documentElement.setAttribute('data-theme', t);
        const btn = document.getElementById('themeToggle');
        if (btn) btn.innerHTML = t === 'light' ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
        
        const btnDark = document.getElementById('btn-dark');
        const btnLight = document.getElementById('btn-light');
        if (btnDark && btnLight) {
            btnDark.style.borderColor = t === 'dark' ? 'var(--green)' : 'var(--border)';
            btnDark.style.color = t === 'dark' ? 'var(--text)' : 'var(--muted)';
            btnLight.style.borderColor = t === 'light' ? 'var(--green)' : 'var(--border)';
            btnLight.style.color = t === 'light' ? 'var(--text)' : 'var(--muted)';
        }
        try {
            localStorage.setItem(THEME_KEY, t);
        } catch(e) { console.warn('localStorage not available'); }
    }
    function toggleTheme() { 
        const current = document.documentElement.getAttribute('data-theme') || 'dark';
        applyTheme(current === 'dark' ? 'light' : 'dark'); 
    }
    function toggleSidebar() {
        const sb = document.getElementById('sidebar');
        if (sb) sb.classList.toggle('open');
    }
    // Set theme immediately to avoid flash
    try {
        applyTheme(localStorage.getItem(THEME_KEY) || 'dark');
    } catch(e) {
        applyTheme('dark');
    }

    // --- Section Switching ---
    function showSection(secId, navItem) {
        console.log('Switching to section:', secId);
        const sections = document.querySelectorAll('.page-section');
        const items = document.querySelectorAll('.nav-item');
        
        sections.forEach(s => s.classList.remove('active'));
        const target = document.getElementById('sec-' + secId);
        if (target) {
            target.classList.add('active');
        } else {
            console.error('Target section not found: sec-' + secId);
        }
        
        items.forEach(i => i.classList.remove('active'));
        const activeNav = navItem || document.getElementById('nav-' + secId);
        if (activeNav) activeNav.classList.add('active');
        
        const titleMap = { 'dashboard':'Dashboard', 'stock':'Inventory', 'suppliers':'Suppliers', 'settings':'Settings', 'sales':'Sales', 'customers':'Customers' };
        const titleEl = document.getElementById('topbarTitle');
        if (titleEl) titleEl.textContent = titleMap[secId] || 'Dashboard';
        
        try {
            const url = new URL(window.location);
            url.searchParams.set('section', secId);
            window.history.replaceState({}, '', url);
        } catch(e) { console.warn('History API not available'); }
    }

    // Modal Control
    function openModal(id)  { document.getElementById(id).classList.add('open'); document.body.style.overflow='hidden'; }
    function closeModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow=''; }
    document.querySelectorAll('.modal-overlay').forEach(o => o.addEventListener('click', e => { if(e.target===o){o.classList.remove('open');document.body.style.overflow='';} }));

    // Product Modals
    function openAddProductModal()    { openModal('addProductModal'); }
    function openEditProductModal(id, name, bc, cp, sp, qty, rl, sid) {
        document.getElementById('editProductId').value = id;
        document.getElementById('editProductName').value = name;
        document.getElementById('editProductBarcode').value = bc;
        document.getElementById('editCostPrice').value = cp;
        document.getElementById('editSellingPrice').value = sp;
        document.getElementById('editStockQty').value = qty;
        document.getElementById('editProductReorder').value = rl;
        document.getElementById('editProductSupplier').value = sid;
        openModal('editProductModal');
    }
    function openDeleteProductModal(id, name) {
        const idEl = document.getElementById('deleteProductId');
        const nameEl = document.getElementById('deleteProductName');
        if (idEl) idEl.value = id;
        if (nameEl) nameEl.textContent = name;
        openModal('deleteProductModal');
    }

    // Supplier Modals
    function openAddSupplierModal()    { openModal('addSupplierModal'); }
    function openEditSupplierModal(id, name, cp, ph, em, bal) {
        document.getElementById('editSupplierId').value = id;
        document.getElementById('editSupplierName').value = name;
        document.getElementById('editSupplierContact').value = cp;
        document.getElementById('editSupplierPhone').value = ph;
        document.getElementById('editSupplierEmail').value = em;
        document.getElementById('editSupplierBalance').value = bal;
        openModal('editSupplierModal');
    }
    function openDeleteSupplierModal(id, name) {
        const idEl = document.getElementById('deleteSupplierId');
        const nameEl = document.getElementById('deleteSupplierName');
        if (idEl) idEl.value = id;
        if (nameEl) nameEl.textContent = name;
        openModal('deleteSupplierModal');
    }

    // Customer Modals
    function openAddCustomerModal() { openModal('addCustomerModal'); }
    function openEditCustomerModal(id, name, phone, email, address) {
        document.getElementById('editCustomerId').value = id;
        document.getElementById('editCustomerName').value = name;
        document.getElementById('editCustomerPhone').value = phone;
        document.getElementById('editCustomerEmail').value = email;
        document.getElementById('editCustomerAddress').value = address;
        openModal('editCustomerModal');
    }
    function openDeleteCustomerModal(id, name) {
        const idEl = document.getElementById('deleteCustomerId');
        const nameEl = document.getElementById('deleteCustomerName');
        if (idEl) idEl.value = id;
        if (nameEl) nameEl.textContent = name;
        openModal('deleteCustomerModal');
    }

    function openEditCustomerModalFromBtn(btn) {
        const id = btn.getAttribute('data-id');
        const name = btn.getAttribute('data-name');
        const phone = btn.getAttribute('data-phone');
        const email = btn.getAttribute('data-email');
        const address = btn.getAttribute('data-address');
        openEditCustomerModal(id, name, phone, email, address);
    }
    function openDeleteCustomerModalFromBtn(btn) {
        const id = btn.getAttribute('data-id');
        const name = btn.getAttribute('data-name');
        openDeleteCustomerModal(id, name);
    }

    // Sales Modals
    function openAddSaleModal() { openModal('addSaleModal'); }
    function openEditSaleModal(saleId, productId, qty, price, payment, customerId) {
        document.getElementById('editSaleId').value = saleId;
        document.getElementById('editQty').value    = qty;
        document.getElementById('editPrice').value  = price;
        for(let o of document.getElementById('editProduct').options)  { if(o.value==productId)  {o.selected=true;break;} }
        for(let o of document.getElementById('editPayment').options)  { if(o.value==payment)    {o.selected=true;break;} }
        for(let o of document.getElementById('editCustomer').options) { if(o.value==customerId) {o.selected=true;break;} }
        calcTotal('edit');
        openModal('editSaleModal');
    }
    function openDeleteSaleModal(saleId, productName) {
        document.getElementById('deleteSaleId').value = saleId;
        document.getElementById('deleteSaleName').textContent = productName + ' — Sale #' + saleId;
        openModal('deleteSaleModal');
    }

    function openEditSaleModalFromBtn(btn) {
        const saleId = btn.getAttribute('data-id');
        const productId = btn.getAttribute('data-product-id');
        const qty = btn.getAttribute('data-qty');
        const price = btn.getAttribute('data-price');
        const payment = btn.getAttribute('data-payment');
        const customerId = btn.getAttribute('data-customer-id');
        openEditSaleModal(saleId, productId, qty, price, payment, customerId);
    }
    function openDeleteSaleModalFromBtn(btn) {
        const saleId = btn.getAttribute('data-id');
        const productName = btn.getAttribute('data-product-name');
        openDeleteSaleModal(saleId, productName);
    }

    function onProductSearchSelect(input) {
        let val = input.value.trim();
        let dataList = document.getElementById('productsList');
        if (!dataList) return;
        let options = dataList.options;
        let found = false;
        
        // Try exact match first, then try matching the "Name [ID: XX]" format
        for (let i = 0; i < options.length; i++) {
            let optVal = options[i].value;
            if (optVal === val || optVal.split(' [ID:')[0] === val) {
                const hiddenId = document.getElementById('hiddenProductId');
                const priceInput = document.getElementById('addPrice');
                const stockNote = document.getElementById('stockNote');
                
                if (hiddenId) hiddenId.value = options[i].getAttribute('data-id');
                let price = options[i].getAttribute('data-price') || '';
                let stock = options[i].getAttribute('data-stock') || '';
                
                if (priceInput) priceInput.value = price ? parseFloat(price).toFixed(2) : '';
                if (stockNote) {
                    stockNote.textContent = stock ? 'Available: ' + stock + ' units' : '';
                    stockNote.style.color = (parseInt(stock) <= 5) ? 'var(--red)' : 'var(--muted)';
                }
                calcTotal('add');
                found = true;
                break;
            }
        }
        if (!found) {
            const hiddenId = document.getElementById('hiddenProductId');
            const stockNote = document.getElementById('stockNote');
            if (hiddenId) hiddenId.value = '';
            if (stockNote) {
                stockNote.textContent = 'Please select a product from the list.';
                stockNote.style.color = 'var(--red)';
            }
        }
    }

    function toggleNewCustomer() {
        let sel = document.getElementById('addCustomerSelect');
        let fields = document.getElementById('newCustomerFields');
        if (sel.value === 'NEW') {
            fields.style.display = 'flex';
            document.getElementById('newCName').required = true;
        } else {
            fields.style.display = 'none';
            document.getElementById('newCName').required = false;
        }
    }

    function calcTotal(mode) {
        const qty   = parseFloat(document.getElementById(mode+'Qty').value)   || 0;
        const price = parseFloat(document.getElementById(mode+'Price').value) || 0;
        document.getElementById(mode+'Total').textContent = 'Rwf ' + (qty*price).toLocaleString('en-US',{minimumFractionDigits:2,maximumFractionDigits:2});
    }

    function openLogoutModal() { openModal('logoutModal'); }

    function validateProductForm(formObj) {
        const purchase = parseFloat(formObj.elements['purchasePrice'] ? formObj.elements['purchasePrice'].value : formObj.elements['editCostPrice'].value);
        const selling = parseFloat(formObj.elements['sellingPrice'] ? formObj.elements['sellingPrice'].value : formObj.elements['editSellingPrice'].value);
        if (selling < purchase) {
            alert('Selling Price cannot be lower than Purchase Price.');
            return false;
        }
        return true;
    }

    function goBack() { window.history.back(); }

    function updateClock() {
        const el = document.getElementById('sidebarClock');
        if(el) el.textContent = new Date().toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'});
    }
    updateClock(); setInterval(updateClock, 1000);

    // Auto-switch to section based on URL
    window.addEventListener('load', () => {
        const urlParams = new URLSearchParams(window.location.search);
        const section = urlParams.get('section') || 'dashboard';
        showSection(section);
    });

    setTimeout(() => {
        document.querySelectorAll('.alert').forEach(el => { el.style.transition='opacity 0.5s'; el.style.opacity='0'; setTimeout(()=>el.remove(),500); });
    }, 5000);
</script>
</body>
</html>
