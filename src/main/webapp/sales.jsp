<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<c:if test="${empty sessionScope.currentUser}">
    <c:redirect url="${pageContext.request.contextPath}/login.jsp"/>
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockVerdict — Sales</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/moon.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/save.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/check.css"/>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo2.png"/>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:      #00e676; --green-dim:  #00c853;
            --green-glow: rgba(0,230,118,0.18);
            --bg:         #040e07; --bg-card:    rgba(4,18,9,0.95);
            --bg-sidebar: #020a04;
            --border:     rgba(0,230,118,0.15); --border-hi: rgba(0,230,118,0.4);
            --text:       #e4ffe4; --text-sub:   #a8d4b0;
            --muted:      #5a9a6a; --surface:    rgba(0,20,8,0.6);
            --red:        #ff5252; --amber:      #ffb300;
        }
        [data-theme="light"] {
            --green:      #00a84a; --green-dim:  #007a35;
            --green-glow: rgba(0,168,74,0.12);
            --bg:         #f0faf2; --bg-card:    #ffffff;
            --bg-sidebar: #e8f5ec;
            --border:     rgba(0,150,60,0.18); --border-hi: rgba(0,150,60,0.45);
            --text:       #0a2e12; --text-sub:   #2d6e3e;
            --muted:      #4a8a5a; --surface:    rgba(210,240,218,0.7);
        }

        body { font-family:'Inter',sans-serif; background:var(--bg); color:var(--text); min-height:100vh; display:flex; transition:background 0.3s,color 0.3s; overflow-x:hidden; }

        /* ── SIDEBAR ── */
        .sidebar { width:240px; flex-shrink:0; background:var(--bg-sidebar); border-right:1px solid var(--border); display:flex; flex-direction:column; position:fixed; top:0; left:0; bottom:0; z-index:50; }
        .sidebar-top { padding:22px 20px 18px; border-bottom:1px solid var(--border); display:flex; align-items:center; gap:10px; }
        .sidebar-logo { width:36px; height:36px; border-radius:50%; object-fit:contain; border:1px solid var(--border-hi); }
        .sidebar-brand { font-family:'Rajdhani',sans-serif; font-size:17px; font-weight:700; color:var(--green); letter-spacing:0.07em; text-transform:uppercase; }
        .sidebar-user { padding:16px 20px; border-bottom:1px solid var(--border); }
        .sidebar-user-name { font-family:'Rajdhani',sans-serif; font-size:14px; font-weight:600; color:var(--text); }
        .sidebar-user-role { font-size:11px; color:var(--muted); letter-spacing:0.1em; text-transform:uppercase; margin-top:2px; }
        .sidebar-nav { flex:1; padding:12px 0; overflow-y:auto; }
        .nav-section-label { padding:10px 20px 4px; font-family:'Rajdhani',sans-serif; font-size:9px; letter-spacing:0.28em; text-transform:uppercase; color:var(--muted); }
        .nav-item { display:flex; align-items:center; gap:11px; padding:10px 20px; color:var(--muted); text-decoration:none; font-size:13px; font-weight:500; cursor:pointer; border:none; background:none; width:100%; text-align:left; transition:color 0.2s,background 0.2s; border-left:3px solid transparent; }
        .nav-item:hover { color:var(--text); background:var(--green-glow); }
        .nav-item.active { color:var(--green); border-left-color:var(--green); background:var(--green-glow); }
        .nav-item.danger { color:var(--red); }
        .nav-item.danger:hover { background:rgba(255,82,82,0.08); }
        .nav-icon { width:18px; text-align:center; flex-shrink:0; font-size:14px; }
        .sidebar-bottom { padding:14px 0; border-top:1px solid var(--border); }

        /* ── MAIN ── */
        .main-content { margin-left:240px; flex:1; min-height:100vh; display:flex; flex-direction:column; }
        .topbar { height:56px; background:var(--bg-card); border-bottom:1px solid var(--border); display:flex; align-items:center; justify-content:space-between; padding:0 28px; position:sticky; top:0; z-index:40; }
        .topbar-title { font-family:'Rajdhani',sans-serif; font-size:16px; font-weight:600; color:var(--text); letter-spacing:0.06em; text-transform:uppercase; }
        .topbar-right { display:flex; align-items:center; gap:10px; }
        .btn-theme { width:34px; height:34px; background:var(--surface); border:1px solid var(--border); color:var(--muted); cursor:pointer; font-size:14px; display:flex; align-items:center; justify-content:center; transition:border-color 0.2s,color 0.2s; }
        .btn-theme:hover { border-color:var(--green); color:var(--green); }
        .btn-logout-top { display:inline-flex; align-items:center; gap:6px; padding:7px 14px; background:rgba(255,82,82,0.08); border:1px solid rgba(255,82,82,0.3); color:var(--red); font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.14em; text-transform:uppercase; cursor:pointer; transition:background 0.2s; }
        .btn-logout-top:hover { background:rgba(255,82,82,0.18); }

        /* ── CONTENT ── */
        .content { padding:28px; flex:1; }

        /* ── PAGE HEADER ── */
        .sec-header { display:flex; align-items:flex-end; justify-content:space-between; margin-bottom:24px; padding-bottom:18px; border-bottom:1px solid var(--border); }
        .sec-eyebrow { font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.26em; text-transform:uppercase; color:var(--green); margin-bottom:4px; }
        .sec-title { font-family:'Rajdhani',sans-serif; font-size:28px; font-weight:700; color:var(--text); line-height:1; }
        .sec-sub { font-size:13px; color:var(--muted); margin-top:5px; }

        /* ── BUTTONS ── */
        .btn-primary { display:inline-flex; align-items:center; gap:7px; padding:10px 20px; background:var(--green); color:#020e05; border:none; cursor:pointer; font-family:'Rajdhani',sans-serif; font-size:12px; font-weight:700; letter-spacing:0.16em; text-transform:uppercase; box-shadow:0 4px 16px var(--green-glow); transition:background 0.2s,transform 0.1s; text-decoration:none; }
        .btn-primary:hover { background:var(--green-dim); }
        .btn-primary:active { transform:scale(0.98); }

        /* ── STATS ── */
        .stats-row { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:24px; }
        .stat-card { background:var(--surface); border:1px solid var(--border); padding:18px 20px; position:relative; overflow:hidden; }
        .stat-card::after { content:''; position:absolute; bottom:0; left:0; right:0; height:2px; background:linear-gradient(90deg,transparent,var(--green),transparent); opacity:0.35; }
        .stat-lbl { font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); margin-bottom:8px; }
        .stat-val { font-family:'Rajdhani',sans-serif; font-size:26px; font-weight:700; color:var(--green); line-height:1; }
        .stat-hint { font-size:11px; color:var(--muted); margin-top:4px; }

        /* ── FILTER BAR ── */
        .filter-bar { display:flex; align-items:center; gap:12px; margin-bottom:18px; flex-wrap:wrap; }
        .filter-group { display:flex; align-items:center; gap:8px; }
        .filter-label { font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); white-space:nowrap; }
        .filter-input, .filter-select { background:var(--surface); border:1px solid var(--border); color:var(--text); font-family:'Inter',sans-serif; font-size:13px; padding:8px 12px; outline:none; transition:border-color 0.2s; appearance:none; border-radius:0; }
        .filter-input:focus, .filter-select:focus { border-color:var(--green); }
        .filter-input::placeholder { color:rgba(90,154,106,0.4); }
        .select-wrap { position:relative; }
        .select-wrap::after { content:''; position:absolute; right:10px; top:50%; transform:translateY(-50%); pointer-events:none; color:var(--muted); }
        select option { background:#061409; color:var(--text); }
        .btn-filter { padding:8px 16px; background:var(--green-glow); border:1px solid var(--border); color:var(--green); font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.14em; text-transform:uppercase; cursor:pointer; transition:background 0.2s; }
        .btn-filter:hover { background:rgba(0,230,118,0.2); }
        .btn-reset { padding:8px 16px; background:transparent; border:1px solid rgba(255,82,82,0.25); color:var(--red); font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.14em; text-transform:uppercase; cursor:pointer; text-decoration:none; display:inline-flex; align-items:center; transition:background 0.2s; }
        .btn-reset:hover { background:rgba(255,82,82,0.1); }

        /* ── TABLE ── */
        .table-wrap { background:var(--surface); border:1px solid var(--border); overflow:hidden; margin-bottom:24px; }
        .table-hdr { display:flex; align-items:center; justify-content:space-between; padding:13px 18px; border-bottom:1px solid var(--border); background:rgba(0,230,118,0.03); }
        .table-hdr-title { font-family:'Rajdhani',sans-serif; font-size:12px; font-weight:600; letter-spacing:0.14em; text-transform:uppercase; color:var(--text); }
        .table-hdr-count { font-size:11px; color:var(--muted); }
        table { width:100%; border-collapse:collapse; }
        thead th { padding:11px 16px; font-family:'Rajdhani',sans-serif; font-size:10px; font-weight:600; letter-spacing:0.18em; text-transform:uppercase; color:var(--muted); border-bottom:1px solid var(--border); text-align:left; }
        thead th:last-child { text-align:center; }
        tbody tr { border-bottom:1px solid rgba(0,230,118,0.07); transition:background 0.15s; }
        tbody tr:last-child { border-bottom:none; }
        tbody tr:hover { background:var(--green-glow); }
        tbody td { padding:12px 16px; font-size:13px; color:var(--text); vertical-align:middle; }
        tbody td:last-child { text-align:center; }
        .td-green { color:var(--green); font-family:'Rajdhani',sans-serif; font-size:14px; font-weight:600; }
        .td-muted { color:var(--muted); font-size:12px; }
        .badge { display:inline-block; padding:2px 10px; font-family:'Rajdhani',sans-serif; font-size:10px; font-weight:600; letter-spacing:0.12em; text-transform:uppercase; border:1px solid; }
        .badge-green { border-color:rgba(0,230,118,0.3); color:var(--green); background:var(--green-glow); }
        .action-btns { display:flex; gap:6px; justify-content:center; }
        .btn-edit { padding:4px 10px; background:var(--green-glow); border:1px solid rgba(0,230,118,0.25); color:var(--green); font-family:'Rajdhani',sans-serif; font-size:10px; font-weight:600; letter-spacing:0.1em; text-transform:uppercase; cursor:pointer; transition:background 0.2s; }
        .btn-edit:hover { background:rgba(0,230,118,0.2); }
        .btn-del { padding:4px 10px; background:rgba(255,82,82,0.08); border:1px solid rgba(255,82,82,0.25); color:var(--red); font-family:'Rajdhani',sans-serif; font-size:10px; font-weight:600; letter-spacing:0.1em; text-transform:uppercase; cursor:pointer; transition:background 0.2s; }
        .btn-del:hover { background:rgba(255,82,82,0.18); }
        .empty-state { text-align:center; padding:50px 20px; color:var(--muted); font-size:13px; }
        .empty-icon { font-size:36px; margin-bottom:12px; opacity:0.4; }

        /* ── MODAL ── */
        .modal-overlay { display:none; position:fixed; inset:0; z-index:500; background:rgba(2,8,4,0.82); backdrop-filter:blur(4px); align-items:center; justify-content:center; padding:20px; }
        .modal-overlay.open { display:flex; }
        .modal { background:var(--bg-card); border:1px solid var(--border-hi); width:100%; max-width:520px; box-shadow:0 0 60px var(--green-glow); animation:modalIn 0.22s ease both; }
        @keyframes modalIn { from{opacity:0;transform:translateY(12px) scale(0.98)} to{opacity:1;transform:translateY(0) scale(1)} }
        .modal-hdr { display:flex; align-items:center; justify-content:space-between; padding:18px 22px 14px; border-bottom:1px solid var(--border); }
        .modal-eyebrow { font-family:'Rajdhani',sans-serif; font-size:9px; letter-spacing:0.26em; text-transform:uppercase; color:var(--green); margin-bottom:2px; }
        .modal-title   { font-family:'Rajdhani',sans-serif; font-size:18px; font-weight:700; color:var(--text); }
        .modal-close   { background:none; border:none; cursor:pointer; color:var(--muted); font-size:18px; padding:4px 8px; transition:color 0.2s; }
        .modal-close:hover { color:var(--text); }
        .modal-body { padding:22px; }
        .modal-footer { display:flex; gap:10px; justify-content:flex-end; padding:14px 22px; border-top:1px solid var(--border); }
        .field { margin-bottom:16px; }
        .field label { display:block; font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.2em; text-transform:uppercase; color:var(--muted); margin-bottom:6px; }
        .field input, .field select { width:100%; background:var(--surface); border:1px solid var(--border); color:var(--text); font-family:'Inter',sans-serif; font-size:13px; padding:10px 13px; outline:none; transition:border-color 0.2s,box-shadow 0.2s; appearance:none; border-radius:0; }
        .field input:focus, .field select:focus { border-color:var(--green); box-shadow:0 0 0 1px var(--green-glow); }
        .field input::placeholder { color:rgba(90,154,106,0.4); }
        .field-note { font-size:11px; color:var(--muted); margin-top:4px; }
        .field-row { display:flex; gap:12px; }
        .field-row .field { flex:1; }
        .total-preview { background:var(--green-glow); border:1px solid rgba(0,230,118,0.2); padding:12px 16px; margin-bottom:16px; display:flex; align-items:center; justify-content:space-between; }
        .total-lbl { font-family:'Rajdhani',sans-serif; font-size:10px; letter-spacing:0.18em; text-transform:uppercase; color:var(--muted); }
        .total-val { font-family:'Rajdhani',sans-serif; font-size:22px; font-weight:700; color:var(--green); }
        .btn-cancel { padding:9px 18px; background:transparent; border:1px solid var(--border); color:var(--muted); font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.14em; text-transform:uppercase; cursor:pointer; transition:border-color 0.2s,color 0.2s; }
        .btn-cancel:hover { border-color:var(--border-hi); color:var(--text); }
        .btn-danger { padding:9px 18px; background:rgba(255,82,82,0.1); border:1px solid var(--red); color:var(--red); font-family:'Rajdhani',sans-serif; font-size:11px; font-weight:600; letter-spacing:0.14em; text-transform:uppercase; cursor:pointer; transition:background 0.2s; text-decoration:none; display:inline-flex; align-items:center; }
        .btn-danger:hover { background:rgba(255,82,82,0.2); }
        .confirm-icon { text-align:center; font-size:36px; margin-bottom:10px; }
        .confirm-msg  { text-align:center; color:var(--muted); font-size:14px; line-height:1.6; margin-bottom:8px; }
        .confirm-name { text-align:center; font-family:'Rajdhani',sans-serif; font-size:15px; color:var(--green); font-weight:600; margin-bottom:18px; }

        .alert { padding:10px 14px; margin-bottom:20px; font-size:13px; border-left:3px solid; }
        .alert-success { background:rgba(0,230,118,0.08); border-color:var(--green); color:var(--green); }
        .alert-error   { background:rgba(255,82,82,0.08); border-color:var(--red); color:#ff8a8a; }

        @media(max-width:900px) { .sidebar{transform:translateX(-100%);} .main-content{margin-left:0;} .stats-row{grid-template-columns:repeat(2,1fr);} }
        @media(max-width:600px) { .stats-row{grid-template-columns:1fr 1fr;} .content{padding:16px;} }
    </style>
</head>
<body>

<!-- ══ SIDEBAR ══ -->
<aside class="sidebar">
    <div class="sidebar-top">
        <a href="${pageContext.request.contextPath}/traderDashboard.jsp" class="sidebar-brand">
            <img src="${pageContext.request.contextPath}/logo2.png" class="sidebar-logo" alt="Logo"/>
            <span class="sidebar-name">StockVerdict</span>
        </a>
    </div>
    <div class="sidebar-user">
        <div class="sidebar-user-name">${sessionScope.currentUser.name}</div>
        <div class="sidebar-user-role">${sessionScope.currentUser.role}</div>
    </div>
    <nav class="sidebar-nav">
        <div class="nav-section-label">Main</div>
        <a href="${pageContext.request.contextPath}/traderDashboard.jsp" class="nav-item">
            <span class="nav-icon"><i class="fa-solid fa-house"></i></span> Dashboard
        </a>
        <a href="${pageContext.request.contextPath}/sales.jsp" class="nav-item active">
            <span class="nav-icon"><i class="fa-solid fa-chart-line"></i></span> Sales
        </a>
        <div class="nav-section-label">Inventory</div>
        <a href="${pageContext.request.contextPath}/traderDashboard.jsp" class="nav-item">
            <span class="nav-icon"><i class="fa-solid fa-boxes-stacked"></i></span> Stock Management
        </a>
        <a href="${pageContext.request.contextPath}/traderDashboard.jsp" class="nav-item">
            <span class="nav-icon"><i class="fa-solid fa-handshake"></i></span> Suppliers
        </a>
        <div class="nav-section-label">Account</div>
        <a href="${pageContext.request.contextPath}/settings.jsp" class="nav-item">
            <span class="nav-icon"><i class="fa-solid fa-gear"></i></span> Settings
        </a>
        <button class="nav-item danger" onclick="openLogoutModal()">
            <span class="nav-icon"><i class="fa-solid fa-right-from-bracket"></i></span> Logout
        </button>
    </nav>
    <div class="sidebar-bottom">
        <div style="padding:10px 20px;font-size:11px;color:var(--muted);">
            <span id="sidebarClock"></span>
        </div>
    </div>
</aside>

<!-- ══ MAIN ══ -->
<div class="main-content">
    <div class="topbar">
        <span class="topbar-title"><i class="fa-solid fa-chart-line" style="margin-right:8px;color:var(--green);"></i>Sales</span>
        <div class="topbar-right">
            <button class="btn-theme" id="themeToggle" onclick="toggleTheme()"><i class="fa-solid fa-moon"></i></button>
            <button class="btn-logout-top" onclick="openLogoutModal()"><i class="fa-solid fa-right-from-bracket"></i> Logout</button>
        </div>
    </div>

    <div class="content">

        <c:if test="${not empty param.success}">
            <div class="alert alert-success">
                <c:choose>
                    <c:when test="${param.success == 'added'}">✓ Sale recorded successfully.</c:when>
                    <c:when test="${param.success == 'updated'}">✓ Sale updated successfully.</c:when>
                    <c:when test="${param.success == 'deleted'}">✓ Sale deleted successfully.</c:when>
                    <c:otherwise>✓ Operation completed.</c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">⚠ An error occurred. Please try again.</div>
        </c:if>

        <div class="sec-header">
            <div>
                <div class="sec-eyebrow">Trader Panel</div>
                <div class="sec-title">Sales Management</div>
                <div class="sec-sub">Record, track, and manage your sales transactions</div>
            </div>
            <button class="btn-primary" onclick="openAddModal()">
                <i class="fa-solid fa-plus"></i> Add New Sale
            </button>
        </div>

        <!-- STATS -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-lbl">Total Sales</div>
                <div class="stat-val"><c:choose><c:when test="${not empty salesList}">${salesList.size()}</c:when><c:otherwise>0</c:otherwise></c:choose></div>
                <div class="stat-hint">All transactions</div>
            </div>
            <div class="stat-card">
                <div class="stat-lbl">Total Revenue</div>
                <div class="stat-val">Rwf <c:choose><c:when test="${not empty totalRevenue}"><fmt:formatNumber value="${totalRevenue}" pattern="#,##0.00"/></c:when><c:otherwise>0.00</c:otherwise></c:choose></div>
                <div class="stat-hint">Gross amount</div>
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
        <form method="get" action="${pageContext.request.contextPath}/sales.jsp">
            <div class="filter-bar">
                <div class="filter-group">
                    <span class="filter-label">From</span>
                    <input type="date" class="filter-input" name="dateFrom" value="${param.dateFrom}"/>
                </div>
                <div class="filter-group">
                    <span class="filter-label">To</span>
                    <input type="date" class="filter-input" name="dateTo" value="${param.dateTo}"/>
                </div>
                <div class="filter-group">
                    <span class="filter-label">Product</span>
                    <div class="select-wrap">
                        <select class="filter-select" name="productFilter">
                            <option value="">All Products</option>
                            <c:forEach var="product" items="${productList}">
                                <option value="${product.id}" <c:if test="${param.productFilter == product.id}">selected</c:if>>${product.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <button type="submit" class="btn-filter"><i class="fa-solid fa-filter"></i> Apply</button>
                <a href="${pageContext.request.contextPath}/sales.jsp" class="btn-reset"><i class="fa-solid fa-xmark"></i> Clear</a>
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
                                <td class="td-muted"><fmt:formatDate value="${sale.saleDate}" pattern="dd MMM yyyy"/></td>
                                <td class="td-green">${sale.saleItems[0].product.name}</td>
                                <td>${sale.saleItems[0].quantity}</td>
                                <td>Rwf <fmt:formatNumber value="${sale.saleItems[0].priceAtSale}" pattern="#,##0.00"/></td>
                                <td class="td-green">Rwf <fmt:formatNumber value="${sale.totalAmount}" pattern="#,##0.00"/></td>
                                <td><span class="badge badge-green">${sale.paymentMethod}</span></td>
                                <td class="td-muted"><c:choose><c:when test="${not empty sale.customer}">${sale.customer.name}</c:when><c:otherwise>—</c:otherwise></c:choose></td>
                                <td>
                                    <div class="action-btns">
                                        <button class="btn-edit" onclick="openEditModal('${sale.id}','${sale.saleItems[0].product.id}','${sale.saleItems[0].quantity}','${sale.saleItems[0].priceAtSale}','${sale.paymentMethod}','${sale.customer.id}')"><i class="fa-solid fa-pen"></i> Edit</button>
                                        <button class="btn-del"  onclick="openDeleteModal('${sale.id}','${sale.saleItems[0].product.name}')"><i class="fa-solid fa-trash"></i> Delete</button>
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
</div>

<!-- ══ ADD SALE MODAL ══ -->
<div class="modal-overlay" id="addModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">New Transaction</div><div class="modal-title">Add New Sale</div></div>
            <button class="modal-close" onclick="closeModal('addModal')">✕</button>
        </div>
        <form action="${pageContext.request.contextPath}/sales" method="post" id="addSaleForm">
            <input type="hidden" name="action" value="addSale"/>
            <div class="modal-body">
                <div class="field">
                    <label>Product</label>
                    <div style="position:relative;">
                        <input type="text" id="addSearchInput" list="productsList" placeholder="Type to search products..." style="width:100%; padding: 0.6rem; border:1px solid var(--border-light); border-radius:6px; background:var(--bg-mid); color:var(--text); font-family:inherit; margin-bottom: 5px;" oninput="onProductSearchSelect(this)" autocomplete="off" required>
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
                        <div class="field-note" id="stockNote"></div>
                    </div>
                    <div class="field">
                        <label>Unit Price (Rwf)</label>
                        <input type="number" name="unitPrice" id="addPrice" step="0.01" min="0" placeholder="0.00" required oninput="calcTotal('add')"/>
                        <div class="field-note">Defaults to product price</div>
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
                <div class="total-preview">
                    <span class="total-lbl">Total Amount</span>
                    <span class="total-val" id="addTotal">Rwf 0.00</span>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('addModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fa-solid fa-floppy-disk"></i> Save Sale</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ EDIT SALE MODAL ══ -->
<div class="modal-overlay" id="editModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Update Transaction</div><div class="modal-title">Edit Sale</div></div>
            <button class="modal-close" onclick="closeModal('editModal')">✕</button>
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
                <div class="total-preview">
                    <span class="total-lbl">Total Amount</span>
                    <span class="total-val" id="editTotal">Rwf 0.00</span>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('editModal')">Cancel</button>
                <button type="submit" class="btn-primary"><i class="fa-solid fa-floppy-disk"></i> Update Sale</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ DELETE CONFIRM MODAL ══ -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Confirm Action</div><div class="modal-title">Delete Sale</div></div>
            <button class="modal-close" onclick="closeModal('deleteModal')">✕</button>
        </div>
        <form action="${pageContext.request.contextPath}/sales" method="post">
            <input type="hidden" name="action" value="deleteSale"/>
            <input type="hidden" name="saleId" id="deleteSaleId"/>
            <div class="modal-body">
                <div class="confirm-icon"><i class="fa-solid fa-triangle-exclamation" style="color:var(--red);font-size:38px;"></i></div>
                <div class="confirm-msg">You are about to permanently delete this sale record.</div>
                <div class="confirm-name" id="deleteSaleName"></div>
                <div class="confirm-msg">This action cannot be undone.</div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeModal('deleteModal')">Cancel</button>
                <button type="submit" class="btn-danger"><i class="fa-solid fa-trash"></i> Yes, Delete</button>
            </div>
        </form>
    </div>
</div>

<!-- ══ LOGOUT CONFIRM MODAL ══ -->
<div class="modal-overlay" id="logoutModal">
    <div class="modal">
        <div class="modal-hdr">
            <div><div class="modal-eyebrow">Confirm</div><div class="modal-title">Log Out</div></div>
            <button class="modal-close" onclick="closeModal('logoutModal')">✕</button>
        </div>
        <div class="modal-body">
            <div class="confirm-icon"><i class="fa-solid fa-right-from-bracket" style="color:var(--green);font-size:38px;"></i></div>
            <div class="confirm-msg">Are you sure you want to log out of StockVerdict?</div>
            <div class="confirm-name">Any unsaved changes will be lost.</div>
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" onclick="closeModal('logoutModal')">Stay Logged In</button>
            <a href="${pageContext.request.contextPath}/user?action=logout" class="btn-danger"><i class="fa-solid fa-right-from-bracket"></i> Yes, Log Out</a>
        </div>
    </div>
</div>

<script>
    const THEME_KEY = 'sv_theme';
    function applyTheme(t) {
        document.documentElement.setAttribute('data-theme', t);
        const btn = document.getElementById('themeToggle');
        if (btn) btn.innerHTML = t === 'light' ? '<i class="fa-solid fa-moon"></i>' : '<i class="fa-solid fa-sun"></i>';
        localStorage.setItem(THEME_KEY, t);
    }
    function toggleTheme() { applyTheme((document.documentElement.getAttribute('data-theme')||'dark')==='dark'?'light':'dark'); }
    applyTheme(localStorage.getItem(THEME_KEY)||'dark');

    function openModal(id)  { document.getElementById(id).classList.add('open'); document.body.style.overflow='hidden'; }
    function closeModal(id) { document.getElementById(id).classList.remove('open'); document.body.style.overflow=''; }
    document.querySelectorAll('.modal-overlay').forEach(o => o.addEventListener('click', e => { if(e.target===o){o.classList.remove('open');document.body.style.overflow='';} }));
    document.addEventListener('keydown', e => { if(e.key==='Escape') document.querySelectorAll('.modal-overlay.open').forEach(m=>{m.classList.remove('open');document.body.style.overflow='';}); });

    function openAddModal()    { openModal('addModal'); }
    function openLogoutModal() { openModal('logoutModal'); }

    function openEditModal(saleId, productId, qty, price, payment, customerId) {
        document.getElementById('editSaleId').value = saleId;
        document.getElementById('editQty').value    = qty;
        document.getElementById('editPrice').value  = price;
        for(let o of document.getElementById('editProduct').options)  { if(o.value==productId)  {o.selected=true;break;} }
        for(let o of document.getElementById('editPayment').options)  { if(o.value==payment)    {o.selected=true;break;} }
        for(let o of document.getElementById('editCustomer').options) { if(o.value==customerId) {o.selected=true;break;} }
        calcTotal('edit');
        openModal('editModal');
    }

    function openDeleteModal(saleId, productName) {
        document.getElementById('deleteSaleId').value = saleId;
        document.getElementById('deleteSaleName').textContent = productName + ' — Sale #' + saleId;
        openModal('deleteModal');
    }

    function prefillPrice(select) {
        // Obsolete for Add Modal since we use datalist, but keeping for reference if Edit modal uses it
        const opt = select.options[select.selectedIndex];
        const price = opt ? (opt.getAttribute('data-price') || '') : '';
        const stock = opt ? (opt.getAttribute('data-stock') || '') : '';
        if (document.getElementById('editPrice')) document.getElementById('editPrice').value = price ? parseFloat(price).toFixed(2) : '';
        calcTotal('edit');
    }

    function onProductSearchSelect(input) {
        let val = input.value;
        let dataList = document.getElementById('productsList');
        let options = dataList.options;
        for (let i = 0; i < options.length; i++) {
            if (options[i].value === val) {
                document.getElementById('hiddenProductId').value = options[i].getAttribute('data-id');
                let price = options[i].getAttribute('data-price') || '';
                let stock = options[i].getAttribute('data-stock') || '';
                document.getElementById('addPrice').value = price ? parseFloat(price).toFixed(2) : '';
                document.getElementById('stockNote').textContent = stock ? 'Available: ' + stock + ' units' : '';
                calcTotal('add');
                return;
            }
        }
        document.getElementById('hiddenProductId').value = '';
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

    function updateClock() {
        const el = document.getElementById('sidebarClock');
        if(el) el.textContent = new Date().toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'});
    }
    updateClock(); setInterval(updateClock, 1000);

    setTimeout(() => {
        document.querySelectorAll('.alert').forEach(el => { el.style.transition='opacity 0.5s'; el.style.opacity='0'; setTimeout(()=>el.remove(),500); });
    }, 5000);
</script>
</body>
</html>