<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — StockVerdict</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo2.png"/>
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>

    <%-- Iconify CSS icon files --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/analytics.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/brightness.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/moon.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/growth.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/handshake.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/chart.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/edit.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/delete.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/package.css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/palette.css"/>

    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green:      #00e676;
            --green-dim:  #00c853;
            --green-glow: rgba(0,230,118,0.2);
            --bg:         #040e07;
            --bg-card:    rgba(4,18,9,0.92);
            --border:     rgba(0,230,118,0.18);
            --border-hi:  rgba(0,230,118,0.4);
            --text:       #e4ffe4;
            --text-sub:   #a8d4b0;
            --muted:      #5a9a6a;
            --surface:    rgba(0,20,8,0.6);
            --red:        #ff5252;
            --red-glow:   rgba(255,82,82,0.15);
            --amber:      #ffb300;
            --amber-glow: rgba(255,179,0,0.15);
            --sidebar-w:  240px;
        }
        [data-theme="light"] {
            --bg:         #f0faf2;
            --bg-card:    rgba(255,255,255,0.95);
            --border:     rgba(0,180,80,0.2);
            --border-hi:  rgba(0,180,80,0.5);
            --text:       #0a2e12;
            --text-sub:   #2d6e3e;
            --muted:      #4a8a5a;
            --surface:    rgba(220,245,225,0.7);
            --green:      #00a84a;
            --green-dim:  #007a35;
            --green-glow: rgba(0,168,74,0.15);
        }
        [data-theme="light"] .stash--moon,
        [data-theme="light"] .icon-park-twotone--brightness,
        [data-theme="light"] .mingcute--chart-bar-line,
        [data-theme="light"] .fluent--arrow-growth-20-regular,
        [data-theme="light"] .emojione-monotone--handshake {
            filter: invert(1) brightness(0.3) sepia(1) hue-rotate(90deg) saturate(4);
        }

        html { scroll-behavior: smooth; }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg); color: var(--text);
            min-height: 100vh; display: flex;
            transition: background 0.3s, color 0.3s;
        }

        /* ── Sidebar ── */
        .sidebar {
            width: var(--sidebar-w); min-height: 100vh;
            background: var(--bg-card); border-right: 1px solid var(--border);
            display: flex; flex-direction: column;
            position: fixed; top: 0; left: 0; z-index: 50;
            transition: background 0.3s;
        }
        .sidebar-brand {
            display: flex; align-items: center; gap: 10px;
            padding: 20px 20px 16px; border-bottom: 1px solid var(--border);
            text-decoration: none;
        }
        .sidebar-logo { width: 32px; height: 32px; border-radius: 50%; object-fit: contain; border: 1px solid var(--border-hi); }
        .sidebar-name {
            font-family: 'Rajdhani', sans-serif; font-size: 17px; font-weight: 700;
            color: var(--green); letter-spacing: 0.08em; text-transform: uppercase;
        }
        .sidebar-section {
            font-size: 9px; letter-spacing: 0.22em; text-transform: uppercase;
            color: var(--muted); padding: 18px 20px 6px;
        }
        .nav-item {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 20px; color: var(--text-sub); text-decoration: none;
            font-size: 13px; font-weight: 500; cursor: pointer;
            border-left: 2px solid transparent;
            transition: color 0.2s, background 0.2s, border-color 0.2s;
        }
        .nav-item:hover, .nav-item.active {
            color: var(--green); background: var(--green-glow);
            border-left-color: var(--green);
        }
        .nav-item .nav-icon { width: 18px; height: 18px; opacity: 0.8; }
        .sidebar-footer {
            margin-top: auto; padding: 16px 20px;
            border-top: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
        }
        .admin-tag {
            font-size: 11px; color: var(--muted);
        }
        .admin-tag span { color: var(--green); font-weight: 600; }

        /* ── Main ── */
        .main {
            margin-left: var(--sidebar-w); flex: 1;
            display: flex; flex-direction: column; min-height: 100vh;
        }
        .topbar {
            height: 60px; background: var(--bg-card);
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 32px; position: sticky; top: 0; z-index: 40;
            backdrop-filter: blur(12px);
        }
        .topbar-title {
            font-family: 'Rajdhani', sans-serif; font-size: 18px; font-weight: 700;
            color: var(--text); letter-spacing: 0.05em; text-transform: uppercase;
        }
        .topbar-actions { display: flex; align-items: center; gap: 10px; }
        .btn-theme {
            width: 34px; height: 34px; background: var(--surface);
            border: 1px solid var(--border); color: var(--muted);
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: border-color 0.2s, color 0.2s;
        }
        .btn-theme:hover { border-color: var(--green); color: var(--green); }
        .btn-theme .icon-park-twotone--brightness,
        .btn-theme .stash--moon { width: 18px !important; height: 18px !important; }

        .content { padding: 28px 32px; flex: 1; }

        /* ── Stat cards ── */
        .stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 28px; }
        .stat-card {
            background: var(--surface); border: 1px solid var(--border);
            padding: 20px 22px; position: relative; overflow: hidden;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .stat-card:hover { border-color: var(--border-hi); box-shadow: 0 0 20px var(--green-glow); }
        .stat-card::after {
            content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 2px;
            background: linear-gradient(90deg, transparent, var(--green), transparent); opacity: 0.5;
        }
        .stat-card.red::after  { background: linear-gradient(90deg, transparent, var(--red), transparent); }
        .stat-card.amber::after { background: linear-gradient(90deg, transparent, var(--amber), transparent); }
        .stat-label { font-size: 10px; letter-spacing: 0.18em; text-transform: uppercase; color: var(--muted); margin-bottom: 8px; }
        .stat-value {
            font-family: 'Rajdhani', sans-serif; font-size: 34px; font-weight: 700;
            color: var(--green); line-height: 1;
        }
        .stat-card.red .stat-value  { color: var(--red); }
        .stat-card.amber .stat-value { color: var(--amber); }
        .stat-sub { font-size: 11px; color: var(--muted); margin-top: 5px; }

        /* ── Section title ── */
        .sec-head {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 16px;
        }
        .sec-title {
            font-family: 'Rajdhani', sans-serif; font-size: 15px; font-weight: 700;
            color: var(--text); letter-spacing: 0.06em; text-transform: uppercase;
        }

        /* ── Report tabs ── */
        .tab-row { display: flex; gap: 4px; margin-bottom: 20px; }
        .tab-btn {
            padding: 7px 18px; background: var(--surface);
            border: 1px solid var(--border); color: var(--muted);
            font-family: 'Rajdhani', sans-serif; font-size: 12px;
            font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase;
            cursor: pointer; transition: all 0.2s;
        }
        .tab-btn:hover { border-color: var(--green); color: var(--green); }
        .tab-btn.active { background: var(--green-glow); border-color: var(--green); color: var(--green); }

        /* ── Chart card ── */
        .chart-card {
            background: var(--surface); border: 1px solid var(--border);
            padding: 24px; margin-bottom: 28px;
        }
        .chart-wrap { position: relative; height: 280px; }

        /* ── Two-col layout ── */
        .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 28px; }

        /* ── Trader table ── */
        .table-card {
            background: var(--surface); border: 1px solid var(--border);
            overflow: hidden; margin-bottom: 28px;
        }
        .table-toolbar {
            display: flex; align-items: center; justify-content: space-between;
            padding: 16px 20px; border-bottom: 1px solid var(--border); gap: 12px; flex-wrap: wrap;
        }
        .search-wrap { position: relative; }
        .search-input {
            background: var(--bg-card); border: 1px solid var(--border);
            color: var(--text); font-size: 12px; padding: 8px 12px 8px 34px;
            width: 240px; outline: none; font-family: 'Inter', sans-serif;
            transition: border-color 0.2s;
        }
        .search-input::placeholder { color: var(--muted); }
        .search-input:focus { border-color: var(--green); }
        .search-icon {
            position: absolute; left: 10px; top: 50%; transform: translateY(-50%);
            font-size: 13px; color: var(--muted); pointer-events: none;
        }
        .filter-select {
            background: var(--bg-card); border: 1px solid var(--border);
            color: var(--text); font-size: 12px; padding: 8px 12px;
            outline: none; font-family: 'Inter', sans-serif; cursor: pointer;
        }
        table { width: 100%; border-collapse: collapse; }
        thead tr { background: rgba(0,230,118,0.05); }
        th {
            text-align: left; padding: 11px 16px;
            font-size: 10px; letter-spacing: 0.16em; text-transform: uppercase;
            color: var(--muted); font-weight: 600; border-bottom: 1px solid var(--border);
        }
        td {
            padding: 12px 16px; font-size: 13px; color: var(--text-sub);
            border-bottom: 1px solid var(--border);
        }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: var(--green-glow); }

        .badge {
            display: inline-block; padding: 3px 10px;
            font-size: 10px; font-weight: 600; letter-spacing: 0.1em; text-transform: uppercase;
        }
        .badge-green  { background: rgba(0,230,118,0.12); color: var(--green); border: 1px solid rgba(0,230,118,0.3); }
        .badge-red    { background: rgba(255,82,82,0.1);  color: var(--red);   border: 1px solid rgba(255,82,82,0.3); }
        .badge-amber  { background: rgba(255,179,0,0.1);  color: var(--amber); border: 1px solid rgba(255,179,0,0.3); }

        .action-btns { display: flex; gap: 6px; }
        .btn-act {
            padding: 5px 10px; font-size: 10px; font-weight: 600;
            letter-spacing: 0.1em; text-transform: uppercase;
            border: 1px solid; cursor: pointer; background: transparent;
            font-family: 'Rajdhani', sans-serif; transition: background 0.2s;
        }
        .btn-act-green  { color: var(--green); border-color: rgba(0,230,118,0.3); }
        .btn-act-green:hover { background: var(--green-glow); }
        .btn-act-amber  { color: var(--amber); border-color: rgba(255,179,0,0.3); }
        .btn-act-amber:hover { background: var(--amber-glow); }
        .btn-act-red    { color: var(--red);   border-color: rgba(255,82,82,0.3); }
        .btn-act-red:hover  { background: var(--red-glow); }

        /* ── Top lists ── */
        .list-card {
            background: var(--surface); border: 1px solid var(--border); padding: 20px;
        }
        .list-item {
            display: flex; align-items: center; justify-content: space-between;
            padding: 10px 0; border-bottom: 1px solid var(--border);
        }
        .list-item:last-child { border-bottom: none; }
        .list-rank {
            font-family: 'Rajdhani', sans-serif; font-size: 18px; font-weight: 700;
            color: var(--green); opacity: 0.4; width: 28px; flex-shrink: 0;
        }
        .list-info { flex: 1; margin: 0 12px; }
        .list-name { font-size: 13px; color: var(--text); font-weight: 500; }
        .list-sub  { font-size: 11px; color: var(--muted); margin-top: 2px; }
        .list-val  {
            font-family: 'Rajdhani', sans-serif; font-size: 16px; font-weight: 700;
            color: var(--green); white-space: nowrap;
        }

        /* ── Pagination ── */
        .pagination {
            display: flex; align-items: center; justify-content: flex-end;
            gap: 4px; padding: 14px 20px; border-top: 1px solid var(--border);
        }
        .page-btn {
            width: 30px; height: 30px; background: var(--surface);
            border: 1px solid var(--border); color: var(--muted);
            font-size: 12px; cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: all 0.2s;
        }
        .page-btn:hover, .page-btn.active { border-color: var(--green); color: var(--green); background: var(--green-glow); }

        /* ── Modal ── */
        .modal-overlay {
            display: none; position: fixed; inset: 0; z-index: 200;
            background: rgba(0,0,0,0.7); align-items: center; justify-content: center;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            background: var(--bg-card); border: 1px solid var(--border-hi);
            padding: 28px; width: 100%; max-width: 440px;
            box-shadow: 0 0 40px var(--green-glow);
        }
        .modal-title {
            font-family: 'Rajdhani', sans-serif; font-size: 18px; font-weight: 700;
            color: var(--text); letter-spacing: 0.05em; margin-bottom: 16px;
        }
        .modal-body { font-size: 13px; color: var(--text-sub); line-height: 1.7; margin-bottom: 24px; }
        .modal-body strong { color: var(--text); }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; }
        .btn-modal-cancel {
            padding: 9px 22px; background: transparent;
            border: 1px solid var(--border); color: var(--muted);
            font-family: 'Rajdhani', sans-serif; font-size: 12px; font-weight: 600;
            letter-spacing: 0.14em; text-transform: uppercase; cursor: pointer;
            transition: border-color 0.2s;
        }
        .btn-modal-cancel:hover { border-color: var(--green); color: var(--green); }
        .btn-modal-confirm {
            padding: 9px 22px; background: var(--red); color: #fff;
            border: none; font-family: 'Rajdhani', sans-serif; font-size: 12px;
            font-weight: 700; letter-spacing: 0.14em; text-transform: uppercase;
            cursor: pointer; transition: opacity 0.2s;
        }
        .btn-modal-confirm:hover { opacity: 0.85; }

        @media (max-width: 1024px) {
            .stats-row { grid-template-columns: repeat(2, 1fr); }
            .two-col   { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); transition: transform 0.3s; }
            .sidebar.open { transform: translateX(0); }
            .main { margin-left: 0; }
            .stats-row { grid-template-columns: 1fr 1fr; }
            .content { padding: 20px 16px; }
        }
    </style>
</head>
<body>

<!-- ═══════════════ SIDEBAR ═══════════════ -->
<aside class="sidebar" id="sidebar">
    <a href="${pageContext.request.contextPath}/adminDashboard.jsp" class="sidebar-brand">
        <img src="${pageContext.request.contextPath}/logo2.png" class="sidebar-logo" alt="Logo"/>
        <span class="sidebar-name">StockVerdict Admin</span>
    </a>

    <div class="sidebar-section">Overview</div>
    <a class="nav-item active" onclick="showSection('dashboard')">
        <span class="mingcute--chart-bar-line nav-icon"></span> Dashboard
    </a>

    <div class="sidebar-section">Reports</div>
    <a class="nav-item" onclick="showSection('reports')">
        <span class="fluent--arrow-growth-20-regular nav-icon"></span> Sales Reports
    </a>

    <div class="sidebar-section">Management</div>
    <a class="nav-item" onclick="showSection('traders')">
        <span class="emojione-monotone--handshake nav-icon"></span> Traders
    </a>

    <div class="sidebar-footer">
        <div class="admin-tag">Logged in as <span>Admin</span></div>
        <a href="${pageContext.request.contextPath}/user?action=logout" style="font-size:11px;color:var(--red);text-decoration:none;">Logout</a>
    </div>
</aside>

<!-- ═══════════════ MAIN ═══════════════ -->
<div class="main">

    <!-- Topbar -->
    <div class="topbar">
        <div class="topbar-title" id="topbarTitle">Dashboard</div>
        <div class="topbar-actions">
            <button class="btn-theme" id="themeToggle" onclick="toggleTheme()" title="Toggle theme">
                <span id="themeIcon" class="icon-park-twotone--brightness"></span>
            </button>
        </div>
    </div>

    <!-- Content -->
    <div class="content">

        <!-- ══════ DASHBOARD SECTION ══════ -->
        <div id="section-dashboard">

            <!-- Stat cards -->
            <div class="stats-row">
                <div class="stat-card">
                    <div class="stat-label">Total Traders</div>
                    <div class="stat-value">${totalTraders != null ? totalTraders : '0'}</div>
                    <div class="stat-sub">Registered accounts</div>
                </div>
                <div class="stat-card amber">
                    <div class="stat-label">Pending Approval</div>
                    <div class="stat-value amber">${pendingTraders != null ? pendingTraders : '0'}</div>
                    <div class="stat-sub">Awaiting review</div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Total Sales (Month)</div>
                    <div class="stat-value">$${monthlySales != null ? monthlySales : '0'}</div>
                    <div class="stat-sub">Current month</div>
                </div>
                <div class="stat-card red">
                    <div class="stat-label">Inactive Traders</div>
                    <div class="stat-value">${inactiveTraders != null ? inactiveTraders : '0'}</div>
                    <div class="stat-sub">Deactivated accounts</div>
                </div>
            </div>

            <!-- Sales growth chart -->
            <div class="sec-head">
                <div class="sec-title">Sales Growth</div>
                <div class="tab-row">
                    <button class="tab-btn active" onclick="switchChart('daily', this)">Daily</button>
                    <button class="tab-btn" onclick="switchChart('weekly', this)">Weekly</button>
                    <button class="tab-btn" onclick="switchChart('monthly', this)">Monthly</button>
                </div>
            </div>
            <div class="chart-card">
                <div class="chart-wrap">
                    <canvas id="salesChart"></canvas>
                </div>
            </div>

            <!-- Top products & top traders -->
            <div class="two-col">
                <div class="list-card">
                    <div class="sec-head" style="margin-bottom:12px">
                        <div class="sec-title">🏆 Top Selling Products</div>
                    </div>
                    <c:choose>
                        <c:when test="${not empty topProducts}">
                            <c:forEach var="p" items="${topProducts}" varStatus="s">
                                <div class="list-item">
                                    <div class="list-rank">0${s.index + 1}</div>
                                    <div class="list-info">
                                        <div class="list-name">${p.name}</div>
                                        <div class="list-sub">${p.category}</div>
                                    </div>
                                    <div class="list-val">${p.unitsSold} sold</div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <%-- Placeholder rows until real data is wired --%>
                            <div class="list-item">
                                <div class="list-rank">01</div>
                                <div class="list-info"><div class="list-name">— No data yet —</div><div class="list-sub">Wire topProducts from servlet</div></div>
                                <div class="list-val">—</div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="list-card">
                    <div class="sec-head" style="margin-bottom:12px">
                        <div class="sec-title">🥇 Top Performing Traders</div>
                    </div>
                    <c:choose>
                        <c:when test="${not empty topTraders}">
                            <c:forEach var="t" items="${topTraders}" varStatus="s">
                                <div class="list-item">
                                    <div class="list-rank">0${s.index + 1}</div>
                                    <div class="list-info">
                                        <div class="list-name">${t.fullName}</div>
                                        <div class="list-sub">${t.email}</div>
                                    </div>
                                    <div class="list-val">$${t.totalSales}</div>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="list-item">
                                <div class="list-rank">01</div>
                                <div class="list-info"><div class="list-name">— No data yet —</div><div class="list-sub">Wire topTraders from servlet</div></div>
                                <div class="list-val">—</div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div><!-- /section-dashboard -->

        <!-- ══════ REPORTS SECTION ══════ -->
        <div id="section-reports" style="display:none">
            <div class="sec-head">
                <div class="sec-title">Sales Reports</div>
                <div class="tab-row">
                    <button class="tab-btn active" onclick="switchReport('daily', this)">Daily</button>
                    <button class="tab-btn" onclick="switchReport('weekly', this)">Weekly</button>
                    <button class="tab-btn" onclick="switchReport('monthly', this)">Monthly</button>
                </div>
            </div>
            <div class="chart-card" style="margin-bottom:28px">
                <div class="chart-wrap">
                    <canvas id="reportChart"></canvas>
                </div>
            </div>

            <div class="table-card">
                <div class="table-toolbar">
                    <div class="sec-title">Report Summary</div>
                </div>
                <table>
                    <thead>
                    <tr>
                        <th>Period</th>
                        <th>Total Sales</th>
                        <th>Orders</th>
                        <th>Avg. Order Value</th>
                        <th>Top Product</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${not empty reportData}">
                            <c:forEach var="r" items="${reportData}">
                                <tr>
                                    <td>${r.period}</td>
                                    <td style="color:var(--green)">$${r.totalSales}</td>
                                    <td>${r.orderCount}</td>
                                    <td>$${r.avgOrderValue}</td>
                                    <td>${r.topProduct}</td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="5" style="text-align:center;color:var(--muted);padding:28px">No report data available. Wire reportData from servlet.</td></tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div><!-- /section-reports -->

        <!-- ══════ TRADERS SECTION ══════ -->
        <div id="section-traders" style="display:none">
            <div class="table-card">
                <div class="table-toolbar">
                    <div class="sec-title">All Traders</div>
                    <div style="display:flex;gap:10px;align-items:center;flex-wrap:wrap">
                        <div class="search-wrap">
                            <span class="search-icon">⌕</span>
                            <input type="text" class="search-input" id="traderSearch"
                                   placeholder="Search name or email..."
                                   oninput="filterTraders()"/>
                        </div>
                        <select class="filter-select" id="statusFilter" onchange="filterTraders()">
                            <option value="">All Status</option>
                            <option value="active">Active</option>
                            <option value="pending">Pending</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                </div>

                <table id="traderTable">
                    <thead>
                    <tr>
                        <th>#</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Joined</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                    </thead>
                    <tbody id="traderBody">
                    <c:choose>
                        <c:when test="${not empty traders}">
                            <c:forEach var="t" items="${traders}" varStatus="s">
                                <tr data-name="${t.fullName.toLowerCase()}"
                                    data-email="${t.email.toLowerCase()}"
                                    data-status="${t.status.toLowerCase()}">
                                    <td style="color:var(--muted)">${s.index + 1}</td>
                                    <td style="color:var(--text);font-weight:500">${t.fullName}</td>
                                    <td>${t.email}</td>
                                    <td>${t.joinDate}</td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${t.status == 'active'}">
                                                <span class="badge badge-green">Active</span>
                                            </c:when>
                                            <c:when test="${t.status == 'pending'}">
                                                <span class="badge badge-amber">Pending</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-red">Inactive</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="action-btns">
                                            <c:if test="${t.status == 'pending'}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/approveTrader" style="display:inline">
                                                    <input type="hidden" name="traderId" value="${t.id}"/>
                                                    <button type="submit" class="btn-act btn-act-green">Approve</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${t.status == 'active'}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/deactivateTrader" style="display:inline">
                                                    <input type="hidden" name="traderId" value="${t.id}"/>
                                                    <button type="submit" class="btn-act btn-act-amber">Deactivate</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${t.status == 'inactive'}">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/activateTrader" style="display:inline">
                                                    <input type="hidden" name="traderId" value="${t.id}"/>
                                                    <button type="submit" class="btn-act btn-act-green">Activate</button>
                                                </form>
                                            </c:if>
                                            <button class="btn-act btn-act-red"
                                                    onclick="confirmDelete('${t.id}', '${t.fullName}')">Delete</button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr><td colspan="6" style="text-align:center;color:var(--muted);padding:28px">No traders found. Wire traders list from servlet.</td></tr>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>

                <div class="pagination">
                    <button class="page-btn active">1</button>
                    <button class="page-btn">2</button>
                    <button class="page-btn">3</button>
                    <button class="page-btn">›</button>
                </div>
            </div>
        </div><!-- /section-traders -->

    </div><!-- /content -->
</div><!-- /main -->

<!-- ═══════════════ DELETE MODAL ═══════════════ -->
<div class="modal-overlay" id="deleteModal">
    <div class="modal">
        <div class="modal-title">Confirm Delete</div>
        <div class="modal-body">
            Are you sure you want to permanently delete trader
            <strong id="modalTraderName"></strong>?
            This action cannot be undone.
        </div>
        <div class="modal-actions">
            <button class="btn-modal-cancel" onclick="closeModal()">Cancel</button>
            <form method="post" action="${pageContext.request.contextPath}/admin/deleteTrader" style="display:inline">
                <input type="hidden" name="traderId" id="modalTraderId"/>
                <button type="submit" class="btn-modal-confirm">Delete</button>
            </form>
        </div>
    </div>
</div>

<script>
    /* ── Theme ── */
    const THEME_KEY = 'sv_theme';
    const themeIcon = document.getElementById('themeIcon');
    function applyTheme(t) {
        document.documentElement.setAttribute('data-theme', t);
        themeIcon.className = t === 'dark' ? 'icon-park-twotone--brightness' : 'stash--moon';
        localStorage.setItem(THEME_KEY, t);
        updateChartTheme(t);
    }
    function toggleTheme() {
        const cur = document.documentElement.getAttribute('data-theme') || 'dark';
        applyTheme(cur === 'dark' ? 'light' : 'dark');
    }

    /* ── Section navigation ── */
    const sections = ['dashboard', 'reports', 'traders'];
    const titles   = { dashboard: 'Dashboard', reports: 'Sales Reports', traders: 'Trader Management' };
    function showSection(name) {
        sections.forEach(s => {
            document.getElementById('section-' + s).style.display = s === name ? '' : 'none';
        });
        document.getElementById('topbarTitle').textContent = titles[name];
        document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
        event.currentTarget.classList.add('active');
    }

    /* ── Chart data ── */
    const chartData = {
        daily:   { labels: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],       data: [420,380,610,540,700,830,590] },
        weekly:  { labels: ['Week 1','Week 2','Week 3','Week 4'],              data: [3200,4100,3750,5200] },
        monthly: { labels: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'], data: [12000,14500,13200,17000,15800,19200,21000,18500,22000,20100,24500,27000] }
    };

    function chartConfig(labels, data, color) {
        return {
            type: 'line',
            data: {
                labels,
                datasets: [{
                    label: 'Sales (Rwf)',
                    data,
                    borderColor: color,
                    backgroundColor: color.replace('1)', '0.08)'),
                    borderWidth: 2,
                    pointBackgroundColor: color,
                    pointRadius: 4,
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    x: { grid: { color: 'rgba(0,230,118,0.06)' }, ticks: { color: '#5a9a6a', font: { size: 11 } } },
                    y: { grid: { color: 'rgba(0,230,118,0.06)' }, ticks: { color: '#5a9a6a', font: { size: 11 }, callback: v => '$' + v.toLocaleString() } }
                }
            }
        };
    }

    const GREEN = 'rgba(0,230,118,1)';
    let salesChart, reportChart;

    window.addEventListener('DOMContentLoaded', () => {
        const d = chartData.daily;
        salesChart  = new Chart(document.getElementById('salesChart'),  chartConfig(d.labels, d.data, GREEN));
        reportChart = new Chart(document.getElementById('reportChart'), chartConfig(d.labels, d.data, GREEN));
        applyTheme(localStorage.getItem(THEME_KEY) || 'dark');
    });

    function switchChart(period, btn) {
        btn.closest('.tab-row').querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        const { labels, data } = chartData[period];
        salesChart.data.labels = labels;
        salesChart.data.datasets[0].data = data;
        salesChart.update();
    }
    function switchReport(period, btn) {
        btn.closest('.tab-row').querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        const { labels, data } = chartData[period];
        reportChart.data.labels = labels;
        reportChart.data.datasets[0].data = data;
        reportChart.update();
    }
    function updateChartTheme(t) {
        const tickColor = t === 'light' ? '#2d6e3e' : '#5a9a6a';
        const gridColor = t === 'light' ? 'rgba(0,168,74,0.08)' : 'rgba(0,230,118,0.06)';
        const color     = t === 'light' ? 'rgba(0,168,74,1)' : GREEN;
        [salesChart, reportChart].forEach(c => {
            if (!c) return;
            c.data.datasets[0].borderColor = color;
            c.data.datasets[0].backgroundColor = color.replace('1)', '0.08)');
            c.data.datasets[0].pointBackgroundColor = color;
            c.options.scales.x.grid.color = gridColor;
            c.options.scales.x.ticks.color = tickColor;
            c.options.scales.y.grid.color = gridColor;
            c.options.scales.y.ticks.color = tickColor;
            c.update();
        });
    }

    /* ── Trader search & filter ── */
    function filterTraders() {
        const q      = document.getElementById('traderSearch').value.toLowerCase();
        const status = document.getElementById('statusFilter').value.toLowerCase();
        document.querySelectorAll('#traderBody tr').forEach(row => {
            const name  = row.dataset.name  || '';
            const email = row.dataset.email || '';
            const st    = row.dataset.status || '';
            const matchQ = !q || name.includes(q) || email.includes(q);
            const matchS = !status || st === status;
            row.style.display = matchQ && matchS ? '' : 'none';
        });
    }

    /* ── Delete modal ── */
    function confirmDelete(id, name) {
        document.getElementById('modalTraderId').value = id;
        document.getElementById('modalTraderName').textContent = name;
        document.getElementById('deleteModal').classList.add('open');
    }
    function closeModal() {
        document.getElementById('deleteModal').classList.remove('open');
    }
    document.getElementById('deleteModal').addEventListener('click', e => {
        if (e.target === e.currentTarget) closeModal();
    });
</script>
</body>
</html>